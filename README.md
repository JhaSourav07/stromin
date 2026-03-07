# Stromin — Full-Stack E-Commerce Platform

![Flutter](https://img.shields.io/badge/Flutter-3.35.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.9.2+-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Node.js](https://img.shields.io/badge/Node.js-18+-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)
![Express](https://img.shields.io/badge/Express-5.x-000000?style=for-the-badge&logo=express&logoColor=white)
![MongoDB](https://img.shields.io/badge/MongoDB-Mongoose-47A248?style=for-the-badge&logo=mongodb&logoColor=white)
![Cloudinary](https://img.shields.io/badge/Cloudinary-Image_Hosting-3448C5?style=for-the-badge&logo=cloudinary&logoColor=white)
![License](https://img.shields.io/badge/License-ISC-yellow?style=for-the-badge)
![Platform](https://img.shields.io/badge/Platform-Android_|_iOS-lightgrey?style=for-the-badge&logo=android&logoColor=white)

A production-ready e-commerce application built with **Flutter** (mobile client) and **Node.js/Express** (REST API backend), featuring role-based authentication, Cloudinary image hosting, and a MongoDB database.

---

## Table of Contents

- [Overview](#overview)
- [Tech Stack](#tech-stack)
- [Features](#features)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Backend Setup](#backend-setup)
  - [Flutter App Setup](#flutter-app-setup)
- [Environment Variables](#environment-variables)
- [API Reference](#api-reference)
- [Architecture](#architecture)
- [Screenshots](#screenshots)
- [Contributing](#contributing)

---

## Overview

Stromin is a cross-platform mobile e-commerce app supporting two user roles — **Customer** and **Admin** — each with their own dedicated experience. Customers can browse products, manage their cart, place orders, and track order history. Admins can manage the full product catalogue and update order statuses from a dedicated dashboard.

---

## Tech Stack

### Mobile (Flutter)
| Package | Purpose |
|---|---|
| `get` | State management & navigation |
| `dio` | HTTP client |
| `flutter_secure_storage` | JWT token storage |
| `shared_preferences` | Cart persistence |
| `image_picker` | Image selection |
| `flutter_animate` | UI animations |
| `google_fonts` | Typography |

### Backend (Node.js)
| Package | Purpose |
|---|---|
| `express` v5 | Web framework |
| `mongoose` | MongoDB ODM |
| `jsonwebtoken` | JWT auth |
| `bcryptjs` | Password hashing |
| `cloudinary` + `multer` | Image uploads |
| `cors` + `morgan` | Middleware |

---

## Features

### Customer
- Secure sign-up & login with JWT authentication
- Browse product catalogue with search and category filtering
- Multi-image product gallery with swipeable carousel
- Persistent shopping cart (survives app restarts)
- Checkout with shipping address form
- Order history with real-time status tracking

### Admin
- Dedicated admin dashboard for product management
- Add products with up to 5 images (uploaded to Cloudinary)
- Edit and delete existing products
- View all customer orders
- Update order status: `Pending → Processing → Shipped → Delivered`

### Security
- Role-based access control (`customer` / `admin`)
- JWT stored in secure encrypted storage
- Automatic logout on token expiry (global 401 interceptor)
- Admin-only API routes protected with dual middleware

---

## Project Structure

```
stromin/
├── ecommerce_app/               # Flutter mobile application
│   └── lib/
│       ├── core/
│       │   ├── constants/       # App-wide constants (base URL, keys)
│       │   └── network/         # Dio API client with interceptors
│       └── features/
│           ├── auth/            # Login, sign-up, splash screens & controller
│           ├── admin/           # Admin dashboard, product CRUD screens
│           ├── shop/            # Customer product listing & details
│           ├── cart/            # Cart management & checkout
│           └── orders/          # Order history
│
└── ecommerce_backend/           # Node.js REST API
    └── src/
        ├── config/              # Database & Cloudinary configuration
        ├── controllers/         # Route handler logic
        ├── middlewares/         # Auth & role-based access
        ├── models/              # Mongoose schemas (User, Product, Order)
        └── routes/              # Express route definitions
```

---

## Getting Started

### Prerequisites

- [Node.js](https://nodejs.org/) >= 18
- [Flutter](https://flutter.dev/) >= 3.35.0 (Dart >= 3.9.2)
- [MongoDB](https://www.mongodb.com/) (local or Atlas)
- [Cloudinary](https://cloudinary.com/) account (free tier works)
- An Android emulator or physical device

---

### Backend Setup

**1. Clone the repository and navigate to the backend:**
```bash
git clone https://github.com/your-username/stromin.git
cd stromin/ecommerce_backend
```

**2. Install dependencies:**
```bash
npm install
```

**3. Create a `.env` file** in `ecommerce_backend/` (see [Environment Variables](#environment-variables)):
```bash
cp .env.example .env
```

**4. Start the development server:**
```bash
npm run dev
```

The API will be available at `http://localhost:5000`.

---

### Flutter App Setup

**1. Navigate to the Flutter project:**
```bash
cd stromin/ecommerce_app
```

**2. Install Flutter dependencies:**
```bash
flutter pub get
```

**3. Configure the base URL** in `lib/core/constants/app_constants.dart`:

| Target | URL |
|---|---|
| Android Emulator | `http://10.0.2.2:5000/api` |
| Physical Device | `http://<YOUR_LOCAL_IP>:5000/api` |

**4. Run the app:**
```bash
flutter run
```

---

## Environment Variables

Create a `.env` file inside `ecommerce_backend/` with the following:

```env
NODE_ENV=development
PORT=5000

MONGO_URI=mongodb+srv://<username>:<password>@cluster.mongodb.net/stromin

JWT_SECRET=your_super_secret_jwt_key
JWT_EXPIRES_IN=30d

CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
```

> **Note:** Never commit your `.env` file. It is already listed in `.gitignore`.

---

## API Reference

### Auth
| Method | Endpoint | Access | Description |
|---|---|---|---|
| `POST` | `/api/auth/signup` | Public | Register a new user |
| `POST` | `/api/auth/login` | Public | Login & receive JWT |
| `GET` | `/api/auth/me` | Private | Get current user |

### Products
| Method | Endpoint | Access | Description |
|---|---|---|---|
| `GET` | `/api/products` | Public | List all products |
| `GET` | `/api/products/:id` | Public | Get single product |
| `POST` | `/api/products` | Admin | Create a product |
| `PUT` | `/api/products/:id` | Admin | Update a product |
| `DELETE` | `/api/products/:id` | Admin | Delete a product |

### Orders
| Method | Endpoint | Access | Description |
|---|---|---|---|
| `POST` | `/api/orders` | Customer | Place an order |
| `GET` | `/api/orders/myorders` | Customer | Get own orders |
| `GET` | `/api/orders` | Admin | Get all orders |
| `PUT` | `/api/orders/:id/status` | Admin | Update order status |

### Uploads
| Method | Endpoint | Access | Description |
|---|---|---|---|
| `POST` | `/api/upload/multiple` | Admin | Upload up to 5 images to Cloudinary |

---

## Architecture

```
Flutter App
    │
    ├── GetX Controllers  ──►  Dio HTTP Client
    │       │                       │
    │   Reactive State          Auth Interceptor
    │       │                  (injects JWT Bearer token)
    │   Screens / Widgets           │
    │                               ▼
    │                      Node.js / Express API
    │                               │
    │                   ┌──────────┴──────────┐
    │                   │                     │
    │               MongoDB               Cloudinary
    │             (Users, Products,      (Product Images)
    │               Orders)
    │
    └── FlutterSecureStorage (JWT)
        SharedPreferences (Cart)
```

**Key design decisions:**
- **GetX** is used for both state management and navigation, keeping controllers decoupled from the UI.
- A **global 401 interceptor** in `ApiClient` automatically logs out the user when the JWT expires, without requiring screen-level error handling.
- The cart is **persisted to disk** using `SharedPreferences` so it survives app restarts and cold launches.
- **Image uploads** are handled by Cloudinary via the backend, keeping credentials off the device.

---

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Commit your changes: `git commit -m 'feat: add your feature'`
4. Push to the branch: `git push origin feature/your-feature`
5. Open a Pull Request

---

## License

This project is licensed under the ISC License.
