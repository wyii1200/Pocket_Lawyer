/*
* Legal chat route for Firebase Cloud Functions.
* This function handles user messages, retrieves relevant legal context from Firestore, 
* sends the combined prompt to Google Generative AI, and returns the AI-generated reply.
*/

// const admin = require("firebase-admin");
// const functions = require("firebase-functions");
// const { db, storage } = require("../config/firebase");
// //const { verifyAuth } = require("../middleware/auth");
// //const getModel = require("../config/gemini");
// //const pdfParse = require("pdf-parse");


// const { generateAIResponse } = require("../services/geminiService");

// exports.legalChat = functions.https.onCall(async (data, context) => {
//   try {
//     const { message } = data;

//     if (!message) {
//       throw new functions.https.HttpsError(
//         "invalid-argument",
//         "Message is required"
//       );
//     }

//     const prompt = `
// You are a professional Malaysian legal assistant.

// Provide:
// - Clear explanation
// - Mention relevant Malaysian Acts if applicable
// - Keep language simple
// - Add a short legal reference line at the end

// User Question:
// ${message}
// `;

//     const aiReply = await generateAIResponse(prompt);

//     return {
//       reply: aiReply,
//       legalRef: "Malaysian Legal Framework"
//     };

//   } catch (error) {
//     console.error("legalChat error:", error);
//     throw new functions.https.HttpsError(
//       "internal",
//       error.message
//     );
//   }
// });


/*exports.legalChat = functions.https.onRequest(async (req, res) => {
  try {
    const { message } = req.body;

    if (!message) {
      return res.status(400).json({ error: "message is required" });
    }

    // Mock response for testing
    const mockReplies = {
      "rights": "In Malaysia, you have several rights under  the Contracts Act 1950. These include the right to enter into a binding contract, the right to interpretation of contract terms in your favor (when ambiguous), and the right to remedies for breach of contract.",
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

const admin = require("firebase-admin");
const functions = require("firebase-functions");
const { GoogleAI } = require("firebase/ai");   // Firebase AI SDK

admin.initializeApp();

// Initialize Firebase AI
const ai = new GoogleAI({
  projectId: process.env.GCLOUD_PROJECT,
});

exports.legalChat = functions.https.onCall(async (data, context) => {
  try {
    const { message } = data;

    if (!message) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Message is required"
      );
    }

    const prompt = `
You are a professional Malaysian legal assistant.

Provide:
- Clear explanation
- Mention relevant Malaysian Acts if applicable
- Keep language simple
- Add a short legal reference line at the end

User Question:
${message}
`;

    // Create Gemini model instance
    const model = ai.getGenerativeModel({
      model: "gemini-2.5-flash",
    });

    // Generate response
    const result = await model.generateContent(prompt);
    const response = await result.response;
    const aiReply = response.text();

    return {
      reply: aiReply,
      legalRef: "Malaysian Legal Framework"
    };

  } catch (error) {
    console.error("legalChat error:", error);
    throw new functions.https.HttpsError(
      "internal",
      error.message
    );
  }
});
