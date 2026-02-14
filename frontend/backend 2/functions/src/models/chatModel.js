/**
 * Model for managing chat messages in Firestore.
 * @params {string} userId - The ID of the user.
 * @params {string} message - The user's message.
 * @params {string} reply - The AI-generated reply.
 * @params {Array} references - Optional references used in generating the reply.
 * @returns {Promise<string>} - The ID of the saved chat message.
 * @returns {Promise<Array>} - List of chat messages for a user.
 *
 */

const {db} = require("../config/firebase");

async function saveChatMessage(userId, message, reply, references = []) {
  const chatRef = db.collection("chats").doc();

  await chatRef.set({
    userId,
    message,
    reply,
    references,
    createdAt: new Date(),
  });

  return chatRef.id;
}

async function getUserChats(userId) {
  const snapshot = await db
    .collection("chats")
    .where("userId", "==", userId)
    .orderBy("createdAt", "desc")
    .get();

  return snapshot.docs.map((doc) => doc.data());
}

module.exports = {saveChatMessage, getUserChats};
