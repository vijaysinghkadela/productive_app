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
exports.rebuildLeaderboard = exports.getLeaderboard = void 0;
const functions = __importStar(require("firebase-functions"));
const firestore_1 = require("firebase-admin/firestore");
const firebase_config_1 = require("../shared/config/firebase.config");
const collections_constants_1 = require("../shared/constants/collections.constants");
// ─── Get Leaderboard (Callable) ───
exports.getLeaderboard = functions.region(firebase_config_1.REGION).https.onCall(async (data, context) => {
    if (!context.auth)
        throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
    const uid = context.auth.uid;
    const db = (0, firebase_config_1.getFirestore)();
    const { period = 'weekly', page = 1, pageSize = 20, countryFilter } = data;
    const validPeriods = ['daily', 'weekly', 'monthly', 'alltime'];
    if (!validPeriods.includes(period)) {
        throw new functions.https.HttpsError('invalid-argument', 'Invalid period');
    }
    const clampedPageSize = Math.min(pageSize, 50);
    const offset = (page - 1) * clampedPageSize;
    // Determine period key
    const now = new Date();
    let periodKey;
    switch (period) {
        case 'daily':
            periodKey = `daily_${now.toISOString().split('T')[0]}`;
            break;
        case 'weekly': {
            const weekNum = getWeekNumber(now);
            periodKey = `weekly_${now.getFullYear()}-W${String(weekNum).padStart(2, '0')}`;
            break;
        }
        case 'monthly':
            periodKey = `monthly_${now.toISOString().slice(0, 7)}`;
            break;
        default:
            periodKey = 'alltime';
    }
    let query = db
        .collection(collections_constants_1.Collections.LEADERBOARD)
        .doc(periodKey)
        .collection(collections_constants_1.Collections.ENTRIES)
        .orderBy('score', 'desc')
        .limit(clampedPageSize)
        .offset(offset);
    if (countryFilter) {
        query = db
            .collection(collections_constants_1.Collections.LEADERBOARD)
            .doc(periodKey)
            .collection(collections_constants_1.Collections.ENTRIES)
            .where('country', '==', countryFilter)
            .orderBy('score', 'desc')
            .limit(clampedPageSize)
            .offset(offset);
    }
    const entriesSnap = await query.get();
    const entries = entriesSnap.docs.map((d, idx) => ({
        ...d.data(),
        rank: offset + idx + 1,
    }));
    // Get user's own entry
    let userEntry = null;
    try {
        const userEntrySnap = await db
            .collection(collections_constants_1.Collections.LEADERBOARD)
            .doc(periodKey)
            .collection(collections_constants_1.Collections.ENTRIES)
            .doc(uid)
            .get();
        if (userEntrySnap.exists) {
            userEntry = userEntrySnap.data();
        }
    }
    catch {
        /* User may not have entry */
    }
    return {
        entries,
        userEntry,
        period: periodKey,
        page,
        pageSize: clampedPageSize,
        hasMore: entries.length === clampedPageSize,
    };
});
// ─── Rebuild Leaderboard (Scheduled, daily 3am UTC) ───
exports.rebuildLeaderboard = functions
    .region(firebase_config_1.REGION)
    .runWith({ timeoutSeconds: 540, memory: '1GB' })
    .pubsub.schedule('0 3 * * *')
    .timeZone('UTC')
    .onRun(async () => {
    const db = (0, firebase_config_1.getFirestore)();
    const today = new Date().toISOString().split('T')[0];
    // Get all active users with stats
    const usersSnap = await db
        .collection(collections_constants_1.Collections.USERS)
        .where('accountStatus', '==', 'active')
        .where('settings.privacy.showOnLeaderboard', '==', true)
        .limit(5000)
        .get();
    // Build leaderboard entries
    const entries = [];
    for (const userDoc of usersSnap.docs) {
        const user = userDoc.data();
        // Get today's score
        const dailySnap = await db
            .collection(collections_constants_1.Collections.USERS)
            .doc(userDoc.id)
            .collection(collections_constants_1.Collections.DAILY_STATS)
            .doc(today)
            .get();
        const dailyScore = dailySnap.exists
            ? dailySnap.data().productivityScore?.final || 0
            : 0;
        entries.push({
            uid: userDoc.id,
            userId: userDoc.id,
            username: user.username,
            displayName: user.displayName,
            avatarUrl: user.avatarUrl,
            level: user.stats.level,
            country: user.country,
            score: dailyScore,
            rank: 0,
            previousRank: 0,
            rankChange: 0,
            streakDays: user.stats.currentStreak,
            focusMinutes: user.stats.totalFocusMinutes,
            xp: user.stats.totalXp,
            badgeIds: [],
            updatedAt: firestore_1.Timestamp.now(),
        });
    }
    // Sort and assign ranks (dense ranking)
    entries.sort((a, b) => b.score - a.score);
    // Determine period keys
    const dailyKey = `daily_${today}`;
    // Batch write (split into chunks of 500)
    for (let i = 0; i < entries.length; i += 400) {
        const batch = db.batch();
        const chunk = entries.slice(i, i + 400);
        for (let j = 0; j < chunk.length; j++) {
            const entry = chunk[j];
            const rank = i + j + 1;
            entry.rank = rank;
            // Get previous rank for rank change
            try {
                const prevSnap = await db
                    .collection(collections_constants_1.Collections.LEADERBOARD)
                    .doc(dailyKey)
                    .collection(collections_constants_1.Collections.ENTRIES)
                    .doc(entry.uid)
                    .get();
                if (prevSnap.exists) {
                    entry.previousRank = prevSnap.data()?.rank || rank;
                    entry.rankChange = entry.previousRank - rank;
                }
            }
            catch {
                /* No previous rank */
            }
            const entryData = { ...entry };
            delete entryData.uid;
            // Write to daily leaderboard
            batch.set(db
                .collection(collections_constants_1.Collections.LEADERBOARD)
                .doc(dailyKey)
                .collection(collections_constants_1.Collections.ENTRIES)
                .doc(entry.uid), entryData);
        }
        await batch.commit();
    }
    console.log(`Leaderboard rebuilt: ${entries.length} entries for ${dailyKey}`);
});
function getWeekNumber(d) {
    const date = new Date(Date.UTC(d.getFullYear(), d.getMonth(), d.getDate()));
    date.setUTCDate(date.getUTCDate() + 4 - (date.getUTCDay() || 7));
    const yearStart = new Date(Date.UTC(date.getUTCFullYear(), 0, 1));
    return Math.ceil(((date.getTime() - yearStart.getTime()) / 86400000 + 1) / 7);
}
//# sourceMappingURL=leaderboard.service.js.map