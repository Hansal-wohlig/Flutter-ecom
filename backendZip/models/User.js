const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
  },
  email: {
    type: String,
    required: true,
    unique: true, // Email must be unique for all users (both Google and local)
  },
  password: {
    // This field is REQUIRED for local (email/password) users.
    // It will be an EMPTY STRING for Google-authenticated users.
    // We make it required: false here because for Google users, it won't be provided.
    // Validation for presence will typically be handled at the route level for local signup.
    type: String,
    required: false, // Set to false, as Google users won't have a password in your DB
    default: '' // Default to empty string for safety/consistency if not provided
  },
  googleId: {
    // This field will only be present for Google-authenticated users.
    // It helps link a Google profile to an existing user or identify a new Google user.
    type: String,
    unique: true, // Make it unique to prevent multiple Google accounts linking to one user if that's your policy
    sparse: true, // IMPORTANT: Allows multiple documents to have a null/undefined googleId but ensures uniqueness where it IS present.
  },
  // Flag to easily distinguish authentication methods, helpful for UI/logic
  authMethod: {
    type: String,
    enum: ['local', 'google'], // Enforce specific values
    default: 'local', // Default to 'local' if not specified (for traditional signup)
    required: true,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

// IMPORTANT: Name your model consistently. You were using 'UserGoogle' and 'User' before.
// Stick to one name, e.g., 'User'.
module.exports = mongoose.model('User', UserSchema);