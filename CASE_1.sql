CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

--1.Restoranda her m��terinin harcad��� toplam miktar nedir?

select * from sales s 
JOIN menu m on m.product_id = s.product_id;

select customer_id,
        sum(price)
from sales s 
JOIN menu m on m.product_id = s.product_id
group by customer_id

--A m��terisi 76, B m��terisi 74, C m��terisi 36 harcama yapm��t�r.

--2.Her m��teri restoran� ka� g�n ziyaret etti?
--M��teri ayn� g�n birden fazla ziyaret edebilece�i i�in d�st�nct komutu kulland�k.
select customer_id,
       count(DISTINCT order_date)
from sales
group by customer_id
--A m��terisi 4 g�n, B m��terisi 6 g�n, C m��terisi 2 g�n ziyaret


--3.Her m��terinin men�den sat�n ald��� ilk �r�n neydi?

with case_tablo as(
select distinct customer_id, order_date, product_name,
       rank() over(partition by customer_id order by order_date) rn
from sales s
join menu m on m.product_id = s.product_id
    )
select customer_id, product_name
from case_tablo where rn=1

--A m��terisi ilk �nce curry ve sushi, B m��terisi curry, C m��terisi ramen alm��.

--4.Men�de en �ok sat�n al�nan �r�n hangisidir ve t�m m��teriler taraf�ndan ka� kez sat�n al�nm��t�r?

select top 1 product_name,
       count(s.product_id)
from sales s 
JOIN menu m on m.product_id = s.product_id 
group by product_name
order by 2 desc; 
 --en �ok sat�n al�nan �r�n ramendir ve 8 kez al�nm��t�r.

 --5.Her bir m��teri i�in en pop�ler �r�n hangisidir?

with tablo as(
select customer_id,
       product_name,
       count(s.product_id) total,
	   rank() over(partition by customer_id order by count(s.product_id) desc) as rn
from sales s 
join menu m on m.product_id = s.product_id
group by customer_id,product_name
    )
select customer_id, product_name, total
from tablo where rn=1;

--6.M��teri �ye olduktan sonra ilk olarak hangi �r�n� sat�n ald�?
WITH tablo AS (
    SELECT 
        s.customer_id,
        s.order_date,
        mn.product_name,
        ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS row_num
    FROM 
        sales s
    LEFT JOIN 
        menu mn ON mn.product_id = s.product_id
    LEFT JOIN 
        members m ON m.customer_id = s.customer_id
    WHERE 
        s.order_date >= m.join_date
)
SELECT customer_id, product_name
FROM tablo
WHERE row_num=1
ORDER BY customer_id, order_date;

--A m��terisi �ye olduktan sonra ilk curry, B m��terisi �ye ald�ktan sonra ilk sushi alm��.

--7.M��teri �ye olmadan hemen �nce hangi �r�n sat�n al�nd�?

WITH tablo AS(
SELECT s.customer_id, m.product_name, s.order_date,
       rank() OVER(PARTITION BY s.customer_id order by s.order_date DESC) as rn
FROM sales s
FULL OUTER JOIN members mem on mem.customer_id = s.customer_id
FULL OUTER JOIN menu m on m.product_id = s.product_id
WHERE order_date < join_date
)
SELECT customer_id, product_name
FROM tablo
WHERE rn=1
Order by 1,2;

-- A m��terisi curry ve sushi alm��, B m��terisi sushi alm��.

--8.�ye olmadan �nce her �yenin toplam harcamas� ve kalemleri ne kadard�?
SELECT s.customer_id,
       count(s.product_id),
	   sum(price)
FROM sales s
FULL OUTER JOIN members mem on mem.customer_id = s.customer_id
FULL OUTER JOIN menu m on m.product_id = s.product_id
WHERE order_date < join_date
Group BY s.customer_id
ORDER BY 1,2;

--A m��terisi 2 kalem harcam�� ve toplam harcamas� 25, B m��terisi 3 kalem harcam�� ve toplam harcamas� 40.

--9.Harcad���n�z her 1 dolar 10 puana e�itse ve su�inin 2x puan �arpan� varsa, her m��teri ka� puan kazan�rd�?
WITH tablo AS(
            SELECT customer_id,
                   product_name,
	               price,
	               CASE 
	                 when product_name = 'sushi' then price * 10 * 2
		             else price * 10
		             end points
           FROM sales s 
           join menu m on m.product_id = s.product_id
		   )
SELECT customer_id,
       sum(points)
FROM tablo
GROUP BY customer_id;

--A m��terisi 860, B m��terisi 940, C m��terisi 360 toplam kazanca sahip olur.

--10.M��teri programa kat�ld�ktan sonraki ilk hafta (kat�l�m tarihi dahil) sadece sushide de�il t�m �r�nlerde 2 kat puan kazan�r -
--Ocak ay� sonunda m��teri A ve B'nin ka� puan� vard�r?
WITH tablo AS(
SELECT 
    s.customer_id,
    mem.join_date AS start_date,
    DATEADD(day, 6, mem.join_date) AS end_date,  -- join_date'e 6 g�n ekleniyor
    s.order_date, 
    m.product_name,
    m.price,
    CASE  
        WHEN s.order_date BETWEEN mem.join_date AND DATEADD(day, 6, mem.join_date) THEN m.price * 20
        WHEN m.product_name = 'sushi' THEN m.price * 20
        ELSE m.price * 10 
    END AS points
FROM 
    sales s
JOIN 
    menu m ON m.product_id = s.product_id
JOIN 
    members mem ON mem.customer_id = s.customer_id
WHERE order_date <= '2021-01-31')

SELECT customer_id,
       sum(points)
FROM tablo
GROUP BY customer_id;

-- A m��terisinin 1370 puan�, B m��terisinin 820 puan� olur.