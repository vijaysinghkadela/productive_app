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
Object.defineProperty(exports, "__esModule", { value: true });
exports.logOverrideAttempt = exports.getActiveBlocks = exports.createFocusMode = exports.updateBlockingSchedule = exports.createBlockingSchedule = void 0;
const functions = __importStar(require("firebase-functions"));
const firestore_1 = require("firebase-admin/firestore");
const firebase_config_1 = require("../shared/config/firebase.config");
const collections_constants_1 = require("../shared/constants/collections.constants");
const feature_flags_1 = require("../shared/constants/feature.flags");
// ─── Create Blocking Schedule (Callable) ───
exports.createBlockingSchedule = functions
    .region(firebase_config_1.REGION)
    .https.onCall(async (data, context) => {
    if (!context.auth)
        throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
    const uid = context.auth.uid;
    const db = (0, firebase_config_1.getFirestore)();
    const now = firestore_1.Timestamp.now();
    const { name, appIds, categories, schedule, dailyLimitMinutes, gracePeriodMinutes, strictMode, } = data;
    if (!name || !Array.isArray(appIds) || !Array.isArray(schedule)) {
        throw new functions.https.HttpsError('invalid-argument', 'name, appIds, and schedule are required');
    }
    // Check subscription limits
    const userSnap = await db.collection(collections_constants_1.Collections.USERS).doc(uid).get();
    const tier = (userSnap.data()?.subscription?.tier || 'free');
    const limits = feature_flags_1.TierLimits[tier];
    const existingSchedules = await db
        .collection(collections_constants_1.Collections.USERS)
        .doc(uid)
        .collection(collections_constants_1.Collections.BLOCKING_SCHEDULE)
        .where('status', '==', 'active')
        .get();
    if (existingSchedules.size >= limits.blockedApps) {
        throw new functions.https.HttpsError('resource-exhausted', `Blocking schedule limit (${limits.blockedApps}) reached for ${tier} plan`);
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
    const scheduleRef = db
        .collection(collections_constants_1.Collections.USERS)
        .doc(uid)
        .collection(collections_constants_1.Collections.BLOCKING_SCHEDULE)
        .doc();
    const doc = {
        scheduleId: scheduleRef.id,
        userId: uid,
        name,
        appIds: appIds.slice(0, 50), // Cap at 50 apps
        categories: categories || [],
        schedule: schedule.map((s) => ({
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
exports.updateBlockingSchedule = functions
    .region(firebase_config_1.REGION)
    .https.onCall(async (data, context) => {
    if (!context.auth)
        throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
    const uid = context.auth.uid;
    const db = (0, firebase_config_1.getFirestore)();
    const { scheduleId, ...updates } = data;
    if (!scheduleId)
        throw new functions.https.HttpsError('invalid-argument', 'scheduleId required');
    const scheduleRef = db
        .collection(collections_constants_1.Collections.USERS)
        .doc(uid)
        .collection(collections_constants_1.Collections.BLOCKING_SCHEDULE)
        .doc(scheduleId);
    const snap = await scheduleRef.get();
    if (!snap.exists)
        throw new functions.https.HttpsError('not-found', 'Schedule not found');
    if (snap.data()?.userId !== uid)
        throw new functions.https.HttpsError('permission-denied', 'Not your schedule');
    const allowedFields = [
        'name',
        'appIds',
        'categories',
        'schedule',
        'dailyLimitMinutes',
        'gracePeriodMinutes',
        'strictMode',
        'status',
    ];
    const safeUpdates = { updatedAt: firestore_1.Timestamp.now() };
    for (const key of Object.keys(updates)) {
        if (allowedFields.includes(key))
            safeUpdates[key] = updates[key];
    }
    await scheduleRef.update(safeUpdates);
    return { success: true };
});
// ─── Create Focus Mode (Callable) ───
exports.createFocusMode = functions.region(firebase_config_1.REGION).https.onCall(async (data, context) => {
    if (!context.auth)
        throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
    const uid = context.auth.uid;
    const db = (0, firebase_config_1.getFirestore)();
    const now = firestore_1.Timestamp.now();
    const userSnap = await db.collection(collections_constants_1.Collections.USERS).doc(uid).get();
    const tier = (userSnap.data()?.subscription?.tier || 'free');
    if (!['pro', 'elite', 'lifetime'].includes(tier)) {
        throw new functions.https.HttpsError('permission-denied', 'Focus modes require Pro or Elite subscription');
    }
    const { name, icon, color, blockedApps, blockedCategories, allowedApps, notificationFilter, ambientSoundProfile, durationMinutes, autoActivate, } = data;
    if (!name)
        throw new functions.https.HttpsError('invalid-argument', 'name is required');
    const modeRef = db
        .collection(collections_constants_1.Collections.USERS)
        .doc(uid)
        .collection(collections_constants_1.Collections.FOCUS_MODES)
        .doc();
    const focusMode = {
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
exports.getActiveBlocks = functions.region(firebase_config_1.REGION).https.onCall(async (data, context) => {
    if (!context.auth)
        throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
    const uid = context.auth.uid;
    const db = (0, firebase_config_1.getFirestore)();
    const now = new Date();
    const currentDay = now.getDay(); // 0-6
    const currentTime = `${String(now.getHours()).padStart(2, '0')}:${String(now.getMinutes()).padStart(2, '0')}`;
    // Get all active schedules
    const schedulesSnap = await db
        .collection(collections_constants_1.Collections.USERS)
        .doc(uid)
        .collection(collections_constants_1.Collections.BLOCKING_SCHEDULE)
        .where('status', '==', 'active')
        .get();
    const blockedApps = new Set();
    const blockedCategories = new Set();
    let strictMode = false;
    let gracePeriodMinutes = 5;
    for (const doc of schedulesSnap.docs) {
        const schedule = doc.data();
        for (const entry of schedule.schedule) {
            if (!entry.enabled)
                continue;
            if (entry.dayOfWeek !== currentDay)
                continue;
            // Check time range
            let isActiveNow = false;
            if (entry.startTime <= entry.endTime) {
                isActiveNow = currentTime >= entry.startTime && currentTime < entry.endTime;
            }
            else {
                // Crosses midnight (e.g., 22:00 → 06:00)
                isActiveNow = currentTime >= entry.startTime || currentTime < entry.endTime;
            }
            if (isActiveNow) {
                schedule.appIds.forEach((app) => blockedApps.add(app));
                schedule.categories.forEach((cat) => blockedCategories.add(cat));
                if (schedule.strictMode)
                    strictMode = true;
                gracePeriodMinutes = Math.min(gracePeriodMinutes, schedule.gracePeriodMinutes);
            }
        }
        // Check daily limit
        if (schedule.dailyLimitMinutes !== null) {
            const today = now.toISOString().split('T')[0];
            const dailySnap = await db
                .collection(collections_constants_1.Collections.USERS)
                .doc(uid)
                .collection(collections_constants_1.Collections.DAILY_STATS)
                .doc(today)
                .get();
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
    const focusModesSnap = await db
        .collection(collections_constants_1.Collections.USERS)
        .doc(uid)
        .collection(collections_constants_1.Collections.FOCUS_MODES)
        .where('status', '==', 'active')
        .get();
    for (const doc of focusModesSnap.docs) {
        const mode = doc.data();
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
exports.logOverrideAttempt = functions.region(firebase_config_1.REGION).https.onCall(async (data, context) => {
    if (!context.auth)
        throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
    const uid = context.auth.uid;
    const db = (0, firebase_config_1.getFirestore)();
    const { appId } = data;
    if (!appId)
        throw new functions.https.HttpsError('invalid-argument', 'appId required');
    const today = new Date().toISOString().split('T')[0];
    const dailyRef = db
        .collection(collections_constants_1.Collections.USERS)
        .doc(uid)
        .collection(collections_constants_1.Collections.DAILY_STATS)
        .doc(today);
    await dailyRef.set({
        [`appUsage.${appId}.overrideCount`]: firestore_1.FieldValue.increment(1),
        updatedAt: firestore_1.Timestamp.now(),
    }, { merge: true });
    // Update user stats
    await db
        .collection(collections_constants_1.Collections.USERS)
        .doc(uid)
        .update({
        'stats.totalAppsBlocked': firestore_1.FieldValue.increment(1),
        updatedAt: firestore_1.Timestamp.now(),
    });
    return { logged: true };
});
//# sourceMappingURL=blocking.service.js.map