-- ============================================================
-- Database Views
-- ============================================================

USE novacommerce;

DROP VIEW IF EXISTS vista_ventas;

CREATE VIEW vista_ventas AS

SELECT

pe.pedido_id,

CONCAT(
cl.nombres,
' ',
cl.apellidos
) AS cliente,

cl.correo,

pr.nombre AS producto,

ca.nombre AS categoria,

dp.cantidad,

dp.precio_unitario,

dp.subtotal,

pa.metodo_pago,

pa.estado AS estado_pago,

pe.estado AS estado_pedido,

pe.fecha_pedido

FROM pedidos pe

INNER JOIN clientes cl
ON pe.cliente_id = cl.cliente_id

INNER JOIN detalle_pedido dp
ON pe.pedido_id = dp.pedido_id

INNER JOIN productos pr
ON dp.producto_id = pr.producto_id

INNER JOIN categorias ca
ON pr.categoria_id = ca.categoria_id

INNER JOIN pagos pa
ON pe.pedido_id = pa.pedido_id;