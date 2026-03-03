import { ScoreComponents, DailyStatsDocument, GoalDocument, HabitDocument } from '../types/firestore.types';
export interface ScoreInput {
    dailyStats: DailyStatsDocument;
    goals: GoalDocument[];
    habits: HabitDocument[];
    streakDays: number;
    firstPhoneUseBefore7am: boolean;
}
export declare function calculateProductivityScore(input: ScoreInput): {
    score: number;
    components: ScoreComponents;
};
export declare function xpForLevel(level: number): number;
export declare function levelFromXp(totalXp: number): {
    level: number;
    xpToNextLevel: number;
};
export declare function checkLevelUp(previousXp: number, newXp: number): {
    leveledUp: boolean;
    newLevel: number;
    xpToNextLevel: number;
};
export declare function calculateSessionXp(durationMinutes: number, completionRate: number, distractionCount: number): number;
//# sourceMappingURL=score.calculator.d.ts.map