

const admin = require("firebase-admin");

//demo use emulator settings for local development, will be ignored in production
/*if (process.env.FUNCTIONS_EMULATOR === "true") {
  process.env.FIRESTORE_EMULATOR_HOST = "127.0.0.1:8080";
  process.env.FIREBASE_STORAGE_EMULATOR_HOST = "127.0.0.1:9199";
  process.env.FIREBASE_AUTH_EMULATOR_HOST = "127.0.0.1:9099";
}

const projectId = process.env.GCLOUD_PROJECT || "demo-pocketlawyer";

admin.initializeApp({
  projectId: projectId,
  storageBucket: `${projectId}.appspot.com`,
});
*/

if (!admin.apps.length) {
  admin.initializeApp();
}

module.exports = {
  db: admin.firestore(),
  storage: admin.storage(),
  auth: admin.auth(),
  admin, // Exporting admin itself is helpful for FieldValue/Timestamp
};