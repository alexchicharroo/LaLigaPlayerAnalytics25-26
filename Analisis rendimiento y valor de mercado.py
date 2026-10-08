import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
Perfiles_jugadores= pd.read_csv("Perfiles_jugadores_limpio.csv", sep=";", decimal=",")
Estadisticas_jugadores= pd.read_csv("Estadisticas_jugadores_limpio.csv", sep=";", decimal=",")
##---REVISIÓN DE LA TABLA Y TIPOS DE DATOS----##
print(Perfiles_jugadores.head())
print(Estadisticas_jugadores.head())
print(Perfiles_jugadores.shape) #530 filas y 6 columnas
print(Estadisticas_jugadores.shape) #487 filas y 19 columnas
print(Perfiles_jugadores.dtypes) #hay que cambiar player id
print(Estadisticas_jugadores.dtypes) #hay que cambiar player id
Perfiles_jugadores["player_id"]=Perfiles_jugadores["player_id"].astype(str)
Estadisticas_jugadores["player_id"]=Estadisticas_jugadores["player_id"].astype(str)
print(Perfiles_jugadores.duplicated().sum()) #no hay duplicados
print(Estadisticas_jugadores.duplicated().sum()) #no hay duplicados
print(Perfiles_jugadores.isnull().sum()) #aqui no hay nulos
print(Estadisticas_jugadores.isnull().sum()) #expected_goals tienen 55 nulos, expected assists tiene 1 nulo. Que se mantienen de momento para ver depués su tratamiento.

##----UNIÓN DE LOS DATOS,REVISION Y DESCIPCION---##
datos=Estadisticas_jugadores.merge(Perfiles_jugadores, on="player_id", how="inner")
print(datos.head())
print(datos.shape) #487 filas y 24 columnas
print(datos.dtypes)
print(datos["player_id"].duplicated().sum()) #no hay duplicados
print(datos[["minutes_played","goals", "assists", "rating", "tackles_e_intercepciones", "saves","valor_mercado"]].describe()) #se nota la aparición de los porteros, y en las paradas al revés.

##----EXPLORACIÓN DE LOS DATOS----##
##Valor de mercado. Histograma y valores extremos
sns.histplot(data=datos, x="valor_mercado", bins=20) 
plt.title("Distribución del valor de mercado")
plt.xlabel("Valor de mercado") 
plt.ylabel("Frecuencia") 
plt.tight_layout() 
plt.show()

sns.boxplot(data=datos, y="valor_mercado")
plt.title("Valores extremos del valor de mercado")
plt.ylabel("Valor de mercado")
plt.tight_layout()
plt.show() ##hay varios ya que la mayoria tienen un valor muy bajo, pero destacan dos sobre los 200M€

##Distribución del rating
sns.histplot(data=datos, x="rating", bins=20) 
plt.title("Distribución del rating")
plt.xlabel("Rating") 
plt.ylabel("Frecuencia") 
plt.tight_layout() 
plt.show() ##mayoria entre el 6.5 y el 7.

##Relación rating con el valor de mercado
sns.scatterplot(data=datos, x="rating", y="valor_mercado")
plt.title("Rating vs valor de mercado")
plt.xlabel("Rating")
plt.ylabel("Valor de mercado")
plt.tight_layout()
plt.show() #se ve un punto con mucho rating y poco valor de mercado que puede ser por minutos jugados.

##Relación produccion ofensiva y valor de mercado
datos["produccion_ofensiva"]=datos["goals"]+ datos["assists"]
sns.scatterplot(data=datos, x="produccion_ofensiva", y="valor_mercado")
plt.title("Producción ofensiva vs valor de mercado")
plt.xlabel("Producción ofensiva")
plt.ylabel("Valor de mercado")
plt.tight_layout()
plt.show() #destacan Lamine y Mbappe, muchos se encuentran entre los mismos valores y puede ser por la edad,no tener proyeccion como Muriqui...

##Correlaciones
variables_correlacion=datos[["valor_mercado", "rating","minutes_played", "goals", "assists", "expected_goals", "expected_assists"]]
correlaciones=variables_correlacion.corr()
print(correlaciones)

sns.heatmap(correlaciones,annot=True)
plt.title("Matriz de correlaciones")
plt.tight_layout()
plt.show()

##Valor de mercado según la posición
sns.boxplot(data=datos,x="position",y="valor_mercado")
plt.title("Valor de mercado según posición")
plt.xlabel("Posición")
plt.ylabel("Valor de mercado")
plt.xticks(rotation=45)
plt.tight_layout()
plt.show()

##----ESTUDIO RENDIMIENTO----##
##Rendimiento ofensivo
datos["diferencia_goles"]=datos["goals"]-datos["expected_goals"]
datos["diferencia_asistencias"]=datos["assists"]-datos["expected_assists"]

print(datos[["name", "diferencia_goles"]].sort_values("diferencia_goles", ascending=False).head(5)) ##guedes, buchanan, espí, lamine, moleiro
print(datos[["name", "diferencia_asistencias"]].sort_values("diferencia_asistencias", ascending=False).head(5)) ##fermín, milla, pedri, mikautadze, vargas
print(datos[["name", "diferencia_goles"]].sort_values("diferencia_goles", ascending=True).head(5)) ##mateo joseph, sancet, pablo ibañez, iñaki williams, aleñá
print(datos[["name", "diferencia_asistencias"]].sort_values("diferencia_asistencias", ascending=True).head(5)) ##carlos alvarez, tchouameni, raphinha, nico williams, mastantuono

sns.scatterplot(data=datos,x="diferencia_goles",y="valor_mercado")
plt.title("Diferencia goles-xG vs valor de mercado")
plt.xlabel("Goles - xG")
plt.ylabel("Valor de mercado")
plt.tight_layout()
plt.show() ##no se ve relación, pero se puede ver que los que más diferencia tienen con lo esperado tienen un valor bajo.

sns.scatterplot(data=datos,x="diferencia_asistencias",y="valor_mercado")
plt.title("Diferencia asistencias-xA vs valor de mercado")
plt.xlabel("Asistencias - xA")
plt.ylabel("Valor de mercado")
plt.tight_layout() ##tampoco hay gran relación, pero se ve que aqui si hay valores de valor de mercado mayores en los que han asistido mas de lo esperado.
plt.show()

##Rendimiento en acciones defensivas
sns.scatterplot(data=datos, x="tackles_e_intercepciones", y="valor_mercado", hue="position")
plt.title("Acciones defensivas vs valor de mercado por posición")
plt.xlabel("Acciones defensivas")
plt.ylabel("Valor de mercado")
plt.tight_layout()
plt.show() #se ve que los que mas acciones defensivas hacen son los defenas y mediocentros pero tienen poco valor de mercado

##Valor de mercado Porteros según paradas.
sns.scatterplot(data=datos[datos["position"]=="Portero"], x="saves", y="valor_mercado")
plt.title("Paradas vs valor de mercado")
plt.xlabel("Paradas")
plt.ylabel("Valor de mercado")
plt.tight_layout()
plt.show() #se ve que tienen un bajo valor de mercado, pero no se ve una relación entre ellos

##Relacion rating vs valor de mercado por posicion
sns.scatterplot(data=datos, x="rating", y="valor_mercado", hue="position")
plt.title("Rating vs valor de mercado por posición")
plt.xlabel("Rating")
plt.ylabel("Valor de mercado")
plt.tight_layout()
plt.show() #hay alguna relacin directa, y se ve que los delanteros y  mediocentros tienen mayor rating y valor de mercado

##Relacion produccion ofensiva con valor de mercado sin tener en cuenta los porteros
sns.scatterplot(data=datos[datos["position"]!="Portero"], x="produccion_ofensiva", y="valor_mercado")
plt.title("Goles y asistencias vs valor de mercado")
plt.xlabel("Goles+asistencias")
plt.ylabel("Valor de mercado")
plt.tight_layout()
plt.show() #hay una pequeña relacion directa en los jugadores con mas valor, con un atipico con mucha produccion pero poco valor de mercado.



