export declare const Collections: {
    readonly USERS: "users";
    readonly SESSIONS: "sessions";
    readonly DAILY_STATS: "daily_stats";
    readonly GOALS: "goals";
    readonly HABITS: "habits";
    readonly ACHIEVEMENTS: "achievements";
    readonly JOURNAL: "journal";
    readonly NOTIFICATIONS: "notifications";
    readonly BLOCKING_SCHEDULE: "blocking_schedule";
    readonly FOCUS_MODES: "focus_modes";
    readonly AI_CONVERSATIONS: "ai_conversations";
    readonly ACCOUNTABILITY_PAIRS: "accountability_pairs";
    readonly ACCOUNTABILITY_GROUPS: "accountability_groups";
    readonly CHALLENGES: "challenges";
    readonly PARTICIPANTS: "participants";
    readonly LEADERBOARD: "leaderboard";
    readonly ENTRIES: "entries";
    readonly REPORTS: "reports";
    readonly REFERRALS: "referrals";
    readonly APP_CONFIG: "app_config";
    readonly ADMIN: "admin";
    readonly RATE_LIMITS: "rate_limits";
    readonly WEBHOOK_EVENTS: "webhook_events";
};
export declare function userSubcollection(uid: string, sub: string): string;
export declare function leaderboardPeriod(period: string): string;
export declare function challengeParticipants(challengeId: string): string;
//# sourceMappingURL=collections.constants.d.ts.map