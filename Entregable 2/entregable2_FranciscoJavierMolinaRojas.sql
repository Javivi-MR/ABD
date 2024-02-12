-- Tabla platos, tendrá la informacion sobre los platos que ofrece la cafeteria
DROP TABLE IF EXISTS Productos CASCADE;
-- Tabla ventas, tendrá la informacion sobre las ventas que se hagan en la cafeteria 
DROP TABLE IF EXISTS Ventas CASCADE;
-- Tabla empleados, almacena la informacion de empleados
DROP TABLE IF EXISTS Empleados CASCADE;
-- Tabla proveedos, almacena informacion de los proveedores
DROP TABLE IF EXISTS Proveedores CASCADE;

CREATE TABLE Proveedores (
    ProveedorID INT,
    Nombre VARCHAR(100),
    Contacto VARCHAR(100),
    Telefono VARCHAR(9),
    Direccion VARCHAR(255)
);

ALTER TABLE Proveedores
	ADD CONSTRAINT Pk_proveedores PRIMARY KEY(ProveedorID);

CREATE TABLE Productos (
    ProductoID INT ,
    Nombre VARCHAR(100),
    Descripcion VARCHAR(255),
    Precio FLOAT,
    Categoria VARCHAR(50),
    stock INT,
    ProveedorID INT, FOREIGN KEY (ProveedorID) REFERENCES Proveedores(ProveedorID)
);

ALTER TABLE Productos
	ADD CONSTRAINT Pk_productos PRIMARY KEY(ProductoID);

CREATE TABLE Empleados (
    EmpleadoID INT,
    Nombre VARCHAR(100),
    FechaContratacion DATE,
    Sueldo FLOAT
);
ALTER TABLE Empleados
	ADD CONSTRAINT Pk_empleados PRIMARY KEY(EmpleadoID);

CREATE TABLE Ventas (
    VentaID INT,
    ProductoID INT,
    EmpleadoID INT,
    Cantidad INT,
    FechaVenta TIMESTAMP,
    TotalVenta FLOAT,
    FOREIGN KEY (ProductoID) REFERENCES Productos(ProductoID),
    FOREIGN KEY (EmpleadoID) REFERENCES Empleados(EmpleadoID)
);
ALTER TABLE Ventas
	ADD CONSTRAINT Pk_ventas PRIMARY KEY(VentaID);

INSERT INTO Proveedores (ProveedorID, Nombre, Contacto, Telefono, Direccion)
VALUES
    (1, 'Carniceria Jesus Rosa', 'jesus@gmail.com', '956542377', 'C/ Angel Leon'),
    (2, 'Juan Fruteria', 'juan@gmail.com', '956584769', 'C/ Juan Travieso'),
    (3, 'Pasteles la mari', 'maria@gmail.com', '956231456', 'C/ Aprobar ABD');

INSERT INTO Empleados (EmpleadoID, Nombre, FechaContratacion, Sueldo)
VALUES
    (1, 'Fco. Javier MR', '2023-01-01', 2500.00),
    (2, 'Isabel BL', '2023-02-15', 2200.00),
    (3, 'B. Maria SM', '2023-03-20', 1800.00);

INSERT INTO Productos (ProductoID, Nombre, Descripcion, Precio, Categoria, Stock, ProveedorID)
VALUES
    (1, 'Hamburgesa de Rubia Gallega', 'Hamburguesa rica', 10.99, 'Carnes', 100, 1),
    (2, 'Platano de canarias', 'Potasio k', 15.99, 'Frutas', 50, 2),
    (3, 'Caña de la ESI', 'Rica en chocolate', 8.99, 'Bolleria', 75, 3);

INSERT INTO Ventas (VentaID, ProductoID, EmpleadoID, Cantidad, FechaVenta, TotalVenta)
VALUES
    (1, 1, 1, 5, '2023-04-01 12:30:00', 54.95),
    (2, 2, 2, 3, '2023-04-02 15:45:00', 47.97),
    (3, 3, 3, 8, '2023-04-03 09:15:00', 71.92);

--Para obtener el backup de la BD realizar: pg_dump -U postgres -f backup.sql NombreBD
--Sustituir NombreBD por el nombre de la base de datos

--Una vez tenemos el archivo, para restaurar la copia de seguridad hacer psql NOMBREBD < backup.sql
--Sustituir NombreBD por el nombre de la base de datos

--VACUUM se usa para liberar el espacio disponible en una BD (Eliminando huecos de las relaciones, caché ...). Puedes especificar que relaciones deseas limpiar y no bloquea la BD.
--VACUUMFULL realiza operaciones similires a vacuum, pero a toda la BD y bloquea esta.
-- ANALYZE recopila estadísticas y sirve para optimizar posibles consultas a la BD.

--En este caso, la opcion más favorable para no bloquear o impedir el flujo de las operaciones del negocio, seria VACUUM y ANALYZE, para garantizar un limpiado y eficiencia en las consultas y a la vez permitir que se siga trabajando con ellas.
--Tambien se podria plantear realizar el VACUUMFULL en horas no ociosas, es decir, horas en las que el negocio no este abierto.
