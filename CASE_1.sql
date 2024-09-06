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

--1.Restoranda her müşterinin harcadığı toplam miktar nedir?

select * from sales s 
JOIN menu m on m.product_id = s.product_id;

select customer_id,
        sum(price)
from sales s 
JOIN menu m on m.product_id = s.product_id
group by customer_id

--A müşterisi 76, B müşterisi 74, C müşterisi 36 harcama yapmıştır.

--2.Her müşteri restoranı kaç gün ziyaret etti?
--MüŞteri aynI gün birden fazla ziyaret edebileceĞi için dıstınct komutu kullandık.
select customer_id,
       count(DISTINCT order_date)
from sales
group by customer_id
--A müşterisi 4 gün, B müşterisi 6 gün, C müşterisi 2 gün ziyaret


--3.Her müşterinin menüden satın aldığı ilk ürün neydi?

with case_tablo as(
select distinct customer_id, order_date, product_name,
       rank() over(partition by customer_id order by order_date) rn
from sales s
join menu m on m.product_id = s.product_id
    )
select customer_id, product_name
from case_tablo where rn=1

--A müşterisi ilk önce curry ve sushi, B müşterisi curry, C müşterisi ramen almış.

--4.Menüde en çok satın alınan ürün hangisidir ve tüm müşteriler tarafından kaç kez satın alınmıştır?

select top 1 product_name,
       count(s.product_id)
from sales s 
JOIN menu m on m.product_id = s.product_id 
group by product_name
order by 2 desc; 
 --en çok satın alınan ürün ramendir ve 8 kez alınmıştır.

 --5.Her bir müşteri için en popüler ürün hangisidir?

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

--6.Müşteri üye olduktan sonra ilk olarak hangi ürünü satın aldı?
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

--A müşterisi üye olduktan sonra ilk curry, B müşterisi üye aldıktan sonra ilk sushi almış.

--7.Müşteri üye olmadan hemen önce hangi ürün satın alındı?

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

-- A müşterisi curry ve sushi almış, B müşterisi sushi almış.

--8.Üye olmadan önce her üyenin toplam harcaması ve kalemleri ne kadardı?
SELECT s.customer_id,
       count(s.product_id),
	   sum(price)
FROM sales s
FULL OUTER JOIN members mem on mem.customer_id = s.customer_id
FULL OUTER JOIN menu m on m.product_id = s.product_id
WHERE order_date < join_date
Group BY s.customer_id
ORDER BY 1,2;

--A müşterisi 2 kalem harcamış ve toplam harcaması 25, B müşterisi 3 kalem harcamış ve toplam harcaması 40.

--9.Harcadığınız her 1 dolar 10 puana eşitse ve sushinin 2x puan çarpanı varsa, her müşteri kaç puan kazanırdı?
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

--A müşterisi 860, B müşterisi 940, C müşterisi 360 toplam kazanca sahip olur.

--10.Müşteri programa katıldıktan sonraki ilk hafta (katılım tarihi dahil) sadece sushide değil tüm ürünlerde 2 kat puan kazanır -
--Ocak ayı sonunda müşteri A ve B'nin kaç puanı vardır?
WITH tablo AS(
SELECT 
    s.customer_id,
    mem.join_date AS start_date,
    DATEADD(day, 6, mem.join_date) AS end_date,  
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

-- A müşterisinin 1370 puanı, B müşterisinin 820 puanı olur.
