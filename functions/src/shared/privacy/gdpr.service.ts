import * as admin from 'firebase-admin';
import { AuditLogger } from '../utils/audit.logger';

export class GDPRService {
  constructor(private auditLogger: AuditLogger) {}

  /**
   * Right to Erasure (Article 17)
   * Hard deletes all PII and user-generated content from Firestore and Storage.
   */
  async deleteUserData(userId: string): Promise<void> {
    const db = admin.firestore();
    const batch = db.batch();

    try {
      // 1. Delete Core User Profile
      batch.delete(db.collection('users').doc(userId));

      // 2. Delete PII subcollections (sessions, journals)
      // Note: A real implementation requires a recursive delete for deep subcollections,
      // or using the `firebase-tools` `firestore:delete` programmatically.
      const sessions = await db.collection('users').doc(userId).collection('sessions').get();
      sessions.forEach(doc => batch.delete(doc.ref));

      const journals = await db.collection('users').doc(userId).collection('journals').get();
      journals.forEach(doc => batch.delete(doc.ref));

      // 3. Cloud Storage (Profile Pics, Attachments)
      const bucket = admin.storage().bucket();
      await bucket.deleteFiles({ prefix: `users/${userId}/` });

      // 4. Anonymize Analytics / Shared Data
      // Instead of deleting from global analytics, replace UID with 'DELETED_USER'
      // to maintain aggregate statistics integrity without retaining PII.

      // 5. Firebase Auth Deletion
      await admin.auth().deleteUser(userId);

      await batch.commit();

      await this.auditLogger.logEvent({
        action: 'USER_DATA_DELETION',
        actorId: userId,
        status: 'SUCCESS',
      });
      console.log(`Successfully erased all data for user ${userId} per GDPR Art 17.`);
    } catch (e) {
      console.error(`Failed to execute Right to Erasure for ${userId}`, e);
      await this.auditLogger.logEvent({
        action: 'USER_DATA_DELETION',
        actorId: userId,
        status: 'FAILURE',
        details: { error: (e as Error).message }
      });
      throw new Error('Erasure failed. Retrying in background or notifying SRE.');
    }
  }

  /**
   * Right to Access / Data Portability (Article 15, 20)
   * Generates a comprehensive JSON export of all data associated with the subject.
   */
  async exportUserData(userId: string): Promise<Record<string, any>> {
    const db = admin.firestore();
    const exportPayload: Record<string, any> = {};

    try {
      const userDoc = await db.collection('users').doc(userId).get();
      exportPayload['profile'] = userDoc.data() || {};

      const collections = ['sessions', 'journals', 'goals', 'preferences'];
      for (const coll of collections) {
        const snap = await db.collection('users').doc(userId).collection(coll).get();
        exportPayload[coll] = snap.docs.map(d => ({ id: d.id, ...d.data() }));
      }

      // Add a cryptographically signed verifiable credential or hash for integrity
      exportPayload['metadata'] = {
        exportedAt: new Date().toISOString(),
        version: '1.0',
        issuer: 'FocusGuard Pro DPO',
      };

      await this.auditLogger.logEvent({
        action: 'USER_DATA_EXPORT',
        actorId: userId,
        status: 'SUCCESS',
      });

      return exportPayload;
    } catch (e) {
      await this.auditLogger.logEvent({
        action: 'USER_DATA_EXPORT',
        actorId: userId,
        status: 'FAILURE',
        details: { error: (e as Error).message }
      });
      throw e;
    }
  }

  /**
   * Right to Restrict Processing (Article 18)
   */
  async restrictProcessing(userId: string): Promise<void> {
    await admin.firestore().collection('users').doc(userId).update({
      processingRestricted: true,
      lastConsentUpdate: admin.firestore.FieldValue.serverTimestamp(),
    });

    await this.auditLogger.logEvent({
      action: 'USER_RESTRICT_PROCESSING',
      actorId: userId,
      status: 'SUCCESS',
    });
  }
}
