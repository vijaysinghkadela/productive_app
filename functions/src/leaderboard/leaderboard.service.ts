import * as functions from 'firebase-functions';
import { Timestamp, FieldValue } from 'firebase-admin/firestore';
import { getFirestore, REGION } from '../shared/config/firebase.config';
import { Collections } from '../shared/constants/collections.constants';
import { LeaderboardEntryDocument, UserDocument, DailyStatsDocument } from '../shared/types/firestore.types';

// ─── Get Leaderboard (Callable) ───
export const getLeaderboard = functions
  .region(REGION)
  .https.onCall(async (data, context) => {
    if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
    const uid = context.auth.uid;
    const db = getFirestore();

    const { period = 'weekly', page = 1, pageSize = 20, countryFilter } = data;
    const validPeriods = ['daily', 'weekly', 'monthly', 'alltime'];
    if (!validPeriods.includes(period)) {
      throw new functions.https.HttpsError('invalid-argument', 'Invalid period');
    }

    const clampedPageSize = Math.min(pageSize, 50);
    const offset = (page - 1) * clampedPageSize;

    // Determine period key
    const now = new Date();
    let periodKey: string;
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

    let query = db.collection(Collections.LEADERBOARD).doc(periodKey)
      .collection(Collections.ENTRIES)
      .orderBy('score', 'desc')
      .limit(clampedPageSize)
      .offset(offset);

    if (countryFilter) {
      query = db.collection(Collections.LEADERBOARD).doc(periodKey)
        .collection(Collections.ENTRIES)
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
      const userEntrySnap = await db.collection(Collections.LEADERBOARD).doc(periodKey)
        .collection(Collections.ENTRIES).doc(uid).get();
      if (userEntrySnap.exists) {
        userEntry = userEntrySnap.data();
      }
    } catch { /* User may not have entry */ }

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
export const rebuildLeaderboard = functions
  .region(REGION)
  .runWith({ timeoutSeconds: 540, memory: '1GB' })
  .pubsub.schedule('0 3 * * *')
  .timeZone('UTC')
  .onRun(async () => {
    const db = getFirestore();
    const today = new Date().toISOString().split('T')[0];
    const now = new Date();

    // Get all active users with stats
    const usersSnap = await db.collection(Collections.USERS)
      .where('accountStatus', '==', 'active')
      .where('settings.privacy.showOnLeaderboard', '==', true)
      .limit(5000)
      .get();

    // Build leaderboard entries
    const entries: (LeaderboardEntryDocument & { uid: string })[] = [];

    for (const userDoc of usersSnap.docs) {
      const user = userDoc.data() as UserDocument;

      // Get today's score
      const dailySnap = await db.collection(Collections.USERS).doc(userDoc.id)
        .collection(Collections.DAILY_STATS).doc(today).get();

      const dailyScore = dailySnap.exists
        ? (dailySnap.data() as DailyStatsDocument).productivityScore?.final || 0
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
        updatedAt: Timestamp.now(),
      });
    }

    // Sort and assign ranks (dense ranking)
    entries.sort((a, b) => b.score - a.score);

    // Determine period keys
    const weekNum = getWeekNumber(now);
    const dailyKey = `daily_${today}`;
    const weeklyKey = `weekly_${now.getFullYear()}-W${String(weekNum).padStart(2, '0')}`;
    const monthlyKey = `monthly_${now.toISOString().slice(0, 7)}`;

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
          const prevSnap = await db.collection(Collections.LEADERBOARD).doc(dailyKey)
            .collection(Collections.ENTRIES).doc(entry.uid).get();
          if (prevSnap.exists) {
            entry.previousRank = prevSnap.data()?.rank || rank;
            entry.rankChange = entry.previousRank - rank;
          }
        } catch { /* No previous rank */ }

        const entryData = { ...entry };
        delete (entryData as { uid?: string }).uid;

        // Write to daily leaderboard
        batch.set(
          db.collection(Collections.LEADERBOARD).doc(dailyKey)
            .collection(Collections.ENTRIES).doc(entry.uid),
          entryData,
        );
      }

      await batch.commit();
    }

    console.log(`Leaderboard rebuilt: ${entries.length} entries for ${dailyKey}`);
  });

function getWeekNumber(d: Date): number {
  const date = new Date(Date.UTC(d.getFullYear(), d.getMonth(), d.getDate()));
  date.setUTCDate(date.getUTCDate() + 4 - (date.getUTCDay() || 7));
  const yearStart = new Date(Date.UTC(date.getUTCFullYear(), 0, 1));
  return Math.ceil(((date.getTime() - yearStart.getTime()) / 86400000 + 1) / 7);
}
