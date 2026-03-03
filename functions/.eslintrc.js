module.exports = {
  root: true,
  env: { es2022: true, node: true, jest: true },
  extends: [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended",
  ],
  parser: "@typescript-eslint/parser",
  parserOptions: { project: ["tsconfig.json"], sourceType: "module" },
  plugins: ["@typescript-eslint"],
  rules: {
    "@typescript-eslint/no-explicit-any": "warn",
    "@typescript-eslint/no-unused-vars": ["warn", { argsIgnorePattern: "^_" }],
    "no-console": "off",
  },
  ignorePatterns: ["/lib/**/*", "/node_modules/**/*"],
};
