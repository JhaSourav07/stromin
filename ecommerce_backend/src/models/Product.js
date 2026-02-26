// src/models/Product.js
const mongoose = require('mongoose');

const productSchema = new mongoose.Schema({
    user: {
        // Links this product to the Admin who created it
        type: mongoose.Schema.Types.ObjectId,
        required: true,
        ref: 'User'
    },
    name: {
        type: String,
        required: [true, 'Please add a product name'],
        trim: true
    },
    description: {
        type: String,
        required: [true, 'Please add a description']
    },
    price: {
        type: Number,
        required: [true, 'Please add a price'],
        default: 0.0
    },
    category: {
        type: String,
        required: [true, 'Please select a category'],
        enum: ['Electronics', 'Clothing', 'Books', 'Home', 'Other'] // Restrict categories
    },
    stock: {
        type: Number,
        required: [true, 'Please add stock quantity'],
        default: 0
    },
    imageUrl: {
        type: String,
        required: [true, 'Please add an image URL'],
        default: 'https://via.placeholder.com/150'
    },
    images: [{
        type: String
    }],
}, {
    timestamps: true
});

module.exports = mongoose.model('Product', productSchema);