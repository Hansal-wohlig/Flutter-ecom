const Cart = require('../models/cartModel');
const Product = require('../models/productModel');

// Add a product to the cart
const addToCart = async (req, res) => {
    try {
        console.log('Add to Cart route hit');
        console.log(req.body);
        
        const { product, quantity = 1 } = req.body;
        const productId = product._id || product;
        const addQuantity = parseInt(quantity) || 1;
        console.log("productId :: "+productId + " , quantity : "+addQuantity);
        
        const productData = await Product.findById(productId);
        console.log("product found"+productData);
        
        if (!productData) {
            return res.status(404).json({ message: 'Product not found' });
        }
        console.log("user : "+req?.user._id);
        
        let cart = await Cart.findOne({ user: req.user._id });
        if (cart) {
            const itemIndex = cart.items.findIndex(item => item.product.toString() === productId);
            if (itemIndex > -1) {
                cart.items[itemIndex].quantity += addQuantity;
            } else {
                cart.items.push({ product: productId, quantity: addQuantity });
            }
            cart = await cart.save();
            console.log('Cart updated:', cart);
        } else {
            cart = await Cart.create({
                user: req.user._id,
                items: [{ product: productId, quantity: addQuantity }]
            });
            console.log('New cart created:', cart);
        }
        res.status(201).json(cart);
    } catch (error) {
        console.error('Error in addToCart:', error);
        res.status(500).json({ message: 'Server error', error: error.message });
    }
}

const getCart = async (req, res) => {
    try {
        console.log('Get Cart route hit');
        const cart = await Cart.findOne({ user: req.user._id }).populate('items.product');

        if (!cart) {
            return res.status(200).json({ message: 'Cart is empty', items: [] });
        }

        res.status(200).json(cart);
    } catch (error) {
        console.error('Error in getCart:', error);
        res.status(500).json({ message: 'Server error' });
    }
};

// @desc   Remove item from cart
const removeFromCart = async (req, res) => {
    try {
        console.log('Remove from Cart route hit');
        const { productId } = req.params;

        const cart = await Cart.findOne({ user: req.user._id });

        if (!cart) {
            return res.status(404).json({ message: 'Cart not found' });
        }

        cart.items = cart.items.filter(item => item.product.toString() !== productId);

        await cart.save();

        res.status(200).json({ message: 'Item removed', cart });
    } catch (error) {
        console.error('Error in removeFromCart:', error);
        res.status(500).json({ message: 'Server error' });
    }
};

// @desc   Clear cart
const clearCart = async (req, res) => {
    try {
        console.log('Clear Cart route hit');
        await Cart.findOneAndDelete({ user: req.user._id });

        res.status(200).json({ message: 'Cart cleared' });
    } catch (error) {
        console.error('Error in clearCart:', error);
        res.status(500).json({ message: 'Server error' });
    }
};

// @desc   Update quantity of an item in cart
const updateCartItem = async (req, res) => {
    try {
        const userId = req.user._id;
        const { product, quantity } = req.body;

        if (!product || typeof quantity !== 'number') {
            return res.status(400).json({ message: 'Product and quantity required' });
        }

        let cart = await Cart.findOne({ user: userId });
        if (!cart) return res.status(404).json({ message: 'Cart not found' });

        const item = cart.items.find(i => i.product.toString() === product);
        if (!item) return res.status(404).json({ message: 'Item not in cart' });

        if (quantity < 1) {
            cart.items = cart.items.filter(i => i.product.toString() !== product);
        } else {
            item.quantity = quantity;
        }
        await cart.save();
        res.json(cart);
    } catch (err) {
        console.error('Error in updateCartItem:', err);
        res.status(500).json({ message: 'Server error' });
    }
};

module.exports = {
    addToCart,
    getCart,
    removeFromCart,
    clearCart,
    updateCartItem
};