// src/routes/productRoutes.js
const express = require('express');
const {
    getProducts,
    getProductById,
    createProduct,
    updateProduct,
    deleteProduct
} = require('../controllers/productController');

// Import our auth middlewares
const { protect, authorize } = require('../middlewares/authMiddleware');

const router = express.Router();

// Public routes (No token required)
router.get('/', getProducts);
router.get('/:id', getProductById);

// Admin-only routes
// 1. protect ensures the user has a valid JWT
// 2. authorize('admin') ensures the decoded JWT user has the 'admin' role
router.post('/', protect, authorize('admin'), createProduct);
router.put('/:id', protect, authorize('admin'), updateProduct);
router.delete('/:id', protect, authorize('admin'), deleteProduct);

module.exports = router;