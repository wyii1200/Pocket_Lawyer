/**
 * Utility to parse risk analysis responses from AI.
 */

function parseRiskResponse(aiText) {
  let riskLevel = "medium";

  if (aiText.toLowerCase().includes("high risk")) {
    riskLevel = "high";
  } else if (aiText.toLowerCase().includes("low risk")) {
    riskLevel = "low";
  }

  return {
    riskLevel,
    fullAnalysis: aiText,
  };
}

module.exports = {parseRiskResponse};
