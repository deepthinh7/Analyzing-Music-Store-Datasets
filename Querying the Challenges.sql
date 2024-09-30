
/* Q1: Who is the senior most employee based on job title? */

with cte as(SELECT *,rank() over( order by levels desc) as rk
  FROM [test1].[dbo].[employee])
  select * from cte where rk=1

/* Q2: Which countries have the most Invoices? */

select billing_country,count(invoice_id) from invoice
group by billing_country
order by count(invoice_id) desc

/* Q3: What are the three largest amounts for the total invoice? */

select top 3 * from invoice
order by total desc 

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

select a.city,sum(total) from customer a
left join  invoice b on a.customer_id=b.customer_id
group by a.city 
order by sum(total) desc

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

select a.customer_id,sum(total) from customer a
left join invoice b on a.customer_id=b.customer_id
group by a.customer_id
order by sum(total) desc


/* Q6: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

--method 1

select distinct a.email,a.first_name,a.last_name,e.name from customer a
left join invoice b on a.customer_id=b.customer_id
left join  invoice_line c on b.invoice_id=c.invoice_id
left join track d on c.track_id=d.track_id
left join genre e on d.genre_id =e.genre_id
where e.name ='Rock'
order by a.email asc

----method 2

SELECT DISTINCT email,first_name, last_name
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN(
	SELECT track_id FROM track
	JOIN genre ON track.genre_id = genre.genre_id
	WHERE genre.name LIKE 'Rock'
)
ORDER BY email;

--method 3

with cte as (select  a.email,a.first_name,a.last_name,e.name from customer a
left join invoice b on a.customer_id=b.customer_id
left join  invoice_line c on b.invoice_id=c.invoice_id
left join track d on c.track_id=d.track_id
left join genre e on d.genre_id =e.genre_id)
select distinct email,first_name,last_name from cte 
where name='Rock'

/* Q7: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */


    SELECT  top 10 a.artist_id,count(c.track_id) as ct_
    FROM artist a
     JOIN album b ON a.artist_id = b.artist_id
     JOIN track c ON c.album_id = b.album_id
     JOIN genre d ON d.genre_id = c.genre_id
where d.name='Rock'
group by a.artist_id
Order by ct_ desc 

/* Q8: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */
 
select name,milliseconds from track a
where milliseconds > (select AVG(milliseconds) FROM track)
order by milliseconds desc

/* Q9: Find how much amount spent by each customer on artists? Write a query to return customer name, 
artist name and total spent */

WITH best_selling_artist AS (
    SELECT artist.artist_id AS artist_id, artist.name AS artist_name, 
           SUM(invoice_line.unit_price * invoice_line.quantity) AS total_sales
    FROM invoice_line
    JOIN track ON track.track_id = invoice_line.track_id
    JOIN album ON album.album_id = track.album_id
    JOIN artist ON artist.artist_id = album.artist_id
    GROUP BY artist.artist_id, artist.name
    ORDER BY total_sales DESC
    -- Use TOP 1 instead of LIMIT 1
    OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, 
       SUM(il.unit_price * il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY c.customer_id, c.first_name, c.last_name, bsa.artist_name
ORDER BY amount_spent DESC;

