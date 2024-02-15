-- For top 3 states/cities with highest loan balance, determine the average loan balance and total number of clients with loan balance greater than cities average loan balance.

WITH ClientSummary AS (
    SELECT
        cd.state_name,
        COUNT(cc.first) AS total_clients,
        ROUND(AVG(cl.amount), 0) AS average_amount
    FROM
        completedloan cl
    JOIN
        completedacct ca ON cl.account_id = ca.account_id
    JOIN
        completeddistrict cd ON ca.district_id = cd.district_id
    JOIN
        completeddisposition cdd ON cdd.account_id = cl.account_id
    JOIN
        completedclient cc ON cc.client_id = cdd.client_id
	Where cd.state_name = "New York" 
    GROUP BY
        cd.state_name

)

SELECT
    cc.first,
    cd.state_name,
    SUM(cl.amount) AS total_amount
FROM
    completedloan cl
JOIN
    completedacct ca ON cl.account_id = ca.account_id
JOIN
    completeddistrict cd ON ca.district_id = cd.district_id
JOIN
    completeddisposition cdd ON cdd.account_id = cl.account_id
JOIN
    completedclient cc ON cc.client_id = cdd.client_id
GROUP BY
    cc.first, cd.state_name
HAVING
    SUM(cl.amount) > (SELECT average_amount FROM ClientSummary WHERE state_name = cd.state_name);
    
    
-- In newyork state, find whether transactions of Insurance is higher or Loan is higher 

With tt as (SELECT
    cd.state_name,
    ct.k_symbol,
    COUNT(cc.first) AS total_clients
from completedtransac ct 
    JOIN
        completedacct ca ON ct.account_id = ca.account_id
    JOIN
        completeddistrict cd ON ca.district_id = cd.district_id
    JOIN
        completeddisposition cdd ON cdd.account_id = ct.account_id
    JOIN
        completedclient cc ON cc.client_id = cdd.client_id
WHERE
    cd.state_name = 'New York'
GROUP BY
    cd.state_name, ct.k_symbol)
Select total_clients, k_symbol from tt where k_symbol = "Loan Payment" or "Insurance Payment";

-- find the day of the week with the maximum total transactions for each bank
SELECT
    dayname(fulldate) AS day_of_week,
    COUNT(*) AS total_transactions
FROM
    completedtransac
GROUP BY
    day_of_week
ORDER BY
    day_of_week;
    
WITH day_table AS (
    SELECT
        dayname(fulldate) AS day_of_week,
        bank,
        COUNT(*) AS total_transactions
    FROM
        completedtransac
    GROUP BY
        bank, day_of_week
    ORDER BY
        day_of_week
)

SELECT
    day_of_week,
    bank,
    total_transactions AS t_o_t
FROM (
    SELECT
        day_of_week,
        bank,
        total_transactions,
        ROW_NUMBER() OVER (PARTITION BY bank ORDER BY total_transactions DESC) AS row_num
    FROM
        day_table
) AS ranked
WHERE
    row_num = 1;

-- which client have highest number of loans
select count(ï»¿loan_id) as d, concat(firstname, lastname) as fullname, social from luxuryloanportfolio
group by social, fullname
order by d desc
limit 10;

-- 
select crmc.Complaint ID, from crm_events crme right join crm_call_center_logs crmc on crme.Complaint ID = crmc.Complaint ID;

-- retrieve total num of transactions and average amount for each month, considering only transactions in last 6 months

WITH RecentTransactions AS (
    SELECT
        EXTRACT(MONTH FROM fulldate) AS month,
        EXTRACT(YEAR FROM fulldate) AS year,
        amount
    FROM
        completedtransac
    WHERE
        fulldate >= DATE_SUB(DATE '2018-07-01', INTERVAL 6 MONTH))
SELECT
    RecentTransactions.month,
    RecentTransactions.year,
    COUNT(ctt.transaction_id) AS total_transactions,
    AVG(amount) AS average_transaction_amount
FROM
    RecentTransactions, completedtransac ctt
GROUP BY
    year, month
ORDER BY
    year, month;
    
-- 