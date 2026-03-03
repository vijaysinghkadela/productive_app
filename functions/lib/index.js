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
exports.pubsubSessionCompleted = exports.disableMFA = exports.verifyBackupCode = exports.verifySMSCode = exports.sendSMSCode = exports.verifyTOTPToken = exports.generateTOTPSecret = exports.cleanupOldNotifications = exports.aggregateWeeklyAnalytics = exports.syncDailyStatsToBigQuery = exports.generateMonthlyReport = exports.generateWeeklyReport = exports.processReferralRewards = exports.processReferral = exports.createReferralLink = exports.updateAccountabilityStats = exports.createAccountabilityGroup = exports.sendNudge = exports.acceptPartner = exports.invitePartner = exports.updateChallengeProgress = exports.getChallengeDetails = exports.withdrawChallenge = exports.joinChallenge = exports.logOverrideAttempt = exports.getActiveBlocks = exports.createFocusMode = exports.updateBlockingSchedule = exports.createBlockingSchedule = exports.sendStreakReminders = exports.rebuildLeaderboard = exports.getLeaderboard = exports.checkEntitlements = exports.revenuecatWebhook = exports.getAICoaching = exports.calculateHabitStreaks = exports.trackHabit = exports.createHabit = exports.evaluateGoalsAtDayEnd = exports.setGoal = exports.getUsageAnalytics = exports.syncDailyUsage = exports.getSessionAnalytics = exports.completeSession = exports.createSession = exports.onUserDocumentUpdate = exports.beforeCreate = exports.beforeSignIn = exports.onUserDeleted = exports.onUserCreated = void 0;
exports.api = exports.sendgridWebhook = exports.stripeWebhook = exports.pubsubLevelUp = exports.pubsubReportReady = exports.pubsubSubscriptionChanged = exports.pubsubAchievementUnlocked = exports.pubsubUsageSynced = void 0;
const functions = __importStar(require("firebase-functions"));
const firebase_config_1 = require("./shared/config/firebase.config");
// ─── Auth Triggers ───
var auth_triggers_1 = require("./auth/auth.triggers");
Object.defineProperty(exports, "onUserCreated", { enumerable: true, get: function () { return auth_triggers_1.onUserCreated; } });
Object.defineProperty(exports, "onUserDeleted", { enumerable: true, get: function () { return auth_triggers_1.onUserDeleted; } });
Object.defineProperty(exports, "beforeSignIn", { enumerable: true, get: function () { return auth_triggers_1.beforeSignIn; } });
Object.defineProperty(exports, "beforeCreate", { enumerable: true, get: function () { return auth_triggers_1.beforeCreate; } });
// ─── User Triggers ───
var users_triggers_1 = require("./users/users.triggers");
Object.defineProperty(exports, "onUserDocumentUpdate", { enumerable: true, get: function () { return users_triggers_1.onUserDocumentUpdate; } });
// ─── Session Functions ───
var sessions_service_1 = require("./sessions/sessions.service");
Object.defineProperty(exports, "createSession", { enumerable: true, get: function () { return sessions_service_1.createSession; } });
Object.defineProperty(exports, "completeSession", { enumerable: true, get: function () { return sessions_service_1.completeSession; } });
Object.defineProperty(exports, "getSessionAnalytics", { enumerable: true, get: function () { return sessions_service_1.getSessionAnalytics; } });
// ─── Usage Functions ───
var usage_service_1 = require("./usage/usage.service");
Object.defineProperty(exports, "syncDailyUsage", { enumerable: true, get: function () { return usage_service_1.syncDailyUsage; } });
Object.defineProperty(exports, "getUsageAnalytics", { enumerable: true, get: function () { return usage_service_1.getUsageAnalytics; } });
// ─── Goal Functions ───
var goals_service_1 = require("./goals/goals.service");
Object.defineProperty(exports, "setGoal", { enumerable: true, get: function () { return goals_service_1.setGoal; } });
Object.defineProperty(exports, "evaluateGoalsAtDayEnd", { enumerable: true, get: function () { return goals_service_1.evaluateGoalsAtDayEnd; } });
// ─── Habit Functions ───
var habits_service_1 = require("./habits/habits.service");
Object.defineProperty(exports, "createHabit", { enumerable: true, get: function () { return habits_service_1.createHabit; } });
Object.defineProperty(exports, "trackHabit", { enumerable: true, get: function () { return habits_service_1.trackHabit; } });
Object.defineProperty(exports, "calculateHabitStreaks", { enumerable: true, get: function () { return habits_service_1.calculateHabitStreaks; } });
// ─── AI Coaching ───
var ai_service_1 = require("./ai/ai.service");
Object.defineProperty(exports, "getAICoaching", { enumerable: true, get: function () { return ai_service_1.getAICoaching; } });
// ─── Subscription Webhooks ───
var subscriptions_service_1 = require("./subscriptions/subscriptions.service");
Object.defineProperty(exports, "revenuecatWebhook", { enumerable: true, get: function () { return subscriptions_service_1.revenuecatWebhook; } });
Object.defineProperty(exports, "checkEntitlements", { enumerable: true, get: function () { return subscriptions_service_1.checkEntitlements; } });
// ─── Leaderboard ───
var leaderboard_service_1 = require("./leaderboard/leaderboard.service");
Object.defineProperty(exports, "getLeaderboard", { enumerable: true, get: function () { return leaderboard_service_1.getLeaderboard; } });
Object.defineProperty(exports, "rebuildLeaderboard", { enumerable: true, get: function () { return leaderboard_service_1.rebuildLeaderboard; } });
// ─── Notifications ───
var notifications_service_1 = require("./notifications/notifications.service");
Object.defineProperty(exports, "sendStreakReminders", { enumerable: true, get: function () { return notifications_service_1.sendStreakReminders; } });
// ─── Blocking & Focus Modes ───
var blocking_service_1 = require("./blocking/blocking.service");
Object.defineProperty(exports, "createBlockingSchedule", { enumerable: true, get: function () { return blocking_service_1.createBlockingSchedule; } });
Object.defineProperty(exports, "updateBlockingSchedule", { enumerable: true, get: function () { return blocking_service_1.updateBlockingSchedule; } });
Object.defineProperty(exports, "createFocusMode", { enumerable: true, get: function () { return blocking_service_1.createFocusMode; } });
Object.defineProperty(exports, "getActiveBlocks", { enumerable: true, get: function () { return blocking_service_1.getActiveBlocks; } });
Object.defineProperty(exports, "logOverrideAttempt", { enumerable: true, get: function () { return blocking_service_1.logOverrideAttempt; } });
// ─── Challenges ───
var challenges_service_1 = require("./challenges/challenges.service");
Object.defineProperty(exports, "joinChallenge", { enumerable: true, get: function () { return challenges_service_1.joinChallenge; } });
Object.defineProperty(exports, "withdrawChallenge", { enumerable: true, get: function () { return challenges_service_1.withdrawChallenge; } });
Object.defineProperty(exports, "getChallengeDetails", { enumerable: true, get: function () { return challenges_service_1.getChallengeDetails; } });
Object.defineProperty(exports, "updateChallengeProgress", { enumerable: true, get: function () { return challenges_service_1.updateChallengeProgress; } });
// ─── Accountability ───
var accountability_service_1 = require("./accountability/accountability.service");
Object.defineProperty(exports, "invitePartner", { enumerable: true, get: function () { return accountability_service_1.invitePartner; } });
Object.defineProperty(exports, "acceptPartner", { enumerable: true, get: function () { return accountability_service_1.acceptPartner; } });
Object.defineProperty(exports, "sendNudge", { enumerable: true, get: function () { return accountability_service_1.sendNudge; } });
Object.defineProperty(exports, "createAccountabilityGroup", { enumerable: true, get: function () { return accountability_service_1.createAccountabilityGroup; } });
Object.defineProperty(exports, "updateAccountabilityStats", { enumerable: true, get: function () { return accountability_service_1.updateAccountabilityStats; } });
// ─── Referrals ───
var referrals_service_1 = require("./referrals/referrals.service");
Object.defineProperty(exports, "createReferralLink", { enumerable: true, get: function () { return referrals_service_1.createReferralLink; } });
Object.defineProperty(exports, "processReferral", { enumerable: true, get: function () { return referrals_service_1.processReferral; } });
Object.defineProperty(exports, "processReferralRewards", { enumerable: true, get: function () { return referrals_service_1.processReferralRewards; } });
// ─── Reports ───
var reports_service_1 = require("./reports/reports.service");
Object.defineProperty(exports, "generateWeeklyReport", { enumerable: true, get: function () { return reports_service_1.generateWeeklyReport; } });
Object.defineProperty(exports, "generateMonthlyReport", { enumerable: true, get: function () { return reports_service_1.generateMonthlyReport; } });
// ─── Analytics & BigQuery ───
var analytics_service_1 = require("./analytics/analytics.service");
Object.defineProperty(exports, "syncDailyStatsToBigQuery", { enumerable: true, get: function () { return analytics_service_1.syncDailyStatsToBigQuery; } });
Object.defineProperty(exports, "aggregateWeeklyAnalytics", { enumerable: true, get: function () { return analytics_service_1.aggregateWeeklyAnalytics; } });
Object.defineProperty(exports, "cleanupOldNotifications", { enumerable: true, get: function () { return analytics_service_1.cleanupOldNotifications; } });
// ─── MFA ───
var mfa_service_1 = require("./auth/mfa.service");
Object.defineProperty(exports, "generateTOTPSecret", { enumerable: true, get: function () { return mfa_service_1.generateTOTPSecret; } });
Object.defineProperty(exports, "verifyTOTPToken", { enumerable: true, get: function () { return mfa_service_1.verifyTOTPToken; } });
Object.defineProperty(exports, "sendSMSCode", { enumerable: true, get: function () { return mfa_service_1.sendSMSCode; } });
Object.defineProperty(exports, "verifySMSCode", { enumerable: true, get: function () { return mfa_service_1.verifySMSCode; } });
Object.defineProperty(exports, "verifyBackupCode", { enumerable: true, get: function () { return mfa_service_1.verifyBackupCode; } });
Object.defineProperty(exports, "disableMFA", { enumerable: true, get: function () { return mfa_service_1.disableMFA; } });
// ─── Pub/Sub Handlers ───
var pubsub_handlers_1 = require("./pubsub/pubsub.handlers");
Object.defineProperty(exports, "pubsubSessionCompleted", { enumerable: true, get: function () { return pubsub_handlers_1.onSessionCompleted; } });
Object.defineProperty(exports, "pubsubUsageSynced", { enumerable: true, get: function () { return pubsub_handlers_1.onUsageSynced; } });
Object.defineProperty(exports, "pubsubAchievementUnlocked", { enumerable: true, get: function () { return pubsub_handlers_1.onAchievementUnlocked; } });
Object.defineProperty(exports, "pubsubSubscriptionChanged", { enumerable: true, get: function () { return pubsub_handlers_1.onSubscriptionChanged; } });
Object.defineProperty(exports, "pubsubReportReady", { enumerable: true, get: function () { return pubsub_handlers_1.onReportReady; } });
Object.defineProperty(exports, "pubsubLevelUp", { enumerable: true, get: function () { return pubsub_handlers_1.onLevelUp; } });
// ─── Webhooks ───
var webhooks_handlers_1 = require("./webhooks/webhooks.handlers");
Object.defineProperty(exports, "stripeWebhook", { enumerable: true, get: function () { return webhooks_handlers_1.stripeWebhook; } });
Object.defineProperty(exports, "sendgridWebhook", { enumerable: true, get: function () { return webhooks_handlers_1.sendgridWebhook; } });
// ─── Express API (Admin + Jobs) ───
const api_router_1 = require("./api/api.router");
exports.api = functions.region(firebase_config_1.REGION).https.onRequest(api_router_1.app);
//# sourceMappingURL=index.js.map