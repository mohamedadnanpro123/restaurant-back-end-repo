import dotenv from "dotenv";
import nodemailer from 'nodemailer';
import express from "express";
import multer from "multer";
import cors from "cors";
import { S3Client, PutObjectCommand } from "@aws-sdk/client-s3";
import pool from "./db.js";
import jwt from 'jsonwebtoken';
dotenv.config();
// Production deployment test - December 15, 2025
// Debug: Check environment variables
console.log("🔍 Environment Variables Check:");
console.log("DB_HOST:", process.env.DB_HOST);
console.log("DB_USER:", process.env.DB_USER);
console.log("DB_NAME:", process.env.DB_NAME);
console.log("DB_PORT:", process.env.DB_PORT);
console.log('🚀 CICD TEST - Production deployment via github actions using docker image - ' + new Date().toISOString());
const app = express();
app.set('trust proxy', true);
const PORT = process.env.PORT || 5000;
app.use(cors({
  origin: ['https://app.restaurantsolutions.shop','http://localhost:3000','https://www.restaurantsolutions.shop', 'http://localhost:5000','https://restaurantsolutions.shop','https://admin.restaurantsolutions.shop'],
  credentials: true
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
// jwt middleware
// JWT Authentication Middleware
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Access token required' });
  }

  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) {
      return res.status(403).json({ error: 'Invalid or expired token' });
    }
    req.user = user;
    next();
  });
};

const requireAdmin = (req, res, next) => {
  if (req.user.role !== 'admin') {
    return res.status(403).json({ error: 'Admin access required' });
  }
  next();
};

// Email Configuration
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.GMAIL_EMAIL,                      // ✅ Changed to GMAIL_EMAIL
    pass: process.env.GMAIL_PASSWORD.replace(/\s/g, '') // ✅ Changed to GMAIL_PASSWORD
  }
});

transporter.verify((error, success) => {
  if (error) {
    console.error("❌ Email configuration error:", error);
  } else {
    console.log("✅ Email server ready to send messages");
  }
});

const createWelcomeEmail = (userName, userEmail) => {
  return {
    from: {
      name: 'Restaurant Solutions',
      address: process.env.GMAIL_USER
    },
    to: userEmail,
    subject: '🎉 Welcome to Restaurant Solutions - Your Account is Ready!',
    html: `
      <!DOCTYPE html>
      <html>
      <head>
        <style>
          body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
            color: #2d3436;
            background-color: #f8f9fa;
            margin: 0;
            padding: 0;
          }
          .container {
            max-width: 600px;
            margin: 40px auto;
            background: white;
            border-radius: 16px;
            overflow: hidden;
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
          }
          .header {
            background: linear-gradient(135deg, #5a6c7d 0%, #4a5568 100%);
            color: white;
            padding: 40px 30px;
            text-align: center;
          }
          .header h1 {
            margin: 0;
            font-size: 32px;
            font-weight: 700;
          }
          .header p {
            margin: 10px 0 0 0;
            font-size: 16px;
            opacity: 0.9;
          }
          .content {
            padding: 40px 30px;
          }
          .content h2 {
            color: #2d3436;
            font-size: 24px;
            margin: 0 0 20px 0;
          }
          .content p {
            color: #636e72;
            font-size: 16px;
            margin: 0 0 15px 0;
          }
          .button {
            display: inline-block;
            background: linear-gradient(135deg, #5a6c7d 0%, #4a5568 100%);
            color: white;
            padding: 14px 32px;
            border-radius: 8px;
            text-decoration: none;
            font-weight: 600;
            font-size: 16px;
            margin: 20px 0;
          }
          .features {
            background: #f8f9fa;
            padding: 25px;
            border-radius: 12px;
            margin: 25px 0;
          }
          .feature {
            display: flex;
            align-items: center;
            margin: 15px 0;
          }
          .feature-icon {
            font-size: 24px;
            margin-right: 15px;
          }
          .feature-text {
            color: #2d3436;
            font-size: 15px;
          }
          .footer {
            background: #f8f9fa;
            padding: 30px;
            text-align: center;
            color: #636e72;
            font-size: 14px;
          }
          .footer a {
            color: #5a6c7d;
            text-decoration: none;
            font-weight: 600;
          }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>✨ Welcome to Restaurant Solutions!</h1>
            <p>Your premium food delivery experience starts here</p>
          </div>
          
          <div class="content">
            <h2>Hi ${userName}! 👋</h2>
            
            <p>Welcome aboard! We're thrilled to have you join the Restaurant Solutions family. Your account has been successfully created and you're all set to explore our delicious menu.</p>
            
            <div class="features">
              <div class="feature">
                <span class="feature-icon">🍕</span>
                <span class="feature-text"><strong>Browse Premium Menu</strong> - Discover our curated selection of gourmet dishes</span>
              </div>
              <div class="feature">
                <span class="feature-icon">🛒</span>
                <span class="feature-text"><strong>Easy Ordering</strong> - Add items to cart and checkout in seconds</span>
              </div>
              <div class="feature">
                <span class="feature-icon">📋</span>
                <span class="feature-text"><strong>Track Orders</strong> - Monitor your order status in real-time</span>
              </div>
              <div class="feature">
                <span class="feature-icon">🎉</span>
                <span class="feature-text"><strong>Exclusive Deals</strong> - Get access to special offers and promotions</span>
              </div>
            </div>
            
            <p><strong>Your Account Details:</strong></p>
            <p style="background: #f8f9fa; padding: 15px; border-radius: 8px; border-left: 4px solid #5a6c7d;">
              📧 Email: ${userEmail}<br>
              🔐 You can login anytime with your email and password
            </p>
            
            <div style="text-align: center; margin: 30px 0;">
              <a href="https://app.restaurantsolutions.shop" class="button">Start Ordering Now 🚀</a>
            </div>
            
            <p style="font-size: 14px; color: #636e72; margin-top: 30px;">
              Need help? Reply to this email or contact our support team. We're here to make your experience amazing!
            </p>
          </div>
          
          <div class="footer">
            <p><strong>Restaurant Solutions</strong> - Premium Food Delivery</p>
            <p>
              <a href="https://app.restaurantsolutions.shop">Visit Website</a> | 
              <a href="https://app.restaurantsolutions.shop">Browse Menu</a> | 
              <a href="mailto:${process.env.GMAIL_USER}">Contact Support</a>
            </p>
            <p style="margin-top: 20px; font-size: 12px;">
              You're receiving this email because you created an account at Restaurant Solutions.<br>
              © ${new Date().getFullYear()} Restaurant Solutions. All rights reserved.
            </p>
          </div>
        </div>
      </body>
      </html>
    `
  };
};

const sendWelcomeEmail = async (userName, userEmail) => {
  try {
    const mailOptions = createWelcomeEmail(userName, userEmail);
    const info = await transporter.sendMail(mailOptions);
    console.log("✅ Welcome email sent:", info.messageId);
    return { success: true, messageId: info.messageId };
  } catch (error) {
    console.error("❌ Email sending failed:", error);
    return { success: false, error: error.message };
  }
};

console.log("Deployment test " + new Date());
// S3 Configuration
const s3 = new S3Client({ region: "us-east-1" });
const BUCKET_NAME = process.env.S3_BUCKET_NAME || "restaurant-react-app-00009";
const upload = multer({ storage: multer.memoryStorage() });

// Routes

// Root endpoint
app.get("/", (req, res) => res.send("Backend running 🚀"));

// Health check endpoint - FIXED (removed .promise())
app.get("/api/health", async (req, res) => {
  try {
    const [rows] = await pool.query("SELECT 1");
    res.json({ status: "healthy", database: "connected", timestamp: new Date() });
  } catch (err) {
    res.status(503).json({ status: "unhealthy", error: err.message });
  }
});

// Debug database endpoint
app.get("/api/debug-db", async (req, res) => {
  try {
    console.log("🔍 Testing database connection...");
    const [results] = await pool.query("SELECT 1 as test");
    console.log("✅ Query successful:", results);
    res.json({
      message: "Database working!",
      test: results,
      connectionState: "healthy"
    });
  } catch (err) {
    console.error("❌ Database error:", err);
    res.status(500).json({ error: "Database test failed: " + err.message });
  }
});

//register users
// Public user registration
app.post("/api/register", async (req, res) => {
  try {
    const { email, password, name } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: "Email and password required" });
    }

    // Check if user already exists
    const [existing] = await pool.query("SELECT id FROM users WHERE email = ?", [email]);
    if (existing.length > 0) {
      return res.status(409).json({ error: "Email already registered" });
    }

    // Create new user with customer role
    const [result] = await pool.query(
      "INSERT INTO users (email, password, name, role) VALUES (?, ?, ?, 'customer')",
      [email, password, name || 'Customer']
    );

    // Auto-login: Generate JWT token
    const token = jwt.sign(
      {
        id: result.insertId,
        email: email,
        role: 'customer'
      },
      process.env.JWT_SECRET,
      { expiresIn: '1h' }
    );

    console.log("✅ User registered:", email);
     // Send welcome email
    await sendWelcomeEmail(name || 'Customer', email);
    res.json({
      message: "Registration successful",
      token: token,
      user: {
        id: result.insertId,
        email: email,
        name: name || 'Customer',
        role: 'customer'
      }
    });
  } catch (err) {
    console.error("❌ Registration error:", err);
    res.status(500).json({ error: "Registration failed", details: err.message });
  }
});

// Public menu endpoint - FIXED (using promise-based pool)
app.get("/api/menu", async (req, res) => {
  try {
    console.log("🔍 Fetching menu items...");
    const [results] = await pool.query("SELECT * FROM menu_items");
    console.log(`✅ Menu query successful, found ${results.length} items`);
    res.json(results);
  } catch (err) {
    console.error("❌ Menu fetch error:", err);
    res.status(500).json({
      error: "Failed to fetch menu",
      details: err.message
    });
  }
});

// Delete order endpoint
app.delete("/api/orders/:id", authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;
    const userRole = req.user.role;

    console.log(`🗑️ Delete request for order ${id} by user ${userId}`);

    // Check if order exists and belongs to user (unless admin)
    const [orderCheck] = await pool.query(
      "SELECT * FROM orders WHERE id = ?",
      [id]
    );

    if (orderCheck.length === 0) {
      return res.status(404).json({ error: "Order not found" });
    }

    const order = orderCheck[0];

    // Only allow user to delete their own orders, or admin can delete any
    if (userRole !== 'admin' && order.user_id !== userId) {
      return res.status(403).json({ error: "Not authorized to delete this order" });
    }

 // Delete the order
    await pool.query("DELETE FROM orders WHERE id = ?", [id]);

    console.log(`✅ Order ${id} deleted successfully`);
    res.json({
      success: true,
      message: "Order deleted successfully"
    });

  } catch (err) {
    console.error("❌ Error deleting order:", err);
    res.status(500).json({ error: "Failed to delete order" });
  }
});


// Login endpoint - FIXED (removed .promise())
app.post("/api/login", async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ error: "Email and password required" });
    }
    console.log("🔐 Login attempt:", email);
    const [results] = await pool.query(
      "SELECT * FROM users WHERE email = ? AND password = ?",
      [email, password]
    );
    if (results.length === 0) {
      return res.status(401).json({ error: "Invalid credentials" });
    }

    const user = results[0];

    // Generate JWT token
    const token = jwt.sign(
      {
        id: user.id,
        email: user.email,
        role: user.role || 'customer'
      },
      process.env.JWT_SECRET,
      { expiresIn: '1h' }
    );

    console.log("✅ Login successful:", email);
    res.json({
      message: "Login successful",
      token: token,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role || 'customer'
      }
    });
  } catch (err) {
    console.error("❌ Login error:", err);
    res.status(500).json({ error: "Database error", details: err.message });
  }
});

// Create order - FIXED (removed .promise())
app.post("/api/orders", authenticateToken, async (req, res) => {
  try {
    const { customer_name, customer_phone, items, total_price } = req.body;
    const userId = req.user.id;

    console.log(`📝 Creating order for user ID: ${userId}, Name: ${customer_name}`);

    const [result] = await pool.query(
      "INSERT INTO orders (user_id, customer_name, customer_phone, items, total_price) VALUES (?, ?, ?, ?, ?)",
      [userId, customer_name, customer_phone, JSON.stringify(items), total_price]
    );

    console.log(`✅ Order created with ID: ${result.insertId}`);
    res.json({
      message: "Order placed successfully",
      orderId: result.insertId
    });
  } catch (err) {
    console.error("❌ Error creating order:", err);
    res.status(500).json({ error: "Failed to place order" });
  }
});


// Get orders - FIXED (removed .promise())
app.get("/api/orders", authenticateToken, async (req, res) => {
  try {
    const userId = req.user.id;
    const userRole = req.user.role;

    console.log(`📋 Fetching orders for user ID: ${userId}, Role: ${userRole}`);

    let query;
    let params;

    // Admin sees all orders, customers see only their orders
    if (userRole === 'admin') {
      query = "SELECT * FROM orders ORDER BY order_date DESC";
      params = [];
      console.log("👑 Admin access - showing all orders");
    } else {
      query = "SELECT * FROM orders WHERE user_id = ? ORDER BY order_date DESC";
      params = [userId];
      console.log(`👤 Customer access - showing orders for user ${userId}`);
    }

    const [results] = await pool.query(query, params);

    const formatted = results.map(order => ({
      ...order,
      items: typeof order.items === 'string' ? JSON.parse(order.items) : order.items
    }));

    console.log(`✅ Retrieved ${formatted.length} orders`);
    res.json(formatted);
  } catch (err) {
    console.error("❌ Orders fetch error:", err);
    res.status(500).json({
      error: "Failed to fetch orders",
      details: err.message
    });
  }
});
// Upload image to S3
app.post("/api/admin/upload", authenticateToken, requireAdmin, upload.single("image"), async (req, res) => {
  try {
    const file = req.file;
    if (!file) {
      return res.status(400).json({ error: "No file uploaded" });
    }

    console.log("📤 Uploading file:", file.originalname);
    await s3.send(new PutObjectCommand({
      Bucket: BUCKET_NAME,
      Key: `dynamic-images/${file.originalname}`,
      Body: file.buffer,
      ContentType: file.mimetype
       }));

     const key = `dynamic-images/${file.originalname}`;
     const CDN_DOMAIN = process.env.CDN_DOMAIN;

     const url = CDN_DOMAIN
     ? `https://${CDN_DOMAIN}/${key}`
     : `https://${BUCKET_NAME}.s3.amazonaws.com/${key}`;
     console.log("✅ File uploaded:", url);
     res.json({ success: true, url });
     } catch (err) {
    console.error("❌ Upload error:", err);
    res.status(500).json({ success: false, error: "Upload failed" });
     }
    });

// Add menu item - FIXED (removed .promise())
app.post("/api/admin/menu", authenticateToken, requireAdmin, async (req, res) => {  try {
    const { name, price, image } = req.body;

    if (!name || !price) {
      return res.status(400).json({ error: "Name and price required" });
    }

    console.log("➕ Adding menu item:", name);
    const [result] = await pool.query(
      "INSERT INTO menu_items (name, price, image) VALUES (?, ?, ?)",
      [name, price, image]
    );

    console.log("✅ Menu item added:", result.insertId);
    res.json({ success: true, id: result.insertId });
  } catch (err) {
    console.error("❌ Add menu error:", err);
    res.status(500).json({ success: false, error: err.message });
  }
});

// Get admin menu - FIXED (removed .promise())
app.get("/api/admin/menu", authenticateToken, requireAdmin, async (req, res) => {  try {
    console.log("📋 Fetching admin menu...");
    const [results] = await pool.query("SELECT * FROM menu_items");
    console.log(`✅ Retrieved ${results.length} items for admin`);
    res.json(results);
  } catch (err) {
    console.error("❌ Admin menu error:", err);
    res.status(500).json({ success: false, error: err.message });
  }
});

// Update menu item - FIXED (removed .promise())
app.put("/api/admin/menu/:id", authenticateToken, requireAdmin, async (req, res) => {
  try {
    const { id } = req.params;
    const { name, price, image } = req.body;

    console.log("✏️ Updating menu item:", id);
    await pool.query(
      "UPDATE menu_items SET name=?, price=?, image=? WHERE id=?",
      [name, price, image, id]
    );

    console.log("✅ Menu item updated:", id);
    res.json({ success: true });
  } catch (err) {
    console.error("❌ Update menu error:", err);
    res.status(500).json({ success: false, error: err.message });
  }
});

// Delete menu item - FIXED (removed .promise())
app.delete("/api/admin/menu/:id", authenticateToken, requireAdmin, async (req, res) => {
  try {
    const { id } = req.params;
    console.log("🗑️ Deleting menu item:", id);
    await pool.query("DELETE FROM menu_items WHERE id=?", [id]);
    console.log("✅ Menu item deleted:", id);
    res.json({ success: true });
  } catch (err) {
    console.error("❌ Delete menu error:", err);
    res.status(500).json({ success: false, error: err.message });
  }
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: "Route not found" });
});

// Graceful shutdown
process.on('SIGTERM', async () => {
  console.log('SIGTERM received, closing connections...');
  await pool.end();
  process.exit(0);
});

process.on('SIGINT', async () => {
  console.log('SIGINT received, closing connections...');
  await pool.end();
  process.exit(0);
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server running on http://0.0.0.0:${PORT}`);
  console.log(`📝 Environment: ${process.env.NODE_ENV || 'development'}`);
});
