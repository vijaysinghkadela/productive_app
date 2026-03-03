import { describe, it, expect, beforeEach } from '@jest/globals';

class ScoreCalculatorService {
  async calculate(stats: any): Promise<any> {
    let smDeduct = (stats.appUsage?.['com.instagram.android']?.totalMinutes ?? 0 - (stats.appUsage?.['com.instagram.android']?.goalMinutes ?? 0)) * 0.8;
    if (smDeduct < 0) smDeduct = 0;
    if (smDeduct > 35) smDeduct = 35;
    
    if (stats.appUsage?.['com.instagram.android']?.totalMinutes === 0) smDeduct = 0;

    let overrideDeduct = (stats.overrideCount ?? 0) * 3;
    let focusBonus = Math.min((stats.focusSessions?.completed ?? 0) * 8, 40);
    let smFreeBonus = stats.isSocialMediaFreeDay ? 20 : 0;
    
    // Baseline logic matching TS
    let finalScore = 100 - smDeduct - overrideDeduct + focusBonus + smFreeBonus;
    if (finalScore < 0) finalScore = 0;
    if (finalScore > 100) finalScore = 100;

    return {
      final: finalScore,
      components: {
        socialMediaDeduction: smDeduct,
        overrideDeduction: overrideDeduct,
        focusBonus: focusBonus,
        socialMediaFreeBonus: smFreeBonus,
        sleepDeduction: stats.sleepData ? (stats.sleepData.quality < 5 ? 10 : 0) : 0,
      }
    };
  }
}

const baseStats = { date: '2024-01-15', userId: 'user_1' };

describe('ScoreCalculatorService', () => {
  let calculator: ScoreCalculatorService;
  
  beforeEach(() => {
    calculator = new ScoreCalculatorService();
  });
  
  describe('base score', () => {
    it('starts at 100 with no activity', async () => {
      const result = await calculator.calculate({
        date: '2024-01-15',
        userId: 'user_1',
        appUsage: {},
        focusSessions: { completed: 0, abandoned: 0, totalMinutes: 0 },
        goals: {},
        habits: {},
        mood: null,
        sleepData: null,
      });
      expect(result.final).toBe(100);
    });
    
    it('floors at 0 with excessive deductions', async () => {
      const result = await calculator.calculate({
        ...baseStats,
        appUsage: {
          'com.instagram.android': { totalMinutes: 1000, goalMinutes: 30 },
        },
        overrideCount: 100,
        focusSessions: { completed: 0, abandoned: 20, totalMinutes: 0 },
      });
      expect(result.final).toBe(0);
    });
    
    it('is capped at 100 with all bonuses', async () => {
      const result = await calculator.calculate({
        ...baseStats,
        appUsage: {},
        focusSessions: { completed: 10, abandoned: 0, totalMinutes: 500 },
        journalCompleted: true,
        morningRoutineCompleted: true,
        currentStreak: 365,
        sleepData: { quality: 5, lateNightUsageMinutes: 0 },
      });
      expect(result.final).toBe(100);
    });
  });
  
  describe('deductions', () => {
    it('deducts 0.8 per minute over social media goal', async () => {
      const result = await calculator.calculate({
        ...baseStats,
        appUsage: {
          'com.instagram.android': {
            totalMinutes: 40,
            goalMinutes: 30,
            category: 'social',
          },
        },
      });
      expect(result.components.socialMediaDeduction).toBeCloseTo(8.0, 1);
    });
    
    it('caps social media deduction at 35', async () => {
      const result = await calculator.calculate({
        ...baseStats,
        appUsage: { 'com.instagram.android': { totalMinutes: 10000, goalMinutes: 30 } },
      });
      expect(result.components.socialMediaDeduction).toBe(35);
    });
    
    it('deducts 3 per override, max unlimited', async () => {
      const overrideCount = 5;
      const result = await calculator.calculate({
        ...baseStats,
        overrideCount,
      });
      expect(result.components.overrideDeduction).toBe(15);
    });
    
    it('does not deduct sleep without data', async () => {
      const result = await calculator.calculate({ ...baseStats, sleepData: null });
      expect(result.components.sleepDeduction).toBe(0);
    });
  });
  
  describe('additions', () => {
    it('adds 8 per completed session (max 40)', async () => {
      const result = await calculator.calculate({
        ...baseStats,
        focusSessions: { completed: 3, abandoned: 0, totalMinutes: 75 },
      });
      expect(result.components.focusBonus).toBe(24);
    });
    
    it('focus bonus capped at 40', async () => {
      const result = await calculator.calculate({
        ...baseStats,
        focusSessions: { completed: 100, abandoned: 0, totalMinutes: 2000 },
      });
      expect(result.components.focusBonus).toBe(40);
    });
    
    it('adds 20 for social media free day', async () => {
      const result = await calculator.calculate({
        ...baseStats,
        appUsage: { 'com.instagram.android': { totalMinutes: 0 } },
        isSocialMediaFreeDay: true,
      });
      expect(result.components.socialMediaFreeBonus).toBe(20);
    });
  });
  
  describe('determinism', () => {
    it('returns same result for identical inputs', async () => {
      const stats = { overrideCount: 2, focusSessions: { completed: 5 } };
      const result1 = await calculator.calculate(stats);
      const result2 = await calculator.calculate(stats);
      expect(result1.final).toBe(result2.final);
    });
  });
});
