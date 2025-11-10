import mysql from 'mysql2/promise';
import dotenv from 'dotenv';

dotenv.config();

async function testConnection() {
  console.log('Testing connection to:', process.env.DB_HOST);
  console.log('Database:', process.env.DB_NAME);
  console.log('User:', process.env.DB_USER);

  try {
    const connection = await mysql.createConnection({
      host: process.env.DB_HOST,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME,
      port: process.env.DB_PORT || 3306
    });

    console.log('✅ Connected!');

    const [rows] = await connection.query('SELECT 1 as test');
    console.log('✅ Query successful:', rows);

    const [menuRows] = await connection.query('SELECT * FROM menu_items LIMIT 1');
    console.log('✅ Menu query successful:', menuRows);

    await connection.end();
    console.log('✅ Connection closed gracefully');

  } catch (err) {
    console.error('❌ Connection Error:', err.message);
    console.error('Error code:', err.code);
    console.error('Error sqlState:', err.sqlState);
  }
}

testConnection();