/*
Pool for .env vars for the postgres connection - for server.js or alike
*/

const { Pool } = require('pg');
const dotenv = require('dotenv');
const path = require('path'); 

dotenv.config({ path: path.join(__dirname, '../../.env') });

console.log("DB Connection Info:", {
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  port: process.env.DB_PORT,
});

const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT,
});

module.exports = pool;