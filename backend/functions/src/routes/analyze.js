/*
* Analyze a contract document stored in Firebase Storage using Google Generative AI.
* This function retrieves the PDF from Storage, extracts text using pdf-parse,
* sends it to the Generative AI model for analysis, and stores the results in Firestore.
*/

const admin = require("firebase-admin");
const { db } = require("../config/firebase");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
console.log("FUNCTION HIT SUCCESSFULLY");

exports.analyzeContract = onCall(
  { region: "us-central1" },  // IMPORTANT
  async (request) => {
   // console.log("RAW REQUEST:", JSON.stringify(request));
    console.log("ANALYZE CALLED");
    console.log("REQUEST DATA:", request.data);
    console.log("AUTH:", request.auth);
    console.log("DATA:", request.data);
    console.log("Incoming data:", request.data);

    //Map<String, dynamic>.from(result.data);
    const { documentId } = request.data;

 
    if (!documentId) {
      throw new HttpsError("invalid-argument", "documentId is required");
    }

      //fix testing: use demo documentId for now
    //const documentId = request.data?.documentId || "demo";

    //demo: skip actual Storage retrieval and pdf parsing, directly update Firestore with mock result
    const aiResult = {
      summary: "Contract looks fine",
      riskLevel: "Low",
      clauses: [
        {
          title: "Termination Clause",
          risk: "May allow early termination without notice",
          legalRef: "Section 57 Contracts Act 1950"
        }]
    };

    await db.collection("documents")
      .doc(documentId)
      .update({
        status: "completed",
        result: aiResult,
        completedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

    return aiResult;
  }
);




/*exports.analyzeContract = onCall(async (request) => {
  try {
    const { documentId } = request.data;

    if (!documentId) {
      throw new HttpsError("invalid-argument", "documentId is required");
    }

    const docRef = db.collection("documents").doc(documentId);
    const docSnap = await docRef.get();

    if (!docSnap.exists) {
      throw new HttpsError("not-found", "Document not found");
    }

    // 🔥 Mock AI result for now
    const aiResult = {
      documentName: "Uploaded Contract",
      riskLevel: "Medium Risk",
      summary: "This contract contains termination clauses and liability limitations.",
      clauses: [
        {
          title: "Termination Clause",
          risk: "Medium",
          explanation: "Early termination may incur penalties."
        },
        {
          title: "Liability Limitation",
          risk: "High",
          explanation: "Liability is heavily restricted in favor of one party."
        }
      ]
    };

    // ✅ Update Firestore properly INSIDE function
    await docRef.update({
      status: "completed",
      result: aiResult,
      completedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return aiResult;

  } catch (error) {
    console.error("Analyze error:", error);
    throw new HttpsError("internal", error.message);
  }
});
*/
