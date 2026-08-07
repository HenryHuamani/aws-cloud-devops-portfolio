# Commands

## Lab 07 – Amazon RDS

This document contains the commands used throughout the implementation and validation of Amazon RDS for the NovaCommerce application.

---

# SSH Connection

Connect to the Amazon EC2 instance.

```bash
ssh -i "henry-key.pem" ec2-user@<EC2_PUBLIC_IP>
```

---

# System Update

Update the operating system packages.

```bash
sudo dnf update -y
```

---

# Install MariaDB Client

```bash
sudo dnf install mariadb105 -y
```

Verify installation.

```bash
mysql --version
```

---

# Download Amazon RDS SSL Certificate

```bash
curl -o global-bundle.pem \
https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem
```

---

# Connect to Amazon RDS

```bash
mysql \
-h <RDS_ENDPOINT> \
-P 3306 \
-u admin \
-p \
--ssl-ca="$HOME/global-bundle.pem" \
--ssl-verify-server-cert
```

---

# Database Commands

Show available databases.

```sql
SHOW DATABASES;
```

Use the NovaCommerce database.

```sql
USE novacommerce;
```

Show all tables.

```sql
SHOW TABLES;
```

Describe a table.

```sql
DESCRIBE clientes;
```

---

# Create Records

Insert categories.

```sql
INSERT INTO categorias (...);
```

Insert customers.

```sql
INSERT INTO clientes (...);
```

Insert products.

```sql
INSERT INTO productos (...);
```

Insert orders.

```sql
INSERT INTO pedidos (...);
```

Insert order details.

```sql
INSERT INTO detalle_pedido (...);
```

Insert inventory movements.

```sql
INSERT INTO inventario (...);
```

Insert payments.

```sql
INSERT INTO pagos (...);
```

---

# Read Operations

Query customers.

```sql
SELECT * FROM clientes;
```

Query products.

```sql
SELECT * FROM productos;
```

Query orders.

```sql
SELECT * FROM pedidos;
```

Query payments.

```sql
SELECT * FROM pagos;
```

---

# JOIN Queries

Sales report.

```sql
SELECT ...
FROM pedidos
JOIN clientes ...
JOIN detalle_pedido ...
JOIN productos ...
JOIN categorias ...
```

---

# Update Operations

Update order status.

```sql
UPDATE pedidos
SET estado='pagado'
WHERE pedido_id=1;
```

Update inventory.

```sql
UPDATE productos
SET stock=stock-1
WHERE producto_id=1;
```

---

# Delete Operations

Delete test records.

```sql
DELETE FROM categorias
WHERE nombre='Temporal';
```

---

# Validation

Check secure connection.

```sql
STATUS;
```

Verify schema.

```sql
SHOW TABLES;
```

Check database.

```sql
SHOW DATABASES;
```

---

# Linux Commands

DNS resolution.

```bash
getent hosts <RDS_ENDPOINT>
```

Download SSL certificate.

```bash
curl -o global-bundle.pem \
https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem
```

Check login history.

```bash
last -i
```

---

# Exit MySQL

```sql
EXIT;
```

Exit Linux.

```bash
exit
```