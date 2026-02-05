const express = require("express");

const app = express();

app.use(express.json());

app.get("/", (_, res) => {
  res.send("api running");
});

app.get("/health", (_, res) => {
  res.status(200).json({ status: "ok" });
});

module.exports = app;
