const express = require("express");
const router = express.Router();
const upload = require("../config/cloudinary");
const { protect, authorize } = require("../middlewares/authMiddleware");


// @route   POST /api/upload
// @desc    Upload an image to Cloudinary
// @access  Private/Admin
router.post(
  "/",
  protect,
  authorize("admin"),
  upload.single("image"),
  (req, res) => {
    try {
      if (!req.file) {
        return res
          .status(400)
          .json({ success: false, message: "No file uploaded" });
      }
      res
        .status(200)
        .json({
          success: true,
          message: "File uploaded successfully",
          file: req.file.path,
        });
    } catch (error) {
      res
        .status(500)
        .json({
          success: false,
          message: "Error uploading file",
          error: error.message,
        });
    }
  },
);

module.exports = router;
