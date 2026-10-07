# ⚽ LaLiga 2025/26 — Rendimiento y valor de mercado

## 📌 Descripción

Proyecto de análisis de datos sobre jugadores de **LaLiga 2025/26** cuyo objetivo es estudiar la relación entre el **rendimiento deportivo y el valor de mercado**.

### 🎯 Pregunta principal

> **¿Hasta qué punto el rendimiento deportivo de un jugador explica su valor de mercado?**

---

## 📂 Fuente de los datos

Los datos utilizados proceden del dataset **European Top Football Leagues Player Stats 25–26**, disponible en **Kaggle**.

El dataset contiene información sobre jugadores de las principales ligas europeas. Para este proyecto se seleccionaron únicamente los jugadores de **LaLiga**, trabajando principalmente con dos conjuntos de datos:

- **Perfiles de jugadores:** nombre, posición y valor de mercado.
- **Estadísticas de jugadores:** minutos jugados, rating, goles, asistencias, xG, xA, tiros, acciones defensivas, paradas y otras estadísticas de rendimiento.

Tras el proceso de limpieza y preparación, el análisis incluye **530 jugadores de LaLiga**.

> ⚠️ **Nota:** las estadísticas corresponden al momento en el que fue extraído el dataset durante la temporada 2025/26. Por tanto, representan una fotografía parcial de la temporada y no los resultados finales.

**Fuente:** [Kaggle - European Top Football Leagues Player Stats 25–26] https://www.kaggle.com/code/hosseinbadrnezhad/european-top-leagues-player-stats-25-26-etl-eda-vi/input?select=all_player_stats.csv

---

## 🛠️ Herramientas utilizadas

- **Excel** → limpieza, transformación y análisis inicial de los datos.
- **SQL** → consultas y análisis del rendimiento de los jugadores.
- **Power BI** → creación de un dashboard interactivo.
- **Python** → análisis exploratorio y visualización de datos.
- **R** → análisis estadístico y modelos de regresión.
  
---

- ## 🔎 Análisis realizado

Se analizaron **530 jugadores**, estudiando variables como:

- Valor de mercado
- Rating
- Minutos jugados
- Goles y asistencias
- Goles esperados (xG) y asistencias esperadas (xA)
- Acciones defensivas
- Posición

El análisis permitió estudiar la distribución del valor de mercado, las diferencias entre posiciones y la relación entre distintas métricas de rendimiento y la valoración de los jugadores.

También se utilizaron modelos de regresión en **R** para analizar hasta qué punto las estadísticas deportivas permiten explicar las diferencias en el valor de mercado.

---

## 📊 Principales resultados

- El **rating** presentó la mayor relación con el valor de mercado entre las variables analizadas.
- Un modelo utilizando únicamente el rating obtuvo un **R² del 32,01 %**.
- Al incorporar otras estadísticas de rendimiento, el R² aumentó hasta aproximadamente **43,75 %**.
- Añadir la posición del jugador produjo una mejora reducida, alcanzando un **R² aproximado del 44,9 %**.
- Los resultados muestran que el rendimiento deportivo está relacionado con el valor de mercado, pero **solo explica una parte de su variabilidad**.







