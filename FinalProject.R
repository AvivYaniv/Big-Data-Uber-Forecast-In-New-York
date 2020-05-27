# Import Section
library(plyr)
library(dplyr)
library(geosphere)
library(lubridate)

#+++++++++++++++++++++++++++ Clear Cache +++++++++++++++++++++++++++++
rm(list = ls())

#~~~~~~~~~~~~~~~~~~~~~~~ Constants Definition ~~~~~~~~~~~~~~~~~~~~~~~
#-------------------- Working Directory Section ---------------------
WORKING_DIRECTORY_PATH <- "C:/R/FinalProject/Aviv_Yaniv/"
lockBinding("WORKING_DIRECTORY_PATH", globalenv())

#------------------------- Flags Section ----------------------------
INSTALL_NECCESARY_PACKAGES      <- FALSE
lockBinding("INSTALL_NECCESARY_PACKAGES", globalenv())

DEBUG                           <- TRUE
lockBinding("DEBUG", globalenv())

DEBUG_PRINT                      <- TRUE
lockBinding("DEBUG_PRINT", globalenv())

SAVE_FILTERED_AND_TEST_TABELS    <- FALSE
lockBinding("SAVE_FILTERED_AND_TEST_TABELS", globalenv())

#------------------------ Export Section ----------------------------

CREATE_HEAT_MAPS <- FALSE
lockBinding("CREATE_HEAT_MAPS", globalenv())

DATA_EXPLORE_CLIMATE <- FALSE
lockBinding("DATA_EXPLORE_CLIMATE", globalenv())

DATA_EXPLORE_PICK_NUM_DISTRIBUTION <- FALSE
lockBinding("DATA_EXPLORE_PICK_NUM_DISTRIBUTION", globalenv())

DATA_EXPLORE_PICK_NUM_EACH_DAY_AND_HOUR <- FALSE
lockBinding("DATA_EXPLORE_PICK_NUM_EACH_DAY_AND_HOUR", globalenv())

CREATE_K_MEANS_MAPS <- FALSE
lockBinding("CREATE_K_MEANS_MAPS", globalenv())

CREATE_MONTHES_CLUSTERS_MAPS <- FALSE
lockBinding("CREATE_MONTHES_CLUSTERS_MAPS", globalenv())

CREATE_PICKNUM_CLUSTERS_DISTRIBUTIONS <- FALSE
lockBinding("CREATE_PICKNUM_CLUSTERS_DISTRIBUTIONS", globalenv())

#------------------- Model Configuration ----------------------------
CLUSTERS_NUMBER <- 8
lockBinding("CLUSTERS_NUMBER", globalenv())

CUTOFF_CLUSTER_ANOMALY_THRESHOLD <- TRUE
lockBinding("CUTOFF_CLUSTER_ANOMALY_THRESHOLD", globalenv())

if (CUTOFF_CLUSTER_ANOMALY_THRESHOLD)
{
  TIME_WINDOW_CLUSTER_ANOMALY_THRESHOLD <- 9
  lockBinding("TIME_WINDOW_CLUSTER_ANOMALY_THRESHOLD", globalenv())
}

CUTOFF_GLOBAL_ANOMALY_TRSHOLD <- FALSE
lockBinding("CUTOFF_CLUSTER_ANOMALY_THRESHOLD", globalenv())

if (CUTOFF_GLOBAL_ANOMALY_TRSHOLD)
{
  GLOBAL_ANOMALY_TRSHOLD              <- 15
  lockBinding("GLOBAL_ANOMALY_TRSHOLD", globalenv())
}

#------------------------- Messages Section -------------------------
FILTER_TABLE_MESSAGE <- "Filtering table:"
lockBinding("FILTER_TABLE_MESSAGE", globalenv())

HEATMAP_CLUSTER_MONTH_MESSAGE <- "Heatmap cluster for month:"
lockBinding("HEATMAP_CLUSTER_MONTH_MESSAGE", globalenv())

PICKNUM_DISTIBUTION_MEAN_VALUE_MESSAGE <- " is the mean value of picknum for "
lockBinding("PICKNUM_DISTIBUTION_MEAN_VALUE_MESSAGE", globalenv())

#--------------- General Constants Definition -----------------------
MONTH_START_NUMBER <- 4
lockBinding("MONTH_START_NUMBER", globalenv())

MONTH_VALIDATION_NUMBER <- 5
lockBinding("MONTH_VALIDATION_NUMBER", globalenv())

TIME_WINDOW_IN_MINUTES <- 15
lockBinding("TIME_WINDOW_IN_MINUTES", globalenv())

TIME_WINDOW <- "15 minutes"
lockBinding("TIME_WINDOW", globalenv())

TIME_ZONE <- "America/New_York"
lockBinding("TIME_ZONE", globalenv())

TIME_FORMAT <- "%m/%d/%Y %H:%M:%S"
lockBinding("TIME_FORMAT", globalenv())

NEW_YORK_STOCK_EXCHANGE_CIRCLE_RADIUS <- 1000
lockBinding("NEW_YORK_STOCK_EXCHANGE_CIRCLE_RADIUS", globalenv())

NEW_YORK_STOCK_EXCHANGE_COORDINATIONS <- c(-74.011322, 40.706913)
lockBinding("NEW_YORK_STOCK_EXCHANGE_COORDINATIONS", globalenv())

NEW_YORK_SQUARE_COORDINATES <- c(-74.043415, 40.698151, -73.967981, 40.725938)
lockBinding("NEW_YORK_SQUARE_COORDINATES", globalenv())

DAY_SEPERATOR <- "_day_"
lockBinding("DAY_SEPERATOR", globalenv())

MONTH_SEPERATOR <- "_month_"
lockBinding("MONTH_SEPERATOR", globalenv())

CLUSTERS_SEPERATOR <- "_clusters_of"
lockBinding("CLUSTERS_SEPERATOR", globalenv())

DEFAULT_IMAGE_EXTENSION <- ".png"
lockBinding("DEFAULT_IMAGE_EXTENSION", globalenv())

GRAPH_DISTRIBUTION_IMAGE_NAME <- "graph_distribution"
lockBinding("GRAPH_DISTRIBUTION_IMAGE_NAME", globalenv())

GRAPH_DISTRIBUTION_IMAGE_EXTENSION <- DEFAULT_IMAGE_EXTENSION
lockBinding("GRAPH_DISTRIBUTION_IMAGE_EXTENSION", globalenv())

COLOR_DISTRIBUTION_IMAGE_NAME <- "color_distribution"
lockBinding("COLOR_DISTRIBUTION_IMAGE_NAME", globalenv())

COLOR_DISTRIBUTION_IMAGE_EXTENSION <- DEFAULT_IMAGE_EXTENSION
lockBinding("COLOR_DISTRIBUTION_IMAGE_EXTENSION", globalenv())

MAPS_FILE_NAME <- "18.maps"
lockBinding("MAPS_FILE_NAME", globalenv())

HEATMAP_PLOT_FILE_NAME <- "heatmap_plot"
lockBinding("HEATMAP_PLOT_FILE_NAME", globalenv())

HEATMAP_PLOT_FILE_EXTENSION <- ".RData"
lockBinding("HEATMAP_PLOT_FILE_EXTENSION", globalenv())

HEATMAP_PLOT_IMAGE_NAME <- "heatmap"
lockBinding("HEATMAP_PLOT_IMAGE_NAME", globalenv())

HEATMAP_PLOT_IMAGE_EXTENSION <- DEFAULT_IMAGE_EXTENSION
lockBinding("HEATMAP_PLOT_IMAGE_EXTENSION", globalenv())

SEED <- 1337
lockBinding("SEED", globalenv())

K_MEANS_MODELS_NUMBER <- 100
lockBinding("K_MEANS_MODELS_NUMBER", globalenv())

KMEANS_MAX_ITER <- 1000
lockBinding("KMEANS_MAX_ITER", globalenv())

#+++++++++++++++++++++++++++ Initialization +++++++++++++++++++++++++
getwd()
setwd(WORKING_DIRECTORY_PATH)
getwd()

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#+++++++++++++++++++ Functions Definition Section +++++++++++++++++++
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#------------------------ Table Functions Section -------------------

join_tables <- function(list_of_tables)
{
  joined_table            <- data.frame(list_of_tables[[1]])
  
  for (i in 2:length(list_of_tables))
  {
    joined_table <- full_join(joined_table, data.frame(list_of_tables[[i]])) 
  }
  
  return(joined_table)
}

#------------------------ Location Functions Section ----------------

filter_by_distance_from_point <- function(data_to_filter, coordinates_center, circle_radius)
{
  # Copying data, to avoid corruption
  data_to_filter_copy = data_to_filter[,]
  
  # Conversion to numeric values
  data_to_filter_copy$Lat = as.numeric(data_to_filter_copy$Lat)
  data_to_filter_copy$Lon = as.numeric(data_to_filter_copy$Lon)
  
  # Making sure order is (longtitude, latitude) for later distance measuring
  data_coordinates <- data.matrix(data_to_filter_copy[c("Lon", "Lat")])
  
  # Calculating distance of data rows from center
  data_to_filter_copy$distance <- distm(data_coordinates, coordinates_center, fun = distHaversine)
  
  # Filtering data if inside circle
  data_filtered_circle <- data.frame(data_to_filter_copy[data_to_filter_copy$distance <= circle_radius,])
  
  return(data_filtered_circle)
}

#------------------------ Time Functions Section --------------------

round_to_time_window <- function(d, window)
{
  rounded_to_time_window <- lubridate::floor_date(d, window)
  return(rounded_to_time_window)
}

string_to_date <- function(s, time_format = TIME_FORMAT)
{
  return(as.POSIXct(s, format = time_format, tz = TIME_ZONE))
}

library(chron)

add_time_columns <- function(raw_data, column_name = "Time_Interval")
{
  datetime                <- raw_data[,column_name]
  raw_data$minute         <- minute(datetime)
  raw_data$hour           <- hour(datetime)
  raw_data$day            <- day(datetime)
  raw_data$day_in_week    <- wday(datetime)
  raw_data$day_in_year    <- yday(datetime)
  raw_data$is_weekend     <- is.weekend(datetime)
  raw_data$month          <- month(datetime)
  return(raw_data)
}

filter_time_between_hours <- function(raw_data, start_hour = 17, end_hour = 23)
{
  hours_filtered_data <- 
    data.frame(raw_data[(raw_data$hour >= start_hour & raw_data$hour <= end_hour),])
  
  return(hours_filtered_data)
}

#-------------------- Aggregate Sums Functions Section --------------

aggregate_count_by_minutes <- function(raw_data, minutes = TIME_WINDOW_IN_MINUTES)
{
  pick_time_datetime      <- string_to_date(raw_data$Date.Time)
  pick_time_offset        <- as.numeric(pick_time_datetime) %% (60*minutes)
  pick_time_interval      <- pick_time_datetime - pick_time_offset
  test_data               <- as.data.frame(table(pick_time_interval))
  colnames(test_data)     <- c("Time_Interval", "pick_num")
  test_data$Time_Interval <- as.POSIXct(test_data$Time_Interval, format = "%Y-%m-%d %H:%M:%S", tz = TIME_ZONE)
  return(test_data)
}

#------------------------- Filter Functions Section -----------------
filter_data <- function(data)
{
  # Add time columns
  data$datetime                       <- string_to_date(data$Date.Time)
  data  				                      <- add_time_columns(data, column_name = "datetime")
  
  # Filter time between hours
  filtered_data 				              <- filter_time_between_hours(data)
  
  # Filter cirlce				
  filtered_circle_data                <- filter_by_distance_from_point(
    filtered_data, 
    NEW_YORK_STOCK_EXCHANGE_COORDINATIONS,
    NEW_YORK_STOCK_EXCHANGE_CIRCLE_RADIUS)
  
  return(filtered_circle_data)
}

filter_data_list <- function(data_list)
{
  filtered_list <- list(dim = length(data_list))
  
  for (i in seq_along(data_list))
  {
    if (DEBUG_PRINT)
    {
      print(paste(FILTER_TABLE_MESSAGE, i)) 
    }
    
    filtered_list[[i]]  <- filter_data(data.frame(data_list[i]))
  }
  
  return (filtered_list)
}

#---------------------- Test Format Functions Section ---------------
convert_to_test_format <- function(data, minutes = TIME_WINDOW_IN_MINUTES)
{
  return(aggregate_count_by_minutes(data, minutes))
}

convert_list_to_test_format <- function(data_list, minutes = TIME_WINDOW_IN_MINUTES)
{
  data_list_test_format <- list(dim = length(data_list))
  
  for (i in seq_along(data_list))
  {
    data_list_test_format[[i]] = aggregate_count_by_minutes(data.frame(data_list[[i]]), minutes)
  }
  
  return(data_list_test_format)
}

#----------------------- External Data Functions Section ------------

join_external_with_test <- function(test_jata, external_data, external_date_format, resolution)
{
  # Creating common column (to test format tables) for later joining of tables
  common_column_name = paste("date_in_", resolution, "_resolution", sep = "")
  external_data[common_column_name] <- 
    round_to_time_window(string_to_date(external_data$Date.Time, external_date_format), resolution)
  test_jata[common_column_name] <- 
    round_to_time_window(test_jata$Time_Interval, resolution)
  
  # Joining external & test tables
  joined_table <- left_join(test_jata, external_data, by = common_column_name)
  
  # Removing Date.Time colum from joined table
  # it's common name that will spam the joined table
  joined_table <- joined_table[, names(joined_table) != "Date.Time" ]
  
  # Removing common column from joined table
  joined_table <- joined_table[, names(joined_table) != common_column_name ]
  
  return(joined_table)
}

#-------------------- Monthes Functions Section ---------------------
month_index_to_number <- function(i, month_start_number = MONTH_START_NUMBER)
{
  return(month_start_number + i - 1)
}

month_index_to_identifier <- function(i, month_start_number = MONTH_START_NUMBER)
{
  return(paste(MONTH_SEPERATOR, month_index_to_number(i, month_start_number), sep = ""))
}

create_monthes_count_table <- function(monthes_list, month_start_number = MONTH_START_NUMBER)
{
  monthes_list_length <- length(monthes_list)
  month_end_number    <- monthes_list_length + month_start_number - 1
  
  monthes_count_table <- data.frame(month_number=numeric(),
                                    month_count=numeric())
  
  for (i in seq_along(monthes_list))
  {
    monthes_count_table[i, "month_number"]  <- month_index_to_number(i)
    monthes_count_table[i, "month_count"]   <- sapply(monthes_list[i], NROW)
  }
  
  return(monthes_count_table)
}

#-------------------- Distribution Plots Functions ------------------

plot_picknum_graph_distribution <- function(data, print_mean_value = TRUE, file_name_suffix = "")
{
  graph_distribution_plot <- ggplot(data, aes(x = pick_num)) + 
    geom_density(aes(y = ..count..), fill = "lightgray") +
    scale_x_continuous('pick_num', 
                       labels = as.character(data$pick_num), 
                       breaks = data$pick_num) + 
    geom_vline(aes(xintercept = mean(pick_num)), 
               linetype = "dashed", size = 0.6,
               color = "#FC4E07")
  
  graph_distribution_plot_image_name <- paste(GRAPH_DISTRIBUTION_IMAGE_NAME, file_name_suffix, GRAPH_DISTRIBUTION_IMAGE_EXTENSION, sep = "")
  ggplot2::ggsave(filename=graph_distribution_plot_image_name, scale=3, plot=graph_distribution_plot, limitsize=FALSE, width=5, height=5, dpi="retina", units = "in")	  
  
  if (print_mean_value)
  {
    print(paste(mean(data$pick_num), PICKNUM_DISTIBUTION_MEAN_VALUE_MESSAGE, file_name_suffix))
  }
}

plot_picknum_for_hours_in_each_day_distribution <- function(data, file_name_suffix = "")
{
  color_distribution_plot <- ggplot(data) + 
    geom_tile(aes(y = day_in_week, x = hour, fill = pick_num)) +
    scale_x_continuous(breaks = seq(min(data$hour), 
                                    max(data$hour),
                                    by = 1))+ 
    scale_y_continuous(breaks = seq(min(data$day_in_week), 
                                    max(data$day_in_week),
                                    by = 1))+ 
    scale_fill_distiller(palette = "Spectral", 
                         limits = 
                           c(
                             min(data$pick_num), 
                             max(data$pick_num)))
  
  color_distribution_plot_image_name <- paste(COLOR_DISTRIBUTION_IMAGE_NAME, file_name_suffix, COLOR_DISTRIBUTION_IMAGE_EXTENSION, sep = "")
  ggplot2::ggsave(filename=color_distribution_plot_image_name, scale=3, plot=color_distribution_plot, limitsize=FALSE, width=5, height=5, dpi="retina", units = "in")	    
}

#------------------------ Heat Map Functions Section ----------------
if (INSTALL_NECCESARY_PACKAGES)
{
  install.packages("ggmap")
  install.packages("ggplot2")
  install.packages("ggthemes")
}
library(ggmap)
library(ggplot2)
library(ggthemes)

get_location_map <- function(location_vec = NEW_YORK_SQUARE_COORDINATES, read_from_file = TRUE)
{
  maps_file 	<- MAPS_FILE_NAME
  
  if (read_from_file)
  {
    area_map		<- readRDS(maps_file)
  }
  else
  {
    #Get the map from stamen
    area_map		<- get_stamenmap(source="stamen", bbox = location_vec, maptype='terrain', crop = TRUE, zoom = 18)	
    
    # Save map to file, for later caching
    saveRDS(area_map, file = maps_file)
  }
  
  return (area_map)
}

create_heatmap <- function(data_map, area_map, locations = NULL, file_name_suffix = "", cache_plot = FALSE)
{
  positions <- data_map[c("Lon", "Lat")]
  
  heatmap_plot <- ggmap(area_map, extent = "device") +
    geom_density2d(data = positions, aes(x = Lon, y = Lat), size = 0.3) + 
    stat_density2d(data = positions, 
                   aes(x = Lon, y = Lat, fill = ..level.., alpha = ..level..), size = 0.001, 
                   bins = 20, geom = "polygon") + scale_fill_gradient(low = "green", high = "red") + 
    scale_alpha(range = c(0, 0.9), guide = FALSE)
  
  if (!is.null(locations))
  {
    heatmap_plot <- heatmap_plot + 
      geom_point(data = locations, aes(x = lon, y = lat), color = 'red', size = 3)
  }
  
  if (cache_plot)
  {
    heatmap_plot_full_file_name  <- paste(HEATMAP_PLOT_FILE_NAME, file_name_suffix, HEATMAP_PLOT_FILE_EXTENSION, sep = "")
    save(heatmap_plot, file = heatmap_plot_full_file_name)  
  }
  
  heatmap_plot_full_image_name <- paste(HEATMAP_PLOT_IMAGE_NAME, file_name_suffix, HEATMAP_PLOT_IMAGE_EXTENSION, sep = "")
  map2disk <- ggplot2::ggsave(filename=heatmap_plot_full_image_name, plot=heatmap_plot, limitsize=FALSE, width=30, height=16, dpi="retina", units = "in")
}

#------------------------ Clusters Functions Section ----------------

extract_from_array <- function(arr, field_name)
{
  len           <- nrow(arr[1])
  arr_extracted <- array(dim = len)
  
  for (i in 1:len)
  {
    arr_extracted[i] <- arr[i, field_name]
  }
  
  return(arr_extracted)
}

extract_coordinates_from_data <- function(data)
{
  return(matrix(c(data$Lon, data$Lat), ncol = 2))
}

# Seperated to another function, 
# to make sure (seed, max-iterations) remains the same
calculate_kmeans_model <- function(data, k, is_raw_data = TRUE)
{
  set.seed(SEED)
  
  if (is_raw_data)
  {
    data                  <- extract_coordinates_from_data(data)
  }
  
  KMC                     <- kmeans(data, centers = k, iter.max = KMEANS_MAX_ITER)
  return (KMC)
}

caclulate_kmeans_models <- function(data, start = 1, end = K_MEANS_MODELS_NUMBER)
{
  # Variable Definition
  arr         <- data.frame(k=integer(),
                            tot.withinss=numeric(),
                            betweenss=numeric(),
                            totss=numeric(),
                            rsquared=numeric())
  
  # Code Section
  data_coordinates <- extract_coordinates_from_data(data)
  
  for (k in start:end)
  {
    i                       <- k - start + 1
    
    KMC                     <- calculate_kmeans_model(data_coordinates, k, FALSE)
    
    arr[i,("k")] 			      <- k
    arr[i,("tot.withinss")]	<- KMC$tot.withinss
    arr[i,("betweenss")] 	  <- KMC$betweenss
    arr[i,("totss")] 		    <- KMC$totss
    arr[i,("rsquared")] 	  <- round(KMC$betweenss/KMC$totss, 3)
  }
  
  return(arr)
}

plot_clusters_total_within_clusters_sum_of_squares <- function(kmeans_models, start = 1, end = K_MEANS_MODELS_NUMBER)
{
  arr_twcss <- extract_from_array(kmeans_models, "tot.withinss")
  
  twcss_graph <- ggplot()    + aes(x = start:end, y = arr_twcss)
  twcss_graph <- twcss_graph + geom_point() + geom_line()
  twcss_graph <- twcss_graph + scale_x_continuous(breaks = start:end)
  twcss_graph <- twcss_graph + scale_y_continuous(labels = scales::comma)
  twcss_graph <- twcss_graph + xlab("k (Number of Clusters)")
  twcss_graph <- twcss_graph + ylab("Total Within clusters Sum of Squares")
  twcss_graph
}

convert_centers_to_locations <- function(centers)
{
  locations <- 
    tibble(
      lon = double(),
      lat = double())
  
  len = nrow(centers)
  
  for (i in 1:len)
  {
    locations[i, "lon"] = centers[i, 1]
    locations[i, "lat"] = centers[i, 2]
  }
  
  return(locations)
}

create_cluster_heatmap <- function(data, area_map, k, heamap_name_suffix = "_cluster")
{
  # Code Section
  set.seed(SEED)
  
  data_coordinates <- matrix(c(data$Lon, data$Lat), ncol = 2)
  
  KMC                     <- kmeans(data_coordinates, centers = k, iter.max = KMEANS_MAX_ITER)
  
  centers                 <- KMC$centers
  locations               <- convert_centers_to_locations(centers)
  
  create_heatmap(data, area_map, locations = locations, file_name_suffix = paste("_", k, heamap_name_suffix, sep = ""))
}

create_kmeans_heatmaps <- function(data, area_map, start = 1, end = K_MEANS_MODELS_NUMBER)
{
  for (k in start:end)
  {
    create_cluster_heatmap(data, area_map, k)
  }
}

#------------------- Evaluation Functions Section -------------------
r_squared <- function(expected, actual)
{
  rss <- sum((expected - actual) ^ 2)
  tss <- sum((actual - mean(actual)) ^ 2)
  rsq <- 1.0 - rss/tss
  return(rsq)
}

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#++++++++++++++++++++++++++++ Code Section ++++++++++++++++++++++++++
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
########################## Section: Step 1 ##########################
# Read raw train data
raw_data_month_4              				    <- read.csv("uber_train/uber-raw-data-apr14.csv")
raw_data_month_5              				    <- read.csv("uber_train/uber-raw-data-may14.csv")
raw_data_month_6              				    <- read.csv("uber_train/uber-raw-data-jun14.csv")
raw_data_month_7              				    <- read.csv("uber_train/uber-raw-data-jul14.csv")

# Setting raw data in list
raw_train_data_tables_list    				    <- list(
  raw_data_month_4, 
  raw_data_month_5, 
  raw_data_month_6, 
  raw_data_month_7)

# Filter raw data
train_data_tables_list_filtered           <- filter_data_list(raw_train_data_tables_list)

# Join train data
train_data_tables_filtered_joined         <- join_tables(train_data_tables_list_filtered)

# Convert each filterd trained data item to test format, for later analyzing
train_data_at_test_format_list_filtered   <- convert_list_to_test_format(train_data_tables_list_filtered, TIME_WINDOW_IN_MINUTES)

# Convert train data to test format
filtered_circle_train_data_at_test_format <- join_tables(train_data_at_test_format_list_filtered)

# Round Train to time window
train_data_tables_filtered_joined$time_interval <-
  round_to_time_window(string_to_date(train_data_tables_filtered_joined$Date.Time), TIME_WINDOW)

if (SAVE_FILTERED_AND_TEST_TABELS)
{
  write.csv(train_data_tables_filtered_joined, "filtered_circle_train_data.csv")
  write.csv(filtered_circle_train_data_at_test_format, "filtered_circle_train_data_at_test_format.csv")
}

#++++++++++++++++++++++++ Explanatory Analysis ++++++++++++++++++++++
# General overview of the data
summary(train_data_tables_filtered_joined)

if (INSTALL_NECCESARY_PACKAGES)
{
  install.packages(VIM)  
}

library(VIM)
# Making sure all values exist
aggr(train_data_tables_filtered_joined)

#--------------------- Adding Columns to test format ----------------
# Adding time columns to test format
filtered_circle_train_data_at_test_format <- 
  add_time_columns(
    filtered_circle_train_data_at_test_format)

for (i in seq_along(train_data_at_test_format_list_filtered))
{
  month_data <- data.frame(train_data_at_test_format_list_filtered[[i]])
  
  train_data_at_test_format_list_filtered[[i]] <- add_time_columns(month_data)
}

#------------------- Exploring Pick Num Distribution ----------------
if (DATA_EXPLORE_PICK_NUM_DISTRIBUTION)
{
  
  # Distribution of pick_num, exponential decrease after mean value
  plot_picknum_graph_distribution(filtered_circle_train_data_at_test_format)
  
  # Creating pick_num distibution for each month
  monthes_list        <- train_data_at_test_format_list_filtered
  for (i in seq_along(monthes_list))
  {
    month_data <- data.frame(monthes_list[[i]])
    
    plot_picknum_graph_distribution(month_data, 
                                    print_mean_value = TRUE,
                                    file_name_suffix = month_index_to_identifier(i))
    
  }
}

#------------------------ External Data Section ---------------------
if (DATA_EXPLORE_PICK_NUM_EACH_DAY_AND_HOUR)
{
  # Most rides are between (17 PM - 18 PM) on Monday till Saturday
  # Most rides on Sundays are at 19 PM
  plot_picknum_for_hours_in_each_day_distribution(filtered_circle_train_data_at_test_format)
  
  # Creating pick_num distibution for each month
  monthes_list        <- train_data_at_test_format_list_filtered
  for (i in seq_along(monthes_list))
  {
    month_data <- data.frame(monthes_list[[i]])
    
    plot_picknum_for_hours_in_each_day_distribution(month_data, 
                                                    file_name_suffix = month_index_to_identifier(i))
  }
}

# Read external data
snp_table               <- read.csv("external/snp500.csv")

joined_filtered_circle_train_data_at_test_format <- 
  filtered_circle_train_data_at_test_format

joined_filtered_circle_train_data_at_test_format <- 
  join_external_with_test(
    joined_filtered_circle_train_data_at_test_format, 
    snp_table, "%d/%m/%Y", "day")

#--------------- Exploring Climate on Peak Times --------------------
if (DATA_EXPLORE_CLIMATE)
{
  ny_climate              <- read.csv("external/ny-climate.csv")
  
  filtered_circle_train_data_at_test_format_events <- 
    read.csv("filtered_circle_train_data_at_test_format_events.csv")
  
  filtered_circle_train_data_at_test_format_events$Time_Interval <-
    string_to_date(filtered_circle_train_data_at_test_format_events$Time_Interval, "%d/%m/%Y %H:%M")
  
  joined_filtered_circle_train_with_events_and_climate_data_at_test_format <- 
    filtered_circle_train_data_at_test_format_events
  
  joined_filtered_circle_train_with_events_and_climate_data_at_test_format <- 
    join_external_with_test(
      joined_filtered_circle_train_with_events_and_climate_data_at_test_format, 
      ny_climate, "%d/%m/%Y %H:%M", "hour")
  
  write.csv(
    joined_filtered_circle_train_with_events_and_climate_data_at_test_format, 
    "joined_filtered_circle_train_with_events_and_climate_data_at_test_format.csv")
}

#------------------- Monthes Exploration Section --------------------
# Creating monthes count table
monthes_count_table <- create_monthes_count_table(train_data_tables_list_filtered)

# Exploring monthes count table
if (INSTALL_NECCESARY_PACKAGES)
{
  install.packages("Scale")
}
library(Scale)

ggplot(data=monthes_count_table, aes(x=month_count, y=month_number))+ 
  geom_bar(stat="identity", color="blue", fill="white") + 
  scale_x_continuous(labels = scales::unit_format(suffix = "k", 
                                                  scale  = 0.001, 
                                                  sep    = ""))
"
# Add following to view exact numbers
scale_x_continuous('month_count', 
                     labels = as.character(monthes_count_table$month_count), 
                     breaks = monthes_count_table$month_count)
"

# Pick num  per month is rising through 2014
ggplot(monthes_count_table, aes(month_number, month_count)) + 
  ggtitle("Pick num  per month is rising through 2014") + 
  geom_line()

#------------------- Correlation Exploration Section --------------------
if (INSTALL_NECCESARY_PACKAGES)
{
  install.packages("corrplot")
}

library(corrplot)
uber_correlation_matrix <- 
  cor(joined_filtered_circle_train_data_at_test_format[sapply(joined_filtered_circle_train_data_at_test_format, function(x) is.numeric(x))], use="pairwise.complete.obs")
corrplot(uber_correlation_matrix, method = "number", type = "full")

#------------------------ Heat Map Section --------------------------
if (CREATE_HEAT_MAPS)
{
  # Get location map of New York
  new_york_map <- get_location_map()
  
  # Create heatmap for the whole filtered training set data
  create_heatmap(train_data_tables_filtered_joined, new_york_map)
  
  # Creating heatmap for each day in week
  for (day_in_week in 1:7)
  {
    day_data <- train_data_tables_filtered_joined[train_data_tables_filtered_joined$day_in_week == day_in_week,]
    create_heatmap(
      day_data, new_york_map, 
      file_name_suffix = paste(DAY_SEPERATOR, day_in_week, sep = ""))
  }
  
  monthes_list        <- train_data_tables_list_filtered
  
  # Creating heatmap for each month
  for (i in seq_along(monthes_list))
  {
    month_data <- data.frame(monthes_list[[i]])
    create_heatmap(
      month_data, new_york_map, 
      file_name_suffix = month_index_to_identifier(i))
  }
}

#-------------------------- Types Section ---------------------------
set_columns_multiple_types <- function(
  data, 
  factors_list  = c("minute", "hour", "day", "day_in_week", "month", "is_weekend"), 
  numeric_list = c("pick_num", "day_in_year", "open", "close", "daily_return"))
{
  set_colums_to_type <- function(data, cols_list, fun)
  {
    for (i in seq_along(cols_list))
    {
      col_name              <- cols_list[i]
      
      if(col_name %in% colnames(data))
      {
        col                   <- data[, col_name]
        col                   <- col %>% fun
        data[, col_name]      <- col
      }
    }
    return(data)
  }
  
  data <- set_colums_to_type(data, factors_list, as.factor)
  data <- set_colums_to_type(data, numeric_list, as.numeric)
  
  return(data)
}

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#++++++++++++++++++++++++++ Model Estimation ++++++++++++++++++++++++
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#~~~~~~~~~~~~~~~~~~~~~~~~~ Clusters Model ~~~~~~~~~~~~~~~~~~~~~~~~~~~
#------------------- Clusters Model Exploration ---------------------
train_data <- train_data_tables_filtered_joined

# Plotting clusters Total within-clusters sum of squares
kmeans_models         <- caclulate_kmeans_models(train_data)
plot_clusters_total_within_clusters_sum_of_squares(kmeans_models)

if (CREATE_K_MEANS_MAPS)
{
  new_york_map <- get_location_map()
  create_kmeans_heatmaps(train_data_tables_filtered_joined, new_york_map)  
}

if (CREATE_MONTHES_CLUSTERS_MAPS)
{
  monthes_list        <- train_data_tables_list_filtered
  
  # Creating heatmap for each month
  for (i in seq_along(monthes_list))
  {
    month_number <- month_index_to_number(i)
    
    if (DEBUG_PRINT)
    {
      print(paste(HEATMAP_CLUSTER_MONTH_MESSAGE, month_number)) 
    }
    
    month_data <- data.frame(monthes_list[[i]])
    create_cluster_heatmap(
      month_data, 
      new_york_map, 
      CLUSTERS_NUMBER, 
      heamap_name_suffix = paste(CLUSTERS_SEPERATOR, MONTH_SEPERATOR, month_number, sep = ""))
  }
}

#-------------------------- Clusters Model Section ------------------
library(purrr)
library(tidyr)
library(dplyr)
library(broom)
library(ggplot2)
library(RColorBrewer)

#-------------------- Prediction Adjustment Section -----------------
# Adjust predictions to be natural numbers
adjust_predictions <- function(predicted_data)
{
  round_integer <- function(d)
  {
    return(round(d))
  }
  
  transform_to_natural_number <- function(n)
  {
    return(ifelse(n < 0, 0, n))
  }
  
  predicted_data <- lapply(predicted_data, FUN = round_integer)
  predicted_data <- lapply(predicted_data, FUN = transform_to_natural_number)
  return(predicted_data)
}

#--------------------------- Train Filter Section -------------------
filter_train <- function(train_data)
{
  train_data <- train_data[(train_data$month == 6) | (train_data$month == 7),]
  return(train_data)
}

library(data.table)

filter_global_anomaly_train <- function(train_data, train_data_at_test_format, global_anomaly_treshold = GLOBAL_ANOMALY_TRSHOLD)
{
  train_data                  <- data.table(train_data)
  train_data_at_test_format   <- data.table(train_data_at_test_format)
  
  anomaly_table <- train_data_at_test_format[train_data_at_test_format$pick_num >= global_anomaly_treshold, ]
  
  setkey(anomaly_table, Time_Interval)
  setkey(train_data, time_interval)
  
  regular_train_table <- train_data[!anomaly_table]
  
  return(regular_train_table)
}

#-------------------- Train Vs Validation Model Section -------------

# Training models
train_data                      <- filter_train(train_data_tables_filtered_joined)
regular_train_data              <- train_data
regular_train_data_test_format  <- convert_to_test_format(regular_train_data)
regular_train_data_test_format  <- add_time_columns(regular_train_data_test_format)
regular_train_data_test_format  <- 
  join_external_with_test(regular_train_data_test_format, snp_table, "%d/%m/%Y", "day")
regular_train_data_test_format  <- set_columns_multiple_types(regular_train_data_test_format)

print("Model Without S&P 500:")
model_without_SP <- lm(pick_num ~ minute + hour + day_in_week + hour*day_in_week, data = regular_train_data_test_format)
summary(model_without_SP)

print("Model With S&P 500:")
model_with_SP <- lm(pick_num ~ minute + hour + day_in_week + hour*day_in_week + daily_return, data = regular_train_data_test_format)
summary(model_with_SP)

validation_data_table             <- train_data_at_test_format_list_filtered[[(MONTH_VALIDATION_NUMBER) - 4 + 1]]
validation_data_table             <- add_time_columns(validation_data_table)
validation_data_table             <- join_external_with_test(validation_data_table, snp_table, "%d/%m/%Y", "day")
validation_data_table             <- set_columns_multiple_types(validation_data_table)

prediction_without_SP             <- predict(model_without_SP, newdata = validation_data_table)
prediction_without_SP             <- data.frame(adjust_predictions(prediction_without_SP))
prediction_without_SP_transposed  <- prediction_without_SP %>% data.frame() %>% t()
rs_validation_without_SP          <- r_squared(expected = prediction_without_SP_transposed, actual = validation_data_table$pick_num)
print(paste("Validation R^2 (Without S&P-500): ", rs_validation_without_SP))

prediction_with_SP                <- predict(model_with_SP, newdata = validation_data_table)
prediction_with_SP                <- data.frame(adjust_predictions(prediction_with_SP))
prediction_with_SP_transposed     <- prediction_with_SP %>% data.frame() %>% t()
rs_validation_with_SP             <- r_squared(expected = prediction_with_SP, actual = validation_data_table$pick_num)
print(paste("Validation R^2 (With S&P-500): ", rs_validation_with_SP))

#----------------------- Model Regression Section -------------------
train_data                                        <- filter_train(train_data_tables_filtered_joined)

# Model for cluster, without S&P data
cluster_model_without_SP <- function(cluster_data)
{
  lm(pick_num ~ minute + hour + day_in_week + hour*day_in_week, data = cluster_data)
}

# Model for cluster, with S&P data
cluster_model_with_SP <- function(cluster_data)
{
  lm(pick_num ~ minute + hour + day_in_week + hour*day_in_week + daily_return, data = cluster_data)
}

# Classifing train data to clusters using a K-Means model
kmeans_cluster_classifier                         <- calculate_kmeans_model(train_data, k = CLUSTERS_NUMBER)
train_data$cluster                                <- kmeans_cluster_classifier$cluster

# Grouping train data into groups by cluster, and nesting to a new table: each row is one cluster
train_data_by_cluster                             <- train_data %>%
  group_by(cluster) %>%
  nest()

# Sanity Checks
if (DEBUG_PRINT)
{
  # Sanity Check: Verifying data is arranged by desired number of clusters
  arrange(train_data_by_cluster, .by_group = TRUE)
  
  # Sanity Check: Verifying amount of locations for each cluster
  train_data_by_cluster                             <- train_data_by_cluster %>% 
    mutate(raw_rows_count = map_dbl(data, nrow))
  train_data_by_cluster
  
  # Sanity Check: Verifying total locations in clusters sum up to train data
  print("Verifying total locations in clusters sum up to train data")
  nrow(train_data) == sum(train_data_by_cluster$raw_rows_count)
}

# Converting train data of each cluster to test format, as needed by model
train_data_at_test_format_by_cluster              <- train_data_by_cluster %>% 
  mutate(test_format = map(data, convert_to_test_format))

if (CUTOFF_CLUSTER_ANOMALY_THRESHOLD)
{
  cutoff_picknum_peak_by_treshold <- function(data, 
                                              treshold = TIME_WINDOW_CLUSTER_ANOMALY_THRESHOLD,
                                              colname  = "pick_num")
  {
    col_values      <- data[, colname]
    data[, colname] <- ifelse(col_values > treshold, treshold, col_values)
    return(data)
  }
  
  # Cutting off pick num according to treshold for each time window
  train_data_at_test_format_by_cluster              <- train_data_at_test_format_by_cluster %>% 
    mutate(
      test_format = 
        map(.x = test_format, 
            .f = cutoff_picknum_peak_by_treshold,
            TIME_WINDOW_CLUSTER_ANOMALY_THRESHOLD))
}

# Adding time columns to clusters test format
raw_prediction_month_data                         <- read.csv("test/uber_test.csv")
raw_prediction_month_data$Time_Interval           <- string_to_date(
  raw_prediction_month_data$Time_Interval, 
  time_format = "%Y-%m-%d %H:%M:%S")
prediction_month_data                             <- add_time_columns(raw_prediction_month_data)
train_data_at_test_format_by_cluster              <- train_data_at_test_format_by_cluster %>% 
  mutate(test_format = map(test_format, add_time_columns))

# Adding S&P 500 colums
snp_table                                         <- read.csv("external/snp500.csv")
prediction_month_data                             <- join_external_with_test(
  prediction_month_data, 
  snp_table,
  "%d/%m/%Y", "day")
train_data_at_test_format_by_cluster              <- train_data_at_test_format_by_cluster %>% 
  mutate(
    test_format = 
      map(
        .x = test_format,
        .f = join_external_with_test,
        snp_table, 
        "%d/%m/%Y", "day"))

# Converting columns to types
prediction_month_data                             <- set_columns_multiple_types(prediction_month_data)
train_data_at_test_format_by_cluster              <- train_data_at_test_format_by_cluster %>% 
  mutate(test_format = map(test_format, set_columns_multiple_types))

# Assigning models as columns to clusters
train_data_at_test_format_by_cluster              <- train_data_at_test_format_by_cluster %>% 
  mutate(model_with_SP    = test_format %>% map(cluster_model_with_SP))
train_data_at_test_format_by_cluster              <- train_data_at_test_format_by_cluster %>% 
  mutate(model_without_SP = test_format %>% map(cluster_model_without_SP))

# Assigning prediction as colums to clusters
train_data_at_test_format_by_cluster              <- train_data_at_test_format_by_cluster %>% 
  mutate(predict_with_SP    = 
           map(.x = model_with_SP,
               .f = predict, 
               prediction_month_data,
           ) %>%
           adjust_predictions)
train_data_at_test_format_by_cluster              <- train_data_at_test_format_by_cluster %>% 
  mutate(predict_without_SP    = 
           map(.x = model_without_SP,
               .f = predict, 
               prediction_month_data) %>%
           adjust_predictions)

# Extract predictions for each time interval
prediction_with_SP_list                           <- train_data_at_test_format_by_cluster$predict_with_SP %>%
  data.frame() %>% rowwise() %>% rowSums()
prediction_without_SP_list                        <- train_data_at_test_format_by_cluster$predict_without_SP %>%
  data.frame() %>% rowwise() %>% rowSums()

# Create predictions table 
prediction_table                                  <- data.frame(Time_Interval      = character(),
                                                                pick_num_withoutSP = numeric()  ,
                                                                pick_num_withSP    = numeric()   )

# Assign time interval to prediciton table
time_intervals                                    <- subset(prediction_month_data, select = c("Time_Interval"))
prediction_table                                  <- rbind.fill(prediction_table, time_intervals)
# Assign predictions to predictions table
prediction_table$pick_num_withoutSP               <- prediction_without_SP_list
prediction_table$pick_num_withSP                  <- prediction_with_SP_list

# Writing prediction table
write.csv(prediction_table, "uber_test.csv")
