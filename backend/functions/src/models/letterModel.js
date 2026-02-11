/**
 * Model for managing letters in Firestore.
 * @params {string} userId - The ID of the user.
 * @params {string} templateId - The ID of the letter template used.
 * @params {string} letterText - The generated letter text.
 * @params {string} pdfUrl - The URL of the stored PDF version of the letter.
 * @returns {Promise<string>} - The ID of the saved letter.
 *
 */


const {db} = require("../config/firebase");

async function saveLetter(userId, templateId, letterText, pdfUrl) {
  const letterRef = db.collection("letters").doc();

  await letterRef.set({
    userId,
    templateId,
    letterText,
    pdfUrl,
    createdAt: new Date(),
  });

  return letterRef.id;
}

module.exports = {saveLetter};
