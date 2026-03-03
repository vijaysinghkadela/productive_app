import * as functions from 'firebase-functions';
import { NotificationType } from '../shared/types/firestore.types';
interface SendNotificationInput {
    userId: string;
    type: NotificationType;
    title: string;
    body: string;
    data?: Record<string, string>;
}
/**
 * Send a notification to a user (FCM + Firestore)
 */
export declare function sendNotification(input: SendNotificationInput): Promise<void>;
export declare const sendStreakReminders: functions.CloudFunction<unknown>;
export declare const NotificationTemplates: {
    readonly welcomeUser: (name: string) => {
        title: string;
        body: string;
    };
    readonly goalWarning: (goalName: string, percentage: number) => {
        title: string;
        body: string;
    };
    readonly goalExceeded: (goalName: string) => {
        title: string;
        body: string;
    };
    readonly goalMet: (goalName: string) => {
        title: string;
        body: string;
    };
    readonly streakMilestone: (days: number) => {
        title: string;
        body: string;
    };
    readonly streakBroken: () => {
        title: string;
        body: string;
    };
    readonly sessionComplete: (minutes: number, xp: number) => {
        title: string;
        body: string;
    };
    readonly achievementUnlocked: (name: string, xp: number) => {
        title: string;
        body: string;
    };
    readonly weeklyReport: () => {
        title: string;
        body: string;
    };
    readonly levelUp: (level: number) => {
        title: string;
        body: string;
    };
    readonly partnerActivity: (partnerName: string, action: string) => {
        title: string;
        body: string;
    };
    readonly bedtimeReminder: () => {
        title: string;
        body: string;
    };
};
export {};
//# sourceMappingURL=notifications.service.d.ts.map