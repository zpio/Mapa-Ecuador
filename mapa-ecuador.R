library(tidyverse)
library(jsonlite)
library(httr)

# En formato lista
mapa.ec <- 
  httr::GET("https://raw.githubusercontent.com/zpio/mapa-ecuador/main/ec-all.geo.json") %>% 
  httr::content(type = 'text') %>% 
  jsonlite::fromJSON(simplifyVector = FALSE)

# En formato data frame
mapa_ec <- 
  jsonlite::fromJSON("https://raw.githubusercontent.com/zpio/mapa-ecuador/main/ec-all.geo.json") %>% 
  as.data.frame()

provincias <- 
  data.frame(name= mapa_ec$features.properties$name,
             lon = mapa_ec$features.properties$longitude,
             lat = mapa_ec$features.properties$latitude) %>% 
  filter(name != is.na(name)) %>% 
  mutate(across(everything(), as.character)) %>% 
  mutate(across(c(lon, lat), as.numeric))

# Poblacion Ecuador por provincia 2020
pop_prov <- 
  read_csv('https://raw.githubusercontent.com/zpio/mapa-ecuador/main/pop_prov2020.csv')


# Grafica mapa Ecuador de la poblacion con degradado por cantidad
highchart() %>% 
  hc_add_series_map(map = mapa.ec,
                    df = pop_prov, 
                    name= 'Población',
                    value = "Poblacion2020",
                    joinBy = c("name", "Provincia"),
                    dataLabels = list(enabled = TRUE, 
                                      format = '{point.name}'),
                    states = list(hover = list(color='#04635b'))
  ) %>% 
  hc_mapNavigation(enabled = TRUE) %>% 
  hc_add_theme(hc_theme_smpl()) %>% 
  hc_colorAxis(minColor = "#5ad1c7", maxColor = "#434348") %>% 
  hc_title(text = "Mapa Poblacional del Ecuador") %>%
  hc_subtitle(text = "Source: zpio.com") %>% 
  hc_legend(layout= 'vertical',
            align= 'right',
            verticalAlign= 'bottom')
  

# Provinicias Ecuador y sus coordenadas

prov_lat_lon <- provincias %>% 
  left_join(pop_prov, by = c('name'='Provincia')) %>% 
  rename(z = Poblacion2020)


# Grafica Mapa Ecuador agregando 'bubble' de un solo color

highchart(type = "map") %>%
  hc_add_series(mapData = mapa.ec, showInLegend = FALSE) %>% 
  hc_add_series(
    data = prov_lat_lon, 
    type = "mapbubble",
    name = "Poblacion", 
    minSize = "1%",
    maxSize = "10%",
    color = 'red'
  )
  
# Grafica Mapa Ecuador agregando 'bubble' con degradado por cantidad

highchart(type = "map") %>%
  hc_add_series(mapData = mapa.ec, showInLegend = FALSE) %>% 
  hc_add_series(
    data = prov_lat_lon, 
    type = "mapbubble",
    name = "Poblacion", 
    minSize = "1%",
    maxSize = "10%"
  ) %>% 
  hc_mapNavigation(enabled = TRUE) %>% 
  hc_add_theme(hc_theme_smpl()) %>% 
  hc_colorAxis(minColor = "#5ad1c7", maxColor = "#434348") %>% 
  hc_title(text = "Mapa Poblacional del Ecuador") %>%
  hc_subtitle(text = "Source: zpio.com") %>% 
  hc_legend(layout= 'vertical',
            align= 'right',
            verticalAlign= 'bottom')























