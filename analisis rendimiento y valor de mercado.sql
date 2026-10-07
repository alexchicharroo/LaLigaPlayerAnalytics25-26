---- PROYECTO ANÁLISIS FUTBOLISTAS ----

---- LIMPIEZA DE VARIABLES NUMÉRICAS ----
UPDATE Perfiles_jugadores_limpio
SET valor_mercado = CAST(REPLACE(valor_mercado, ',', '.') AS REAL);

UPDATE Estadisticas_jugadores_limpio
SET rating = CAST(REPLACE(rating, ',', '.') AS REAL),
    expected_goals = CAST(REPLACE(expected_goals, ',', '.') AS REAL),
    expected_assists = CAST(REPLACE(expected_assists, ',', '.') AS REAL);

----RESUMEN GENERAL----
SELECT COUNT(player_id) AS numero_jugadores, ROUND(AVG(valor_mercado), 2) AS valor_medio, MIN(valor_mercado) AS valor_minimo,MAX(valor_mercado) AS valor_maximo FROM Perfiles_jugadores_limpio;

----ANÁLISIS POR POSICIÓN----
SELECT pjl.position, COUNT(pjl.player_id) AS numero_jugadores, ROUND(AVG(pjl.valor_mercado), 2) AS valor_medio,ROUND(AVG(ejl.rating), 2) AS rating_medio FROM Perfiles_jugadores_limpio pjl
LEFT JOIN Estadisticas_jugadores_limpio ejl ON pjl.player_id = ejl.player_id GROUP BY pjl.position ORDER BY valor_medio DESC;

----TOP 10 JUGADORES POR VALOR DE MERCADO----
SELECT name, position, valor_mercado FROM Perfiles_jugadores_limpio ORDER BY valor_mercado DESC LIMIT 10; --Lamine, Mbappe, Vinicius, Pedri, Jude, Valverde, Fermin, Julian, Guler, Tchouameni

----RENDIMIENTO OFENSIVO: MÁS GOLES----
SELECT pjl.name, pjl.position, ejl.goals, ejl.minutes_played, ejl.rating FROM Perfiles_jugadores_limpio pjl INNER JOIN Estadisticas_jugadores_limpio ejl ON pjl.player_id = ejl.player_id 
ORDER BY ejl.goals DESC LIMIT 10; --Mbappe, Muriqui, Lamine, Budimirr, Ferran, Oyarzabal, Lewandowski, Raphinha, Vinicius, Borja Iglesias

----RENDIMIENTO OFENSIVO: MÁS ASISTENCIAS----
SELECT pjl.name, pjl.position, ejl.assists, ejl.minutes_played, ejl.rating FROM Perfiles_jugadores_limpio pjl INNER JOIN Estadisticas_jugadores_limpio ejl ON pjl.player_id = ejl.player_id
ORDER BY ejl.assists DESC LIMIT 10; --Lamine, Milla, Fermin, Guler, Pedri, Valverde, Rashford, Olmo, Simeone, Edu Exposito

----MEJORES RATINGS CON MÍNIMO 900 MINUTOS----
SELECT pjl.name, ejl.minutes_played, ejl.rating FROM Perfiles_jugadores_limpio pjl INNER JOIN Estadisticas_jugadores_limpio ejl ON pjl.player_id = ejl.player_id WHERE ejl.minutes_played >= 900
ORDER BY rating DESC LIMIT 10; --Lamine, Mbappe, Pedri, Raphinha, Joan, Dituro, De Jong, Vini, Militao, Ryan

----MAYOR DIFERENCIA POSITIVA GOLES - xG----
SELECT pjl.name, ejl.goals, ejl.expected_goals, ROUND((ejl.goals - ejl.expected_goals),2) AS diferencia_goles FROM Perfiles_jugadores_limpio pjl INNER JOIN Estadisticas_jugadores_limpio ejl
ON pjl.player_id = ejl.player_id  ORDER BY diferencia_goles DESC LIMIT 5; --Guedes, Buchanan, Espi, Lamine, Moleiro

----MAYOR DIFERENCIA NEGATIVA GOLES - xG----
SELECT pjl.name, ejl.goals, ejl.expected_goals, ROUND((ejl.goals - ejl.expected_goals),2) AS diferencia_goles FROM Perfiles_jugadores_limpio pjl INNER JOIN Estadisticas_jugadores_limpio ejl
ON pjl.player_id = ejl.player_id  ORDER BY diferencia_goles ASC LIMIT 5; --Sancet, Mateo Joseph, Pablo Ibañez, Iñaki Williams, Aleñá

----MAYOR DIFERENCIA POSITIVA ASISTENCIAS - xA----
SELECT pjl.name, ejl.assists, ejl.expected_assists, ROUND((ejl.assists - ejl.expected_assists),2) AS diferencia_asistencias FROM Perfiles_jugadores_limpio pjl INNER JOIN Estadisticas_jugadores_limpio ejl
ON pjl.player_id = ejl.player_id  ORDER BY diferencia_asistencias DESC LIMIT 5; --Fermin, Luis Milla, Pedri, Mikautadze, Vargas

----MAYOR DIFERENCIA NEGATIVA ASISTENCIAS - xA----
SELECT pjl.name, ejl.assists, ejl.expected_assists, ROUND((ejl.assists - ejl.expected_assists),2) AS diferencia_asistencias FROM Perfiles_jugadores_limpio pjl INNER JOIN Estadisticas_jugadores_limpio ejl
ON pjl.player_id = ejl.player_id  ORDER BY diferencia_asistencias ASC LIMIT 5; --Carlos Alvarez, Tchouameni, Raphinha, Nico Williams, Mastantuono

----POSICIONES CON MAYOR VALOR DE MERCADO
----SOLO POSICIONES CON AL MENOS 80 JUGADORES----
SELECT position, COUNT(player_id) AS numero_jugadores, ROUND(AVG(valor_mercado),2) AS valor_medio FROM Perfiles_jugadores_limpio GROUP BY position HAVING COUNT(player_id) >= 80
ORDER BY valor_medio DESC;

----TOP 3 CON MAYOR VALOR DE MERCADO POR POSICION----
WITH ranking as (SELECT pjl.position, pjl.name,pjl.valor_mercado, RANK()OVER(PARTITION BY pjl.position ORDER BY pjl.valor_mercado DESC) as ranking_posicion from Perfiles_jugadores_limpio pjl) 
SELECT * FROM ranking WHERE ranking_posicion<=3 ;
