export interface StreakResult {
    currentStreak: number;
    longestStreak: number;
    isAtRisk: boolean;
    milestoneReached: number | null;
}
/**
 * Calculate streak from a completion history.
 * Skips don't break streaks (max 2 per week).
 */
export declare function calculateStreak(history: {
    date: string;
    completed: boolean;
    skipped: boolean;
}[], today: string): StreakResult;
/**
 * Calculate daily active streak (consecutive days with any activity).
 */
export declare function calculateDailyStreak(activeDates: string[], today: string): {
    currentStreak: number;
    longestStreak: number;
};
//# sourceMappingURL=streak.calculator.d.ts.map