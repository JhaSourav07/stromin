// ecommerce_backend/src/controllers/orderController.js
const Order = require("../models/Order");
const Product = require("../models/Product");


// @desc    Create new order
// @route   POST /api/orders
// @access  Private (Customer)
exports.addOrderItems = async (req, res) => {
  try {
    const { orderItems, shippingAddress, totalPrice } = req.body;

    if (!orderItems || orderItems.length === 0) {
      return res
        .status(400)
        .json({ success: false, message: "No order items provided" });
    }

    const stockErrors = [];

    for (const item of orderItems) {
      const product = await Product.findById(item.product);

      if (!product) {
        stockErrors.push(`Product "${item.name}" no longer exists.`);
        continue;
      }

      if (product.stock < item.qty) {
        stockErrors.push(
          `"${product.name}" only has ${product.stock} left in stock (you requested ${item.qty}).`
        );
      }
    }

    if (stockErrors.length > 0) {
      return res.status(400).json({
        success: false,
        message: "Some items are out of stock",
        errors: stockErrors,
      });
    }

    // ── CREATE ORDER ─────────────────────────────────────────────────────────
    const order = new Order({
      user: req.user.id,
      orderItems,
      shippingAddress,
      totalPrice,
    });

    const createdOrder = await order.save();

    for (const item of orderItems) {
      await Product.findByIdAndUpdate(
        item.product,
        { $inc: { stock: -item.qty } },
        { new: false } // we don't need the updated doc back, skip the extra work
      );
    }

    res.status(201).json({ success: true, data: createdOrder });

  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};


// @desc    Get logged in user orders
// @route   GET /api/orders/myorders
// @access  Private (Customer)
exports.getMyOrders = async (req, res) => {
  try {
    const orders = await Order.find({ user: req.user.id }).sort({ createdAt: -1 });
    res.status(200).json({ success: true, count: orders.length, data: orders });
  } catch (error) {
    res.status(500).json({ success: false, message: "Server Error", error: error.message });
  }
};


// @desc    Get all orders (admin)
// @route   GET /api/orders
// @access  Private/Admin
exports.getOrders = async (req, res) => {
  try {
    const orders = await Order.find({})
      .sort({ createdAt: -1 })
      .populate("user", "id name email");

    res.status(200).json({ success: true, count: orders.length, data: orders });
  } catch (error) {
    res.status(500).json({ success: false, message: "Server Error", error: error.message });
  }
};


// @desc    Update order status (admin)
// @route   PUT /api/orders/:id/status
// @access  Private/Admin
exports.updateOrderStatus = async (req, res) => {
  try {
    const { status } = req.body;
    const order = await Order.findById(req.params.id);

    if (!order) {
      return res.status(404).json({ success: false, message: "Order not found" });
    }

    order.status = status;
    const updatedOrder = await order.save();

    res.status(200).json({ success: true, data: updatedOrder });
  } catch (error) {
    res.status(500).json({ success: false, message: "Server Error" });
  }
};