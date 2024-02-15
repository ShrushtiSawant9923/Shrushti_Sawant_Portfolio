ALTER TABLE luxuryloanportfolio
RENAME COLUMN `interest rate` TO interest_rate,
              `ï»¿loan_id` TO loan_id,
              `property value` TO property_value,
              `loan balance` TO `loan_balance`,
              `total past payments` TO total_past_payments,
              `duration years` TO `duration_years`,
              `duration months` TO `duration_months`;


-- For each loan, calculate the percentage of the property value covered by the funded amount. Display loan_id, funded_amount, property_value, and the percentage coverage.
SELECT 
    loan_id, 
    funded_amount, 
    property_value,
    (funded_amount / property_value) * 100 AS percentage_coverage
FROM luxuryloanportfolio;

 -- Find loans where the ratio of total past payments to funded amount is below the average for each purpose. Display loan_id, purpose, and the calculated ratio.
SELECT 
    loan_id, 
    purpose, 
    total_past_payments / funded_amount AS ratio
FROM luxuryloanportfolio
WHERE (total_past_payments / funded_amount) < (SELECT AVG(total_past_payments / funded_amount) FROM luxuryloanportfolio);

 -- Identify loans with the highest outstanding balance relative to the property value. Display loan_id, loan_balance, property_value, and the percentage of the property value represented by the outstanding balance.
SELECT 
    loan_id, 
    loan_balance, 
    property_value,
    (loan_balance / property_value) * 100 AS percentage_outstanding
FROM luxuryloanportfolio
ORDER BY percentage_outstanding DESC
LIMIT 1;

-- Identify loans with a significant increase in payments. Find loans where the total payments in the last month are at least 20% higher than the average total payments. Display loan_id, total_past_payments, and the percentage increase
CREATE TEMPORARY TABLE avg_payments AS 
SELECT 
    loan_id, 
    AVG(payments) AS avg_total_payments 
FROM 
    luxuryloanportfolio 
GROUP BY 
    loan_id;

SELECT 
    l.loan_id, 
    l.total_past_payments, 
    (l.total_past_payments - a.avg_total_payments) / a.avg_total_payments * 100 AS percentage_increase 
FROM 
    luxuryloanportfolio l
JOIN 
    avg_payments a ON l.loan_id = a.loan_id 
WHERE 
    EXTRACT(MONTH FROM l.funded_date) = 12 AND EXTRACT(YEAR FROM l.funded_date) = 2019 
    AND l.funded_date > '2019-11-30' AND l.funded_date <= '2019-12-31' 
    AND (l.total_past_payments - a.avg_total_payments) / a.avg_total_payments * 100 >= 20;

-- Identify loans where the duration is below the overall average duration. Display loan_id, duration_years, and the difference from the average duration.
SELECT 
    loan_id, 
    duration_years,
    duration_years - AVG(duration_years) OVER () AS duration_difference
FROM luxuryloanportfolio
ORDER BY duration_difference;

-- Find loans where the property value is above the average property value for each purpose. Display loan_id, purpose, property_value, and the percentage difference from the average.
SELECT 
    loan_id,
    purpose,
    property_value,
    (property_value - AVG(property_value) OVER (PARTITION BY purpose)) / AVG(property_value) OVER (PARTITION BY purpose) * 100 AS percentage_difference
FROM luxuryloanportfolio
ORDER BY purpose, percentage_difference DESC;

-- Can you provide details on each luxury loan, including borrower names, funded date, duration, total past payments, loan balance, and a bonus amount for loans paid off by at least 80%, with a 5% bonus based on the original loan amount?
SELECT 
    loan_id,
    firstname,
    lastname,
    funded_date,
    duration_years,
    duration_months,
    total_past_payments,
    loan_balance,
    CASE
        WHEN total_past_payments >= (funded_amount * (1 + interest_rate / 100) * (duration_years + duration_months / 12)) THEN 'Paid Off'
        ELSE 'Not Paid Off'
    END AS repayment_status,
    CASE
        WHEN total_past_payments >= (funded_amount * (1 + interest_rate / 100) * (duration_years + duration_months / 12)) THEN
            CASE
                WHEN (total_past_payments / (funded_amount * (1 + interest_rate / 100) * (duration_years + duration_months / 12))) >= 0.8 THEN
                    -- Bonus calculation logic based on the condition (80% of loan paid off)
                    funded_amount * 0.05  -- 5% bonus as an example
                ELSE 0  -- No bonus
            END
        ELSE 0  -- No bonus
    END AS bonus_amount
FROM luxuryloanportfolio;