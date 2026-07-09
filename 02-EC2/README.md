# Laboratorio 02 - Amazon EC2

## Objetivo

Implementar una instancia Amazon EC2 con Ubuntu Server, configurar el acceso seguro mediante SSH y comprender los componentes fundamentales para la administración de servidores en AWS.

---

## Servicios utilizados

- Amazon EC2
- Security Groups
- Key Pair
- SSH (OpenSSH)

---

## Arquitectura

```text
PowerShell (Windows)
        │
        │ SSH
        ▼
Security Group (Puerto 22)
        │
        ▼
Amazon EC2
Ubuntu Server 26.04
```

---

## Actividades realizadas

- Creación de una instancia EC2 tipo t3.micro.
- Selección de la imagen Ubuntu Server.
- Creación de un Key Pair (.pem).
- Configuración del Security Group permitiendo acceso SSH únicamente desde mi dirección IP.
- Conexión mediante SSH utilizando PowerShell.
- Diagnóstico y solución de problemas relacionados con los permisos del archivo `.pem`.
- Validación del acceso exitoso a la instancia Linux.

---

## Problema encontrado

Durante la conexión SSH, OpenSSH rechazó la llave privada debido a permisos demasiado abiertos en Windows.

### Error

```
WARNING: UNPROTECTED PRIVATE KEY FILE!
Permissions are too open.
Permission denied (publickey)
```

### Solución

Se modificaron los permisos del archivo `.pem` utilizando `icacls`, eliminando el acceso del grupo **BUILTIN\Usuarios** y dejando únicamente los permisos necesarios para el propietario.

---

## Comandos utilizados

```bash
ssh -i henry-key.pem ubuntu@<DNS_PUBLICO>

whoami

hostname

pwd

ls
```

---

## Evidencias

| Evidencia | Descripción |
|-----------|-------------|
| 01-ec2-dashboard.png | Consola EC2 |
| 02-instance-details.png | Detalles de la instancia |
| 03-security-group.png | Configuración del Security Group |
| 04-connect-error.png | Error inicial de conexión |
| 05-ssh-permissions-error.png | Error por permisos del archivo PEM |
| 06-ssh-success.png | Conexión exitosa mediante SSH |

---

## Buenas prácticas aplicadas

- Restringir el puerto 22 únicamente a la IP pública del administrador.
- Utilizar autenticación mediante llaves SSH.
- No compartir archivos `.pem`.
- Resolver problemas de permisos antes de utilizar la llave privada.

---

## Lecciones aprendidas

- Amazon EC2 permite desplegar servidores virtuales bajo demanda.
- Los Security Groups funcionan como firewall de la instancia.
- SSH es el método recomendado para la administración remota de servidores Linux.
- En Windows, OpenSSH exige permisos restringidos sobre los archivos `.pem`.

---

## Próximos pasos

En el siguiente laboratorio se trabajará con Amazon S3 para comprender el almacenamiento de objetos en AWS.
