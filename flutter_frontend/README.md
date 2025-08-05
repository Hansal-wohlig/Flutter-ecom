# Flutter E-Commerce Frontend

This is a Flutter implementation of the e-commerce frontend that connects to the existing Node.js backend.

## Features

- User authentication (Email/Password and Google Sign-In)
- Product browsing with category filtering
- Shopping cart management
- User profile management
- Stripe payment integration

## Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Node.js backend running on `http://localhost:5000`
- Stripe account and API keys

## Setup

1. Clone the repository and navigate to the flutter_frontend directory:
```bash
cd flutter_frontend
```

2. Install dependencies:
```bash
flutter pub get
```

3. Create a `.env` file in the root directory with the following content:
```
STRIPE_PUBLISHABLE_KEY=your_stripe_publishable_key
```

4. Make sure the backend server is running on `http://localhost:5000`

## Running the App

1. Start an emulator or connect a physical device

2. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
  ├── main.dart              # App entry point and initialization
  ├── providers/             # State management
  │   ├── auth_provider.dart # Authentication state
  │   └── cart_provider.dart # Shopping cart state
  ├── screens/               # App screens
  │   ├── home_screen.dart   # Main screen with bottom navigation
  │   ├── login_screen.dart  # Login screen
  │   ├── register_screen.dart # Registration screen
  │   ├── shop_screen.dart   # Product listing
  │   ├── cart_screen.dart   # Shopping cart
  │   └── profile_screen.dart # User profile
  └── widgets/               # Reusable widgets
      └── cart_item_widget.dart # Cart item display
```

## Backend API Integration

The app connects to the following backend endpoints:

- Authentication:
  - POST `/api/users/register` - User registration
  - POST `/api/users/login` - User login
  - GET `/api/users/profile` - Get user profile
  - GET `/auth/google` - Google authentication

- Products:
  - GET `/api/products` - Get all products
  - GET `/api/products/:id` - Get product details

- Cart:
  - GET `/api/cart` - Get cart items
  - POST `/api/cart/add` - Add item to cart
  - PUT `/api/cart/update` - Update item quantity
  - DELETE `/api/cart/remove/:id` - Remove item from cart
  - DELETE `/api/cart/clear` - Clear cart

## State Management

The app uses Provider for state management with two main providers:

- `AuthProvider`: Handles user authentication state and API calls
- `CartProvider`: Manages shopping cart state and operations

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request 