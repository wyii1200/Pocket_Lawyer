/*
* Upload route for handling PDF file uploads
* processing with Google Generative AI
* and storing metadata in Firestore.
*/

const { FieldValue } = require("firebase-admin/firestore"); // fix
const admin = require("firebase-admin");
const { db, storage } = require("../config/firebase");

//change from onRequest to onCall for better error handling and auth support
const { onCall, HttpsError } = require("firebase-functions/v2/https");

exports.uploadDocument = onCall({ region: "us-central1" },async (request) => {
  const { fileBase64 } = request.data;

  if (!fileBase64) {
    throw new HttpsError("invalid-argument", "fileBase64 is required");
  }

  const documentId = db.collection("documents").doc().id;

  await db.collection("documents").doc(documentId).set({
    status: "processing",
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return { documentId, status: "processing" };

 
});


