/**
 * Letter generation route for Firebase Cloud Functions.
 * This function generates formal letters based on user-provided templates and data
 * using Google Generative AI, and stores the generated letters in Firestore.
 */



const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { generateAIResponse } = require("../services/geminiService");

const mockTemplates = {
  complaint: `Dear {{recipientName}},

I am writing to lodge a formal complaint regarding {{issue}}.

This matter occurred on {{date}}.

I kindly request your immediate attention to this matter.

Yours faithfully,
{{userName}}`,

  demand: `To: {{recipientName}}
Date: {{date}}

RE: FORMAL LETTER OF DEMAND

This is a formal demand regarding {{issue}}.

Please resolve this matter promptly or further action will be taken.

Yours faithfully,
{{userName}}`,

  notice: `To: {{recipientName}}
Date: {{date}}

RE: FORMAL NOTICE

Please be advised that {{issue}}.

This notice requires your immediate attention.

Yours faithfully,
{{userName}}`,
};

exports.generateLetter = onCall({ region: "us-central1" }, async (request) => {
  console.log("=== generateLetter called ===");
  console.log("request.data:", JSON.stringify(request.data));

  const { templateId, templateContent, userData } = request.data;

  if (!userData || Object.keys(userData).length === 0) {
    throw new HttpsError("invalid-argument", "userData is required and cannot be empty");
  }

  if (!templateId && !templateContent) {
    throw new HttpsError("invalid-argument", "Either templateId or templateContent must be provided");
  }

  let templateText = templateContent;
  if (!templateText) {
    templateText = mockTemplates[templateId?.toLowerCase()];
    if (!templateText) {
      throw new HttpsError(
        "not-found",
        `Template "${templateId}" not found. Available templates: ${Object.keys(mockTemplates).join(", ")}`
      );
    }
  }

  let filledTemplate = templateText;
  const placeholderRegex = /{{(\w+)}}/g;
  const requiredFields = [...templateText.matchAll(placeholderRegex)].map((m) => m[1]);
  const missingFields = requiredFields.filter((field) => !(field in userData));

  if (missingFields.length > 0) {
    throw new HttpsError(
      "invalid-argument",
      `Missing required fields: ${missingFields.join(", ")}`
    );
  }

  for (const key in userData) {
    const regex = new RegExp(`{{${key}}}`, "g");
    filledTemplate = filledTemplate.replace(regex, userData[key]);
  }

  const prompt = `You are a professional legal letter writer.

Below is a pre-filled letter template. Your task is to:
- Improve the language to be formal, clear, and professional
- Fix any grammar or phrasing issues
- Keep ALL the specific details, names, dates, and facts exactly as provided
- Do NOT add new facts or legal advice not already present
- Return ONLY the final letter text, with no commentary, preamble, or markdown formatting

--- TEMPLATE ---
${filledTemplate}
--- END TEMPLATE ---`;

  let letterText;
  try {
    letterText = await generateAIResponse(prompt);
  } catch (err) {
    console.error("Gemini generation failed:", err);
    throw new HttpsError("internal", "Failed to generate letter via AI. Please try again later.");
  }

  if (!letterText || letterText.trim() === "") {
    throw new HttpsError("internal", "AI returned an empty response. Please try again.");
  }

  return {
    letterText: letterText.trim(),
    templateUsed: templateId || "custom",
    generatedAt: new Date().toISOString(),
  };
});