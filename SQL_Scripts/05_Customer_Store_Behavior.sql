/* 
=============================================================================
SECCIÓN 5: CUSTOMER & STORE BEHAVIOR (COMPORTAMIENTO DE PUNTOS DE VENTA)
Proyecto: Arquitectura de Datos Retail
Autor: Luis Bettiol
=============================================================================
Objetivo: Evaluar el rendimiento individual de las tiendas y la concentración 
de ventas por ubicación mediante técnicas de ranking.
*/



--       1. TOP 25 mejores clientes (tiendas con mayor facturación)

-- Creacion de CTE para crear el Ranking con ROW_NUMBER
WITH tabla_ranking AS(        
SELECT 
    t.nombre_tienda AS tienda,
    t.pais AS pais,
    COUNT(v.id_venta) AS n_transacciones,
    ROUND(SUM(v.facturacion), 2) AS facturacion_total,
    RANK() OVER(ORDER BY SUM(v.facturacion) DESC) AS ranking_ventas
FROM ventas_agr v
JOIN tiendas t 
	ON v.id_tienda = t.id_tienda
GROUP BY t.nombre_tienda, t.pais
ORDER BY ranking_ventas
)
SELECT
	*
FROM tabla_ranking
WHERE ranking_ventas <= 25
;    
/*
RESPUESTA

TIENDA							              	PAIS		      	TRANSACCIONES		FACTURACION		  RANKING
Grand choix						            	Switzerland		  7102				    67071631.15		  1
Chen Yu Enterprise Co.,		       		Korea		      	4703			    	56562861.95		  2
VIP Department Stores			        	Canada		    	3767			    	43715679.08		  3
Leisure Land				            		United Kingdom	2714			    	39527410.48		  4
Hangzhou Superman Sports Goods Co.	China		      	1551			    	30171596		    5
Naranco de Bulnes					          Spain		      	1902			    	29690996.4		  6
Campismo El Aquila, S.A.		        Mexico		    	1846		    		29074062.56		  7
Sport & Freizeit				          	Germany		    	3346		    		28839099.69		  8
The Marketplace					          	United States  	2117		    		28624421.8		  9
Golf Shop Jiro					          	Japan		      	1654		    		27843202.59		  10
Extreme Outdoors					          United States  	2541		    		27570058.42		  11
Hai Wan Shin Sport Equipment Co.	  Singapore	    	1516			    	24791614.88		  12
Extrem!							              	Germany		    	2210			    	24371278.75	  	13
Holstein Golf				          	  	Germany		    	1783			    	23624624.06	  	14
Arjan Aitta						            	Finland		    	1894			    	23300558.42	  	15
Esportes Grumari			          		Brazil		    	1588			    	22949873.44		  16
La bonne Forme				          		France		    	2936			    	22381758.1		  17
Consumer Club					            	United States	  507			    		21587086.56		  18
Hansung Golf					            	Korea			      645				    	20756935.61		  19
Ocio y Aventura					          	Spain		      	2602			    	20521957.07		  20
Jensen Mountaineering			        	United Kingdom	2011			    	19695038.18		  21
Falcon Outfitters				          	United States	  2014			    	19080605.81		  22
Lan King Sports Co., LTD.	      		China			      1638			    	18585385.91		  23
Outdoor-FachgeschÃ¤ft MÃ¼ller	    	Austria		    	2243			    	18170223.95		  24
Hurst Ironmongers					          United Kingdom	1480			    	17878305.3	  	25
*/



-- 			2. Análisis de Concentración (Pareto de Tiendas)

-- Calculamos el porcentaje acumulado de facturación para identificar el Core del negocio.
WITH ventas_tienda AS (
    SELECT 
        id_tienda,
        SUM(facturacion) AS facturacion_tienda
    FROM ventas_agr
    GROUP BY id_tienda
),
ventas_acumuladas AS (
    SELECT 
        id_tienda,
        facturacion_tienda,
        SUM(facturacion_tienda) OVER(ORDER BY facturacion_tienda DESC) AS suma_acumulada,
        SUM(facturacion_tienda) OVER() AS suma_total
    FROM ventas_tienda
),
tabla_pct_acumulado AS (
SELECT 
    t.nombre_tienda,
    ROUND(va.facturacion_tienda, 2) AS facturacion,
    ROUND((va.suma_acumulada / va.suma_total) * 100, 2) AS pct_acumulado
FROM ventas_acumuladas va
JOIN tiendas t 
	ON va.id_tienda = t.id_tienda
ORDER BY facturacion DESC
)
SELECT
	*
FROM tabla_pct_acumulado
WHERE pct_acumulado <= 80
;
/*
RESPUESTA:

TIENDA 							              	FACTURACION 	% ACUMULADO		
Grand choix					            		67071631.15		5.36
Chen Yu Enterprise Co.,			       	56562861.95		9.88
VIP Department Stores			        	43715679.08		13.37
Leisure Land						            39527410.48		16.53
Hangzhou Superman Sports Goods Co.	30171596		  18.94
Naranco de Bulnes					          29690996.4		21.32
Campismo El Aquila, S.A. de C.V.	  29074062.56		23.64
Sport & Freizeit					          28839099.69		25.94
The Marketplace					          	28624421.8		28.23
Golf Shop Jiro						          27843202.59		30.46
Extreme Outdoors					          27570058.42		32.66
Hai Wan Shin Sport Equipment Co.	  24791614.88		34.64
Extrem!								              24371278.75		36.59
Holstein Golf				             		23624624.06		38.48
Arjan Aitta					            		23300558.42		40.34
Esportes Grumari	          				22949873.44		42.17
La bonne Forme					          	22381758.1		43.96
Consumer Club						            21587086.56		45.69
Hansung Golf					            	20756935.61		47.34
Ocio y Aventura				          		20521957.07		48.98
Jensen Mountaineering			        	19695038.18		50.56
Falcon Outfitters					          19080605.81		52.08
Lan King Sports Co., LTD.			      18585385.91		53.57
Outdoor-FachgeschÃ¤ft MÃ¼ller		    18170223.95		55.02
Hurst Ironmongers				          	17878305.3		56.45
Holland Zonzoekers				        	17687839.6		57.86
Edward's Department Store			      17539278.19		59.26
Todo para el Golf, S.A. de C.V.		  16745903.34		60.6
Beter Buitenleven				          	16559568.2		61.93
Kanga Kampers				            		15580570.86		63.17
Golf's'us							              14071705.83		64.3
Hartman's						              	13640112.06		65.39
Sportworld						            	13624730.22		66.47
Beck's Sports Store				        	13416652.98		67.55
NonSoloNeve						            	12363651.98		68.53
Caravanserai						            12126400.16		69.5
Chuei Hyakkaten					          	11675054.89		70.44
Der Fitness-Doktor			        		11339687.79		71.34
Campingspecialisten			        		10296819.38		72.17
Extra Sport							            9243304.64		72.9
Beach Beds Pty Ltd.		        			9107680.83		73.63
Die Zeltstadt					            	9077780.19		74.36
The Golf Hut					            	8366233.63		75.03
Taeho Sports						            8289984.66		75.69
AusrÃ¼stungshaus Globetrotter	    	8188815.5		  76.34
Rock Steady						            	8164882.07		77
Shoumaru Hyakkaten				        	7809009.77		77.62
Maximum Sports						          7658397.33		78.23
MER-KA-DOS, S.A. de C.V.		       	7596403.35		78.84
Yuan Li Enterprises Co.			      	7378095.93		79.43
*/



-- 			3. Eficiencia del TOP 10 de Tiendas (Ticket Promedio y Unidades por Transacción)

-- Medimos la calidad de la venta en cada sucursal.
SELECT 
    t.nombre_tienda,
    ROUND(SUM(v.facturacion) / COUNT(DISTINCT v.id_venta), 2) AS ticket_promedio_venta,
    ROUND(SUM(v.cantidad) / COUNT(DISTINCT v.id_venta), 2) AS unidades_por_ticket
FROM ventas_agr v
JOIN tiendas t 
    ON v.id_tienda = t.id_tienda
GROUP BY t.nombre_tienda
ORDER BY ticket_promedio_venta DESC
LIMIT 10;

/*
RESPUESTA:
    
TIENDA 							        	    TICKET_PROMEDIO 		UNIDADES_POR_TICKET
Tre Valli							            68989.58			    	263.68
Yuan Li Enterprises Co.		    		67688.95			    	532.84
Samdo Club							          63185.22			    	532.80
Blue Mountains Golfing Company		59408.9				    	90.05
Bicicletas La Rueda, S.A.		    	56148.48			    	410.90
Act'N'Up Fitness				        	55595.84			    	371.79
Rantalan Tukku					        	54076.3				    	450.60
Todo para el Golf, S.A. de C.V.		50288				      	341.14
Nankyu Outdoor Youhin Senmonten		45623.58			    	224.56
Consumer Club						          42578.08			    	682.90
*/



-- 			4. Analisis de la evolución de facturación de cada país por trimestre desde 2017	

/*
Para esta consulta hay que tomar en cuenta 6 Trimestres
		-Q1 2017 (del 2017-01-01 al 2017-03-31)
        -Q2 2017 (del 2017-04-01 al 2017-06-30)
        -Q3 2017 (del 2017-07-01 al 2017-09-30)
        -Q4 2017 (del 2017-10-01 al 2017-12-31)
        -Q1 2018 (del 2018-01-01 al 2018-03-31)
        -Q2 2018 (del 2018-04-01 al 2018-06-30)

Objetivos:
	- Creacion de un CTE para agrupar y mejorar la legibilidad de la consulta
	- CASE WHEN para separar los trimestres bien
	- Se pudo hacer con la funcion QUARTER pero con CASE queda mas legible tanto la consulta como la salida
	- JOIN para traer los nombres de los Paises
	- Calculo de la Diferencia Porcentual sobre el Mes anterior
*/
-- Creacion de un CTE para agrupar y mejorar la legibilidad de la consulta
WITH tabla_trimestres_pais AS (
SELECT 
    CASE
        WHEN fecha BETWEEN '2017-01-01' AND '2017-03-31' THEN '2017 Q1' -- Primer Trimestre de 2017
        WHEN fecha BETWEEN '2017-04-01' AND '2017-06-30' THEN '2017 Q2' -- Segundo Trimestre de 2017
        WHEN fecha BETWEEN '2017-07-01' AND '2017-09-30' THEN '2017 Q3' -- Tercer Trimestre de 2017
        WHEN fecha BETWEEN '2017-10-01' AND '2017-12-31' THEN '2017 Q4' -- Cuarto Trimestre de 2017
        WHEN fecha BETWEEN '2018-01-01' AND '2018-03-31' THEN '2018 Q1' -- Primer Trimestre de 2018
        WHEN fecha BETWEEN '2018-04-01' AND '2018-06-30' THEN '2018 Q2' -- Segundo Trimestre de 2018
    END AS trimestres,
    t.pais AS pais,
    v.facturacion AS facturacion_por_pais
FROM ventas_agr AS v
JOIN tiendas AS t 
    ON v.id_tienda = t.id_tienda
WHERE fecha BETWEEN '2017-01-01' AND '2018-06-30' -- todos los registros desde el 2017, y hasta 30 de junio del 2018
),
-- Segundo CTE para Totalizar la Facturacion por paises
TABLA_TOTAL AS (
SELECT
	  pais,
    trimestres,
    ROUND(SUM(facturacion_por_pais),2) AS facturacion_por_pais -- Totalizacion de la facturacion
FROM tabla_trimestres_pais
GROUP BY 1,2 -- Agregado por Pais y Trimestre
ORDER BY 1,2 -- Ordenado por Pais y Trimestre
)
-- Consulta Final con manejo de NULLs
SELECT 
	  *,
    COALESCE( -- Para manejar los NULL del primer mes por que no tiene como compararse contra un mes anterior porque no existe
				ROUND( -- Para redondear
						((facturacion_por_pais - LAG(facturacion_por_pais, 1, 0) OVER(PARTITION BY pais ORDER BY trimestres)) -- Mes Actual - Mes Anterior
						/ LAG(facturacion_por_pais, 1, 0) OVER(PARTITION BY pais ORDER BY trimestres)) * 100.00, -- Dividido entre Mes Anterior * 100
					2), -- cierre del Round
				0) AS dif_porcentual_mes_anterior -- Cierre del Coalesce 
FROM TABLA_TOTAL;
/*
RESPUESTA FINAL

PAIS				      TRIMESTRE		FACTURACION			DIFERENCIA PORCENTUAL VS MES ANTERIOR
Australia			    2017 Q1			2288983.97			0
Australia			    2017 Q2			3641949.07			59.11
Australia		    	2017 Q3			3105849.15			-14.72
Australia			    2017 Q4			2455803.77			-20.93
Australia		  	  2018 Q1			4263983.38			73.63
Australia			    2018 Q2			4571072.27			7.2

Austria			    	2017 Q1			2234696.42			0
Austria			    	2017 Q2			2815212.71			25.98
Austria			    	2017 Q3			2534421.3			  -9.97
Austria			    	2017 Q4			3217914.96			26.97
Austria				    2018 Q1			3150450.88			-2.1
Austria		  	  	2018 Q2			3551423.62			12.73

Belgium			    	2017 Q1			2599101.07			0
Belgium			    	2017 Q2			2893020.93			11.31
Belgium			    	2017 Q3			2975930.45			2.87
Belgium				    2017 Q4			3027869.17			1.75
Belgium			    	2018 Q1			3900303.23			28.81
Belgium			    	2018 Q2			4426420.26			13.49

Brazil			    	2017 Q1			2393200.04			0
Brazil			    	2017 Q2			2217028.59			-7.36
Brazil			    	2017 Q3			2638287.97			19
Brazil			  	  2017 Q4			2364221.71			-10.39
Brazil			    	2018 Q1			2426428.22			2.63
Brazil			    	2018 Q2			2437065.28			0.44

Canada			    	2017 Q1			5060278.54			0
Canada			    	2017 Q2			6003678.19			18.64
Canada			    	2017 Q3			6719022.72			11.92
Canada			    	2017 Q4			6713252.18			-0.09
Canada			    	2018 Q1			6495973.51			-3.24
Canada			    	2018 Q2			7634556.89			17.53

China				      2017 Q1			4055135.57			0
China				      2017 Q2			5104245.36			25.87
China				      2017 Q3			4235179.68			-17.03
China				      2017 Q4			4210725.32			-0.58
China				      2018 Q1			7534613.82			78.94
China				      2018 Q2			6070339.72			-19.43

Denmark			    	2017 Q1			434796.67			  0
Denmark			    	2017 Q2			371057.23		  	-14.66
Denmark			    	2017 Q3			459429.84		  	23.82
Denmark			  	  2017 Q4			603348.33			  31.33
Denmark			    	2018 Q1			527631.55		  	-12.55
Denmark			    	2018 Q2			725471.49		  	37.5

Finland				    2017 Q1			2038195.95			0
Finland			    	2017 Q2			3518347.87			72.62
Finland			    	2017 Q3			2964717.65			-15.74
Finland			    	2017 Q4			2994376.85			1
Finland			  	  2018 Q1			4245924.63			41.8
Finland			    	2018 Q2			3460343.33			-18.5
  
France			    	2017 Q1			4225972.86			0
France			    	2017 Q2			3715128.02			-12.09
France			    	2017 Q3			3541804.01			-4.67
France			     	2017 Q4			4244876.23			19.85
France			    	2018 Q1			4611729.18			8.64
France			    	2018 Q2			4521939.18			-1.95

Germany				    2017 Q1			6969439.13			0
Germany				    2017 Q2			8662717.21			24.3
Germany				    2017 Q3			8644939.97			-0.21
Germany				    2017 Q4			8214917.26			-4.97
Germany			    	2018 Q1			9227806.71			12.33
Germany			    	2018 Q2			9422805.22			2.11

Italy			  	    2017 Q1			1745651.27			0
Italy			      	2017 Q2			1767665.45			1.26
Italy				      2017 Q3			2113573.58			19.57
Italy				      2017 Q4			1815606.58			-14.1
Italy				      2018 Q1			2238205.22			23.28
Italy				      2018 Q2			2043239.17			-8.71

Japan				      2017 Q1			2932092.49			0
Japan				      2017 Q2			5776196.02			97
Japan				      2017 Q3			5234001.35			-9.39
Japan				      2017 Q4			5277764.19			0.84
Japan				      2018 Q1			5537435.01			4.92
Japan				      2018 Q2			6062081.21			9.47

Korea			  	    2017 Q1			6062587.7			  0
Korea			  	    2017 Q2			6786563.3		  	11.94
Korea			      	2017 Q3			6669326.91			-1.73
Korea			       	2017 Q4			6749906.69			1.21
Korea			  	    2018 Q1			8159355.13			20.88
Korea			      	2018 Q2			8215380.14			0.69

Mexico		  	  	2017 Q1			5633108.11			0
Mexico			    	2017 Q2			5482263.06			-2.68
Mexico			    	2017 Q3			5348786.59			-2.43
Mexico			    	2017 Q4			7228497.12			35.14
Mexico			    	2018 Q1			7400918.7			  2.39
Mexico			    	2018 Q2			6699443				  -9.48

Netherlands		  	2017 Q1			5699663.74			0
Netherlands			  2017 Q2			5022736.86			-11.88
Netherlands		  	2017 Q3			6118926.99			21.82
Netherlands		  	2017 Q4			5290264.22			-13.54
Netherlands		  	2018 Q1			6328251.38			19.62
Netherlands		  	2018 Q2			6977726.49			10.26

Singapore			    2017 Q1			2442159.44			0
Singapore			    2017 Q2			3437691.44			40.76
Singapore			    2017 Q3			2793745.81			-18.73
Singapore			    2017 Q4			3140589.78			12.42
Singapore			    2018 Q1			2888208.3			  -8.04
Singapore		    	2018 Q2			3269427.08			13.2

Spain			      	2017 Q1			4957930.58			0
Spain				      2017 Q2			3946368.67			-20.4
Spain			      	2017 Q3			3992009.8			  1.16
Spain				      2017 Q4			4778876.18			19.71
Spain				      2018 Q1			6555733.96			37.18
Spain				      2018 Q2			5340424.8		  	-18.54

Sweden			  	  2017 Q1			1929035.8		  	0
Sweden			  	  2017 Q2			1567778.08			-18.73
Sweden			  	  2017 Q3			1918607.3		  	22.38
Sweden			  	  2017 Q4			1693098.29			-11.75
Sweden			  	  2018 Q1			2050140			  	21.09
Sweden			  	  2018 Q2			2525473.78			23.19

Switzerland		  	2017 Q1			4947398.72			0
Switzerland		  	2017 Q2			6595850.75			33.32
Switzerland		  	2017 Q3			6711659.52			1.76
Switzerland		  	2017 Q4			6810664.92			1.48
Switzerland		  	2018 Q1			7520235.51			10.42
Switzerland		  	2018 Q2			7099835.55			-5.59

United Kingdom		2017 Q1			7727460.7		  	0
United Kingdom		2017 Q2			8067327.04			4.4
United Kingdom		2017 Q3			8441392.72			4.64
United Kingdom		2017 Q4			9105465.98			7.87
United Kingdom		2018 Q1			9712221			  	6.66
United Kingdom		2018 Q2			8844073.26			-8.94

United States		  2017 Q1			12267687.29			0
United States	  	2017 Q2			15617770.16			27.31
United States	  	2017 Q3			15272451.65			-2.21
United States		  2017 Q4			17311977.21			13.35
United States		  2018 Q1			16953185.26			-2.07
United States		  2018 Q2			19585027.93			15.52
*/



-- 			5. Segmentación de clientes: 

				  -- Creacion de una matriz de 4 segmentos en base al número de pedidos y la facturación de cada cliente (tienda)
			  	-- Cada eje dividirá entre los que están por encima y por debajo de la media
/*
Creacion de una Vista para poder Acceder a la Matriz con los siguientes campos
	- El ID de cada tienda
    - La facturacion total de cada tienda
    - La facturacion total
    - La cantidad de pedidos total por tienda
    - El numero total de pedidos
*/
CREATE VIEW v_tabla_matriz_segmentada AS -- Creacion de la vista
-- Creacion del Primer CTE
WITH tabla_facturacion_pedidos AS (
SELECT
	  DISTINCT id_tienda, -- El ID de cada tienda
    SUM(facturacion) OVER(PARTITION BY id_tienda) AS facturacion_total_por_tienda, -- La facturacion total de cada tienda
    SUM(facturacion) OVER() AS total_facturacion, -- La facturacion total
    COUNT(id_venta) OVER(PARTITION BY id_tienda) AS total_pedidos_por_tienda, -- La cantidad de pedidos total por tienda
    COUNT(id_venta) OVER() AS total_pedidos -- El numero total de pedidos
FROM ventas_agr
),
/*
Creacion del Segundo CTE para calcular:
	- Media de facturacion de todas las tiendas 
    - Media de cantidad de pedidos de todas las tiendas 
    
De esa manera poder ubicar a cada tienda en alguno de los 4 segmentos de la matriz:
	- Segmento 1: Muchos Pedidos 	(mas de la media) 	/ 	Mucha Facturacion 	(mas de la media)
    - Segmento 2: Muchos Pedidos 	(mas de la media) 	/ 	Poca Facturacion 	(menos de la media)
    - Segmento 3: Pocos Pedidos 	(menos de la media) / 	Mucha Facturacion 	(mas de la media)
    - Segmento 4: Pocos Pedidos		(menos de la media) / 	Poca Facturacion 	(menos de la media)
*/
tabla_facturacion_pedidos_promedio AS (
SELECT 
	  id_tienda,
    facturacion_total_por_tienda,
    AVG(facturacion_total_por_tienda) OVER() AS promedio_facturacion_por_tienda,
    total_pedidos_por_tienda,
    AVG(total_pedidos_por_tienda) OVER() AS promedio_pedidos_por_tienda
FROM tabla_facturacion_pedidos
),
/*
Creacion del Tercer CTE para hacer la segmentacion de la matriz utilizando CASE WHEN
	- Segmento 1:
		SI la Facturacion de la tienda es MAYOR a la Facturacion Promedio
			Y el total de Pedidos de la tienda es MAYOR al promedio de pedidos
	- Segmento 2:
		SI la Facturacion de la tienda es MAYOR a la Facturacion Promedio
			Y el total de Pedidos de la tienda es MENOR al promedio de pedidos
	- Segmento 3:
		SI la Facturacion de la tienda es MENOR a la Facturacion Promedio
			Y el total de Pedidos de la tienda es MAYOR al promedio de pedidos
	- Segmento 4:
		SI la Facturacion de la tienda es MENOR a la Facturacion Promedio
			Y el total de Pedidos de la tienda es MENOR al promedio de pedidos
*/
tabla_matriz AS (
SELECT 
	  *,
    CASE
		    WHEN facturacion_total_por_tienda > promedio_facturacion_por_tienda AND total_pedidos_por_tienda > promedio_pedidos_por_tienda
			      THEN '1_mas_pedidos_mas_facturacion' 		-- Primer Segmento
		    WHEN facturacion_total_por_tienda <= promedio_facturacion_por_tienda AND total_pedidos_por_tienda > promedio_pedidos_por_tienda
			      THEN'2_mas_pedidos_menos_facturacion' 		-- Segundo Segemento
		    WHEN facturacion_total_por_tienda > promedio_facturacion_por_tienda AND total_pedidos_por_tienda <= promedio_pedidos_por_tienda
			      THEN '3_menos_pedidos_mas_facturacion' 		-- Tercer Segmento
		    WHEN facturacion_total_por_tienda <= promedio_facturacion_por_tienda AND total_pedidos_por_tienda <= promedio_pedidos_por_tienda
			      THEN '4_menos_pedidos_menos_facturacion' 	-- Cuarto Segmento
	  END AS matriz
FROM tabla_facturacion_pedidos_promedio
)
-- Consulta Final: JOIN para obtener el nombre de las Tiendas
SELECT 
	  m.id_tienda AS id_tienda,
    t.nombre_tienda AS tienda,
    ROUND(m.facturacion_total_por_tienda, 2) AS facturacion_total_por_tienda,
    ROUND(m.promedio_facturacion_por_tienda, 2) AS promedio_facturacion_por_tienda,
    m.total_pedidos_por_tienda AS total_pedidos_por_tienda,
    ROUND(m.promedio_pedidos_por_tienda, 2) AS promedio_pedidos_por_tienda,
    m.matriz AS matriz
FROM tabla_matriz AS m
JOIN tiendas AS t 
		ON m.id_tienda = t.id_tienda
ORDER BY matriz;


			-- 5.1 Calculo de cuantos clientes existen en cada segmento de la matriz
SELECT
	  matriz,
    COUNT(id_tienda) AS total_clientes_del_segmento
FROM v_tabla_matriz_segmentada
GROUP BY matriz
ORDER BY 1;
/*
RESPUESTA:
Resultado de la MATRIZ

1_mas_pedidos_mas_facturacion		  	56
2_mas_pedidos_menos_facturacion			11
3_menos_pedidos_mas_facturacion			9
4_menos_pedidos_menos_facturacion		213
*/



--       6. Potencial de desarrollo:

			      -- Segmentar las tiendas por su tipo, y calcular el P75 de la facturación
		      	-- Para cada tienda que esté por debajo del P75 calcular su potencial de desarrollo (diferencia entre la facturación P75 y su facturación)
-- Creacion del Primer CTE: Obtener la Facturacion total de cada tienda y Tipo de Tienda
WITH nivel_tienda AS (     
SELECT
	t.id_tienda AS tienda,
    t.tipo AS tipo,
    SUM(v.facturacion) AS facturacion_por_tienda
FROM 
	tiendas AS t
JOIN 
	ventas_agr AS v 
		ON t.id_tienda = v.id_tienda
GROUP BY 1,2
ORDER BY 2,3
),
-- Creacion del Segundo CTE: Calcular los Percentiles
tabla_percentil AS (
SELECT
	*,
    ROUND(PERCENT_RANK() OVER(PARTITION BY tipo ORDER BY facturacion_por_tienda)* 100, 2) AS percentil
FROM 
	nivel_tienda
),
-- Creacion del Tercer CTE: Filtar todos los que esten por arriba del Percentil 75 (75%)
tabla_percentil_75superior AS (
SELECT
	*
FROM 
	tabla_percentil
WHERE percentil >= 75
),
-- Creacion del Cuarto CTE: Enumerar cada registro y asi obtener un (1) solo registro, el mas cercano al 75%
tabla_percentil_ranking AS (
SELECT
	*,
ROW_NUMBER() OVER(PARTITION BY tipo) AS ranking
FROM 
	tabla_percentil_75superior
),
-- Creacion del Quinto CTE: Seleccionar el primero del ranking (posicion mas cercana a 75%). Ese sera el Valor IDEAL (el percentil 75)
tabla_percentil75_ideal AS (
SELECT
	tipo,
    facturacion_por_tienda AS ideal
FROM 
	tabla_percentil_ranking
WHERE ranking = 1
),
-- Creacion del Sexto CTE: Union de la ultima tabla (tabla_percentil75_ideal) con la primera tabla del CTE (nivel_tienda) para obtener todos los datos
tabla_conjunta AS (
SELECT
	t.*,
    p.ideal
FROM 
	nivel_tienda AS t
JOIN 
	tabla_percentil75_ideal AS p
		ON t.tipo = p.tipo
    )
/*
Consulta Final:

CASE WHEN para segmentar:
	Si la facturacion de la tienda esta por debajo del IDEAl (percentil 75), entonces SI tiene potencial de desarrollo
		Al restar la Facturacion de la tienda del Ideal, obtenemos la diferencia, ese es el Potencial de desarrollo
	
    Si la Facturacion de la tienda es igual o mayor que el IDEAL (percentil 75), entonces NO tiene potencial de desarrollo debido a que ya supero el percentil 75
		Se indica con un '0' (cero potencial de desarrollo o innecesario)
*/
SELECT
	*,
    CASE
		WHEN facturacion_por_tienda < ideal
			THEN ROUND(ideal - facturacion_por_tienda, 2)
		WHEN facturacion_por_tienda >= ideal
			THEN 0
	END AS potencial_de_desarrollo
FROM tabla_conjunta
 ;
/*
RESPUESTA:
 
ID		LINEA			          FACTURACION    	IDEAL P75		  POTENCIAL DE DESARROLO 
1526	Department Store	  87620.8					13640112.06		13552491.26
1433	Department Store	  90160					  13640112.06		13549952.06
1570	Department Store	  139016					13640112.06		13501096.06
1587	Department Store	  158200					13640112.06		13481912.06
1518	Department Store	  173496					13640112.06		13466616.06
1445	Department Store	  361726.1				13640112.06		13278385.96
1418	Department Store	  410436.2				13640112.06		13229675.86
1697	Department Store	  477219.3				13640112.06		13162892.76
1626	Department Store	  529780.8				13640112.06		13110331.26
1513	Department Store	  534810.5				13640112.06		13105301.56
1611	Department Store	  616372.4				13640112.06		13023739.66
1550	Department Store	  768815					13640112.06		12871297.06
1624	Department Store	  872078.43				13640112.06		12768033.63
1698	Department Store	  1200533.78			13640112.06		12439578.28
1349	Department Store	  1598917.64			13640112.06		12041194.42
1529	Department Store	  1749481.85			13640112.06		11890630.21
1498	Department Store	  2102455.78			13640112.06		11537656.28
1250	Department Store	  2755137.1				13640112.06		10884974.96
1547	Department Store	  4803977.47			13640112.06		8836134.59
1223	Department Store	  4840094.97			13640112.06		8800017.09
1749	Department Store	  5100912.17			13640112.06		8539199.89
1216	Department Store	  7285332.56			13640112.06		6354779.5
1228	Department Store	  7596403.35			13640112.06		6043708.71
1467	Department Store	  7809009.77			13640112.06		5831102.29
1309	Department Store	  8188815.5				13640112.06		5451296.56
1255	Department Store	  9107680.83			13640112.06		4532431.23
1235	Department Store	  11675054.89			13640112.06		1965057.17
1241	Department Store	  13624730.22			13640112.06		15381.84
1218	Department Store	  13640112.06			13640112.06		0
1213	Department Store	  17539278.19			13640112.06		0
1259	Department Store	  20521957.07			13640112.06		0
1260	Department Store	  22949873.44			13640112.06		0	
1201	Department Store	  28624421.8			13640112.06		0
1148	Department Store	  28839099.69			13640112.06		0
1282	Department Store	  39527410.48			13640112.06		0
1192	Department Store	  43715679.08			13640112.06		0
1272	Department Store	  56562861.95			13640112.06		0
1137	Department Store	  67071631.15			13640112.06		0

1273	Direct Marketing	  26453				  	140712.6		  114259.6
1617	Direct Marketing	  29651.25				140712.6	  	111061.35
1492	Direct Marketing	  30449.84				140712.6	  	110262.76
1368	Direct Marketing	  30526.67				140712.6	  	110185.93
1540	Direct Marketing	  33316.15				140712.6		  107396.45
1606	Direct Marketing	  36065.89				140712.6		  104646.71
1236	Direct Marketing	  43632.89				140712.6		  97079.71
1457	Direct Marketing	  45546.56				140712.6		  95166.04
1364	Direct Marketing	  46867.1					140712.6		  93845.5
1242	Direct Marketing	  140712.6				140712.6		  0
1313	Direct Marketing	  141109.57				140712.6		  0
1551	Direct Marketing	  224807.08				140712.6		  0

1319	Eyewear Store		    306015.1				2867409.33		2561394.23
1756	Eyewear Store		    654717.75				2867409.33		2212691.58
1559	Eyewear Store		    861060.46				2867409.33		2006348.87
1579	Eyewear Store		    895039.83				2867409.33		1972369.5
1344	Eyewear Store		    924129.69				2867409.33		1943279.64
1759	Eyewear Store		    992669.08				2867409.33		1874740.25
1750	Eyewear Store		    1087918.99			2867409.33		1779490.34
1134	Eyewear Store		    1234503.5				2867409.33		1632905.83	
1631	Eyewear Store		    1283313.92			2867409.33		1584095.41
1469	Eyewear Store		    1314084.01			2867409.33		1553325.32
1484	Eyewear Store	    	1587184.22			2867409.33		1280225.11
1531	Eyewear Store	    	1640934.04			2867409.33		1226475.29
1520	Eyewear Store	    	1706702.37			2867409.33		1160706.96
1475	Eyewear Store	    	1804582.75			2867409.33		1062826.58
1537	Eyewear Store	    	1894215.69			2867409.33		973193.64
1640	Eyewear Store	    	2057222.77			2867409.33		810186.56
1366	Eyewear Store		    2264603.61			2867409.33		602805.72
1405	Eyewear Store	    	2711493.03			2867409.33		155916.3
1510	Eyewear Store	    	2867409.33			2867409.33		0
1158	Eyewear Store	    	3649341.61			2867409.33		0
1279	Eyewear Store		    4155787.51			2867409.33		0
1211	Eyewear Store		    4426521.34			2867409.33		0
1194	Eyewear Store		    6220062.9				2867409.33		0
1205	Eyewear Store		    7089471.53			2867409.33		0

1422	Golf Shop		       	65388.4					14071705.83		14006317.43
1486	Golf Shop		      	78768					  14071705.83		13992937.83
1527	Golf Shop		      	93055.6					14071705.83		13978650.23
1742	Golf Shop		      	93756				  	14071705.83		13977949.83
1714	Golf Shop		      	105126.7				14071705.83		13966579.13
1491	Golf Shop		      	123940					14071705.83		13947765.83
1459	Golf Shop		      	127920					14071705.83		13943785.83
1605	Golf Shop		      	149705.65				14071705.83		13922000.18
1651	Golf Shop			      180373.2				14071705.83		13891332.63
1572	Golf Shop			      208455.54				14071705.83		13863250.29
1619	Golf Shop			      240004.2				14071705.83		13831701.63
1504	Golf Shop			      273152.2				14071705.83		13798553.63
1653	Golf Shop			      278042.6				14071705.83		13793663.23
1657	Golf Shop			      293506.8				14071705.83		13778199.03
1604	Golf Shop			      346590.35				14071705.83		13725115.48
1410	Golf Shop			      640643.8				14071705.83		13431062.03
1310	Golf Shop		      	929209					14071705.83		13142496.83
1200	Golf Shop		      	943261.85				14071705.83		13128443.98
1256	Golf Shop			      1247586.96			14071705.83		12824118.87
1115	Golf Shop			      1453142.55			14071705.83		12618563.28
1232	Golf Shop		      	1521468.8				14071705.83		12550237.03
1193	Golf Shop			      2567640.95			14071705.83		11504064.88
1286	Golf Shop			      7363187.77			14071705.83		6708518.06
1210	Golf Shop			      8366233.63			14071705.83		5705472.2
1289	Golf Shop		      	14071705.83			14071705.83		0
1227	Golf Shop			      16745903.34			14071705.83		0
1244	Golf Shop			      17687839.6			14071705.83		0
1280	Golf Shop			      17878305.3			14071705.83		0
1270	Golf Shop			      20756935.61			14071705.83		0
1149	Golf Shop		      	23624624.06			14071705.83		0
1274	Golf Shop			      24791614.88			14071705.83		0
1229	Golf Shop		      	27843202.59			14071705.83		0
1275	Golf Shop		      	30171596				14071705.83		0

1523	Outdoors Shop	    	79490.55				1318208			  1238717.45
1378	Outdoors Shop	    	89586					  1318208			  1228622
1508	Outdoors Shop		    94600					  1318208			  1223608
1586	Outdoors Shop		    105340					1318208		  	1212868
1317	Outdoors Shop		    106545.2				1318208		  	1211662.8
1346	Outdoors Shop		    107773.8				1318208		  	1210434.2
1666	Outdoors Shop		    108128					1318208		  	1210080
1639	Outdoors Shop		    108332					1318208		  	1209876
1627	Outdoors Shop		    108421.2				1318208		  	1209786.8
1496	Outdoors Shop		    111252					1318208		  	1206956
1693	Outdoors Shop	    	111880					1318208			  1206328
1622	Outdoors Shop		    114008					1318208			  1204200
1734	Outdoors Shop		    115988					1318208		  	1202220
1683	Outdoors Shop		    120408.75				1318208		  	1197799.25
1702	Outdoors Shop		    124192					1318208			  1194016
1358	Outdoors Shop		    127412					1318208			  1190796
1573	Outdoors Shop		    136840					1318208			  1181368
1762	Outdoors Shop		    144676					1318208			  1173532
1691	Outdoors Shop		    148056					1318208			  1170152
1448	Outdoors Shop		    153788					1318208			  1164420
1718	Outdoors Shop	    	154484					1318208			  1163724
1355	Outdoors Shop		    155788					1318208			  1162420
1324	Outdoors Shop		    165252					1318208			  1152956
1359	Outdoors Shop	    	182984					1318208			  1135224
1208	Outdoors Shop	    	189244					1318208			  1128964
1430	Outdoors Shop	    	190064					1318208			  1128144
1314	Outdoors Shop	    	200704					1318208			  1117504
1466	Outdoors Shop	    	202804.4				1318208			  1115403.6
1357	Outdoors Shop		    203310.8				1318208			  1114897.2
1546	Outdoors Shop		    219836					1318208			  1098372
1737	Outdoors Shop		    232353					1318208		  	1085855
1720	Outdoors Shop		    237614					1318208		  	1080594
1440	Outdoors Shop	    	238115.6				1318208		  	1080092.4
1495	Outdoors Shop		    243616.65				1318208			  1074591.35
1406	Outdoors Shop		    255465.6				1318208			  1062742.4
1515	Outdoors Shop		    264219					1318208			  1053989
1757	Outdoors Shop		    283955.2				1318208			  1034252.8
1401	Outdoors Shop		    284893					1318208			  1033315
1685	Outdoors Shop		    285924					1318208			  1032284
1758	Outdoors Shop		    286308.8				1318208		  	1031899.2
1731	Outdoors Shop		    309840.4				1318208		  	1008367.6
1395	Outdoors Shop		    310609.8				1318208		  	1007598.2
1487	Outdoors Shop	    	322630.35				1318208		  	995577.65
1345	Outdoors Shop		    353789.3				1318208		  	964418.7
1567	Outdoors Shop		    360390.55				1318208		  	957817.45
1571	Outdoors Shop		    360827.2				1318208			  957380.8
1665	Outdoors Shop		    373957.6				1318208		  	944250.4
1717	Outdoors Shop		    376096					1318208		  	942112
1539	Outdoors Shop		    422585.4				1318208			  895622.6
1327	Outdoors Shop	    	442530.1				1318208			  875677.9
1602	Outdoors Shop	    	449388.8				1318208			  868819.2
1690	Outdoors Shop	    	472895.2				1318208		  	845312.8
1472	Outdoors Shop	    	484487					1318208		  	833721
1735	Outdoors Shop	    	544167.4				1318208		  	774040.6
1503	Outdoors Shop	    	544853.6				1318208		  	773354.4
1512	Outdoors Shop	    	584620.25				1318208		  	733587.75
1394	Outdoors Shop		    610327.35				1318208		  	707880.65
1516	Outdoors Shop		    620078.3				1318208		  	698129.7
1760	Outdoors Shop	    	639065.48				1318208		  	679142.52
1608	Outdoors Shop	    	713539.9				1318208		   	604668.1
1614	Outdoors Shop	    	716319.15				1318208		  	601888.85
1703	Outdoors Shop	    	719052.8				1318208			  599155.2
1684	Outdoors Shop		    721640.1				1318208			  596567.9
1733	Outdoors Shop		    853200.05				1318208		  	465007.95
1379	Outdoors Shop		    934551.8				1318208		  	383656.2
1715	Outdoors Shop	    	984662.57				1318208		  	333545.43
1423	Outdoors Shop		    1215846.45			1318208		  	102361.55
1566	Outdoors Shop		    1236124					1318208		  	82084
1716	Outdoors Shop		    1318208					1318208		  	0
1248	Outdoors Shop		    1451896					1318208			  0
1462	Outdoors Shop		    1551201.73			1318208			  0
1217	Outdoors Shop	    	1599967.14			1318208			  0
1283	Outdoors Shop	    	2401962.85			1318208		  	0
1261	Outdoors Shop	    	3217318.65			1318208		  	0
1224	Outdoors Shop		    3325741.34			1318208		  	0
1135	Outdoors Shop	    	6609209.53			1318208		  	0
1133	Outdoors Shop		    6966903.78			1318208		  	0
1189	Outdoors Shop		    8164882.07			1318208		  	0
1237	Outdoors Shop		    10296819.38			1318208		  	0
1294	Outdoors Shop		    12126400.16			1318208		  	0
1257	Outdoors Shop		    15580570.86			1318208		  	0
1245	Outdoors Shop		    16559568.2			1318208		  	0
1311	Outdoors Shop		    18170223.95			1318208		  	0
1277	Outdoors Shop		    18585385.91			1318208		  	0
1195	Outdoors Shop	    	19080605.81			1318208		  	0
1281	Outdoors Shop		    19695038.18			1318208		   	0
1268	Outdoors Shop		    23300558.42			1318208		  	0
1151	Outdoors Shop		    24371278.75			1318208		  	0
1204	Outdoors Shop		    27570058.42			1318208		  	0
1226	Outdoors Shop	    	29074062.56			1318208		  	0
1258	Outdoors Shop	    	29690996.4			1318208		  	0

1728	Sports Store	    	86740				  	978570.68		  891830.68
1712	Sports Store	    	95214.55				978570.68		  883356.13
1679	Sports Store		    95896				  	978570.68		  882674.68
1675	Sports Store		    96904.8					978570.68		  881665.88
1363	Sports Store		    106752					978570.68		  871818.68
1490	Sports Store		    117044					978570.68	  	861526.68
1352	Sports Store		    123288					978570.68	  	855282.68
1672	Sports Store		    130532					978570.68	  	848038.68
1426	Sports Store		    144108					978570.68	  	834462.68
1443	Sports Store		    152404.4				978570.68		  826166.28
1442	Sports Store		    155732					978570.68		  822838.68
1397	Sports Store	    	158216					978570.68		  820354.68
1710	Sports Store		    179516					978570.68		  799054.68
1747	Sports Store	    	232171.2				978570.68		  746399.48
1476	Sports Store	    	245242.4				978570.68		  733328.28
1534	Sports Store	    	248131.4				978570.68		  730439.28
1763	Sports Store		    250348					978570.68		  728222.68
1644	Sports Store		    252733.4				978570.68		  725837.28
1381	Sports Store		    262612.8				978570.68		  715957.88
1743	Sports Store		    269029					978570.68		  709541.68
1745	Sports Store	    	275341.6				978570.68		  703229.08
1449	Sports Store	    	275786.4				978570.68		  702784.28
1738	Sports Store	    	280552					978570.68		  698018.68
1521	Sports Store	    	298299.8				978570.68	  	680270.88
1730	Sports Store	    	306831					978570.68	  	671739.68
1432	Sports Store	    	325923.8				978570.68	  	652646.88
1647	Sports Store		    334925.2				978570.68	  	643645.48
1740	Sports Store		    340971.4				978570.68	  	637599.28
1383	Sports Store		    342249.6				978570.68	  	636321.08
1642	Sports Store		    365549.4				978570.68	  	613021.28
1766	Sports Store		    369523					978570.68	  	609047.68
1497	Sports Store		    378771.4				978570.68	  	599799.28
1502	Sports Store		    381254.2				978570.68	  	597316.48
1460	Sports Store		    393090.85				978570.68		  585479.83
1471	Sports Store		    402325.45				978570.68	  	576245.23
1643	Sports Store		    420828.4				978570.68		  557742.28
1664	Sports Store		    464729.7				978570.68		  513840.98
1670	Sports Store	    	469468.6				978570.68	  	509102.08
1636	Sports Store		    470216.1				978570.68	  	508354.58
1663	Sports Store		    479435.85				978570.68	  	499134.83
1220	Sports Store	    	503999.3				978570.68	  	474571.38
1680	Sports Store	    	533079.6				978570.68	  	445491.08
1711	Sports Store	    	539988.73				978570.68	  	438581.95
1385	Sports Store	    	558988.8				978570.68	  	419581.88
1412	Sports Store	    	563979.05				978570.68		  414591.63
1676	Sports Store		    586797.65				978570.68		  391773.03
1656	Sports Store		    603472.2				978570.68	  	375098.48
1709	Sports Store		    604149.85				978570.68	  	374420.83
1398	Sports Store		    686003.3				978570.68	  	292567.38
1447	Sports Store		    703003					978570.68	  	275567.68
1744	Sports Store	    	710325.8				978570.68		  268244.88
1677	Sports Store		    816078.95				978570.68		  162491.73
1765	Sports Store		    818929.5				978570.68		  159641.18
1429	Sports Store		    821679.12				978570.68		  156891.56
1673	Sports Store		    829342.5				978570.68		  149228.18
1662	Sports Store		    840954.1				978570.68		  137616.58
1427	Sports Store		    850128.3				978570.68		  128442.38
1681	Sports Store		    853806.38				978570.68		  124764.3
1648	Sports Store		    978570.68				978570.68	  	0
1554	Sports Store		    1008176.25			978570.68	  	0
1234	Sports Store		    1181576.36			978570.68	  	0
1288	Sports Store	    	1461616.4				978570.68	  	0
1326	Sports Store		    2217116.01			97870.68		  0
1362	Sports Store		    3000967.79			978570.68		  0
1209	Sports Store		    3231567.68			978570.68		  0
1621	Sports Store		    3617359.06			978570.68		  0
1230	Sports Store		    4058546.65			978570.68		  0
1424	Sports Store		    4131761.88			978570.68		  0
1190	Sports Store		    4465289.1				978570.68		  0
1238	Sports Store		    5292250.56			978570.68		  0
1206	Sports Store		    6282699.48			978570.68		  0
1196	Sports Store	    	7658397.33			978570.68		  0
1271	Sports Store		    8289984.66			978570.68		  0
1246	Sports Store		    9243304.64			978570.68		  0
1147	Sports Store		    11339687.79			978570.68		  0
1247	Sports Store		    12363651.98			978570.68		  0
1278	Sports Store		    13416652.98			978570.68		  0
1225	Sports Store		    22381758.1			978570.68		  0

1199	Warehouse Store		  246557.76				6615904.99		6369347.23
1501	Warehouse Store		  1566966.78			6615904.99		5048938.21
1615	Warehouse Store		  1775335.01			6615904.99		4840569.98
1507	Warehouse Store		  2482168.56			6615904.99		4133736.43
1538	Warehouse Store	  	2828572.89			6615904.99		3787332.1
1535	Warehouse Store	  	3136425.35			6615904.99		3479479.64
1360	Warehouse Store		  3425057.37			6615904.99		3190847.62
1556	Warehouse Store		  3791113.1				6615904.99		2824791.89
1132	Warehouse Store		  5077173.2				6615904.99		1538731.79
1197	Warehouse Store		  6615904.99			6615904.99		0
1597	Warehouse Store		  7378095.93			6615904.99		0
1150	Warehouse Store		  9077780.19			6615904.99		0
1215	Warehouse Store		  21587086.56			6615904.99		0
 */



-- 			 7. Reactivación de clientes

			-- Identificar clientes que lleven más de 3 meses sin comprar (versus la última fecha disponible)
/*
Creacion del primer CTE 
	- Obtener la Ultima fecha en la que cada cliente hizo un pedido y la ultima fecha registrada en la tabla
	- Uso de ROW NUMBER debido a que existen diversos registros de cada tienda, de esa manera se obtiene el correspondiente al mas reciente
*/
WITH tabla_fechas AS(
SELECT
  	fecha,
    id_tienda,
    MAX(fecha) OVER(PARTITION BY id_tienda) AS ultima_compra_cliente,
    MAX(fecha) OVER() AS ultima_fecha_disponible,
    ROW_NUMBER() OVER(PARTITION BY id_tienda) AS ranking
FROM ventas_agr
)
,
/* 
Creacion del Segundo CTE 
	- Funcion DATEDIFF para calcular la cantidad de dias que hay entre la ultima fecha de la tabla (2018-07-20) y la ultima fecha de compra de cada cliente 
    Resultando en la Cantidad de Dias SIN realizar pedidos
*/
tabla_fechas_diferencias AS (
SELECT 
  	id_tienda,
    ultima_compra_cliente,
    ultima_fecha_disponible,
    DATEDIFF(ultima_fecha_disponible, ultima_compra_cliente) AS diferencia
FROM tabla_fechas
WHERE ranking = 1
),
/*
Creacion del tercer CTE
	- Filtrar los registros que tengan una cantidad de dias mayor a 90 (3 meses)
*/
tabla_resultado_final AS (
SELECT
	*
FROM tabla_fechas_diferencias
WHERE	diferencia >90
)
/*
Consulta Final: 
	- JOIN para Obtener el nombre de las tiendas 
    - Ordenado por las que tienen mayor cantidad de dias sin realizar un pedido
*/
SELECT
	  f.id_tienda AS id_tienda,
    t.nombre_tienda AS tienda,
    f.diferencia AS tiempo_desde_ultima_compra
FROM tabla_resultado_final AS f
JOIN tiendas AS t
		ON f.id_tienda = t.id_tienda
ORDER BY 3 DESC
;
/*
RESPUESTA:

ID		TIENDA				  	          CANTIDAD DE DIAS SIN HACER UN PEDIDO
1728	Island Sports					      	274
1735	Air marin						      	  155
1611	FreshCo							      	  136
1570	Valle Luz						      	  134
1317	Precipice Equipment					  126
1346	Wanderwelt						    	  102
1663	Sport Planet					    	  101
1363	Deportes La Fortaleza, S.A.  	100
1422	The Golf Cart					    	  100
1495	Camping 2000					      	100
1526	Hartvigsens						      	99
1433	The Bazaar						      	94
1712	Unternehmungslustig				  	94
1762	Ao ar livre						      	93
1670	Sports Scene					      	91
*/  







