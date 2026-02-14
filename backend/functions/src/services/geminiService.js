/**
 * Service to interact with Google Generative AI for content generation.
 * This module provides a function to send prompts to the AI model
 * and retrieve generated responses.
 *
 */


const getModel = require("../config/gemini");

async function generateAIResponse(prompt) {
  const model = getModel();
  const result = await model.generateContent(prompt);

  const response = await result.response;
  return response.text();
}

module.exports = {generateAIResponse};
