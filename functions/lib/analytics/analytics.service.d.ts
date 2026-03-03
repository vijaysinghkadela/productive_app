import * as functions from 'firebase-functions';
export declare const BIGQUERY_SCHEMAS: {
    daily_stats: {
        fields: ({
            name: string;
            type: string;
            mode: string;
        } | {
            name: string;
            type: string;
            mode?: undefined;
        })[];
    };
    sessions: {
        fields: ({
            name: string;
            type: string;
            mode: string;
        } | {
            name: string;
            type: string;
            mode?: undefined;
        })[];
    };
    subscriptions: {
        fields: ({
            name: string;
            type: string;
            mode: string;
        } | {
            name: string;
            type: string;
            mode?: undefined;
        })[];
    };
    ai_usage: {
        fields: ({
            name: string;
            type: string;
            mode: string;
        } | {
            name: string;
            type: string;
            mode?: undefined;
        })[];
    };
    user_events: {
        fields: ({
            name: string;
            type: string;
            mode: string;
        } | {
            name: string;
            type: string;
            mode?: undefined;
        })[];
    };
    achievements: {
        fields: ({
            name: string;
            type: string;
            mode: string;
        } | {
            name: string;
            type: string;
            mode?: undefined;
        })[];
    };
    notifications: {
        fields: ({
            name: string;
            type: string;
            mode: string;
        } | {
            name: string;
            type: string;
            mode?: undefined;
        })[];
    };
};
export declare const syncDailyStatsToBigQuery: functions.CloudFunction<functions.Change<functions.firestore.DocumentSnapshot>>;
export declare const aggregateWeeklyAnalytics: functions.CloudFunction<unknown>;
export declare const cleanupOldNotifications: functions.CloudFunction<unknown>;
//# sourceMappingURL=analytics.service.d.ts.map