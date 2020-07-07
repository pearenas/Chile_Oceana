Reporte Published Data Preliminar Oceana Chile AMP Pisagua
================
Esteban Arenas
7/3/2020

Nada del código corre dentro de este Rmarkdown pero lo incluyo nada más
para que se pueda evaluar la metodología. Este es un reporte preliminar
que solo muestra el código usado y los resultados obtenidos. Podremos ir
modificándolo para llegar a la versión final.

UniqueVessNames es la base de datos que se generó previamente en el
análisis AIS. Contiene todas las embarcaciones VMS Chile que estén
dentro del PDF que nos dio Oceana Chile

El resto del proceso se explica en los comentarios del código

``` sql
SELECT vessel_id, n_shipname.value
FROM `world-fishing-827.pipe_chile_production_v20200331.vessel_info`
INNER JOIN `world-fishing-827.scratch_Esteban.UniqueVessNames_`
  ON `world-fishing-827.pipe_chile_production_v20200331.vessel_info`.n_shipname.value = `world-fishing-827.scratch_Esteban.UniqueVessNames_`.string_field_2
```

``` r
#Multiple vessel ids per vessel name
write.csv(Vessel_id, file = "Vessel_id.csv")
```

``` sql
WITH
JOINED AS (
SELECT event_type,vessel_id,event_start,event_end,lat_mean,lon_mean,lat_min,lat_max,lon_min,lon_max
FROM `world-fishing-827.pipe_chile_production_v20200331.published_events_fishing`
INNER JOIN `world-fishing-827.scratch_Esteban.Vessel_id`
  ON `world-fishing-827.pipe_chile_production_v20200331.published_events_fishing`.vessel_id = `world-fishing-827.scratch_Esteban.Vessel_id`.vessel_id_2
)
SELECT *
FROM JOINED
WHERE event_start BETWEEN TIMESTAMP('2019-02-01')
AND TIMESTAMP('2020-06-13')
AND lat_min > -22 and lat_max < -18.6 and lon_min > -74 and lon_max < -69.8
```

``` r
Published_Data_Copy <- copy(Published_Data)
#Add associated vessel name
Published_Data_Copy$n_shipname <- AISChileVessels_ID$value[match(Published_Data_Copy$vessel_id, AISChileVessels_ID$vessel_id)]
#Order by n_shipname and then timestamp
Published_Data_Copy <- Published_Data_Copy[with(Published_Data_Copy, order(vessel_id, event_start)),]
#Calculate time in between timestamps
#Convert timestamp to epoch seconds
Published_Data_Copy$EpochSec_Start <- as.integer(as.POSIXct(Published_Data_Copy$event_start))
Published_Data_Copy$EpochSec_End <- as.integer(as.POSIXct(Published_Data_Copy$event_end))
#Converting back to date to make sure epoch is correct
#as_datetime(Published_Data_Copy$EpochSec_Start[1])
#Calculate hours between event_start and event_end
Published_Data_Copy$hours <- (Published_Data_Copy$EpochSec_End - Published_Data_Copy$EpochSec_Start)/3600

#Resulting file is exported and clipped in QGIS according to each region.
#This file includes published fishing hours for all VMS available vessels of interest to Oceana Chile.
#Around 18 thousand rows for vessels between 2019-02-01 and 2020-06-13
write.csv(Published_Data_Copy, file = "Published_Data.csv")
############################################ START - "Published_Data.csv" saved used for cropping
#Published_Data <- read.csv ("/Users/Esteban/Documents/Jobs/GFW/Proyectos/Chile/Chile_Oceana/Final_Report/Tables/FullData/Published_Data.csv", header = TRUE)
```

**“Published\_Data.csv”** is exported and clipped in QGIS according to
each region. This file includes Published fishing hours for all VMS
available vessels of interest to Oceana Chile. This is around 18
thousand rows for vessels between 2019-02-01 and 2020-06-13

Clipped versions of the file, according to polygons of interest, are
then imported below: Tarapacá and Pisagua

``` r
##### 1.) TARAPACA
Vessels_Clip_Tarapaca_Published <- read.csv ("/Users/Esteban/Documents/Jobs/GFW/Proyectos/Chile/Chile_Oceana/Final_Report/Tables/FullData/Vessels_Clip_Tarapaca_Published.csv", header = TRUE)

UniqueVessNames <- read.csv ("/Users/Esteban/Documents/Jobs/GFW/Proyectos/Chile/Chile_Oceana/Data/UniqueVessNames.csv", header = TRUE)

#Aggregate by vessel, adding fishing hours
Tarapaca_FH_Published <- data.frame(aggregate(hours ~ n_shipname + vessel_id, Vessels_Clip_Tarapaca_Published, sum))
#Add associated vessel name
Tarapaca_FH_Published$Embarcacion <- UniqueVessNames$shipname[match(Tarapaca_FH_Published$n_shipname, UniqueVessNames$n_shipname)]
Tarapaca_FH_Published$Horas <- Tarapaca_FH_Published$hours
#Removing ID rows
Tarapaca_FH_Published <- Tarapaca_FH_Published[-c(1:3)]
#Order from highest to lowest hours
Tarapaca_FH_Published <- Tarapaca_FH_Published[with(Tarapaca_FH_Published, order(-Horas)),]

#Export final list of vessels and associated hours within
#Tarapaca region

#write.csv(Tarapaca_FH_Published, file = "Tarapaca_Horas_de_Pesca_Published.csv")
```

Resultados en horas de esfuerzo pesquero de las distintas áreas debajo

**Tarapacá**

Horas de Pesca

|    | Embarcacion                    |     Horas |
| -- | :----------------------------- | --------: |
| 11 | ATACAMA IV (IND)               | 602.13333 |
| 67 | ALBIMER (IND)                  | 576.80001 |
| 8  | HURACAN (IND)                  | 541.93833 |
| 46 | EPERVA 65 (IND)                | 541.26029 |
| 86 | AUDAZ (IND)                    | 539.32861 |
| 10 | COSTA GRANDE 1 (IND)           | 534.10000 |
| 90 | LOA 1 (IND)                    | 529.45001 |
| 21 | EPERVA 56 (IND)                | 513.29139 |
| 15 | DON ERNESTO AYALA MARFIL (IND) | 506.95472 |
| 34 | BARRACUDA IV (IND)             | 499.78750 |
| 74 | EPERVA 66 (IND)                | 495.63472 |
| 73 | CORPESCA 2 (IND)               | 492.64139 |
| 37 | CLAUDIA ALEJANDRA (IND)        | 492.55222 |
| 65 | RELAMPAGO (IND)                | 491.82917 |
| 13 | INTREPIDO (IND)                | 488.01722 |
| 69 | LOA 7 (IND)                    | 486.49167 |
| 33 | AVENTURERO (IND)               | 483.92527 |
| 47 | PARINA I (IND)                 | 482.77694 |
| 39 | LICANTEN (IND)                 | 468.66667 |
| 68 | DON GINO (IND)                 | 459.53639 |
| 2  | LOA 2 (IND)                    | 457.95000 |
| 44 | MERO (IND)                     | 454.31916 |
| 83 | ATACAMA V (IND)                | 445.86668 |
| 77 | EPERVA 61 (IND)                | 439.01111 |
| 9  | ANGAMOS 3 (IND)                | 437.34028 |
| 56 | ICALMA (IND)                   | 436.27806 |
| 52 | COLLEN (IND)                   | 431.63333 |
| 49 | TORNADO (IND)                  | 418.89972 |
| 76 | EPERVA 62 (IND)                | 405.97639 |
| 40 | ANGAMOS 4 (IND)                | 385.53388 |
| 58 | HALCON (IND)                   | 379.79694 |
| 70 | BLANQUILLO (IND)               | 377.82833 |
| 48 | EPERVA 51 (IND)                | 336.16278 |
| 25 | ANGAMOS 2 (IND)                | 325.70306 |
| 75 | EPERVA 64 (IND)                | 322.74750 |
| 30 | SALMON (IND)                   | 321.89694 |
| 72 | ANGAMOS 1 (IND)                | 319.73528 |
| 7  | ANGAMOS 9 (IND)                | 316.99417 |
| 82 | BANDURRIA (IND)                | 315.78139 |
| 51 | EPERVA 49 (IND)                | 305.80000 |
| 63 | ALERCE (IND)                   | 292.33334 |
| 31 | MARLIN (IND)                   | 285.87389 |
| 91 | PUCARA (IND)                   | 265.33500 |
| 64 | SAN JORGE I (IND)              | 240.95333 |
| 62 | SAN JORGE I (IND)              | 235.53333 |
| 6  | TRUENO I (IND)                 | 205.36444 |
| 55 | LOA 1 (IND)                    | 168.63333 |
| 18 | COLLEN (IND)                   | 162.51667 |
| 3  | CAMIÑA (IND)                   | 162.26861 |
| 66 | ATACAMA IV (IND)               | 133.20000 |
| 60 | LOA 7 (IND)                    | 132.91667 |
| 42 | LOA 2 (IND)                    | 131.05000 |
| 61 | BANDURRIA (IND)                | 128.53333 |
| 81 | ALBIMER (IND)                  | 128.26667 |
| 59 | EPERVA 49 (IND)                | 127.20000 |
| 54 | ATACAMA V (IND)                | 126.45000 |
| 22 | LICANTEN (IND)                 | 123.21667 |
| 38 | ALERCE (IND)                   | 115.40000 |
| 80 | CLAUDIA ALEJANDRA (IND)        | 115.28000 |
| 1  | ANGAMOS 1 (IND)                | 113.57889 |
| 89 | DON GINO (IND)                 | 113.14417 |
| 53 | HALCON (IND)                   | 111.65667 |
| 88 | EPERVA 65 (IND)                | 106.33917 |
| 57 | COSTA GRANDE 1 (IND)           | 105.70000 |
| 19 | ANGAMOS 3 (IND)                | 101.38278 |
| 14 | CORPESCA 2 (IND)               | 100.94167 |
| 24 | RELAMPAGO (IND)                |  92.67083 |
| 4  | AVENTURERO (IND)               |  92.52861 |
| 20 | SAN JORGE I (IND)              |  90.09167 |
| 29 | EPERVA 66 (IND)                |  86.50250 |
| 78 | HURACAN (IND)                  |  85.74139 |
| 71 | DON ERNESTO AYALA MARFIL (IND) |  85.14694 |
| 43 | ANGAMOS 4 (IND)                |  80.37834 |
| 12 | MARLIN (IND)                   |  76.28056 |
| 36 | PUCARA (IND)                   |  75.46750 |
| 16 | PARINA I (IND)                 |  61.84528 |
| 79 | BLANQUILLO (IND)               |  61.67389 |
| 84 | EPERVA 51 (IND)                |  60.10389 |
| 28 | AUDAZ (IND)                    |  56.92444 |
| 5  | MERO (IND)                     |  56.35167 |
| 41 | BARRACUDA IV (IND)             |  54.44528 |
| 45 | INTREPIDO (IND)                |  52.21417 |
| 17 | EPERVA 56 (IND)                |  50.97917 |
| 23 | TRUENO I (IND)                 |  50.36028 |
| 27 | EPERVA 61 (IND)                |  40.20000 |
| 87 | EPERVA 64 (IND)                |  39.83778 |
| 35 | ANGAMOS 2 (IND)                |  39.26917 |
| 26 | ICALMA (IND)                   |  36.19861 |
| 50 | TORNADO (IND)                  |  34.21556 |
| 32 | CAMIÑA (IND)                   |  25.55056 |
| 85 | EPERVA 62 (IND)                |  22.57556 |

``` r
##### 2.) PISAGUA
Vessels_Clip_Pisagua_Published <- read.csv ("/Users/Esteban/Documents/Jobs/GFW/Proyectos/Chile/Chile_Oceana/Final_Report/Tables/FullData/Vessels_Clip_Pisagua_Published.csv", header = TRUE)

#Aggregate by vessel, adding fishing hours
Pisagua_FH_Published <- data.frame(aggregate(hours ~ n_shipname + vessel_id, Vessels_Clip_Pisagua_Published, sum))
#Add associated vessel name
Pisagua_FH_Published$Embarcacion <- UniqueVessNames$shipname[match(Pisagua_FH_Published$n_shipname, UniqueVessNames$n_shipname)]
Pisagua_FH_Published$Horas <- Pisagua_FH_Published$hours
#Removing ID rows
Pisagua_FH_Published <- Pisagua_FH_Published[-c(1:3)]
#Order from highest to lowest hours
Pisagua_FH_Published <- Pisagua_FH_Published[with(Pisagua_FH_Published, order(-Horas)),]

#Export final list of vessels and associated hours within
#Pisagua region

#write.csv(Pisagua_FH_Published, file = "Pisagua_Horas_de_Pesca_Published.csv")
```

**Pisagua**

Horas de Pesca

|    | Embarcacion                    |      Horas |
| -- | :----------------------------- | ---------: |
| 6  | HURACAN (IND)                  | 85.9561111 |
| 18 | EPERVA 56 (IND)                | 85.4858333 |
| 69 | EPERVA 66 (IND)                | 82.4738881 |
| 44 | TORNADO (IND)                  | 75.3194454 |
| 51 | ICALMA (IND)                   | 72.7727776 |
| 41 | EPERVA 65 (IND)                | 64.5277792 |
| 22 | ANGAMOS 2 (IND)                | 62.8433333 |
| 71 | EPERVA 62 (IND)                | 58.9744482 |
| 30 | BARRACUDA IV (IND)             | 58.5697223 |
| 9  | ATACAMA IV (IND)               | 58.0000000 |
| 64 | LOA 7 (IND)                    | 57.1183354 |
| 68 | CORPESCA 2 (IND)               | 55.2022234 |
| 7  | ANGAMOS 3 (IND)                | 53.7522222 |
| 78 | ATACAMA V (IND)                | 53.5833334 |
| 72 | EPERVA 61 (IND)                | 52.7005562 |
| 29 | AVENTURERO (IND)               | 51.5080541 |
| 12 | DON ERNESTO AYALA MARFIL (IND) | 51.1550000 |
| 33 | CLAUDIA ALEJANDRA (IND)        | 50.1333319 |
| 62 | ALBIMER (IND)                  | 48.8000008 |
| 67 | ANGAMOS 1 (IND)                | 48.2933345 |
| 5  | ANGAMOS 9 (IND)                | 47.7522222 |
| 10 | INTREPIDO (IND)                | 46.5516667 |
| 86 | PUCARA (IND)                   | 46.2308352 |
| 39 | MERO (IND)                     | 45.8386116 |
| 81 | AUDAZ (IND)                    | 44.9827782 |
| 70 | EPERVA 64 (IND)                | 43.1774993 |
| 65 | BLANQUILLO (IND)               | 42.7336122 |
| 35 | ANGAMOS 4 (IND)                | 42.6897225 |
| 85 | LOA 1 (IND)                    | 41.7666661 |
| 42 | PARINA I (IND)                 | 41.7438879 |
| 4  | TRUENO I (IND)                 | 41.5502778 |
| 8  | COSTA GRANDE 1 (IND)           | 39.9333333 |
| 27 | SALMON (IND)                   | 39.7827760 |
| 34 | LICANTEN (IND)                 | 36.9830556 |
| 47 | COLLEN (IND)                   | 34.3333322 |
| 60 | RELAMPAGO (IND)                | 34.3097228 |
| 46 | EPERVA 49 (IND)                | 33.5333330 |
| 77 | BANDURRIA (IND)                | 32.3388894 |
| 1  | LOA 2 (IND)                    | 31.3333333 |
| 63 | DON GINO (IND)                 | 30.5036108 |
| 50 | LOA 1 (IND)                    | 28.9166682 |
| 43 | EPERVA 51 (IND)                | 22.3799996 |
| 57 | SAN JORGE I (IND)              | 21.2666666 |
| 28 | MARLIN (IND)                   | 18.5369449 |
| 76 | ALBIMER (IND)                  | 18.5333336 |
| 14 | EPERVA 56 (IND)                | 17.5405556 |
| 26 | EPERVA 66 (IND)                | 16.8641663 |
| 58 | ALERCE (IND)                   | 16.5333343 |
| 53 | HALCON (IND)                   | 15.5947227 |
| 61 | ATACAMA IV (IND)               | 14.2666674 |
| 49 | ATACAMA V (IND)                | 12.5999997 |
| 40 | INTREPIDO (IND)                | 11.8077782 |
| 75 | CLAUDIA ALEJANDRA (IND)        | 11.5999999 |
| 21 | RELAMPAGO (IND)                |  9.9794444 |
| 52 | COSTA GRANDE 1 (IND)           |  8.4666670 |
| 15 | COLLEN (IND)                   |  7.8333333 |
| 19 | LICANTEN (IND)                 |  7.6500000 |
| 37 | LOA 2 (IND)                    |  6.8166669 |
| 36 | BARRACUDA IV (IND)             |  6.7863896 |
| 55 | LOA 7 (IND)                    |  6.7499999 |
| 83 | EPERVA 65 (IND)                |  5.9588883 |
| 25 | AUDAZ (IND)                    |  5.4438897 |
| 3  | MERO (IND)                     |  5.2988889 |
| 11 | CORPESCA 2 (IND)               |  5.0908333 |
| 17 | SAN JORGE I (IND)              |  4.0550000 |
| 45 | TORNADO (IND)                  |  3.2166669 |
| 31 | ANGAMOS 2 (IND)                |  3.1222225 |
| 66 | DON ERNESTO AYALA MARFIL (IND) |  2.9930557 |
| 73 | HURACAN (IND)                  |  2.5952782 |
| 59 | SAN JORGE I (IND)              |  2.5102774 |
| 23 | ICALMA (IND)                   |  2.4999997 |
| 79 | EPERVA 51 (IND)                |  2.4719447 |
| 38 | ANGAMOS 4 (IND)                |  2.3877782 |
| 48 | HALCON (IND)                   |  2.3283331 |
| 16 | ANGAMOS 3 (IND)                |  2.2608333 |
| 80 | EPERVA 62 (IND)                |  2.2372224 |
| 82 | EPERVA 64 (IND)                |  2.1166670 |
| 74 | BLANQUILLO (IND)               |  2.0327781 |
| 54 | EPERVA 49 (IND)                |  1.8666670 |
| 13 | PARINA I (IND)                 |  1.7500000 |
| 24 | EPERVA 61 (IND)                |  1.7461114 |
| 20 | TRUENO I (IND)                 |  1.6000000 |
| 32 | PUCARA (IND)                   |  1.2511111 |
| 56 | BANDURRIA (IND)                |  0.6666667 |
| 2  | CAMIÑA (IND)                   |  0.5572222 |
| 84 | DON GINO (IND)                 |  0.5333333 |

**Ventana 5**

No hay ninguna embarcación dentro de la ventana 5

**Ventana 6**

No hay ninguna embarcación dentro de la ventana 6

**Ventana 7**

No hay ninguna embarcación dentro de la ventana 7

Agrupar los datos por décimas de grados Lat y Lon, sumar horas totales
de actividad y horas de pesca También se bajan los archivos JSON con los
polígonos de interes que irán en los mapas

``` r
#Graphing Fishing Effort Hours for the "Tarapaca_Fishing_Published" DB
#by grouping hours into lat and lon hundreth bins
Vessels_Clip_Tarapaca_Published$LatBin <- (floor(Vessels_Clip_Tarapaca_Published$lat_mean * 100)/100)
Vessels_Clip_Tarapaca_Published$LonBin <- (floor(Vessels_Clip_Tarapaca_Published$lon_mean * 100)/100)

#Fishing hours Graph
FishingHoursGraph_Published <- data.frame(aggregate(hours ~ LatBin + LonBin, Vessels_Clip_Tarapaca_Published, sum))
#Se quitan 36 lineas (outliers) de valores > 20 (.53% de los datos) para que el mapa 
#muestre resultados útiles
FishingHoursGraph_Published <- FishingHoursGraph_Published[which(FishingHoursGraph_Published$hours < 20),]

#write.csv(FishingHoursGraph_Published, file = "FishingHoursGraph_Published.csv")

###Mapa
#Bajar los archivos JSON con los polígonos de interés
#Pisagua
Pisagua_ST <- st_read("/Users/Esteban/Documents/Jobs/GFW/Proyectos/Chile/Chile_Oceana/Data/Shapes/Pisagua.geojson")
#Tarapacá
Tarapaca_ST <- st_read("/Users/Esteban/Documents/Jobs/GFW/Proyectos/Chile/Chile_Oceana/Data/Shapes/TarapacaPoly.geojson")
#Ventana 5
Ventana5_ST <- st_read("/Users/Esteban/Documents/Jobs/GFW/Proyectos/Chile/Chile_Oceana/Data/Shapes/VP5gj.geojson")
#Ventana 6
Ventana6_ST <- st_read("/Users/Esteban/Documents/Jobs/GFW/Proyectos/Chile/Chile_Oceana/Data/Shapes/VP6gj.geojson")
#Ventana 7
Ventana7_ST <- st_read("/Users/Esteban/Documents/Jobs/GFW/Proyectos/Chile/Chile_Oceana/Data/Shapes/VP7intersectgj.geojson")
```

Generar el mapa de esfuerzo pesquero por horas de pesca de acuerdo a
décimas de grados Lat y Lon

``` r
# GFW logo
gfw_logo <- png::readPNG("/Users/Esteban/Documents/Jobs/GFW/General/Logo/GFW_logo_primary_White.png")
gfw_logo_rast <- grid::rasterGrob(gfw_logo, interpolate = T)

#Map
land_sf <- rnaturalearth::ne_countries(scale = 10, returnclass = 'sf')
MapTest_Published <- ggplot() + 
  geom_sf(data = land_sf,
            fill = fishwatchr::gfw_palettes$map_country_dark[1],
            color = fishwatchr::gfw_palettes$map_country_dark[2],
          size=.1) +
    scale_fill_gradientn(colours = fishwatchr::gfw_palettes$map_effort_dark)+
  fishwatchr::theme_gfw_map(theme = 'dark')+
  geom_tile(data = FishingHoursGraph_Published, aes(x = LonBin, y = LatBin, fill = hours), alpha = 0.5)+
  labs(fill = "Horas", title = "Horas de Pesca por Área en Datos Publicados de GFW")+
  geom_sf(data=Tarapaca_ST,fill=NA, color="#CC3A8E")+geom_sf(data=Pisagua_ST, fill=NA, color="#00C1E7")+
  geom_sf(data=Ventana5_ST, fill=NA, color="#99C945")+geom_sf(data=Ventana6_ST, fill=NA, color="#DAA51B")+
  geom_sf(data=Ventana7_ST, fill=NA, color="#58E8C6")+
  coord_sf(xlim = c(-74, -69.8), ylim = c(-22, -18.6))+
  #Add GFW logo
  annotation_custom(gfw_logo_rast,
                      ymin = -21.95,
                      ymax = -21.53,
                      xmin = -73.8,
                      xmax = -72.6)
MapTest_Published
```

![](Report_Published_files/figure-gfm/unnamed-chunk-11-1.png)<!-- -->

El mismo mapa de arriba pero enfocado en Pisagua

``` r
#Zoomed in Pisagua fishing hours map
MapTest2_Published <- MapTest_Published + coord_sf(xlim = c(-70.5, -70.1), ylim = c(-19.87, -19.3))+
    #Add GFW logo
  annotation_custom(gfw_logo_rast,
                      ymin = -19.35,
                      ymax = -19.3,
                      xmin = -70.2,
                      xmax = -70.1)
```

    ## Coordinate system already present. Adding new coordinate system, which will replace the existing one.

``` r
MapTest2_Published
```

![](Report_Published_files/figure-gfm/unnamed-chunk-12-1.png)<!-- -->
