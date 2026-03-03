import * as admin from 'firebase-admin';
export declare function getFirebaseApp(): admin.app.App;
export declare function getFirestore(): admin.firestore.Firestore;
export declare function getAuth(): admin.auth.Auth;
export declare function getMessaging(): admin.messaging.Messaging;
export declare function getStorage(): admin.storage.Storage;
export declare function getSecret(name: string): Promise<string>;
export declare const PROJECT_ID: string;
export declare const REGION = "us-central1";
export declare const IS_EMULATOR: boolean;
//# sourceMappingURL=firebase.config.d.ts.map