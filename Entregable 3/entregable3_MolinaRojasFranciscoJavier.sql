DROP ROLE IF EXISTS rol_empleado, rol_cliente, rol_administrador;

CREATE ROLE rol_empleado;
CREATE ROLE rol_cliente;
CREATE ROLE rol_administrador;

--A pesar de crear un solo "usuario" por tipo de rol, se podria crear usuarios para cada empleado especifico de la tienda y para los administradores del sitio.
DROP USER IF EXISTS usuario_empleado, usuario_cliente, usuario_admin;
CREATE USER usuario_empleado;
CREATE USER usuario_cliente;
CREATE USER usuario_admin;


-- Apartado A)
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE proveedores, categorias, productos TO rol_empleado;
GRANT SELECT, INSERT, UPDATE ON TABLE ordenes, detalle_ordenes TO rol_empleado;
GRANT SELECT ON TABLE clientes, ordenes, detalle_ordenes, productos TO rol_cliente;
GRANT ALL PRIVILEGES ON TABLE empleados, proveedores, categorias, clientes, ordenes, detalle_ordenes, productos TO rol_administrador;

-- Apartado B)

DROP VIEW IF EXISTS vista_0,vista_1,vista_2,vista_3,vista_4,vista_5,vista_6;

--Vista numero 0
CREATE VIEW vista_0 AS
SELECT o.ordenid, e.apellido, e.nombre, c.nombrecia, o.fechaorden
FROM ordenes o
JOIN empleados e ON o.empleadoid = e.empleadoid
JOIN clientes c ON o.clienteid = c.clienteid;

--Vista numero 1
CREATE VIEW vista_1 AS
SELECT productoid, SUM(cantidad) AS total_pedidos
FROM detalle_ordenes
GROUP BY productoid;

--Vista numero 2
CREATE VIEW vista_2 AS
SELECT e.empleadoid, e.apellido, e.nombre, COALESCE(COUNT(o.ordenid), 0) AS ordenes_atendidas
FROM empleados e
LEFT JOIN ordenes o ON e.empleadoid = o.empleadoid
GROUP BY e.empleadoid
ORDER BY ordenes_atendidas DESC;

--Vista numero 3
CREATE VIEW vista_3 AS
SELECT p.proveedorid, p.nombreprov, SUM(preciounit * cantidad) AS total_ventas
FROM productos pr
JOIN proveedores p ON pr.proveedorid = p.proveedorid
JOIN detalle_ordenes d ON pr.productoid = d.productoid
GROUP BY p.proveedorid;

--Vista numero 4
CREATE VIEW vista_4 AS
SELECT categoriaid, COUNT(productoid) AS num_productos
FROM productos
GROUP BY categoriaid;

--Vista numero 5
CREATE VIEW vista_5 AS
SELECT
  c.clienteid,
  SUM(d.cantidad) AS cantidad_total,
  d.productoid,
  p.descripcion
FROM clientes c
LEFT JOIN ordenes o ON c.clienteid = o.clienteid
LEFT JOIN detalle_ordenes d ON o.ordenid = d.ordenid
LEFT JOIN productos p ON d.productoid = p.productoid
WHERE c.clienteid IN (
    SELECT c.clienteid
    FROM clientes c
    LEFT JOIN ordenes o ON c.clienteid = o.clienteid
    LEFT JOIN detalle_ordenes d ON o.ordenid = d.ordenid
    GROUP BY c.clienteid
    ORDER BY COUNT(d.ordenid) DESC
    LIMIT 1
)
GROUP BY c.clienteid, d.productoid, p.descripcion
ORDER BY c.clienteid, d.productoid;

--Vista numero 6
CREATE VIEW vista_6 AS
SELECT c.categoriaid, p.productoid, p.descripcion, pr.nombreprov, pr.emailprov
FROM productos p
JOIN categorias c ON p.categoriaid = c.categoriaid
JOIN proveedores pr ON p.proveedorid = pr.proveedorid;

-- Apartado C)

--Selecciono materializar la vista 3 y la vista 4 debido a que son consultas que frecuentemente se usaran y para asegurar su ejecución se almacenan en memoria
DROP MATERIALIZED VIEW IF EXISTS mat_view_3, mat_view_4;

CREATE MATERIALIZED VIEW mat_view_3 AS
SELECT p.proveedorid, p.nombreprov, SUM(preciounit * cantidad) AS total_ventas
FROM productos pr
JOIN proveedores p ON pr.proveedorid = p.proveedorid
JOIN detalle_ordenes d ON pr.productoid = d.productoid
GROUP BY p.proveedorid, p.nombreprov;

CREATE MATERIALIZED VIEW mat_view_4 AS
SELECT categoriaid, COUNT(productoid) AS num_productos
FROM productos
GROUP BY categoriaid;

-- Tiene sentido crear indice sobre atributos de tablas en los que hagamos muchas "queries" y podamos mejorar la eficiencia de busqueda en estos.
-- Propongo los siguientes indices (teniendio en cuenta que NO podemos seleccionar las CP debido a que estas estan pre-indexadas)
DROP INDEX IF EXISTS idx_ordenes_empleadoid, idx_productos_proveedorid;
CREATE INDEX idx_ordenes_empleadoid ON ordenes(empleadoid); 
CREATE INDEX idx_productos_proveedorid ON productos(proveedorid);
