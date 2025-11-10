// db.js
import mysql from "mysql2/promise";
import dotenv from "dotenv";

dotenv.config(); // Load environment variables

console.log("📡 Connecting to:", process.env.DB_HOST);
console.log("👤 User:", process.env.DB_USER);
console.log("🗄️ Database:", process.env.DB_NAME);

const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  port: process.env.DB_PORT || 3306,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// Optional: quick test when starting
try {
  const connection = await pool.getConnection();
  console.log("✅ Connected to RDS MySQL database (via pool)!");
  connection.release();
} catch (err) {
  console.error("❌ Initial DB connection failed:", err.message);
}

export default pool;