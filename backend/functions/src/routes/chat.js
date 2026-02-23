/*
* Legal chat route for Firebase Cloud Functions.
* This function handles user messages, retrieves relevant legal context from Firestore, 
* sends the combined prompt to Google Generative AI, and returns the AI-generated reply.
*/

//MOCK
const { onCall, HttpsError } = require("firebase-functions/v2/https");

exports.legalChat = onCall(
  { region: "us-central1" },
  async (request) => {
    console.log("LEGAL CHAT CALLED", request.data);

    const message = request.data?.message;
    const lang = request.data?.lang || "en";

    if (!message || message.trim() === "") {
      throw new HttpsError("invalid-argument", "Message is required");
    }

    // Mock responses based on keywords
    const isEn = lang === 'en';
    let reply = "";
    let legalRef = "Contracts Act 1950 (Malaysia)";

    const msg = message.toLowerCase();

    if (msg.includes("tenant") || msg.includes("rent") || msg.includes("penyewa")) {
      reply = isEn
        ? "As a tenant in Malaysia, your key rights include: right to quiet enjoyment of the property, right to receive proper maintenance, protection against unlawful eviction, and right to a written tenancy agreement. The landlord must give reasonable notice before entry."
        : "Sebagai penyewa di Malaysia, hak utama anda termasuk: hak untuk menikmati hartanah dengan aman, hak penyelenggaraan yang betul, perlindungan daripada pengusiran haram, dan hak perjanjian sewa bertulis.";
      legalRef = "Contracts Act 1950 & National Land Code 1965";

    } else if (msg.includes("contract") || msg.includes("terminate") || msg.includes("kontrak")) {
      reply = isEn
        ? "Under the Contracts Act 1950, a contract can be terminated by mutual agreement, breach of contract, frustration of contract, or expiry of term. Early termination without cause may expose you to damages."
        : "Di bawah Akta Kontrak 1950, kontrak boleh ditamatkan melalui persetujuan bersama, kemungkiran kontrak, atau tamat tempoh.";
      legalRef = "Contracts Act 1950, Section 40 & 57";

    } else if (msg.includes("workplace") || msg.includes("dispute") || msg.includes("pekerja")) {
      reply = isEn
        ? "For workplace disputes in Malaysia, you can file a complaint with the Industrial Relations Department (DGIR), the Labour Department, or the Industrial Court. Common issues include unfair dismissal and wage disputes."
        : "Untuk pertikaian tempat kerja di Malaysia, anda boleh membuat aduan kepada Jabatan Hubungan Perusahaan atau Mahkamah Perusahaan.";
      legalRef = "Employment Act 1955 & Industrial Relations Act 1967";

    } else {
      reply = isEn
        ? `Thank you for your question about "${message}". For specific legal advice in Malaysia, I recommend consulting a licensed lawyer or visiting the Legal Aid Bureau (Biro Bantuan Guaman). Generally, Malaysian law is guided by the Contracts Act 1950, civil law principles, and relevant statutory provisions.`
        : `Terima kasih atas soalan anda. Untuk nasihat undang-undang khusus, sila hubungi peguam berlesen atau Biro Bantuan Guaman Malaysia.`;
      legalRef = "General Malaysian Law";
    }

    return { reply, legalRef };
  }
);



//USE API KEY FROM ENV VARS FOR BETTER SECURITY
//use v2 of firebase functions for better error handling and auth support
/*const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { generateAIResponse } = require("../services/geminiService");

exports.legalChat = onCall(
  { region: "us-central1" },
  async (request) => {
    console.log("LEGAL CHAT CALLED");
    console.log("DATA:", request.data);

    if (!request.data) {
      throw new HttpsError("invalid-argument", "No data received");
    }

    const message = request.data.message;
    const lang = request.data.lang || "en";

    if (!message || message.trim() === "") {
      throw new HttpsError("invalid-argument", "Message is required");
    }

    try {
      const prompt = `You are a legal assistant for Malaysian law.
Language: ${lang === 'en' ? 'English' : 'Bahasa Malaysia'}
User Question: ${message}
Provide general legal information only. Be concise and helpful.`;

      console.log("Calling Gemini...");
      const reply = await generateAIResponse(prompt);
      console.log("Gemini replied:", reply?.substring(0, 100));

      return {
        reply: reply,
        legalRef: "Contracts Act 1950 (Malaysia)",
      };

    } catch (error) {
      console.error("AI ERROR name:", error.name);
      console.error("AI ERROR message:", error.message);
      console.error("AI ERROR stack:", error.stack);
      throw new HttpsError("internal", `AI processing failed: ${error.message}`);
    }
  }
);*/