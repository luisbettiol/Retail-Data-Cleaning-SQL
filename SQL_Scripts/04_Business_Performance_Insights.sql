/* 
=============================================================================
SECCIÓN 4: BUSINESS PERFORMANCE INSIGHTS (ANÁLISIS DE NEGOCIO)
Proyecto: Arquitectura de Datos Retail
Autor: Luis Bettiol
=============================================================================
Objetivo: Analizar el rendimiento comercial mediante métricas de estacionalidad,
efectividad de canales y análisis de precios.
*/


-- 			1. Análisis de Estacionalidad

-- El ciclo analizado es de Julio 2017 a Junio 2018. 
-- Creacion de un CTE con un CASE WHEN para forzar el ordenamiento cronológico.

WITH reporte_mensual AS (
    SELECT 
        MONTHNAME(fecha) AS mes, -- Extraccion del nombre del mes.
        MONTH(fecha) AS num_mes, -- Extraccion del numero del mes.
        SUM(facturacion) AS total_facturado, -- Total de la Facturacion.
        SUM(cantidad) AS unidades -- Total de unidades vendidas.
    FROM ventas_agr
    WHERE fecha BETWEEN '2017-07-01' AND '2018-06-30' -- Filtro de los ultimos 12 meses (de Julio de 2017 a Junio de 2018).
    GROUP BY 1, 2
)
SELECT 
    mes, 
    ROUND(total_facturado, 2) AS facturacion,
    unidades
FROM reporte_mensual
ORDER BY 
    CASE 
        WHEN num_mes >= 7 THEN num_mes - 6  -- A los meses de la segunda mitad del año les resta 6.
        ELSE num_mes + 6 -- A los meses de la primera mitad del año les suma 6.
    END;
/*
RESPUESTA:

MES			  FACTURACION		UNIDADES VENDIDAS
July		  30248969.3		420274
August		37542454.97		530295
September	34642640.69		489355
October		34492574.43		476067
November	37025783.69		531642
December	35731658.82		544742
January		32185230.42		519263
February	45402035.83		671556
March		  44141468.33		633552
April		  39797797.76		584305
May			  43832265.25		704863
June		  39853506.66		619536
*/



-- 			2. Evolución mensual de la facturación por canal en los últimos 12 meses

-- 		- Creacion de un CTE con:
--			- Registros entre los ultimos 12 meses completos (de Julio de 2017 a Junio de 2018)
--			- Extraccion del mes de la fecha
--			- Agregacion de la facturacion por canal y por mes

WITH tabla_facturacion_12_meses AS(
SELECT 
    MONTH(fecha) AS mes, -- Extraccion el mes de la fecha
    id_canal,
    ROUND(SUM(facturacion),2) AS total_mensual_por_canal -- Total de la Facturacion 
FROM ventas_agr
WHERE fecha BETWEEN '2017-07-01' AND '2018-06-30' -- Filtro de los ultimos 12 meses completos (de Julio de 2017 a Junio de 2018)
GROUP BY 1 , 2 -- Agrupado por Mes y por Canal
)
-- Consulta Final con:
--	- CASE WHEN para re-nombrar los meses para que la consulta sea legible y poder ordenar correctamente
--	- JOIN con la tabla de canales para obtener el nombre de los canales
SELECT 
	CASE
	    WHEN mes = 1 THEN '2018 01 Enero'
      WHEN mes = 2 THEN '2018 02 Febrero'
      WHEN mes = 3 THEN '2018 03 Marzo'
      WHEN mes = 4 THEN '2018 04 Abril'
      WHEN mes = 5 THEN '2018 05 Mayo'
      WHEN mes = 6 THEN '2018 06 Junio'
      WHEN mes = 7 THEN '2017 07 Julio'
      WHEN mes = 8 THEN '2017 08 Agosto'
      WHEN mes = 9 THEN '2017 09 Septiembre'
      WHEN mes = 10 THEN '2017 10 Octubre'
      WHEN mes = 11 THEN '2017 11 Noviembre'
      WHEN mes = 12 THEN '2017 12 Diciembre'
	END AS Mes,
  c.canal AS Canal,
  ROUND(m.total_mensual_por_canal,2) AS Facturacion_Mensual
FROM tabla_facturacion_12_meses AS m
JOIN canales AS c 
	ON m.id_canal = c.id_canal
ORDER BY 2,1; -- Ordenado por Canal y por mes, desde Julio 2017 hasta Junio 2018
/*
RESPUESTA:

FECHA                CANAL        TOTAL DE FACTURACION
2017 07 Julio		    E-mail		    830789.75
2017 08 Agosto		  E-mail		    530748.96
2017 09 Septiembre	E-mail	    	494096.2
2017 10 Octubre		  E-mail		    423403.69
2017 11 Noviembre  	E-mail		    557065.13
2017 12 Diciembre	  E-mail		    621299.7
2018 01 Enero		    E-mail	    	46871.06
2018 02 Febrero		  E-mail	    	1250019.69
2018 03 Marzo		    E-mail	    	1341516.29
2018 04 Abril		    E-mail		    732607.41
2018 05 Mayo		    E-mail		    1000785.89
2018 06 Junio		    E-mail		    708471.3

2018 01 Enero		    Fax			      398846.85
2018 04 Abril		    Fax			      405543.97
2018 05 Mayo		    Fax			      1604.67

2017 07 Julio		    Mail		      14849
2017 08 Agosto		  Mail		      10585.9
2017 09 Septiembre	Mail		      16697.9
2017 11 Noviembre	  Mail		      18058.3
2017 12 Diciembre  	Mail		      22421
2018 03 Marzo		    Mail		      18281.56
2018 05 Mayo		    Mail	      	14983.94
2018 06 Junio		    Mail		      12501.9

2017 07 Julio		    Sales visit	  1735340.79
2017 08 Agosto		  Sales visit	  2059307.54
2017 09 Septiembre	Sales visit	  1834088.92
2017 10 Octubre		  Sales visit	  3688239.28
2017 11 Noviembre	  Sales visit	  2263118.2
2017 12 Diciembre	  Sales visit	  3072409.28
2018 01 Enero		    Sales visit	  3839936.32
2018 02 Febrero		  Sales visit	  4472393.61
2018 03 Marzo		    Sales visit  	1804940.05
2018 04 Abril		    Sales visit	  2440929.64
2018 05 Mayo		    Sales visit	  4060740.3
2018 06 Junio		    Sales visit	  2724015.46

2017 07 Julio		    Telephone	    1226619.29
2017 08 Agosto		  Telephone  	  1434623.23
2017 09 Septiembre	Telephone    	527090.13
2017 10 Octubre		  Telephone    	1009339.46
2017 11 Noviembre	  Telephone	    542557.47
2017 12 Diciembre  	Telephone	    240891.48
2018 01 Enero		    Telephone	    356840.39
2018 02 Febrero		  Telephone	    521377.61
2018 03 Marzo	    	Telephone	    1278588
2018 04 Abril	    	Telephone	    1498352.4
2018 05 Mayo		    Telephone	    1284276.19
2018 06 Junio		    Telephone	    935424.28

2017 07 Julio		    Web			      26441370.47
2017 08 Agosto		  Web			      33507189.34
2017 09 Septiembre	Web			      31770667.54
2017 10 Octubre		  Web			      29371592
2017 11 Noviembre  	Web		      	33644984.59
2017 12 Diciembre  	Web		      	31774637.36
2018 01 Enero		    Web		      	27542735.8
2018 02 Febrero		  Web		      	39158244.92
2018 03 Marzo		    Web		      	39698142.43
2018 04 Abril	    	Web		      	34720364.34
2018 05 Mayo		    Web		      	37469874.26
2018 06 Junio		    Web			      35473093.72
*/



-- 			3. Análisis de Canales de Venta

-- Evaluacion de la eficiencia de cada canal en términos de volumen y facturación.

SELECT 
  c.canal AS canal_venta,
  COUNT(DISTINCT v.id_pedido) AS total_pedidos, -- Total de Pedidos por Canal de Venta.
  SUM(v.cantidad) AS unidades_vendidas, -- Total de Unidades Vendidas por Canal de Venta.
  ROUND(SUM(v.facturacion), 2) AS ingresos_totales, -- Total de Facturacion por Canal de Venta.
  ROUND(SUM(v.facturacion) / COUNT(DISTINCT v.id_pedido), 2) AS ticket_promedio_pedido -- Ticket Promedio por Canal de Venta.
FROM v_ventas_agr_pedido AS v
JOIN canales AS c 
	ON v.id_canal = c.id_canal
GROUP BY c.canal
ORDER BY ingresos_totales DESC;
/*
RESPUESTA:

CANAL VENTA		TOTAL PEDIDOS	  TOTAL UNIDADES	INGRESOS TOTALES	TICKET PROMEDIO
Web			    	19307			      13616971		    909471253.16		  47105.78
Telephone		  1630		      	2891249			    157869786.05		  96852.63
E-mail			  892			      	1651440			    87908957.07		  	98552.64
Sales visit		538			      	1155195		    	67957531.43		  	126315.11
Mail			    189			      	331113			    20761811.89			  109850.86
Special			  65			      	104637		    	4514876.04			  69459.63
Fax			    	100			      	45342			      2879547.51			  28795.48
*/



-- 			4. Los 20 productos con mayor margen ((precio - coste) / coste * 100) en cada Línea de Producto

-- CTE con Calculo del Margen de todos los productos mas Row Number para dividir el ranking por linea de producto

WITH tabla_rankeada_por_linea AS (
SELECT 
	id_prod,
  linea,
  producto,
  ROUND(((precio - coste) / coste) *100, 2) AS margen,
  ROW_NUMBER() OVER (PARTITION BY linea ORDER BY ((precio - coste) / coste) *100 DESC) AS rank_por_linea
FROM productos
)
-- Consulta Final: Filtro sobre el CTE para obtener los 20 productos con mayor margen por cada linea de producto
SELECT 
    *
FROM tabla_rankeada_por_linea
WHERE rank_por_linea <= 20 -- Filtro de los 20 con mayor margen
ORDER BY linea , rank_por_linea;
/*
RESPUESTA

ID			LINEA						          PRODUCTO					        MARGEN		RANKING
4110	  	Camping Equipment		    	TrailChef Cup						    330.59		1
9110	 	Camping Equipment		    	TrailChef Kettle					    160.75		2
1110	  	Camping Equipment		    	TrailChef Water Bag				        137.91		3
41110	  	Camping Equipment		    	Flicker Lantern					        124.65		4
20110	  	Camping Equipment			    Hibernator Self-Inflating Mat	    	124.38		5
21110	  	Camping Equipment			    Hibernator Pad						    119.38		6
30110	  	Camping Equipment		    	Firefly Lite						    118.81		7
31110	  	Camping Equipment			    Firefly Mapreader				        117.2		8
28110	  	Camping Equipment		    	Canyon Mule Cooler			    	  	114.08		9
22110	  	Camping Equipment		    	Hibernator Pillow				        110.87		10
16110	  	Camping Equipment		    	Star Peg						        106			11
8110	  	Camping Equipment		    	TrailChef Double Flame			      	102.36		12
10110	  	Camping Equipment		    	TrailChef Utensils					    99.28	  	13
36110	  	Camping Equipment			    EverGlow Single						    95.54		14
27110	 	Camping Equipment			    Canyon Mule Extreme Backpack		    92.78	  	15
40110	 	Camping Equipment			    EverGlow Lamp					        88.41		16
2110	  	Camping Equipment		    	TrailChef Canteen				        86.71		17
34110		Camping Equipment		    	Firefly Extreme					        82.27		18
37110	 	Camping Equipment		    	EverGlow Double					        81.39		19
29110  		Camping Equipment		    	Canyon Mule Carryall			        78.48		20

115110		Golf Equipment			    	Course Pro Gloves					    321.65		1
112110		Golf Equipment				    Course Pro Golf and Tee Set		    	269.44		2
114110		Golf Equipment			    	Course Pro Golf Bag					    175.16		3
109110		Golf Equipment			    	Course Pro Putter				        140.87		4
110110		Golf Equipment			    	Blue Steel Putter				        120.75		5
107110		Golf Equipment			    	Lady Hailstorm Titanium Woods Set	    113.19		6
113110		Golf Equipment			    	Course Pro Umbrella				       	110.69		7
101110		Golf Equipment			    	Hailstorm Steel Irons				    107.94		8
106110		Golf Equipment			    	Hailstorm Steel Woods Set		      	107.71		9
108110		Golf Equipment				    Lady Hailstorm Steel Woods Set	  	  	102.8		10
111110		Golf Equipment				    Blue Steel Max Putter				    102.02		11
104110		Golf Equipment				    Lady Hailstorm Titanium Irons		    101.15		12
102110		Golf Equipment			    	Hailstorm Titanium Irons		        99.01		13
105110		Golf Equipment				    Hailstorm Titanium Woods Set	      	95.94		14
103110		Golf Equipment				    Lady Hailstorm Steel Irons		      	91.8		15

55110		Mountaineering Equipment		Firefly Rechargeable Battery	      	153.97		1
54110		Mountaineering Equipment		Firefly Charger					        136.99		2
49110		Mountaineering Equipment		Granite Signal Mirror			        113.32		3
56110	 	Mountaineering Equipment		Granite Chalk Bag					    111.02		4
52110	  	Mountaineering Equipment		Granite Pulley					        107.08		5
57110  		Mountaineering Equipment		Granite Ice						        105.29		6
61110	 	Mountaineering Equipment		Granite Axe						        104.92		7
50110  		Mountaineering Equipment		Granite Carabiner				        104.08		8
48110	  	Mountaineering Equipment		Husky Harness Extreme			        103.97		9
51110	  	Mountaineering Equipment		Granite Belay					        103.08		10
60110	  	Mountaineering Equipment		Granite Grip					        102.22		11
53110	  	Mountaineering Equipment		Firefly Climbing Lamp		      		85.4		12
62110	  	Mountaineering Equipment		Granite Extreme					        71.97		13
59110	  	Mountaineering Equipment		Granite Shovel					       	61.83		14
42110	  	Mountaineering Equipment		Husky Rope 50						    58.56		15
45110	  	Mountaineering Equipment		Husky Rope 200					       	55.25		16
44110	  	Mountaineering Equipment		Husky Rope 100					        52.25		17
43110	  	Mountaineering Equipment		Husky Rope 60						    50.19		18
47110	  	Mountaineering Equipment		Husky Harness					        48.5		19
46110	  	Mountaineering Equipment		Granite Climbing Helmet			    	40.85		20

88110	  	Outdoor Protection		  		BugShield Lotion Lite				    272.34		1
87110	  	Outdoor Protection		  		BugShield Spray					        228.42		2
86110	  	Outdoor Protection		  		BugShield Natural				        222.58		3
89110	  	Outdoor Protection		  		BugShield Lotion				        200.43		4
90110	  	Outdoor Protection		  		BugShield Extreme				        189.26		5
93110	  	Outdoor Protection		  		Sun Shelter 15						    178.77		6
99110	  	Outdoor Protection		  		Aloe Relief							    172.4		7
94110	  	Outdoor Protection		  		Sun Shelter 30						    170.27		8
91110	  	Outdoor Protection		  		Sun Blocker						        156.41		9
92110	  	Outdoor Protection		  		Sun Shelter Stick				        155.1		10
96110	  	Outdoor Protection		  		Compact Relief Kit					    154.71		11
100110		Outdoor Protection	  	  		Insect Bite Relief					    117.39		12
95110	  	Outdoor Protection		  		Sun Shield							    117.39		13
98110	  	Outdoor Protection		  		Calamine Relief					        112.01		14
97110  		Outdoor Protection		  		Deluxe Family Relief Kit		      	109.83		15

134140		Personal Accessories	  		Pocket Gizmo					        172.69		1
67110	  	Personal Accessories		  	Mountain Man Extreme		          	153.36		2
134120		Personal Accessories		  	Pocket Gizmo						    152.42		3
134110		Personal Accessories	  		Pocket Gizmo					        150.51		4
134130		Personal Accessories	  		Pocket Gizmo					        145.71		5
131130		Personal Accessories	  		Max Gizmo							    137.54		6
68240	  	Personal Accessories	  		Polar Sun					            137.39		7
68220	  	Personal Accessories		  	Polar Sun					            137.39		8
68190	  	Personal Accessories		  	Polar Sun					            137.39		9
68230	  	Personal Accessories		  	Polar Sun					            137.3		10
68200	  	Personal Accessories		  	Polar Sun					            137.21		11
68110	  	Personal Accessories		  	Polar Sun					            137.12		12
68120	  	Personal Accessories		  	Polar Sun					            137.12		13
68250	  	Personal Accessories		  	Polar Sun					            137.12		14
71110	  	Personal Accessories		  	Polar Wave				              	133.5		15
69120	  	Personal Accessories	  		Polar Ice						        121.37		16
69110	  	Personal Accessories		  	Polar Ice						        119.86		17
133110		Personal Accessories		  	Opera Vision					        118.25		18
66110	  	Personal Accessories		  	Mountain Man Combination		        117.8		19
131110		Personal Accessories		  	Max Gizmo						        116.58		20
*/



-- 			5. Productos en los que se estan haciendo descuentos (en porcentaje) superiores al valor de decuento que deja por debajo al 90% de los descuentos

/*
CTE con Calculo de Porcentaje de Descuento que se le esta aplicando a cada producto
(con un AVG porque no en todas las ventas se aplico el mismo descuento, asi conseguimos una media del descuento aplicado)
*/

WITH tabla_de_descuentos AS (
	SELECT 
		id_prod,
		ROUND(AVG((((precio_oferta * 100) / precio_oficial) - 100) * -1),2) AS descuento_aplicado
	FROM ventas_agr
	GROUP BY id_prod
),
-- Segundo CTE para calcular la disrtribucion acumulada sobre el descuento aplicado (percentil)
tabla_percentil AS ( 
SELECT 
	*,
  CUME_DIST() OVER(ORDER BY descuento_aplicado) AS percentil
FROM tabla_de_descuentos
)
-- Consulta Final: filtrar por el campo percentil
SELECT 
    *
FROM tabla_percentil
WHERE percentil >= 0.9; -- Productos que que se encuentren por arriba del 0.90 (90%) de la distribucion acumulada
/*
RESPUESTA
 
ID		    DESCUENTO	  PERCENTIL 
40110	    7.9			    0.9016393442622951
55110	    7.98		    0.9057377049180327
8110	    8.31		    0.9098360655737705
36110    	8.83		    0.9139344262295082
4110	    9.46	    	0.9180327868852459
115110	  	9.95		    0.9221311475409836
80110	    10.07	    	0.9262295081967213
20110	    10.96	    	0.930327868852459
2110	    11.08	    	0.9344262295081968
1110	    11.24		    0.9385245901639344
87110	    11.48		    0.9426229508196722
21110    	11.76		    0.9467213114754098
110110	 	 12.03	    	0.9508196721311475
109110	  	12.32	    	0.9549180327868853
31110	    12.5		    0.9590163934426229
9110	    12.59		    0.9631147540983607
111110	  	14.37		    0.9672131147540983
81110	    14.85		    0.9713114754098361
6110	    14.98		    0.9754098360655737
90110	    15.6		    0.9795081967213115
23110	    16.34	    	0.9836065573770492
112110	  	16.86	    	0.9877049180327869
113110	  	18.45	    	0.9918032786885246
5110	    25.32		    0.9959016393442623
94110	    27.64	    	1
*/



-- 			6. ¿Con qué productos necesitaríamos quedarnos para mantener el 90% de la facturación actual?

-- Creacion de CTE para agregar por producto y obtener el total facturado por cada producto, ordenado desde el de Mayor Facturacion hasta el Menor

WITH tabla_total_por_producto AS(
SELECT
	id_prod,
  SUM(facturacion) AS total_por_producto
FROM ventas_agr
GROUP BY id_prod
ORDER BY 2 DESC
),
/*
Creacion del Seguundo CTE donde agrego 3 nuevos campos con Window Functions
	- total_facturacion_acumulado
		con este campo voy llevando el acumulado de las facturacion, desde el que mas vende hacia el que menos vende
	- total_facturado
		El total de toda la facturacion
	- pct_del_total
		cuanto representa cada producto del total de la facturacion y lo llevamos de manera acumulada
        
	De esta forma, cuando el pct_del_total llegue a 90, quiere decir que en ese punto se cumple con el 90% de la facturacion total
    todo lo que quede por debajo de ese 90 (de 90 al 100) corresponde al 10% de la facturacion restante
*/
tabla_pct_del_total AS (
SELECT
	*,
    SUM(total_por_producto) OVER(ORDER BY total_por_producto DESC) AS total_facturacion_acumulado, -- Total Acumulado
    SUM(total_por_producto) OVER() AS total_facturado, -- Total Facturacion
    (SUM(total_por_producto) OVER(ORDER BY total_por_producto DESC) / SUM(total_por_producto) OVER()) * 100.00 AS pct_del_total -- % del Total
FROM tabla_total_por_producto
)
-- Consulta Final: Productos que cubren el 90% de la facturacion total
SELECT 
    ROUND(t.pct_del_total, 2) AS porcentaje_acumulado
FROM tabla_pct_del_total AS t
JOIN productos AS p 
    ON t.id_prod = p.id_prod
WHERE pct_del_total <= 90 -- Filtro para los Productos que Cubren el 90% de la Facturacion
;
/*
RESPUESTA:

De los 244 Productos que se ofrecen, solo con 111 (los mencionado a continuacion) se obtiene el 90% de la facturacion

ID		    PRODUCTO								            PORCENTAJE ACUMULADO
105110	 	Hailstorm Titanium Woods Set	  					4.54
11110	    Star Lite						             		8.25
144180	  	TX										            11.79
102110  	Hailstorm Titanium Irons			    			15.32
106110  	Hailstorm Steel Woods Set			     			18.3
25110	    Canyon Mule Weekender Backpack						20.92
107110  	Lady Hailstorm Titanium Woods Set					23.47
26110	    Canyon Mule Journey Backpack			  			25.93
101110  	Hailstorm Steel Irons					      		28.01
104110	  	Lady Hailstorm Titanium Irons		  				30.03
109110	  	Course Pro Putter						        	31.88
145170	  	Legend									            33.72
19110	    Hibernator Extreme					      			35.56
108110	  	Lady Hailstorm Steel Woods Set						37.35
13110	    Star Gazer 2						          		39.08
103110	  	Lady Hailstorm Steel Irons		  					40.5
44110	    Husky Rope 100						        		41.9
15110	    Star Gazer 6							         	43.23
111110  	Blue Steel Max Putter			      				44.52
62110	    Granite Extreme						        		45.77
48110	    Husky Harness Extreme			      				46.93
45110	    Husky Rope 200						        		48.06
128140  	Inferno									            49.13
27110	    Canyon Mule Extreme Backpack		  				50.19
29110	    Canyon Mule Carryall					      		51.25
129130	  	Infinity							            	52.23
126140	  	Dante								              	53.13
18110    	Hibernator					          				54
61110	    Granite Axe							          		54.84
12110	    Star Dome								            55.67
46110	    Granite Climbing Helmet				    			56.47
147110  	Zone									            57.26
110110	  	Blue Steel Putter				        			58.04
57110	    Granite Ice						          			58.8
124190	  	Cat Eye									            59.53
114110	  	Course Pro Golf Bag		 		      				60.26
40110	    EverGlow Lamp						          		60.98
125110	  	Venue									            61.7
126110	  	Dante								              	62.36
17110	    Hibernator Lite						        		63.03
42110	    Husky Rope 50					          			63.64
127130	  	Fairway								            	64.25
21110	    Hibernator Pad						        		64.84
75110	    Edge Extreme						          		65.43
54110    	Firefly Charger						        		65.97
3110	    TrailChef Kitchen Kit				      			66.5
23110	    Hibernator Camp Cot					      			67.02
20110    	Hibernator Self - Inflating Mat						67.53
51110    	Granite Belay						          		68.05
9110	    TrailChef Kettle			        				68.56
128200	  	Inferno							            		69.06
143110	  	Trendi							            		69.56
147180	  	Zone						              			70.06
14110	    Star Gazer 3				          				70.55
58110	    Granite Hammer					        			71.03
24110	    Canyon Mule Climber Backpack		  				71.5
5110	    TrailChef Cook Set				      				71.97
151110	  	Astro Pilot							          		72.44
147170	  	Zone									            72.89
28110	    Canyon Mule Cooler		      						73.35
149140  	Retro								 	            73.8
43110    	Husky Rope 60				          				74.25
32110	    Firefly 2						            		74.7
129150	  	Infinity						            		75.14
47110	    Husky Harness						          		75.58
85110	    Glacier GPS Extreme			      					76.01
132120	  	Maximus									            76.45
52110	    Granite Pulley				        				76.87
132110	  	Maximus								            	77.29
132170	  	Maximus								            	77.71
113110	  	Course Pro Umbrella				      				78.12
129180	  	Infinity								            78.49
147120  	Zone							              		78.86
147130	  	Zone								              	79.21
70240	    Polar Sports						          		79.56
50110	    Granite Carabiner					         		79.91
148120	  	Hawk Eye								            80.25
8110	    TrailChef Double Flame				    			80.59
55110    	Firefly Rechargeable Battery		  				80.93
128130	  	Inferno								            	81.26
69110	    Polar Ice							            	81.59
152110	  	Sky Pilot							            	81.91
112110	  	Course Pro Golf and Tee Set		  					82.24
145130	  	Legend								            	82.55
128150	  	Inferno								            	82.87
148130	  	Hawk Eye							            	83.18
31110	    Firefly Mapreader				        			83.48
125120	  	Venue							              		83.78
136140	  	Sam									              	84.08
6110	    TrailChef Deluxe Cook Set		    				84.38
79110	    Seeker 50								            84.68
128210	  	Inferno							            		84.96
135120	  	Ranger Vision						          		85.24
84110    	Glacier GPS						          			85.52
132140	  	Maximus								            	85.79
53110	    Firefly Climbing Lamp			      				86.07
127110	  	Fairway								            	86.34
59110	    Granite Shovel					         			86.61
63140    	Mountain Man Analog				      				86.88
60110	    Granite Grip						          		87.15
97110	    Deluxe Family Relief Kit		    				87.41
147160	  	Zone								              	87.67
7110	    TrailChef Single Flame		    					87.92
22110    	Hibernator Pillow						        	88.17
122140	  	Bella									            88.41
82110	    Glacier Basic					          			88.65
126130	  	Dante									            88.89
129110	  	Infinity						            		89.12
68250	    Polar Sun							            	89.35
115110	  	Course Pro Gloves			        				89.58
130110	  Lux								              		89.8
*/



-- 			6.1. Productos de los que se puede prescindir y mantener el 90% de la facturacion

-- Utilizando la misma consulta anterior, filtrando esta vez a los productos que se encuentran entre 90-100 

WITH tabla_total_por_producto AS(
SELECT
	id_prod,
  SUM(facturacion) AS total_por_producto
FROM ventas_agr
GROUP BY id_prod
ORDER BY 2 DESC
),
tabla_pct_del_total AS (
SELECT 
	*,
    SUM(total_por_producto) OVER(ORDER BY total_por_producto DESC) AS total_facturacion_acumulado,
    sum(total_por_producto) OVER() AS total_facturado,
    (sum(total_por_producto) OVER(ORDER BY total_por_producto DESC) / SUM(total_por_producto) OVER()) * 100.00 AS pct_del_total
FROM tabla_total_por_producto
)
SELECT
	P.ID_PROD AS ID,
  p.producto
FROM tabla_pct_del_total AS t
JOIN productos AS p
	ON t.id_prod = p.id_prod
WHERE pct_del_total > 90 -- Filtro para los Mayores a 90
;
/*
RESPUESTA:
Se puede prescindir de los siguientes productos e igual mantener el 90% de la facturacion total

143120		Trendi
148110		Hawk Eye
63130	 	Mountain Man Analog
89110	  	BugShield Lotion
141110		Trail Scout
145160		Legend
90110	  	BugShield Extreme
144150		TX
65110	 	Mountain Man Deluxe
149130		Retro
68230	  	Polar Sun
36110	  	EverGlow Single
78110	  	Seeker 35
142110		Trail Star
124110		Cat Eye
39110	 	EverGlow Butane
154150		Kodiak
1110	  	TrailChef Water Bag
136130		Sam
69120	  	Polar Ice
81110	  	Seeker Mini
73110  		Single Edge
135130		Ranger Vision
35110	  	Firefly Multi-light
135110		Ranger Vision
49110	  	Granite Signal Mirror
68110	  	Polar Sun
63110	  	Mountain Man Analog
124140		Cat Eye
70110  		Polar Sports
132150		Maximus
67110  		Mountain Man Extreme
34110  		Firefly Extreme
38110  		EverGlow Kerosene
88110	  	BugShield Lotion Lite
123140		Capri
147150		Zone
147140		Zone
80110	  	Seeker Extreme
10110	  	TrailChef Utensils
64110	  	Mountain Man Digital
95110	  	Sun Shield
56110	  	Granite Chalk Bag
144170		TX
68120	  	Polar Sun
131120		Max Gizmo
94110	  	Sun Shelter 30
71110	  	Polar Wave
76110	  	Bear Edge
130130		Lux
93110	  	Sun Shelter 15
133110		Opera Vision
68200	  	Polar Sun
72110	  	Polar Extreme
149150		Retro
140110		Trail Master
37110	  	EverGlow Double
144110		TX
96110	  	Compact Relief Kit
41110	  	Flicker Lantern
124160		Cat Eye
86110	  	BugShield Natural
33110	  	Firefly 4
154130		Kodiak
83110  		Glacier Deluxe
125150		Venue
124180		Cat Eye
92110	  	Sun Shelter Stick
30110	  	Firefly Lite
149120		Retro
87110	  	BugShield Spray
70200	  	Polar Sports
122120		Bella
70160	  	Polar Sports
4110	  	TrailChef Cup
144120		TX
134120		Pocket Gizmo
131110		Max Gizmo
124120		Cat Eye
65120	  	Mountain Man Deluxe
66110	  	Mountain Man Combination
123120		Capri
126150		Dante
123110		Capri
154110		Kodiak
68190	  	Polar Sun
154120		Kodiak
2110	  	TrailChef Canteen
16110	  	Star Peg
70140	  	Polar Sports
123150		Capri
74110	  	Double Edge
143130		Trendi
68220  		Polar Sun
68240	  	Polar Sun
143140		Trendi
123160		Capri
127150		Fairway
124130		Cat Eye
91110	  	Sun Blocker
77110	  	Bear Survival Edge
144200		TX
153110		Auto Pilot
129170		Infinity
70120	  	Polar Sports
99110	  	Aloe Relief
149160		Retro
146110		Zodiak
125140		Venue
146140		Zodiak
124150		Cat Eye
100110		Insect Bite Relief
129160		Infinity
146130		Zodiak
134130		Pocket Gizmo
128160		Inferno
147190		Zone
146120		Zodiak
132160		Maximus
144140		TX
145110		Legend
128190		Inferno
151120		Astro Pilot
134140		Pocket Gizmo
136150		Sam
98110	  	Calamine Relief
145180		Legend
126120		Dante
136110		Sam
131130		Max Gizmo
144160		TX
130140		Lux
125160		Venue
*/



-- 			7. Las diferentes Lienas de Productos

SELECT 
	DISTINCT linea
FROM productos;
/*
RESPUIESTA:

Camping Equipment
Mountaineering Equipment
Personal Accessories
Outdoor Protection
Golf Equipment
*/


-- 			7.1. La Contribución (en porcentaje) de cada Línea de Producto al total de facturación

-- Creacion del primer CTE con el calculo del total de facturacion por linea de producto

WITH tabla_facturacion_por_lineas AS (
SELECT
	p.linea,
  SUM(v.facturacion) AS total_facturacion_por_linea
FROM ventas_agr AS v
JOIN productos AS p 
	ON v.id_prod = p.id_prod
GROUP BY p.linea
ORDER BY 2 DESC
),
-- Creacion de un segundo CTE para agregar el campo de facturacion TOTAL
tabla_total_facturacion_por_lineas AS (
SELECT
	*,
  SUM(total_facturacion_por_linea) OVER() AS total_facturacion
FROM tabla_facturacion_por_lineas
)
-- Consulta Final: Division del total de cada linea de producto entre el total general para obtener el porcentaje de representacion de cada una
SELECT 
	linea AS Linea_Productos,
    ROUND(total_facturacion_por_linea, 2) AS Total_Facturacion_por_Linea,
    ROUND(total_facturacion, 2) AS total_facturacion,
    ROUND((total_facturacion_por_linea / total_facturacion) * 100.00,2) AS pct_por_linea_del_total
FROM 	tabla_total_facturacion_por_lineas
;
/*
RESPUESTA:

LINEA PRODUCTOS				  	TOTAL FACTURACION POR LINEA			TOTAL FACTURACION		% POR LINEA DEL TOTAL
Personal Accessories			410329373.18					    1251363763.15				32.79
Camping Equipment				334691880.39				       	1251363763.15				26.75
Golf Equipment					331781144.33			      		1251363763.15				26.51
Mountaineering Equipment		156860394.34				      	1251363763.15				12.54
Outdoor Protection				17700970.91						    1251363763.15				1.41

Personal Accessories es la liena que mas contribuye al total de la Facturacion
con un 32.79% de la facturacion total
*/



-- 			7.2. ¿Se Podria prescindir de alguna línea de productos sin que afecte mucho a la facturación?

/*
RESPUESTA: 

Se podria prescindir de la linea 'Outdoor Protection" debido a que solo represneta el 1.41% de la Facturacion
*/



-- 			8. Dentro de la línea que más facture ¿hay algún producto concreto que esté en tendencia? (Definimos tendencia como el crecimiento de Q2-2018 sobre Q1-2018)

-- Creacion del Primer CTE con un filtro de la fecha para tener los primeros 6 meses del ano, (primer trimestre y segundo trimestre)

WITH tabla_facturacion AS (
SELECT
	v.fecha,
	v.id_prod,
  v.facturacion
FROM ventas_agr AS v
JOIN productos AS p
	ON v.id_prod = p.id_prod
WHERE p.linea = 'Personal Accessories' -- Linea de Producto de Mayor Contribucion a la Facturacion total
		AND fecha BETWEEN '2018-01-01' AND '2018-06-30' -- Filtro para Aislar los 2 primeros trimestres del 2018
ORDER BY fecha
),
-- Creacion del Segundo CTE con un CASE WHEN para definir ambos trimestres, se podia hacer con la funcion Quarter pero de esta manera el formato es mas legible
tabla_quarters AS (
SELECT
	*,
  CASE 
	  WHEN fecha <= DATE('2018-03-31') THEN 'Q1'
    WHEN fecha >= DATE('2018-04-01') THEN 'Q2'
	END AS Quarters
FROM tabla_facturacion
),
-- Creacion del tercer CTE y agregacion por trimestres y producto, ordenado por trimestres y facturacion
tabla_quarters_ordenada AS (
SELECT 
	quarters,
	id_prod,
  SUM(facturacion) AS total
FROM tabla_quarters
GROUP BY 1,2
ORDER BY 1,3 DESC
),
/*
Creacion del Cuarto CTE con un Self Join de la misma tabla, para comparar el trimestre 2 contra el trimestre 1
filtrando para poder ver solo los productos del trimestre 2 'Q2' y los que solamente sean mayores en el Q2 contra el Q1
*/
tabla_final AS (
SELECT 
	q2.quarters,
	q2.id_prod,
  ROUND(q2.total,0) AS Q2,
  ROUND(q1.total,0) AS Q1
FROM tabla_quarters_ordenada AS q1
JOIN tabla_quarters_ordenada AS q2
	ON q1.id_prod = q2.id_prod
WHERE q2.quarters = 'Q2' 
	AND q2.total > q1.total
)
-- Consulta Final: JOIN con la tabla productos para obtener el nombre de los productos
SELECT
	p.producto,
	tf.id_prod,
  tf.q1,
  tf.q2
FROM tabla_final AS tf
JOIN productos AS p
	ON tf.id_prod = p.id_prod
;
/*
RESPUESTA

Todos los Productos mencionados en esta lista se encuentran en Tendencia debido a que como se puede observar, la Facturacion en el Q2 fue Mayor a la del Q1

PRODUCTO			      	ID		  Q1		  Q2
Mountain Man Analog			63110	  108400	152523
Mountain Man Digital		64110	  72804  	100209
Mountain Man Deluxe			65120	  96558  	138361
Mountain Man Extreme		67110	  214452	246009
Polar Sun			      	68120	  233335	305045
Polar Sun				    68190	  85711  	93760
Polar Sun				    68200	  116854	139803
Polar Sun				    68240	  76311  	90819
Polar Sun				    68250	  384012	541104
Polar Ice			    	69110	  449387	528898
Polar Ice				    69120	  305780	371942
Polar Sports		  	  	70120	  52736  	58790
Polar Sports		    	70140	  97453	  	154688
Polar Sports		    	70160	  201610	226962
Polar Sports		    	70200     164830	179052
Polar Sport			    	70240	  325989	344299
Polar Wave			    	71110	  134716	182287
Polar Extreme		    	72110	  132140	151624
Double Edge			    	74110	  26872  	30891
Edge Extreme		    	75110	  803930	1002240
Bear Edge			    	76110	  159417	160541
Bear Survival Edge  		77110	  9645	  	20517
Seeker 35			    	78110	  131039	397919
Seeker Extreme		  		80110	  127031	252154
Seeker Mini				    81110	  89137	  	190845
Glacier Basic		    	82110	  24822	  	217694
Glacier Deluxe		  		83110	  98125	  	145767
Capri				        123110	  33551	  	35542
Capri				        123140	  167754	432675
Capri				        123150	  144429	216586
Cat Eye				       	124160	  267169	510942
Cat Eye			    	  	124180	  274592	370362
Venue				        125110	  236739	288715
Dante				        126150	  109093	321490
Fairway				       	127130	  743708	749828
Inferno					    128200	  1164290	1243788
Inferno					    128210	  457220	488294
Infinity			      	129110	  290674	389861
Infinity				    129130	  757910	766405
Infinity			      	129150	  683514	702818
Infinity				    129180	  325941	382962
Lux					        130140	  8527	  	10032
Pocket Gizmo		    	134120	  39590  	53238
Pocket Gizmo		    	134140	  12036	  	15016
Ranger Vision		    	135110	  96648  	98490
Sam					        136130	  474466	508901
Sam					        136140	  264833	368325
Trendi				      	143140	  31039  	188112
TX						    144150	  34026  	39376
TX						    144170	  79002	  	145719
TX						    144180	  2314600	2326800
Legend				      	145130	  172894	243038
Zodiak				      	146110	  9746	  	36902
Zodiak				      	146130	  20805	  	39310
Zone				        147140	  322324  	363784
Zone				        147150	  159224  	422210
Hawk Eye			      	148110	  295360 	329688
Hawk Eye			    	148130	  720766	863741
Retro					    149120	  60019	  	90968
Retro				      	149140	  589599	873842
Retro					    149150	  211882	734885
Sky Pilot			      	152110	  220170	303942
*/



-- 			8.1 Misma Consulta pero con un procedimiento diferente
-- Trimestres aislados con QUARTER, Join con la tabla de productos y agregacion pro trimestres y productos
SELECT
	QUARTER(v.fecha) AS quarters,
  v.id_prod AS id_prod,
  ROUND(SUM(v.facturacion), 2) AS facturacion
FROM ventas_agr AS v
JOIN productos AS p
  ON v.id_prod = p.id_prod
WHERE p.linea = 'Personal Accessories'
	AND fecha BETWEEN '2018-01-01' AND '2018-06-30'
GROUP BY 1,2
ORDER BY 2;
/*
Creacion de 2 VISTAS (VIEWS)
	vista_tablaQ1
    vista_tablaQ2
para mantener separados ambos trimestres y pdoer realizar el cruce y comparacion entre ambos    
*/
CREATE VIEW vista_tablaq1 AS -- Creacion de Vista1 (Trimestre 1)
WITH tabla_q1 AS(
SELECT
	QUARTER(v.fecha) AS quarters,
  v.id_prod AS id_prod,
  ROUND(SUM(v.facturacion), 2) AS facturacion
FROM ventas_agr AS v
JOIN productos AS p
	ON v.id_prod = p.id_prod
WHERE p.linea = 'Personal Accessories'
	AND fecha BETWEEN '2018-01-01' AND '2018-06-30'
GROUP BY 1,2
ORDER BY 2
)
SELECT 
  *
FROM tabla_q1
WHERE quarters = 1;


CREATE VIEW vista_tablaq1 AS -- Creacion de Vista2 (Trimestre 2)
WITH tabla_q1 AS(
SELECT
	QUARTER(v.fecha) AS quarters,
  v.id_prod AS id_prod,
   ROUND(SUM(v.facturacion), 2) AS facturacion
FROM ventas_agr AS v
JOIN productos AS p
	ON v.id_prod = p.id_prod
WHERE p.linea = 'Personal Accessories'
	AND fecha BETWEEN '2018-01-01' AND '2018-06-30'
GROUP BY 1,2
ORDER BY 2
)
SELECT 
  *
FROM tabla_q1
WHERE quarters = 1;
/*
Consulta Final: Cruce de ambas tablas (Vistas) para colocarlas de manera horizontal y resta del total del Q2 menos el total del Q1

	- si el resultado de la operacion da un numero Positivo (mayor a 0),
	quiere decir que el Q2 fue MAYOR a Q1, por ende, es un producto en Tendencia

	- si el resultado de la operacion da un numero Negativo (menor a 0)
	quiere decir que el Q2 fue MENOR a Q1, por ende, es un producto que NO ESTA en Tendencia

Agrupado por producto y filtrado para que unicamente mostrara los productos donde el resultado fuese MAYOR a 0 (en Tendencia)
*/
SELECT
	q1.id_prod,
  ROUND(q2.facturacion - q1.facturacion, 2) AS diferencia_entre_q2_q1
FROM vista_tablaq1 AS q1
JOIN vista_tablaq2 AS q2
	ON q1.id_prod = q2.id_prod
GROUP BY 1
HAVING diferencia_entre_q2_q1 > 0;
/*
RESPUESTA:
ID	      	DIFERENCIA DE FACTURACION DE Q2 - Q1
63110		  	44123.26
64110			  27404.88
65120			  41803.47
67110		  	31557.34
68120		  	71710.05
68190		  	8048.07
68200		  	22949.51
68240		  	14507.69
68250		  	157091.51
69110		  	79510.47
69120		  	66161.7
70120		  	6054.53
70140		  	57235.87
70160		  	25352.19
70200		  	14221.54
70240		  	18309.94
71110		  	47571.44
72110			  19484.08
74110			  4019.13
75110			  198310.24
76110		  	1123.69
77110		  	10872.32
78110		  	266880.04
80110			  125122.34
81110		  	101708.14
82110			  192871.95
83110		  	47642.4
123110			1991.6
123140			264921.1
123150			72157.2
124160			243772.8
124180			95770
125110			51976
126150			212396.5
127130			6120
128200			79497.6
128210			31074.4
129110			99187.2
129130			8495.2
129150			19304
129180			57021
130140			1504.8
134120			13648.2
134140			2979.9
135110			1842.5
136130			34434.4
136140			103492.4
143140			157073.6
144150			5350
144170			66717
144180			12200
145130			70144
146110			27156
146130			18505.5
147140			41459.25
147150			262986.3
148110			34328.25
148130			142975
149120			30949.1
149140			284243.05
149150			523002.2
152110			83772

		
        IMPORTANTE
        
	Ambas soluciones arrojaron:
		- Misma cantidad de registors (62)
		- Exactamente los mismos registros por ID de Producto
			Los 62 registros son los mismos en ambas consultas
*/







