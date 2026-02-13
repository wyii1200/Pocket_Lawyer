/*
* Legal chat route for Firebase Cloud Functions.
* This function handles user messages, retrieves relevant legal context from Firestore, 
* sends the combined prompt to Google Generative AI, and returns the AI-generated reply.
*/

const admin = require("firebase-admin");
const functions = require("firebase-functions");
const { db, storage } = require("../config/firebase");
const { verifyAuth } = require("../middleware/auth");
const getModel = require("../config/gemini");
const pdfParse = require("pdf-parse");

exports.legalChat = functions.https.onRequest(async (req, res) => {
  try {
    const { message } = req.body;

    const lawsSnapshot = await db.collection("laws").limit(5).get();
    let context = "";
    lawsSnapshot.forEach((doc) => {
      context += doc.data().content + "\n";
    });

    const prompt = `You are a Malaysian legal assistant. Answer ONLY based on provided laws.\nContext:\n${context}\nQuestion:\n${message}`;

    const model = getModel();
    const result = await model.generateContent(prompt);
    const response = await result.response;
    const reply = response.text();

    await db.collection("chats").add({
      userId: "anonymous",
      message,
      reply,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    res.status(200).json({ reply });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});