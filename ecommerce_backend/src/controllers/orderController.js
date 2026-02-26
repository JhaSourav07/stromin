const Order = require("../models/Order");


// @desc    Create new order
// @route   POST /api/orders
// @access  Private (Customer)
exports.addOrderItems = async (req, res) => {
  try {
    const { orderItems, shippingAddress, totalPrice } = req.body;

    if (orderItems && orderItems.length === 0) {
      return res
        .status(400)
        .json({ success: false, message: "No order items provided" });
    }

    const order = new Order({
      user: req.user.id,
      orderItems,
      shippingAddress,
      totalPrice,
    });

    const createdOrder = await order.save();
    res.status(201).json({ success: true, data: createdOrder });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};


exports.getMyOrders = async (req, res) => {
    try{
        const orders = await Order.find({user: req.user.id}).sort({ createdAt: -1 });
        res.status(200).json({ success: true, count: orders.length, data: orders })

    } catch (error) {
        res.status(500).json({ success: false, message: 'Server Error', error: error.message });
    }
};