import * as functions from 'firebase-functions';
export declare const onUserCreated: functions.CloudFunction<import("firebase-admin/auth").UserRecord>;
export declare const onUserDeleted: functions.CloudFunction<import("firebase-admin/auth").UserRecord>;
export declare const beforeSignIn: functions.BlockingFunction;
export declare const beforeCreate: functions.BlockingFunction;
//# sourceMappingURL=auth.triggers.d.ts.map