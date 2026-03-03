import * as functions from 'firebase-functions';
import { Timestamp, FieldValue } from 'firebase-admin/firestore';
import { getFirestore, REGION } from '../shared/config/firebase.config';
import { Collections } from '../shared/constants/collections.constants';
import { BlockingScheduleDocument, FocusModeDocument, SubscriptionTier } from '../shared/types/firestore.types';
import { TierLimits } from '../shared/constants/feature.flags';
import { sendNotification } from '../notifications/notifications.service';

// ─── Create Blocking Schedule (Callable) ───
export const createBlockingSchedule = functions
  .region(REGION)
  .https.onCall(async (data, context) => {
    if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
    const uid = context.auth.uid;
    const db = getFirestore();
    const now = Timestamp.now();

    const { name, appIds, categories, schedule, dailyLimitMinutes, gracePeriodMinutes, strictMode } = data;

    if (!name || !Array.isArray(appIds) || !Array.isArray(schedule)) {
      throw new functions.https.HttpsError('invalid-argument', 'name, appIds, and schedule are required');
    }

    // Check subscription limits
    const userSnap = await db.collection(Collections.USERS).doc(uid).get();
    const tier = (userSnap.data()?.subscription?.tier || 'free') as SubscriptionTier;
    const limits = TierLimits[tier];

    const existingSchedules = await db.collection(Collections.USERS).doc(uid)
      .collection(Collections.BLOCKING_SCHEDULE).where('status', '==', 'active').get();

    if (existingSchedules.size >= limits.blockedApps) {
      throw new functions.https.HttpsError('resource-exhausted',
        `Blocking schedule limit (${limits.blockedApps}) reached for ${tier} plan`);
    }

    // Strict mode requires Pro+
    if (strictMode && !['pro', 'elite', 'lifetime'].includes(tier)) {
      throw new functions.https.HttpsError('permission-denied', 'Strict mode requires Pro or Elite subscription');
    }

    // Validate schedule entries
    for (const entry of schedule) {
      if (entry.dayOfWeek < 0 || entry.dayOfWeek > 6) {
        throw new functions.https.HttpsError('invalid-argument', 'dayOfWeek must be 0-6');
      }
      if (!/^\d{2}:\d{2}$/.test(entry.startTime) || !/^\d{2}:\d{2}$/.test(entry.endTime)) {
        throw new functions.https.HttpsError('invalid-argument', 'Time must be HH:mm format');
      }
    }

    const scheduleRef = db.collection(Collections.USERS).doc(uid)
      .collection(Collections.BLOCKING_SCHEDULE).doc();

    const doc: BlockingScheduleDocument = {
      scheduleId: scheduleRef.id,
      userId: uid,
      name,
      appIds: appIds.slice(0, 50), // Cap at 50 apps
      categories: categories || [],
      schedule: schedule.map((s: { dayOfWeek: number; startTime: string; endTime: string; enabled?: boolean }) => ({
        dayOfWeek: s.dayOfWeek,
        startTime: s.startTime,
        endTime: s.endTime,
        enabled: s.enabled !== false,
      })),
      dailyLimitMinutes: dailyLimitMinutes || null,
      gracePeriodMinutes: gracePeriodMinutes || 5,
      strictMode: strictMode || false,
      status: 'active',
      createdAt: now,
      updatedAt: now,
    };

    await scheduleRef.set(doc);

    return { scheduleId: scheduleRef.id };
  });

// ─── Update Blocking Schedule (Callable) ───
export const updateBlockingSchedule = functions
  .region(REGION)
  .https.onCall(async (data, context) => {
    if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
    const uid = context.auth.uid;
    const db = getFirestore();

    const { scheduleId, ...updates } = data;
    if (!scheduleId) throw new functions.https.HttpsError('invalid-argument', 'scheduleId required');

    const scheduleRef = db.collection(Collections.USERS).doc(uid)
      .collection(Collections.BLOCKING_SCHEDULE).doc(scheduleId);
    const snap = await scheduleRef.get();

    if (!snap.exists) throw new functions.https.HttpsError('not-found', 'Schedule not found');
    if (snap.data()?.userId !== uid) throw new functions.https.HttpsError('permission-denied', 'Not your schedule');

    const allowedFields = ['name', 'appIds', 'categories', 'schedule', 'dailyLimitMinutes', 'gracePeriodMinutes', 'strictMode', 'status'];
    const safeUpdates: Record<string, unknown> = { updatedAt: Timestamp.now() };
    for (const key of Object.keys(updates)) {
      if (allowedFields.includes(key)) safeUpdates[key] = updates[key];
    }

    await scheduleRef.update(safeUpdates);
    return { success: true };
  });

// ─── Create Focus Mode (Callable) ───
export const createFocusMode = functions
  .region(REGION)
  .https.onCall(async (data, context) => {
    if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
    const uid = context.auth.uid;
    const db = getFirestore();
    const now = Timestamp.now();

    const userSnap = await db.collection(Collections.USERS).doc(uid).get();
    const tier = (userSnap.data()?.subscription?.tier || 'free') as SubscriptionTier;

    if (!['pro', 'elite', 'lifetime'].includes(tier)) {
      throw new functions.https.HttpsError('permission-denied', 'Focus modes require Pro or Elite subscription');
    }

    const { name, icon, color, blockedApps, blockedCategories, allowedApps, notificationFilter, ambientSoundProfile, durationMinutes, autoActivate } = data;

    if (!name) throw new functions.https.HttpsError('invalid-argument', 'name is required');

    const modeRef = db.collection(Collections.USERS).doc(uid)
      .collection(Collections.FOCUS_MODES).doc();

    const focusMode: FocusModeDocument = {
      modeId: modeRef.id,
      userId: uid,
      name,
      icon: icon || '🎯',
      color: color || '#6C5CE7',
      blockedApps: blockedApps || [],
      blockedCategories: blockedCategories || [],
      allowedApps: allowedApps || [],
      notificationFilter: notificationFilter || 'none',
      ambientSoundProfile: ambientSoundProfile || null,
      durationMinutes: durationMinutes || null,
      autoActivate: {
        timeRules: autoActivate?.timeRules || [],
        locationRules: autoActivate?.locationRules || [],
        calendarKeywords: autoActivate?.calendarKeywords || [],
        bluetoothDevices: autoActivate?.bluetoothDevices || [],
      },
      status: 'active',
      isPreset: false,
      usageCount: 0,
      createdAt: now,
      updatedAt: now,
    };

    await modeRef.set(focusMode);
    return { modeId: modeRef.id };
  });

// ─── Check Active Blocks (Callable — returns currently active blocks for device) ───
export const getActiveBlocks = functions
  .region(REGION)
  .https.onCall(async (data, context) => {
    if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
    const uid = context.auth.uid;
    const db = getFirestore();

    const now = new Date();
    const currentDay = now.getDay(); // 0-6
    const currentTime = `${String(now.getHours()).padStart(2, '0')}:${String(now.getMinutes()).padStart(2, '0')}`;

    // Get all active schedules
    const schedulesSnap = await db.collection(Collections.USERS).doc(uid)
      .collection(Collections.BLOCKING_SCHEDULE).where('status', '==', 'active').get();

    const blockedApps = new Set<string>();
    const blockedCategories = new Set<string>();
    let strictMode = false;
    let gracePeriodMinutes = 5;

    for (const doc of schedulesSnap.docs) {
      const schedule = doc.data() as BlockingScheduleDocument;

      for (const entry of schedule.schedule) {
        if (!entry.enabled) continue;
        if (entry.dayOfWeek !== currentDay) continue;

        // Check time range
        let isActiveNow = false;
        if (entry.startTime <= entry.endTime) {
          isActiveNow = currentTime >= entry.startTime && currentTime < entry.endTime;
        } else {
          // Crosses midnight (e.g., 22:00 → 06:00)
          isActiveNow = currentTime >= entry.startTime || currentTime < entry.endTime;
        }

        if (isActiveNow) {
          schedule.appIds.forEach((app) => blockedApps.add(app));
          schedule.categories.forEach((cat) => blockedCategories.add(cat));
          if (schedule.strictMode) strictMode = true;
          gracePeriodMinutes = Math.min(gracePeriodMinutes, schedule.gracePeriodMinutes);
        }
      }

      // Check daily limit
      if (schedule.dailyLimitMinutes !== null) {
        const today = now.toISOString().split('T')[0];
        const dailySnap = await db.collection(Collections.USERS).doc(uid)
          .collection(Collections.DAILY_STATS).doc(today).get();

        if (dailySnap.exists) {
          const appUsage = dailySnap.data()?.appUsage || {};
          for (const appId of schedule.appIds) {
            const usage = appUsage[appId];
            if (usage && usage.totalMinutes >= schedule.dailyLimitMinutes) {
              blockedApps.add(appId);
            }
          }
        }
      }
    }

    // Get active focus modes
    const focusModesSnap = await db.collection(Collections.USERS).doc(uid)
      .collection(Collections.FOCUS_MODES).where('status', '==', 'active').get();

    for (const doc of focusModesSnap.docs) {
      const mode = doc.data() as FocusModeDocument;
      mode.blockedApps.forEach((app) => blockedApps.add(app));
      mode.blockedCategories.forEach((cat) => blockedCategories.add(cat));
    }

    return {
      blockedApps: Array.from(blockedApps),
      blockedCategories: Array.from(blockedCategories),
      strictMode,
      gracePeriodMinutes,
    };
  });

// ─── Log Override Attempt (Callable) ───
export const logOverrideAttempt = functions
  .region(REGION)
  .https.onCall(async (data, context) => {
    if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
    const uid = context.auth.uid;
    const db = getFirestore();

    const { appId, scheduleId } = data;
    if (!appId) throw new functions.https.HttpsError('invalid-argument', 'appId required');

    const today = new Date().toISOString().split('T')[0];
    const dailyRef = db.collection(Collections.USERS).doc(uid)
      .collection(Collections.DAILY_STATS).doc(today);

    await dailyRef.set({
      [`appUsage.${appId}.overrideCount`]: FieldValue.increment(1),
      updatedAt: Timestamp.now(),
    }, { merge: true });

    // Update user stats
    await db.collection(Collections.USERS).doc(uid).update({
      'stats.totalAppsBlocked': FieldValue.increment(1),
      updatedAt: Timestamp.now(),
    });

    return { logged: true };
  });
