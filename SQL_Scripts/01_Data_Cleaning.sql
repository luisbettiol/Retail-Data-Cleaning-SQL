/* 
===============================================================================
SECCIÓN 1: ETAPA DE LIMPIEZA (STAGING)
Proyecto: Arquitectura de Datos Retail
Autor: Luis Bettiol
===============================================================================
Objetivo: Transformar el dataset crudo en una tabla de staging optimizada, 
corrigiendo tipos de datos y eliminando redundancias.
*/


--       1. Verificacion del Volumen Inicial y Tipos de Datos
-- El objetivo es validar la integridad de la carga inicial de 149,257 registros.
SELECT 
    COUNT(*)
FROM 
    ventas;



--       2. Detección de Duplicados
-- Identificacion de registros redundantes a nivel de tienda, producto, canal y fecha.
SELECT 
    COUNT(*) AS conteo, 
    id_tienda, 
    id_prod, 
    id_canal, 
    fecha
FROM
    ventas
GROUP BY id_tienda , id_prod , id_canal , fecha
HAVING conteo > 1
ORDER BY id_tienda , id_prod , id_canal , fecha;



--       3. Creación de Tabla de Staging (ventas_agr)
-- Transformación: Conversión de fechas de String a DATE.
-- Agregación: Consolidación de registros duplicados sumando cantidades 	
-- y promediando precios para mantener la integridad financiera.
CREATE TABLE ventas_agr AS 
	SELECT STR_TO_DATE(fecha, '%d/%m/%Y') AS fecha, -- Corrección de formato de texto a DATE 
		id_prod,
		id_tienda,
		id_canal,
		SUM(cantidad) AS cantidad, -- Consolidación de pedidos diarios 
		AVG(precio_oficial) AS precio_oficial,
		AVG(precio_oferta) AS precio_oferta,
		ROUND(SUM(cantidad) * AVG(precio_oferta), 2) AS facturacion -- Cálculo de ingreso neto 
	FROM 
		ventas
	GROUP BY 1 , 2 , 3 , 4;



--       4. Verificación de la Limpieza
-- Comprobacion: Eeducción del dataset tras la agregación (134,688 registros esperados).
SELECT 
  COUNT(*) AS registros_limpios 
FROM 
  ventas_agr;

