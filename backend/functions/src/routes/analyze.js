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
const vision = require("@google-cloud/vision"); // For OCR
const client = new vision.ImageAnnotatorClient();

const { onCall, HttpsError } = require("firebase-functions/v2/https");

exports.analyzeContract = onCall(async (request) => {
  try {
    const { documentId } = request.data; // Data comes from request.data
    const userUid = request.auth.uid;   // Auth is handled automatically

    // ... your existing extraction logic here ...

    const docRef = db.collection("documents").doc(documentId);
    const docSnap = await docRef.get();

    if (!docSnap.exists) throw new Error("Document not found");

    const {filePath} = docSnap.data();

    // Download file from Storage
    const file = storage.bucket().file(filePath);
    const [buffer] = await file.download();

    let extractedText = "";

    // --- 1. PDF extraction ---
    if (fileType === "pdf") {
      const pdfData = await pdfParse(buffer);
      extractedText = pdfData.text;
    }

    // --- 2. Image extraction ---
    else if (fileType === "image") {
      const [result] = await client.textDetection(buffer);
      const detections = result.textAnnotations;
      extractedText = detections.length > 0 ? detections[0].description : "";
    }

    if (!extractedText) throw new Error("No text found in document");


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

  
    return { status: "completed", analysis: text }; // Return JSON directly
  } catch (error) {
    throw new HttpsError("internal", error.message);
  }
});

