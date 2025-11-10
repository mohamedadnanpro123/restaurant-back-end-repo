const express = require("express");
const router = express.Router();
const pool = require("../db");
const jwt = require("jsonwebtoken");
const bcrypt = require("bcrypt");
const multer = require("multer");

// Middleware: verify JWT
function verifyToken(req, res, next) {
  const token = req.headers["authorization"]?.split(" ")[1];
  if (!token) return res.status(403).json({ error: "No token provided" });
  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) return res.status(403).json({ error: "Invalid token" });
    req.user = user;
    next();
  });
}

// Multer config for image uploads
const storage = multer.diskStorage({
  destination: "uploads/",
  filename: (req, file, cb) => {
    cb(null, Date.now() + "-" + file.originalname);
  },
});
const upload = multer({ storage });

// Admin login
router.post("/login", async (req, res) => {
  const { username, password } = req.body;
  try {
    const [rows] = await pool.query("SELECT * FROM admins WHERE username = ?", [username]);
    if (rows.length === 0) return res.status(401).json({ error: "User not found" });

    const match = await bcrypt.compare(password, rows[0].password);
    if (!match) return res.status(401).json({ error: "Wrong password" });

    const token = jwt.sign(
      { id: rows[0].id, username },
      process.env.JWT_SECRET,
      { expiresIn: "1h" }
    );
    res.json({ token });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Login failed" });
  }
});

// Create new menu item (with image upload)
router.post("/menu", verifyToken, upload.single("image"), async (req, res) => {
  const { name, price } = req.body;
  const imagePath = req.file ? `/uploads/${req.file.filename}` : null;

  try {
    const [result] = await pool.query(
      "INSERT INTO menu (name, price, image) VALUES (?, ?, ?)",
      [name, price, imagePath]
    );
    res.json({ id: result.insertId, name, price, image: imagePath });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to add menu item" });
  }
});

module.exports = router;
