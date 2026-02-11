/**
 * Letter generation route for Firebase Cloud Functions.
 * This function generates formal letters based on user-provided templates and data
 * using Google Generative AI, and stores the generated letters in Firestore.
 */

const admin = require("firebase-admin");
const functions = require("firebase-functions");
const { db, storage } = require("../config/firebase");
const { verifyAuth } = require("../middleware/auth");
const { model } = require("../config/gemini");
const pdfParse = require("pdf-parse");

exports.generateLetter = functions.https.onRequest(async (req, res) => {
  try {
    const user = await verifyAuth(req);
    const {templateId, userData} = req.body;

    const prompt = `
    Generate a formal ${templateId} letter.
    Use Malaysian legal tone.
    
    Details:
    ${JSON.stringify(userData)}
    `;

    const result = await model.generateContent(prompt);
    const response = await result.response;
    const letterText = response.text();

    const docRef = db.collection("letters").doc();

    await docRef.set({
      userId: user.uid,
      templateId,
      letterText,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    res.json({letterText});
  } catch (error) {
    res.status(500).json({error: error.message});
  }
});
