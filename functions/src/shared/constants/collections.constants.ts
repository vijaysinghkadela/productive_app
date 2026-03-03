// Firestore collection path constants
export const Collections = {
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
} as const;

// Subcollection path helpers
export function userSubcollection(uid: string, sub: string): string {
  return `${Collections.USERS}/${uid}/${sub}`;
}

export function leaderboardPeriod(period: string): string {
  return `${Collections.LEADERBOARD}/${period}/${Collections.ENTRIES}`;
}

export function challengeParticipants(challengeId: string): string {
  return `${Collections.CHALLENGES}/${challengeId}/${Collections.PARTICIPANTS}`;
}
