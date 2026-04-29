# Retail Data Architecture & Advanced Business Analytics (SQL)

## 👤 Perfil Profesional
**Administrador de Empresas** con enfoque en **Data Engineering**. Especializado en la creación de arquitecturas de datos sólidas, limpieza de datos críticos y modelado relacional (Star Schema). Mi fuerte es el procesamiento de datos en el backend para garantizar reportes eficientes y escalables.

---

## 🎯 Objetivo del Proyecto
Transformar un dataset crudo de retail con más de 149,000 registros en una infraestructura analítica optimizada. El proyecto cubre desde la ingesta y limpieza inicial hasta la creación de un motor de recomendaciones avanzado.

## 🛠️ Stack Tecnológico
* **Lenguaje:** SQL (MySQL)
* **Técnicas:** CTEs, Window Functions, Self-Joins, Integridad Referencial, Normalización.
* **Sintaxis Forzada:** Configurada mediante `.gitattributes` para reconocimiento de MySQL.

---

## 📂 Estructura del Repositorio (6 Etapas)
El proyecto se divide en módulos que representan el ciclo de vida completo del dato:

1.  **[01_Etapa_Limpieza](./sql_scripts/01_data_cleaning.sql):** Normalización de fechas, corrección de tipos y deduplicación.
2.  **[02_Etapa_Modelado](./sql_scripts/02_data_modeling.sql):** Diseño de arquitectura (PKs/FKs) y creación de la lógica de pedidos (Vista transaccional).
3.  **[03_Analisis_Metricas](./sql_scripts/03_exploratory_data_analysis.sql):** Auditoría de volúmenes, KPIs globales y cobertura temporal.
4.  **[04_Analisis_Negocio](./sql_scripts/04_business_performance_insights.sql):** Estacionalidad (Calendario Fiscal de Julio a Junio) y rendimiento de canales.
5.  **[05_Analisis_Clientes_Tiendas](./sql_scripts/05_customer_behavior_segmentation.sql):** Matriz de segmentación, análisis de reactivación (Churn) y potencial de desarrollo.
6.  **[06_Recomendador](./sql_scripts/06_market_basket_engine.sql):** Motor de analítica avanzada basado en Market Basket Analysis y sugerencias personalizadas.

---

## 📊 Resultados e Impacto
* **Eficiencia:** Creación de un modelo relacional que reduce la redundancia de datos.
* **Visión Estratégica:** Implementación de métricas de segmentación que identifican tiendas con baja productividad y clientes en riesgo.
* **Valor Agregado:** Motor de recomendación funcional para estrategias de Cross-selling directamente desde SQL.
