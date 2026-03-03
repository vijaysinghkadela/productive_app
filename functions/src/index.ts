import * as functions from 'firebase-functions';
import { REGION } from './shared/config/firebase.config';

// ─── Auth Triggers ───
export {
  onUserCreated,
  onUserDeleted,
  beforeSignIn,
  beforeCreate,
} from './auth/auth.triggers';

// ─── User Triggers ───
export { onUserDocumentUpdate } from './users/users.triggers';

// ─── Session Functions ───
export {
  createSession,
  completeSession,
  getSessionAnalytics,
} from './sessions/sessions.service';

// ─── Usage Functions ───
export {
  syncDailyUsage,
  getUsageAnalytics,
} from './usage/usage.service';

// ─── Goal Functions ───
export {
  setGoal,
  evaluateGoalsAtDayEnd,
} from './goals/goals.service';

// ─── Habit Functions ───
export {
  createHabit,
  trackHabit,
  calculateHabitStreaks,
} from './habits/habits.service';

// ─── AI Coaching ───
export { getAICoaching } from './ai/ai.service';

// ─── Subscription Webhooks ───
export {
  revenuecatWebhook,
  checkEntitlements,
} from './subscriptions/subscriptions.service';

// ─── Leaderboard ───
export {
  getLeaderboard,
  rebuildLeaderboard,
} from './leaderboard/leaderboard.service';

// ─── Notifications ───
export { sendStreakReminders } from './notifications/notifications.service';

// ─── Blocking & Focus Modes ───
export {
  createBlockingSchedule,
  updateBlockingSchedule,
  createFocusMode,
  getActiveBlocks,
  logOverrideAttempt,
} from './blocking/blocking.service';

// ─── Challenges ───
export {
  joinChallenge,
  withdrawChallenge,
  getChallengeDetails,
  updateChallengeProgress,
} from './challenges/challenges.service';

// ─── Accountability ───
export {
  invitePartner,
  acceptPartner,
  sendNudge,
  createAccountabilityGroup,
  updateAccountabilityStats,
} from './accountability/accountability.service';

// ─── Referrals ───
export {
  createReferralLink,
  processReferral,
  processReferralRewards,
} from './referrals/referrals.service';

// ─── Reports ───
export {
  generateWeeklyReport,
  generateMonthlyReport,
} from './reports/reports.service';

// ─── Analytics & BigQuery ───
export {
  syncDailyStatsToBigQuery,
  aggregateWeeklyAnalytics,
  cleanupOldNotifications,
} from './analytics/analytics.service';

// ─── MFA ───
export {
  generateTOTPSecret,
  verifyTOTPToken,
  sendSMSCode,
  verifySMSCode,
  verifyBackupCode,
  disableMFA,
} from './auth/mfa.service';

// ─── Pub/Sub Handlers ───
export {
  onSessionCompleted as pubsubSessionCompleted,
  onUsageSynced as pubsubUsageSynced,
  onAchievementUnlocked as pubsubAchievementUnlocked,
  onSubscriptionChanged as pubsubSubscriptionChanged,
  onReportReady as pubsubReportReady,
  onLevelUp as pubsubLevelUp,
} from './pubsub/pubsub.handlers';

// ─── Webhooks ───
export {
  stripeWebhook,
  sendgridWebhook,
} from './webhooks/webhooks.handlers';

// ─── Express API (Admin + Jobs) ───
import { app } from './api/api.router';
export const api = functions.region(REGION).https.onRequest(app);
