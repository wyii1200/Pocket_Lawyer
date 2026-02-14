/*
* Analyze a contract document stored in Firebase Storage using Google Generative AI.
* This function retrieves the PDF from Storage, extracts text using pdf-parse,
* sends it to the Generative AI model for analysis, and stores the results in Firestore.
*/

const admin = require("firebase-admin");
//const functions = require("firebase-functions");
const { db, storage } = require("../config/firebase");
//const { verifyAuth } = require("../middleware/auth");
//const getModel = require("../config/gemini");
const pdfParse = require("pdf-parse");


//change from onRequest to onCall for better error handling and auth support
const { onCall, HttpsError } = require("firebase-functions/v2/https");


// quick debug test
exports.analyzeContract = onCall(async (request) => {
  console.log("ANALYZE CALLED");
  return { message: "Function working!" };
});





/*exports.analyzeContract = onCall(async (request) => {
  try {
    const { documentId, contractText } = request.data;

    if (!documentId && !contractText) {
      throw new HttpsError(
        "invalid-argument",
        "Either documentId or contractText is required"
      );
    }

    let extractedText = contractText;
    
    console.log("Incoming data:", request.data);

  
    if (!extractedText && documentId) {
      const docRef = db.collection("documents").doc(documentId);
      const docSnap = await docRef.get();

      if (!docSnap.exists) {
        throw new HttpsError("not-found", "Document not found");
      }

      const { filePath } = docSnap.data();
      const file = storage.bucket().file(filePath);
      const [buffer] = await file.download();

      const pdfData = await pdfParse(buffer);
      extractedText = pdfData.text;
      
    }


    const mockAnalysis = {
      summary:
        "This is a standard contract agreement between parties with defined terms and conditions.",
      riskyClauses: [
        "Limitation of Liability clause may restrict your remedies",
        "Termination clause allows either party to exit with 30 days notice",
      ],
      riskLevel: "medium",
      explanation:
        "The contract contains typical commercial terms. The main risks involve liability limitations and termination conditions.",
    };

    if (documentId) {
      await db.collection("documents").doc(documentId).update({
        status: "completed",
        analysis: mockAnalysis,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    return {
      status: "completed",
      analysis: mockAnalysis,
    };

  } catch (error) {
    console.error("Analyze function error:", error);
    throw new HttpsError("internal", error.message);
  }
});
*/
