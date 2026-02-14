/*const admin = require("firebase-admin");

admin.initializeApp();

module.exports = {
  db: admin.firestore(),
  storage: admin.storage(),
  auth: admin.auth(),
};
*/


const admin = require("firebase-admin");

// The Admin SDK automatically connects to emulators
// if these specific environment variables are set.
if (process.env.FUNCTIONS_EMULATOR === "true") {
  process.env.FIRESTORE_EMULATOR_HOST = "127.0.0.1:8080";
  process.env.FIREBASE_STORAGE_EMULATOR_HOST = "127.0.0.1:9199";
  process.env.FIREBASE_AUTH_EMULATOR_HOST = "127.0.0.1:9099";
}

admin.initializeApp({
  // Use a placeholder for local development
  projectId: process.env.GCLOUD_PROJECT || "demo-pocketlawyer",
});

module.exports = {
  db: admin.firestore(),
  storage: admin.storage(),
  auth: admin.auth(),
  admin, // Exporting admin itself is helpful for FieldValue/Timestamp
};