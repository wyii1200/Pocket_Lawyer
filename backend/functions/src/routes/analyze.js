/*
* Analyze a contract document stored in Firebase Storage using Google Generative AI.
* This function retrieves the PDF from Storage, extracts text using pdf-parse,
* sends it to the Generative AI model for analysis, and stores the results in Firestore.
*/

const admin = require("firebase-admin");
const functions = require("firebase-functions");
const { db, storage } = require("../config/firebase");
const { verifyAuth } = require("../middleware/auth");
const { model } = require("../config/gemini");
const pdfParse = require("pdf-parse");

exports.analyzeContract = functions.https.onRequest(async (req, res) => {
  try {
    const user = await verifyAuth(req);
    const {documentId} = req.body;

    const docRef = db.collection("documents").doc(documentId);
    const docSnap = await docRef.get();

    if (!docSnap.exists) throw new Error("Document not found");

    const {filePath} = docSnap.data();

    const file = storage.bucket().file(filePath);
    const [buffer] = await file.download();

    const pdfData = await pdfParse(buffer);
    const extractedText = pdfData.text;

    const prompt = `
    Analyze this contract.
    1. Provide summary
    2. Identify risky clauses
    3. Assign risk level (low, medium, high)
    4. Explain in simple English

    Contract:
    ${extractedText}
    `;

    const result = await model.generateContent(prompt);
    const response = await result.response;
    const text = response.text();

    await docRef.update({
      status: "completed",
      analysis: text,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    res.json({status: "completed", analysis: text});
  } catch (error) {
    res.status(500).json({error: error.message});
  }
});
