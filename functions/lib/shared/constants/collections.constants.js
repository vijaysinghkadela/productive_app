"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Collections = void 0;
exports.userSubcollection = userSubcollection;
exports.leaderboardPeriod = leaderboardPeriod;
exports.challengeParticipants = challengeParticipants;
// Firestore collection path constants
exports.Collections = {
    USERS: 'users',
    SESSIONS: 'sessions',
    DAILY_STATS: 'daily_stats',
    GOALS: 'goals',
    HABITS: 'habits',
    ACHIEVEMENTS: 'achievements',
    JOURNAL: 'journal',
    NOTIFICATIONS: 'notifications',
    BLOCKING_SCHEDULE: 'blocking_schedule',
    FOCUS_MODES: 'focus_modes',
    AI_CONVERSATIONS: 'ai_conversations',
    ACCOUNTABILITY_PAIRS: 'accountability_pairs',
    ACCOUNTABILITY_GROUPS: 'accountability_groups',
    CHALLENGES: 'challenges',
    PARTICIPANTS: 'participants',
    LEADERBOARD: 'leaderboard',
    ENTRIES: 'entries',
    REPORTS: 'reports',
    REFERRALS: 'referrals',
    APP_CONFIG: 'app_config',
    ADMIN: 'admin',
    RATE_LIMITS: 'rate_limits',
    WEBHOOK_EVENTS: 'webhook_events',
};
// Subcollection path helpers
function userSubcollection(uid, sub) {
    return `${exports.Collections.USERS}/${uid}/${sub}`;
}
function leaderboardPeriod(period) {
    return `${exports.Collections.LEADERBOARD}/${period}/${exports.Collections.ENTRIES}`;
}
function challengeParticipants(challengeId) {
    return `${exports.Collections.CHALLENGES}/${challengeId}/${exports.Collections.PARTICIPANTS}`;
}
//# sourceMappingURL=collections.constants.js.map