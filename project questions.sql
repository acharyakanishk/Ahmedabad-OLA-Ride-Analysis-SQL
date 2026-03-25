-- 1. Retrieve all successful bookings.
SELECT
	*
FROM
	BOOKINGS
WHERE
	"Booking Status" = 'Success';
	
-- 2. Find total number of rides.
SELECT
	COUNT(*) AS TOTAL_RIDES
FROM
	BOOKINGS;
	
-- 3. Calculate total revenue from successful rides.
SELECT
	SUM("Booking Value") AS TOTAL_REVENUE
FROM
	BOOKINGS
WHERE
	"Booking Status" = 'Success';
	
-- 4. Find average ride distance.
SELECT
	AVG("Ride Distance") AS AVG_DISTANCE
FROM
	BOOKINGS ;
	
-- 5. Count rides by booking status.
SELECT
	"Booking Status",
	COUNT(*) AS TOTAL_RIDES
FROM
	BOOKINGS
GROUP BY
	"Booking Status";
	
-- 6. Find number of rides per vehicle type.
SELECT
	COUNT(*) AS TOTAL_RIDES,
	"Vehicle Type"
FROM
	BOOKINGS
GROUP BY
	"Vehicle Type"
ORDER BY
	TOTAL_RIDES DESC;
	
-- 7. Find total revenue by vehicle type
SELECT 
    "Vehicle Type",
    SUM("Booking Value") AS total_revenue
FROM bookings b
WHERE "Booking Status" = 'Success'
GROUP BY "Vehicle Type"
ORDER BY total_revenue DESC;

-- 8. Join bookings and ride_metrics to get ride details with ratings.
SELECT
	B."Booking ID",
	B."Vehicle Type",
	B."Booking Value",
	R."Driver Ratings",
	R."Customer Rating"
FROM
	BOOKINGS B
	JOIN RIDE_METRICS R ON B."Booking ID" = R."Booking ID"
	
-- 9. Join bookings and cancellations to find all cancelled rides with reasons.
SELECT 
    b."Booking ID",
    b."Booking Status",
    c."Reason for cancelling by Customer",
    c."Driver Cancel Reason"
FROM bookings b
LEFT JOIN cancellations c
ON b."Booking ID" = c."Booking ID"
WHERE b."Booking Status" LIKE 'Cancelled%';

-- 10. Get average driver rating for each vehicle type.
SELECT
	b."Vehicle Type",
    Round(AVG(r."Driver Ratings"),2) AS avg_driver_rating
FROM bookings b
LEFT JOIN ride_metrics r
ON b."Booking ID" = r."Booking ID"
GROUP BY b."Vehicle Type";

-- 11. Find number of cancellations by pickup location.
SELECT 
    b."Pickup Location",
    COUNT(*) AS total_cancellations
FROM bookings b
LEFT JOIN cancellations c
ON b."Booking ID" = c."Booking ID"
WHERE b."Booking Status" <> 'Success'
GROUP BY b."Pickup Location"
ORDER BY total_cancellations DESC;

-- 12. Get ride details with both ratings and cancellation reasons using multiple joins.
SELECT 
    b."Booking ID",
    b."Booking Status",
    b."Vehicle Type",
    b."Booking Value",
    r."Driver Ratings",
    r."Customer Rating",
    c."Driver Cancel Reason",
    c."Reason for cancelling by Customer"
FROM bookings b
LEFT JOIN ride_metrics r
ON b."Booking ID" = r."Booking ID"
LEFT JOIN cancellations c
ON b."Booking ID" = c."Booking ID";


-- 13. Rank customers based on total number of rides.
SELECT 
    "Customer ID",
    total_rides,
    RANK() OVER (ORDER BY total_rides DESC) AS rnk
FROM (
    SELECT 
        "Customer ID",
        COUNT("Booking ID") AS total_rides
    FROM bookings
    GROUP BY "Customer ID"
) t;

-- 14. Find top 5 customers using window function.
SELECT
	*
FROM
	(
		SELECT
			"Customer ID",
			SUM("Booking Value") AS TOTAL_SPENT,
			DENSE_RANK() OVER (
				ORDER BY
					SUM("Booking Value") DESC
			) AS RNK
		FROM
			BOOKINGS
		WHERE
			"Booking Status" = 'Success'
		GROUP BY
			"Customer ID"
	)
WHERE
	RNK <= 5;
	
-- 15. Calculate running total of revenue by date.
SELECT "Date",
       SUM("Booking Value") AS daily_revenue,
       SUM(SUM("Booking Value")) OVER (ORDER BY "Date") AS running_total
FROM bookings
WHERE "Booking Status" = 'Success'
GROUP BY "Date";

-- 16. Find highest booking value ride per day.
SELECT *
FROM (
    SELECT "Date", "Booking ID", "Booking Value",
           RANK() OVER (PARTITION BY "Date" ORDER BY "Booking Value" DESC) AS rnk
    FROM bookings
) t
WHERE rnk = 1;

-- 17. Calculate average ride value partitioned by vehicle type.
SELECT "Vehicle Type", 
       ROUND(AVG("Booking Value"), 2) AS avg_booking_value
FROM bookings
GROUP BY "Vehicle Type";

-- 18. Find rides with booking value greater than overall average.
SELECT *
FROM bookings
WHERE "Booking Value" > (
    SELECT AVG("Booking Value")
    FROM bookings
);

-- 19. Get vehicle type with highest total revenue.
SELECT "Vehicle Type"
FROM bookings
WHERE "Booking Status" = 'Success'
GROUP BY "Vehicle Type"
ORDER BY SUM("Booking Value") DESC
LIMIT 1;

-- 20 Find customers who never cancelled a ride.
SELECT DISTINCT "Customer ID"
FROM bookings
WHERE "Customer ID" NOT IN (
    SELECT "Customer ID"
    FROM bookings
    WHERE "Booking Status" <> 'Success'
);

-- 21. Categorize rides as Short, Medium, Long based on distance.
SELECT "Booking ID",
CASE 
    WHEN "Ride Distance" < 5 THEN 'Short'
    WHEN "Ride Distance" < 15 THEN 'Medium'
    ELSE 'Long'
END AS distance_type
FROM bookings;

-- 22.Categorize ratings into Good, Average, Poor.
SELECT "Booking ID",
CASE 
    WHEN "Driver Ratings" >= 4 THEN 'Good'
    WHEN "Driver Ratings" >= 3 THEN 'Average'
    ELSE 'Poor'
END AS rating_category
FROM ride_metrics;

-- 23 List the top 5 customers who booked the highest number of rides:
SELECT
	COUNT(*) AS TOTAL_RIDES,
	"Customer ID"
FROM
	bookings
GROUP BY
	"Customer ID"
ORDER BY
	TOTAL_RIDES DESC
LIMIT
	5;

-- 24.Find the maximum and minimum driver ratings for Prime Sedan bookings:
SELECT
	MAX(r."Driver Ratings"),
	MIN(r."Driver Ratings")
FROM
 ride_metrics r left join bookings b on r."Booking ID" = b."Booking ID"
WHERE
	b."Vehicle Type" = 'Prime Sedan';

-- 25. Repeat Customers
SELECT
	"Customer ID",
	COUNT("Booking ID") AS TOTAL_RIDES
FROM
     bookings
GROUP BY
	"Customer ID"
HAVING
	COUNT("Booking ID") > 3
ORDER BY
	TOTAL_RIDES DESC;

-- 26. Peak Hour
SELECT 
    EXTRACT(HOUR FROM "Time") AS hour,
    COUNT(*) AS total_rides
FROM bookings
GROUP BY hour
ORDER BY total_rides DESC;
