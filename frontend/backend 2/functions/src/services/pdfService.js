/**
 * Service to generate PDFs and upload them to cloud storage.
 * This module creates a PDF from given text content,
 * uploads it to Firebase Storage, and returns the file URL.
 *
 */

const PDFDocument = require("pdfkit");
const {uploadBuffer} = require("./storageService");

async function generatePDF(userId, letterText) {
  const doc = new PDFDocument();
  const chunks = [];

  doc.on("data", (chunk) => chunks.push(chunk));
  doc.text(letterText);
  doc.end();

  return new Promise((resolve) => {
    doc.on("end", async () => {
      const pdfBuffer = Buffer.concat(chunks);
      const filePath = `letters/${userId}-${Date.now()}.pdf`;

      const url = await uploadBuffer(pdfBuffer, filePath);
      resolve(url);
    });
  });
}

module.exports = {generatePDF};
