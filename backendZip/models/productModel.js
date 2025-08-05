const mongoose = require('mongoose');

const productSchema = new mongoose.Schema({
    name: { type : String, required: [true, 'Please enter product name'] },
    description: { type : String, required: [true, 'Please enter product description'] },
    stock: { type: Number, default: 0, min: [0, 'Stock cannot be negative'] },
    category: { type: String },
    price: { type : Number, required: [true, 'Please enter product price'], min: [0, 'Price cannot be negative'] },
    image: { type : String, default: 'https://via.placeholder.com/150' },
}, {timestamps: true});

module.exports = mongoose.model('Product', productSchema);

