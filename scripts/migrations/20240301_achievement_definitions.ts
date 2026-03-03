import * as admin from 'firebase-admin';
import { Timestamp } from 'firebase-admin/firestore';
import { ACHIEVEMENT_DEFINITIONS } from '../../functions/src/achievements/achievements.definitions';

export const description = 'Seed all 60 achievement definitions to Firestore';

export async function up(db: admin.firestore.Firestore): Promise<void> {
  let batch = db.batch();
  let count = 0;

  for (let i = 0; i < ACHIEVEMENT_DEFINITIONS.length; i++) {
    const ach = ACHIEVEMENT_DEFINITIONS[i];
    batch.set(db.collection('achievements').doc(ach.achievementId), {
      ...ach,
      isActive: true,
      order: i,
    });
    count++;

    if (count % 400 === 0) {
      await batch.commit();
      batch = db.batch();
    }
  }

  await batch.commit();
  console.log(`    Seeded ${ACHIEVEMENT_DEFINITIONS.length} achievement definitions`);
}
