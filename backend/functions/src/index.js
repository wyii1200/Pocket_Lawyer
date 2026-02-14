/**
 * Firebase Cloud Functions entry point.
 * This file exports all the HTTP functions for handling various routes
 * such as document upload, contract analysis, legal chat, and letter generation.
 */

require("dotenv").config();


const {db} = require("./config/firebase");
const functions = require("firebase-functions");

// Import your route handlers - they already export the functions properly
const { uploadDocument } = require("./routes/upload");
const { analyzeContract } = require("./routes/analyze");
const { legalChat } = require("./routes/chat");
const { generateLetter } = require("./routes/letter");

// Export the functions directly
exports.uploadDocument = uploadDocument;
exports.analyzeContract = analyzeContract;
exports.legalChat = legalChat;
exports.generateLetter = generateLetter;

exports.testDB = functions.https.onRequest(async (req, res) => {
  res.send("Firestore working - emulator is responding!");
});
