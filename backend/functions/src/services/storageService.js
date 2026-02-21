/**
 * Service for uploading files to Google Cloud Storage.
 * This module provides a function to upload a buffer
 * to a specified path in Firebase Storage and returns the public URL.
 */

const {storage} = require("../config/firebase");

async function uploadBuffer(buffer, filePath) {
  const bucket = storage.bucket();
  const file = bucket.file(filePath);

  await file.save(buffer);

  //await file.makePublic();


  return `http://localhost:9199/${bucket.name}/${filePath}`;

  //return `https://storage.googleapis.com/${bucket.name}/${filePath}`;
}

module.exports = {uploadBuffer};
