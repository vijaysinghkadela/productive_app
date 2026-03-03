"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.app = void 0;
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const helmet_1 = __importDefault(require("helmet"));
const auth_middleware_1 = require("../shared/middleware/auth.middleware");
const validation_middleware_1 = require("../shared/middleware/validation.middleware");
const ratelimit_middleware_1 = require("../shared/middleware/ratelimit.middleware");
const error_handler_1 = require("../shared/errors/error.handler");
const firebase_config_1 = require("../shared/config/firebase.config");
const collections_constants_1 = require("../shared/constants/collections.constants");
const firestore_1 = require("firebase-admin/firestore");
const app = (0, express_1.default)();
exports.app = app;
// ─── Global Middleware ───
app.use((0, helmet_1.default)());
app.use((0, cors_1.default)((0, validation_middleware_1.corsConfig)()));
app.use(express_1.default.json({ limit: '10mb' }));
app.use(validation_middleware_1.requestLogger);
// ─── Health Check ───
app.get('/health', (_req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString(), version: '1.0.0' });
});
// ─── Admin API Routes ───
const adminRouter = express_1.default.Router();
adminRouter.use(auth_middleware_1.authMiddleware);
adminRouter.use(auth_middleware_1.requireEmailVerification);
adminRouter.use(auth_middleware_1.requireAdmin);
adminRouter.use(ratelimit_middleware_1.adminRateLimit);
// GET /admin/users — list users
adminRouter.get('/users', async (req, res, next) => {
    try {
        const db = (0, firebase_config_1.getFirestore)();
        const { page = '1', pageSize = '20', tier, status } = req.query;
        const limit = Math.min(parseInt(pageSize) || 20, 100);
        const offset = (parseInt(page) - 1) * limit;
        let query = db
            .collection(collections_constants_1.Collections.USERS)
            .orderBy('createdAt', 'desc')
            .limit(limit)
            .offset(offset);
        if (tier)
            query = db
                .collection(collections_constants_1.Collections.USERS)
                .where('subscription.tier', '==', tier)
                .limit(limit)
                .offset(offset);
        if (status)
            query = db
                .collection(collections_constants_1.Collections.USERS)
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
            meta: { page: parseInt(page), pageSize: limit },
        });
    }
    catch (err) {
        next(err);
    }
});
// GET /admin/users/:uid — full user profile
adminRouter.get('/users/:uid', async (req, res, next) => {
    try {
        const db = (0, firebase_config_1.getFirestore)();
        const snap = await db.collection(collections_constants_1.Collections.USERS).doc(req.params.uid).get();
        if (!snap.exists)
            return res
                .status(404)
                .json({ success: false, error: { code: 'NOT_FOUND', message: 'User not found' } });
        res.json({ success: true, data: snap.data() });
    }
    catch (err) {
        next(err);
    }
});
// PUT /admin/users/:uid/suspend
adminRouter.put('/users/:uid/suspend', async (req, res, next) => {
    try {
        const db = (0, firebase_config_1.getFirestore)();
        await db.collection(collections_constants_1.Collections.USERS).doc(req.params.uid).update({
            accountStatus: 'suspended',
            updatedAt: firestore_1.Timestamp.now(),
        });
        res.json({ success: true, data: { message: 'User suspended' } });
    }
    catch (err) {
        next(err);
    }
});
// PUT /admin/users/:uid/restore
adminRouter.put('/users/:uid/restore', async (req, res, next) => {
    try {
        const db = (0, firebase_config_1.getFirestore)();
        await db.collection(collections_constants_1.Collections.USERS).doc(req.params.uid).update({
            accountStatus: 'active',
            updatedAt: firestore_1.Timestamp.now(),
        });
        res.json({ success: true, data: { message: 'User restored' } });
    }
    catch (err) {
        next(err);
    }
});
// GET /admin/analytics/overview
adminRouter.get('/analytics/overview', async (_req, res, next) => {
    try {
        const db = (0, firebase_config_1.getFirestore)();
        const today = new Date().toISOString().split('T')[0];
        const [totalUsers, activeToday, proUsers, eliteUsers] = await Promise.all([
            db.collection(collections_constants_1.Collections.USERS).count().get(),
            db.collection(collections_constants_1.Collections.USERS).where('stats.lastActiveDate', '==', today).count().get(),
            db.collection(collections_constants_1.Collections.USERS).where('subscription.tier', '==', 'pro').count().get(),
            db.collection(collections_constants_1.Collections.USERS).where('subscription.tier', '==', 'elite').count().get(),
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
    }
    catch (err) {
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
        const db = (0, firebase_config_1.getFirestore)();
        let query = db.collection(collections_constants_1.Collections.USERS).where('accountStatus', '==', 'active');
        if (segment?.tier)
            query = query.where('subscription.tier', '==', segment.tier);
        const usersSnap = await query.limit(1000).get();
        const now = firestore_1.Timestamp.now();
        let count = 0;
        for (let i = 0; i < usersSnap.docs.length; i += 400) {
            const batch = db.batch();
            const chunk = usersSnap.docs.slice(i, i + 400);
            for (const userDoc of chunk) {
                const notifRef = db
                    .collection(collections_constants_1.Collections.USERS)
                    .doc(userDoc.id)
                    .collection(collections_constants_1.Collections.NOTIFICATIONS)
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
    }
    catch (err) {
        next(err);
    }
});
// POST /admin/achievements — create achievement
adminRouter.post('/achievements', async (req, res, next) => {
    try {
        const db = (0, firebase_config_1.getFirestore)();
        const ref = db.collection(collections_constants_1.Collections.ACHIEVEMENTS).doc(req.body.achievementId || undefined);
        await ref.set({ ...req.body, isActive: true });
        res.json({ success: true, data: { achievementId: ref.id } });
    }
    catch (err) {
        next(err);
    }
});
// POST /admin/challenges — create challenge
adminRouter.post('/challenges', async (req, res, next) => {
    try {
        const db = (0, firebase_config_1.getFirestore)();
        const ref = db.collection(collections_constants_1.Collections.CHALLENGES).doc();
        await ref.set({
            ...req.body,
            challengeId: ref.id,
            participantCount: 0,
            completionCount: 0,
            status: 'upcoming',
            createdAt: firestore_1.Timestamp.now(),
            updatedAt: firestore_1.Timestamp.now(),
        });
        res.json({ success: true, data: { challengeId: ref.id } });
    }
    catch (err) {
        next(err);
    }
});
app.use('/admin', adminRouter);
// ─── Job Handlers (Cloud Tasks) ───
const jobsRouter = express_1.default.Router();
jobsRouter.use(auth_middleware_1.authMiddleware);
jobsRouter.post('/send-notification', async (req, res, next) => {
    try {
        const { sendNotification } = await Promise.resolve().then(() => __importStar(require('../notifications/notifications.service')));
        await sendNotification(req.body);
        res.json({ success: true });
    }
    catch (err) {
        next(err);
    }
});
app.use('/jobs', jobsRouter);
// ─── Error Handler ───
app.use(error_handler_1.globalErrorHandler);
//# sourceMappingURL=api.router.js.map