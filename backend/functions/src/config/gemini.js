const {GoogleGenerativeAI} = require("@google/generative-ai");

let model = null;

const getModel = () => {
  if (!model) {
    const apiKey = process.env.GEMINI_API_KEY || "demo-key-for-emulator";
    const genAI = new GoogleGenerativeAI(apiKey);
    model = genAI.getGenerativeModel({model: "gemini-1.5-pro"});
  }
  return model;
};

module.exports = getModel;
