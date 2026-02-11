/**
 * Service to retrieve relevant legal laws from Firestore for RAG.
 * This module fetches law snippets to provide context for legal AI responses.
 *
 */

const {db} = require("../config/firebase");

async function retrieveRelevantLaws(limit = 5) {
  const snapshot = await db.collection("laws").limit(limit).get();

  let context = "";
  const references = [];

  snapshot.forEach((doc) => {
    const data = doc.data();
    context += data.content + "\n";
    references.push({
      title: data.title,
      section: data.section,
    });
  });

  return {context, references};
}

module.exports = {retrieveRelevantLaws};
