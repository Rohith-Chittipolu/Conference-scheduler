const express = require("express");
require("dotenv").config();
const client = require("./config/database");

const { userRouteHandlers } = require("./routes/user");

const app = express();

app.use(express.json({ limit: "200mb" }));

app.use("/api/user", userRouteHandlers);

client
  .connect()
  .then(() => console.log("database connected"))
  .then(() =>
    app.listen(process.env.PORT || 5000, () => console.log("server started"))
  )
  .catch((err) => console.error("database connection error", err.stack));
