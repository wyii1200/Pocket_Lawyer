const {GoogleGenerativeAI} = require("@google/generative-ai");

let model = null;

const getModel = () => {
  if (!model) {
    const apiKey = process.env.GEMINI_API_KEY || "demo-key-for-emulator";
    const genAI = new GoogleGenerativeAI(apiKey);
    model = genAI.getGenerativeModel({model: "gemini-2.5-pro"});
  }
  return model;
};

// For testing purposes, we can mock the AI response when running in the emulator
async function generateAIResponse(prompt) {
  if (process.env.FUNCTIONS_EMULATOR) {
    return "Mock AI reply for emulator testing.";
  }

  const model = getModel();
  const result = await model.generateContent(prompt);
  const response = await result.response;
  return response.text();
}

module.exports = {getModel, generateAIResponse};
