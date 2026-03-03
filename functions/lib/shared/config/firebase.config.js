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
exports.IS_EMULATOR = exports.REGION = exports.PROJECT_ID = void 0;
exports.getFirebaseApp = getFirebaseApp;
exports.getFirestore = getFirestore;
exports.getAuth = getAuth;
exports.getMessaging = getMessaging;
exports.getStorage = getStorage;
exports.getSecret = getSecret;
const admin = __importStar(require("firebase-admin"));
const secret_manager_1 = require("@google-cloud/secret-manager");
let _app = null;
let _secretClient = null;
const _secretCache = new Map();
function getFirebaseApp() {
    if (!_app) {
        _app = admin.initializeApp();
    }
    return _app;
}
function getFirestore() {
    return getFirebaseApp().firestore();
}
function getAuth() {
    return getFirebaseApp().auth();
}
function getMessaging() {
    return getFirebaseApp().messaging();
}
function getStorage() {
    return getFirebaseApp().storage();
}
function getSecretClient() {
    if (!_secretClient) {
        _secretClient = new secret_manager_1.SecretManagerServiceClient();
    }
    return _secretClient;
}
async function getSecret(name) {
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
        if (!payload)
            throw new Error(`Secret ${name} has no payload`);
        const value = typeof payload === 'string' ? payload : Buffer.from(payload).toString('utf-8');
        // Cache for 5 minutes
        _secretCache.set(name, { value, expiresAt: Date.now() + 5 * 60 * 1000 });
        return value;
    }
    catch (error) {
        console.error(`Failed to access secret ${name}:`, error);
        // Fallback to environment variable
        const envValue = process.env[name.toUpperCase().replace(/-/g, '_')];
        if (envValue)
            return envValue;
        throw new Error(`Secret ${name} not found in Secret Manager or environment`);
    }
}
// Config constants
exports.PROJECT_ID = process.env.GOOGLE_CLOUD_PROJECT || 'focusguard-pro';
exports.REGION = 'us-central1';
exports.IS_EMULATOR = process.env.FUNCTIONS_EMULATOR === 'true';
//# sourceMappingURL=firebase.config.js.map