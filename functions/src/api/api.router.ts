import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import {
  authMiddleware,
  requireAdmin,
  requireEmailVerification,
} from '../shared/middleware/auth.middleware';
import { requestLogger, corsConfig } from '../shared/middleware/validation.middleware';
import { adminRateLimit } from '../shared/middleware/ratelimit.middleware';
import { globalErrorHandler } from '../shared/errors/error.handler';
import { getFirestore } from '../shared/config/firebase.config';
import { Collections } from '../shared/constants/collections.constants';
import { Timestamp } from 'firebase-admin/firestore';

const app = express();

// ─── Global Middleware ───
app.use(helmet());
app.use(cors(corsConfig()));
app.use(express.json({ limit: '10mb' }));
app.use(requestLogger);

// ─── Health Check ───
app.get('/health', (_req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString(), version: '1.0.0' });
});

// ─── Admin API Routes ───
const adminRouter = express.Router();
adminRouter.use(authMiddleware);
adminRouter.use(requireEmailVerification);
adminRouter.use(requireAdmin);
adminRouter.use(adminRateLimit);

// GET /admin/users — list users
adminRouter.get('/users', async (req, res, next) => {
  try {
    const db = getFirestore();
    const { page = '1', pageSize = '20', tier, status } = req.query;
    const limit = Math.min(parseInt(pageSize as string) || 20, 100);
    const offset = (parseInt(page as string) - 1) * limit;

    let query = db
      .collection(Collections.USERS)
      .orderBy('createdAt', 'desc')
      .limit(limit)
      .offset(offset);

    if (tier)
      query = db
        .collection(Collections.USERS)
        .where('subscription.tier', '==', tier)
        .limit(limit)
        .offset(offset);
    if (status)
      query = db
        .collection(Collections.USERS)
        .where('accountStatus', '==', status)
        .limit(limit)
        .offset(offset);

    const snap = await query.get();
    const users = snap.docs.map((d) => ({
      uid: d.id,
      email: d.data().email,
      displayName: d.data().displayName,
      username: d.data().username,
      tier: d.data().subscription?.tier,
      status: d.data().accountStatus,
      level: d.data().stats?.level,
      createdAt: d.data().createdAt?.toDate(),
    }));

    res.json({
      success: true,
      data: users,
      meta: { page: parseInt(page as string), pageSize: limit },
    });
  } catch (err) {
    next(err);
  }
});

// GET /admin/users/:uid — full user profile
adminRouter.get('/users/:uid', async (req, res, next) => {
  try {
    const db = getFirestore();
    const snap = await db.collection(Collections.USERS).doc(req.params.uid).get();
    if (!snap.exists)
      return res
        .status(404)
        .json({ success: false, error: { code: 'NOT_FOUND', message: 'User not found' } });
    res.json({ success: true, data: snap.data() });
  } catch (err) {
    next(err);
  }
});

// PUT /admin/users/:uid/suspend
adminRouter.put('/users/:uid/suspend', async (req, res, next) => {
  try {
    const db = getFirestore();
    await db.collection(Collections.USERS).doc(req.params.uid).update({
      accountStatus: 'suspended',
      updatedAt: Timestamp.now(),
    });
    res.json({ success: true, data: { message: 'User suspended' } });
  } catch (err) {
    next(err);
  }
});

// PUT /admin/users/:uid/restore
adminRouter.put('/users/:uid/restore', async (req, res, next) => {
  try {
    const db = getFirestore();
    await db.collection(Collections.USERS).doc(req.params.uid).update({
      accountStatus: 'active',
      updatedAt: Timestamp.now(),
    });
    res.json({ success: true, data: { message: 'User restored' } });
  } catch (err) {
    next(err);
  }
});

// GET /admin/analytics/overview
adminRouter.get('/analytics/overview', async (_req, res, next) => {
  try {
    const db = getFirestore();
    const today = new Date().toISOString().split('T')[0];

    const [totalUsers, activeToday, proUsers, eliteUsers] = await Promise.all([
      db.collection(Collections.USERS).count().get(),
      db.collection(Collections.USERS).where('stats.lastActiveDate', '==', today).count().get(),
      db.collection(Collections.USERS).where('subscription.tier', '==', 'pro').count().get(),
      db.collection(Collections.USERS).where('subscription.tier', '==', 'elite').count().get(),
    ]);

    res.json({
      success: true,
      data: {
        totalUsers: totalUsers.data().count,
        dailyActiveUsers: activeToday.data().count,
        proSubscribers: proUsers.data().count,
        eliteSubscribers: eliteUsers.data().count,
        date: today,
      },
    });
  } catch (err) {
    next(err);
  }
});

// POST /admin/notifications/broadcast
adminRouter.post('/notifications/broadcast', async (req, res, next) => {
  try {
    const { title, body, data = {}, segment } = req.body;
    if (!title || !body)
      return res.status(400).json({
        success: false,
        error: { code: 'VALIDATION_001', message: 'title and body required' },
      });

    const db = getFirestore();
    let query = db.collection(Collections.USERS).where('accountStatus', '==', 'active');
    if (segment?.tier) query = query.where('subscription.tier', '==', segment.tier);

    const usersSnap = await query.limit(1000).get();
    const now = Timestamp.now();

    let count = 0;
    for (let i = 0; i < usersSnap.docs.length; i += 400) {
      const batch = db.batch();
      const chunk = usersSnap.docs.slice(i, i + 400);
      for (const userDoc of chunk) {
        const notifRef = db
          .collection(Collections.USERS)
          .doc(userDoc.id)
          .collection(Collections.NOTIFICATIONS)
          .doc();
        batch.set(notifRef, {
          notificationId: notifRef.id,
          userId: userDoc.id,
          type: 'system',
          title,
          body,
          data,
          read: false,
          readAt: null,
          actionTaken: null,
          fcmMessageId: null,
          deliveredAt: null,
          createdAt: now,
        });
        count++;
      }
      await batch.commit();
    }

    res.json({ success: true, data: { sent: count } });
  } catch (err) {
    next(err);
  }
});

// POST /admin/achievements — create achievement
adminRouter.post('/achievements', async (req, res, next) => {
  try {
    const db = getFirestore();
    const ref = db.collection(Collections.ACHIEVEMENTS).doc(req.body.achievementId || undefined);
    await ref.set({ ...req.body, isActive: true });
    res.json({ success: true, data: { achievementId: ref.id } });
  } catch (err) {
    next(err);
  }
});

// POST /admin/challenges — create challenge
adminRouter.post('/challenges', async (req, res, next) => {
  try {
    const db = getFirestore();
    const ref = db.collection(Collections.CHALLENGES).doc();
    await ref.set({
      ...req.body,
      challengeId: ref.id,
      participantCount: 0,
      completionCount: 0,
      status: 'upcoming',
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    });
    res.json({ success: true, data: { challengeId: ref.id } });
  } catch (err) {
    next(err);
  }
});

app.use('/admin', adminRouter);

// ─── Job Handlers (Cloud Tasks) ───
const jobsRouter = express.Router();
jobsRouter.use(authMiddleware);

jobsRouter.post('/send-notification', async (req, res, next) => {
  try {
    const { sendNotification } = await import('../notifications/notifications.service');
    await sendNotification(req.body);
    res.json({ success: true });
  } catch (err) {
    next(err);
  }
});

app.use('/jobs', jobsRouter);

// ─── Error Handler ───
app.use(globalErrorHandler);

export { app };
