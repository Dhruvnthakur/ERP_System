-- ══════════════════════════════════════════════════════════════════════════════
--  SoleERP — Supabase Setup Script
--  Run this in: Supabase Dashboard → SQL Editor → New Query → Run
-- ══════════════════════════════════════════════════════════════════════════════

-- ── 1. TABLES ─────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS users (
  id         SERIAL PRIMARY KEY,
  username   VARCHAR(50)  UNIQUE NOT NULL,
  password   VARCHAR(255) NOT NULL,
  role       VARCHAR(20)  NOT NULL CHECK (role IN ('hr_manager', 'supervisor')),
  full_name  VARCHAR(100) NOT NULL,
  email      VARCHAR(100) NOT NULL,
  created_at TIMESTAMPTZ  DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS products (
  id               SERIAL PRIMARY KEY,
  name             VARCHAR(100) NOT NULL,
  sku              VARCHAR(50)  UNIQUE NOT NULL,
  category         VARCHAR(50)  NOT NULL,
  description      TEXT,
  available_sizes  TEXT NOT NULL,
  available_colors TEXT NOT NULL,
  price            DECIMAL(10,2) NOT NULL,
  image_url        TEXT,
  material         VARCHAR(100),
  gender           VARCHAR(10)  DEFAULT 'unisex',
  is_active        BOOLEAN      DEFAULT TRUE,
  created_at       TIMESTAMPTZ  DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS inventory (
  id           SERIAL PRIMARY KEY,
  product_id   INTEGER REFERENCES products(id) ON DELETE CASCADE,
  size         VARCHAR(10)  NOT NULL,
  color        VARCHAR(50)  NOT NULL,
  quantity     INTEGER      DEFAULT 0,
  status       VARCHAR(20)  DEFAULT 'in_stock'
                CHECK (status IN ('in_stock','manufacturing','low_stock')),
  last_updated TIMESTAMPTZ  DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS raw_materials (
  id            SERIAL PRIMARY KEY,
  name          VARCHAR(100)   NOT NULL,
  unit          VARCHAR(20)    NOT NULL,
  quantity      DECIMAL(10,2)  DEFAULT 0,
  minimum_stock DECIMAL(10,2)  DEFAULT 0,
  supplier      VARCHAR(100),
  last_updated  TIMESTAMPTZ    DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS manufacturing_batches (
  id                  SERIAL PRIMARY KEY,
  product_id          INTEGER REFERENCES products(id) ON DELETE CASCADE,
  quantity            INTEGER NOT NULL,
  status              VARCHAR(20) DEFAULT 'cutting'
                        CHECK (status IN ('cutting','stitching','finishing','quality_check','completed')),
  start_date          TIMESTAMPTZ DEFAULT NOW(),
  expected_completion TIMESTAMPTZ NOT NULL,
  supervisor_name     VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS orders (
  id                SERIAL PRIMARY KEY,
  order_number      VARCHAR(20) UNIQUE NOT NULL,
  customer_name     VARCHAR(100) NOT NULL,
  customer_email    VARCHAR(100),
  customer_phone    VARCHAR(20),
  shipping_address  TEXT NOT NULL,
  status            VARCHAR(20) DEFAULT 'pending'
                      CHECK (status IN ('pending','processing','shipped','delivered','cancelled')),
  total_amount      DECIMAL(10,2) NOT NULL,
  order_date        TIMESTAMPTZ DEFAULT NOW(),
  estimated_delivery TIMESTAMPTZ,
  tracking_number   VARCHAR(50),
  notes             TEXT
);

CREATE TABLE IF NOT EXISTS order_items (
  id         SERIAL PRIMARY KEY,
  order_id   INTEGER REFERENCES orders(id)   ON DELETE CASCADE,
  product_id INTEGER REFERENCES products(id) ON DELETE SET NULL,
  size       VARCHAR(10)   NOT NULL,
  color      VARCHAR(50)   NOT NULL,
  quantity   INTEGER       NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL
);

-- ── 2. ROW LEVEL SECURITY (RLS) ───────────────────────────────────────────────
-- Enable RLS on all tables but allow all operations via anon key.
-- For production, replace these with proper role-based policies.

ALTER TABLE users                 ENABLE ROW LEVEL SECURITY;
ALTER TABLE products              ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory             ENABLE ROW LEVEL SECURITY;
ALTER TABLE raw_materials         ENABLE ROW LEVEL SECURITY;
ALTER TABLE manufacturing_batches ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders                ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items           ENABLE ROW LEVEL SECURITY;

-- Allow full access to anon role (matches your anonKey from Flutter app)
CREATE POLICY "allow_all_users"         ON users                 FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "allow_all_products"      ON products              FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "allow_all_inventory"     ON inventory             FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "allow_all_raw_materials" ON raw_materials         FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "allow_all_batches"       ON manufacturing_batches FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "allow_all_orders"        ON orders                FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "allow_all_order_items"   ON order_items           FOR ALL TO anon USING (true) WITH CHECK (true);

-- ── 3. SEED DATA ──────────────────────────────────────────────────────────────

-- Default users
INSERT INTO users (username, password, role, full_name, email) VALUES
  ('admin',       'admin123', 'hr_manager', 'System Administrator', 'admin@shoesfactory.com'),
  ('supervisor1', 'super123', 'supervisor',  'John Smith',           'jsmith@shoesfactory.com')
ON CONFLICT (username) DO NOTHING;

-- Sample products
INSERT INTO products (name, sku, category, description, available_sizes, available_colors, price, material, gender) VALUES
  ('AirWalk Pro',    'AWP-001', 'Athletic', 'High-performance running shoes',    '38,39,40,41,42,43,44,45', 'Black,White,Red,Blue',  89.99,  'Mesh+Rubber',    'unisex'),
  ('Classic Oxford', 'COX-001', 'Formal',   'Timeless leather oxford shoes',     '38,39,40,41,42,43,44',    'Black,Brown,Tan',       149.99, 'Genuine Leather','men'),
  ('SkyHigh Heels',  'SHH-001', 'Formal',   'Elegant stiletto heels',            '35,36,37,38,39,40',       'Black,Nude,Red',        119.99, 'Patent Leather', 'women'),
  ('Trail Blazer',   'TRB-001', 'Outdoor',  'Rugged hiking boots',               '39,40,41,42,43,44,45',    'Brown,Khaki,Black',     179.99, 'Nubuck+Rubber',  'unisex'),
  ('Kiddo Runner',   'KDR-001', 'Kids',     'Comfortable kids running shoes',    '28,29,30,31,32,33,34',    'Pink,Blue,Green,Red',   49.99,  'Synthetic',      'kids')
ON CONFLICT (sku) DO NOTHING;

-- Inventory
INSERT INTO inventory (product_id, size, color, quantity, status)
SELECT p.id, v.size, v.color, v.quantity::int, v.status
FROM products p
JOIN (VALUES
  ('AWP-001','42','Black', '150','in_stock'),
  ('AWP-001','43','White', '80', 'in_stock'),
  ('AWP-001','41','Red',   '25', 'low_stock'),
  ('COX-001','42','Black', '60', 'in_stock'),
  ('COX-001','43','Brown', '45', 'in_stock'),
  ('SHH-001','38','Black', '90', 'in_stock'),
  ('TRB-001','42','Brown', '35', 'in_stock'),
  ('KDR-001','30','Pink',  '120','in_stock')
) AS v(sku, size, color, quantity, status) ON p.sku = v.sku
WHERE NOT EXISTS (SELECT 1 FROM inventory);

-- Raw materials
INSERT INTO raw_materials (name, unit, quantity, minimum_stock, supplier) VALUES
  ('Leather (Full Grain)',  'sq ft',  2500, 500,  'Premium Hides Co.'),
  ('Rubber Sole Material',  'kg',      800, 200,  'SoleTech Industries'),
  ('Mesh Fabric',           'meters', 1200, 300,  'TextilePro Ltd.'),
  ('Laces',                 'pairs',  5000, 1000, 'AccessoryWorld'),
  ('Adhesive Glue',         'liters',  150, 50,   'BindTech'),
  ('Thread (Nylon)',         'spools',  400, 100,  'ThreadMasters'),
  ('Foam Insole',           'units',  3000, 600,  'ComfortFoam Inc.'),
  ('Eyelets',               'boxes',   200, 50,   'MetalParts Co.')
ON CONFLICT DO NOTHING;

-- Manufacturing batches
INSERT INTO manufacturing_batches (product_id, quantity, status, expected_completion, supervisor_name)
SELECT p.id, v.qty::int, v.status, NOW() + v.eta::interval, v.supervisor
FROM products p
JOIN (VALUES
  ('AWP-001', '500', 'stitching',    '5 days',  'John Smith'),
  ('COX-001', '200', 'cutting',      '8 days',  'Maria Garcia'),
  ('SHH-001', '300', 'finishing',    '3 days',  'David Lee'),
  ('TRB-001', '150', 'quality_check','1 day',   'John Smith')
) AS v(sku, qty, status, eta, supervisor) ON p.sku = v.sku
WHERE NOT EXISTS (SELECT 1 FROM manufacturing_batches);

-- Sample orders
INSERT INTO orders (order_number, customer_name, customer_email, customer_phone, shipping_address, status, total_amount, estimated_delivery) VALUES
  ('ORD-2024-001','Global Shoes Retail', 'orders@globalshoes.com',  '+1-555-0100','123 Retail Ave, New York, NY 10001',         'shipped',    8999.00,  NOW() + INTERVAL '2 days'),
  ('ORD-2024-002','SportZone Chain',     'purchasing@sportzone.com', '+1-555-0200','456 Commerce Blvd, Los Angeles, CA 90001',   'processing', 14999.50, NOW() + INTERVAL '5 days'),
  ('ORD-2024-003','Elite Fashion House', 'buyer@elitefashion.com',   '+1-555-0300','789 Luxury Lane, Chicago, IL 60601',         'pending',    5999.75,  NOW() + INTERVAL '7 days'),
  ('ORD-2024-004','Kids World Stores',   'orders@kidsworld.com',     '+1-555-0400','321 Family St, Houston, TX 77001',           'delivered',  2499.50,  NOW() - INTERVAL '2 days'),
  ('ORD-2024-005','Mountain Gear Co',    'procurement@mgear.com',    '+1-555-0500','654 Adventure Rd, Denver, CO 80201',         'pending',    26998.50, NOW() + INTERVAL '10 days')
ON CONFLICT (order_number) DO NOTHING;

-- ── Done ─────────────────────────────────────────────────────────────────────
-- All 7 tables created, RLS enabled, seed data inserted.
-- Return to your Flutter app and update the credentials in database_service.dart
