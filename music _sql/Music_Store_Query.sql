-- Q1: who is the semior most employee based on the job title?
	
-- select * from employee
-- order by levels desc
-- limit 1 

-- Q2: Which countries have the most Invoices?
-- select count(*) as c, billing_country from invoice
-- group by billing_country
-- order by c desc 

/* Q3: What are top 3 values of total invoice? */
-- select total from invoice
-- order by total desc 
-- limit 3

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

-- select sum(total) as invoice_total, billing_city from invoice
-- group by billing_city
-- order by invoice_total desc	

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

-- select * from customer
-- select * from invoice 
-- select c.customer_id, c.first_name, c.last_name, sum(total) as total_spending
-- from customer as c
-- join invoice as i on c.customer_id = i.customer_id
-- group by c.customer_id
-- order by total_spending desc 
-- limit 1

/* Question Set 2 - Moderate */

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

-- Method 1

-- select DISTINCT c.email,c.first_name,c.last_name,g.name
-- from customer as c 
-- join invoice as i on c.customer_id = i.customer_id
-- join invoice_line as n on n.invoice_id = i.invoice_id
-- join track as t on t.track_id = n.track_id
-- join genre as g on g.genre_id = t.genre_id
-- where g.name like 'Rock'
-- order by c.email

-- Method 2
-- select DISTINCT c.email,c.first_name,c.last_name
-- from customer as c 
-- join invoice as i on c.customer_id = i.customer_id
-- join invoice_line as n on n.invoice_id = i.invoice_id
-- where n.track_id in(
-- 	select t.track_id from track as t
-- 	join genre as g on g.genre_id = t.genre_id
-- 	where g.name Like 'Rock'
-- 	)order by c.email
    
/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

-- select a.name,a.artist_id,count(a.artist_id) as no_of_songs from artist as a
-- join album as al on al.artist_id = a.artist_id
-- join track as t on t.album_id = al.album_id
-- join genre as g on g.genre_id = t.genre_id
-- where g.name like 'Rock'
-- group by a.artist_id
-- order by no_of_songs desc
-- limit 10

/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

-- select name,Milliseconds 
-- from track
-- where Milliseconds >(
-- select avg(Milliseconds) AS avg_track_length 
-- from track)
-- order by Milliseconds desc

/* Question Set 3 - Advance */

/* Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

/* Steps to Solve: First, find which artist has earned the most according to the InvoiceLines. Now use this artist to find 
which customer spent the most on this artist. For this query, you will need to use the Invoice, InvoiceLine, Track, Customer, 
Album, and Artist tables. Note, this one is tricky because the Total spent in the Invoice table might not be on a single product, 
so you need to use the InvoiceLine table to find out how many of each product was purchased, and then multiply this by the price
for each artist. */
-- select c.customer_id,c.first_name , c.last_name, a.name, sum(n.unit_price*n.quantity) as total_spent
-- from customer as c 
-- join invoice as i on c.customer_id = i.customer_id 
-- join invoice_line as n on n.invoice_id = i.invoice_id
-- join track as t on t.track_id = n.track_id
-- join album as al on al.album_id = t.album_id
-- join artist as a on a.artist_id = al.artist_id
-- group by c.customer_id,c.first_name , c.last_name, a.name, n.unit_price
-- order by total_spent desc
-- second 2 method

-- with best_selling_price as(
--     select a.artist_id , a.name ,
--     sum(n.unit_price*n.quantity) as total_spent
--     from invoice_line as n 
--     join invoice as i on n.invoice_id = i.invoice_id
--     join track as t on t.track_id = n.track_id	
--     join album as al on al.album_id = t.album_id
--     join artist as a on a.artist_id = al.artist_id
--     group by a.artist_id , a.name
--     order by total_spent desc
--     limit 1
-- 	)
-- select c.customer_id,c.first_name , c.last_name, a.name, sum(n.unit_price*n.quantity) as total_spent
-- from customer as c 
-- join invoice as i on c.customer_id = i.customer_id 
-- join invoice_line as n on n.invoice_id = i.invoice_id
-- join track as t on t.track_id = n.track_id
-- join album as al on al.album_id = t.album_id
-- join artist as a on a.artist_id = al.artist_id
-- join best_selling_price as bsa on bsa.artist_id = al.artist_id
-- group by c.customer_id,c.first_name , c.last_name, a.name, n.unit_price
-- order by total_spent desc

/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

/* Steps to Solve:  There are two parts in question- first most popular music genre and second need data at country level. */

-- WITH popular_genre AS(
-- 	select count(n.quantity) as purchases, c.country,g.genre_id, g.name,
--            row_number() over(partition by c.country order by count(n.quantity) desc) as RowNo
--     from invoice_line as n 
--     join invoice as i on i.invoice_id = n.invoice_id
--     join customer as c on c.customer_id = i.customer_id
--     join track as t on t.track_id = n.track_id
--     JOIN genre as g ON g.genre_id = t.genre_id
--     group by c.country,g.genre_id, g.name
-- )
-- select * from popular_genre where RowNo <=1

/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

/* Steps to Solve:  Similar to the above question. There are two parts in question- 
first find the most spent on music for each country and second filter the data for respective customers. */

-- WITH Customter_with_country AS (
-- 		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
-- 	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
-- 		FROM invoice
-- 		JOIN customer ON customer.customer_id = invoice.customer_id
-- 		GROUP BY 1,2,3,4
-- 		ORDER BY 4 ASC,5 DESC)
-- SELECT * FROM Customter_with_country WHERE RowNo <= 1


