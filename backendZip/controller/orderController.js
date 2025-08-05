const Order = require('../models/orderModel');
const Cart = require('../models/cartModel');
const Product = require('../models/productModel');

const placeOrder = async (req, res) => {
    try {
        console.log('Placing order for user:', req.user._id);
        console.log('Request body:', req.body);
        
        let orderItems;
        let totalPrice;

        // If items are sent directly in the request
        if (req.body.items && req.body.items.length > 0) {
            console.log('Processing direct items:', req.body.items);
            orderItems = req.body.items.map(item => ({
                product: item._id,
                quantity: item.qty
            }));
            totalPrice = req.body.items.reduce((total, item) => 
                total + (item.price * item.qty), 0
            );
        } else {
            // Get items from cart
            console.log('Fetching items from cart');
            const cart = await Cart.findOne({ user: req.user._id }).populate('items.product');
            if (!cart || cart.items.length === 0) {
                return res.status(400).json({ message: 'Cart is empty' });
            }
            orderItems = cart.items.map(item => ({
                product: item.product._id,
                quantity: item.quantity
            }));
            totalPrice = cart.items.reduce((total, item) => 
                total + (item.product.price * item.quantity), 0
            );
            // Delete cart after getting items
            await Cart.findOneAndDelete({ user: req.user._id });
        }

        console.log('Creating order with items:', orderItems);

        // Create the order
        const order = await Order.create({
            user: req.user._id,
            orderItems,
            totalPrice,
            paymentMethod: req.body.paymentMethod || 'Cash on Delivery'
        });

        console.log('Order created:', order);

        // Reduce stock for each product ordered
        for (const item of orderItems) {
            try {
                const product = await Product.findById(item.product);
                if (product) {
                    console.log(`Reducing stock for product ${product._id} from ${product.stock} by ${item.quantity}`);
                    product.stock = Math.max(0, product.stock - item.quantity);
                    await product.save();
                    console.log(`New stock for product ${product._id}: ${product.stock}`);
                }
            } catch (stockError) {
                console.error(`Error updating stock for product ${item.product}:`, stockError);
                // Continue with other products even if one fails
            }
        }

        await Cart.findOneAndDelete({ user: req.user._id });
        console.log('Cart cleared after order placement');
        res.status(201).json({ 
            message: 'Order placed successfully', 
            order,
            orderItems: orderItems 
        });
    } catch (error) {
        console.error('Error placing order:', error);
        res.status(500).json({ 
            message: 'Server error',
            error: error.message,
            stack: error.stack
        });
    }
};

// @desc   Get User's Orders
const getMyOrders = async (req, res) => {
    try {
        console.log('Fetching orders for user:', req.user._id);
        const orders = await Order.find({ user: req.user._id }).populate('orderItems.product');
        res.status(200).json(orders);
    } catch (error) {
        console.error('Error fetching orders:', error);
        res.status(500).json({ message: 'Server error' });
    }
};

module.exports = {
    placeOrder,
    getMyOrders
};