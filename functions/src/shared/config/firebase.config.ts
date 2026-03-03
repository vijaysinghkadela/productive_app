import * as admin from 'firebase-admin';
import { SecretManagerServiceClient } from '@google-cloud/secret-manager';

let _app: admin.app.App | null = null;
let _secretClient: SecretManagerServiceClient | null = null;
const _secretCache = new Map<string, { value: string; expiresAt: number }>();

export function getFirebaseApp(): admin.app.App {
  if (!_app) {
    _app = admin.initializeApp();
  }
  return _app;
}

export function getFirestore(): admin.firestore.Firestore {
  return getFirebaseApp().firestore();
}

export function getAuth(): admin.auth.Auth {
  return getFirebaseApp().auth();
}

export function getMessaging(): admin.messaging.Messaging {
  return getFirebaseApp().messaging();
}

export function getStorage(): admin.storage.Storage {
  return getFirebaseApp().storage();
}

function getSecretClient(): SecretManagerServiceClient {
  if (!_secretClient) {
    _secretClient = new SecretManagerServiceClient();
  }
  return _secretClient;
}

export async function getSecret(name: string): Promise<string> {
  const cached = _secretCache.get(name);
  if (cached && cached.expiresAt > Date.now()) {
    return cached.value;
  }

  const projectId = process.env.GOOGLE_CLOUD_PROJECT || process.env.GCLOUD_PROJECT;
  const secretPath = `projects/${projectId}/secrets/${name}/versions/latest`;

  try {
    const client = getSecretClient();
    const [version] = await client.accessSecretVersion({ name: secretPath });
    const payload = version.payload?.data;
    if (!payload) throw new Error(`Secret ${name} has no payload`);
    const value = typeof payload === 'string' ? payload : Buffer.from(payload).toString('utf-8');

    // Cache for 5 minutes
    _secretCache.set(name, { value, expiresAt: Date.now() + 5 * 60 * 1000 });
    return value;
  } catch (error) {
    console.error(`Failed to access secret ${name}:`, error);
    // Fallback to environment variable
    const envValue = process.env[name.toUpperCase().replace(/-/g, '_')];
    if (envValue) return envValue;
    throw new Error(`Secret ${name} not found in Secret Manager or environment`);
  }
}

// Config constants
export const PROJECT_ID = process.env.GOOGLE_CLOUD_PROJECT || 'focusguard-pro';
export const REGION = 'us-central1';
export const IS_EMULATOR = process.env.FUNCTIONS_EMULATOR === 'true';
