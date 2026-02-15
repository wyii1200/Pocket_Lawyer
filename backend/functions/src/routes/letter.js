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

This is a formal demand for {{demandDescription}}


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




/*exports.generateLetter = functions.https.onRequest(async (req, res) => {
  try {
    const { templateId, templateContent, userData } = req.body;

    if (!userData) {
      return res.status(400).json({ error: "userData is required" });
    }

    let letterText = templateContent;

    // If no direct template content, try to fetch from mock templates
    if (!letterText) {
      if (!templateId) {
        return res.status(400).json({ error: "Either templateId or templateContent is required" });
      }
      letterText = mockTemplates[templateId.toLowerCase()];
      if (!letterText) {
        return res.status(404).json({ 
          error: `Template not found. Available templates: ${Object.keys(mockTemplates).join(', ')}` 
        });
      }
    }

    // Replace placeholders with userData
    for (const key in userData) {
      const regex = new RegExp(`{{${key}}}`, "g");
      letterText = letterText.replace(regex, userData[key]);
    }

    // Try to save to Firestore if available
    try {
      await db.collection("letters").add({
        templateId,
        userData,
        letterText,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    } catch (dbError) {
      console.warn("Could not save letter to Firestore:", dbError.message);
    }

    res.status(200).json({ 
      letterText,
      message: "Letter generated successfully"
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});*/

