-- ============================================================
-- Sample Data
-- ============================================================

USE novacommerce;

-- Categories

INSERT INTO categorias (nombre, descripcion)
VALUES
('Tecnología','Electronic devices and accessories'),
('Hogar','Home products'),
('Oficina','Office supplies');

-- Customers

INSERT INTO clientes
(
nombres,
apellidos,
correo,
telefono,
direccion
)
VALUES
(
'Henry Junior',
'Huamani',
'henry@novacommerce.com',
'999111111',
'Lima'
),
(
'Kristell Margarita',
'Castañeda Sarmiento',
'kristell@novacommerce.com',
'999222222',
'Chanchamayo'
),
(
'Carlos',
'Mendoza',
'carlos@novacommerce.com',
'999333333',
'Arequipa'
);

-- Products

INSERT INTO productos
(
categoria_id,
nombre,
descripcion,
precio,
stock
)
VALUES
(
1,
'Laptop NovaBook',
'Professional Laptop',
2899.90,
10
),
(
1,
'Wireless Mouse',
'USB Mouse',
79.90,
40
),
(
2,
'LED Lamp',
'Modern desk lamp',
119.90,
20
),
(
3,
'Office Chair',
'Ergonomic chair',
649.90,
8
);

-- Order

INSERT INTO pedidos
(
cliente_id,
estado,
total
)
VALUES
(
1,
'pagado',
3059.70
);

SET @pedido := LAST_INSERT_ID();

-- Order Details

INSERT INTO detalle_pedido
(
pedido_id,
producto_id,
cantidad,
precio_unitario,
subtotal
)
VALUES
(
@pedido,
1,
1,
2899.90,
2899.90
),
(
@pedido,
2,
2,
79.90,
159.80
);

-- Inventory

INSERT INTO inventario
(
producto_id,
tipo_movimiento,
cantidad,
observacion
)
VALUES
(
1,
'salida',
1,
'Sale Order'
),
(
2,
'salida',
2,
'Sale Order'
);

-- Payments

INSERT INTO pagos
(
pedido_id,
metodo_pago,
monto,
estado
)
VALUES
(
@pedido,
'yape',
3059.70,
'procesado'
);