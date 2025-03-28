create database project5_freelance;

SELECT * FROM freelance;

-- Basic Level (1-5)

-- What is the total number of jobs completed in the dataset?

SELECT 
    COUNT(job_completed) AS total_completed_jobs
FROM
    freelance;
    
    

-- What is the average earnings per job across the entire dataset?

SELECT 
    job_category, ROUND(AVG(earnings_usd), 0) AS AVG_earnings
FROM
    freelance
GROUP BY job_category
ORDER BY AVG_earnings DESC;



-- How many unique job categories are there, and what are their names?

SELECT DISTINCT
    (job_category) AS unique_categories
FROM
    freelance;
    
    

-- What is the average client rating for each job category?

SELECT 
    job_category, ROUND(AVG(client_rating), 2) AS avg_rating
FROM
    freelance
GROUP BY job_category
ORDER BY avg_rating DESC;



-- How many projects were fixed-price and how many were hourly?

SELECT 
    project_type, COUNT(project_type) AS count
FROM
    freelance
GROUP BY project_type;


-- Intermediate Level (6-10)



-- What is the total earnings generated from each platform?

SELECT 
    platform, SUM(earnings_usd) AS total_earnings
FROM
    freelance
GROUP BY platform;



-- Which job category has the highest average hourly rate?

SELECT 
    job_category, ROUND(AVG(hourly_rate),2) AS avg_hourly_rate
FROM
    freelance
GROUP BY job_category
ORDER BY avg_hourly_rate DESC
LIMIT 1;



-- What is the most common experience level among freelancers?

SELECT 
    experience_level
FROM
    (SELECT 
        experience_level, COUNT(experience_level) AS count
    FROM
        freelance
    GROUP BY experience_level) AS t
ORDER BY count DESC
LIMIT 1;



-- Which client region has the highest total earnings, and how does it compare to other regions?

SELECT 
    client_region, SUM(earnings_usd) AS total_earnings
FROM
    freelance
GROUP BY client_region
ORDER BY total_earnings DESC
LIMIT 1;



-- What is the average job success rate across different platforms?

SELECT platform, ROUND(avg(job_success_rate), 2) as avg_success_rate
FROM freelance
GROUP BY platform;


-- Advance level


-- Find the top 3 highest-earning freelancers in each job category, including their earnings, platform, and experience level.

with cte as 
	(SELECT freelancer_id, job_category, platform, earnings_usd, experience_level, RANK() OVER(partition by job_category ORDER by earnings_usd DESC) as rnk
	FROM freelance)
SELECT 
    freelancer_id,
    job_category,
    platform,
    earnings_usd,
    experience_level
FROM
    cte
WHERE
    rnk = 1;
    
    
    
-- Calculate the average earnings per platform and compare it to the overall average earnings. Show the difference for each platform.

with avg_platform_earnings as (SELECT platform, avg(earnings_usd) as avg_earnings
FROM freelance
GROUP BY platform),
total_avg_earnings as (SELECT distinct(platform),avg(earnings_usd) over() as overall_earnings
FROM freelance)
SELECT 
    p.platform,
    p.avg_earnings,
    t.overall_earnings,
    (p.avg_earnings - t.overall_earnings) AS difference
FROM
    avg_platform_earnings AS p
        JOIN
    total_avg_earnings AS t USING (platform);
    
    
    
-- Rank freelancers within each platform based on their job success rate. Find top 5 freelancers within each platform.

SELECT 
	freelancer_id, 
    platform,
    job_success_rate, 
    ranking
FROM 
	( SELECT 
			freelancer_id, 
            platform,
            job_success_rate, 
            dense_rank() OVER(partition by platform ORDER BY job_success_rate DESC) as ranking
	FROM freelance) as t
WHERE ranking <= 5;



-- Find the client region with the highest total earnings, and calculate the percentage contribution of that region to the overall earnings.

with region_earnings as
		(SELECT 
			client_region, 
			sum(earnings_usd) as total_earnings
		FROM 
			freelance
		GROUP BY 
			client_region)
SELECT 
	client_region, 
	total_earnings,
    ROUND((total_earnings/ sum(total_earnings) OVER())* 100,2) as percent_contribution
FROM 
	region_earnings
GROUP BY 
	client_region, 
    total_earnings
ORDER BY 
	percent_contribution DESC;
    
    
    
-- Find the top 5 freelancers in each experience level (Beginner, Intermediate, Expert) based on total earnings.

SELECT 
	freelancer_id, 
    experience_level,
    earnings_usd , 
    ranking
FROM
	(SELECT 
			freelancer_id,
            experience_level,
            earnings_usd, 
            rank() OVER(partition by experience_level order by earnings_usd DESC) as ranking
	FROM freelance) as t
where ranking <= 5;








