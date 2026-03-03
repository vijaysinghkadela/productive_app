import * as admin from 'firebase-admin';
import * as fs from 'fs';
import * as path from 'path';
import { Timestamp } from 'firebase-admin/firestore';

// Initialize Firebase Admin
if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();
const MIGRATIONS_DIR = path.join(__dirname, 'migrations');
const MIGRATIONS_COLLECTION = 'admin';
const MIGRATIONS_DOC = 'migrations';

interface MigrationRecord {
  name: string;
  appliedAt: Timestamp;
  durationMs: number;
}

interface MigrationModule {
  up: (db: admin.firestore.Firestore) => Promise<void>;
  description: string;
}

async function getAppliedMigrations(): Promise<string[]> {
  const doc = await db.collection(MIGRATIONS_COLLECTION).doc(MIGRATIONS_DOC).get();
  if (!doc.exists) return [];
  const data = doc.data();
  return (data?.applied || []).map((m: MigrationRecord) => m.name);
}

async function markMigrationApplied(name: string, durationMs: number): Promise<void> {
  const record: MigrationRecord = {
    name,
    appliedAt: Timestamp.now(),
    durationMs,
  };

  await db.collection(MIGRATIONS_COLLECTION).doc(MIGRATIONS_DOC).set({
    applied: admin.firestore.FieldValue.arrayUnion(record),
    lastMigration: name,
    lastMigrationAt: Timestamp.now(),
  }, { merge: true });
}

async function runMigrations(dryRun = false): Promise<void> {
  console.log(`🔄 Running migrations${dryRun ? ' (DRY RUN)' : ''}...\n`);

  // Ensure migrations directory exists
  if (!fs.existsSync(MIGRATIONS_DIR)) {
    console.log('No migrations directory found. Creating...');
    fs.mkdirSync(MIGRATIONS_DIR, { recursive: true });
    console.log('Created migrations directory. Add migration files and run again.');
    return;
  }

  // Get all migration files, sorted
  const files = fs.readdirSync(MIGRATIONS_DIR)
    .filter((f) => f.endsWith('.ts') || f.endsWith('.js'))
    .sort();

  if (files.length === 0) {
    console.log('No migration files found.');
    return;
  }

  // Get already applied migrations
  const applied = await getAppliedMigrations();
  console.log(`Found ${files.length} migration files, ${applied.length} already applied.\n`);

  // Run pending migrations
  let pendingCount = 0;
  for (const file of files) {
    const name = file.replace(/\.(ts|js)$/, '');

    if (applied.includes(name)) {
      console.log(`  ⏭️  ${name} (already applied)`);
      continue;
    }

    pendingCount++;
    console.log(`  🔄 ${name}...`);

    if (dryRun) {
      console.log(`  ⏸️  ${name} (dry run — skipped)`);
      continue;
    }

    const startTime = Date.now();
    try {
      const migration: MigrationModule = require(path.join(MIGRATIONS_DIR, file));
      if (typeof migration.up !== 'function') {
        throw new Error(`Migration ${name} does not export an 'up' function`);
      }

      await migration.up(db);
      const durationMs = Date.now() - startTime;

      await markMigrationApplied(name, durationMs);
      console.log(`  ✅ ${name} (${durationMs}ms)`);
    } catch (err) {
      console.error(`  ❌ ${name} FAILED:`, err);
      console.error('\nMigration halted. Fix the issue and run again.');
      process.exit(1);
    }
  }

  if (pendingCount === 0) {
    console.log('\n✅ All migrations already applied. Database is up to date.');
  } else if (!dryRun) {
    console.log(`\n✅ Applied ${pendingCount} migration(s).`);
  } else {
    console.log(`\n📋 ${pendingCount} pending migration(s) found (dry run).`);
  }
}

// CLI
const args = process.argv.slice(2);
const dryRun = args.includes('--dry-run');

runMigrations(dryRun)
  .then(() => process.exit(0))
  .catch((err) => { console.error('Migration runner failed:', err); process.exit(1); });
