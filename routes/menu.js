const express = require("express");
const router = express.Router();
const pool = require("../db");

// GET all menu items
router.get("/", async (req, res) => {
  try {
    const [rows] = await pool.query("SELECT id, name, price, image FROM menu");
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to fetch menu" });
  }
});

module.exports = router;
