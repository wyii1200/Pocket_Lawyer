/**
 *  Service for extracting text from PDF documents.
 * This module uses pdf-parse to extract and return text content
 * from a given PDF buffer.
 *
 */


const pdfParse = require("pdf-parse");

async function extractTextFromPDF(buffer) {
  const data = await pdfParse(buffer);
  return data.text;
}

module.exports = {extractTextFromPDF};
