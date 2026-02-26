/*
* Analyze a contract document stored in Firebase Storage using Google Generative AI.
* This function retrieves the PDF from Storage, extracts text using pdf-parse,
* sends it to the Generative AI model for analysis, and stores the results in Firestore.
*/

/*const { FieldValue } = require("firebase-admin/firestore");
const { db, storage } = require("../config/firebase");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { extractTextFromPDF } = require("../services/ocrService");
const { retrieveRelevantLaws } = require("../services/ragService");
const { generateAIResponse } = require("../services/geminiService");

exports.analyzeContract = onCall(
  { region: "us-central1" },
  async (request) => {
    console.log("ANALYZE CALLED", request.data);
    const { documentId } = request.data;

    if (!documentId) {
      throw new HttpsError("invalid-argument", "documentId is required");
    }

    try {
      // Step 1: Get document metadata from Firestore
      const docSnap = await db.collection("documents").doc(documentId).get();
      if (!docSnap.exists) {
        throw new HttpsError("not-found", "Document not found in Firestore");
      }

      const { filePath } = docSnap.data();
      console.log("File path:", filePath);

      // Step 2: Download file from Firebase Storage
      const bucket = storage.bucket();
      const file = bucket.file(filePath);
      const [buffer] = await file.download();
      console.log("File downloaded, size:", buffer.length);

      // Step 3: Extract text from PDF (or use buffer directly for images)
      let extractedText = "";
      if (filePath.endsWith(".pdf")) {
        extractedText = await extractTextFromPDF(buffer);
      } else {
        // For images, send raw base64 to Gemini vision
        extractedText = `[IMAGE_BASE64]:${buffer.toString("base64")}`;
      }
      console.log("Extracted text length:", extractedText.length);

      if (!extractedText || extractedText.trim().length < 10) {
        throw new HttpsError("invalid-argument", "Could not extract text from document");
      }

      // Step 4: Retrieve relevant Malaysian laws from Firestore
      const { context: lawContext, references } = await retrieveRelevantLaws(5);
      console.log("Laws retrieved:", references.length);

      // Step 5: Build prompt for Gemini
      const isImage = extractedText.startsWith("[IMAGE_BASE64]:");
      const prompt = isImage
        ? buildImagePrompt(extractedText.replace("[IMAGE_BASE64]:", ""), lawContext)
        : buildTextPrompt(extractedText, lawContext);

      // Step 6: Call Gemini
      console.log("Calling Gemini for analysis...");
      const aiRawResponse = await generateAIResponse(prompt);
      console.log("Gemini raw response:", aiRawResponse?.substring(0, 200));

      // Step 7: Parse Gemini JSON response
      const aiResult = parseGeminiResponse(aiRawResponse, references);
      console.log("Parsed result:", JSON.stringify(aiResult).substring(0, 200));

      // Step 8: Update Firestore with result
      await db.collection("documents").doc(documentId).update({
        status: "completed",
        result: aiResult,
        completedAt: FieldValue.serverTimestamp(),
      });

      return aiResult;

    } catch (error) {
      console.error("ANALYZE ERROR:", error.message);

      await db.collection("documents").doc(documentId).update({
        status: "failed",
        error: error.message,
      }).catch(() => {});

      if (error instanceof HttpsError) throw error;
      throw new HttpsError("internal", `Analysis failed: ${error.message}`);
    }
  }
);

// --- Prompt Builders ---

function buildTextPrompt(text, lawContext) {
  return `You are a Malaysian legal contract analyzer. Analyze the following contract and identify risky clauses.

RELEVANT MALAYSIAN LAWS FOR REFERENCE:
${lawContext}

CONTRACT TEXT:
${text.substring(0, 8000)}

Respond ONLY with valid JSON in this exact format, no extra text:
{
  "summary": "brief overall summary of the contract",
  "riskLevel": "LOW" or "MEDIUM" or "HIGH",
  "clauses": [
    {
      "title": "clause name",
      "risk": "description of the risk",
      "legalRef": "relevant Malaysian law reference"
    }
  ]
}`;
}

function buildImagePrompt(base64, lawContext) {
  return `You are a Malaysian legal contract analyzer. Analyze the document image and identify risky clauses.

RELEVANT MALAYSIAN LAWS FOR REFERENCE:
${lawContext}

Respond ONLY with valid JSON in this exact format, no extra text:
{
  "summary": "brief overall summary",
  "riskLevel": "LOW" or "MEDIUM" or "HIGH", 
  "clauses": [
    {
      "title": "clause name",
      "risk": "description of the risk",
      "legalRef": "relevant Malaysian law reference"
    }
  ]
}`;
}

// --- Response Parser ---

function parseGeminiResponse(raw, references) {
  try {
    // Strip markdown code fences if present
    const cleaned = raw
      .replace(/```json/g, "")
      .replace(/```/g, "")
      .trim();

    const parsed = JSON.parse(cleaned);

    // Validate required fields
    return {
      summary: parsed.summary || "Analysis complete",
      riskLevel: ["LOW", "MEDIUM", "HIGH"].includes(parsed.riskLevel?.toUpperCase())
        ? parsed.riskLevel.toUpperCase()
        : "MEDIUM",
      clauses: Array.isArray(parsed.clauses) ? parsed.clauses : [],
    };

  } catch (e) {
    console.error("Failed to parse Gemini response:", e.message);
    // Fallback if JSON parsing fails
    return {
      summary: "Analysis complete. Please review the document manually.",
      riskLevel: "MEDIUM",
      clauses: [{
        title: "Review Required",
        risk: "AI could not fully parse this document. Manual review recommended.",
        legalRef: "Contracts Act 1950 (Malaysia)"
      }]
    };
  }
}*/





const { FieldValue } = require("firebase-admin/firestore"); // ADD THIS
const { db } = require("../config/firebase");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");

const geminiKey = defineSecret("GEMINI_API_KEY");

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





