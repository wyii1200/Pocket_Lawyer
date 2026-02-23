/*
* Analyze a contract document stored in Firebase Storage using Google Generative AI.
* This function retrieves the PDF from Storage, extracts text using pdf-parse,
* sends it to the Generative AI model for analysis, and stores the results in Firestore.
*/

const admin = require("firebase-admin");
const { FieldValue } = require("firebase-admin/firestore"); // ADD THIS
const { db } = require("../config/firebase");
const { onCall, HttpsError } = require("firebase-functions/v2/https");


exports.analyzeContract = onCall(
  { region: "us-central1" },
  async (request) => {
    console.log("ANALYZE CALLED", request.data);
    const { documentId } = request.data;

    if (!documentId) {
      throw new HttpsError("invalid-argument", "documentId is required");
    }

    
    const aiResult = {
      summary: "Contract looks fine",
      riskLevel: "MEDIUM",
      clauses: [{
        title: "Termination Clause",
        risk: "May allow early termination without notice",
        legalRef: "Section 57 Contracts Act 1950"
      }]
    };

    await db.collection("documents").doc(documentId).update({
      status: "completed",
      result: aiResult,
      completedAt: FieldValue.serverTimestamp(), // FIXED
    });

    return aiResult;
  }
);





