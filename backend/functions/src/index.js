/**
 * Firebase Cloud Functions entry point.
 * This file exports all the HTTP functions for handling various routes
 * such as document upload, contract analysis, legal chat, and letter generation.
 */



const {db} = require("./config/firebase");
const functions = require("firebase-functions");

const upload = require("./routes/upload");
const analyze = require("./routes/analyze");
const chat = require("./routes/chat");
const letter = require("./routes/letter");

exports.uploadDocument = functions.https.onRequest(upload);
exports.analyzeContract = functions.https.onRequest(analyze);
exports.legalChat = functions.https.onRequest(chat);
exports.generateLetter = functions.https.onRequest(letter);


exports.testDB = functions.https.onRequest(async (req, res) => {
  await db.collection("test").add({message: "connected"});
  res.send("Firestore working");
});
