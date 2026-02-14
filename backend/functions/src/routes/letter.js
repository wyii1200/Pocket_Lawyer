/**
 * Letter generation route for Firebase Cloud Functions.
 * This function generates formal letters based on user-provided templates and data
 * using Google Generative AI, and stores the generated letters in Firestore.
 */


const functions = require("firebase-functions");
const { admin, db, storage } = require("../config/firebase");

let openai = null;

const getOpenAI = () => {
  if (!openai && process.env.OPENAI_API_KEY) {
    const { OpenAI } = require("openai");
    openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });
  }
  return openai;
};

// Mock templates for testing
const mockTemplates = {
  complaint: `Dear {{recipientName}},

I am writing to lodge a formal complaint regarding {{issueDescription}}.

This matter occurred on {{date}} and has caused {{impact}}.

I kindly request {{request}} within {{timeframe}} days.

Yours faithfully,
{{senderName}}`,

  demand: `To: {{recipientName}}
Date: {{date}}

RE: FORMAL DEMAND FOR {{demandType}}

This is a formal demand for {{demandDescription}}.

Amount: {{amount}}
Due Date: {{dueDate}}

Please remit payment by {{paymentDeadline}} or further action will be taken.

{{senderName}}`,

  agreement: `AGREEMENT

This Agreement is made between:
- {{party1Name}} ("Party 1")
- {{party2Name}} ("Party 2")

Effective Date: {{effectiveDate}}

TERMS:
1. {{term1}}
2. {{term2}}
3. {{term3}}

Signed: 
Party 1: _________________
Party 2: _________________`
};


const { onCall, HttpsError } = require("firebase-functions/v2/https");

exports.generateLetter = onCall(async (request) => {
  const { templateId, templateContent, userData } = request.data;

  if (!userData) {
    throw new HttpsError("invalid-argument", "userData is required");
  }

  let letterText = templateContent;

  if (!letterText) {
    letterText = mockTemplates[templateId?.toLowerCase()];
    if (!letterText) {
      throw new HttpsError("not-found", "Template not found");
    }
  }

  for (const key in userData) {
    const regex = new RegExp(`{{${key}}}`, "g");
    letterText = letterText.replace(regex, userData[key]);
  }

  return { letterText };
});


