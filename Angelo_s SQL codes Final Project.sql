SELECT * FROM competitors
SELECT * FROM corruption_convictions_per_capita
SELECT * FROM health_spending
SELECT * FROM population
SELECT * FROM property_prices
SELECT * FROM state_income

--- create and merge tables with the same column names

CREATE TABLE merged_data AS
SELECT
    c.research_development_spent,
    c.administration,
    c.marketing_spent,
    c.state_usa AS competitors_state_usa,
    c.profit,
    ccp.convictions_per_capita,
    hs.avg_spending,
    hs.min_spending,
    hs.max_spending,
    p.estimate,
    pp.avg_price,
    pp.min_price,
    pp.max_price,
    si.average_income,
    si.minimum_income,
    si.maximum_income
FROM
    competitors AS c
JOIN
    corruption_convictions_per_capita AS ccp
    ON c.state_usa = ccp.state_usa
JOIN
    health_spending AS hs
    ON c.state_usa = hs.state_usa
JOIN
    population AS p
    ON c.state_usa = p.state_usa
JOIN
    property_prices AS pp
    ON c.state_usa = pp.state_usa
JOIN
    state_income AS si
    ON c.state_usa = si.state_usa;
	
--- SET 1 Final Project

---Calculate the percentage of income by state and corruption convictions per capita in relation to the total amount of income by state and corruption convictions per capita. Is there any observable connection between income by state and corruption convictions per capita?
---Identify the states with the highest and lowest average income.
---Identify the states with the highest and lowest corruption conviction rates.

-- 1.
SELECT competitors_state_usa,
       ROUND((SUM(average_income) / (SELECT SUM(average_income) FROM merged_data)) * 100, 2) AS income_percentage,
       ROUND((SUM(convictions_per_capita) / (SELECT SUM(convictions_per_capita) FROM merged_data)) * 100, 2) AS convictions_percentage
FROM merged_data
GROUP BY competitors_state_usa;

-- 2. 
SELECT competitors_state_usa, SUM(average_income) AS total_income
FROM merged_data
GROUP BY competitors_state_usa
ORDER BY total_income DESC
LIMIT 5; -- Highest Average Income

SELECT competitors_state_usa, SUM(average_income) AS total_income
FROM merged_data
GROUP BY competitors_state_usa
ORDER BY total_income ASC
LIMIT 5; -- Lowest Average Income

-- 3.
SELECT competitors_state_usa, ROUND(AVG(convictions_per_capita), 2) AS avg_conviction_rate
FROM merged_data
GROUP BY competitors_state_usa
ORDER BY avg_conviction_rate DESC
LIMIT 5; -- Highest Conviction Rate

SELECT competitors_state_usa, ROUND(AVG(convictions_per_capita), 2) AS avg_conviction_rate
FROM merged_data
GROUP BY competitors_state_usa
ORDER BY avg_conviction_rate ASC
LIMIT 5; -- Lowest Conviction Rate

--- SET 2 Final Project

---Calculate the percentage of property prices and population by state in relation to the total amount of property price and population. Is there any observable connection between property prices and population?
---Identify the states with the highest and lowest average property prices.
---Identify the states with the highest and lowest population.

-- 1.
SELECT competitors_state_usa,
       ROUND((SUM(avg_price) / (SELECT SUM(avg_price) FROM merged_data)) * 100, 2) AS price_percentage,
       ROUND((SUM(estimate) / (SELECT SUM(estimate) FROM merged_data)) * 100, 2) AS population_percentage
FROM merged_data
GROUP BY competitors_state_usa;

-- 2. 
SELECT competitors_state_usa, SUM(avg_price) AS total_avg_price
FROM merged_data
GROUP BY competitors_state_usa
ORDER BY total_avg_price DESC
LIMIT 5; -- Highest Average Property Price


SELECT competitors_state_usa, SUM(avg_price) AS total_avg_price
FROM merged_data
GROUP BY competitors_state_usa
ORDER BY total_avg_price ASC
LIMIT 5; -- Lowest Average Property Price

-- 3.
SELECT competitors_state_usa, SUM(estimate) AS total_population
FROM merged_data
GROUP BY competitors_state_usa
ORDER BY total_population DESC
LIMIT 5; -- Highest population

SELECT competitors_state_usa, SUM(estimate) AS total_population
FROM merged_data
GROUP BY competitors_state_usa
ORDER BY total_population ASC
LIMIT 5; -- Lowest population

--- SET 3 Final Project

---Calculate the percentage of healthcare spending and competitor spending by state in relation to the total amount of healthcare spending and competitor spending. Is there any observable connection between healthcare spending and competitor spending?
---Identify the states with the highest and lowest average healthcare spending.
---Identify the states with the highest and lowest competitor spending.

-- 1. 
SELECT competitors_state_usa,
       ROUND((sum(avg_spending) / total_healthcare_spending) * 100, 2) AS healthcare_spending_percentage,
       ROUND((sum(avg_spending) / total_competitor_spending) * 100, 2) AS competitor_spending_percentage
FROM merged_data
CROSS JOIN (
    SELECT sum(avg_spending) AS total_healthcare_spending,
           sum(research_development_spent + administration + marketing_spent) AS total_competitor_spending
    FROM merged_data
) totals
GROUP BY competitors_state_usa, total_healthcare_spending, total_competitor_spending;

-- 2.
SELECT competitors_state_usa, SUM(avg_spending) AS total_avg_spending
FROM merged_data
GROUP BY competitors_state_usa
ORDER BY total_avg_spending DESC
LIMIT 5; -- Highest Healthcare Spending

SELECT competitors_state_usa, SUM(avg_spending) AS total_avg_spending
FROM merged_data
GROUP BY competitors_state_usa
ORDER BY total_avg_spending ASC
LIMIT 5; -- Lowest Healthcare Spending

-- 3.
SELECT competitors_state_usa, 
       ROUND(SUM(research_development_spent + administration + marketing_spent), 2) AS total_competitor_spending
FROM merged_data
GROUP BY competitors_state_usa
ORDER BY total_competitor_spending DESC
LIMIT 5; -- Highest Competitor Spending

SELECT competitors_state_usa, 
       ROUND(SUM(research_development_spent + administration + marketing_spent), 2) AS total_competitor_spending
FROM merged_data
GROUP BY competitors_state_usa
ORDER BY total_competitor_spending ASC
LIMIT 5; -- Lowest Competitor Spending

--- SET 4 Final Project	
	
---Find the top 5 states with the total highest health spending based on the average and population.
---Find the top 5 states with the total lowest health spending based on the average and population.
---Join the competitor dataset with the health spending dataset to see if there is any correlation between health spending per state and profit.	

-- 1. 
SELECT competitors_state_usa, ROUND(SUM(avg_spending * estimate), 0) AS total_health_spending
FROM merged_data
GROUP BY competitors_state_usa
ORDER BY total_health_spending DESC
LIMIT 5;

-- 2.
SELECT competitors_state_usa, ROUND(SUM(avg_spending * estimate), 0) AS total_health_spending
FROM merged_data
GROUP BY competitors_state_usa
ORDER BY total_health_spending ASC
LIMIT 5;

-- 3.
SELECT
    competitors.state_usa,
    SUM(competitors.profit) AS total_profit,
    SUM(health_spending.avg_spending) AS total_avg_spending
FROM
    competitors
JOIN
    health_spending
    ON competitors.state_usa = health_spending.state_usa
GROUP BY
    competitors.state_usa;
	
--- SET 5 Final Project

---Find the top 5 states with the highest income per capita.
---Calculate the average income for each state and rank them by their income.
---Join the competitor dataset with the population dataset to see if there is any correlation between population and profit.

-- 1.
SELECT competitors_state_usa, SUM(average_income) AS total_income
FROM merged_data
GROUP BY competitors_state_usa
ORDER BY total_income DESC
LIMIT 5;

-- 2.
SELECT competitors_state_usa, ROUND(SUM(average_income)) AS avg_income
FROM merged_data
GROUP BY competitors_state_usa
ORDER BY avg_income DESC;

-- 3.
SELECT
    competitors.state_usa,
    SUM(competitors.profit) AS total_profit,
    SUM(population.estimate) AS total_estimate
FROM
    competitors
JOIN
    population
    ON competitors.state_usa = population.state_usa
GROUP BY
    competitors.state_usa;
	
--- SET 6 Final Project

---Calculate the total profit, research & development expenditure, administration expenditure, and marketing expenditure for each state.
---Rank the states based on their total profit and identify the top 5 states.
---Calculate the average health spending, property prices, state income, and population for the top 5 states and compare them.

-- 1.
SELECT
    competitors_state_usa AS state,
    ROUND(SUM(profit)) AS total_profit,
    ROUND(SUM(research_development_spent)) AS total_rnd_expenditure,
    ROUND(SUM(administration)) AS total_admin_expenditure,
    ROUND(SUM(marketing_spent)) AS total_marketing_expenditure
FROM
    merged_data
GROUP BY
    state;
	
-- 2.
SELECT competitors_state_usa, ROUND(SUM(profit)) AS total_profit
FROM merged_data
GROUP BY competitors_state_usa
ORDER BY total_profit DESC
LIMIT 5;

-- 3.
SELECT competitors_state_usa,
       ROUND(AVG(avg_spending), 2) AS avg_health_spending,
       ROUND(AVG(avg_price), 2) AS avg_property_price,
       ROUND(AVG(average_income), 2) AS avg_state_income,
       ROUND(SUM(estimate)) AS total_population
FROM merged_data
GROUP BY competitors_state_usa
ORDER BY total_population DESC
LIMIT 5;