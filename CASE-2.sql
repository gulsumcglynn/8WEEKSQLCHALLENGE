DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  "runner_id" INTEGER,
  "registration_date" DATETIME2
);
INSERT INTO runners
  ("runner_id", "registration_date")
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  "order_id" INTEGER,
  "customer_id" INTEGER,
  "pizza_id" INTEGER,
  "exclusions" VARCHAR(4),
  "extras" VARCHAR(4),
  "order_time" DATETIME2
);

INSERT INTO customer_orders
  ("order_id", "customer_id", "pizza_id", "exclusions", "extras", "order_time")
VALUES
  (1, 101, 1, NULL, NULL, '2020-01-01 18:05:02'),
  (2, 101, 1, NULL, NULL, '2020-01-01 19:00:52'),
  (3, 102, 1, NULL, NULL, '2020-01-02 23:51:23'),
  (3, 102, 2, NULL, NULL, '2020-01-02 23:51:23'),
  (4, 103, 1, '4', NULL, '2020-01-04 13:23:46'),
  (4, 103, 1, '4', NULL, '2020-01-04 13:23:46'),
  (4, 103, 2, '4', NULL, '2020-01-04 13:23:46'),
  (5, 104, 1, NULL, '1', '2020-01-08 21:00:29'),
  (6, 101, 2, NULL, NULL, '2020-01-08 21:03:13'),
  (7, 105, 2, NULL, '1', '2020-01-08 21:20:29'),
  (8, 102, 1, NULL, NULL, '2020-01-09 23:54:33'),
  (9, 103, 1, '4', '1, 5', '2020-01-10 11:22:59'),
  (10, 104, 1, NULL, NULL, '2020-01-11 18:34:49'),
  (10, 104, 1, '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  "order_id" INTEGER,
  "runner_id" INTEGER,
  "pickup_time" DATETIME,
  "distance" VARCHAR(7),
  "duration" VARCHAR(10),
  "cancellation" VARCHAR(23)
);

INSERT INTO runner_orders
  ("order_id", "runner_id", "pickup_time", "distance", "duration", "cancellation")
VALUES
  (1, 1, '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  (2, 1, '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  (3, 1, '2020-01-03 00:12:37', '13.4km', '20 mins', ''),
  (4, 2, '2020-01-04 13:53:03', '23.4', '40', ''),
  (5, 3, '2020-01-08 21:10:57', '10', '15', ''),
  (6, 3, NULL, NULL, NULL, 'Restaurant Cancellation'),
  (7, 2, '2020-01-08 21:30:45', '25km', '25mins', ''),
  (8, 2, '2020-01-10 00:15:02', '23.4 km', '15 minute', ''),
  (9, 2, NULL, NULL, NULL, 'Customer Cancellation'),
  (10, 1, '2020-01-11 18:50:20', '10km', '10minutes', '');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  "pizza_id" INTEGER,
  "pizza_name" VARCHAR(MAX)
);
INSERT INTO pizza_names
  ("pizza_id", "pizza_name")
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  "pizza_id" INTEGER,
  "toppings" VARCHAR(MAX)
);
INSERT INTO pizza_recipes
  ("pizza_id", "toppings")
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  "topping_id" INTEGER,
  "topping_name" VARCHAR(MAX)
);
INSERT INTO pizza_toppings
  ("topping_id", "topping_name")
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');


  --VERİ TEMİZLİĞİ
-- distance ve duration sütununda sayısal işlemler yapabilmek için sondaki string ifadeleri silip, sütun tipini değiştirdim.
--Aynı zamanda cancellation sütununda da boşlukları NULL olarak değiştirdim.
UPDATE runner_orders
SET distance = CASE
                 WHEN RIGHT(distance, 2) = 'km' THEN LEFT(distance, LEN(distance) - 2)
                 ELSE distance
               END;
ALTER TABLE runner_orders
ALTER COLUMN distance FLOAT;

UPDATE runner_orders
SET duration = CASE
                 WHEN RIGHT(duration, 7) = 'minutes' THEN LEFT(duration, LEN(duration) - 7)
				 WHEN RIGHT(duration, 4) = 'mins' THEN LEFT(duration, LEN(duration) - 4)
				 WHEN RIGHT(duration, 6) = 'minute' THEN LEFT(duration, LEN(duration) - 6)
                 ELSE duration
               END;
ALTER TABLE runner_orders
ALTER COLUMN duration INTEGER;
UPDATE runner_orders
SET cancellation = CASE
                     WHEN cancellation = '' THEN  NULL
					 ELSE cancellation
				   END;

--A.PIZZA METRICS
--1.How many pizzas were ordered?
select count(order_id)
from customer_orders;
--14 sipariş verilmiş.

--2.How many unique customer orders were made?

SELECT COUNT(DISTINCT order_id)
FROM customer_orders;
--10 adet unique sipariş verilmiştir.

--3.How many succesful orders were delivered by each runner?
SELECT runner_id,
       COUNT(order_id)
FROM runner_orders
WHERE cancellation is NULL
GROUP BY runner_id;

--1 nolu runner 4,2 nolu runner 3, 3 nolu runner 1 başarılı sipariş teslim etmiş.

--4.How many of each type of pizza was delivered?
SELECT pizza_id,
        COUNT(pizza_id) 
FROM customer_orders co
JOIN runner_orders ro on co.order_id = ro.order_id
WHERE cancellation is NULL
GROUP BY pizza_id; 
--1 nolu pizza 9 kez teslim edilmiş, 2 nolu pizza 3 kez teslim edilmiş.

--5.How many Vegetarian and Meatlovers were ordered by each customer?
SELECT customer_id,
       pizza_name,
       count(co.pizza_id) as count
FROM customer_orders co
JOIN pizza_names pn on pn.pizza_id = co.pizza_id
GROUP BY customer_id, pizza_name;

--6.What was the maximum number of pizzas delivered in a single order?
SELECT TOP 1 co.order_id,
       count(pizza_id) count
FROM customer_orders co
JOIN runner_orders ro on co.order_id = ro.order_id
WHERE cancellation is NULL
GROUP BY co.order_id
ORDER BY count DESC;

--En fazla 4. siparişte 3 adet pizza sipariþ edilmiş.
--7.For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT customer_id,
       SUM(CASE
	       WHEN exclusions is NULL and extras is NULL THEN 1 
		   ELSE 0
		   END) AS NOT_CHANGED,
	   SUM(CASE
	       WHEN exclusions is NULL and extras is NULL THEN 1 
		   ELSE 0
		   END) AS CHANGED
FROM customer_orders co
JOIN runner_orders ro on co.order_id = ro.order_id
WHERE ro.cancellation IS NULL
GROUP BY customer_id;

--8.How many pizzas were delivered that had both exclusions and extras?

SELECT pizza_id 
FROM customer_orders co
JOIN runner_orders ro on co.order_id = ro.order_id
WHERE ro.cancellation is NULL and exclusions is not null and extras is not null
GROUP BY pizza_id;

--Bu koşullara sahip 1 adet sipariş teslim edilmiş.
--9.What was the total volume of pizzas ordered for each hour of the day?
SELECT 
    FORMAT(order_time, 'HH') as saat, 
    COUNT(pizza_id) as toplam_pizza  
FROM 
    customer_orders
GROUP BY 
    FORMAT(order_time, 'HH');

--10.What was the volume of orders for each day of the week?
SELECT 
    FORMAT(order_time, 'dddd') as gun, 
    COUNT(order_id) as toplam_sýparýs  
FROM 
    customer_orders
GROUP BY 
    FORMAT(order_time, 'dddd');
--Cuma 1,Cumartesi 5, Perşembe 3, Çarşamba 5 sipariş verilmiş.

--B.Runner and Customer Experience
--1.How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT DATEPART(WEEK, registration_date) kacýncý_hafta,
       COUNT(runner_id) kac_runner_kaydoldu
FROM runners
GROUP BY DATEPART(WEEK, registration_date);

--1.hafta 1,2.hafta 2, 3.hafta 1 runner kaydoldu.

--2.What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
SELECT runner_id,
       AVG(DATEDIFF(MINUTE, order_time, pickup_time)) ort_sure
FROM customer_orders c
JOIN runner_orders r on c.order_id = r.order_id
GROUP BY runner_id;

--1 nolu runnerın ortalamalası 15,2 nolu runnerın ortalaması 24,3 nolu runnerın ortalaması 10 dk.

--3.Is there any relationship between the number of pizzas and how long the order takes to prepare?
WITH prep_time_cte AS
(
  SELECT 
    c.order_id, 
    COUNT(c.order_id) AS pizza_order,  
    DATEDIFF(MINUTE, c.order_time, r.pickup_time) prep_time
  FROM customer_orders AS c
  JOIN runner_orders AS r
    ON c.order_id = r.order_id
  WHERE r.cancellation is NULL
  GROUP BY c.order_id, c.order_time, r.pickup_time
)

SELECT 
  pizza_order, 
  AVG(prep_time) AS avg_prep_time
FROM prep_time_cte
GROUP BY pizza_order;
--1 pizza sipariş edildiğinde hazırlama süresi 12 dk, 2 pizza sipariş edildiğinde sipariş baþýna hazırlama süresi 9 dk oluyor,3 pizza sipariþ edildiğinde
--hazırlama sipariş başına 10 dk oluyor.Yani en verimli süre 2 pizza birlikte hazırlandığında oluyor.

--4.What was the average distance travelled for each customer?
SELECT customer_id,
       AVG(distance) as avg_distance
FROM runner_orders r
JOIN customer_orders c on r.order_id = c.order_id
GROUP BY customer_id;
--101 nolu müşteri için 20,102 nolu müşteri için 16.733,103 nolu müşteri için 23.4,104 nolu müşteri için 10,105 nolu müşteri için 25 km yol kat edildi.

--5.What was the difference between the longest and shortest delivery times for all orders?
SELECT MAX(duration)-MIN(duration) as difference
FROM runner_orders;
--30.

--6.What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT 
    r.runner_id,
	c.order_id,
    ROUND(AVG(r.distance / NULLIF(r.duration / 60.0, 0)),2) AS avg_speed
FROM 
    customer_orders c
JOIN 
    runner_orders r ON c.order_id = r.order_id
WHERE 
    r.cancellation IS NULL
GROUP BY 
    r.runner_id,c.order_id
ORDER BY
    c.order_id;
--1 nolu runner için bir trend yok.2 nolu runner için artan bir trend var.3 nolu runnerın teslim ettiği tek sipariþ olduğu için bir trend yok.
--7.What is the successful delivery percentage for each runner?
SELECT 
  runner_id, 
  100 * SUM(
    CASE WHEN distance is NULL THEN 0
    ELSE 1 END) / COUNT(order_id) AS basarý_yuzdesý
FROM runner_orders
GROUP BY runner_id;

--C.Ingredient Optimisation
--1.What are the standard ingredients for each pizza?
WITH toppingbreak AS(
  SELECT 
  pr.pizza_id,
  t.value AS topping_id,
  pt.topping_name
FROM pizza_recipes pr
  CROSS APPLY string_split(toppings, ',') AS t
JOIN pizza_toppings pt
  ON TRIM(t.value) = pt.topping_id
  )
  
SELECT 
  p.pizza_name,
  STRING_AGG(t.topping_name, ', ') AS ingredients
FROM toppingBreak t
JOIN pizza_names p 
  ON t.pizza_id = p.pizza_id
GROUP BY p.pizza_name;

--2.What was the most commonly added extra?
WITH AggregatedExtras AS (
    SELECT 
        order_id, 
        STRING_AGG(extras, ', ') WITHIN GROUP (ORDER BY extras) AS all_extras
    FROM customer_orders
    WHERE extras IS NOT NULL
    GROUP BY order_id
)
SELECT TOP 1 all_extras
FROM AggregatedExtras;

--3.What was the most common exclusion?

-- Sadece en sýk tekrar eden elemaný getir
WITH SplitExclusions AS (
    SELECT
        value AS exclusions_item
    FROM customer_orders
    CROSS APPLY string_split(exclusions, ',')
	WHERE exclusions is NOT NULL
)

SELECT TOP 1
    exclusions_item,
    COUNT(*) AS frequency
FROM SplitExclusions
GROUP BY exclusions_item
ORDER BY frequency DESC;
 --4 defa 4 nolu topping çıkarılmış.

--4.Generate an order item for each record in the customers_orders table in the format of one of the following: :
--Meat Lovers
--Meat Lovers - Exclude Beef
--Meat Lovers - Extra Bacon
--Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers


-- SEQUENCE kullanarak customer_orders tablosuna record_id sütunu ekledim.
CREATE SEQUENCE Seq_customer_orders
    START WITH 1
    INCREMENT BY 1;
ALTER TABLE customer_orders
ADD record_id INT;
UPDATE customer_orders
SET record_id = NEXT VALUE FOR Seq_customer_orders;


--Hangi kayıtlarda extra malzeme eklenmiş ona bakıyoruz.
SELECT 
  c.record_id,
  TRIM(e.value) AS extra_id
INTO extrasBreaks 
FROM customer_orders c
  CROSS APPLY string_split(extras, ',') AS e;

SELECT *
FROM extrasBreaks;

----Hangi kayıtlarda malzeme çıkarılmış ona bakıyoruz.
SELECT 
  c.record_id,
  TRIM(e.value) AS exclusion_id
INTO exclusionsBreak 
FROM customer_orders c
  CROSS APPLY string_split(exclusions, ',') AS e;

SELECT *
FROM exclusionsBreak;

--Yeni tablolar oluşturup pizza_info adında yeni bir sütun ekledim.


WITH extras_table AS (
  SELECT 
    e.record_id,
    'Extra ' + STRING_AGG(t.topping_name, ', ') AS record_options
  FROM extrasBreaks e JOIN pizza_toppings t on e.extra_id = t.topping_id
  GROUP BY e.record_id
), 

exclusions_table AS (
  SELECT 
    e.record_id,
    'Exclusion ' + STRING_AGG(t.topping_name, ', ') AS record_options
  FROM exclusionsBreak e JOIN pizza_toppings t on e.exclusion_id = t.topping_id
  GROUP BY e.record_id
), 

full_table AS (
  SELECT * FROM extras_table
  UNION
  SELECT * FROM exclusions_table
)

SELECT 
  c.record_id,
  c.order_id,
  c.customer_id,
  c.pizza_id,
  c.order_time,
  CONCAT_WS(' - ', p.pizza_name, STRING_AGG(u.record_options, ' - ')) AS pizza_info
FROM customer_orders c LEFT JOIN full_table u on c.record_id = u.record_id
JOIN pizza_names p ON c.pizza_id = p.pizza_id
GROUP BY
  c.record_id, 
  c.order_id,
  c.customer_id,
  c.pizza_id,
  c.order_time,
  p.pizza_name
ORDER BY record_id;

--5.Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
--For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
WITH INGREDIENTS AS (
    SELECT 
        c.order_id,
        c.pizza_id,
        pn.pizza_name,
        c.order_time,
        c.record_id,
        CASE 
            WHEN tb.topping_id IN (
                SELECT e.extra_id
                FROM extrasBreak e 
                WHERE e.extra_id = c.record_id
            )
            THEN CONCAT('2x', tb.topping_name)
            ELSE tb.topping_name
        END AS topping
    FROM 
        customer_orders c
    JOIN 
        pizza_names pn ON pn.pizza_id = c.pizza_id
    JOIN 
        toppingsBreak tb ON tb.pizza_id = c.pizza_id
    WHERE 
        tb.topping_id NOT IN (
            SELECT e.exclusion_id 
            FROM exclusionsBreak e 
            WHERE c.record_id = e.record_id
        )
)
SELECT 
    record_id,
    order_id,
    pizza_id,
    order_time,
    CONCAT(pizza_name, ':', STRING_AGG(topping, ',')) AS ingredients
FROM 
    INGREDIENTS
GROUP BY 
    record_id, order_id, pizza_id, order_time, pizza_name;


--6.What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
WITH frekans_tablosu AS (SELECT c.record_id,t.topping_name,
     CASE WHEN t.topping_id IN(
	                         SELECT e.extra_id
							 FROM extrasBreak e
							 WHERE e.extra_id = c.record_id)
		  THEN 2
		  WHEN t.topping_id IN(
		                     SELECT eb.exclusion_id
							 FROM exclusionsBreak eb
							 WHERE eb.exclusion_id = c.record_id)
		  THEN 0
		  ELSE 1
		  END AS topping_frekans
FROM customer_orders c
JOIN toppingsBreak t on t.pizza_id = c.pizza_id
JOIN pizza_names pn on pn.pizza_id = c.pizza_id)

SELECT topping_name,
       sum(topping_frekans) as topping_frekans
FROM frekans_tablosu
GROUP BY topping_name
ORDER BY topping_frekans DESC;

--D.Pricing and Ratings
--1.If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
SELECT 
	   SUM(CASE WHEN pn.pizza_name = 'Meatlovers' THEN 12 ELSE 10 END) AS toplam_fiyat
FROM 
    customer_orders c
JOIN 
    runner_orders r ON c.order_id = r.order_id
JOIN 
    pizza_names pn ON c.pizza_id = pn.pizza_id
WHERE 
    r.cancellation IS NULL;
--138.

--2.What if there was an additional $1 charge for any pizza extras?
--Add cheese is $1 extra
WITH TOPLAM_FIYAT AS (
    SELECT 
        SUM(CASE WHEN pn.pizza_name = 'Meatlovers' THEN 12 ELSE 10 END) AS toplam_fiyat
    FROM 
        customer_orders c
    JOIN 
        runner_orders r ON c.order_id = r.order_id
    JOIN 
        pizza_names pn ON c.pizza_id = pn.pizza_id
    WHERE 
        r.cancellation IS NULL
),
TOPLAM_TUTAR AS (
    SELECT 
        (SELECT toplam_fiyat FROM TOPLAM_FIYAT) 
        + SUM(CASE WHEN pt.topping_name = 'Cheese' THEN 1 ELSE 0 END) AS yeni_toplam_fiyat
    FROM 
        extrasBreak e
    JOIN 
        pizza_toppings pt ON e.extra_id = pt.topping_id
)
SELECT * FROM TOPLAM_TUTAR;
--3.The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
DROP TABLE IF EXISTS ratings
CREATE TABLE ratings (
  order_id INT,
  rating INT);
INSERT INTO ratings (order_id, rating)
VALUES 
  (1,3),
  (2,5),
  (3,3),
  (4,1),
  (5,5),
  (7,3),
  (8,4),
  (10,3);

 SELECT * FROM ratings;
--4.Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
--customer_id,order_id,runner_id,rating,order_time,pickup_time
--Time between order and pickup
--Delivery duration
--Average speed
--Total number of pizzas
SELECT customer_id,
       c.order_id,
	   runner_id,
	   rating,
	   order_time,
	   pickup_time,
	   DATEDIFF(MINUTE, order_time, pickup_time) as týme,
	   duration,
	   AVG(ROUND(distance/(duration/60.0),2)) as ort_hýz,
	   COUNT(pizza_id) AS toplam_pizza_sayýsý
FROM customer_orders c
JOIN runner_orders ro on c.order_id = ro.order_id
JOIN ratings r on r.order_id = c.order_id
WHERE cancellation is NULL
GROUP BY customer_id,
         c.order_id,
		 order_time,
		 pickup_time,
		 runner_id,
		 rating,
		 duration;
--5.If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?
WITH TOPLAM_FIYAT AS (
    SELECT 
        SUM(CASE WHEN pn.pizza_name = 'Meatlovers' THEN 12 ELSE 10 END) AS toplam_fiyat
    FROM 
        customer_orders c
    JOIN 
        runner_orders r ON c.order_id = r.order_id
    JOIN 
        pizza_names pn ON c.pizza_id = pn.pizza_id
    WHERE 
        r.cancellation IS NULL
),

MONEY_TABLE AS(SELECT
                    (SELECT toplam_fiyat FROM TOPLAM_FIYAT) - (SUM(distance)*0.3)  AS kalan_para
                    FROM runner_orders)		
SELECT * FROM MONEY_TABLE;
