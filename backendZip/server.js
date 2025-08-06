const express = require('express');
const connectDb = require('./config/db');
const dotenv = require('dotenv');
const cors = require('cors');
const passport = require('passport');
const session = require('express-session');
const GoogleStrategy = require('passport-google-oauth20').Strategy;
const User = require('./models/User')
const jwt = require('jsonwebtoken');


const userRoutes = require('./routes/userRoute');
const productRoutes = require('./routes/productRoute');
const cartRoutes = require('./routes/cartRoute');
const orderRoutes = require('./routes/orderRoute');

dotenv.config();
connectDb();

const app = express();
app.use(express.json());

const corsOptions = {
  origin: function (origin, callback) {
    // Allow requests with no origin (like mobile apps or curl requests)
    if (!origin) return callback(null, true);
    
    // Allow any localhost origin for development
    if (origin && (origin.startsWith('http://localhost:') || origin.startsWith('https://localhost:'))) {
      return callback(null, true);
    }
    
    // Allow your production frontend domain (update this with your actual domain)
    const allowedOrigins = [
      'https://your-flutter-app.netlify.app',
      'https://your-flutter-app.vercel.app',
      'https://your-custom-domain.com'
    ];
    
    if (allowedOrigins.includes(origin)) {
      return callback(null, true);
    }
    
    // For development, allow all origins (remove this in production if needed)
    if (process.env.NODE_ENV !== 'production') {
      return callback(null, true);
    }
    
    // Block other origins
    callback(new Error('Not allowed by CORS'));
  },
  credentials: true, // If using cookies, authorization headers, etc.
};

app.use(cors(corsOptions));

app.use(
  session({
    secret : "secret",
    resave: false,
    saveUninitialized: true,
  })
);
app.use(passport.initialize());
app.use(passport.session());   
// passport.use(
//   new GoogleStrategy(
//     {
//         clientID: process.env.GOOGLE_CLIENT_ID,
//         clientSecret : process.env.GOOGLE_CLIENT_SECRET,
//         callbackURL: 'http://localhost:3000/auth/google/callback',
//     },
//  (accessToken, refreshToken, profile, done) =>{
//   return done(null, profile);
// })
// )  
                

passport.use(
  new GoogleStrategy(
    {
      clientID: process.env.GOOGLE_CLIENT_ID,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET,
    //   callbackURL: 'http://localhost:5000'
      callbackURL: process.env.GOOGLE_CALLBACK_URL, // Use env variable for deployment readiness
    },
    async (accessToken, refreshToken, profile, done) => {
      try {
        const email = profile.emails[0].value;
        console.log("email :: "+email);
        
        let user = await User.findOne({ email });
        console.log("user : "+user);
        
        
        if (!user) { // Check if 'user' (the variable) is null/undefined
          console.log('User not found, creating new user...');
          user = await User.create({
            name: profile.displayName,
            email: email,
            password: '',
            isGoogleUser: true,
            // You might also want to save the Google ID here
            googleId: profile.id, // Add this if you want to store Google's unique ID
          });
          console.log('New user created:', user.email);
        } else {
          console.log('User found:', user.email);
          // Optional: Update existing user's Google ID if not present
          if (!user.googleId) {
            user.googleId = profile.id;
            await user.save();
          }
        }

        return done(null, user);
      } catch (err) {
        return done(err, null);
      }
    }
  )
)


passport.serializeUser((user, done) => done(null, user));
passport.deserializeUser((user, done) => done(null, user))
  

app.use('/api/users', userRoutes);
app.use('/api/products', productRoutes);
app.use('/api/cart', cartRoutes);
app.use('/api/orders', orderRoutes);

app.use('/api/payments', require('./routes/paymentRoute'));

app.get('/', (req, res) => {
  res.send("<a href = '/auth/google'> Login with Google</a>");
});


app.get('/auth/google', passport.authenticate('google', {scope: ["profile", "email"]})
);

// app.get('/auth/google/callback', passport.authenticate('google', {failureRedirect: "/"}), (req, res)=>{
//     res.redirect('/api/user')
// }
// );

app.get(
  '/auth/google/callback',
  passport.authenticate('google', { failureRedirect: '/' }),
  (req, res) => {
    const user = req.user;
    console.log("user" + user);
    
    // Generate token
    const token = jwt.sign(
      { id: user._id, email: user.email },
      process.env.JWT_SECRET,
      { expiresIn: '1d' }
    );
    // res.redirect(`http://localhost:3000/`)
    res.redirect(`${process.env.BASE_URL}/google/success?token=${token}&user=${encodeURIComponent(user.email)}`);
  }
);

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));