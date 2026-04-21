-- PostgreSQL Setup Script for SoleERP
-- Run this as a PostgreSQL superuser before launching the app

-- Create the database
CREATE DATABASE shoes_erp_db;

-- Connect to the new database
\c shoes_erp_db;

-- Create a dedicated user (optional but recommended)
CREATE USER shoes_erp_user WITH PASSWORD 'SecurePassword123!';
GRANT ALL PRIVILEGES ON DATABASE shoes_erp_db TO shoes_erp_user;

-- The tables are auto-created on first app launch via DatabaseService.initializeDatabase()
-- But if you want to create them manually, here they are:

CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('hr_manager', 'supervisor')),
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    sku VARCHAR(50) UNIQUE NOT NULL,
    category VARCHAR(50) NOT NULL,
    description TEXT,
    available_sizes TEXT NOT NULL,
    available_colors TEXT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    image_url TEXT,
    material VARCHAR(100),
    gender VARCHAR(10) DEFAULT 'unisex',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS inventory (
    id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(id),
    size VARCHAR(10) NOT NULL,
    color VARCHAR(50) NOT NULL,
    quantity INTEGER DEFAULT 0,
    status VARCHAR(20) DEFAULT 'in_stock' CHECK (status IN ('in_stock','manufacturing','low_stock')),
    last_updated TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS raw_materials (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    unit VARCHAR(20) NOT NULL,
    quantity DECIMAL(10,2) DEFAULT 0,
    minimum_stock DECIMAL(10,2) DEFAULT 0,
    supplier VARCHAR(100),
    last_updated TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS manufacturing_batches (
    id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(id),
    quantity INTEGER NOT NULL,
    status VARCHAR(20) DEFAULT 'cutting' CHECK (status IN ('cutting','stitching','finishing','quality_check','completed')),
    start_date TIMESTAMP DEFAULT NOW(),
    expected_completion TIMESTAMP NOT NULL,
    supervisor_name VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS orders (
    id SERIAL PRIMARY KEY,
    order_number VARCHAR(20) UNIQUE NOT NULL,
    customer_name VARCHAR(100) NOT NULL,
    customer_email VARCHAR(100),
    customer_phone VARCHAR(20),
    shipping_address TEXT NOT NULL,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending','processing','shipped','delivered','cancelled')),
    total_amount DECIMAL(10,2) NOT NULL,
    order_date TIMESTAMP DEFAULT NOW(),
    estimated_delivery TIMESTAMP,
    tracking_number VARCHAR(50),
    notes TEXT
);

CREATE TABLE IF NOT EXISTS order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products(id),
    size VARCHAR(10) NOT NULL,
    color VARCHAR(50) NOT NULL,
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL
);

-- Default admin user (password: admin123)
INSERT INTO users (username, password, role, full_name, email)
VALUES ('admin', 'admin123', 'hr_manager', 'System Administrator', 'admin@shoesfactory.com')
ON CONFLICT (username) DO NOTHING;

-- Example supervisor user
INSERT INTO users (username, password, role, full_name, email)
VALUES ('supervisor1', 'super123', 'supervisor', 'John Smith', 'jsmith@shoesfactory.com')
ON CONFLICT (username) DO NOTHING;

-- Grant table permissions
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO shoes_erp_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO shoes_erp_user;
