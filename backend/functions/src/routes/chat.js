/*
* Legal chat route for Firebase Cloud Functions.
* This function handles user messages, retrieves relevant legal context from Firestore, 
* sends the combined prompt to Google Generative AI, and returns the AI-generated reply.
*/

const admin = require("firebase-admin");
const functions = require("firebase-functions");
const { db, storage } = require("../config/firebase");
const { verifyAuth } = require("../middleware/auth");
const { model } = require("../config/gemini");
const pdfParse = require("pdf-parse");

exports.legalChat = functions.https.onRequest(async (req, res) => {
  try {
    const user = await verifyAuth(req);
    const {message} = req.body;

    // 🔹 Simple RAG – fetch relevant law snippets
    const lawsSnapshot = await db.collection("laws")
      .limit(5)
      .get();

    let context = "";
    lawsSnapshot.forEach((doc) => {
      context += doc.data().content + "\n";
    });

    const prompt = `
    You are a Malaysian legal assistant.
    Answer ONLY based on provided laws.
    
    Context:
    ${context}
    
    Question:
    ${message}
    `;

    const result = await model.generateContent(prompt);
    const response = await result.response;
    const reply = response.text();

    await db.collection("chats").add({
      userId: user.uid,
      message,
      reply,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    res.json({reply});
  } catch (error) {
    res.status(500).json({error: error.message});
  }
});
