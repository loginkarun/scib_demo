-- SpringBoot API Test Data Setup Script
-- This script sets up test data for API testing
-- Run this script before executing API tests

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create test database schema if it doesn't exist
CREATE SCHEMA IF NOT EXISTS test_data;

-- Set search path to include test_data schema
SET search_path TO test_data, public;

-- =============================================
-- CLEANUP EXISTING TEST DATA
-- =============================================

-- Drop existing test data tables if they exist
DROP TABLE IF EXISTS test_data.order_items CASCADE;
DROP TABLE IF EXISTS test_data.orders CASCADE;
DROP TABLE IF EXISTS test_data.products CASCADE;
DROP TABLE IF EXISTS test_data.users CASCADE;
DROP TABLE IF EXISTS test_data.categories CASCADE;

-- =============================================
-- CREATE TEST TABLES
-- =============================================

-- Categories table
CREATE TABLE test_data.categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Users table
CREATE TABLE test_data.users (
    id SERIAL PRIMARY KEY,
    uuid UUID DEFAULT uuid_generate_v4() UNIQUE,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    role VARCHAR(50) DEFAULT 'USER',
    active BOOLEAN DEFAULT true,
    email_verified BOOLEAN DEFAULT false,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Products table
CREATE TABLE test_data.products (
    id SERIAL PRIMARY KEY,
    uuid UUID DEFAULT uuid_generate_v4() UNIQUE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    category_id INTEGER REFERENCES test_data.categories(id),
    subcategory VARCHAR(100),
    brand VARCHAR(100),
    sku VARCHAR(100) UNIQUE,
    stock INTEGER DEFAULT 0 CHECK (stock >= 0),
    weight DECIMAL(8,3),
    dimensions JSONB,
    features JSONB,
    active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Orders table
CREATE TABLE test_data.orders (
    id SERIAL PRIMARY KEY,
    uuid UUID DEFAULT uuid_generate_v4() UNIQUE,
    user_id INTEGER REFERENCES test_data.users(id),
    status VARCHAR(50) DEFAULT 'PENDING',
    total_amount DECIMAL(10,2) NOT NULL,
    shipping_address JSONB,
    billing_address JSONB,
    payment_method VARCHAR(50),
    payment_status VARCHAR(50) DEFAULT 'PENDING',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Order items table
CREATE TABLE test_data.order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES test_data.orders(id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES test_data.products(id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- CREATE INDEXES FOR PERFORMANCE
-- =============================================

CREATE INDEX idx_users_email ON test_data.users(email);
CREATE INDEX idx_users_uuid ON test_data.users(uuid);
CREATE INDEX idx_users_active ON test_data.users(active);
CREATE INDEX idx_products_category ON test_data.products(category_id);
CREATE INDEX idx_products_sku ON test_data.products(sku);
CREATE INDEX idx_products_active ON test_data.products(active);
CREATE INDEX idx_products_price ON test_data.products(price);
CREATE INDEX idx_orders_user ON test_data.orders(user_id);
CREATE INDEX idx_orders_status ON test_data.orders(status);
CREATE INDEX idx_order_items_order ON test_data.order_items(order_id);
CREATE INDEX idx_order_items_product ON test_data.order_items(product_id);

-- =============================================
-- INSERT TEST DATA
-- =============================================

-- Insert categories
INSERT INTO test_data.categories (name, description) VALUES
('Electronics', 'Electronic devices and gadgets'),
('Clothing', 'Apparel and fashion items'),
('Home & Garden', 'Home improvement and garden supplies'),
('Sports', 'Sports and fitness equipment'),
('Books', 'Books and educational materials'),
('Test', 'Test category for API testing');

-- Insert test users
INSERT INTO test_data.users (name, email, password_hash, phone, role, active, email_verified) VALUES
('John Doe', 'john.doe@example.com', '$2a$10$N9qo8uLOickgx2ZMRZoMye1VdLSnqpjLjMTYiaPi4YxdMw0q6Ue5u', '+1234567890', 'USER', true, true),
('Jane Smith', 'jane.smith@example.com', '$2a$10$N9qo8uLOickgx2ZMRZoMye1VdLSnqpjLjMTYiaPi4YxdMw0q6Ue5u', '+1234567891', 'USER', true, true),
('Admin User', 'admin@example.com', '$2a$10$N9qo8uLOickgx2ZMRZoMye1VdLSnqpjLjMTYiaPi4YxdMw0q6Ue5u', '+1234567892', 'ADMIN', true, true),
('Test Manager', 'manager@example.com', '$2a$10$N9qo8uLOickgx2ZMRZoMye1VdLSnqpjLjMTYiaPi4YxdMw0q6Ue5u', '+1234567893', 'MANAGER', true, true),
('Inactive User', 'inactive@example.com', '$2a$10$N9qo8uLOickgx2ZMRZoMye1VdLSnqpjLjMTYiaPi4YxdMw0q6Ue5u', '+1234567894', 'USER', false, false),
('Test User', 'testuser@example.com', '$2a$10$N9qo8uLOickgx2ZMRZoMye1VdLSnqpjLjMTYiaPi4YxdMw0q6Ue5u', '+1234567895', 'USER', true, true);

-- Insert test products
INSERT INTO test_data.products (name, description, price, category_id, subcategory, brand, sku, stock, weight, dimensions, features) VALUES
('Laptop Pro 15', 'High-performance laptop with 15-inch display', 1299.99, 1, 'Computers', 'TechBrand', 'LTP-PRO-15-001', 50, 2.1, 
 '{"length": 35.0, "width": 24.0, "height": 2.0}', 
 '["16GB RAM", "512GB SSD", "Intel i7 Processor", "Dedicated Graphics"]'),

('Wireless Headphones', 'Premium noise-cancelling wireless headphones', 299.99, 1, 'Audio', 'AudioTech', 'WH-NC-001', 100, 0.3,
 '{"length": 20.0, "width": 18.0, "height": 8.0}',
 '["Active Noise Cancellation", "30-hour battery life", "Bluetooth 5.0", "Quick charge"]'),

('Smart Watch Series 5', 'Advanced fitness tracking smartwatch', 399.99, 1, 'Wearables', 'WearTech', 'SW-S5-001', 75, 0.05,
 '{"length": 4.4, "width": 3.8, "height": 1.1}',
 '["Heart Rate Monitor", "GPS Tracking", "Water Resistant", "Sleep Tracking"]'),

('Gaming Mouse RGB', 'High-precision gaming mouse with RGB lighting', 79.99, 1, 'Gaming', 'GameTech', 'GM-RGB-001', 200, 0.12,
 '{"length": 12.5, "width": 6.8, "height": 4.2}',
 '["16000 DPI", "RGB Lighting", "Programmable Buttons", "Ergonomic Design"]'),

('Running Shoes', 'Professional running shoes for athletes', 129.99, 4, 'Footwear', 'SportsBrand', 'RS-PRO-001', 80, 0.8,
 '{"length": 30.0, "width": 12.0, "height": 10.0}',
 '["Breathable Material", "Shock Absorption", "Lightweight", "Durable"]'),

('Discontinued Product', 'This product is no longer available', 199.99, 1, 'Misc', 'OldTech', 'DISC-001', 0, 1.0,
 '{"length": 10.0, "width": 10.0, "height": 5.0}',
 '["Legacy Support"]');

-- Update the discontinued product to inactive
UPDATE test_data.products SET active = false WHERE sku = 'DISC-001';

-- Insert test orders
INSERT INTO test_data.orders (user_id, status, total_amount, shipping_address, payment_method, payment_status) VALUES
(1, 'COMPLETED', 1599.98, 
 '{"street": "123 Main St", "city": "Anytown", "state": "CA", "zip": "12345", "country": "USA"}',
 'CREDIT_CARD', 'PAID'),

(2, 'PENDING', 399.99,
 '{"street": "456 Oak Ave", "city": "Another City", "state": "NY", "zip": "67890", "country": "USA"}',
 'PAYPAL', 'PENDING'),

(1, 'SHIPPED', 79.99,
 '{"street": "123 Main St", "city": "Anytown", "state": "CA", "zip": "12345", "country": "USA"}',
 'CREDIT_CARD', 'PAID');

-- Insert order items
INSERT INTO test_data.order_items (order_id, product_id, quantity, unit_price, total_price) VALUES
(1, 1, 1, 1299.99, 1299.99),  -- Laptop
(1, 2, 1, 299.99, 299.99),    -- Headphones
(2, 3, 1, 399.99, 399.99),    -- Smart Watch
(3, 4, 1, 79.99, 79.99);      -- Gaming Mouse

-- =============================================
-- CREATE VIEWS FOR TESTING
-- =============================================

-- View for active products with category names
CREATE OR REPLACE VIEW test_data.active_products_view AS
SELECT 
    p.id,
    p.uuid,
    p.name,
    p.description,
    p.price,
    c.name as category_name,
    p.subcategory,
    p.brand,
    p.sku,
    p.stock,
    p.created_at
FROM test_data.products p
JOIN test_data.categories c ON p.category_id = c.id
WHERE p.active = true;

-- View for user order summary
CREATE OR REPLACE VIEW test_data.user_order_summary AS
SELECT 
    u.id as user_id,
    u.name as user_name,
    u.email,
    COUNT(o.id) as total_orders,
    COALESCE(SUM(o.total_amount), 0) as total_spent,
    MAX(o.created_at) as last_order_date
FROM test_data.users u
LEFT JOIN test_data.orders o ON u.id = o.user_id
WHERE u.active = true
GROUP BY u.id, u.name, u.email;

-- =============================================
-- CREATE FUNCTIONS FOR TESTING
-- =============================================

-- Function to get random test user
CREATE OR REPLACE FUNCTION test_data.get_random_test_user()
RETURNS TABLE(id INTEGER, name VARCHAR, email VARCHAR) AS $$
BEGIN
    RETURN QUERY
    SELECT u.id, u.name, u.email
    FROM test_data.users u
    WHERE u.active = true AND u.role = 'USER'
    ORDER BY RANDOM()
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- Function to get products by category
CREATE OR REPLACE FUNCTION test_data.get_products_by_category(category_name VARCHAR)
RETURNS TABLE(id INTEGER, name VARCHAR, price DECIMAL) AS $$
BEGIN
    RETURN QUERY
    SELECT p.id, p.name, p.price
    FROM test_data.products p
    JOIN test_data.categories c ON p.category_id = c.id
    WHERE c.name = category_name AND p.active = true;
END;
$$ LANGUAGE plpgsql;

-- Function to cleanup test data
CREATE OR REPLACE FUNCTION test_data.cleanup_test_data()
RETURNS VOID AS $$
BEGIN
    -- Delete test orders and related data
    DELETE FROM test_data.order_items WHERE order_id IN (
        SELECT id FROM test_data.orders WHERE user_id IN (
            SELECT id FROM test_data.users WHERE email LIKE '%test%' OR email LIKE '%example.com'
        )
    );
    
    DELETE FROM test_data.orders WHERE user_id IN (
        SELECT id FROM test_data.users WHERE email LIKE '%test%' OR email LIKE '%example.com'
    );
    
    -- Delete test products
    DELETE FROM test_data.products WHERE sku LIKE 'TEST-%' OR brand = 'TestBrand';
    
    -- Delete test users (except predefined ones)
    DELETE FROM test_data.users WHERE email LIKE '%test%' AND email NOT IN (
        'testuser@example.com',
        'admin@example.com',
        'manager@example.com'
    );
    
    RAISE NOTICE 'Test data cleanup completed';
END;
$$ LANGUAGE plpgsql;

-- =============================================
-- GRANT PERMISSIONS
-- =============================================

-- Grant permissions to application user (adjust username as needed)
-- GRANT ALL PRIVILEGES ON SCHEMA test_data TO your_app_user;
-- GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA test_data TO your_app_user;
-- GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA test_data TO your_app_user;
-- GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA test_data TO your_app_user;

-- =============================================
-- VERIFICATION QUERIES
-- =============================================

-- Verify data insertion
SELECT 'Categories' as table_name, COUNT(*) as record_count FROM test_data.categories
UNION ALL
SELECT 'Users' as table_name, COUNT(*) as record_count FROM test_data.users
UNION ALL
SELECT 'Products' as table_name, COUNT(*) as record_count FROM test_data.products
UNION ALL
SELECT 'Orders' as table_name, COUNT(*) as record_count FROM test_data.orders
UNION ALL
SELECT 'Order Items' as table_name, COUNT(*) as record_count FROM test_data.order_items;

-- Display sample data
SELECT 'Sample Users:' as info;
SELECT id, name, email, role, active FROM test_data.users LIMIT 3;

SELECT 'Sample Products:' as info;
SELECT id, name, price, sku, stock FROM test_data.products WHERE active = true LIMIT 3;

SELECT 'Sample Orders:' as info;
SELECT o.id, u.name as customer, o.status, o.total_amount 
FROM test_data.orders o 
JOIN test_data.users u ON o.user_id = u.id 
LIMIT 3;

-- =============================================
-- COMPLETION MESSAGE
-- =============================================

SELECT 'Test data setup completed successfully!' as status;
SELECT 'Run the following command to cleanup test data when needed:' as cleanup_info;
SELECT 'SELECT test_data.cleanup_test_data();' as cleanup_command;

-- Reset search path
RESET search_path;