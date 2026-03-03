import { Timestamp } from 'firebase-admin/firestore';

// ─── User Document ───
export interface UserDocument {
  uid: string;
  email: string;
  emailVerified: boolean;
  displayName: string;
  username: string;
  avatarUrl: string | null;
  avatarType: 'photo' | 'illustration';
  avatarId: string | null;
  bio: string | null;
  dateOfBirth: Timestamp | null;
  country: string;
  timezone: string;
  language: string;
  subscription: UserSubscription;
  stats: UserStats;
  settings: UserSettings;
  onboarding: UserOnboarding;
  termsAccepted: TermsAccepted;
  fcmTokens: string[];
  devices: UserDevice[];
  referralCode: string;
  referredBy: string | null;
  accountStatus: 'active' | 'suspended' | 'deleted';
  deletionScheduledAt: Timestamp | null;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

export interface UserSubscription {
  tier: SubscriptionTier;
  status: 'active' | 'trial' | 'grace_period' | 'expired' | 'cancelled';
  trialEndsAt: Timestamp | null;
  currentPeriodStart: Timestamp | null;
  currentPeriodEnd: Timestamp | null;
  cancelAtPeriodEnd: boolean;
  revenuecatCustomerId: string | null;
  entitlements: string[];
}

export type SubscriptionTier = 'free' | 'basic' | 'pro' | 'elite' | 'lifetime';

export interface UserStats {
  totalFocusMinutes: number;
  totalSessionsCompleted: number;
  totalAppsBlocked: number;
  totalGoalsMet: number;
  totalHabitsCompleted: number;
  totalAchievementsUnlocked: number;
  totalXp: number;
  level: number;
  currentStreak: number;
  longestStreak: number;
  lastActiveDate: string;
  accountabilityPartnersCount: number;
  referralCount: number;
}

export interface UserSettings {
  notifications: NotificationSettings;
  privacy: PrivacySettings;
  app: AppSettings;
  blocking: BlockingSettings;
  focus: FocusSettings;
}

export interface NotificationSettings {
  enabled: boolean;
  blockingAlerts: boolean;
  goalWarnings: boolean;
  streakReminders: boolean;
  achievementAlerts: boolean;
  weeklyReport: boolean;
  aiInsights: boolean;
  partnerActivity: boolean;
  challengeUpdates: boolean;
  quietHoursStart: string;
  quietHoursEnd: string;
  smartScheduling: boolean;
}

export interface PrivacySettings {
  showOnLeaderboard: boolean;
  showProfileToPartners: boolean;
  analyticsOptOut: boolean;
  shareUsageData: boolean;
}

export interface AppSettings {
  theme: 'dark' | 'light' | 'system';
  accentColor: string;
  fontSize: 'small' | 'medium' | 'large';
  hapticEnabled: boolean;
  reduceMotion: boolean;
}

export interface BlockingSettings {
  overlayTheme: 'motivational' | 'scary' | 'friendly';
  gracePeriodMinutes: number;
  cooldownAfterOverrides: number;
  strictModeEnabled: boolean;
  strictModePinHash: string | null;
  biometricEnabled: boolean;
}

export interface FocusSettings {
  defaultSessionType: string;
  defaultDuration: number;
  autoStartBreak: boolean;
  endOfSessionSound: string;
}

export interface UserOnboarding {
  completed: boolean;
  completedAt: Timestamp | null;
  stepsCompleted: string[];
  permissionsGranted: string[];
}

export interface TermsAccepted {
  version: string;
  acceptedAt: Timestamp;
  ipAddress: string;
}

export interface UserDevice {
  deviceId: string;
  platform: 'android' | 'ios';
  osVersion: string;
  appVersion: string;
  lastSeen: Timestamp;
}

// ─── Session Document ───
export interface SessionDocument {
  sessionId: string;
  userId: string;
  type: SessionType;
  mode: SessionMode;
  plannedDurationMinutes: number;
  actualDurationMinutes: number;
  phases: SessionPhase[];
  status: 'active' | 'completed' | 'abandoned' | 'paused';
  distractionCount: number;
  distractionEvents: DistractionEvent[];
  focusNote: string | null;
  ambientSound: string | null;
  xpEarned: number;
  scoreImpact: number;
  appsBlockedDuring: string[];
  pauseEvents: PauseEvent[];
  completionRate: number;
  focusModeId: string | null;
  deviceId: string;
  startedAt: Timestamp;
  endedAt: Timestamp | null;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

export type SessionType =
  | 'deep_work' | 'study' | 'creative' | 'reading'
  | 'exercise' | 'meditation' | 'coding' | 'writing' | 'custom';

export type SessionMode = 'pomodoro' | 'deep_work' | 'ultra_focus' | 'flowtime' | 'custom';

export interface SessionPhase {
  phaseNumber: number;
  type: 'work' | 'break';
  plannedMinutes: number;
  actualMinutes: number;
  startedAt: Timestamp;
  endedAt: Timestamp | null;
  completed: boolean;
}

export interface DistractionEvent {
  timestamp: Timestamp;
  note: string | null;
}

export interface PauseEvent {
  pausedAt: Timestamp;
  resumedAt: Timestamp | null;
  reason: string | null;
}

// ─── Daily Stats Document ───
export interface DailyStatsDocument {
  date: string;
  userId: string;
  appUsage: Record<string, AppUsageEntry>;
  totalScreenTimeMinutes: number;
  socialMediaMinutes: number;
  productiveMinutes: number;
  entertainmentMinutes: number;
  otherMinutes: number;
  hourlyScreenTime: number[];
  phonePickups: number;
  hourlyPickups: number[];
  firstPhoneUse: string | null;
  lastPhoneUse: string | null;
  focusSessions: FocusSessionStats;
  goals: Record<string, GoalProgress>;
  habits: Record<string, HabitProgress>;
  mood: 1 | 2 | 3 | 4 | 5 | null;
  journalCompleted: boolean;
  gratitudeCompleted: boolean;
  productivityScore: ProductivityScore;
  xpEarned: number;
  achievementsUnlocked: string[];
  sleepData: SleepData;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

export interface AppUsageEntry {
  appName: string;
  category: string;
  totalMinutes: number;
  sessions: number;
  firstUsed: string;
  lastUsed: string;
  hourlyMinutes: number[];
  isBlocked: boolean;
  goalMinutes: number | null;
  goalExceeded: boolean;
  overrideCount: number;
}

export interface FocusSessionStats {
  completed: number;
  abandoned: number;
  totalMinutes: number;
  averageLength: number;
  longestSession: number;
}

export interface GoalProgress {
  targetMinutes: number;
  actualMinutes: number;
  met: boolean;
  type: string;
}

export interface HabitProgress {
  completed: boolean;
  completedAt: Timestamp | null;
  skipped: boolean;
}

export interface ProductivityScore {
  final: number;
  components: ScoreComponents;
  hourlySnapshots: { hour: number; score: number }[];
  calculatedAt: Timestamp;
}

export interface ScoreComponents {
  baseScore: number;
  socialMediaDeduction: number;
  screenTimeDeduction: number;
  overrideDeduction: number;
  abandonedSessionDeduction: number;
  habitDeduction: number;
  focusBonus: number;
  goalBonus: number;
  habitBonus: number;
  streakBonus: number;
  journalBonus: number;
  morningRoutineBonus: number;
  socialMediaFreeBonus: number;
}

export interface SleepData {
  bedtime: string | null;
  wakeTime: string | null;
  quality: 1 | 2 | 3 | 4 | 5 | null;
  lateNightUsageMinutes: number;
}

// ─── Goal Document ───
export interface GoalDocument {
  goalId: string;
  userId: string;
  type: GoalType;
  name: string;
  appId: string | null;
  category: string | null;
  targetValue: number;
  unit: 'minutes' | 'hours' | 'days' | 'score' | 'sessions';
  frequency: 'daily' | 'weekly' | 'monthly';
  currentStreak: number;
  longestStreak: number;
  totalCompletions: number;
  history: GoalHistoryEntry[];
  status: 'active' | 'paused' | 'archived';
  color: string;
  icon: string;
  reminderEnabled: boolean;
  reminderTime: string | null;
  aiSuggested: boolean;
  difficulty: 'easy' | 'medium' | 'hard' | 'custom';
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

export type GoalType =
  | 'app_limit' | 'focus_target' | 'social_free_days'
  | 'weekly_focus_hours' | 'monthly_score' | 'custom';

export interface GoalHistoryEntry {
  date: string;
  targetValue: number;
  actualValue: number;
  met: boolean;
  xpEarned: number;
}

// ─── Habit Document ───
export interface HabitDocument {
  habitId: string;
  userId: string;
  name: string;
  description: string | null;
  icon: string;
  color: string;
  category: HabitCategory;
  frequency: HabitFrequency;
  reminderTime: string | null;
  reminderDays: number[];
  currentStreak: number;
  longestStreak: number;
  totalCompletions: number;
  totalSkips: number;
  lastCompletedDate: string | null;
  completionHistory: HabitCompletionEntry[];
  stackedWith: string | null;
  isTemplate: boolean;
  templateId: string | null;
  status: 'active' | 'paused' | 'archived';
  order: number;
  xpPerCompletion: number;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

export type HabitCategory =
  | 'digital_wellness' | 'productivity' | 'health'
  | 'mindfulness' | 'sleep' | 'social' | 'custom';

export interface HabitFrequency {
  type: 'daily' | 'weekdays' | 'weekends' | 'specific_days' | 'x_per_week';
  specificDays: number[] | null;
  timesPerWeek: number | null;
}

export interface HabitCompletionEntry {
  date: string;
  completed: boolean;
  skipped: boolean;
  completedAt: Timestamp | null;
  note: string | null;
}

// ─── Achievement Documents ───
export interface UserAchievementDocument {
  achievementId: string;
  userId: string;
  unlockedAt: Timestamp;
  xpEarned: number;
  progress: number;
  notified: boolean;
}

export interface AchievementDefinitionDocument {
  achievementId: string;
  name: string;
  description: string;
  category: AchievementCategory;
  rarity: AchievementRarity;
  icon: string;
  xpReward: number;
  condition: AchievementCondition;
  unlockMessage: string;
  order: number;
  isActive: boolean;
}

export type AchievementCategory = 'focus' | 'social' | 'streak' | 'habit' | 'social_feature' | 'special';
export type AchievementRarity = 'common' | 'rare' | 'epic' | 'legendary';

export interface AchievementCondition {
  metric: string;
  operator: 'gte' | 'lte' | 'eq' | 'streak' | 'special';
  value: number;
  timeWindow: 'all_time' | 'daily' | 'weekly' | 'monthly' | null;
}

// ─── Journal Document ───
export interface JournalDocument {
  date: string;
  userId: string;
  mood: 1 | 2 | 3 | 4 | 5 | null;
  moodLabel: string | null;
  entry: string | null;
  entryWordCount: number;
  gratitude: string[];
  reflectionAnswers: { question: string; answer: string }[];
  lessonsLearned: string[];
  aiSummary: string | null;
  encrypted: boolean;
  encryptionKeyId: string | null;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

// ─── Notification Document ───
export interface NotificationDocument {
  notificationId: string;
  userId: string;
  type: NotificationType;
  title: string;
  body: string;
  data: Record<string, string>;
  read: boolean;
  readAt: Timestamp | null;
  actionTaken: string | null;
  fcmMessageId: string | null;
  deliveredAt: Timestamp | null;
  createdAt: Timestamp;
}

export type NotificationType =
  | 'blocking_alert' | 'goal_warning' | 'goal_achieved' | 'streak_alert'
  | 'achievement' | 'partner_activity' | 'challenge_update' | 'weekly_report'
  | 'ai_insight' | 'bedtime' | 'system' | 'referral';

// ─── Blocking Schedule Document ───
export interface BlockingScheduleDocument {
  scheduleId: string;
  userId: string;
  name: string;
  appIds: string[];
  categories: string[];
  schedule: ScheduleEntry[];
  dailyLimitMinutes: number | null;
  gracePeriodMinutes: number;
  strictMode: boolean;
  status: 'active' | 'paused';
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

export interface ScheduleEntry {
  dayOfWeek: number;
  startTime: string;
  endTime: string;
  enabled: boolean;
}

// ─── Focus Mode Document ───
export interface FocusModeDocument {
  modeId: string;
  userId: string;
  name: string;
  icon: string;
  color: string;
  blockedApps: string[];
  blockedCategories: string[];
  allowedApps: string[];
  notificationFilter: 'none' | 'calls_only' | 'all';
  ambientSoundProfile: string | null;
  durationMinutes: number | null;
  autoActivate: AutoActivateRules;
  status: 'active' | 'inactive' | 'scheduled';
  isPreset: boolean;
  usageCount: number;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

export interface AutoActivateRules {
  timeRules: { dayOfWeek: number; startTime: string; endTime: string }[];
  locationRules: { latitude: number; longitude: number; radiusMeters: number; label: string }[];
  calendarKeywords: string[];
  bluetoothDevices: string[];
}

// ─── AI Conversation Document ───
export interface AIConversationDocument {
  conversationId: string;
  userId: string;
  messages: AIMessage[];
  contextSnapshot: AIContextSnapshot;
  totalTokensUsed: number;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

export interface AIMessage {
  messageId: string;
  role: 'user' | 'assistant' | 'system';
  content: string;
  tokensUsed: number | null;
  createdAt: Timestamp;
}

export interface AIContextSnapshot {
  weeklyScoreAverage: number;
  topDistractingApps: string[];
  currentStreak: number;
  weakestArea: string;
  strongestArea: string;
  capturedAt: Timestamp;
}

// ─── Accountability Pair Document ───
export interface AccountabilityPairDocument {
  pairId: string;
  userIds: [string, string];
  initiatorId: string;
  status: 'pending' | 'active' | 'paused' | 'ended';
  sharedSettings: {
    showScore: boolean;
    showStreak: boolean;
    showFocusTime: boolean;
    showAppsBlocked: boolean;
    allowNudges: boolean;
    allowCheer: boolean;
    strictModeAlerts: boolean;
  };
  stats: {
    daysPartner: number;
    cheersExchanged: number;
    nudgesSent: number;
    jointGoals: number;
    messagesExchanged: number;
  };
  messages: AccountabilityMessage[];
  inviteCode: string;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

export interface AccountabilityMessage {
  messageId: string;
  senderId: string;
  text: string;
  type: 'text' | 'cheer' | 'nudge' | 'achievement_share';
  createdAt: Timestamp;
}

// ─── Accountability Group Document ───
export interface AccountabilityGroupDocument {
  groupId: string;
  name: string;
  description: string;
  memberIds: string[];
  adminId: string;
  inviteCode: string;
  status: 'active' | 'archived';
  sharedSettings: {
    showScore: boolean;
    showStreak: boolean;
    showFocusTime: boolean;
  };
  stats: {
    totalFocusMinutes: number;
    totalSessionsCompleted: number;
  };
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

// ─── Challenge Document ───
export interface ChallengeDocument {
  challengeId: string;
  title: string;
  description: string;
  type: ChallengeType;
  category: 'focus' | 'social' | 'habits' | 'sleep' | 'custom';
  rules: ChallengeRule[];
  durationDays: number;
  startDate: Timestamp;
  endDate: Timestamp;
  difficulty: 'easy' | 'medium' | 'hard' | 'extreme';
  xpReward: number;
  badgeId: string;
  participantCount: number;
  completionCount: number;
  status: 'upcoming' | 'active' | 'completed' | 'archived';
  isOfficial: boolean;
  createdBy: string;
  featured: boolean;
  imageUrl: string | null;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

export type ChallengeType =
  | 'social_media_detox' | 'focus_marathon' | 'morning_person'
  | 'screen_time_slash' | 'deep_work' | 'custom';

export interface ChallengeRule {
  ruleId: string;
  description: string;
  metricType: string;
  targetValue: number;
  unit: string;
  comparison: 'gte' | 'lte' | 'eq';
  daily: boolean;
}

// ─── Challenge Participant Document ───
export interface ChallengeParticipantDocument {
  challengeId: string;
  userId: string;
  status: 'active' | 'completed' | 'failed' | 'withdrew';
  progress: Record<string, {
    currentValue: number;
    targetValue: number;
    percentage: number;
    dailyHistory: { date: string; value: number; met: boolean }[];
  }>;
  rank: number;
  score: number;
  completionPercentage: number;
  joinedAt: Timestamp;
  completedAt: Timestamp | null;
  xpEarned: number;
  updatedAt: Timestamp;
}

// ─── Leaderboard Entry Document ───
export interface LeaderboardEntryDocument {
  userId: string;
  username: string;
  displayName: string;
  avatarUrl: string | null;
  level: number;
  country: string;
  score: number;
  rank: number;
  previousRank: number;
  rankChange: number;
  streakDays: number;
  focusMinutes: number;
  xp: number;
  badgeIds: string[];
  updatedAt: Timestamp;
}

export type LeaderboardPeriod = 'daily' | 'weekly' | 'monthly' | 'alltime';

// ─── Report Document ───
export interface ReportDocument {
  reportId: string;
  userId: string;
  type: 'weekly' | 'monthly';
  periodStart: Timestamp;
  periodEnd: Timestamp;
  status: 'generating' | 'ready' | 'failed';
  data: ReportData;
  pdfUrl: string | null;
  emailSent: boolean;
  viewedAt: Timestamp | null;
  generatedAt: Timestamp;
  createdAt: Timestamp;
}

export interface ReportData {
  productivityScores: { date: string; score: number }[];
  averageScore: number;
  bestScore: number;
  worstScore: number;
  totalFocusMinutes: number;
  totalSessionsCompleted: number;
  sessionCompletionRate: number;
  topDistractingApps: { appId: string; appName: string; minutes: number }[];
  socialMediaMinutes: number;
  socialMediaReduction: number;
  goalsMetCount: number;
  goalsTotalCount: number;
  habitCompletionRate: number;
  achievementsUnlocked: string[];
  xpEarned: number;
  levelUps: number;
  streakHighlight: number;
  aiInsightSummary: string | null;
  topRecommendations: string[];
  comparisonToPrevious: {
    scoreChange: number;
    focusChange: number;
    socialMediaChange: number;
    goalsChange: number;
  };
}

// ─── Referral Document ───
export interface ReferralDocument {
  referralCode: string;
  ownerId: string;
  uses: number;
  maxUses: number | null;
  referredUsers: {
    userId: string;
    joinedAt: Timestamp;
    rewardGranted: boolean;
    rewardGrantedAt: Timestamp | null;
  }[];
  rewardType: 'free_month_basic' | 'free_month_pro' | 'free_month_elite';
  status: 'active' | 'expired';
  createdAt: Timestamp;
}
