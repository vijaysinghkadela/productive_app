const functions = require("firebase-functions/v2");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const { OpenAI } = require("openai");

admin.initializeApp();

/**
 * getAICoaching — Proxy OpenAI API calls through Firebase Functions.
 * Validates authentication, enforces rate limits, and returns AI response.
 */
exports.getAICoaching = onCall({
  maxInstances: 10,
  timeoutSeconds: 60,
  cors: true,
}, async (request) => {
  // Verify authentication
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Must be signed in to use AI coaching.");
  }

  const uid = request.auth.uid;
  const { message, context: userContext } = request.data;

  if (!message || typeof message !== "string") {
    throw new HttpsError("invalid-argument", "Message is required.");
  }

  // Check subscription tier
  const userDoc = await admin.firestore().collection("users").doc(uid).get();
  const tier = userDoc.exists ? userDoc.data().subscriptionTier || "free" : "free";

  // Rate limiting
  const today = new Date().toISOString().split("T")[0];
  const usageRef = admin.firestore()
    .collection("users").doc(uid)
    .collection("ai_usage").doc(today);

  const usageDoc = await usageRef.get();
  const usageCount = usageDoc.exists ? usageDoc.data().count || 0 : 0;

  const limits = { free: 0, basic: 3, pro: 10, elite: 999 };
  const maxRequests = limits[tier] || 0;

  if (usageCount >= maxRequests) {
    throw new HttpsError(
      "resource-exhausted",
      `AI coaching limit reached (${maxRequests}/day for ${tier} tier). Upgrade for more.`
    );
  }

  // Build system prompt with user context
  const systemPrompt = `You are Alex, a friendly and motivating productivity coach in the FocusGuard app.
User context: ${JSON.stringify(userContext || {})}
Rules:
- Be concise (max 3 sentences)  
- Be warm, encouraging, never judgmental
- Give specific, actionable advice
- Reference their data when possible
- Use emojis sparingly for warmth`;

  try {
    const openai = new OpenAI({
      apiKey: process.env.OPENAI_API_KEY,
    });

    const response = await openai.chat.completions.create({
      model: "gpt-4o",
      messages: [
        { role: "system", content: systemPrompt },
        { role: "user", content: message },
      ],
      max_tokens: 500,
      temperature: 0.7,
    });

    const reply = response.choices[0]?.message?.content || "I'm here to help! Try asking about your productivity patterns.";

    // Update usage count
    await usageRef.set({
      count: usageCount + 1,
      lastUsed: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });

    // Log to analytics
    await admin.firestore().collection("users").doc(uid)
      .collection("ai_conversations").add({
        userMessage: message,
        aiResponse: reply,
        tier: tier,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      });

    return { reply, remaining: maxRequests - usageCount - 1 };
  } catch (error) {
    console.error("OpenAI API error:", error);
    throw new HttpsError("internal", "AI coaching is temporarily unavailable. Please try again later.");
  }
});

/**
 * generateReport — Generate weekly/monthly productivity reports.
 */
exports.generateReport = onCall({
  maxInstances: 5,
  timeoutSeconds: 120,
}, async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Must be signed in.");
  }

  const uid = request.auth.uid;
  const { type } = request.data; // "weekly" or "monthly"

  const daysBack = type === "monthly" ? 30 : 7;
  const startDate = new Date();
  startDate.setDate(startDate.getDate() - daysBack);

  // Fetch usage stats
  const statsSnapshot = await admin.firestore()
    .collection("users").doc(uid)
    .collection("daily_stats")
    .where("date", ">=", startDate.toISOString().split("T")[0])
    .orderBy("date")
    .get();

  const stats = statsSnapshot.docs.map(doc => doc.data());

  // Calculate summary
  const totalFocusMinutes = stats.reduce((sum, s) => sum + (s.focusSessionsCompleted || 0) * 25, 0);
  const totalSocialMediaMinutes = stats.reduce((sum, s) => sum + (s.socialMediaMinutes || 0), 0);
  const avgScore = stats.length > 0
    ? Math.round(stats.reduce((sum, s) => sum + (s.productivityScore || 0), 0) / stats.length)
    : 0;

  const report = {
    userId: uid,
    type: type,
    periodStart: startDate.toISOString(),
    periodEnd: new Date().toISOString(),
    generatedAt: new Date().toISOString(),
    averageScore: avgScore,
    totalFocusMinutes: totalFocusMinutes,
    totalSocialMediaMinutes: totalSocialMediaMinutes,
    stats: stats,
  };

  // Save report
  const reportRef = await admin.firestore()
    .collection("users").doc(uid)
    .collection("reports").add(report);

  return { reportId: reportRef.id, ...report };
});

/**
 * onUserCreate — Initialize new user data on account creation.
 */
exports.onUserCreate = functions.auth.user().onCreate(async (user) => {
  const userData = {
    uid: user.uid,
    email: user.email,
    displayName: user.displayName || user.email.split("@")[0],
    photoUrl: user.photoURL || null,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    lastLoginAt: admin.firestore.FieldValue.serverTimestamp(),
    streakDays: 0,
    totalFocusMinutes: 0,
    level: 1,
    totalXp: 0,
    subscriptionTier: "free",
    settings: { theme: "dark", locale: "en" },
  };

  await admin.firestore().collection("users").doc(user.uid).set(userData);
  console.log(`New user initialized: ${user.uid}`);
});
