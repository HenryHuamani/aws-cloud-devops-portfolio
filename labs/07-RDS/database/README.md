# NovaCommerce Database

This directory contains all SQL artifacts required to recreate the NovaCommerce database used throughout the AWS Cloud & DevOps Portfolio.

---

# Contents

| File | Description |
|------|-------------|
| 01-schema.sql | Creates the NovaCommerce database, tables, Primary Keys, and Foreign Keys. |
| 02-sample-data.sql | Inserts sample business data for validation and testing. |
| 03-views.sql | Creates reusable reporting views. |

---

# Execution Order

Execute the scripts in the following order:

```text
01-schema.sql

↓

02-sample-data.sql

↓

03-views.sql
```

---

# Prerequisites

Before executing the scripts:

- Amazon RDS MySQL must be running.
- The database endpoint must be reachable.
- SSL/TLS connectivity must be configured.
- The database administrator credentials must be available.

---

# Example

Connect to Amazon RDS:

```bash
mysql \
-h <RDS_ENDPOINT> \
-P 3306 \
-u admin \
-p \
--ssl-ca="$HOME/global-bundle.pem" \
--ssl-verify-server-cert
```

Execute the schema:

```sql
SOURCE database/01-schema.sql;
```

Load sample data:

```sql
SOURCE database/02-sample-data.sql;
```

Create the views:

```sql
SOURCE database/03-views.sql;
```

---

# Validation

Verify the installation:

```sql
SHOW DATABASES;

USE novacommerce;

SHOW TABLES;

SELECT * FROM vista_ventas;
```

The expected database should contain the following tables:

- categorias
- clientes
- productos
- inventario
- pedidos
- detalle_pedido
- pagos

and the following view:

- vista_ventas

---

# Notes

These scripts are idempotent whenever possible and are intended for learning purposes within the AWS Cloud & DevOps Portfolio.

The database model represents the persistence layer of the fictional e-commerce application **NovaCommerce**, which will be reused in subsequent laboratories involving Application Load Balancers, Containers, CI/CD pipelines, and Kubernetes.