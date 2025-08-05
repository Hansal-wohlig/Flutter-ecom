const { compareSync } = require('bcryptjs');
const Product = require('../models/productModel');

const createProduct = async (req, res) => {
    try {
        console.log('Create Product route hit');
        const { name, description, stock, category, price, image } = req.body;
        if (!name || !description || !price) {
            return res.status(400).json({ message: 'Please fill all the required fields' });
        }
        const product = new Product({
            name,
            description,
            stock: stock || 0,
            category: category || 'General',
            price,
            image: image || 'https://via.placeholder.com/150',
        });
        res.status(201).json(await product.save());
        
    }catch (error) {
        console.error('Error in Create Product Route:', error);
        res.status(500).json({ message: 'Server error' });
    };
}

const getProducts = async (req, res) => {
    try {
        console.log('Get Products route hit' );
        const products = await Product.find({});
        res.status(200).json(products);        
    }catch (error) {
        console.error('Error in Get Products Route:', error);
        res.status(500).json({ message: 'Server error' });
    }
}

const getProductById = async (req, res) => {
    try {
        console.log('Get Product by ID route hit');
        const product = await Product.findById(req.params.id);
        if (!product) {
            return res.status(404).json({ message: 'Product not found' });
        }
        res.status(200).json(product);
    } catch (error) {
        console.error('Error in Get Product by ID Route:', error);
        res.status(500).json({ message: 'Server error' });
    }
}

const updateProduct = async (req, res) => {
    try {
        console.log('Update Product route hit');
        const product = await Product.findById(req.params.id);  
        if (!product) {
            return res.status(404).json({ message: 'Product not found' });
        }
        const updatedProduct = await Product.findByIdAndUpdate(
            req.params.id,
            req.body,
            { new: true }
        );
        res.status(200).json(updatedProduct);
    } catch (error) {
        console.error('Error in Update Product Route:', error);
        res.status(500).json({ message: 'Server error' });
    }
};

const deleteProduct = async (req, res) => {
    try {
        console.log('Delete Product route hit');
        const product = await Product.findByIdAndDelete(req.params.id);
        if (!product) {
            return res.status(404).json({ message: 'Product not found' });
        }
        res.status(200).json({ message: 'Product deleted successfully' });
        
    }catch (error) {
        console.error('Error in Delete Product Route:', error);
        res.status(500).json({ message: 'Server error' });
    }
};

module.exports = {
    createProduct,
    getProducts,
    getProductById,
    updateProduct,
    deleteProduct
};