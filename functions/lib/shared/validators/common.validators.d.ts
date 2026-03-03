import { z } from 'zod';
export declare const dateSchema: z.ZodString;
export declare const timeSchema: z.ZodString;
export declare const hexColorSchema: z.ZodString;
export declare const createSessionSchema: z.ZodObject<{
    type: z.ZodEnum<["deep_work", "study", "creative", "reading", "exercise", "meditation", "coding", "writing", "custom"]>;
    mode: z.ZodEnum<["pomodoro", "deep_work", "ultra_focus", "flowtime", "custom"]>;
    plannedDurationMinutes: z.ZodNumber;
    focusModeId: z.ZodOptional<z.ZodString>;
    ambientSound: z.ZodOptional<z.ZodString>;
    deviceId: z.ZodString;
}, "strip", z.ZodTypeAny, {
    type: "deep_work" | "study" | "creative" | "reading" | "exercise" | "meditation" | "coding" | "writing" | "custom";
    mode: "deep_work" | "custom" | "pomodoro" | "ultra_focus" | "flowtime";
    plannedDurationMinutes: number;
    deviceId: string;
    focusModeId?: string | undefined;
    ambientSound?: string | undefined;
}, {
    type: "deep_work" | "study" | "creative" | "reading" | "exercise" | "meditation" | "coding" | "writing" | "custom";
    mode: "deep_work" | "custom" | "pomodoro" | "ultra_focus" | "flowtime";
    plannedDurationMinutes: number;
    deviceId: string;
    focusModeId?: string | undefined;
    ambientSound?: string | undefined;
}>;
export declare const endSessionSchema: z.ZodObject<{
    sessionId: z.ZodString;
    actualDurationMinutes: z.ZodNumber;
    distractionCount: z.ZodNumber;
    phases: z.ZodOptional<z.ZodArray<z.ZodObject<{
        phaseNumber: z.ZodNumber;
        type: z.ZodEnum<["work", "break"]>;
        plannedMinutes: z.ZodNumber;
        actualMinutes: z.ZodNumber;
        completed: z.ZodBoolean;
    }, "strip", z.ZodTypeAny, {
        completed: boolean;
        type: "work" | "break";
        phaseNumber: number;
        plannedMinutes: number;
        actualMinutes: number;
    }, {
        completed: boolean;
        type: "work" | "break";
        phaseNumber: number;
        plannedMinutes: number;
        actualMinutes: number;
    }>, "many">>;
    focusNote: z.ZodOptional<z.ZodString>;
    status: z.ZodEnum<["completed", "abandoned"]>;
}, "strip", z.ZodTypeAny, {
    status: "completed" | "abandoned";
    sessionId: string;
    actualDurationMinutes: number;
    distractionCount: number;
    phases?: {
        completed: boolean;
        type: "work" | "break";
        phaseNumber: number;
        plannedMinutes: number;
        actualMinutes: number;
    }[] | undefined;
    focusNote?: string | undefined;
}, {
    status: "completed" | "abandoned";
    sessionId: string;
    actualDurationMinutes: number;
    distractionCount: number;
    phases?: {
        completed: boolean;
        type: "work" | "break";
        phaseNumber: number;
        plannedMinutes: number;
        actualMinutes: number;
    }[] | undefined;
    focusNote?: string | undefined;
}>;
export declare const syncDailyUsageSchema: z.ZodObject<{
    date: z.ZodString;
    appUsage: z.ZodRecord<z.ZodString, z.ZodObject<{
        appName: z.ZodString;
        category: z.ZodString;
        totalMinutes: z.ZodNumber;
        sessions: z.ZodNumber;
        firstUsed: z.ZodString;
        lastUsed: z.ZodString;
        hourlyMinutes: z.ZodArray<z.ZodNumber, "many">;
        isBlocked: z.ZodBoolean;
        overrideCount: z.ZodNumber;
    }, "strip", z.ZodTypeAny, {
        sessions: number;
        totalMinutes: number;
        category: string;
        appName: string;
        firstUsed: string;
        lastUsed: string;
        hourlyMinutes: number[];
        isBlocked: boolean;
        overrideCount: number;
    }, {
        sessions: number;
        totalMinutes: number;
        category: string;
        appName: string;
        firstUsed: string;
        lastUsed: string;
        hourlyMinutes: number[];
        isBlocked: boolean;
        overrideCount: number;
    }>>;
    phonePickups: z.ZodNumber;
    hourlyPickups: z.ZodArray<z.ZodNumber, "many">;
    firstPhoneUse: z.ZodNullable<z.ZodString>;
    lastPhoneUse: z.ZodNullable<z.ZodString>;
}, "strip", z.ZodTypeAny, {
    date: string;
    phonePickups: number;
    firstPhoneUse: string | null;
    lastPhoneUse: string | null;
    appUsage: Record<string, {
        sessions: number;
        totalMinutes: number;
        category: string;
        appName: string;
        firstUsed: string;
        lastUsed: string;
        hourlyMinutes: number[];
        isBlocked: boolean;
        overrideCount: number;
    }>;
    hourlyPickups: number[];
}, {
    date: string;
    phonePickups: number;
    firstPhoneUse: string | null;
    lastPhoneUse: string | null;
    appUsage: Record<string, {
        sessions: number;
        totalMinutes: number;
        category: string;
        appName: string;
        firstUsed: string;
        lastUsed: string;
        hourlyMinutes: number[];
        isBlocked: boolean;
        overrideCount: number;
    }>;
    hourlyPickups: number[];
}>;
export declare const setGoalSchema: z.ZodObject<{
    type: z.ZodEnum<["app_limit", "focus_target", "social_free_days", "weekly_focus_hours", "monthly_score", "custom"]>;
    name: z.ZodString;
    appId: z.ZodOptional<z.ZodString>;
    category: z.ZodOptional<z.ZodString>;
    targetValue: z.ZodNumber;
    unit: z.ZodEnum<["minutes", "hours", "days", "score", "sessions"]>;
    frequency: z.ZodEnum<["daily", "weekly", "monthly"]>;
    reminderEnabled: z.ZodDefault<z.ZodBoolean>;
    reminderTime: z.ZodOptional<z.ZodString>;
    color: z.ZodDefault<z.ZodString>;
    icon: z.ZodDefault<z.ZodString>;
    difficulty: z.ZodDefault<z.ZodEnum<["easy", "medium", "hard", "custom"]>>;
}, "strip", z.ZodTypeAny, {
    name: string;
    type: "custom" | "app_limit" | "focus_target" | "social_free_days" | "weekly_focus_hours" | "monthly_score";
    targetValue: number;
    unit: "sessions" | "minutes" | "hours" | "days" | "score";
    frequency: "daily" | "weekly" | "monthly";
    color: string;
    icon: string;
    reminderEnabled: boolean;
    difficulty: "medium" | "custom" | "easy" | "hard";
    appId?: string | undefined;
    category?: string | undefined;
    reminderTime?: string | undefined;
}, {
    name: string;
    type: "custom" | "app_limit" | "focus_target" | "social_free_days" | "weekly_focus_hours" | "monthly_score";
    targetValue: number;
    unit: "sessions" | "minutes" | "hours" | "days" | "score";
    frequency: "daily" | "weekly" | "monthly";
    appId?: string | undefined;
    category?: string | undefined;
    color?: string | undefined;
    icon?: string | undefined;
    reminderEnabled?: boolean | undefined;
    reminderTime?: string | undefined;
    difficulty?: "medium" | "custom" | "easy" | "hard" | undefined;
}>;
export declare const createHabitSchema: z.ZodObject<{
    name: z.ZodString;
    description: z.ZodOptional<z.ZodString>;
    icon: z.ZodDefault<z.ZodString>;
    color: z.ZodDefault<z.ZodString>;
    category: z.ZodEnum<["digital_wellness", "productivity", "health", "mindfulness", "sleep", "social", "custom"]>;
    frequency: z.ZodObject<{
        type: z.ZodEnum<["daily", "weekdays", "weekends", "specific_days", "x_per_week"]>;
        specificDays: z.ZodOptional<z.ZodArray<z.ZodNumber, "many">>;
        timesPerWeek: z.ZodOptional<z.ZodNumber>;
    }, "strip", z.ZodTypeAny, {
        type: "daily" | "weekdays" | "weekends" | "specific_days" | "x_per_week";
        specificDays?: number[] | undefined;
        timesPerWeek?: number | undefined;
    }, {
        type: "daily" | "weekdays" | "weekends" | "specific_days" | "x_per_week";
        specificDays?: number[] | undefined;
        timesPerWeek?: number | undefined;
    }>;
    reminderTime: z.ZodOptional<z.ZodString>;
    reminderDays: z.ZodDefault<z.ZodArray<z.ZodNumber, "many">>;
    stackedWith: z.ZodOptional<z.ZodString>;
    xpPerCompletion: z.ZodDefault<z.ZodNumber>;
}, "strip", z.ZodTypeAny, {
    name: string;
    category: "custom" | "digital_wellness" | "productivity" | "health" | "mindfulness" | "sleep" | "social";
    frequency: {
        type: "daily" | "weekdays" | "weekends" | "specific_days" | "x_per_week";
        specificDays?: number[] | undefined;
        timesPerWeek?: number | undefined;
    };
    color: string;
    icon: string;
    xpPerCompletion: number;
    reminderDays: number[];
    description?: string | undefined;
    reminderTime?: string | undefined;
    stackedWith?: string | undefined;
}, {
    name: string;
    category: "custom" | "digital_wellness" | "productivity" | "health" | "mindfulness" | "sleep" | "social";
    frequency: {
        type: "daily" | "weekdays" | "weekends" | "specific_days" | "x_per_week";
        specificDays?: number[] | undefined;
        timesPerWeek?: number | undefined;
    };
    description?: string | undefined;
    color?: string | undefined;
    icon?: string | undefined;
    reminderTime?: string | undefined;
    stackedWith?: string | undefined;
    xpPerCompletion?: number | undefined;
    reminderDays?: number[] | undefined;
}>;
export declare const trackHabitSchema: z.ZodObject<{
    habitId: z.ZodString;
    date: z.ZodString;
    completed: z.ZodBoolean;
    skipped: z.ZodDefault<z.ZodBoolean>;
    note: z.ZodOptional<z.ZodString>;
}, "strip", z.ZodTypeAny, {
    completed: boolean;
    date: string;
    habitId: string;
    skipped: boolean;
    note?: string | undefined;
}, {
    completed: boolean;
    date: string;
    habitId: string;
    skipped?: boolean | undefined;
    note?: string | undefined;
}>;
export declare const journalEntrySchema: z.ZodObject<{
    date: z.ZodString;
    mood: z.ZodOptional<z.ZodNumber>;
    moodLabel: z.ZodOptional<z.ZodString>;
    entry: z.ZodOptional<z.ZodString>;
    gratitude: z.ZodDefault<z.ZodArray<z.ZodString, "many">>;
    reflectionAnswers: z.ZodDefault<z.ZodArray<z.ZodObject<{
        question: z.ZodString;
        answer: z.ZodString;
    }, "strip", z.ZodTypeAny, {
        question: string;
        answer: string;
    }, {
        question: string;
        answer: string;
    }>, "many">>;
    lessonsLearned: z.ZodDefault<z.ZodArray<z.ZodString, "many">>;
}, "strip", z.ZodTypeAny, {
    date: string;
    gratitude: string[];
    reflectionAnswers: {
        question: string;
        answer: string;
    }[];
    lessonsLearned: string[];
    mood?: number | undefined;
    moodLabel?: string | undefined;
    entry?: string | undefined;
}, {
    date: string;
    mood?: number | undefined;
    moodLabel?: string | undefined;
    entry?: string | undefined;
    gratitude?: string[] | undefined;
    reflectionAnswers?: {
        question: string;
        answer: string;
    }[] | undefined;
    lessonsLearned?: string[] | undefined;
}>;
export declare const aiChatSchema: z.ZodObject<{
    message: z.ZodString;
    conversationId: z.ZodOptional<z.ZodString>;
}, "strip", z.ZodTypeAny, {
    message: string;
    conversationId?: string | undefined;
}, {
    message: string;
    conversationId?: string | undefined;
}>;
export declare const blockingScheduleSchema: z.ZodObject<{
    name: z.ZodString;
    appIds: z.ZodArray<z.ZodString, "many">;
    categories: z.ZodDefault<z.ZodArray<z.ZodString, "many">>;
    schedule: z.ZodArray<z.ZodObject<{
        dayOfWeek: z.ZodNumber;
        startTime: z.ZodString;
        endTime: z.ZodString;
        enabled: z.ZodBoolean;
    }, "strip", z.ZodTypeAny, {
        enabled: boolean;
        dayOfWeek: number;
        startTime: string;
        endTime: string;
    }, {
        enabled: boolean;
        dayOfWeek: number;
        startTime: string;
        endTime: string;
    }>, "many">;
    dailyLimitMinutes: z.ZodOptional<z.ZodNumber>;
    gracePeriodMinutes: z.ZodDefault<z.ZodNumber>;
    strictMode: z.ZodDefault<z.ZodBoolean>;
}, "strip", z.ZodTypeAny, {
    name: string;
    appIds: string[];
    categories: string[];
    schedule: {
        enabled: boolean;
        dayOfWeek: number;
        startTime: string;
        endTime: string;
    }[];
    gracePeriodMinutes: number;
    strictMode: boolean;
    dailyLimitMinutes?: number | undefined;
}, {
    name: string;
    appIds: string[];
    schedule: {
        enabled: boolean;
        dayOfWeek: number;
        startTime: string;
        endTime: string;
    }[];
    categories?: string[] | undefined;
    dailyLimitMinutes?: number | undefined;
    gracePeriodMinutes?: number | undefined;
    strictMode?: boolean | undefined;
}>;
export declare const invitePartnerSchema: z.ZodObject<{
    inviteCode: z.ZodString;
}, "strip", z.ZodTypeAny, {
    inviteCode: string;
}, {
    inviteCode: string;
}>;
export declare const sendNudgeSchema: z.ZodObject<{
    pairId: z.ZodString;
    text: z.ZodString;
    type: z.ZodEnum<["text", "cheer", "nudge"]>;
}, "strip", z.ZodTypeAny, {
    text: string;
    type: "text" | "cheer" | "nudge";
    pairId: string;
}, {
    text: string;
    type: "text" | "cheer" | "nudge";
    pairId: string;
}>;
export declare const joinChallengeSchema: z.ZodObject<{
    challengeId: z.ZodString;
}, "strip", z.ZodTypeAny, {
    challengeId: string;
}, {
    challengeId: string;
}>;
export declare const getLeaderboardSchema: z.ZodObject<{
    period: z.ZodEnum<["daily", "weekly", "monthly", "alltime"]>;
    page: z.ZodDefault<z.ZodNumber>;
    pageSize: z.ZodDefault<z.ZodNumber>;
    countryFilter: z.ZodOptional<z.ZodString>;
}, "strip", z.ZodTypeAny, {
    period: "daily" | "weekly" | "monthly" | "alltime";
    page: number;
    pageSize: number;
    countryFilter?: string | undefined;
}, {
    period: "daily" | "weekly" | "monthly" | "alltime";
    page?: number | undefined;
    pageSize?: number | undefined;
    countryFilter?: string | undefined;
}>;
export declare const updateSettingsSchema: z.ZodObject<{
    notifications: z.ZodOptional<z.ZodObject<{
        enabled: z.ZodOptional<z.ZodBoolean>;
        blockingAlerts: z.ZodOptional<z.ZodBoolean>;
        goalWarnings: z.ZodOptional<z.ZodBoolean>;
        streakReminders: z.ZodOptional<z.ZodBoolean>;
        achievementAlerts: z.ZodOptional<z.ZodBoolean>;
        weeklyReport: z.ZodOptional<z.ZodBoolean>;
        aiInsights: z.ZodOptional<z.ZodBoolean>;
        partnerActivity: z.ZodOptional<z.ZodBoolean>;
        challengeUpdates: z.ZodOptional<z.ZodBoolean>;
        quietHoursStart: z.ZodOptional<z.ZodString>;
        quietHoursEnd: z.ZodOptional<z.ZodString>;
        smartScheduling: z.ZodOptional<z.ZodBoolean>;
    }, "strip", z.ZodTypeAny, {
        enabled?: boolean | undefined;
        blockingAlerts?: boolean | undefined;
        goalWarnings?: boolean | undefined;
        streakReminders?: boolean | undefined;
        achievementAlerts?: boolean | undefined;
        weeklyReport?: boolean | undefined;
        aiInsights?: boolean | undefined;
        partnerActivity?: boolean | undefined;
        challengeUpdates?: boolean | undefined;
        quietHoursStart?: string | undefined;
        quietHoursEnd?: string | undefined;
        smartScheduling?: boolean | undefined;
    }, {
        enabled?: boolean | undefined;
        blockingAlerts?: boolean | undefined;
        goalWarnings?: boolean | undefined;
        streakReminders?: boolean | undefined;
        achievementAlerts?: boolean | undefined;
        weeklyReport?: boolean | undefined;
        aiInsights?: boolean | undefined;
        partnerActivity?: boolean | undefined;
        challengeUpdates?: boolean | undefined;
        quietHoursStart?: string | undefined;
        quietHoursEnd?: string | undefined;
        smartScheduling?: boolean | undefined;
    }>>;
    privacy: z.ZodOptional<z.ZodObject<{
        showOnLeaderboard: z.ZodOptional<z.ZodBoolean>;
        showProfileToPartners: z.ZodOptional<z.ZodBoolean>;
        analyticsOptOut: z.ZodOptional<z.ZodBoolean>;
        shareUsageData: z.ZodOptional<z.ZodBoolean>;
    }, "strip", z.ZodTypeAny, {
        showOnLeaderboard?: boolean | undefined;
        showProfileToPartners?: boolean | undefined;
        analyticsOptOut?: boolean | undefined;
        shareUsageData?: boolean | undefined;
    }, {
        showOnLeaderboard?: boolean | undefined;
        showProfileToPartners?: boolean | undefined;
        analyticsOptOut?: boolean | undefined;
        shareUsageData?: boolean | undefined;
    }>>;
    app: z.ZodOptional<z.ZodObject<{
        theme: z.ZodOptional<z.ZodEnum<["dark", "light", "system"]>>;
        accentColor: z.ZodOptional<z.ZodString>;
        fontSize: z.ZodOptional<z.ZodEnum<["small", "medium", "large"]>>;
        hapticEnabled: z.ZodOptional<z.ZodBoolean>;
        reduceMotion: z.ZodOptional<z.ZodBoolean>;
    }, "strip", z.ZodTypeAny, {
        theme?: "dark" | "light" | "system" | undefined;
        accentColor?: string | undefined;
        fontSize?: "small" | "medium" | "large" | undefined;
        hapticEnabled?: boolean | undefined;
        reduceMotion?: boolean | undefined;
    }, {
        theme?: "dark" | "light" | "system" | undefined;
        accentColor?: string | undefined;
        fontSize?: "small" | "medium" | "large" | undefined;
        hapticEnabled?: boolean | undefined;
        reduceMotion?: boolean | undefined;
    }>>;
    blocking: z.ZodOptional<z.ZodObject<{
        overlayTheme: z.ZodOptional<z.ZodEnum<["motivational", "scary", "friendly"]>>;
        gracePeriodMinutes: z.ZodOptional<z.ZodNumber>;
        cooldownAfterOverrides: z.ZodOptional<z.ZodNumber>;
        strictModeEnabled: z.ZodOptional<z.ZodBoolean>;
        biometricEnabled: z.ZodOptional<z.ZodBoolean>;
    }, "strip", z.ZodTypeAny, {
        gracePeriodMinutes?: number | undefined;
        overlayTheme?: "motivational" | "scary" | "friendly" | undefined;
        cooldownAfterOverrides?: number | undefined;
        strictModeEnabled?: boolean | undefined;
        biometricEnabled?: boolean | undefined;
    }, {
        gracePeriodMinutes?: number | undefined;
        overlayTheme?: "motivational" | "scary" | "friendly" | undefined;
        cooldownAfterOverrides?: number | undefined;
        strictModeEnabled?: boolean | undefined;
        biometricEnabled?: boolean | undefined;
    }>>;
    focus: z.ZodOptional<z.ZodObject<{
        defaultSessionType: z.ZodOptional<z.ZodString>;
        defaultDuration: z.ZodOptional<z.ZodNumber>;
        autoStartBreak: z.ZodOptional<z.ZodBoolean>;
        endOfSessionSound: z.ZodOptional<z.ZodString>;
    }, "strip", z.ZodTypeAny, {
        defaultSessionType?: string | undefined;
        defaultDuration?: number | undefined;
        autoStartBreak?: boolean | undefined;
        endOfSessionSound?: string | undefined;
    }, {
        defaultSessionType?: string | undefined;
        defaultDuration?: number | undefined;
        autoStartBreak?: boolean | undefined;
        endOfSessionSound?: string | undefined;
    }>>;
}, "strip", z.ZodTypeAny, {
    notifications?: {
        enabled?: boolean | undefined;
        blockingAlerts?: boolean | undefined;
        goalWarnings?: boolean | undefined;
        streakReminders?: boolean | undefined;
        achievementAlerts?: boolean | undefined;
        weeklyReport?: boolean | undefined;
        aiInsights?: boolean | undefined;
        partnerActivity?: boolean | undefined;
        challengeUpdates?: boolean | undefined;
        quietHoursStart?: string | undefined;
        quietHoursEnd?: string | undefined;
        smartScheduling?: boolean | undefined;
    } | undefined;
    focus?: {
        defaultSessionType?: string | undefined;
        defaultDuration?: number | undefined;
        autoStartBreak?: boolean | undefined;
        endOfSessionSound?: string | undefined;
    } | undefined;
    privacy?: {
        showOnLeaderboard?: boolean | undefined;
        showProfileToPartners?: boolean | undefined;
        analyticsOptOut?: boolean | undefined;
        shareUsageData?: boolean | undefined;
    } | undefined;
    app?: {
        theme?: "dark" | "light" | "system" | undefined;
        accentColor?: string | undefined;
        fontSize?: "small" | "medium" | "large" | undefined;
        hapticEnabled?: boolean | undefined;
        reduceMotion?: boolean | undefined;
    } | undefined;
    blocking?: {
        gracePeriodMinutes?: number | undefined;
        overlayTheme?: "motivational" | "scary" | "friendly" | undefined;
        cooldownAfterOverrides?: number | undefined;
        strictModeEnabled?: boolean | undefined;
        biometricEnabled?: boolean | undefined;
    } | undefined;
}, {
    notifications?: {
        enabled?: boolean | undefined;
        blockingAlerts?: boolean | undefined;
        goalWarnings?: boolean | undefined;
        streakReminders?: boolean | undefined;
        achievementAlerts?: boolean | undefined;
        weeklyReport?: boolean | undefined;
        aiInsights?: boolean | undefined;
        partnerActivity?: boolean | undefined;
        challengeUpdates?: boolean | undefined;
        quietHoursStart?: string | undefined;
        quietHoursEnd?: string | undefined;
        smartScheduling?: boolean | undefined;
    } | undefined;
    focus?: {
        defaultSessionType?: string | undefined;
        defaultDuration?: number | undefined;
        autoStartBreak?: boolean | undefined;
        endOfSessionSound?: string | undefined;
    } | undefined;
    privacy?: {
        showOnLeaderboard?: boolean | undefined;
        showProfileToPartners?: boolean | undefined;
        analyticsOptOut?: boolean | undefined;
        shareUsageData?: boolean | undefined;
    } | undefined;
    app?: {
        theme?: "dark" | "light" | "system" | undefined;
        accentColor?: string | undefined;
        fontSize?: "small" | "medium" | "large" | undefined;
        hapticEnabled?: boolean | undefined;
        reduceMotion?: boolean | undefined;
    } | undefined;
    blocking?: {
        gracePeriodMinutes?: number | undefined;
        overlayTheme?: "motivational" | "scary" | "friendly" | undefined;
        cooldownAfterOverrides?: number | undefined;
        strictModeEnabled?: boolean | undefined;
        biometricEnabled?: boolean | undefined;
    } | undefined;
}>;
//# sourceMappingURL=common.validators.d.ts.map