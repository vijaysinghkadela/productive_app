"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.updateSettingsSchema = exports.getLeaderboardSchema = exports.joinChallengeSchema = exports.sendNudgeSchema = exports.invitePartnerSchema = exports.blockingScheduleSchema = exports.aiChatSchema = exports.journalEntrySchema = exports.trackHabitSchema = exports.createHabitSchema = exports.setGoalSchema = exports.syncDailyUsageSchema = exports.endSessionSchema = exports.createSessionSchema = exports.hexColorSchema = exports.timeSchema = exports.dateSchema = void 0;
const zod_1 = require("zod");
// ─── Common Validators ───
const dateRegex = /^\d{4}-\d{2}-\d{2}$/;
const timeRegex = /^\d{2}:\d{2}$/;
const hexColorRegex = /^#[0-9A-Fa-f]{6}$/;
exports.dateSchema = zod_1.z.string().regex(dateRegex, 'Invalid date format (YYYY-MM-DD)');
exports.timeSchema = zod_1.z.string().regex(timeRegex, 'Invalid time format (HH:mm)');
exports.hexColorSchema = zod_1.z.string().regex(hexColorRegex, 'Invalid hex color');
// ─── Session Validators ───
exports.createSessionSchema = zod_1.z.object({
    type: zod_1.z.enum([
        'deep_work',
        'study',
        'creative',
        'reading',
        'exercise',
        'meditation',
        'coding',
        'writing',
        'custom',
    ]),
    mode: zod_1.z.enum(['pomodoro', 'deep_work', 'ultra_focus', 'flowtime', 'custom']),
    plannedDurationMinutes: zod_1.z.number().int().min(1).max(480),
    focusModeId: zod_1.z.string().optional(),
    ambientSound: zod_1.z.string().optional(),
    deviceId: zod_1.z.string().min(1),
});
exports.endSessionSchema = zod_1.z.object({
    sessionId: zod_1.z.string().min(1),
    actualDurationMinutes: zod_1.z.number().min(0).max(480),
    distractionCount: zod_1.z.number().int().min(0),
    phases: zod_1.z
        .array(zod_1.z.object({
        phaseNumber: zod_1.z.number().int().min(1),
        type: zod_1.z.enum(['work', 'break']),
        plannedMinutes: zod_1.z.number().min(0),
        actualMinutes: zod_1.z.number().min(0),
        completed: zod_1.z.boolean(),
    }))
        .optional(),
    focusNote: zod_1.z.string().max(500).optional(),
    status: zod_1.z.enum(['completed', 'abandoned']),
});
// ─── Usage Validators ───
exports.syncDailyUsageSchema = zod_1.z.object({
    date: exports.dateSchema,
    appUsage: zod_1.z.record(zod_1.z.string(), zod_1.z.object({
        appName: zod_1.z.string(),
        category: zod_1.z.string(),
        totalMinutes: zod_1.z.number().min(0).max(1440),
        sessions: zod_1.z.number().int().min(0),
        firstUsed: exports.timeSchema,
        lastUsed: exports.timeSchema,
        hourlyMinutes: zod_1.z.array(zod_1.z.number().min(0)).length(24),
        isBlocked: zod_1.z.boolean(),
        overrideCount: zod_1.z.number().int().min(0),
    })),
    phonePickups: zod_1.z.number().int().min(0).max(1000),
    hourlyPickups: zod_1.z.array(zod_1.z.number().int().min(0)).length(24),
    firstPhoneUse: exports.timeSchema.nullable(),
    lastPhoneUse: exports.timeSchema.nullable(),
});
// ─── Goal Validators ───
exports.setGoalSchema = zod_1.z.object({
    type: zod_1.z.enum([
        'app_limit',
        'focus_target',
        'social_free_days',
        'weekly_focus_hours',
        'monthly_score',
        'custom',
    ]),
    name: zod_1.z.string().min(1).max(100),
    appId: zod_1.z.string().optional(),
    category: zod_1.z.string().optional(),
    targetValue: zod_1.z.number().min(1),
    unit: zod_1.z.enum(['minutes', 'hours', 'days', 'score', 'sessions']),
    frequency: zod_1.z.enum(['daily', 'weekly', 'monthly']),
    reminderEnabled: zod_1.z.boolean().default(false),
    reminderTime: exports.timeSchema.optional(),
    color: exports.hexColorSchema.default('#6C63FF'),
    icon: zod_1.z.string().default('🎯'),
    difficulty: zod_1.z.enum(['easy', 'medium', 'hard', 'custom']).default('medium'),
});
// ─── Habit Validators ───
exports.createHabitSchema = zod_1.z.object({
    name: zod_1.z.string().min(1).max(100),
    description: zod_1.z.string().max(500).optional(),
    icon: zod_1.z.string().default('✅'),
    color: exports.hexColorSchema.default('#6C63FF'),
    category: zod_1.z.enum([
        'digital_wellness',
        'productivity',
        'health',
        'mindfulness',
        'sleep',
        'social',
        'custom',
    ]),
    frequency: zod_1.z.object({
        type: zod_1.z.enum(['daily', 'weekdays', 'weekends', 'specific_days', 'x_per_week']),
        specificDays: zod_1.z.array(zod_1.z.number().int().min(0).max(6)).optional(),
        timesPerWeek: zod_1.z.number().int().min(1).max(7).optional(),
    }),
    reminderTime: exports.timeSchema.optional(),
    reminderDays: zod_1.z.array(zod_1.z.number().int().min(0).max(6)).default([]),
    stackedWith: zod_1.z.string().optional(),
    xpPerCompletion: zod_1.z.number().int().min(0).max(100).default(25),
});
exports.trackHabitSchema = zod_1.z.object({
    habitId: zod_1.z.string().min(1),
    date: exports.dateSchema,
    completed: zod_1.z.boolean(),
    skipped: zod_1.z.boolean().default(false),
    note: zod_1.z.string().max(500).optional(),
});
// ─── Journal Validators ───
exports.journalEntrySchema = zod_1.z.object({
    date: exports.dateSchema,
    mood: zod_1.z.number().int().min(1).max(5).optional(),
    moodLabel: zod_1.z.string().max(50).optional(),
    entry: zod_1.z.string().max(10000).optional(),
    gratitude: zod_1.z.array(zod_1.z.string().max(500)).max(3).default([]),
    reflectionAnswers: zod_1.z
        .array(zod_1.z.object({
        question: zod_1.z.string(),
        answer: zod_1.z.string().max(500),
    }))
        .max(5)
        .default([]),
    lessonsLearned: zod_1.z.array(zod_1.z.string().max(500)).max(5).default([]),
});
// ─── AI Chat Validators ───
exports.aiChatSchema = zod_1.z.object({
    message: zod_1.z.string().min(1).max(2000),
    conversationId: zod_1.z.string().optional(),
});
// ─── Blocking Schedule Validators ───
exports.blockingScheduleSchema = zod_1.z.object({
    name: zod_1.z.string().min(1).max(100),
    appIds: zod_1.z.array(zod_1.z.string()).min(1),
    categories: zod_1.z.array(zod_1.z.string()).default([]),
    schedule: zod_1.z.array(zod_1.z.object({
        dayOfWeek: zod_1.z.number().int().min(0).max(6),
        startTime: exports.timeSchema,
        endTime: exports.timeSchema,
        enabled: zod_1.z.boolean(),
    })),
    dailyLimitMinutes: zod_1.z.number().int().min(1).max(1440).optional(),
    gracePeriodMinutes: zod_1.z.number().int().min(0).max(30).default(5),
    strictMode: zod_1.z.boolean().default(false),
});
// ─── Accountability Validators ───
exports.invitePartnerSchema = zod_1.z.object({
    inviteCode: zod_1.z.string().min(6).max(6),
});
exports.sendNudgeSchema = zod_1.z.object({
    pairId: zod_1.z.string().min(1),
    text: zod_1.z.string().min(1).max(500),
    type: zod_1.z.enum(['text', 'cheer', 'nudge']),
});
// ─── Challenge Validators ───
exports.joinChallengeSchema = zod_1.z.object({
    challengeId: zod_1.z.string().min(1),
});
// ─── Leaderboard Validators ───
exports.getLeaderboardSchema = zod_1.z.object({
    period: zod_1.z.enum(['daily', 'weekly', 'monthly', 'alltime']),
    page: zod_1.z.number().int().min(1).default(1),
    pageSize: zod_1.z.number().int().min(1).max(50).default(20),
    countryFilter: zod_1.z.string().length(2).optional(),
});
// ─── Settings Validators ───
exports.updateSettingsSchema = zod_1.z.object({
    notifications: zod_1.z
        .object({
        enabled: zod_1.z.boolean(),
        blockingAlerts: zod_1.z.boolean(),
        goalWarnings: zod_1.z.boolean(),
        streakReminders: zod_1.z.boolean(),
        achievementAlerts: zod_1.z.boolean(),
        weeklyReport: zod_1.z.boolean(),
        aiInsights: zod_1.z.boolean(),
        partnerActivity: zod_1.z.boolean(),
        challengeUpdates: zod_1.z.boolean(),
        quietHoursStart: exports.timeSchema,
        quietHoursEnd: exports.timeSchema,
        smartScheduling: zod_1.z.boolean(),
    })
        .partial()
        .optional(),
    privacy: zod_1.z
        .object({
        showOnLeaderboard: zod_1.z.boolean(),
        showProfileToPartners: zod_1.z.boolean(),
        analyticsOptOut: zod_1.z.boolean(),
        shareUsageData: zod_1.z.boolean(),
    })
        .partial()
        .optional(),
    app: zod_1.z
        .object({
        theme: zod_1.z.enum(['dark', 'light', 'system']),
        accentColor: exports.hexColorSchema,
        fontSize: zod_1.z.enum(['small', 'medium', 'large']),
        hapticEnabled: zod_1.z.boolean(),
        reduceMotion: zod_1.z.boolean(),
    })
        .partial()
        .optional(),
    blocking: zod_1.z
        .object({
        overlayTheme: zod_1.z.enum(['motivational', 'scary', 'friendly']),
        gracePeriodMinutes: zod_1.z.number().int().min(0).max(30),
        cooldownAfterOverrides: zod_1.z.number().int().min(0).max(60),
        strictModeEnabled: zod_1.z.boolean(),
        biometricEnabled: zod_1.z.boolean(),
    })
        .partial()
        .optional(),
    focus: zod_1.z
        .object({
        defaultSessionType: zod_1.z.string(),
        defaultDuration: zod_1.z.number().int().min(1).max(480),
        autoStartBreak: zod_1.z.boolean(),
        endOfSessionSound: zod_1.z.string(),
    })
        .partial()
        .optional(),
});
//# sourceMappingURL=common.validators.js.map