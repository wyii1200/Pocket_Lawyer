/*
* Legal chat route for Firebase Cloud Functions.
* This function handles user messages, retrieves relevant legal context from Firestore, 
* sends the combined prompt to Google Generative AI, and returns the AI-generated reply.
*/


//use v2 of firebase functions for better error handling and auth support
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { generateAIResponse } = require("../services/geminiService");

exports.legalChat = onCall(
  { region: "us-central1" },
  async (request) => {
    console.log("LEGAL CHAT CALLED");
    console.log("DATA:", request.data);
    console.log("AUTH:", request.auth);

    // Safety check
    if (!request.data) {
      throw new HttpsError("invalid-argument", "No data received");
    }

    const message = request.data.message;
    const lang = request.data.lang || "en";

    if (!message || message.trim() === "") {
      throw new HttpsError("invalid-argument", "Message is required");
    }

    try {
      const prompt = `
      You are a legal assistant.
      Language: ${lang}
      User Question: ${message}
      Provide general legal information only.
      `;

      const reply = await generateAIResponse(prompt);

      return {
        reply: reply,
        legalRef: "Contracts Act 1950 (Malaysia)"
      };

    } catch (error) {
      console.error("AI ERROR:", error);
      throw new HttpsError("internal", "AI processing failed");
    }
  }
);

/*exports.legalChat = functions.https.onRequest(async (req, res) => {
  try {
    const { message } = req.body;

    if (!message) {
      return res.status(400).json({ error: "message is required" });
    }

    // Mock response for testing
    const mockReplies = {
      "rights": "In Malaysia, you have several rights under the Contracts Act 1950. These include the right to enter into a binding contract, the right to interpretation of contract terms in your favor (when ambiguous), and the right to remedies for breach of contract.",
      "contract": "A contract is a legally binding agreement between two or more parties. In Malaysia, contracts are governed by the Contracts Act 1950. The essential elements are offer, acceptance, consideration, and intention to create legal relations.",
      "default": "I'm a legal assistant trained on Malaysian law. I can help you understand contracts, consumer rights, employment law, and other legal matters. Please ask your question clearly."
    };

    // Find the closest matching reply based on keywords
    let reply = mockReplies.default;
    if (message.toLowerCase().includes("right")) {
      reply = mockReplies.rights;
    } else if (message.toLowerCase().includes("contract")) {
      reply = mockReplies.contract;
    }

    // Try to save to Firestore if available
    try {
      await db.collection("chats").add({
        userId: "anonymous",
        message,
        reply,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    } catch (saveError) {
      console.warn("Could not save chat to Firestore:", saveError.message);
    }

    res.status(200).json({ reply });
  } catch (error) {
    console.error("Chat function error:", error);
    res.status(500).json({ error: error.message });
  }
});*/