/* 
 ============================================================================
SECTION 2 - MODELING STAR SCHEMA / SECCION 2 - ETAPA DE MODELADO (ESTRELLA)
Proyecto: Arquitectura de Datos Retail
Autor: Luis Bettiol 
=============================================================================
Objetivo: Implementar integridad referencial y transformar la tabla de staging
en una Tabla de Hechos (Fact Table) vinculada a sus Dimensiones.
*/


--       1. Definición de la Tabla de Hechos
-- Inclusion de una Clave Primaria (PK) única para identificar cada registro transaccional.
ALTER TABLE ventas_agr 
    ADD id_venta INT AUTO_INCREMENT PRIMARY KEY;


--       2. Implementación de Integridad Referencial (Foreign Keys)
-- Vincular la tabla de hechos con las dimensiones (Productos, Tiendas, Canales).
-- Esto asegura que no existan ventas registradas de entidades inexistentes.
ALTER TABLE ventas_agr
    ADD CONSTRAINT fk_ventas_productos FOREIGN KEY (id_prod) REFERENCES productos(id_prod),
    ADD CONSTRAINT fk_ventas_tiendas FOREIGN KEY (id_tienda) REFERENCES tiendas(id_tienda),
    ADD CONSTRAINT fk_ventas_canales FOREIGN KEY (id_canal) REFERENCES canales(id_canal);


--       3. Creación de la Vista de Pedidos
-- Generacion de un ID de Pedido dado que el dataset original no cuenta con uno. 
-- Agrupación por Fecha, Tienda y Canal utilizando Window Functions.
CREATE OR REPLACE VIEW v_ventas_agr_pedido AS
WITH maestro_pedidos AS (
    SELECT 
        fecha, 
        id_tienda, 
        id_canal, 
        ROW_NUMBER() OVER(ORDER BY fecha, id_tienda, id_canal) AS id_pedido
    FROM ventas_agr
    GROUP BY fecha, id_tienda, id_canal
)
SELECT 
    v.id_venta,
    mp.id_pedido,
    v.fecha,
    v.id_prod,
    v.id_tienda,
    v.id_canal,
    v.cantidad,
    v.facturacion
FROM ventas_agr v
JOIN maestro_pedidos mp 
    ON v.fecha = mp.fecha 
    AND v.id_tienda = mp.id_tienda 
    AND v.id_canal = mp.id_canal;


 --     4. Validación del Modelo
 -- Verificamos que la cantidad de pedidos únicos (22,721) sea consistente con la lógica de negocio.
SELECT 
   COUNT(DISTINCT id_pedido) AS total_pedidos_generados 
FROM v_ventas_agr_pedido;
