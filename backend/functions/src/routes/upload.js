/*
* Upload route for handling PDF file uploads
* processing with Google Generative AI
* and storing metadata in Firestore.
*/


const admin = require("firebase-admin");
const functions = require("firebase-functions");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { db, storage } = require("../config/firebase");
const { verifyAuth } = require("../middleware/auth");
const getModel = require("../config/gemini");
const pdfParse = require("pdf-parse");

exports.uploadDocument = onCall(async (request) => {
  if (!request.auth) throw new HttpsError("unauthenticated", "Auth required.");

  try {
    const { fileBase64 } = request.data; 
    const buffer = Buffer.from(fileBase64, "base64");
    const documentId = db.collection("documents").doc().id;

    const filePath = `documents/${request.auth.uid}/${documentId}.pdf`;
    const fileRef = storage.bucket().file(filePath);

    await fileRef.save(buffer, { contentType: 'application/pdf' });

    await db.collection("documents").doc(documentId).set({
      userId: request.auth.uid,
      status: "processing",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      filePath,
    });

    return { documentId, status: "processing" };
  } catch (error) {
    throw new HttpsError("internal", error.message);
  }
}); 

