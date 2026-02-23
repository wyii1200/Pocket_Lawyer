/*
* Analyze a contract document stored in Firebase Storage using Google Generative AI.
* This function retrieves the PDF from Storage, extracts text using pdf-parse,
* sends it to the Generative AI model for analysis, and stores the results in Firestore.
*/

const admin = require("firebase-admin");
//const functions = require("firebase-functions");
const { db, storage } = require("../config/firebase");
//const { verifyAuth } = require("../middleware/auth");
const getModel = require("../config/gemini");
const pdfParse = require("pdf-parse");
const vision = require("@google-cloud/vision"); // For OCR
const client = new vision.ImageAnnotatorClient();


//change from onRequest to onCall for better error handling and auth support
const { onCall, HttpsError } = require("firebase-functions/v2/https");




exports.analyzeContract = onCall(async (request) => {
  console.log("ANALYZE CALLED");

  const { documentId } = request.data;
  if (!documentId) {
    throw new HttpsError("invalid-argument", "documentId is required");
  }

  // Example AI result placeholder
  const aiResult = { summary: "Contract looks fine", riskLevel: "Low" };

  await db.collection("documents").doc(documentId).update({
    status: "completed",
    result: aiResult,
    completedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  
  return { message: "Function working!", ...aiResult };
});





exports.analyzeContract = onCall(async (request) => {
  try {
    const { documentId } = request.data;

    if (!documentId) {
      throw new HttpsError("invalid-argument", "documentId is required");
    }

    let extractedText = contractText;
    
    //console.log("Incoming data:", request.data);

    let docRef = null;

    if (!extractedText && documentId) {
      docRef = db.collection("documents").doc(documentId);
      const docSnap = await docRef.get();

    if (!docSnap.exists) {
      throw new HttpsError("not-found", "Document not found");
    }

    const {filePath, fileType} = docSnap.data();

    // Download file from Storage
    const file = storage.bucket().file(filePath);
    const [buffer] = await file.download();

    //let extractedText = "";

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
  }

    if (!extractedText) throw new Error("No text found in document");


    const prompt = `
    Analyze this contract and return ONLY valid JSON.
    1. Provide summary
    2. Identify risky clauses
    3. Assign risk level (low, medium, high)
    4. Explain in simple English

    Format:
{
  "riskLevel": "low | medium | high",
  "clauses": [
    {
      "title": "Clause title",
      "risk": "Why risky",
      "legalRef": "Relevant law reference"
    }
  ]
}


    Contract:
    ${extractedText}
    `;
    const model = getModel(); 
    const result = await model.generateContent(prompt);
    const response = await result.response;
    const text = response.text();

    const parsed = JSON.parse(text);

    return parsed;

    // if (documentId) {
    //   await docRef.update({
    //     status: "completed",
    //     analysis: text,
    //   });
    // }
    // return { status: "completed", analysis: text };

  } catch (error) {
    console.error("Analyze error:", error);
    throw new HttpsError("internal", error.message);
  }
});

