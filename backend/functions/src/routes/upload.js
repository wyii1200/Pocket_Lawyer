/*
* Upload route for handling PDF file uploads
* processing with Google Generative AI
* and storing metadata in Firestore.
*/


const admin = require("firebase-admin");
const functions = require("firebase-functions");
const { db, storage } = require("../config/firebase");
const { verifyAuth } = require("../middleware/auth");
const { model } = require("../config/gemini");
const pdfParse = require("pdf-parse");

exports.uploadDocument = functions.https.onRequest(async (req, res) => {
  try {
    const user = await verifyAuth(req);

    const file = req.body.file; // assume base64 for simplicity
    const buffer = Buffer.from(file, "base64");

    const documentId = db.collection("documents").doc().id;

    const filePath = `documents/${user.uid}/${documentId}.pdf`;
    const fileRef = storage.bucket().file(filePath);

    await fileRef.save(buffer);

    await db.collection("documents").doc(documentId).set({
      userId: user.uid,
      status: "processing",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      filePath,
    });

    res.json({documentId, status: "processing"});
  } catch (error) {
    res.status(500).json({error: error.message});
  }
});

