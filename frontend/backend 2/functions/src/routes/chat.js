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

exports.legalChat = onCall(async (request) => {
  // Check if user is logged in
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "The function must be called while authenticated.");
  }

  try {
    const { message } = request.data; // Flutter sends data here

    const lawsSnapshot = await db.collection("laws").limit(5).get();
    let context = "";
    lawsSnapshot.forEach((doc) => {
      context += doc.data().content + "\n";
    });

    const prompt = `You are a Malaysian legal assistant. Answer ONLY based on provided laws.\nContext:\n${context}\nQuestion:\n${message}`;

    const result = await model.generateContent(prompt);
    const response = await result.response;
    const reply = response.text();

    await db.collection("chats").add({
      userId: request.auth.uid,
      message,
      reply,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return { reply }; // Send directly back to Flutter
  } catch (error) {
    throw new HttpsError("internal", error.message);
  }
});