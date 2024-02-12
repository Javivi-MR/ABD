-- Tabla platos, tendrá la informacion sobre los platos que ofrece la cafeteria
DROP TABLE IF EXISTS Productos CASCADE;
-- Tabla ventas, tendrá la informacion sobre las ventas que se hagan en la cafeteria 
DROP TABLE IF EXISTS Ventas CASCADE;
-- Tabla empleados, almacena la informacion de empleados
DROP TABLE IF EXISTS Empleados CASCADE;
-- Tabla Solicitud, maneja solicitudes de empleados. Aqui pueden expresar alguna necesidad
DROP TABLE IF EXISTS Solicitud CASCADE;

CREATE TABLE Productos (
    ProductoID INT ,
    Nombre VARCHAR(100),
    Descripcion VARCHAR(255),
    Precio FLOAT,
    Categoria VARCHAR(50),
    stock INT
);
ALTER TABLE Productos
	ADD CONSTRAINT Pk_productos PRIMARY KEY(ProductoID);

CREATE TABLE Empleados (
    EmpleadoID INT,
    Nombre VARCHAR(100),
    Cargo VARCHAR(20) CHECK (Cargo IN ('Cocina', 'Barra', 'Limpieza')),
    FechaContratacion DATE,
    Sueldo FLOAT
);
ALTER TABLE Empleados
	ADD CONSTRAINT Pk_empleados PRIMARY KEY(EmpleadoID);

CREATE TABLE Solicitud (
    SolicitudID INT,
    EmpleadoID INT,
    Titulo VARCHAR(100),
    Descripcion TEXT,
    Urgente BOOL,
    FOREIGN KEY (EmpleadoID) REFERENCES Empleados(EmpleadoID)
);
ALTER TABLE Solicitud
	ADD CONSTRAINT Pk_solicitud PRIMARY KEY(SolicitudID);


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

-- Inserts para la tabla Productos
INSERT INTO Productos (ProductoID, Nombre, Descripcion, Precio, Categoria, stock) VALUES
(1, 'Hamburguesa', 'Deliciosa hamburguesa con queso', 8.99, 'Comida rápida', 50),
(2, 'Café Americano', 'Café negro tradicional', 2.49, 'Bebida caliente', 100),
(3, 'Ensalada César', 'Ensalada fresca con aderezo César', 6.99, 'Ensalada', 30);

-- Inserts para la tabla Empleados
INSERT INTO Empleados (EmpleadoID, Nombre, Cargo, FechaContratacion, Sueldo) VALUES
(1, 'Juan Pérez', 'Cocina', '2022-01-01', 2500.00),
(2, 'María Rodriguez', 'Barra', '2022-02-15', 2200.00),
(3, 'Carlos López', 'Limpieza', '2022-03-10', 1800.00);

-- Inserts para la tabla Solicitud
INSERT INTO Solicitud (SolicitudID, EmpleadoID, Titulo, Descripcion, Urgente) VALUES
(1, 1, 'Vacaciones', 'Necesito tomar una semana de vacaciones en marzo', true),
(2, 2, 'Equipo nuevo', 'Necesitamos un nuevo exprimidor de jugo para la barra', false),
(3, 3, 'Horario flexible', 'Solicito un horario flexible debido a compromisos familiares', false);

-- Inserts para la tabla Ventas
INSERT INTO Ventas (VentaID, ProductoID, EmpleadoID, Cantidad, FechaVenta, TotalVenta) VALUES
(1, 1, 1, 5, '2023-11-30 12:30:00', 44.95),
(2, 2, 2, 2, '2023-11-30 08:45:00', 4.98),
(3, 3, 1, 3, '2023-11-29 19:15:00', 20.97);

--Crear los usuarios que haran uso de los roles
DROP ROLE IF EXISTS juan_perez;
DROP ROLE IF EXISTS maria_rodriguez;
DROP ROLE IF EXISTS carlos_lopez;
CREATE ROLE juan_perez;
CREATE ROLE maria_rodriguez;
CREATE ROLE carlos_lopez;

-- Crear roles para cada tipo de trabajador
DROP ROLE IF EXISTS rol_cocina;
DROP ROLE IF EXISTS rol_barra;
DROP ROLE IF EXISTS rol_limpieza;
CREATE ROLE rol_cocina VALID UNTIL '2024-12-31';
CREATE ROLE rol_barra VALID UNTIL '2024-12-31';
CREATE ROLE rol_limpieza VALID UNTIL '2024-12-31';



-- Otorgar permisos a los roles en las tablas correspondientes
-- Para la tabla Productos
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE Productos TO rol_cocina;
GRANT SELECT ON TABLE Productos TO rol_barra;

-- Para la tabla Empleados
GRANT SELECT ON TABLE Empleados TO rol_cocina, rol_barra, rol_limpieza;

-- Para la tabla Solicitud
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE Solicitud TO rol_cocina, rol_barra, rol_limpieza;

-- Para la tabla Ventas
GRANT SELECT, INSERT ON TABLE Ventas TO rol_barra;

-- Asignar roles a los empleados
ALTER USER juan_perez SET ROLE rol_cocina;
ALTER USER maria_rodriguez SET ROLE rol_barra;
ALTER USER carlos_lopez SET ROLE rol_limpieza;

SELECT rolname, rolvaliduntil FROM pg_roles WHERE rolname IN ('rol_cocina','rol_barra','rol_limpieza');
SELECT * FROM information_schema.table_privileges WHERE table_name IN ('productos','ventas','empleados','solicitud');
SELECT pg_database.datname, pg_size_pretty (pg_database_size(pg_database.datname)) AS tamaño FROM pg_database;
