const jwt = require('jsonwebtoken');
const User = require('../models/User'); // Assuming your User model path

const protect = async (req, res, next) => {
  let token;

  try {
    console.log('--- Protect Middleware Hit ---');
    // 1. Check if the Authorization header exists and is in the correct format
    if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
      // Extract the token from the 'Bearer <token>' string
      token = req.headers.authorization.split(' ')[1];
      console.log("Token received:", token);
    } else {
      console.log("No authorization header or incorrect format.");
      return res.status(401).json({ message: 'Not authorized, no token' });
    }
    console.log("Verifying with JWT_SECRET:", process.env.JWT_SECRET); 
    // 2. Verify the token using the secret from environment variables
    // Ensure process.env.JWT_SECRET is correctly loaded and matches the secret used for signing
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    console.log("Decoded JWT payload:", decoded);

    // 3. Find the user based on the decoded ID and attach to the request
    // Exclude the password field for security
    req.user = await User.findById(decoded.id).select('-password');

    if (!req.user) {
      console.log("User not found for the given token ID.");
      return res.status(404).json({ message: 'User not found' });
    }

    console.log("Authenticated user:", req.user.username || req.user.email); // Log relevant user info
    next(); // Move to the next middleware or route handler

  } catch (error) {
    // Centralized error handling for JWT issues and other errors
    console.error('Authentication error:', error.message);

    if (error.name === 'JsonWebTokenError') {
      // Specific error messages for different JWT issues
      if (error.message === 'invalid signature') {
        res.status(401).json({ message: 'Not authorized, invalid token signature. Secret mismatch.' });
      } else if (error.message === 'jwt expired') {
        res.status(401).json({ message: 'Not authorized, token expired.' });
      } else if (error.message === 'invalid token') {
        res.status(401).json({ message: 'Not authorized, invalid token format.' });
      } else {
        res.status(401).json({ message: 'Not authorized, token verification failed.' });
      }
    } else {
      // Handle other potential errors (e.g., database errors, network issues)
      res.status(500).json({ message: 'Server error during authentication.' });
    }
  }
};

module.exports = { protect };