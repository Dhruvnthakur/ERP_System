# SoleERP — Shoes Factory ERP System

A complete Enterprise Resource Planning (ERP) system built with **Flutter** and **PostgreSQL**, designed for shoes manufacturing factories.

---

## 📱 Features Overview

### 🔐 Authentication
- Role-based login: **HR Manager** and **Supervisor**
- Secure session with SharedPreferences
- Animated login screen with form validation

### 🏠 Dashboard (Home)
- Real-time KPIs: Revenue, Products, Orders, Low Stock, Production batches
- Quick action buttons (Add Product, Check Inventory, New Order, Reports)
- Logged-in user profile display
- Pull-to-refresh data

### 📦 Inventory Page
Three tabs:
1. **Stock** — All shoes in stock with low-stock alerts, status badges, size/color breakdown
2. **Manufacturing** — Active production batches with stage pipeline (Cutting → Stitching → Finishing → Quality Check → Done)
3. **Raw Materials** — Leather, rubber, fabric inventory with reorder warnings

### 🛍️ Products Page (Catalog)
- Grid/List view toggle
- Filter by Category (Athletic, Formal, Casual, etc.) and Gender
- Search by name or SKU
- Full product detail sheet (sizes, colors, material, pricing)
- Add/Edit products directly from catalog

### 📋 Orders Page
- Tab-filtered by status: All, Pending, Processing, Shipped, Delivered
- Revenue summary bar
- Order progress visualization
- Update order status via popup menu
- Add tracking numbers when marking as shipped
- Create new orders via dialog

---

## 🗂️ Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/
│   ├── user_model.dart         # User/role data model
│   ├── product_model.dart      # Shoe product model
│   ├── inventory_model.dart    # Inventory + raw materials + batches
│   └── order_model.dart        # Order + order items
├── screens/
│   ├── login_screen.dart       # Login / auth screen
│   ├── main_scaffold.dart      # Navigation shell (side nav + bottom nav)
│   ├── home_screen.dart        # Dashboard
│   ├── add_product_screen.dart # Add/edit product form
│   ├── inventory_screen.dart   # Inventory management
│   ├── product_screen.dart     # Product catalog
│   └── order_screen.dart       # Order management
├── services/
│   └── database_service.dart  # PostgreSQL CRUD layer
├── providers/
│   └── auth_provider.dart      # Auth state management
├── widgets/
│   └── common_widgets.dart     # Shared UI components
└── utils/
    └── app_theme.dart          # Dark theme + color helpers
```

---

## 🚀 Setup Instructions

### Step 1: Install Prerequisites
- Flutter SDK 3.0+
- PostgreSQL 14+
- Dart 3.0+

### Step 2: Set Up the Database

```bash
# Install PostgreSQL and start it
# On macOS: brew install postgresql && brew services start postgresql
# On Ubuntu: sudo apt install postgresql && sudo service postgresql start

# Run the setup script
psql -U postgres -f database_setup.sql
```

### Step 3: Configure Database Connection

Edit `lib/services/database_service.dart`:

```dart
static const String _host = 'localhost';     // Your PostgreSQL host
static const int _port = 5432;              // Default PostgreSQL port
static const String _database = 'shoes_erp_db';
static const String _username = 'postgres'; // Your PostgreSQL username
static const String _password = 'your_password'; // Your password
```

### Step 4: Install Flutter Dependencies

```bash
cd shoes_erp
flutter pub get
```

### Step 5: Create Asset Directories

```bash
mkdir -p assets/images assets/icons
```

### Step 6: Run the App

```bash
# Run on desktop (recommended for ERP)
flutter run -d macos    # or windows / linux

# Run on mobile
flutter run -d android  # or ios
```

---

## 🔑 Default Login Credentials

| Role         | Username     | Password   |
|--------------|-------------|------------|
| HR Manager   | `admin`     | `admin123` |
| Supervisor   | `supervisor1` | `super123` |

---

## 📊 Database Schema

```
users              products           inventory
├─ id              ├─ id              ├─ id
├─ username        ├─ name            ├─ product_id (FK)
├─ password        ├─ sku             ├─ size
├─ role            ├─ category        ├─ color
├─ full_name       ├─ description     ├─ quantity
└─ email           ├─ available_sizes └─ status
                   ├─ available_colors
raw_materials      ├─ price           manufacturing_batches
├─ id              ├─ material        ├─ id
├─ name            └─ gender          ├─ product_id (FK)
├─ unit                               ├─ quantity
├─ quantity        orders             ├─ status
├─ minimum_stock   ├─ id              ├─ start_date
└─ supplier        ├─ order_number    └─ expected_completion
                   ├─ customer_name
                   ├─ status
                   └─ total_amount
```

---

## 🎨 Tech Stack

| Layer       | Technology              |
|-------------|------------------------|
| Frontend    | Flutter (Dart)          |
| State Mgmt  | Provider                |
| Database    | PostgreSQL              |
| DB Client   | `postgres` Dart package |
| Charts      | fl_chart                |
| Persistence | shared_preferences      |

---

## 🔒 Security Notes

> For production use, implement:
> - Password hashing (bcrypt/argon2) instead of plain text
> - JWT tokens or session management
> - HTTPS/TLS for remote database connections
> - Environment variables for DB credentials (not hardcoded)
> - Role-based access control at the API layer

---

## 📱 Responsive Design

- **Desktop/Tablet (>800px)**: Side navigation rail
- **Mobile (<800px)**: Bottom navigation bar
- Adaptive grid columns based on screen width

---

*Built for shoes manufacturing ERP management*
