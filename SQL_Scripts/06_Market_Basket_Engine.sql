/* 
=============================================================================
SECCIÓN 6: ADVANCED ANALYTICS - MARKET BASKET ENGINE
Proyecto: Arquitectura de Datos Retail
Autor: Luis Bettiol
=============================================================================
Objetivo: Crear un sistema de recomendación basado en productos que suelen 
   comprarse juntos, eliminando los artículos que el cliente ya posee.
*/


--       1. Etapa de Diagnóstico.

-- Analisis de Distribucion Actual de Ventas por Tienda (CLiente).
-- Realizar un perfil de cada tienda para entender sus productos estrella.

WITH tabla_conteo AS (
  SELECT 
	    id_tienda,
	    id_prod,
	    COUNT(id_prod)
  FROM ventas_agr
  GROUP BY 1, 2
  ORDER BY 1, 3 DESC
),
tabla_row AS (
  SELECT
	    *,
	    ROW_NUMBER() OVER(PARTITION BY id_tienda) AS ranking
  FROM tabla_conteo
)
SELECT
	  *
FROM tabla_row
WHERE ranking <=3;



--       2. Etapa de Modelo Global.

-- Tabla Recomendador.
-- Creacion de un motor de afinidad mediante un Self Join.
-- Identifica qué productos se compran juntos con mayor frecuencia en todo el histórico de pedidos.

CREATE TABLE recomendador AS
SELECT
  	v1.id_prod AS antecedente,
    v2.id_prod AS consecuente,
    COUNT(v1.id_pedido) ASfrecuencia
FROM v_ventas_agr_pedido AS v1
JOIN v_ventas_agr_pedido AS v2
		ON v1.id_pedido = v2.id_pedido -- cruzamos pedido con pedido para identificar los productos que se compran en el mismo pedido.
		  AND v1.id_prod != v2.id_prod -- quitamos los registros de cada producto consigo mismo.
		  AND v1.id_prod < v2.id_prod -- evitar matriz simetrica.
GROUP BY v1.id_prod, v2.id_prod -- en cuantos pedidos aparecen juntos.
;



--       2.1 Comprobacion del Recomendador.

SELECT
	*
FROM recomendador;



--       3. Etapa de Personalizacion

-- Generador de recomendaciones para cada cliente concreto.
-- Creacion de un algoritmo que cruza el historial de una tienda con el motor de afinidad, 
-- filtrando los productos que ya poseen para ofrecer una lista de 'Próxima Mejor Compra'.

WITH input_cliente AS (
	SELECT
	  	id_tienda,
		  id_prod
	FROM ventas_agr
	WHERE id_tienda = '1205' -- COLOCAR AQUI el ID de la tienda 
),
tabla_recomendaciones AS (
	SELECT
		  consecuente,
		  SUM(frecuencia) AS frecuencia
	FROM input_cliente AS c
	LEFT JOIN recomendador AS r
			ON c.id_prod = r.antecedente
	GROUP BY consecuente
	ORDER BY frecuencia DESC
)
SELECT
	  r.consecuente AS recomendacion,
    r.frecuencia AS frecuencia
FROM tabla_recomendaciones AS r
LEFT JOIN input_cliente AS c
		ON r.consecuente = c.id_prod
WHERE id_prod IS NULL
LIMIT 10 -- Para No Saturar al Usuario
;




