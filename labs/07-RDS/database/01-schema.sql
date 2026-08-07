-- ============================================================
-- AWS Cloud & DevOps Portfolio
-- Lab 07 - Amazon RDS
-- NovaCommerce Database Schema
--
-- Author : Henry Huamani
-- Purpose: Create the complete NovaCommerce relational schema
-- ============================================================

CREATE DATABASE IF NOT EXISTS novacommerce;

USE novacommerce;

-- ============================================================
-- Customers
-- ============================================================

CREATE TABLE clientes (
    cliente_id INT AUTO_INCREMENT PRIMARY KEY,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    correo VARCHAR(150) NOT NULL UNIQUE,
    telefono VARCHAR(20),
    direccion VARCHAR(255),
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- Categories
-- ============================================================

CREATE TABLE categorias (
    categoria_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion VARCHAR(255),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- Products
-- ============================================================

CREATE TABLE productos (
    producto_id INT AUTO_INCREMENT PRIMARY KEY,
    categoria_id INT NOT NULL,
    nombre VARCHAR(150) NOT NULL,
    descripcion VARCHAR(255),
    precio DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    estado ENUM('activo','inactivo') DEFAULT 'activo',
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_producto_categoria
        FOREIGN KEY (categoria_id)
        REFERENCES categorias(categoria_id)
);

-- ============================================================
-- Orders
-- ============================================================

CREATE TABLE pedidos (
    pedido_id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    fecha_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado ENUM(
        'pendiente',
        'pagado',
        'enviado',
        'entregado',
        'cancelado'
    ) DEFAULT 'pendiente',
    total DECIMAL(10,2) DEFAULT 0,

    CONSTRAINT fk_pedido_cliente
        FOREIGN KEY (cliente_id)
        REFERENCES clientes(cliente_id)
);

-- ============================================================
-- Order Details
-- ============================================================

CREATE TABLE detalle_pedido (
    detalle_id INT AUTO_INCREMENT PRIMARY KEY,
    pedido_id INT NOT NULL,
    producto_id INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,

    CONSTRAINT fk_detalle_pedido
        FOREIGN KEY (pedido_id)
        REFERENCES pedidos(pedido_id),

    CONSTRAINT fk_detalle_producto
        FOREIGN KEY (producto_id)
        REFERENCES productos(producto_id)
);

-- ============================================================
-- Inventory
-- ============================================================

CREATE TABLE inventario (
    movimiento_id INT AUTO_INCREMENT PRIMARY KEY,
    producto_id INT NOT NULL,
    tipo_movimiento ENUM(
        'entrada',
        'salida',
        'ajuste'
    ) NOT NULL,
    cantidad INT NOT NULL,
    observacion VARCHAR(255),
    fecha_movimiento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_inventario_producto
        FOREIGN KEY (producto_id)
        REFERENCES productos(producto_id)
);

-- ============================================================
-- Payments
-- ============================================================

CREATE TABLE pagos (
    pago_id INT AUTO_INCREMENT PRIMARY KEY,
    pedido_id INT NOT NULL,
    metodo_pago ENUM(
        'tarjeta',
        'transferencia',
        'yape',
        'plin',
        'efectivo'
    ) NOT NULL,
    monto DECIMAL(10,2) NOT NULL,
    estado ENUM(
        'pendiente',
        'procesado',
        'rechazado'
    ) DEFAULT 'pendiente',
    fecha_pago TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_pago_pedido
        FOREIGN KEY (pedido_id)
        REFERENCES pedidos(pedido_id)
);