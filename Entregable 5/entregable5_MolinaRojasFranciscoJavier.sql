DROP DATABASE IF EXISTS empresa_logistica;
CREATE DATABASE empresa_logistica;
\c empresa_logistica

DROP TABLE IF EXISTS usuarios CASCADE;
DROP TABLE IF EXISTS trabajadores CASCADE;
DROP TABLE IF EXISTS proveedores CASCADE;
DROP TABLE IF EXISTS productos CASCADE;
DROP TABLE IF EXISTS pedidos CASCADE;

DROP ROLE IF EXISTS rol_principal, rol_colaborador, rol_eventual, rol_junior, rol_externo;

-- Una compañia de venta de productos y logistica necesita informatizar sus servicios. Despues de una ardua busqueda, te encuentran como programador independiente y te hacen una oferta que no puedes rechazar
-- A cambio del importe acordado, te comprometes a crear un sistema de bases de datos que satisfaga las necesidadeas de la empresa.
-- Las necesidades son las siguientes: 
-- Almacenar información relativa a: usuarios, trabajadores, productos (junto a sus proveedores), y los pedidos.
-- Es importante saber que un producto será proveido por un solo proveedor y un proveedor puede proveer varios productos. Un usuario puede realizar varios pedidos. Cada pedido es hecho por un usuario y supervisado por un trabajador 
-- Y cada pedido tiene asociado UN solo producto. Por ultimo, la empresa te proporciona la informacion que debes guardar de cada uno de estos.

-- Con esto decides ponerte en marcha, primero creando la base de datos en un servicio postgres (puedes verlas al principio del fichero)

-- Con la base de datos creada te dispones a crear un script que creará las tablas, y en el proceso de creacion, recuerdas un fallo comun que tu profesor de prácticas de administracion de bases de datos solia recordar en clase. 
-- Debes crear las tablas de forma en la que no haya entrelazados de tablas (no se creen tablas que dependen de otras sin haber creado las que se necesita)


CREATE TABLE usuarios(
    DNIusuario char(9) NOT NULL,
    Nombre char(50) NOT NULL,
    Apellidos char(70),
    Telefono char(12) NOT NULL,
    Correo char(60) NOT NULL,
    Direccion char(100) NOT NULL,
    PRIMARY KEY (DNIusuario)
);


CREATE TABLE trabajadores(
    DNItrabajador char(9) NOT NULL,
    Nombre char(50) NOT NULL,
    Apellidos char(70),
    Telefono char(12) NOT NULL,
    Correo char(60) NOT NULL,
    Direccion char(100) NOT NULL,
    IBAN char(34) NOT NULL,
    Puesto char(30) NOT NULL default 'Puesto no formalizado todavia',
    PRIMARY KEY(DNItrabajador)
);


CREATE TABLE proveedores(
    CIFproveedor char(9) NOT NULL,
    Nombre char(50) NOT NULL,
    IBAN char(34) NOT NULL,
    Telefono char(12) NOT NULL,
    Direccion char(100) NOT NULL,
    PRIMARY KEY(CIFproveedor)
);


CREATE TABLE productos(
    Idproducto int NOT NULL,
    Nombre char(50) NOT NULL,
    Descripcion char(100) NOT NULL,
    Categoria char(30) NOT NULL,
    Precio float NOT NULL,
    CIFproveedor char(9) NOT NULL,
    PRIMARY KEY (Idproducto),
    CONSTRAINT productos_fk FOREIGN KEY (CIFproveedor) REFERENCES proveedores (CIFproveedor)
);


CREATE TABLE pedidos(
    Idpedido int NOT NULL,
    Idproducto int NOT NULL,
    DNIusuario char(9) NOT NULL,
    DNItrabajador char(9) NOT NULL,
    Fecha timestamp NOT NULL default CURRENT_TIMESTAMP,
    Direccion char(100) NOT NULL,
    PRIMARY KEY (Idpedido),
    CONSTRAINT pedidos_fk_1 FOREIGN KEY (Idproducto) REFERENCES productos (Idproducto),
    CONSTRAINT pedidos_fk_2 FOREIGN KEY (DNIusuario) REFERENCES usuarios (DNIusuario),
    CONSTRAINT pedidos_fk_3 FOREIGN KEY (DNItrabajador) REFERENCES trabajadores (DNItrabajador)
);

-- Creando las tablas, sabes que por cada clave primaria definida se crea un inidice, pero segun tu criterio, decides añadir dos indices más para mejorar la eficiencia de ciertas consultas
-- Estos indices seran creados en los atributos IBAN de los proveedores y de los trabajadores, para cuando la empresa necesite localizar a un trabajador a traves de su iban, se haga de una manera eficiente.
DROP INDEX IF EXISTS idx_iban_trabajadores, idx_iban_proveedores;
CREATE INDEX idx_iban_trabajadores ON trabajadores(IBAN); 
CREATE INDEX idx_iban_proveedores ON proveedores(IBAN); 


-- Ademas de esto, recuerdas que la empresa te pidio la creacion la creación de 5 usuarios con diferentes permisos, por los que los creas:

CREATE ROLE rol_principal;
CREATE ROLE rol_colaborador;
CREATE ROLE rol_eventual;
CREATE ROLE rol_junior;
CREATE ROLE rol_externo;

GRANT ALL PRIVILEGES ON TABLE usuarios, trabajadores, proveedores, productos, pedidos TO rol_principal;
GRANT UPDATE ON TABLE usuarios, trabajadores, proveedores, productos, pedidos TO rol_colaborador;
GRANT SELECT ON TABLE usuarios, trabajadores, proveedores, productos, pedidos TO rol_eventual;
GRANT ALL PRIVILEGES ON TABLE pedidos TO rol_junior;
GRANT SELECT ON TABLE usuarios, productos, pedidos TO rol_externo;

-- Cuando terminas, recuerdas que tu profesor solia recomendar introducir registros generados aleatoriamente para ver si se cumplen o no con las especificaciones de la empresa 
-- asi que decides usar la web generatedata.com para generar al menos 450 registros de cada tabla. 
-- Para ejecutar los inserts decides crear 5 ficheros.sql, uno por cada tabla.
-- deben ser ejecutados en el siguiente orden: 1. InsertsUsuarios.sql, 2. InsertsTrabajadores.sql, 3. InsertsProveedores.sql, 4. InsertsProductos.sql, 5. InsertsPedidos.sql
-- Haciendo esto habras podido insertar los datos de forma correcta.

\i InsertsUsuarios.sql
\i InsertsTrabajadores.sql
\i InsertsProveedores.sql
\i InsertsProductos.sql
\i InsertsPedidos.sql

-- Con los datos introducidos, decides hacer alguna mejoras, añadiendo 3 vistas (una de ellas materializadas) y 2 disparadores
-- La primera vista (siendo esta materializada) sera una que muestre todos los productos junto a su informacion (es materializada debido a que sera una consulta frecuente por los usuarios y queremos almacenarla en memoria)
DROP MATERIALIZED VIEW IF EXISTS view_all_products;
CREATE MATERIALIZED VIEW view_all_products AS
SELECT *
FROM productos;

-- La segunda vista sera una que muestre la informacion de los proveedores junto al numero de productos que venden
DROP VIEW IF EXISTS view_all_products_providers;
CREATE VIEW view_all_products_providers AS
SELECT pr.CIFproveedor, COUNT(*) as NumProductosQueVende
FROM productos p JOIN proveedores pr on (p.CIFproveedor = pr.CIFproveedor)
GROUP BY pr.CIFproveedor;

-- La tercera y ultima vista sera una que muestre de cada pedido el dni,nombre y correo del usuario que lo ha realizado
DROP VIEW IF EXISTS view_user_orders;
CREATE VIEW view_user_orders AS
SELECT p.Idpedido, u.DNIusuario, u.Nombre, u.Correo
FROM pedidos p JOIN usuarios u ON p.DNIusuario = u.DNIusuario;

--El primer disparador tendra la funcion de mantener la ultima fecha de modificacion de los pedidos.
DROP FUNCTION IF EXISTS actualizarFecha;
CREATE OR REPLACE FUNCTION actualizarFecha() RETURNS TRIGGER AS
$actualizarFecha$
   BEGIN
      NEW.Fecha := CURRENT_TIMESTAMP; 
      RETURN NEW;
   END;
$actualizarFecha$ LANGUAGE plpgsql;


CREATE TRIGGER actualizarFecha BEFORE UPDATE ON pedidos
FOR EACH ROW EXECUTE PROCEDURE actualizarFecha();

--Por ultimo, el segundo disparador tendra la funcion de almacenar un log de los trabajadores que sean despedidos (se borren de trabajadores)
DROP TABLE IF EXISTS logDespidos CASCADE;
CREATE TABLE logDespidos(
    Fechadespido timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    DNItrabajador char(9) NOT NULL,
    Nombre char(50) NOT NULL,
    Apellidos char(70),
    Telefono char(12) NOT NULL,
    Correo char(60) NOT NULL,
    Direccion char(100) NOT NULL,
    IBAN char(24) NOT NULL,
    Puesto char(30) NOT NULL default 'Puesto no formalizado todavia',
    PRIMARY KEY(DNItrabajador)
);


DROP FUNCTION IF EXISTS logDespidos;
CREATE OR REPLACE FUNCTION logDespidos() RETURNS TRIGGER AS
$logDespidos$
   BEGIN
      INSERT INTO logDespidos (DNItrabajador,Nombre,Apellidos,Telefono,Correo,Direccion,IBAN,Puesto)
      VALUES (OLD.DNItrabajador,OLD.Nombre,OLD.Apellidos,OLD.Telefono,OLD.Correo,OLD.Direccion,OLD.IBAN,OLD.Puesto);
      RETURN OLD;
   END;
$logDespidos$ LANGUAGE plpgsql;


CREATE TRIGGER logDespidos
BEFORE DELETE ON trabajadores
FOR EACH ROW
EXECUTE PROCEDURE logDespidos();

