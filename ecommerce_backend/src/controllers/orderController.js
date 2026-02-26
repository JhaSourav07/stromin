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

// it fetches the orders for the logged-in user, sorts them by creation date in descending order, and returns the orders along with a success message and the count of orders. If there's an error during the process, it catches the error and returns a server error message along with the error details.
// @desc    Get logged in user orders
// @route   GET /api/orders/me
// @access  Private (Customer)
exports.getMyOrders = async (req, res) => {
    try{
        const orders = await Order.find({user: req.user.id}).sort({ createdAt: -1 });
        res.status(200).json({ success: true, count: orders.length, data: orders })

    } catch (error) {
        res.status(500).json({ success: false, message: 'Server Error', error: error.message });
    }
};

// @desc    Get all orders
// @route   GET /api/orders
// @access  Private/Admin
exports.getOrders = async (req, res) => {
    try {
        // Fetch all orders, sort by newest first, and attach the user's name/email
        const orders = await Order.find({})
            .sort({ createdAt: -1 })
            .populate('user', 'id name email');
            
        res.status(200).json({ success: true, count: orders.length, data: orders });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Server Error', error: error.message });
    }
};

// @desc    Update order status
// @route   PUT /api/orders/:id/status
// @access  Private/Admin
exports.updateOrderStatus = async (req, res) => {
    try {
        const { status } = req.body;
        const order = await Order.findById(req.params.id);

        if (!order) {
            return res.status(404).json({ success: false, message: 'Order not found' });
        }

        order.status = status;
        const updatedOrder = await order.save();

        res.status(200).json({ success: true, data: updatedOrder });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Server Error' });
    }
};