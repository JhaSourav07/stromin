const express = require("express");
const router = express.Router();
const {
  addOrderItems,
  getMyOrders,
  getOrders,
  updateOrderStatus,
} = require("../controllers/orderController");
const { protect, authorize } = require("../middlewares/authMiddleware");

router.post("/", protect, addOrderItems);
router.get("/myorders", protect, getMyOrders);
router.get("/", protect, authorize("admin"), getOrders);
router.put("/:id/status", protect, authorize("admin"), updateOrderStatus);

module.exports = router;
