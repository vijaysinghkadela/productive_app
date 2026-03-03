// Examples of optimizing Cloud Function Execution flows
import * as admin from 'firebase-admin';
/*
import { onCall } from 'firebase-functions/v2/https';
import { CloudTasksClient } from '@google-cloud/tasks';
*/

// FUNCTION EXECUTION OPTIMIZATION:

// 1. Parallel async operations: 3x faster resolving without yielding blocking threads
async function optimizedFetches(uid: string) {
  // RIGHT: parallel operations (3x faster)
  const [user, subscription, stats] = await Promise.all([
    getUser(uid),
    getSubscription(uid),
    getStats(uid),
  ]);
  return { user, subscription, stats };
}

// 2. Cloud Tasks for async work: (Yield early to client, offload processing)
/*
const cloudTasksClient = new CloudTasksClient();

export const syncUsage = onCall(async (request) => {
  const { data, auth } = request;
  
  // Validate and update critical data synchronously:
  await updateDailyStats(auth.uid, data);
  
  // Queue non-critical work asynchronously (don't await):
  await cloudTasksClient.createTask({
    parent: "queues/SCORE_CALCULATION",
    task: { payload: { userId: auth.uid, date: data.date } }
  });
  // ↑ Returns immediately — score calculated in background
  
  return { success: true }; // Instant response to client
});
*/

// 3. Memory Optimization: Trigger GC when manipulating massive PDFs/Images
async function generateReport(userId: string) {
  let reportData: any = await fetchAllReportData(userId); // Large object
  const pdf = await generatePDF(reportData);
  
  reportData = null; // Free reference for GC 
  // Expect Cloud runtime explicitly started with --expose-gc flag
  if (global.gc) {
    global.gc(); 
  }
  
  await uploadPDF(pdf);
}

// Mocks
async function getUser(uid: string) {}
async function getSubscription(uid: string) {}
async function getStats(uid: string) {}
async function updateDailyStats(uid: string, data: any) {}
async function fetchAllReportData(uid: string) { return {}; }
async function generatePDF(data: any) { return Buffer.from("mock"); }
async function uploadPDF(pdf: Buffer) {}
