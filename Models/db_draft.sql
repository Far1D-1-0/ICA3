-- CREATE DATABASE costco_db;
-- USE costco_db;

CREATE TABLE Cliente (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    telefono VARCHAR(20)
);

CREATE TABLE Membresia (
    id_membresia INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    tipo VARCHAR(50),
    fecha_inicio DATE,
    fecha_fin DATE,
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente)
);

CREATE TABLE Categoria (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

CREATE TABLE Producto (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    precio_efectivo DECIMAL(10,2),
    precio_credito DECIMAL(10,2),
    precio_debito DECIMAL(10,2),
    stock INT,
    id_categoria INT,
    FOREIGN KEY (id_categoria) REFERENCES Categoria(id_categoria)
);

CREATE TABLE Historial_Precios (
    id_historial INT AUTO_INCREMENT PRIMARY KEY,
    id_producto INT NOT NULL,
    precio_efectivo DECIMAL(10,2),
    precio_credito DECIMAL(10,2),
    fecha_inicio DATE,
    fecha_fin DATE,
    FOREIGN KEY (id_producto) REFERENCES Producto(id_producto)
);

CREATE TABLE Promocion (
    id_promocion INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100),
    tipo VARCHAR(50),
    fecha_inicio DATE,
    fecha_fin DATE
);

CREATE TABLE Descuento (
    id_descuento INT AUTO_INCREMENT PRIMARY KEY,
    tipo VARCHAR(50),
    valor DECIMAL(5,2)
);

CREATE TABLE Producto_Promocion (
    id_producto INT,
    id_promocion INT,
    PRIMARY KEY (id_producto, id_promocion),
    FOREIGN KEY (id_producto) REFERENCES Producto(id_producto),
    FOREIGN KEY (id_promocion) REFERENCES Promocion(id_promocion)
);

CREATE TABLE Producto_Descuento (
    id_producto INT,
    id_descuento INT,
    PRIMARY KEY (id_producto, id_descuento),
    FOREIGN KEY (id_producto) REFERENCES Producto(id_producto),
    FOREIGN KEY (id_descuento) REFERENCES Descuento(id_descuento)
);

CREATE TABLE Rol (
    id_rol INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50)
);

CREATE TABLE Area (
    id_area INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100)
);

CREATE TABLE Empleado (
    id_empleado INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100),
    id_rol INT,
    id_area INT,
    FOREIGN KEY (id_rol) REFERENCES Rol(id_rol),
    FOREIGN KEY (id_area) REFERENCES Area(id_area)
);

CREATE TABLE Proveedor (
    id_proveedor INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100)
);

CREATE TABLE Compra (
    id_compra INT AUTO_INCREMENT PRIMARY KEY,
    fecha DATE,
    id_proveedor INT,
    FOREIGN KEY (id_proveedor) REFERENCES Proveedor(id_proveedor)
);

CREATE TABLE DetalleCompra (
    id_detalleC INT AUTO_INCREMENT PRIMARY KEY,
    id_compra INT,
    id_producto INT,
    cantidad INT,
    precio DECIMAL(10,2),
    FOREIGN KEY (id_compra) REFERENCES Compra(id_compra),
    FOREIGN KEY (id_producto) REFERENCES Producto(id_producto)
);

CREATE TABLE Venta (
    id_venta INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT,
    id_empleado INT,
    fecha DATE,
    total DECIMAL(10,2),
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente),
    FOREIGN KEY (id_empleado) REFERENCES Empleado(id_empleado)
);

CREATE TABLE DetalleVenta (
    id_detalleV INT AUTO_INCREMENT PRIMARY KEY,
    id_venta INT,
    id_producto INT,
    cantidad INT,
    precio DECIMAL(10,2),
    FOREIGN KEY (id_venta) REFERENCES Venta(id_venta),
    FOREIGN KEY (id_producto) REFERENCES Producto(id_producto)
);

CREATE TABLE Caja (
    id_caja INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50)
);

CREATE TABLE CorteCaja (
    id_corte INT AUTO_INCREMENT PRIMARY KEY,
    id_caja INT,
    id_empleado INT,
    fecha_apertura DATETIME,
    fecha_cierre DATETIME,
    monto_inicial DECIMAL(10,2),
    monto_final DECIMAL(10,2),
    FOREIGN KEY (id_caja) REFERENCES Caja(id_caja),
    FOREIGN KEY (id_empleado) REFERENCES Empleado(id_empleado)
);

CREATE TABLE Facturacion (
    id_factura INT AUTO_INCREMENT PRIMARY KEY,
    monto DECIMAL(10,2),
    fecha DATE,
    RFC VARCHAR(20),
    nombre VARCHAR(100),
    codigo_postal VARCHAR(10)
);

CREATE TABLE Facturacion_Cliente (
    id_factura INT,
    id_cliente INT,
    PRIMARY KEY (id_factura, id_cliente),
    FOREIGN KEY (id_factura) REFERENCES Facturacion(id_factura),
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente)
);

CREATE TABLE Facturacion_Proveedor (
    id_factura INT,
    id_proveedor INT,
    PRIMARY KEY (id_factura, id_proveedor),
    FOREIGN KEY (id_factura) REFERENCES Facturacion(id_factura),
    FOREIGN KEY (id_proveedor) REFERENCES Proveedor(id_proveedor)
);