const User = require('../models/User');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { OAuth2Client } = require('google-auth-library');


// Generate JWT Token
const generateToken = (id) => {
  return jwt.sign({ id }, process.env.JWT_SECRET, {
    expiresIn: '30d',
  });
};

const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);


const registerUser = async (req, res) => {
  try {
    console.log('Register route hit');
    const { name, email, password } = req.body;

    if (!name || !email || !password) {
      return res.status(400).json({ message: 'Please fill all the fields' });
    }

    const userExists = await User.findOne({ email });
    if (userExists) {
      return res.status(400).json({ message: 'User already exists' });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);



    const user = new User({
      name,
      email,
      password: hashedPassword,
    });
    await user.save();

    res.status(201).json({
      _id: user._id,
      name: user.name,
      email: user.email,
      token: generateToken(user._id),
    });
  } catch (error) {
    console.error('Error in Register Route:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

const loginUser = async (req, res) => {
  try {
    console.log('Login route hit');
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ message: 'Please fill all the fields' });
    }

    const user = await User.findOne({ email });
    if (!user) {
      return res.status(400).json({ message: 'User does not exist' });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ message: 'Invalid credentials' });
    }

    res.status(200).json({
      _id: user._id,
      name: user.name,
      email: user.email,
      token: generateToken(user._id),
    });
  } catch (error) {
    console.error('Error in Login Route:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

const getUserProfile = async(req, res) => {
        try {
        console.log('Profile route hit');
        if(!req.user) {
            return res.status(401).json({ message: 'No user found' });
        }
        res.status(200).json({
            _id: req.user._id, 
            name: req.user.name,
            email: req.user.email,
        });
    } catch (error) {
        console.error('Error in Profile Route:', error);
        res.status(500).json({ message: 'Server error' });
    }
}

const googleLogin = async (req, res) => {
  try {
    const { token } = req.body;
    console.log("google-token : "+token);
    

    const ticket = await client.verifyIdToken({
      idToken: token,
      audience: process.env.GOOGLE_CLIENT_ID,
    });

    const { name, email } = ticket.getPayload();

    let user = await User.findOne({ email });

    if (!user) {
      user = await User.create({
        name,
        email,
        password: '',  // Password is blank for SSO users
      });
    }

    res.status(200).json({
      _id: user._id,
      name: user.name,
      email: user.email,
      token: generateToken(user._id),
    });
  } catch (error) {
    console.error('Google Login Error:', error);
    res.status(401).json({ message: 'Invalid Google Token' });
  }
};


module.exports = { 
  registerUser, 
  loginUser, 
  getUserProfile,
  googleLogin 
};

