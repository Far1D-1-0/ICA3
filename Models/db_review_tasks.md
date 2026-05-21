# Revisión del modelo relacional de `db_draft.sql`

## Hallazgos principales

1. **Campos obligatorios no declarados como `NOT NULL`.** Muchas llaves foráneas y atributos operativos aceptan `NULL` aunque el registro no tiene sentido sin ellos, por ejemplo `DetalleVenta.id_venta`, `DetalleVenta.id_producto`, `cantidad`, `precio`, `Compra.id_proveedor`, `Venta.id_cliente`, `Venta.id_empleado`, `CorteCaja.id_caja` y `CorteCaja.id_empleado`.
2. **Faltan restricciones de unicidad para catálogos y datos identificadores.** Tablas como `Categoria`, `Rol`, `Area`, `Caja`, `Proveedor`, `Promocion` y `Descuento` permiten nombres duplicados sin control. `Cliente.telefono` tampoco tiene una regla clara si debe ser único.
3. **Faltan restricciones de dominio y validación.** Precios, montos, stock y cantidades pueden ser negativos; fechas finales pueden ser anteriores a fechas iniciales; `Descuento.valor` no distingue si es porcentaje o monto fijo; los tipos de membresía, promoción y descuento son texto libre.
4. **Modelo de precios poco normalizado.** `Producto` guarda tres columnas de precio (`precio_efectivo`, `precio_credito`, `precio_debito`) y `Historial_Precios` solo guarda dos de ellas, lo que genera inconsistencia y dificulta agregar nuevos métodos de pago.
5. **Ventas y compras no registran método de pago ni estado.** La venta contiene el total, pero no la forma de pago utilizada para seleccionar precio, ni estado de venta. Las compras tampoco registran estado o subtotal/total.
6. **Totales y montos derivados pueden desincronizarse.** `Venta.total`, `Facturacion.monto` y posiblemente futuros totales de compra dependen de detalles, descuentos e impuestos; sin reglas, triggers o procesos transaccionales pueden quedar inconsistentes.
7. **Facturación no está ligada a la operación facturada.** `Facturacion` se relaciona con clientes o proveedores, pero no con `Venta` ni `Compra`, por lo que no se puede saber qué transacción generó una factura.
8. **Relación de facturación ambigua.** Las tablas `Facturacion_Cliente` y `Facturacion_Proveedor` permiten que una misma factura esté asociada simultáneamente a múltiples clientes y proveedores, algo normalmente inválido para una factura fiscal.
9. **Datos fiscales no están normalizados.** `Facturacion` guarda `RFC`, `nombre` y `codigo_postal` directamente; si un cliente o proveedor tiene varios perfiles fiscales, conviene modelarlos como entidades reutilizables.
10. **Faltan datos básicos de negocio.** Cliente solo tiene nombre y teléfono; proveedor solo nombre; empleado solo nombre, rol y área. Faltan correos, direcciones, identificadores fiscales, estatus y fechas de alta/baja según reglas del negocio.
11. **Relaciones muchos-a-muchos sin metadatos temporales o comerciales.** `Producto_Promocion` y `Producto_Descuento` no indican vigencia específica, prioridad, acumulabilidad, cantidad mínima o límites de uso por producto.
12. **Promociones y descuentos se traslapan conceptualmente.** Existe `Promocion` con `tipo` y `Descuento` con `tipo`/`valor`, pero no hay una relación clara entre promoción y descuento; puede causar duplicidad de reglas comerciales.
13. **No hay control de inventario transaccional.** `Producto.stock` es un saldo agregado, pero no existe una tabla de movimientos de inventario para auditar entradas, salidas, ajustes, devoluciones o mermas.
14. **Detalles de venta y compra permiten productos repetidos por operación.** Al usar un id autoincremental como única clave, no se impide repetir el mismo producto varias veces en la misma venta o compra salvo que se agregue una restricción única.
15. **Convenciones de nombres inconsistentes.** Hay mezcla de singular/plural, snake_case y PascalCase (`Historial_Precios`, `DetalleCompra`, `DetalleVenta`, `Facturacion_Cliente`), además de columnas como `id_detalleC` e `id_detalleV`.
16. **Acciones referenciales no definidas.** Las llaves foráneas no declaran `ON DELETE` ni `ON UPDATE`; esto deja el comportamiento a los defaults del motor y puede bloquear operaciones o permitir datos huérfanos según cambios futuros.
17. **Índices secundarios no declarados explícitamente.** Aunque algunas bases indexan FKs automáticamente y otras no, conviene definir índices para consultas frecuentes por cliente, producto, fecha, proveedor, empleado, categoría y caja.
18. **Tipos de datos fiscales y fechas requieren ajustes.** `RFC VARCHAR(20)` es más amplio de lo necesario para México (12 o 13 caracteres); `codigo_postal VARCHAR(10)` es flexible, pero para México normalmente son 5 dígitos. `Venta.fecha` y `Compra.fecha` usan `DATE`, perdiendo hora exacta de operación.
19. **Seguridad y auditoría ausentes.** No existen columnas de auditoría como `created_at`, `updated_at`, `created_by`, ni columnas de estado para altas/bajas lógicas.
20. **Membresía permite múltiples membresías activas por cliente.** No hay restricción que impida solapamientos de fechas o más de una membresía activa para el mismo cliente.

## Lista de tareas recomendadas

1. **Definir reglas de obligatoriedad.** Marcar como `NOT NULL` todas las FKs y campos indispensables para cada proceso: detalles, cantidades, precios, fechas, responsables, caja, proveedor, cliente y empleado.
2. **Agregar validaciones `CHECK`.** Incluir reglas para `precio >= 0`, `cantidad > 0`, `stock >= 0`, `monto >= 0`, `fecha_fin >= fecha_inicio`, `fecha_cierre >= fecha_apertura` y porcentajes entre `0` y `100`.
3. **Normalizar métodos de pago y precios.** Crear tablas como `MetodoPago` y `ProductoPrecio` o `ListaPrecio` para reemplazar columnas de precio por método de pago y mantener historial consistente.
4. **Completar el historial de precios.** Registrar método de pago, precio, fecha de inicio, fecha de fin y usuario/responsable del cambio; evitar traslapes de vigencia para el mismo producto y método.
5. **Rediseñar promociones y descuentos.** Unificar o relacionar `Promocion` y `Descuento`, agregar vigencia, prioridad, acumulabilidad, reglas de aplicación y restricciones por producto/categoría/membresía.
6. **Relacionar facturas con transacciones.** Vincular `Facturacion` con `Venta` o `Compra`, y decidir si se separan facturas emitidas a clientes de facturas recibidas de proveedores.
7. **Normalizar datos fiscales.** Crear perfiles fiscales para clientes y proveedores con RFC, razón social, régimen fiscal, código postal y dirección fiscal; referenciar esos perfiles desde facturas.
8. **Eliminar ambigüedad de facturación.** Reemplazar las relaciones muchos-a-muchos de facturación por una relación directa y obligatoria al sujeto facturado, o separar `FacturaCliente` y `FacturaProveedor`.
9. **Implementar movimiento de inventario.** Crear una tabla `MovimientoInventario` ligada a compras, ventas, ajustes y devoluciones para auditar todos los cambios de stock.
10. **Proteger la consistencia de detalles.** Agregar restricciones únicas como `(id_venta, id_producto)` y `(id_compra, id_producto)` o definir una columna de línea si se permiten productos repetidos por motivos específicos.
11. **Agregar estados de documentos.** Incluir estados para venta, compra, corte de caja, promoción, factura y membresía para controlar borradores, cancelaciones, cierres y operaciones activas.
12. **Revisar totales derivados.** Decidir si `Venta.total` y `Facturacion.monto` serán calculados al vuelo o persistidos; si se persisten, mantenerlos con transacciones, procedimientos o triggers.
13. **Agregar catálogos controlados.** Convertir campos de texto libre (`tipo` de membresía, promoción y descuento) en catálogos con FK o `ENUM` según el estándar del proyecto.
14. **Agregar restricciones únicas.** Definir unicidad para nombres de catálogos, códigos de caja, RFC/perfil fiscal cuando aplique y otros identificadores de negocio.
15. **Definir acciones referenciales.** Especificar `ON DELETE RESTRICT`, `ON DELETE CASCADE`, `ON DELETE SET NULL` y `ON UPDATE CASCADE/RESTRICT` según cada relación.
16. **Crear índices de consulta.** Indexar FKs y columnas de búsqueda frecuente: fechas de venta/compra, producto, cliente, proveedor, empleado, categoría, membresía activa y caja.
17. **Estandarizar nombres.** Elegir una convención (por ejemplo, snake_case en singular) y renombrar tablas/columnas de forma consistente.
18. **Mejorar tipos de datos.** Usar `DATETIME`/`TIMESTAMP` para operaciones transaccionales, ajustar longitudes de RFC y código postal, y evaluar `DECIMAL(12,2)` o mayor para montos acumulados.
19. **Agregar auditoría.** Incorporar `created_at`, `updated_at`, `deleted_at` opcional, `created_by` y `updated_by` en tablas críticas.
20. **Controlar vigencia de membresías.** Impedir membresías activas solapadas para el mismo cliente y exigir fechas de inicio/fin válidas.
21. **Documentar reglas de negocio.** Escribir decisiones sobre facturación, descuentos, precios, inventario y cancelaciones antes de aplicar el rediseño físico.
22. **Preparar migraciones y pruebas.** Crear scripts de migración incrementales y pruebas con datos de ejemplo para validar FKs, checks, unicidad y cálculos de totales.
