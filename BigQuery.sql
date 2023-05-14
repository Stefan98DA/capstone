## merging all files in a temporary table 
## excluded start_station_id and end station_id since there were some inconsistencies and the columns were not necessary for this analysis

BEGIN
 CREATE TEMP TABLE all_data AS
   SELECT * FROM(
    SELECT ride_id,
           rideable_type,
           started_at,
           ended_at,
           start_station_name,
           end_station_name,
           member_casual,
           trip_duration,
           weekday
    FROM `capstone-385619.bikeshare.apr_2020`
    UNION ALL
    SELECT ride_id,
           rideable_type,
           started_at,
           ended_at,
           start_station_name,
           end_station_name,
           member_casual,
           trip_duration,
           weekday
    FROM `capstone-385619.bikeshare.aug_2020`
    UNION ALL
    SELECT ride_id,
           rideable_type,
           started_at,
           ended_at,
           start_station_name,
           end_station_name,
           member_casual,
           trip_duration,
           weekday
    FROM `capstone-385619.bikeshare.dec_2020`
    UNION ALL
    SELECT ride_id,
           rideable_type,
           started_at,
           ended_at,
           start_station_name,
           end_station_name,
           member_casual,
           trip_duration,
           weekday
    FROM `capstone-385619.bikeshare.feb_2021`
    UNION ALL
    SELECT ride_id,
           rideable_type,
           started_at,
           ended_at,
           start_station_name,
           end_station_name,
           member_casual,
           trip_duration,
           weekday
    FROM `capstone-385619.bikeshare.jan_2021`
    UNION ALL
    SELECT ride_id,
           rideable_type,
           started_at,
           ended_at,
           start_station_name,
           end_station_name,
           member_casual,
           trip_duration,
           weekday
    FROM `capstone-385619.bikeshare.jul_2020`
    UNION ALL
    SELECT ride_id,
           rideable_type,
           started_at,
           ended_at,
           start_station_name,
           end_station_name,
           member_casual,
           trip_duration,
           weekday
    FROM `capstone-385619.bikeshare.jun_2020`
    UNION ALL
    SELECT ride_id,
           rideable_type,
           started_at,
           ended_at,
           start_station_name,
           end_station_name,
           member_casual,
           trip_duration,
           weekday
    FROM `capstone-385619.bikeshare.mar_2021`
    UNION ALL
    SELECT ride_id,
           rideable_type,
           started_at,
           ended_at,
           start_station_name,
           end_station_name,
           member_casual,
           trip_duration,
           weekday
    FROM `capstone-385619.bikeshare.may_2020`
    UNION ALL
    SELECT ride_id,
           rideable_type,
           started_at,
           ended_at,
           start_station_name,
           end_station_name,
           member_casual,
           trip_duration,
           weekday
    FROM `capstone-385619.bikeshare.nov_2020`
    UNION ALL
    SELECT ride_id,
           rideable_type,
           started_at,
           ended_at,
           start_station_name,
           end_station_name,
           member_casual,
           trip_duration,
           weekday
    FROM `capstone-385619.bikeshare.oct_2020`
    UNION ALL
    SELECT ride_id,
           rideable_type,
           started_at,
           ended_at,
           start_station_name,
           end_station_name,
           member_casual,
           trip_duration,
           weekday
    FROM `capstone-385619.bikeshare.sep_2020`);
END

## 'docked_bike' is an old name for 'classic_bike'

 UPDATE `capstone-385619._script6b214dfd5465895ad9f713fd8760bf1dcfa33f76.all_data` 
SET rideable_type = 'classic_bike' WHERE rideable_type = 'docked_bike'



## temp table with "bad data"

BEGIN
CREATE TEMP TABLE null_stations2 AS
  SELECT ride_id AS bad_ride_id FROM (
    SELECT ride_id,
           start_station_name,
           end_station_name
    FROM `capstone-385619._script6b214dfd5465895ad9f713fd8760bf1dcfa33f76.all_data`
    WHERE rideable_type = 'classic_bike' AND (start_station_name IS NULL OR end_station_name IS NULL));
  END   


## table with "bad data" excluded 


BEGIN
CREATE TEMP TABLE cleaned_combined_data AS
 SELECT * FROM `capstone-385619._script6b214dfd5465895ad9f713fd8760bf1dcfa33f76.all_data` AS cd
LEFT JOIN `capstone-385619._script0988d88bc82ec60de2cad2302c9cf2999b9d2547.null_stations2` AS ns
ON cd.ride_id = ns.bad_ride_id
WHERE ns.bad_ride_id IS NULL;
END

## final table ready for analysis 

BEGIN
CREATE TEMP TABLE final_data AS
    SELECT * FROM(
      SELECT ride_id,
             rideable_type,
             started_at,
             ended_at,
             start_station_name,
             end_station_name,
             member_casual AS member_type,
             trip_duration,
             weekday,
             CASE
         WHEN EXTRACT(MONTH FROM started_at) = 1 THEN 'January'
         WHEN EXTRACT(MONTH FROM started_at) = 2 THEN 'February'
         WHEN EXTRACT(MONTH FROM started_at) = 3 THEN 'March'
         WHEN EXTRACT(MONTH FROM started_at) = 4 THEN 'April'
         WHEN EXTRACT(MONTH FROM started_at) = 5 THEN 'May'
         WHEN EXTRACT(MONTH FROM started_at) = 6 THEN 'June'
         WHEN EXTRACT(MONTH FROM started_at) = 7 THEN 'July'
         WHEN EXTRACT(MONTH FROM started_at) = 8 THEN 'August'
         WHEN EXTRACT(MONTH FROM started_at) = 9 THEN 'September'
         WHEN EXTRACT(MONTH FROM started_at) = 10 THEN 'October'
         WHEN EXTRACT(MONTH FROM started_at) = 11 THEN 'November'
         ELSE 'December'
       END AS month
       FROM `capstone-385619._script3a551157e7d7cde40cceb65be3281e4165b9e1ea.cleaned_combined_data` 
      );
      END





## Data Analysis 
## added a WHERE clause because bikes with trip durations longer than a day are considered stolen or in repair
## number of rides by member_type and bike_type(rideable_type)

SELECT COUNT(*) AS number_of_rides, rideable_type, member_type
FROM `capstone-385619._script2fed36877decab554777bc3d3c01cc24dd9889df.final_data`
WHERE trip_duration <= 1440
GROUP BY  member_type, rideable_type

## average ride duration by member_type, month

SELECT ROUND(AVG(trip_duration),0) AS average_duration, member_type, month
FROM `capstone-385619._script2fed36877decab554777bc3d3c01cc24dd9889df.final_data`
WHERE trip_duration <= 1440
GROUP BY member_type, month

## average ride duration by member_type, day


SELECT ROUND(AVG(trip_duration),0) AS average_duration, member_type, weekday
FROM `capstone-385619._script2fed36877decab554777bc3d3c01cc24dd9889df.final_data`
WHERE trip_duration <= 1440
GROUP BY member_type, weekday


## average ride duration by member_type

SELECT ROUND(AVG(trip_duration),0)AS average_trip, member_type
FROM `capstone-385619._script2fed36877decab554777bc3d3c01cc24dd9889df.final_data`
WHERE trip_duration <= 1440
GROUP BY member_type

## number of rides per month, member_type
SELECT COUNT(*) AS num_of_trips, member_type, month
FROM `capstone-385619._script2fed36877decab554777bc3d3c01cc24dd9889df.final_data`
WHERE trip_duration <= 1440
GROUP BY member_type, month

## average number of rides by member_type
SELECT COUNT(*) AS number_of_trips,  member_type 
FROM `capstone-385619._script2fed36877decab554777bc3d3c01cc24dd9889df.final_data`
WHERE trip_duration <= 1440
GROUP BY member_type
