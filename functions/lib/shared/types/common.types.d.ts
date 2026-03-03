export interface ApiResponse<T = unknown> {
    success: boolean;
    data?: T;
    error?: ApiErrorResponse;
    meta?: ApiMeta;
}
export interface ApiErrorResponse {
    code: string;
    message: string;
    details?: Record<string, unknown>;
}
export interface ApiMeta {
    page?: number;
    pageSize?: number;
    totalCount?: number;
    hasMore?: boolean;
    requestId?: string;
}
export interface PaginationParams {
    page: number;
    pageSize: number;
}
export interface DateRange {
    startDate: string;
    endDate: string;
}
export type GroupBy = 'day' | 'week' | 'month';
export interface UserEvent {
    userId: string;
    eventName: string;
    eventParams: Record<string, unknown>;
    platform: 'android' | 'ios';
    appVersion: string;
    timestamp: Date;
}
export interface AchievementTrigger {
    userId: string;
    triggerType: AchievementTriggerType;
    triggerData: Record<string, unknown>;
}
export type AchievementTriggerType = 'session_completed' | 'usage_synced' | 'goal_met' | 'habit_completed' | 'streak_updated' | 'level_up' | 'challenge_completed' | 'accountability_started' | 'referral_completed' | 'leaderboard_rank_changed' | 'social_media_free_day' | 'score_calculated';
export interface RevenueCatWebhookEvent {
    api_version: string;
    event: {
        id: string;
        type: RevenueCatEventType;
        app_user_id: string;
        aliases: string[];
        product_id: string;
        entitlement_ids: string[];
        period_type: 'NORMAL' | 'TRIAL' | 'INTRO';
        purchased_at_ms: number;
        expiration_at_ms: number | null;
        environment: 'SANDBOX' | 'PRODUCTION';
        store: 'APP_STORE' | 'PLAY_STORE' | 'STRIPE';
        is_trial_conversion: boolean;
        cancel_reason: string | null;
        currency: string;
        price: number;
        price_in_purchased_currency: number;
        subscriber_attributes: Record<string, {
            value: string;
            updated_at_ms: number;
        }>;
        transaction_id: string;
        original_transaction_id: string;
    };
}
export type RevenueCatEventType = 'INITIAL_PURCHASE' | 'RENEWAL' | 'CANCELLATION' | 'BILLING_ISSUE' | 'EXPIRATION' | 'UNCANCELLATION' | 'PRODUCT_CHANGE' | 'TRANSFER' | 'TEST' | 'SUBSCRIBER_ALIAS';
export interface FeatureGates {
    basic_tracking: boolean;
    blocked_apps_limit: number;
    stats_days_limit: number;
    goals_limit: number;
    habits_limit: number;
    full_analytics: boolean;
    all_timers: boolean;
    bedtime_mode: boolean;
    focus_modes: boolean;
    achievements: boolean;
    leaderboard: boolean;
    accountability_partners_limit: number;
    challenges: boolean;
    export_reports: boolean;
    ambient_sounds: boolean;
    focus_spaces: boolean;
    ai_basic_insights: boolean;
    ai_coaching_chat: boolean;
    ai_monthly_limit: number;
    strict_mode_biometric: boolean;
    live_activities: boolean;
    watch_app: boolean;
    custom_overlay: boolean;
    priority_support: boolean;
}
//# sourceMappingURL=common.types.d.ts.map