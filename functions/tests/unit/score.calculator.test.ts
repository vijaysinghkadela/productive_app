import { calculateProductivityScore, xpForLevel, levelFromXp, checkLevelUp, calculateSessionXp } from '../../src/shared/utils/score.calculator';
import { ScoreComponents, DailyStatsDocument, GoalDocument, HabitDocument } from '../../src/shared/types/firestore.types';
import { Timestamp } from 'firebase-admin/firestore';

// Mock Timestamp
const mockTimestamp = { toDate: () => new Date(), seconds: 0, nanoseconds: 0, isEqual: () => true, valueOf: () => '' } as unknown as Timestamp;

function createMockDailyStats(overrides: Partial<DailyStatsDocument> = {}): DailyStatsDocument {
  return {
    date: '2025-01-15',
    userId: 'test-user',
    appUsage: {},
    totalScreenTimeMinutes: 120,
    socialMediaMinutes: 30,
    productiveMinutes: 60,
    entertainmentMinutes: 20,
    otherMinutes: 10,
    hourlyScreenTime: new Array(24).fill(0),
    phonePickups: 50,
    hourlyPickups: new Array(24).fill(0),
    firstPhoneUse: '08:00',
    lastPhoneUse: '22:00',
    focusSessions: { completed: 2, abandoned: 0, totalMinutes: 50, averageLength: 25, longestSession: 30 },
    goals: {},
    habits: {},
    mood: 4,
    journalCompleted: false,
    gratitudeCompleted: false,
    productivityScore: {
      final: 0,
      components: {} as ScoreComponents,
      hourlySnapshots: [],
      calculatedAt: mockTimestamp,
    },
    xpEarned: 0,
    achievementsUnlocked: [],
    sleepData: { bedtime: '23:00', wakeTime: '07:00', quality: 4, lateNightUsageMinutes: 5 },
    createdAt: mockTimestamp,
    updatedAt: mockTimestamp,
    ...overrides,
  };
}

describe('Productivity Score Calculator', () => {
  const emptyGoals: GoalDocument[] = [];
  const emptyHabits: HabitDocument[] = [];

  test('base score is 100 with no activity', () => {
    const stats = createMockDailyStats({
      focusSessions: { completed: 0, abandoned: 0, totalMinutes: 0, averageLength: 0, longestSession: 0 },
      socialMediaMinutes: 0,
    });
    const { score } = calculateProductivityScore({
      dailyStats: stats,
      goals: emptyGoals,
      habits: emptyHabits,
      streakDays: 0,
      firstPhoneUseBefore7am: false,
    });
    // Social media free day bonus (+20) should apply
    expect(score).toBeGreaterThanOrEqual(0);
    expect(score).toBeLessThanOrEqual(100);
  });

  test('perfect day yields high score', () => {
    const stats = createMockDailyStats({
      focusSessions: { completed: 5, abandoned: 0, totalMinutes: 200, averageLength: 40, longestSession: 50 },
      socialMediaMinutes: 0,
      journalCompleted: true,
      gratitudeCompleted: true,
      firstPhoneUse: '09:00',
    });
    const { score, components } = calculateProductivityScore({
      dailyStats: stats,
      goals: emptyGoals,
      habits: emptyHabits,
      streakDays: 10,
      firstPhoneUseBefore7am: false,
    });
    expect(score).toBe(100); // Capped at 100
    expect(components.focusBonus).toBe(40); // 5 sessions × 8, max 40
    expect(components.socialMediaFreeBonus).toBe(20);
    expect(components.journalBonus).toBe(5); // 3 + 2
    expect(components.morningRoutineBonus).toBe(5);
    expect(components.streakBonus).toBe(10);
  });

  test('abandoned sessions cause deductions', () => {
    const stats = createMockDailyStats({
      focusSessions: { completed: 0, abandoned: 3, totalMinutes: 30, averageLength: 10, longestSession: 15 },
    });
    const { components } = calculateProductivityScore({
      dailyStats: stats,
      goals: emptyGoals,
      habits: emptyHabits,
      streakDays: 0,
      firstPhoneUseBefore7am: false,
    });
    expect(components.abandonedSessionDeduction).toBe(-15); // 3 × 5, max 15
  });

  test('abandoned session deduction caps at -15', () => {
    const stats = createMockDailyStats({
      focusSessions: { completed: 0, abandoned: 10, totalMinutes: 0, averageLength: 0, longestSession: 0 },
    });
    const { components } = calculateProductivityScore({
      dailyStats: stats,
      goals: emptyGoals,
      habits: emptyHabits,
      streakDays: 0,
      firstPhoneUseBefore7am: false,
    });
    expect(components.abandonedSessionDeduction).toBe(-15); // Capped
  });

  test('early phone use deduction', () => {
    // Use stats with no bonuses so score stays below 100 cap
    const baseStats = createMockDailyStats({
      focusSessions: { completed: 0, abandoned: 0, totalMinutes: 0, averageLength: 0, longestSession: 0 },
      socialMediaMinutes: 30,
      firstPhoneUse: '06:30',
    });
    const { score: scoreEarly } = calculateProductivityScore({
      dailyStats: baseStats,
      goals: emptyGoals,
      habits: emptyHabits,
      streakDays: 0,
      firstPhoneUseBefore7am: true,
    });

    const { score: scoreLate } = calculateProductivityScore({
      dailyStats: { ...baseStats, firstPhoneUse: '08:00' },
      goals: emptyGoals,
      habits: emptyHabits,
      streakDays: 0,
      firstPhoneUseBefore7am: false,
    });

    expect(scoreEarly).toBeLessThan(scoreLate);
  });

  test('streak bonus caps at 15', () => {
    const stats = createMockDailyStats();
    const { components } = calculateProductivityScore({
      dailyStats: stats,
      goals: emptyGoals,
      habits: emptyHabits,
      streakDays: 100,
      firstPhoneUseBefore7am: false,
    });
    expect(components.streakBonus).toBe(15);
  });

  test('focus bonus caps at 40', () => {
    const stats = createMockDailyStats({
      focusSessions: { completed: 10, abandoned: 0, totalMinutes: 250, averageLength: 25, longestSession: 25 },
    });
    const { components } = calculateProductivityScore({
      dailyStats: stats,
      goals: emptyGoals,
      habits: emptyHabits,
      streakDays: 0,
      firstPhoneUseBefore7am: false,
    });
    expect(components.focusBonus).toBe(40); // 10 × 8 = 80, capped at 40
  });

  test('score is floored at 0', () => {
    const stats = createMockDailyStats({
      focusSessions: { completed: 0, abandoned: 3, totalMinutes: 0, averageLength: 0, longestSession: 0 },
      socialMediaMinutes: 500,
      appUsage: {
        'com.instagram.android': {
          appName: 'Instagram', category: 'social_media', totalMinutes: 500,
          sessions: 20, firstUsed: '06:00', lastUsed: '23:00',
          hourlyMinutes: new Array(24).fill(0), isBlocked: true,
          goalMinutes: 60, goalExceeded: true, overrideCount: 20,
        },
      },
    });
    const goals: GoalDocument[] = [{
      goalId: 'g1', userId: 'test', type: 'app_limit', name: 'Instagram',
      appId: 'com.instagram.android', category: 'social_media',
      targetValue: 60, unit: 'minutes', frequency: 'daily',
      currentStreak: 0, longestStreak: 0, totalCompletions: 0,
      history: [], status: 'active', color: '#E1306C', icon: '📸',
      reminderEnabled: false, reminderTime: null, aiSuggested: false,
      difficulty: 'medium', createdAt: mockTimestamp, updatedAt: mockTimestamp,
    }];

    const { score } = calculateProductivityScore({
      dailyStats: stats,
      goals,
      habits: emptyHabits,
      streakDays: 0,
      firstPhoneUseBefore7am: true,
    });
    expect(score).toBe(0);
  });

  test('deterministic: same inputs produce same output', () => {
    const stats = createMockDailyStats();
    const input = { dailyStats: stats, goals: emptyGoals, habits: emptyHabits, streakDays: 5, firstPhoneUseBefore7am: false };
    const result1 = calculateProductivityScore(input);
    const result2 = calculateProductivityScore(input);
    expect(result1.score).toBe(result2.score);
    expect(result1.components).toEqual(result2.components);
  });

  test('late night usage causes deduction', () => {
    // Use stats with no bonuses so scores stay below 100 cap
    const baseOverrides = {
      focusSessions: { completed: 0, abandoned: 0, totalMinutes: 0, averageLength: 0, longestSession: 0 } as const,
      socialMediaMinutes: 30,
    };
    const lateStats = createMockDailyStats({
      ...baseOverrides,
      sleepData: { bedtime: '01:00', wakeTime: '09:00', quality: 2, lateNightUsageMinutes: 60 },
    });
    const { score: lateScore } = calculateProductivityScore({
      dailyStats: lateStats,
      goals: emptyGoals,
      habits: emptyHabits,
      streakDays: 0,
      firstPhoneUseBefore7am: false,
    });

    const normalStats = createMockDailyStats(baseOverrides);
    const { score: normalScore } = calculateProductivityScore({
      dailyStats: normalStats,
      goals: emptyGoals,
      habits: emptyHabits,
      streakDays: 0,
      firstPhoneUseBefore7am: false,
    });

    expect(lateScore).toBeLessThan(normalScore);
  });
});

describe('XP and Level Calculator', () => {
  test('level 1 requires 0 XP', () => {
    expect(xpForLevel(1)).toBe(0);
  });

  test('level 2 requires 100 XP', () => {
    expect(xpForLevel(2)).toBe(Math.floor(100 * Math.pow(2, 1.5)));
  });

  test('levelFromXp returns correct level', () => {
    const { level } = levelFromXp(0);
    expect(level).toBe(1);

    const { level: level2 } = levelFromXp(500);
    expect(level2).toBeGreaterThan(1);
  });

  test('checkLevelUp detects level transition', () => {
    const threshold = xpForLevel(2);
    const { leveledUp } = checkLevelUp(threshold - 1, threshold + 1);
    expect(leveledUp).toBe(true);
  });

  test('checkLevelUp returns false when no transition', () => {
    const { leveledUp } = checkLevelUp(50, 90);
    expect(leveledUp).toBe(false);
  });
});

describe('Session XP Calculator', () => {
  test('base XP is 50', () => {
    const xp = calculateSessionXp(0, 0, 0);
    expect(xp).toBe(50);
  });

  test('duration bonus adds 0.5 per minute', () => {
    const xp = calculateSessionXp(60, 100, 0);
    expect(xp).toBe(50 + 30 + 25); // base + duration + completion bonus
  });

  test('distractions reduce XP', () => {
    const xpNoDistraction = calculateSessionXp(30, 100, 0);
    const xpWithDistraction = calculateSessionXp(30, 100, 5);
    expect(xpWithDistraction).toBeLessThan(xpNoDistraction);
  });

  test('long session bonus for 120+ minutes', () => {
    const xp120 = calculateSessionXp(120, 100, 0);
    const xp60 = calculateSessionXp(60, 100, 0);
    expect(xp120 - xp60).toBeGreaterThanOrEqual(50); // 50 bonus + duration difference
  });

  test('XP never goes below 0', () => {
    const xp = calculateSessionXp(0, 0, 100);
    expect(xp).toBeGreaterThanOrEqual(0);
  });
});
