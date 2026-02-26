const express = require("express");
const router = express.Router();
const upload = require("../config/cloudinary");
const { protect, authorize } = require("../middlewares/authMiddleware");


// @route   POST /api/upload/multiple
// @desc    Upload multiple images to Cloudinary (Max 5)
// @access  Private/Admin
router.post('/multiple', protect, authorize('admin'), upload.array('images', 5), (req, res) => {
    try {
        if (!req.files || req.files.length === 0) {
            return res.status(400).json({ success: false, message: 'Please upload images' });
        }

        // Extract the Cloudinary URLs from the uploaded files
        const imageUrls = req.files.map(file => file.path);

        res.status(200).json({
            success: true,
            imageUrls: imageUrls, 
            message: 'Images uploaded successfully'
        });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Multiple image upload failed' });
    }
});

module.exports = router;
