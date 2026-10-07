library(tidyverse)
library(dplyr)
library(ggplot2)
perfiles_jugadores=read.csv("Perfiles_jugadores_limpio.csv", dec = ",", sep=";")
estadisticas_jugadores=read.csv("Estadisticas_jugadores_limpio.csv", dec = ",", sep=";")
head(estadisticas_jugadores)
head(perfiles_jugadores)
glimpse(estadisticas_jugadores) #hay que cambiar player id, 
glimpse(perfiles_jugadores)
summary(estadisticas_jugadores)
summary(perfiles_jugadores)
colSums(is.na(estadisticas_jugadores)) ##55 expected goals y una expected assists
colSums(is.na(perfiles_jugadores))
sum(duplicated(perfiles_jugadores))
sum(duplicated(estadisticas_jugadores))

##--- CAMBIO VARIABLES ---##
perfiles_jugadores$player_id=as.character(perfiles_jugadores$player_id)
estadisticas_jugadores$player_id=as.character(estadisticas_jugadores$player_id)

##--- UNION TABLAS ---##
datos <- perfiles_jugadores %>%inner_join(estadisticas_jugadores,by = "player_id")
head(datos)
glimpse(datos)
summary(datos)
colSums(is.na(datos))

##--- EJERCICIOS ---#
#1.Seleccionar algunas variables
datos%>% select(,c(name, position, valor_mercado, minutes_played, rating))

#2.Jugadores con mas de 900 min
datos[datos$minutes_played>900,]

#3. Ordenar jugadores con valor de mercado
datos%>%arrange(desc(valor_mercado))

#4. Valor medio del rating
mean(datos$rating, na.rm = TRUE)

#5.Por posicion numero de jugadores y valor medio
datos%>%group_by(position)%>%summarise(
  numero_jugadores= n(),
  valor_mercado_medio= round(mean(valor_mercado, na.rm=TRUE),2)
)%>% arrange(desc(numero_jugadores))


##Comienza análisis estadístico
#DISTRIBUCION VALOR DE MERCADO
summary(datos$valor_mercado)
sd(datos$valor_mercado, na.rm = TRUE)

#LOG DEL VALOR DE MERCADO PARA COMPARAR MAS ADELANTE
datos$log_valor_mercado=log(datos$valor_mercado)
summary(datos$log_valor_mercado) #media y mediana se acercan
sd(datos$log_valor_mercado, na.rm = TRUE)

#CORRELACION DE VALOR DE MERCADO Y LOG
variables <- datos[, c("valor_mercado","rating","goals","assists","expected_goals","expected_assists","minutes_played")]
matriz_cor <- cor(variables, use = "complete.obs")
matriz_cor["valor_mercado",]

variables2 <- datos[, c("log_valor_mercado","rating","goals","assists","expected_goals","expected_assists","minutes_played")]
matriz_cor2 <- cor(variables2, use = "complete.obs")
matriz_cor2["log_valor_mercado",]
#hay mas relacion con la variable normal excepto en minutos jugados

#CALCULA POR POSICION NUMERO, MEDIA Y MEDIANA DELVALOR DE MERCADO
datos%>%group_by(position)%>%summarise(
  numero_jugadores= n(),
  valor_medio_mercado= round(mean(valor_mercado, na.rm=TRUE),2),
  valor_mediano_mercado= round(median(valor_mercado, na.rm=TRUE),2)
)

#DATOS DE VALOR DE MERCADO POR POSICION
ggplot(datos, aes(x = position, y = valor_mercado)) +
  geom_boxplot()

##La media y la mediana están bastante alejadas en general. Con el log se acercan bastante 
##El rating tiene la correlacion más alta con el valor de mercado.
##El valor medio de mercado es mucho más alto que el valor mediano por posicion.
##En cuanto a los boxplot podemos ver que donde menos atipicos hay es en los porteros. Que en todas las posiciones la mayoría esta entre 0 y  unos 20-30 millones. En el medio y delanteros son los valores más altos.

##---REGRESION LINEAL CON R---#
datos_modelo <- datos %>%
  select(valor_mercado,log_valor_mercado,rating,goals,assists,expected_goals,expected_assists,minutes_played,position,tackles_e_intercepciones
  ) %>%
  na.omit()
#REG LINEAL SIMPLE
modelo1<-lm(valor_mercado~rating, data=datos_modelo)
modelo2<-lm(log_valor_mercado~rating, data=datos_modelo)
summary(modelo1) ##significativo, r^2 de 0.3201, muy bajo
summary(modelo2) ##significativo, r^2 de 0.2472, más bajo aún. Coeficientes mucho más pequeños en valor absoluto.

##MODELO MULTIPLE RENDIMIENTO OFENSIVO
modelo3<-lm(valor_mercado~rating+goals+assists+expected_goals+expected_assists+minutes_played, data=datos_modelo)
summary(modelo3) #coeficientes muy pequeños, goals no es significativa y algunas variables solo al 0.1. Rating y minutos las que más. El r^2 ha subido a 0.4375
modelo4<-lm(log_valor_mercado~rating+goals+assists+expected_goals+expected_assists+minutes_played, data=datos_modelo)
summary(modelo4) #solo rating significativa, minutos y assists solo al 0.1. R^2 muy bajo aún 0.32

#Añadimos position
modelo5<-lm(valor_mercado~rating+goals+assists+expected_goals+expected_assists+minutes_played+position, data=datos_modelo)
summary(modelo5) #al añadir posocion, defensa ni nos sale, delantero si es significativa. Pero el r^2 sigue estando en 0.449
modelo6<-lm(log_valor_mercado~rating+goals+assists+expected_goals+expected_assists+minutes_played+position, data=datos_modelo)
summary(modelo6) #significacion igual que sin position, y el R^2 sigue siendo 0.3315.

##No ha habido una gran mejora con log, osea que nos quedariamos con modelo 3 o 5
##por lo que vamos a realizar predicciones con el modelo 5.
##--- PREDICCIONES ---##
predicciones<-predict(modelo5)
residuos<-residuals(modelo5)
datos_modelo$prediccion <- predicciones
datos_modelo$residuo <- residuos
plot(modelo5)
#El modelo capta parte de la relación entre rendimiento y valor de mercado, 
#pero tiene dificultades especialmente con los jugadores de mayor valor. Los residuos no se distribuyen aleatoriamente alrededor de cero, 
#por lo que el ajuste lineal no explica igual de bien todo el rango de valores.

#Los residuos se aproximan a la normalidad en la parte central, pero presentan desviaciones importantes en los extremos, 


##Parece que hay heterocedasticidad, ya que la dispersion de los errores aumenta segun crecen los valores ajustados. Deberia ser horizontal

##Hay valores influyentes que se alejan del resto

##---COMPARACION REAL VS PREDICCION---##
ggplot(datos_modelo, aes(x = valor_mercado, y = prediccion)) +
  geom_point() +
  geom_abline(intercept = 0, slope = 1, linetype = "dashed") +
  labs(
    x = "Valor de mercado real",
    y = "Valor predicho",
    title = "Valor real vs predicción"
  ) ##en valores bajos hay dispersion, y en valores altos, el modelo subestima a algunos jugadores.

##---RMSE---##
rmse <- sqrt(mean((datos_modelo$valor_mercado - datos_modelo$prediccion)^2,na.rm = TRUE))

rmse #El modelo presenta un RMSE de 17,76 millones de euros, lo que indica un error de predicción considerable. 
#Además, el gráfico de valor real frente a predicción muestra que los mayores errores se concentran en jugadores con valores de mercado elevados.


###---CONCLUSIONES---#
# 1. El valor de mercado presenta una distribución claramente asimétrica, con una media superior a la mediana y con valores atípicos,
# destacando loscentrocampistas y delanteros. La mayoría de jugadores se concentra en valores de mercado relativamente bajos frente a unos pocos
# futbolistas con valoraciones muy elevadas.

#2.La transformación logarítmica reduce esta asimetría y acerca la media y la mediana, pero tienen menor correlación las variables con log_valor_mercado.

#3.El rating es la que más relación tiene con valor de mercado pero si usamos exclusivamente esta variable, explica un 32.01% de la variabilidad del modelo.

#4.Aumentando las variables añadiendo variables ofensivas, aumenta a un 43,75%, teniendo importancia rating y minutos jugados.

#5.Añadir la posicion del jugador  aumenta muy poco el R^2 de 43,75% a 44,9%

#6.Los modelos con log reducen el R^2, por lo que aunque mejore la distribución, no mejora la capacidad explicativa.

#7.Los gráficos muestran problemas del modelo lineal. Los residuos presentan desviaciones en los extremos y  la dispersión aumenta, 
#lo que puede indicar heterocedasticidad. Además hay variables influyentes, con valores altos de mercado.

#8.Comparando los valores reales y las predicciones se ve que predice bien la tendencia general (de forma razonable) pero tiene problemas con valores altos.

#9.El rmse de 17,76 indica un error de estimación que puede deberse a la falta de variables como puede ser la edad, proyección, contrato... Deja claro que hay más variables
#a parte de las deportivas que aumentan el valor de mercado.

#10.Indica que hay relación entre el rendimiento y el valor de mercado, pero de forma limitada.