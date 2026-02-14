/**
 * Middleware to verify Firebase Authentication tokens in incoming requests.
 * This function extracts the ID token from the Authorization header,
 * verifies it using Firebase Admin SDK, and returns the decoded user information.
 */

const { auth } = require("../config/firebase");

async function verifyAuth(req) {
  const idToken = req.headers.authorization?.split("Bearer ")[1];
  if (!idToken) throw new Error("Unauthorized");

  return await auth.verifyIdToken(idToken);
}

module.exports = verifyAuth;
