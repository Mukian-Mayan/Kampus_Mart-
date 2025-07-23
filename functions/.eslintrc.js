module.exports = {
  env: {
    es6: true,
    node: true,
  },
  parserOptions: {
    ecmaVersion: 2020, // Updated to support modern JS features
    sourceType: "module", // Added to support ES modules
  },
  extends: [
    "eslint:recommended",
    "google",
  ],
  rules: {
    "no-restricted-globals": ["error", "name", "length"],
    "prefer-arrow-callback": "error",
    "quotes": ["error", "double", {"allowTemplateLiterals": true}],
    "indent": ["error", 2], // Consistent with Google style
    "max-len": ["error", {"code": 80}], // Google style line length
  },
  overrides: [
    {
      files: ["**/*.spec.*"],
      env: {
        mocha: true,
      },
      rules: {
        "max-len": "off", // Allow longer lines in test files
      },
    },
  ],
  globals: {
    // Add any global variables your project uses
  },
};