-- Comparador de Compras de Productos de Tecnología — UAN 2026-I
-- PostgreSQL schema ONLY (sin datos)
-- Para importar datos, use schema_and_data.sql o cargue los CSV/JSON

DROP TABLE IF EXISTS product_prices CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS stores CASCADE;
DROP TABLE IF EXISTS brands CASCADE;
DROP TABLE IF EXISTS categories CASCADE;

CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE brands (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE stores (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) NOT NULL UNIQUE,
    url VARCHAR(255),
    city VARCHAR(100)
);

CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    category_id INTEGER NOT NULL REFERENCES categories(id),
    brand_id INTEGER NOT NULL REFERENCES brands(id),
    name VARCHAR(500) NOT NULL,
    model VARCHAR(200),
    description TEXT,
    image_url VARCHAR(500),
    specifications JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE product_prices (
    id SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL REFERENCES products(id),
    store_id INTEGER NOT NULL REFERENCES stores(id),
    price INTEGER NOT NULL,
    original_price INTEGER,
    currency VARCHAR(10) DEFAULT 'COP',
    availability VARCHAR(50) DEFAULT 'disponible',
    url VARCHAR(500),
    last_updated DATE DEFAULT CURRENT_DATE
);

CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_brand ON products(brand_id);
CREATE INDEX idx_prices_product ON product_prices(product_id);
CREATE INDEX idx_prices_store ON product_prices(store_id);
CREATE INDEX idx_prices_price ON product_prices(price);
CREATE INDEX idx_products_specs ON products USING GIN(specifications);