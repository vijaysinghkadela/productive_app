"use strict";
// Streak calculation utilities
Object.defineProperty(exports, "__esModule", { value: true });
exports.calculateStreak = calculateStreak;
exports.calculateDailyStreak = calculateDailyStreak;
const STREAK_MILESTONES = [3, 7, 14, 30, 60, 90, 180, 365];
/**
 * Calculate streak from a completion history.
 * Skips don't break streaks (max 2 per week).
 */
function calculateStreak(history, today) {
    if (history.length === 0) {
        return { currentStreak: 0, longestStreak: 0, isAtRisk: false, milestoneReached: null };
    }
    // Sort history by date descending
    const sorted = [...history].sort((a, b) => b.date.localeCompare(a.date));
    let currentStreak = 0;
    let longestStreak = 0;
    let tempStreak = 0;
    let weekSkips = 0;
    let lastDate = null;
    // Sort ascending for longest streak calc
    const ascending = [...history].sort((a, b) => a.date.localeCompare(b.date));
    for (const entry of ascending) {
        const entryDate = new Date(entry.date);
        if (entry.completed || entry.skipped) {
            if (entry.skipped) {
                // Count skips in the current week
                weekSkips++;
                if (weekSkips > 2) {
                    // Too many skips, streak breaks
                    tempStreak = 0;
                    weekSkips = 0;
                    continue;
                }
            }
            if (lastDate) {
                const dayDiff = Math.floor((entryDate.getTime() - lastDate.getTime()) / (24 * 60 * 60 * 1000));
                if (dayDiff === 1) {
                    tempStreak++;
                }
                else if (dayDiff > 1) {
                    tempStreak = 1;
                    weekSkips = entry.skipped ? 1 : 0;
                }
            }
            else {
                tempStreak = 1;
            }
            longestStreak = Math.max(longestStreak, tempStreak);
            lastDate = entryDate;
        }
        else {
            // Not completed and not skipped — streak breaks
            tempStreak = 0;
            weekSkips = 0;
            lastDate = entryDate;
        }
    }
    // Calculate current streak from today backwards
    currentStreak = 0;
    weekSkips = 0;
    const todayDate = new Date(today);
    for (const entry of sorted) {
        const entryDate = new Date(entry.date);
        const expectedDate = new Date(todayDate);
        expectedDate.setDate(expectedDate.getDate() - currentStreak);
        const dayDiff = Math.floor((expectedDate.getTime() - entryDate.getTime()) / (24 * 60 * 60 * 1000));
        if (dayDiff > 1)
            break;
        if (entry.completed) {
            currentStreak++;
        }
        else if (entry.skipped) {
            weekSkips++;
            if (weekSkips <= 2) {
                currentStreak++; // Skip counts toward streak
            }
            else {
                break;
            }
        }
        else {
            break; // Missed day breaks streak
        }
    }
    // Check if streak is at risk (today not yet completed)
    const todayEntry = history.find((h) => h.date === today);
    const isAtRisk = currentStreak > 0 && (!todayEntry || !todayEntry.completed);
    // Check milestones
    let milestoneReached = null;
    for (const milestone of STREAK_MILESTONES) {
        if (currentStreak === milestone) {
            milestoneReached = milestone;
            break;
        }
    }
    return { currentStreak, longestStreak, isAtRisk, milestoneReached };
}
/**
 * Calculate daily active streak (consecutive days with any activity).
 */
function calculateDailyStreak(activeDates, today) {
    if (activeDates.length === 0)
        return { currentStreak: 0, longestStreak: 0 };
    const sorted = [...new Set(activeDates)].sort().reverse();
    let currentStreak = 0;
    let longestStreak = 0;
    let tempStreak = 0;
    // Check current streak from today backwards
    const todayDate = new Date(today);
    for (let i = 0; i < sorted.length; i++) {
        const expectedDate = new Date(todayDate);
        expectedDate.setDate(expectedDate.getDate() - i);
        const expected = expectedDate.toISOString().split('T')[0];
        if (sorted[i] === expected) {
            currentStreak++;
        }
        else {
            break;
        }
    }
    // Calculate longest streak
    const ascending = [...sorted].reverse();
    for (let i = 0; i < ascending.length; i++) {
        if (i === 0) {
            tempStreak = 1;
        }
        else {
            const prev = new Date(ascending[i - 1]);
            const curr = new Date(ascending[i]);
            const diff = Math.floor((curr.getTime() - prev.getTime()) / (24 * 60 * 60 * 1000));
            if (diff === 1) {
                tempStreak++;
            }
            else {
                tempStreak = 1;
            }
        }
        longestStreak = Math.max(longestStreak, tempStreak);
    }
    return { currentStreak, longestStreak };
}
//# sourceMappingURL=streak.calculator.js.map