/* 
=============================================================================
SECCIÓN 3: EXPLORATORY DATA ANALYSIS (EDA) - MÉTRICAS BASE
Proyecto: Arquitectura de Datos Retail
Autor: Luis Bettiol
=============================================================================
Objetivo: Realizar una auditoría de volumen y valores para validar la 
consistencia de la información cargada en el modelo relacional.
*/

--       1. Auditoría de Catálogos (Dimensiones)
-- Verificamos la cantidad de entidades únicas en cada dimensión.
SELECT 
    (SELECT COUNT(*) FROM productos) AS total_productos,
    (SELECT COUNT(*) FROM tiendas) AS total_tiendas,
    (SELECT COUNT(*) FROM canales) AS total_canales;
  /*
      Total Productos		Total Tiendas		Total Canales
      274				       	562					    12
  */



--       2. KPIs Globales de Operación
-- Resumen general de volumen de ventas, unidades y facturación total.
SELECT 
    COUNT(id_venta) AS transacciones_totales,
    SUM(cantidad) AS unidades_vendidas,
    ROUND(SUM(facturacion), 2) AS facturacion_total,
    ROUND(AVG(facturacion), 2) AS ticket_promedio_linea
FROM ventas_agr;
/*
Total_Transacciones		Unidades_Vendidas	  Facturacion_Total	  Venta_Promedio
134688					      19795947			      1251363763.15		    9290.83
*/



-- 			3. Analisis de Cobertura Temporal
-- Verificacion del rango de Fechas del Historico de Datos
SELECT 
    MIN(fecha), 
    MAX(fecha)
FROM ventas_agr;
-- RESPUESTA:
-- Desde 2015-01-12 (12/01/2015)
-- Hasta el 2018-07-20 (20/07/2018)



-- 			4. Verificacion de Productos Unicos en el Catalogo de Venta
SELECT 
    COUNT(DISTINCT id_prod)
FROM productos;
-- RESPUESTA:
-- 274 incluyendo el mismo producto con diferentes colores

SELECT 
    COUNT(DISTINCT producto)
FROM productos;
-- RESPUESTA:
-- 144 sin tomar en cuenta los diferentes colores



-- 			5. Total de tiendas distintas (Clientes)
SELECT 
    COUNT(DISTINCT id_tienda)
FROM tiendas;
-- RESPUESTA:
-- 562 tiendas distintas



-- 			6. Total de Canales de Venta (Distribucion)
SELECT 
	DISTINCT canal
FROM canales;
/*
RESPUESTA:

Fax
Telephone
Mail
E-mail
Web
Sales visit
Special
Other
*/



-- 			7. Distribución Inicial por Canal
-- 	      - Total de Transacciones por Canal de venta
-- 	      - Total de Facturacion por Canal de venta
--        - Porcentaje de Participacion por Canal de venta al total
SELECT 
    c.canal AS canal_venta,
    COUNT(v.id_venta) AS total_transacciones,
    ROUND(SUM(v.facturacion), 2) AS total_facturacion,
    ROUND((SUM(v.facturacion) / (SELECT SUM(facturacion) FROM ventas_agr)) * 100, 2) AS pct_participacion_por_canal
FROM ventas_agr AS v
JOIN canales AS c 
	ON v.id_canal = c.id_canal
GROUP BY c.canal
ORDER BY total_facturacion DESC;
/*
RESPUESTA:

CANAL			  N TRANSACCIONES		TOTAL FACTURACION	  PCT DE PARTICIPACION
Web		  	    111014				    909471253.16		    72.68
Telephone		  11549			      	157869786.05	    	12.62
E-mail			  6891			      	87908957.07		    	7.03
Sales visit		3659				      67957531.43		    	5.43
Mail			    926					      20761811.89		    	1.66
Special			  370				      	4514876.04		    	0.36
Fax				    279				      	2879547.51		     	0.23
*/
