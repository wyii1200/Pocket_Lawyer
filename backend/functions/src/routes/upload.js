/*
* Upload route for handling PDF file uploads
* processing with Google Generative AI
* and storing metadata in Firestore.
*/


const admin = require("firebase-admin");
const functions = require("firebase-functions");
const { db, storage } = require("../config/firebase");
const { verifyAuth } = require("../middleware/auth");
const getModel = require("../config/gemini");
const pdfParse = require("pdf-parse");


//change from onRequest to onCall for better error handling and auth support
const { onCall, HttpsError } = require("firebase-functions/v2/https");

exports.uploadDocument = onCall(async (request) => {
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

/*exports.uploadDocument = functions.https.onRequest(async (req, res) => {
  try {
    const { fileBase64 } = req.body; 
    if (!fileBase64) {
      return res.status(400).json({ error: "fileBase64 is required" });
    }
    
    const documentId = db.collection("documents").doc().id;
    const userId = "anonymous"; // Default userId, can extract from auth header if needed

    // For testing, skip actual storage upload
    // const buffer = Buffer.from(fileBase64, "base64");
    // const filePath = `documents/${userId}/${documentId}.pdf`;
    // const fileRef = storage.bucket().file(filePath);
    // await fileRef.save(buffer, { contentType: 'application/pdf' });

    // Save metadata to Firestore
    try {
      await db.collection("documents").doc(documentId).set({
        userId: userId,
        status: "processing",
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        filePath: `documents/${userId}/${documentId}.pdf`,
      });
    } catch (dbError) {
      console.warn("Firestore not available, but function still works:", dbError.message);
    }

    res.status(200).json({ documentId, status: "processing" });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});*/

