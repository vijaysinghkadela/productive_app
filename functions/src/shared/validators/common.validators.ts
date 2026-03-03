import { z } from 'zod';

// ─── Common Validators ───
const dateRegex = /^\d{4}-\d{2}-\d{2}$/;
const timeRegex = /^\d{2}:\d{2}$/;
const hexColorRegex = /^#[0-9A-Fa-f]{6}$/;

export const dateSchema = z.string().regex(dateRegex, 'Invalid date format (YYYY-MM-DD)');
export const timeSchema = z.string().regex(timeRegex, 'Invalid time format (HH:mm)');
export const hexColorSchema = z.string().regex(hexColorRegex, 'Invalid hex color');

// ─── Session Validators ───
export const createSessionSchema = z.object({
  type: z.enum([
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
  mode: z.enum(['pomodoro', 'deep_work', 'ultra_focus', 'flowtime', 'custom']),
  plannedDurationMinutes: z.number().int().min(1).max(480),
  focusModeId: z.string().optional(),
  ambientSound: z.string().optional(),
  deviceId: z.string().min(1),
});

export const endSessionSchema = z.object({
  sessionId: z.string().min(1),
  actualDurationMinutes: z.number().min(0).max(480),
  distractionCount: z.number().int().min(0),
  phases: z
    .array(
      z.object({
        phaseNumber: z.number().int().min(1),
        type: z.enum(['work', 'break']),
        plannedMinutes: z.number().min(0),
        actualMinutes: z.number().min(0),
        completed: z.boolean(),
      }),
    )
    .optional(),
  focusNote: z.string().max(500).optional(),
  status: z.enum(['completed', 'abandoned']),
});

// ─── Usage Validators ───
export const syncDailyUsageSchema = z.object({
  date: dateSchema,
  appUsage: z.record(
    z.string(),
    z.object({
      appName: z.string(),
      category: z.string(),
      totalMinutes: z.number().min(0).max(1440),
      sessions: z.number().int().min(0),
      firstUsed: timeSchema,
      lastUsed: timeSchema,
      hourlyMinutes: z.array(z.number().min(0)).length(24),
      isBlocked: z.boolean(),
      overrideCount: z.number().int().min(0),
    }),
  ),
  phonePickups: z.number().int().min(0).max(1000),
  hourlyPickups: z.array(z.number().int().min(0)).length(24),
  firstPhoneUse: timeSchema.nullable(),
  lastPhoneUse: timeSchema.nullable(),
});

// ─── Goal Validators ───
export const setGoalSchema = z.object({
  type: z.enum([
    'app_limit',
    'focus_target',
    'social_free_days',
    'weekly_focus_hours',
    'monthly_score',
    'custom',
  ]),
  name: z.string().min(1).max(100),
  appId: z.string().optional(),
  category: z.string().optional(),
  targetValue: z.number().min(1),
  unit: z.enum(['minutes', 'hours', 'days', 'score', 'sessions']),
  frequency: z.enum(['daily', 'weekly', 'monthly']),
  reminderEnabled: z.boolean().default(false),
  reminderTime: timeSchema.optional(),
  color: hexColorSchema.default('#6C63FF'),
  icon: z.string().default('🎯'),
  difficulty: z.enum(['easy', 'medium', 'hard', 'custom']).default('medium'),
});

// ─── Habit Validators ───
export const createHabitSchema = z.object({
  name: z.string().min(1).max(100),
  description: z.string().max(500).optional(),
  icon: z.string().default('✅'),
  color: hexColorSchema.default('#6C63FF'),
  category: z.enum([
    'digital_wellness',
    'productivity',
    'health',
    'mindfulness',
    'sleep',
    'social',
    'custom',
  ]),
  frequency: z.object({
    type: z.enum(['daily', 'weekdays', 'weekends', 'specific_days', 'x_per_week']),
    specificDays: z.array(z.number().int().min(0).max(6)).optional(),
    timesPerWeek: z.number().int().min(1).max(7).optional(),
  }),
  reminderTime: timeSchema.optional(),
  reminderDays: z.array(z.number().int().min(0).max(6)).default([]),
  stackedWith: z.string().optional(),
  xpPerCompletion: z.number().int().min(0).max(100).default(25),
});

export const trackHabitSchema = z.object({
  habitId: z.string().min(1),
  date: dateSchema,
  completed: z.boolean(),
  skipped: z.boolean().default(false),
  note: z.string().max(500).optional(),
});

// ─── Journal Validators ───
export const journalEntrySchema = z.object({
  date: dateSchema,
  mood: z.number().int().min(1).max(5).optional(),
  moodLabel: z.string().max(50).optional(),
  entry: z.string().max(10000).optional(),
  gratitude: z.array(z.string().max(500)).max(3).default([]),
  reflectionAnswers: z
    .array(
      z.object({
        question: z.string(),
        answer: z.string().max(500),
      }),
    )
    .max(5)
    .default([]),
  lessonsLearned: z.array(z.string().max(500)).max(5).default([]),
});

// ─── AI Chat Validators ───
export const aiChatSchema = z.object({
  message: z.string().min(1).max(2000),
  conversationId: z.string().optional(),
});

// ─── Blocking Schedule Validators ───
export const blockingScheduleSchema = z.object({
  name: z.string().min(1).max(100),
  appIds: z.array(z.string()).min(1),
  categories: z.array(z.string()).default([]),
  schedule: z.array(
    z.object({
      dayOfWeek: z.number().int().min(0).max(6),
      startTime: timeSchema,
      endTime: timeSchema,
      enabled: z.boolean(),
    }),
  ),
  dailyLimitMinutes: z.number().int().min(1).max(1440).optional(),
  gracePeriodMinutes: z.number().int().min(0).max(30).default(5),
  strictMode: z.boolean().default(false),
});

// ─── Accountability Validators ───
export const invitePartnerSchema = z.object({
  inviteCode: z.string().min(6).max(6),
});

export const sendNudgeSchema = z.object({
  pairId: z.string().min(1),
  text: z.string().min(1).max(500),
  type: z.enum(['text', 'cheer', 'nudge']),
});

// ─── Challenge Validators ───
export const joinChallengeSchema = z.object({
  challengeId: z.string().min(1),
});

// ─── Leaderboard Validators ───
export const getLeaderboardSchema = z.object({
  period: z.enum(['daily', 'weekly', 'monthly', 'alltime']),
  page: z.number().int().min(1).default(1),
  pageSize: z.number().int().min(1).max(50).default(20),
  countryFilter: z.string().length(2).optional(),
});

// ─── Settings Validators ───
export const updateSettingsSchema = z.object({
  notifications: z
    .object({
      enabled: z.boolean(),
      blockingAlerts: z.boolean(),
      goalWarnings: z.boolean(),
      streakReminders: z.boolean(),
      achievementAlerts: z.boolean(),
      weeklyReport: z.boolean(),
      aiInsights: z.boolean(),
      partnerActivity: z.boolean(),
      challengeUpdates: z.boolean(),
      quietHoursStart: timeSchema,
      quietHoursEnd: timeSchema,
      smartScheduling: z.boolean(),
    })
    .partial()
    .optional(),
  privacy: z
    .object({
      showOnLeaderboard: z.boolean(),
      showProfileToPartners: z.boolean(),
      analyticsOptOut: z.boolean(),
      shareUsageData: z.boolean(),
    })
    .partial()
    .optional(),
  app: z
    .object({
      theme: z.enum(['dark', 'light', 'system']),
      accentColor: hexColorSchema,
      fontSize: z.enum(['small', 'medium', 'large']),
      hapticEnabled: z.boolean(),
      reduceMotion: z.boolean(),
    })
    .partial()
    .optional(),
  blocking: z
    .object({
      overlayTheme: z.enum(['motivational', 'scary', 'friendly']),
      gracePeriodMinutes: z.number().int().min(0).max(30),
      cooldownAfterOverrides: z.number().int().min(0).max(60),
      strictModeEnabled: z.boolean(),
      biometricEnabled: z.boolean(),
    })
    .partial()
    .optional(),
  focus: z
    .object({
      defaultSessionType: z.string(),
      defaultDuration: z.number().int().min(1).max(480),
      autoStartBreak: z.boolean(),
      endOfSessionSound: z.string(),
    })
    .partial()
    .optional(),
});
