/*
* Legal chat route for Firebase Cloud Functions.
* This function handles user messages, retrieves relevant legal context from Firestore, 
* sends the combined prompt to Google Generative AI, and returns the AI-generated reply.
*/


const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { generateAIResponse } = require("../services/geminiService");

exports.legalChat = onCall(
  { region: "us-central1" },
  async (request) => {
    console.log("LEGAL CHAT CALLED", request.data);

    const message = request.data?.message;
    const lang = request.data?.lang || "en";

    if (!message || message.trim() === "") {
      throw new HttpsError("invalid-argument", "Message is required");
    }

    const langInstruction = lang === "en"
      ? "Respond in English."
      : "Respond in Bahasa Malaysia.";

    const prompt = `You are a helpful Malaysian legal assistant. You provide general legal information based on Malaysian law.

Important guidelines:
- Only provide general legal information, NOT specific legal advice
- Always reference relevant Malaysian laws where applicable (e.g. Contracts Act 1950, Employment Act 1955, National Land Code 1965)
- End your response with a "Legal Reference:" line citing the most relevant Malaysian law(s)
- Recommend consulting a licensed lawyer or the Legal Aid Bureau (Biro Bantuan Guaman) for specific advice
- ${langInstruction}
- Keep responses clear and concise

User question: ${message}

Format your response as JSON with exactly these two fields:
{
  "reply": "your response here",
  "legalRef": "relevant Malaysian law(s) here"
}
Return only the JSON, no markdown, no extra text.`;

    let result;
    try {
      const raw = await generateAIResponse(prompt);
      const cleaned = raw.replace(/```json|```/g, "").trim();
      result = JSON.parse(cleaned);
    } catch (err) {
      console.error("Gemini legal chat failed:", err);
      throw new HttpsError("internal", "Failed to generate legal response. Please try again.");
    }

    if (!result?.reply) {
      throw new HttpsError("internal", "AI returned an unexpected response format.");
    }

    return {
      reply: result.reply,
      legalRef: result.legalRef || "General Malaysian Law",
    };
  }
);