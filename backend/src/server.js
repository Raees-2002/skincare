require("dotenv").config();
const app = require("./src/app");

const PORT = process.env.PORT || 5000;

app.get('/version', (req, res) => {
  res.json({
    version: process.env.VERSION || "dev",
    time: new Date()
  })
})

app.listen(PORT, () => {
  console.log(`server started on ${PORT}`);
});
