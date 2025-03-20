-- DROP DATABASE merch_store;

-- -- Create the database (run this separately if needed)
-- CREATE DATABASE merch_store;

-- Create categories table
CREATE TABLE categories (
  category_id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Create products table
CREATE TABLE products (
  product_id SERIAL PRIMARY KEY,
  category_id INTEGER REFERENCES categories(category_id),
  name VARCHAR(200) NOT NULL,
  description TEXT,
  price DECIMAL(10, 2) NOT NULL,
  sku VARCHAR(50) UNIQUE,
  image_url VARCHAR(255),
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP
);

-- Create inventory table
CREATE TABLE inventory (
  inventory_id SERIAL PRIMARY KEY,
  product_id INTEGER NOT NULL REFERENCES products(product_id),
  quantity INTEGER NOT NULL DEFAULT 0,
  last_updated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Create product_variants table for size, color, etc.
CREATE TABLE product_variants (
  variant_id SERIAL PRIMARY KEY,
  product_id INTEGER NOT NULL REFERENCES products(product_id),
  size VARCHAR(20),
  color VARCHAR(50),
  additional_price DECIMAL(10, 2) DEFAULT 0,
  inventory_count INTEGER NOT NULL DEFAULT 0
);

-- Insert sample data
-- Categories
INSERT INTO categories (name, description) VALUES
('T-Shirts', 'Comfortable cotton t-shirts in various designs'),
('Hoodies', 'Warm hoodies for cold weather'),
('Hats', 'Stylish caps and beanies'),
('Accessories', 'Pins, stickers, and other small items');

-- Products
INSERT INTO products (category_id, name, description, price, sku, image_url) VALUES
(1, 'Classic Logo Tee', 'A comfortable cotton t-shirt with our classic logo', 24.99, 'TSH-001', '/images/products/classic-tee.jpg'),
(1, 'Vintage Graphic Tee', 'Retro-inspired graphic t-shirt', 29.99, 'TSH-002', '/images/products/vintage-tee.jpg'),
(2, 'Pullover Hoodie', 'A warm pullover hoodie with front pocket', 49.99, 'HOD-001', '/images/products/pullover-hoodie.jpg'),
(2, 'Zip-up Hoodie', 'Zip-up hoodie with our logo on the back', 54.99, 'HOD-002', '/images/products/zip-hoodie.jpg'),
(3, 'Snapback Cap', 'Adjustable snapback cap with embroidered logo', 22.99, 'HAT-001', '/images/products/snapback.jpg'),
(4, 'Enamel Pin Set', 'Set of 3 colorful enamel pins', 12.99, 'ACC-001', '/images/products/pin-set.jpg');

-- Inventory
INSERT INTO inventory (product_id, quantity) VALUES
(1, 100),
(2, 75),
(3, 50),
(4, 60),
(5, 80),
(6, 120);

-- Product Variants
INSERT INTO product_variants (product_id, size, color, inventory_count) VALUES
(1, 'S', 'Black', 20),
(1, 'M', 'Black', 30),
(1, 'L', 'Black', 30),
(1, 'XL', 'Black', 20),
(1, 'S', 'White', 15),
(1, 'M', 'White', 25),
(1, 'L', 'White', 25),
(1, 'XL', 'White', 15),
(2, 'S', 'Gray', 15),
(2, 'M', 'Gray', 20),
(2, 'L', 'Gray', 25),
(2, 'XL', 'Gray', 15),
(3, 'M', 'Black', 15),
(3, 'L', 'Black', 20),
(3, 'XL', 'Black', 15),
(4, 'M', 'Navy', 20),
(4, 'L', 'Navy', 25),
(4, 'XL', 'Navy', 15);

-- Create trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
   NEW.updated_at = NOW();
   RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER update_product_modtime
BEFORE UPDATE ON products
FOR EACH ROW
EXECUTE FUNCTION update_modified_column();

-- Create index for common queries
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_inventory_product ON inventory(product_id);
CREATE INDEX idx_variants_product ON product_variants(product_id);

-- Create users table
CREATE TABLE users (
  user_id SERIAL PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  phone VARCHAR(20),
  is_admin BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP
);

-- Create addresses table
CREATE TABLE addresses (
  address_id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(user_id),
  address_type VARCHAR(20) NOT NULL, -- 'billing' or 'shipping'
  address_line1 VARCHAR(255) NOT NULL,
  address_line2 VARCHAR(255),
  city VARCHAR(100) NOT NULL,
  state VARCHAR(100) NOT NULL,
  postal_code VARCHAR(20) NOT NULL,
  country VARCHAR(100) NOT NULL DEFAULT 'United States',
  is_default BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP
);

-- Create payment_methods table
CREATE TABLE payment_methods (
  payment_method_id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL
);

-- Create order_statuses table
CREATE TABLE order_statuses (
  status_id SERIAL PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  description TEXT
);

-- Create orders table
CREATE TABLE orders (
  order_id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(user_id),
  status_id INTEGER NOT NULL REFERENCES order_statuses(status_id),
  shipping_address_id INTEGER NOT NULL REFERENCES addresses(address_id),
  billing_address_id INTEGER NOT NULL REFERENCES addresses(address_id),
  payment_method_id INTEGER NOT NULL REFERENCES payment_methods(payment_method_id),
  subtotal DECIMAL(10, 2) NOT NULL,
  tax DECIMAL(10, 2) NOT NULL,
  shipping_cost DECIMAL(10, 2) NOT NULL,
  total_amount DECIMAL(10, 2) NOT NULL,
  tracking_number VARCHAR(100),
  notes TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP
);

-- Create order_items table
CREATE TABLE order_items (
  order_item_id SERIAL PRIMARY KEY,
  order_id INTEGER NOT NULL REFERENCES orders(order_id),
  product_id INTEGER NOT NULL REFERENCES products(product_id),
  variant_id INTEGER REFERENCES product_variants(variant_id),
  quantity INTEGER NOT NULL,
  unit_price DECIMAL(10, 2) NOT NULL,
  subtotal DECIMAL(10, 2) NOT NULL
);

-- Create product_reviews table
CREATE TABLE product_reviews (
  review_id SERIAL PRIMARY KEY,
  product_id INTEGER NOT NULL REFERENCES products(product_id),
  user_id INTEGER NOT NULL REFERENCES users(user_id),
  rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
  review_text TEXT,
  is_verified_purchase BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Create coupons table
CREATE TABLE coupons (
  coupon_id SERIAL PRIMARY KEY,
  code VARCHAR(50) UNIQUE NOT NULL,
  description TEXT,
  discount_type VARCHAR(20) NOT NULL, -- 'percentage' or 'fixed'
  discount_value DECIMAL(10, 2) NOT NULL,
  min_purchase DECIMAL(10, 2) DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  starts_at TIMESTAMP,
  expires_at TIMESTAMP,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Create order_coupons table for tracking which coupons were used with orders
CREATE TABLE order_coupons (
  order_id INTEGER NOT NULL REFERENCES orders(order_id),
  coupon_id INTEGER NOT NULL REFERENCES coupons(coupon_id),
  discount_amount DECIMAL(10, 2) NOT NULL,
  PRIMARY KEY (order_id, coupon_id)
);

-- Create cart table for session shopping carts
CREATE TABLE cart (
  cart_id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(user_id),
  session_id VARCHAR(100), -- For guest users
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP
);

-- Create cart_items table
CREATE TABLE cart_items (
  cart_item_id SERIAL PRIMARY KEY,
  cart_id INTEGER NOT NULL REFERENCES cart(cart_id),
  product_id INTEGER NOT NULL REFERENCES products(product_id),
  variant_id INTEGER REFERENCES product_variants(variant_id),
  quantity INTEGER NOT NULL DEFAULT 1,
  added_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Add more triggers for updated_at timestamps
CREATE TRIGGER update_user_modtime
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION update_modified_column();

CREATE TRIGGER update_address_modtime
BEFORE UPDATE ON addresses
FOR EACH ROW
EXECUTE FUNCTION update_modified_column();

CREATE TRIGGER update_order_modtime
BEFORE UPDATE ON orders
FOR EACH ROW
EXECUTE FUNCTION update_modified_column();

CREATE TRIGGER update_cart_modtime
BEFORE UPDATE ON cart
FOR EACH ROW
EXECUTE FUNCTION update_modified_column();

-- Insert sample data for new tables
-- Sample users
INSERT INTO users (email, password_hash, first_name, last_name, phone, is_admin) VALUES
('admin@example.com', '$2a$12$1InE3Tg5PFHJgRfFNlZ0AOoaQnWM1HvNsHdryLlzwCr9HXl3.TQ0i', 'Admin', 'User', '555-123-4567', TRUE),
('customer1@example.com', '$2a$12$1InE3Tg5PFHJgRfFNlZ0AOoaQnWM1HvNsHdryLlzwCr9HXl3.TQ0i', 'John', 'Doe', '555-987-6543', FALSE),
('customer2@example.com', '$2a$12$1InE3Tg5PFHJgRfFNlZ0AOoaQnWM1HvNsHdryLlzwCr9HXl3.TQ0i', 'Jane', 'Smith', '555-456-7890', FALSE);

-- Sample addresses
INSERT INTO addresses (user_id, address_type, address_line1, city, state, postal_code, country, is_default) VALUES
(2, 'shipping', '123 Main St', 'Anytown', 'NY', '12345', 'United States', TRUE),
(2, 'billing', '123 Main St', 'Anytown', 'NY', '12345', 'United States', TRUE),
(3, 'shipping', '456 Oak Ave', 'Somewhere', 'CA', '94321', 'United States', TRUE),
(3, 'billing', '456 Oak Ave', 'Somewhere', 'CA', '94321', 'United States', TRUE);

-- Payment methods
INSERT INTO payment_methods (name) VALUES
('Credit Card'),
('PayPal'),
('Bank Transfer'),
('Apple Pay');

-- Order statuses
INSERT INTO order_statuses (name, description) VALUES
('Pending', 'Order has been placed but not yet processed'),
('Processing', 'Order is being prepared for shipment'),
('Shipped', 'Order has been shipped'),
('Delivered', 'Order has been delivered'),
('Cancelled', 'Order has been cancelled'),
('Returned', 'Order has been returned');

-- Sample orders
INSERT INTO orders (user_id, status_id, shipping_address_id, billing_address_id, 
                   payment_method_id, subtotal, tax, shipping_cost, total_amount) VALUES
(2, 3, 1, 2, 1, 79.98, 6.40, 5.00, 91.38),
(3, 2, 3, 4, 2, 54.99, 4.40, 5.00, 64.39);

-- Sample order items
INSERT INTO order_items (order_id, product_id, variant_id, quantity, unit_price, subtotal) VALUES
(1, 1, 3, 2, 24.99, 49.98),
(1, 6, NULL, 1, 12.99, 12.99),
(1, 3, 13, 1, 49.99, 49.99),
(2, 4, 16, 1, 54.99, 54.99);

-- Sample product reviews
INSERT INTO product_reviews (product_id, user_id, rating, review_text, is_verified_purchase) VALUES
(1, 2, 5, 'Great quality t-shirt, fits perfectly!', TRUE),
(3, 2, 4, 'Very comfortable hoodie, but runs a bit large.', TRUE),
(4, 3, 5, 'Love this zip-up, gets lots of compliments.', TRUE);

-- Sample coupons
INSERT INTO coupons (code, description, discount_type, discount_value, min_purchase, is_active) VALUES
('WELCOME10', 'Get 10% off your first order', 'percentage', 10.00, 0, TRUE),
('SUMMER2023', 'Summer sale discount', 'percentage', 15.00, 50.00, TRUE),
('FREESHIP', 'Free shipping on orders over $75', 'fixed', 5.00, 75.00, TRUE);

-- Create indexes for common queries
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_addresses_user ON addresses(user_id);
CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(status_id);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);
CREATE INDEX idx_product_reviews_product ON product_reviews(product_id);
CREATE INDEX idx_product_reviews_user ON product_reviews(user_id);
CREATE INDEX idx_cart_user ON cart(user_id);
CREATE INDEX idx_cart_items_cart ON cart_items(cart_id);
