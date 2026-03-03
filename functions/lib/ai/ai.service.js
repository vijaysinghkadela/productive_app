"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.getAICoaching = void 0;
const functions = __importStar(require("firebase-functions"));
const firestore_1 = require("firebase-admin/firestore");
const firebase_config_1 = require("../shared/config/firebase.config");
const collections_constants_1 = require("../shared/constants/collections.constants");
const redis_config_1 = require("../shared/config/redis.config");
const common_validators_1 = require("../shared/validators/common.validators");
const uuid_1 = require("uuid");
// ─── AI Coaching Chat (Callable) ───
exports.getAICoaching = functions
    .region(firebase_config_1.REGION)
    .runWith({ timeoutSeconds: 120, memory: '512MB' })
    .https.onCall(async (data, context) => {
    if (!context.auth)
        throw new functions.https.HttpsError('unauthenticated', 'Not authenticated');
    const uid = context.auth.uid;
    const db = (0, firebase_config_1.getFirestore)();
    const now = firestore_1.Timestamp.now();
    // Check subscription
    const userSnap = await db.collection(collections_constants_1.Collections.USERS).doc(uid).get();
    if (!userSnap.exists)
        throw new functions.https.HttpsError('not-found', 'User not found');
    const user = userSnap.data();
    const tier = user.subscription.tier;
    if (!['pro', 'elite', 'lifetime'].includes(tier)) {
        throw new functions.https.HttpsError('permission-denied', 'AI coaching requires Pro or Elite subscription');
    }
    // Rate limiting
    const monthKey = new Date().toISOString().slice(0, 7); // YYYY-MM
    const rateLimitKey = `ai_rate:${uid}:${monthKey}`;
    const maxMessages = tier === 'pro' ? 10 : 500;
    const currentCount = await (0, redis_config_1.cacheIncrement)(rateLimitKey, 30 * 86400); // Expire end of month
    if (currentCount > maxMessages) {
        throw new functions.https.HttpsError('resource-exhausted', `Monthly AI message limit (${maxMessages}) reached. ${tier === 'pro' ? 'Upgrade to Elite for 500/month.' : ''}`);
    }
    const parsed = common_validators_1.aiChatSchema.safeParse(data);
    if (!parsed.success) {
        throw new functions.https.HttpsError('invalid-argument', 'Invalid message', {
            errors: parsed.error.errors,
        });
    }
    const { message, conversationId } = parsed.data;
    // Load or create conversation
    let conversation = null;
    let convoRef;
    if (conversationId) {
        convoRef = db
            .collection(collections_constants_1.Collections.USERS)
            .doc(uid)
            .collection(collections_constants_1.Collections.AI_CONVERSATIONS)
            .doc(conversationId);
        const convoSnap = await convoRef.get();
        if (convoSnap.exists) {
            conversation = convoSnap.data();
        }
    }
    if (!conversation) {
        const newId = conversationId || (0, uuid_1.v4)();
        convoRef = db
            .collection(collections_constants_1.Collections.USERS)
            .doc(uid)
            .collection(collections_constants_1.Collections.AI_CONVERSATIONS)
            .doc(newId);
    }
    // Build context snapshot from last 7 days
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
    const startDateStr = sevenDaysAgo.toISOString().split('T')[0];
    const statsSnap = await db
        .collection(collections_constants_1.Collections.USERS)
        .doc(uid)
        .collection(collections_constants_1.Collections.DAILY_STATS)
        .where('date', '>=', startDateStr)
        .orderBy('date', 'desc')
        .limit(7)
        .get();
    const stats = statsSnap.docs.map((d) => d.data());
    const scores = stats.map((s) => s.productivityScore?.final || 0);
    const avgScore = scores.length > 0 ? Math.round(scores.reduce((a, b) => a + b, 0) / scores.length) : 0;
    const bestScore = Math.max(...scores, 0);
    const worstScore = Math.min(...scores.filter((s) => s > 0), 100);
    // Find top distracting apps
    const appUsageTotals = {};
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
    const historyMessages = [
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
    const apiKey = await (0, firebase_config_1.getSecret)('openai-api-key');
    const { default: OpenAI } = await Promise.resolve().then(() => __importStar(require('openai')));
    const openai = new OpenAI({ apiKey });
    const completion = await openai.chat.completions.create({
        model: 'gpt-4o',
        messages: historyMessages,
        max_tokens: 500,
        temperature: 0.7,
    });
    const aiResponse = completion.choices[0]?.message?.content ||
        "I apologize, but I couldn't generate a response. Please try again.";
    const tokensUsed = completion.usage?.total_tokens || 0;
    // Save conversation
    const userMessage = {
        messageId: (0, uuid_1.v4)(),
        role: 'user',
        content: message,
        tokensUsed: null,
        createdAt: now,
    };
    const assistantMessage = {
        messageId: (0, uuid_1.v4)(),
        role: 'assistant',
        content: aiResponse,
        tokensUsed,
        createdAt: now,
    };
    const updatedMessages = [...(conversation?.messages || []), userMessage, assistantMessage];
    const convoData = {
        conversationId: convoRef.id,
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
    await convoRef.set(convoData);
    return {
        response: aiResponse,
        conversationId: convoRef.id,
        tokensUsed,
        monthlyRemaining: maxMessages - currentCount,
    };
});
//# sourceMappingURL=ai.service.js.map