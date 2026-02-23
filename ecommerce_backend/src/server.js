// src/server.js
const express = require('express');
const dotenv = require('dotenv');
const cors = require('cors');
const morgan = require('morgan');
const connectDB = require('./config/database');

// Load env vars
dotenv.config();

// Connect to database
connectDB();

const app = express();

// Middlewares
app.use(express.json()); // Body parser (allows us to accept JSON data in req.body)
app.use(cors());         // Enable CORS

// Dev logging middleware
if (process.env.NODE_ENV === 'development' || true) {
    app.use(morgan('dev')); 
}

// Route files
const authRoutes = require('./routes/authRoutes');

// Mount routers
app.use('/api/auth', authRoutes);

// Base route for testing
app.get('/', (req, res) => {
    res.send('E-commerce API is running...');
});

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
    console.log(`Server running in ${process.env.NODE_ENV || 'development'} mode on port ${PORT}`);
});