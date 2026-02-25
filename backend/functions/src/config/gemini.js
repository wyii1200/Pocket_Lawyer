
const { GoogleGenAI } = require("@google/genai");

const API_KEY = process.env.GEMINI_API_KEY;
let ai = null;


const getAI = () => {
  if (!ai) {
    console.log("API KEY BEING USED:", process.env.GEMINI_API_KEY?.substring(0, 10) + "...");
    ai = new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY
     });
  }
  return ai;
};

module.exports = getAI;