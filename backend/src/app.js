const express = require("express");

const app = express();

app.use(express.json());



app.get("/", (_, res) => {
  res.send("api running, new deployment triggered!" );
});

app.get("/health", (_, res) => {
  res.status(200).json({ status: "current version 1 is ok" });
});

module.exports = app;
