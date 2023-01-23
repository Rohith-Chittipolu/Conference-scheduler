const { Client } = require("pg");

const client = new Client({
  host: "localhost",
  port: 5432,
  database: "nursingconference",
  user: "postgres",
  password: "",
});

module.exports = client;
