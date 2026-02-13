/**
 * Letter generation route for Firebase Cloud Functions.
 * This function generates formal letters based on user-provided templates and data
 * using Google Generative AI, and stores the generated letters in Firestore.
 */


const functions = require("firebase-functions");
const { admin, storage } = require("../config/firebase");

let openai = null;

const getOpenAI = () => {
  if (!openai && process.env.OPENAI_API_KEY) {
    const { OpenAI } = require("openai");
    openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });
  }
  return openai;
};

const bucket = storage.bucket();

exports.generateLetter = functions.https.onRequest(async (req, res) => {
  try {
    const { templateId, userData } = req.body;

    // 1️⃣ Fetch template from Storage
    const file = bucket.file(`templates/${templateId}.txt`);
    const templateContent = (await file.download())[0].toString("utf8");

    // 2️⃣ Replace placeholders
    let letterText = templateContent;
    for (const key in userData) {
      const regex = new RegExp(`{{${key}}}`, "g");
      letterText = letterText.replace(regex, userData[key]);
    }

    // 3️⃣ Optional AI enhancement (RAG)
    // For example, generate formal wording using OpenAI
    // const aiResponse = await openai.chat.completions.create({
    //   model: "gpt-4",
    //   messages: [
    //     { role: "system", content: "You are a professional legal letter writer." },
    //     { role: "user", content: letterText }
    //   ]
    // });
    // letterText = aiResponse.choices[0].message.content;

    res.status(200).json({ letterText });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

