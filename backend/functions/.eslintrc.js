module.exports = {
  env: {
    es6: true,
    node: true,
  },
  parserOptions: {
    "ecmaVersion": 2020,
  },
  extends: [
    "eslint:recommended",
    "google",
  ],
  rules: {
    "no-restricted-globals": ["error", "name", "length"],
    "prefer-arrow-callback": "error",
    "quotes": ["error", "double", {"allowTemplateLiterals": true}],

    // --- Custom Fixes for Pocket Lawyer Project ---

    // 1. Fix the CRLF vs LF issue automatically
    "linebreak-style": 0,

    // 2. Stop requiring JSDoc comments for every single function
    "require-jsdoc": 0,

    // 3. Relax the line length (80 is very short; 120 is standard)
    "max-len": ["error", {"code": 120}],

    // 4. Don't crash on unused variables (just warn)
    "no-unused-vars": "warn",

    // 5. Ignore specific spacing rules that cause 100+ errors
    "object-curly-spacing": 0,
    "indent": ["error", 2], // Standard 2-space indent
    "comma-dangle": 0,
  },
  overrides: [
    {
      files: ["**/*.spec.*"],
      env: {
        mocha: true,
      },
      rules: {},
    },
  ],
  globals: {},
};
