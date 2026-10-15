const express = require("express");
const path = require("path");

const app = express();
const PORT = process.env.PORT || 3000;

// Serve static frontend files
app.use(express.static(path.join(__dirname, "public")));

// Health endpoint for ALB/ECS later
app.get("/health", (req, res) => {
  res.status(200).json({
    status: "healthy",
    application: "retail-banking-frontend",
    environment: process.env.NODE_ENV || "dev"
  });
});

// Start server
app.listen(PORT, "0.0.0.0", () => {
  console.log(`Retail Banking frontend running on port ${PORT}`);
});

