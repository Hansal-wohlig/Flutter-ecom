const express = require('express');
const router = express.Router();

const {
    addToCart,
    getCart,
    removeFromCart,
    clearCart,
    updateCartItem
} = require('../controller/cartController');

const { protect } = require('../middleware/authMiddleware');

// ✅ Protected Routes
router.post('/add',protect, addToCart);
router.get('/', protect, getCart);
router.delete('/remove/:productId', protect, removeFromCart);
router.delete('/clear', protect, clearCart);

// Update cart item quantity
router.put('/update', protect, updateCartItem);

module.exports = router;