use sakila;

-- * 1a. Display the first and last names of all actors from the table `actor`.
select first_name, last_name 
from actor 
limit 10;

-- * 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
SELECT UPPER(CONCAT(first_name, ' ', last_name)) AS Actor_Name 
FROM actor 
LIMIT 10;


-- * 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe."  What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name 
FROM actor 
WHERE first_name = 'Joe';

-- * 2b. Find all actors whose last name contain the letters `GEN`:
select first_name, last_name 
from actor 
where last_name like "%GEN%";

-- * 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
select first_name, last_name 
from actor 
where last_name like "%LI%" 
order by last_name, first_name;


-- * 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country 
from country 
where country in ("Afghanistan", "Bangladesh", "China");


-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
alter table actor 
add description blob after last_name;


-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
alter table actor 
drop description;


-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name, count(1) as last_name_count 
from actor 
group by last_name 
order by last_name_count desc;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors.

select L_Name.last_name, L_Name.last_name_count from
(select last_name, count(last_name) as last_name_count
from actor
group by last_name) L_Name
having L_Name.last_name_count >= 2;

-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.

update actor
set first_name = "HARPO"
where first_name = "GROUCHO"
and last_name = "WILLIAMS";

-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.

update actor
set first_name = "GROUCHO"
where first_name = "HARPO";

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?

describe address;
show create table address;

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member.  Use the tables `staff` and `address`:

select st.first_name, st.last_name, addr.address 
from staff st
join address addr
on st.address_id = addr.address_id;


-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005.  Use tables `staff` and `payment`.

select first_name, count(amount_rung) from
(select st.first_name as first_name, st.last_name as last_name, pay.amount as amount_rung, pay.payment_date as pay_date 
from staff st
join payment pay
on st.staff_id = pay.staff_id
and pay.payment_date >= str_to_date("August 01 2005", "%M %d %Y")
and pay.payment_date <= str_to_date("August 31 2005", "%M %d %Y")) st_pmt 
group by st_pmt.first_name
order by st_pmt.first_name;


-- 6c. List each film and the number of actors who are listed for that film.  Use tables `film_actor` and `film`. Use inner join.

select title, count(actor_id) as total_actors from 
(select flm.title as title, act.actor_id as actor_id from film flm
join film_actor act
on flm.film_id = act.film_id) film_act_map
group by title
order by total_actors desc;


-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?

select count(*) as film_inventory_count 
from inventory 
where film_id in (select film_id 
					from film 
                    where title = "Hunchback Impossible");


-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:

select first_name, last_name, sum(amt_paid) from
(select cust.first_name as first_name, cust.last_name as last_name, pmt.amount as amt_paid 
from customer cust
join payment pmt
on cust.customer_id = pmt.customer_id) cust_name_payment
group by last_name, first_name
order by last_name asc;


-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
select * 
from film 
where (title like "K%" or title like "Q%") 
and language_id in (select language_id from language where name = "English");


-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
select first_name, last_name 
from actor 
where actor_id in 
	(select actor_id 
    from film_actor 
    where film_id in 
		(select film_id 
		from film 
        where title = "Alone Trip"));

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.

select cust.first_name as first_name, cust.last_name as last_name, cust.email as e_mail
from city ct 
join country cnt on ct.country_id = cnt.country_id 
join address addr on ct.city_id = addr.city_id
join customer cust on cust.address_id = addr.address_id
and cnt.country = "Canada";


-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.

select flm.film_id, flm.title, cat.name as category, flm.rental_rate
from film_category flm_cat
join category cat on cat.category_id = flm_cat.category_id
join film flm on flm.film_id = flm_cat.film_id
and cat.name = "Family";

 -- 7e. Display the most frequently rented movies in descending order.
  select title, count(title) as rental_count from (
 select flm.film_id, flm.title, rnt.rental_id
 from film flm
 join inventory invnt on flm.film_id = invnt.inventory_id
 join rental rnt on rnt.inventory_id = invnt.inventory_id
 order by title) A
 group by title 
 order by rental_count desc;
 
-- 7f. Write a query to display how much business, in dollars, each store brought in.
select str.store_id, concat('$', sales.sales_amt) as total_sales, addr.address from
(select pmt.staff_id, sum(pmt.amount) as sales_amt 
from payment pmt 
group by pmt.staff_id 
order by sales_amt desc) sales 
join store str on str.manager_staff_id = sales.staff_id
join address addr on addr.address_id = str.address_id;


-- 7g. Write a query to display for each store its store ID, city, and country.
select str.store_id, cty.city, cnt.country From store str
join address addr on addr.address_id = str.address_id
join city cty on cty.city_id = addr.address_id
join country cnt on cnt.country_id = cty.country_id;


-- 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

select genre, sum(amount) as total_amount from 
(select cat.name as genre, pmnt.amount as amount from category cat
join film_category flm_cat on flm_Cat.category_id = cat.category_id
join inventory invnt on invnt.film_id = flm_cat.film_id
join rental rntl on rntl.inventory_id = invnt.inventory_id
join payment pmnt on pmnt.rental_id = rntl.rental_id) A
group by genre
order by total_amount desc limit 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

create view top_five_genres as
select genre, sum(amount) as total_amount from 
(select cat.name as genre, pmnt.amount as amount from category cat
join film_category flm_cat on flm_Cat.category_id = cat.category_id
join inventory invnt on invnt.film_id = flm_cat.film_id
join rental rntl on rntl.inventory_id = invnt.inventory_id
join payment pmnt on pmnt.rental_id = rntl.rental_id) A
group by genre
order by total_amount desc limit 5;

-- 8b. How would you display the view that you created in 8a?
select * from top_five_genres;


-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
drop view top_five_genres;