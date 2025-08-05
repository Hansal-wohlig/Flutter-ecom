const mongoose = require('mongoose');

// Connect to MongoDB
const connectDb = async () => {
    try {
        const conn = await mongoose.connect(process.env.MONGO_URI);
        console.log(`MongoDB connected: ${conn.connection.host}`);

    }catch(error){
        console.log(`Connnection failed: ${error.message}`);
        process.exit(1);
        
    }
};

module.exports = connectDb;