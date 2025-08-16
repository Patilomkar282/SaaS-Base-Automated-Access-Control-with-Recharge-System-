import jwt from "jsonwebtoken";
import db from "../config/db.js";

// Verify JWT token
export const verifyToken = async (req, res, next) => {
  const token = req.header("Authorization")?.replace("Bearer ", "");
  console.log(token);

  if (!token) {
    return res.status(401).json({ message: "Access denied. No token provided." });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    // Check if user still exists and is active
    const [user] = await db.query("SELECT * FROM users WHERE user_id = ? AND status = 'active'", [decoded.id]);
    
    if (user.length === 0) {
      return res.status(401).json({ message: "Invalid token or user inactive" });
    }

    req.user = decoded;
    next();
  } catch (error) {
    res.status(401).json({ message: "Invalid token" });
  }
};

// Access control middleware - checks wallet balance for form submission
export const checkAccess = (formType) => {
  return async (req, res, next) => {
    try {
      const [wallet] = await db.query(
        "SELECT balance, status, valid_until FROM wallets WHERE user_id = ?",
        [req.user.id]
      );

      if (wallet.length === 0) {
        return res.status(404).json({ message: "Wallet not found" });
      }

      const { balance, status, valid_until } = wallet[0];

      const rate = formType === 'realtime_validation' 
        ? parseFloat(process.env.REALTIME_VALIDATION_RATE) 
        : parseFloat(process.env.BASIC_FORM_RATE);

      // Check wallet validity
      if (valid_until && new Date(valid_until) < new Date()) {
        return res.status(403).json({ message: "subscription validity expired" });
      }

      // Check if wallet is active
      if (status !== 'active') {
        return res.status(403).json({ message: "subscription is inactive" });
      }

      // Check balance
      if (balance < rate) {
        return res.status(403).json({ 
          message: "Insufficient balance. Please recharge your wallet.",
          required: rate,
          current: balance
        });
      }

      req.formRate = rate;
      req.accessType = 'prepaid'; // all wallet based access is prepaid
      next();
    } catch (error) {
      console.error("Access Check Error:", error);
      res.status(500).json({ message: "Server error" });
    }
  };
};


// Role-based access control
export const checkRole = (allowedRoles) => {
  return (req, res, next) => {
    if (!allowedRoles.includes(req.user.role)) {
      return res.status(403).json({ message: "Access denied for your role" });
    }
    next();
  };
};