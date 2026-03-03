import {
  ScoreComponents,
  DailyStatsDocument,
  GoalDocument,
  HabitDocument,
} from '../types/firestore.types';

export interface ScoreInput {
  dailyStats: DailyStatsDocument;
  goals: GoalDocument[];
  habits: HabitDocument[];
  streakDays: number;
  firstPhoneUseBefore7am: boolean;
}

export function calculateProductivityScore(input: ScoreInput): {
  score: number;
  components: ScoreComponents;
} {
  const { dailyStats, goals, habits, streakDays, firstPhoneUseBefore7am } = input;

  // --- DEDUCTIONS ---
  // Social media over goal: -0.8 per minute, max -35
  let socialMediaDeduction = 0;
  const socialGoals = goals.filter((g) => g.type === 'app_limit' && g.status === 'active');
  for (const goal of socialGoals) {
    const usage = dailyStats.appUsage[goal.appId || ''];
    if (usage && goal.targetValue > 0) {
      const overMinutes = Math.max(0, usage.totalMinutes - goal.targetValue);
      socialMediaDeduction += overMinutes * 0.8;
    }
  }
  socialMediaDeduction = Math.min(socialMediaDeduction, 35);

  // Total screen time over goal: -0.3 per minute, max -20
  const screenTimeGoal = goals.find((g) => g.type === 'focus_target' && g.unit === 'minutes');
  let screenTimeDeduction = 0;
  if (screenTimeGoal) {
    const over = Math.max(0, dailyStats.totalScreenTimeMinutes - screenTimeGoal.targetValue);
    screenTimeDeduction = Math.min(over * 0.3, 20);
  }

  // Override taps: -3 per tap
  let overrideDeduction = 0;
  for (const appKey of Object.keys(dailyStats.appUsage)) {
    overrideDeduction += dailyStats.appUsage[appKey].overrideCount * 3;
  }

  // Abandoned sessions: -5 per session, max -15
  const abandonedSessionDeduction = Math.min(dailyStats.focusSessions.abandoned * 5, 15);

  // Habits not completed: -3 per habit, max -15
  const activeHabits = habits.filter((h) => h.status === 'active');
  let habitsMissed = 0;
  for (const habit of activeHabits) {
    const progress = dailyStats.habits[habit.habitId];
    if (!progress || (!progress.completed && !progress.skipped)) {
      habitsMissed++;
    }
  }
  const habitDeduction = Math.min(habitsMissed * 3, 15);

  // No focus session by 11am weekdays: -5
  const today = new Date(dailyStats.date);
  const isWeekday = today.getDay() >= 1 && today.getDay() <= 5;
  let noSessionPenalty = 0;
  if (isWeekday && dailyStats.focusSessions.completed === 0) {
    noSessionPenalty = 5;
  }

  // First phone use before 7am: -5
  const earlyPhonePenalty = firstPhoneUseBefore7am ? 5 : 0;

  // Social media after 10pm > 15min: -5
  let lateNightPenalty = 0;
  if (dailyStats.sleepData.lateNightUsageMinutes > 15) {
    lateNightPenalty = 5;
  }

  const totalDeductions =
    socialMediaDeduction +
    screenTimeDeduction +
    overrideDeduction +
    abandonedSessionDeduction +
    habitDeduction +
    noSessionPenalty +
    earlyPhonePenalty +
    lateNightPenalty;

  // --- ADDITIONS ---
  // Completed focus sessions: +8 each, max +40
  const focusBonus = Math.min(dailyStats.focusSessions.completed * 8, 40);

  // Beat social media goal for all apps: +5 per app, max +15
  let goalBonus = 0;
  let allGoalsMet = true;
  const activeGoals = goals.filter((g) => g.status === 'active');
  for (const goal of activeGoals) {
    const progress = dailyStats.goals[goal.goalId];
    if (progress && progress.met) {
      goalBonus += 5;
    } else {
      allGoalsMet = false;
    }
  }
  goalBonus = Math.min(goalBonus, 15);
  if (allGoalsMet && activeGoals.length > 0) goalBonus += 10;

  // All active habits completed: +10
  let allHabitsCompleted = activeHabits.length > 0;
  for (const habit of activeHabits) {
    const progress = dailyStats.habits[habit.habitId];
    if (!progress || !progress.completed) {
      allHabitsCompleted = false;
      break;
    }
  }
  const habitBonus = allHabitsCompleted ? 10 : 0;

  // Social media free day: +20
  const socialMediaFreeBonus = dailyStats.socialMediaMinutes === 0 ? 20 : 0;

  // Streak: +1 per day, max +15
  const streakBonus = Math.min(streakDays, 15);

  // Journal: +3
  const journalBonus = dailyStats.journalCompleted ? 3 : 0;

  // Gratitude: +2
  const gratitudeBonus = dailyStats.gratitudeCompleted ? 2 : 0;

  // Morning routine (no phone first hour): +5
  const morningRoutineBonus =
    dailyStats.firstPhoneUse && dailyStats.firstPhoneUse >= '08:00' ? 5 : 0;

  const totalAdditions =
    focusBonus +
    goalBonus +
    habitBonus +
    socialMediaFreeBonus +
    streakBonus +
    journalBonus +
    gratitudeBonus +
    morningRoutineBonus;

  // --- FINAL SCORE ---
  const rawScore = 100 - totalDeductions + totalAdditions;
  const score = Math.max(0, Math.min(100, Math.round(rawScore)));

  const components: ScoreComponents = {
    baseScore: 100,
    socialMediaDeduction: -socialMediaDeduction,
    screenTimeDeduction: -screenTimeDeduction,
    overrideDeduction: -overrideDeduction,
    abandonedSessionDeduction: -abandonedSessionDeduction,
    habitDeduction: -habitDeduction,
    focusBonus,
    goalBonus,
    habitBonus,
    streakBonus,
    journalBonus: journalBonus + gratitudeBonus,
    morningRoutineBonus,
    socialMediaFreeBonus,
  };

  return { score, components };
}

// XP needed for a given level
export function xpForLevel(level: number): number {
  if (level <= 1) return 0;
  return Math.floor(100 * Math.pow(level, 1.5));
}

// Calculate level from total XP
export function levelFromXp(totalXp: number): { level: number; xpToNextLevel: number } {
  let level = 1;
  while (xpForLevel(level + 1) <= totalXp) {
    level++;
    if (level >= 100) break; // Safety cap
  }
  const nextLevelXp = xpForLevel(level + 1);
  return { level, xpToNextLevel: nextLevelXp - totalXp };
}

// Check if XP crosses a level threshold
export function checkLevelUp(
  previousXp: number,
  newXp: number,
): { leveledUp: boolean; newLevel: number; xpToNextLevel: number } {
  const prev = levelFromXp(previousXp);
  const curr = levelFromXp(newXp);
  return {
    leveledUp: curr.level > prev.level,
    newLevel: curr.level,
    xpToNextLevel: curr.xpToNextLevel,
  };
}

// Calculate session XP
export function calculateSessionXp(
  durationMinutes: number,
  completionRate: number,
  distractionCount: number,
): number {
  const base = 50;
  const durationBonus = Math.floor(durationMinutes * 0.5);
  const completionBonus = completionRate >= 100 ? 25 : completionRate >= 80 ? 10 : 0;
  const distractionPenalty = distractionCount * 5;
  const longSessionBonus = durationMinutes >= 120 ? 50 : 0;

  return Math.max(
    0,
    base + durationBonus + completionBonus - distractionPenalty + longSessionBonus,
  );
}
