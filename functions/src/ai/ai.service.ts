import * as functions from 'firebase-functions';
import { Timestamp } from 'firebase-admin/firestore';
import { getFirestore, getSecret, REGION } from '../shared/config/firebase.config';
import { Collections } from '../shared/constants/collections.constants';
import { cacheIncrement } from '../shared/config/redis.config';
import { aiChatSchema } from '../shared/validators/common.validators';
import { AIConversationDocument, AIMessage, UserDocument, DailyStatsDocument } from '../shared/types/firestore.types';
import { v4 as uuidv4 } from 'uuid';

// ─── AI Coaching Chat (Callable) ───
export const getAICoaching = functions
  .region(REGION)
  .runWith({ timeoutSeconds: 120, memory: '512MB' })
  .https.onCall(async (data, context) => {
    if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
    const uid = context.auth.uid;
    const db = getFirestore();
    const now = Timestamp.now();

    // Check subscription
    const userSnap = await db.collection(Collections.USERS).doc(uid).get();
    if (!userSnap.exists) throw new functions.https.HttpsError('not-found', 'User not found');
    const user = userSnap.data() as UserDocument;
    const tier = user.subscription.tier;

    if (!['pro', 'elite', 'lifetime'].includes(tier)) {
      throw new functions.https.HttpsError('permission-denied',
        'AI coaching requires Pro or Elite subscription');
    }

    // Rate limiting
    const monthKey = new Date().toISOString().slice(0, 7); // YYYY-MM
    const rateLimitKey = `ai_rate:${uid}:${monthKey}`;
    const maxMessages = tier === 'pro' ? 10 : 500;
    const currentCount = await cacheIncrement(rateLimitKey, 30 * 86400); // Expire end of month

    if (currentCount > maxMessages) {
      throw new functions.https.HttpsError('resource-exhausted',
        `Monthly AI message limit (${maxMessages}) reached. ${tier === 'pro' ? 'Upgrade to Elite for 500/month.' : ''}`);
    }

    const parsed = aiChatSchema.safeParse(data);
    if (!parsed.success) {
      throw new functions.https.HttpsError('invalid-argument', 'Invalid message',
        { errors: parsed.error.errors });
    }

    const { message, conversationId } = parsed.data;

    // Load or create conversation
    let conversation: AIConversationDocument | null = null;
    let convoRef;

    if (conversationId) {
      convoRef = db.collection(Collections.USERS).doc(uid)
        .collection(Collections.AI_CONVERSATIONS).doc(conversationId);
      const convoSnap = await convoRef.get();
      if (convoSnap.exists) {
        conversation = convoSnap.data() as AIConversationDocument;
      }
    }

    if (!conversation) {
      const newId = conversationId || uuidv4();
      convoRef = db.collection(Collections.USERS).doc(uid)
        .collection(Collections.AI_CONVERSATIONS).doc(newId);
    }

    // Build context snapshot from last 7 days
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
    const startDateStr = sevenDaysAgo.toISOString().split('T')[0];

    const statsSnap = await db.collection(Collections.USERS).doc(uid)
      .collection(Collections.DAILY_STATS)
      .where('date', '>=', startDateStr)
      .orderBy('date', 'desc')
      .limit(7)
      .get();

    const stats = statsSnap.docs.map((d) => d.data() as DailyStatsDocument);

    const scores = stats.map((s) => s.productivityScore?.final || 0);
    const avgScore = scores.length > 0
      ? Math.round(scores.reduce((a, b) => a + b, 0) / scores.length) : 0;
    const bestScore = Math.max(...scores, 0);
    const worstScore = Math.min(...scores.filter((s) => s > 0), 100);

    // Find top distracting apps
    const appUsageTotals: Record<string, number> = {};
    for (const stat of stats) {
      for (const [appId, usage] of Object.entries(stat.appUsage || {})) {
        if (usage.category === 'social_media' || usage.category === 'entertainment') {
          appUsageTotals[appId] = (appUsageTotals[appId] || 0) + usage.totalMinutes;
        }
      }
    }
    const topDistractingApps = Object.entries(appUsageTotals)
      .sort(([, a], [, b]) => b - a)
      .slice(0, 3)
      .map(([appId]) => appId);

    const contextString = [
      `User stats (last 7 days):`,
      `- Average productivity score: ${avgScore}/100 (best: ${bestScore}, worst: ${worstScore})`,
      `- Current streak: ${user.stats.currentStreak} days`,
      `- Level: ${user.stats.level}`,
      `- Total focus hours: ${Math.round(user.stats.totalFocusMinutes / 60)}`,
      `- Top distracting apps: ${topDistractingApps.join(', ') || 'none detected'}`,
      `- Social media today: ${stats[0]?.socialMediaMinutes || 0} minutes`,
      `- Focus sessions this week: ${stats.reduce((s, d) => s + (d.focusSessions?.completed || 0), 0)}`,
    ].join('\n');

    const systemPrompt = `You are Alex, a warm, knowledgeable productivity coach in the FocusGuard Pro app. You have access to the user's anonymized usage statistics. Be specific, actionable, empathetic, and concise. Never shame the user. Use their actual data to personalize advice. Keep responses under 150 words unless user asks for detail. Use emojis sparingly.\n\nContext:\n${contextString}`;

    // Build messages array
    const historyMessages: { role: 'system' | 'user' | 'assistant'; content: string }[] = [
      { role: 'system', content: systemPrompt },
    ];

    // Add last 20 messages from conversation history
    if (conversation?.messages) {
      const recentMessages = conversation.messages.slice(-20);
      for (const msg of recentMessages) {
        if (msg.role !== 'system') {
          historyMessages.push({ role: msg.role, content: msg.content });
        }
      }
    }

    historyMessages.push({ role: 'user', content: message });

    // Call OpenAI
    const apiKey = await getSecret('openai-api-key');
    const { default: OpenAI } = await import('openai');
    const openai = new OpenAI({ apiKey });

    const completion = await openai.chat.completions.create({
      model: 'gpt-4o',
      messages: historyMessages,
      max_tokens: 500,
      temperature: 0.7,
    });

    const aiResponse = completion.choices[0]?.message?.content || 'I apologize, but I couldn\'t generate a response. Please try again.';
    const tokensUsed = completion.usage?.total_tokens || 0;

    // Save conversation
    const userMessage: AIMessage = {
      messageId: uuidv4(),
      role: 'user',
      content: message,
      tokensUsed: null,
      createdAt: now,
    };

    const assistantMessage: AIMessage = {
      messageId: uuidv4(),
      role: 'assistant',
      content: aiResponse,
      tokensUsed,
      createdAt: now,
    };

    const updatedMessages = [
      ...(conversation?.messages || []),
      userMessage,
      assistantMessage,
    ];

    const convoData: AIConversationDocument = {
      conversationId: convoRef!.id,
      userId: uid,
      messages: updatedMessages,
      contextSnapshot: {
        weeklyScoreAverage: avgScore,
        topDistractingApps,
        currentStreak: user.stats.currentStreak,
        weakestArea: worstScore < 50 ? 'productivity score' : 'social media usage',
        strongestArea: bestScore > 80 ? 'focus sessions' : 'habit completion',
        capturedAt: now,
      },
      totalTokensUsed: (conversation?.totalTokensUsed || 0) + tokensUsed,
      createdAt: conversation?.createdAt || now,
      updatedAt: now,
    };

    await convoRef!.set(convoData);

    return {
      response: aiResponse,
      conversationId: convoRef!.id,
      tokensUsed,
      monthlyRemaining: maxMessages - currentCount,
    };
  });
