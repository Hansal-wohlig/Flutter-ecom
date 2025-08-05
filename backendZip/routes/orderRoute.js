const express = require('express');
const router = express.Router();

const { placeOrder, getMyOrders } = require('../controller/orderController');
const { protect } = require('../middleware/authMiddleware');

// ✅ Place Order
router.post('/', protect, placeOrder);

// ✅ Get My Orders
router.get('/myorders', protect, getMyOrders);

module.exports = router;