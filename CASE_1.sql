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

--1.Restoranda her müþterinin harcadýðý toplam miktar nedir?

select * from sales s 
JOIN menu m on m.product_id = s.product_id;

select customer_id,
        sum(price)
from sales s 
JOIN menu m on m.product_id = s.product_id
group by customer_id

--A müþterisi 76, B müþterisi 74, C müþterisi 36 harcama yapmýþtýr.

--2.Her müþteri restoraný kaç gün ziyaret etti?
--Müþteri ayný gün birden fazla ziyaret edebileceði için dýstýnct komutu kullandýk.
select customer_id,
       count(DISTINCT order_date)
from sales
group by customer_id
--A müþterisi 4 gün, B müþterisi 6 gün, C müþterisi 2 gün ziyaret


--3.Her müþterinin menüden satýn aldýðý ilk ürün neydi?

with case_tablo as(
select distinct customer_id, order_date, product_name,
       rank() over(partition by customer_id order by order_date) rn
from sales s
join menu m on m.product_id = s.product_id
    )
select customer_id, product_name
from case_tablo where rn=1

--A müþterisi ilk önce curry ve sushi, B müþterisi curry, C müþterisi ramen almýþ.

--4.Menüde en çok satýn alýnan ürün hangisidir ve tüm müþteriler tarafýndan kaç kez satýn alýnmýþtýr?

select top 1 product_name,
       count(s.product_id)
from sales s 
JOIN menu m on m.product_id = s.product_id 
group by product_name
order by 2 desc; 
 --en çok satýn alýnan ürün ramendir ve 8 kez alýnmýþtýr.

 --5.Her bir müþteri için en popüler ürün hangisidir?

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

--6.Müþteri üye olduktan sonra ilk olarak hangi ürünü satýn aldý?
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

--A müþterisi üye olduktan sonra ilk curry, B müþterisi üye aldýktan sonra ilk sushi almýþ.

--7.Müþteri üye olmadan hemen önce hangi ürün satýn alýndý?

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

-- A müþterisi curry ve sushi almýþ, B müþterisi sushi almýþ.

--8.Üye olmadan önce her üyenin toplam harcamasý ve kalemleri ne kadardý?
SELECT s.customer_id,
       count(s.product_id),
	   sum(price)
FROM sales s
FULL OUTER JOIN members mem on mem.customer_id = s.customer_id
FULL OUTER JOIN menu m on m.product_id = s.product_id
WHERE order_date < join_date
Group BY s.customer_id
ORDER BY 1,2;

--A müþterisi 2 kalem harcamýþ ve toplam harcamasý 25, B müþterisi 3 kalem harcamýþ ve toplam harcamasý 40.

--9.Harcadýðýnýz her 1 dolar 10 puana eþitse ve suþinin 2x puan çarpaný varsa, her müþteri kaç puan kazanýrdý?
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

--A müþterisi 860, B müþterisi 940, C müþterisi 360 toplam kazanca sahip olur.

--10.Müþteri programa katýldýktan sonraki ilk hafta (katýlým tarihi dahil) sadece sushide deðil tüm ürünlerde 2 kat puan kazanýr -
--Ocak ayý sonunda müþteri A ve B'nin kaç puaný vardýr?
WITH tablo AS(
SELECT 
    s.customer_id,
    mem.join_date AS start_date,
    DATEADD(day, 6, mem.join_date) AS end_date,  -- join_date'e 6 gün ekleniyor
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

-- A müþterisinin 1370 puaný, B müþterisinin 820 puaný olur.