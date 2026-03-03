import * as admin from 'firebase-admin';
import { Timestamp } from 'firebase-admin/firestore';
import { ACHIEVEMENT_DEFINITIONS } from '../src/achievements/achievements.definitions';

// Initialize Firebase Admin
if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

interface SeedUser {
  uid: string;
  email: string;
  displayName: string;
  username: string;
  tier: 'free' | 'basic' | 'pro' | 'elite';
}

const SEED_USERS: SeedUser[] = [
  { uid: 'seed-user-001', email: 'alice@test.com', displayName: 'Alice Johnson', username: 'alice', tier: 'elite' },
  { uid: 'seed-user-002', email: 'bob@test.com', displayName: 'Bob Smith', username: 'bob', tier: 'pro' },
  { uid: 'seed-user-003', email: 'charlie@test.com', displayName: 'Charlie Brown', username: 'charlie', tier: 'pro' },
  { uid: 'seed-user-004', email: 'diana@test.com', displayName: 'Diana Prince', username: 'diana', tier: 'basic' },
  { uid: 'seed-user-005', email: 'evan@test.com', displayName: 'Evan Williams', username: 'evan', tier: 'basic' },
  { uid: 'seed-user-006', email: 'fiona@test.com', displayName: 'Fiona Green', username: 'fiona', tier: 'free' },
  { uid: 'seed-user-007', email: 'george@test.com', displayName: 'George Harrison', username: 'george', tier: 'free' },
  { uid: 'seed-user-008', email: 'hana@test.com', displayName: 'Hana Tanaka', username: 'hana', tier: 'elite' },
  { uid: 'seed-user-009', email: 'ivan@test.com', displayName: 'Ivan Petrov', username: 'ivan', tier: 'pro' },
  { uid: 'seed-user-010', email: 'julia@test.com', displayName: 'Julia Roberts', username: 'julia', tier: 'free' },
];

async function seedDatabase(): Promise<void> {
  console.log('🌱 Seeding FocusGuard Pro database...\n');

  // 1. Seed achievement definitions
  console.log('📜 Seeding achievement definitions...');
  let batch = db.batch();
  let count = 0;
  for (let i = 0; i < ACHIEVEMENT_DEFINITIONS.length; i++) {
    const ach = ACHIEVEMENT_DEFINITIONS[i];
    batch.set(db.collection('achievements').doc(ach.achievementId), {
      ...ach,
      isActive: true,
      order: i,
    });
    count++;
    if (count % 400 === 0) { await batch.commit(); batch = db.batch(); }
  }
  await batch.commit();
  console.log(`  ✅ ${ACHIEVEMENT_DEFINITIONS.length} achievements seeded`);

  // 2. Seed app config
  console.log('⚙️ Seeding app config...');
  await db.collection('app_config').doc('social_apps').set({
    android: {
      'com.instagram.android': 'Instagram',
      'com.zhiliaoapp.musically': 'TikTok',
      'com.google.android.youtube': 'YouTube',
      'com.twitter.android': 'X (Twitter)',
      'com.facebook.katana': 'Facebook',
      'com.snapchat.android': 'Snapchat',
      'com.reddit.frontpage': 'Reddit',
    },
    ios: {
      'com.burbn.instagram': 'Instagram',
      'com.zhiliaoapp.musically': 'TikTok',
      'com.google.ios.youtube': 'YouTube',
    },
    updatedAt: Timestamp.now(),
  });

  await db.collection('app_config').doc('banned_email_domains').set({
    domains: ['tempmail.com', 'throwaway.email', 'guerrillamail.com', 'mailinator.com', 'yopmail.com',
      '10minutemail.com', 'trashmail.com', 'dispostable.com', 'sharklasers.com', 'guerrillamailblock.com'],
    updatedAt: Timestamp.now(),
  });
  console.log('  ✅ App config seeded');

  // 3. Seed users with daily stats
  console.log('👤 Seeding users...');
  for (const seedUser of SEED_USERS) {
    const now = Timestamp.now();
    const userDoc = {
      uid: seedUser.uid,
      email: seedUser.email,
      emailVerified: true,
      displayName: seedUser.displayName,
      username: seedUser.username,
      avatarUrl: null,
      avatarType: 'illustration',
      avatarId: null,
      bio: null,
      dateOfBirth: null,
      country: 'US',
      timezone: 'America/New_York',
      language: 'en',
      subscription: {
        tier: seedUser.tier,
        status: seedUser.tier === 'free' ? 'active' : 'active',
        trialEndsAt: null,
        currentPeriodStart: now,
        currentPeriodEnd: null,
        cancelAtPeriodEnd: false,
        revenuecatCustomerId: null,
        entitlements: seedUser.tier === 'free' ? [] : [seedUser.tier],
      },
      stats: {
        totalFocusMinutes: Math.floor(Math.random() * 5000),
        totalSessionsCompleted: Math.floor(Math.random() * 200),
        totalAppsBlocked: Math.floor(Math.random() * 500),
        totalGoalsMet: Math.floor(Math.random() * 100),
        totalHabitsCompleted: Math.floor(Math.random() * 300),
        totalAchievementsUnlocked: Math.floor(Math.random() * 20),
        totalXp: Math.floor(Math.random() * 10000),
        level: Math.floor(Math.random() * 20) + 1,
        currentStreak: Math.floor(Math.random() * 30),
        longestStreak: Math.floor(Math.random() * 60),
        lastActiveDate: new Date().toISOString().split('T')[0],
        accountabilityPartnersCount: 0,
        referralCount: 0,
      },
      settings: {
        notifications: {
          enabled: true, blockingAlerts: true, goalWarnings: true,
          streakReminders: true, achievementAlerts: true, weeklyReport: true,
          aiInsights: true, partnerActivity: true, challengeUpdates: true,
          quietHoursStart: '22:00', quietHoursEnd: '07:00', smartScheduling: false,
        },
        privacy: {
          showOnLeaderboard: true, showProfileToPartners: true,
          analyticsOptOut: false, shareUsageData: true,
        },
        app: { theme: 'dark', accentColor: '#6C5CE7', fontSize: 'medium', hapticEnabled: true, reduceMotion: false },
        blocking: {
          overlayTheme: 'motivational', gracePeriodMinutes: 5,
          cooldownAfterOverrides: 3, strictModeEnabled: false,
          strictModePinHash: null, biometricEnabled: false,
        },
        focus: { defaultSessionType: 'deep_work', defaultDuration: 25, autoStartBreak: true, endOfSessionSound: 'bell' },
      },
      onboarding: { completed: true, completedAt: now, stepsCompleted: ['welcome', 'permissions', 'goals', 'habits'], permissionsGranted: ['usage_access', 'notifications'] },
      termsAccepted: { version: '1.0', acceptedAt: now, ipAddress: '127.0.0.1' },
      fcmTokens: [],
      devices: [],
      referralCode: `REF${seedUser.username.toUpperCase().slice(0, 3)}${Math.floor(Math.random() * 1000)}`,
      referredBy: null,
      accountStatus: 'active',
      deletionScheduledAt: null,
      createdAt: now,
      updatedAt: now,
    };

    await db.collection('users').doc(seedUser.uid).set(userDoc);

    // Generate 30 days of daily stats
    for (let d = 0; d < 30; d++) {
      const date = new Date();
      date.setDate(date.getDate() - d);
      const dateStr = date.toISOString().split('T')[0];

      const score = Math.floor(Math.random() * 60) + 30; // 30-90
      const socialMinutes = Math.floor(Math.random() * 120);
      const focusMinutes = Math.floor(Math.random() * 180);

      await db.collection('users').doc(seedUser.uid)
        .collection('daily_stats').doc(dateStr).set({
          date: dateStr,
          userId: seedUser.uid,
          appUsage: {},
          totalScreenTimeMinutes: socialMinutes + focusMinutes + Math.floor(Math.random() * 60),
          socialMediaMinutes: socialMinutes,
          productiveMinutes: focusMinutes,
          entertainmentMinutes: Math.floor(Math.random() * 30),
          otherMinutes: Math.floor(Math.random() * 20),
          hourlyScreenTime: new Array(24).fill(0).map(() => Math.floor(Math.random() * 30)),
          phonePickups: Math.floor(Math.random() * 80) + 20,
          hourlyPickups: new Array(24).fill(0).map(() => Math.floor(Math.random() * 10)),
          firstPhoneUse: `0${Math.floor(Math.random() * 3) + 6}:${String(Math.floor(Math.random() * 60)).padStart(2, '0')}`,
          lastPhoneUse: `${Math.floor(Math.random() * 3) + 21}:${String(Math.floor(Math.random() * 60)).padStart(2, '0')}`,
          focusSessions: {
            completed: Math.floor(Math.random() * 5),
            abandoned: Math.floor(Math.random() * 2),
            totalMinutes: focusMinutes,
            averageLength: focusMinutes > 0 ? Math.floor(focusMinutes / Math.max(1, Math.floor(Math.random() * 5))) : 0,
            longestSession: Math.floor(Math.random() * 60) + 15,
          },
          goals: {},
          habits: {},
          mood: (Math.floor(Math.random() * 5) + 1) as 1 | 2 | 3 | 4 | 5,
          journalCompleted: Math.random() > 0.5,
          gratitudeCompleted: Math.random() > 0.6,
          productivityScore: {
            final: score,
            components: {
              baseScore: 100,
              socialMediaDeduction: -Math.floor(socialMinutes * 0.3),
              screenTimeDeduction: -Math.floor(Math.random() * 10),
              overrideDeduction: 0,
              abandonedSessionDeduction: 0,
              habitDeduction: 0,
              focusBonus: Math.min(40, Math.floor(Math.random() * 5) * 8),
              goalBonus: Math.random() > 0.5 ? 10 : 0,
              habitBonus: Math.random() > 0.5 ? 10 : 0,
              streakBonus: Math.min(15, Math.floor(Math.random() * 20)),
              journalBonus: Math.random() > 0.5 ? 3 : 0,
              morningRoutineBonus: Math.random() > 0.7 ? 5 : 0,
              socialMediaFreeBonus: socialMinutes === 0 ? 20 : 0,
            },
            hourlySnapshots: [],
            calculatedAt: Timestamp.now(),
          },
          xpEarned: Math.floor(Math.random() * 200) + 50,
          achievementsUnlocked: [],
          sleepData: {
            bedtime: `${Math.floor(Math.random() * 2) + 22}:${String(Math.floor(Math.random() * 60)).padStart(2, '0')}`,
            wakeTime: `0${Math.floor(Math.random() * 2) + 6}:${String(Math.floor(Math.random() * 60)).padStart(2, '0')}`,
            quality: (Math.floor(Math.random() * 5) + 1) as 1 | 2 | 3 | 4 | 5,
            lateNightUsageMinutes: Math.floor(Math.random() * 30),
          },
          createdAt: Timestamp.now(),
          updatedAt: Timestamp.now(),
        });
    }

    console.log(`  ✅ User ${seedUser.displayName} (${seedUser.tier}) + 30 days stats`);
  }

  // 4. Seed challenges
  console.log('🏆 Seeding challenges...');
  const challenges = [
    { title: '7-Day Social Media Detox', type: 'social_media_detox', category: 'social', difficulty: 'medium', durationDays: 7, xpReward: 1500 },
    { title: '30-Day Focus Marathon', type: 'focus_marathon', category: 'focus', difficulty: 'hard', durationDays: 30, xpReward: 5000 },
    { title: 'Morning Person Challenge', type: 'morning_person', category: 'habits', difficulty: 'medium', durationDays: 14, xpReward: 2000 },
    { title: 'Screen Time Slasher', type: 'screen_time_slash', category: 'social', difficulty: 'easy', durationDays: 7, xpReward: 1000 },
    { title: 'Deep Work Week', type: 'deep_work', category: 'focus', difficulty: 'hard', durationDays: 7, xpReward: 2500 },
  ];

  for (const ch of challenges) {
    const startDate = new Date();
    const endDate = new Date(startDate.getTime() + ch.durationDays * 86400000);

    await db.collection('challenges').add({
      title: ch.title,
      description: `Complete the ${ch.title} and earn ${ch.xpReward} XP!`,
      type: ch.type,
      category: ch.category,
      rules: [{ ruleId: 'r1', description: 'Meet daily target', metricType: 'productivity_score', targetValue: 70, unit: 'score', comparison: 'gte', daily: true }],
      durationDays: ch.durationDays,
      startDate: Timestamp.fromDate(startDate),
      endDate: Timestamp.fromDate(endDate),
      difficulty: ch.difficulty,
      xpReward: ch.xpReward,
      badgeId: `badge_${ch.type}`,
      participantCount: 0,
      completionCount: 0,
      status: 'active',
      isOfficial: true,
      createdBy: 'system',
      featured: true,
      imageUrl: null,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    });
  }
  console.log(`  ✅ ${challenges.length} challenges seeded`);

  console.log('\n🎉 Database seeding complete!');
}

// Run
seedDatabase()
  .then(() => process.exit(0))
  .catch((err) => { console.error('Seed failed:', err); process.exit(1); });
