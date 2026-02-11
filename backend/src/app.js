const express = require("express");

const app = express();

app.use(express.json());

app.get("/", (_, res) => {
  res.send("api running");
});

app.get('/health', (req, res) => {
  res.status(500).send('fail');
});


module.exports = app;
