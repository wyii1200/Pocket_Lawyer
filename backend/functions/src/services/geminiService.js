/**
 * Service to interact with Google Generative AI for content generation.
 * This module provides a function to send prompts to the AI model
 * and retrieve generated responses.
 *
 */


const getAI = require("../config/gemini");

async function generateAIResponse(prompt) {
  const ai = getAI();

  const response = await ai.models.generateContent({
    model: "gemini-2.0-flash",
    contents: prompt,
  });

  // In @google/genai v1.x, response.text is a string directly
  return response.text;
}

module.exports = { generateAIResponse };