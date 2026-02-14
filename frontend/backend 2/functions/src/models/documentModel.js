/**
 * Model for managing documents in Firestore.
 * @params {Object} data - Document data to be saved.
 * @returns {Promise<string>} - The ID of the created document.
 * @returns {Promise<void>} - Resolves when the document is updated.
 * @returns {Promise<Object|null>} - The document data or null if not found.
 *
 */

const {db} = require("../config/firebase");

async function createDocument(data) {
  const docRef = db.collection("documents").doc();
  await docRef.set({
    ...data,
    createdAt: new Date(),
  });
  return docRef.id;
}

async function updateDocument(documentId, data) {
  return db.collection("documents").doc(documentId).update(data);
}

async function getDocument(documentId) {
  const doc = await db.collection("documents").doc(documentId).get();
  return doc.exists ? doc.data() : null;
}

module.exports = {createDocument, updateDocument, getDocument};
