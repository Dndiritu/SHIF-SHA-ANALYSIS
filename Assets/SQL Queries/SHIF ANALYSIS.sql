Create Database Social_Health_Insurance;

use Social_Health_Insurance;
------since the Data is derived form CSV files, we create connections between tables using CSV files.
-- Add foreign key to Contributions
ALTER TABLE Contributions
ADD CONSTRAINT fk_contributions_member
FOREIGN KEY (member_id)
REFERENCES Members(member_id)
ON DELETE CASCADE;

-- Add foreign keys to Healthcare_Services
ALTER TABLE Healthcare_Services
DROP CONSTRAINT fk_services_membeR;
ALTER TABLE Healthcare_Services
ADD CONSTRAINT fk_services_member
FOREIGN KEY (member_id)
REFERENCES Members(member_id)
;
ALTER TABLE Healthcare_Services
DROP CONSTRAINT fk_services_provider;

ALTER TABLE Healthcare_Services
ADD CONSTRAINT fk_services_provider
FOREIGN KEY (provider_id)
REFERENCES Providers(provider_id)
;

-- Add foreign keys to Claims
ALTER TABLE Claims
ADD CONSTRAINT fk_claims_provider
FOREIGN KEY (provider_id)
;

ALTER TABLE Claims
ADD CONSTRAINT fk_claims_service
FOREIGN KEY (service_id)
REFERENCES Healthcare_Services(service_id)
;

-- Add foreign key to Surveys
ALTER TABLE Surveys
ADD CONSTRAINT fk_surveys_member
FOREIGN KEY (member_id)
REFERENCES Members(member_id)
;
SELECT *
FROM Contributions c
LEFT JOIN Members m ON c.member_id = m.member_id
WHERE m.member_id IS NULL;

--What is the distribution of members by income level and employment status?

SELECT income_level,
       employment_status,
       COUNT(*) AS member_distribution
FROM 
    Members
GROUP BY 
    income_level, 
    employment_status
ORDER BY 
    income_level, 
    employment_status;

select Distinct member_id from Contributions;

WITH IncomeEmploymentDistribution AS (
    SELECT
        income_level,
        employment_status,
        COUNT(*) AS member_count
    FROM
        members
    WHERE
        income_level IN ('High','middle','low')
        AND employment_status IN ('Employed', 'Unemployed', 'Self-Employed')
    GROUP BY
        income_level,
        employment_status
)

SELECT
    income_level,
    employment_status,
    member_count,
    RANK() OVER (PARTITION BY income_level ORDER BY member_count DESC) AS rank_within_income
FROM
    IncomeEmploymentDistribution
ORDER BY
  income_level,
  rank_within_income;

	----How many members are subsidized versus non-subsidized across different regions?
SELECT is_subsidized,
		region, COUNT(*) AS member_count,
		RANK() OVER (PARTITION BY is_subsidized ORDER BY member_count DESC) AS rank_within_income
       
FROM 
    Members

ORDER BY 
    member_count;
----Subquery using rank-----
SELECT 
    is_subsidized,
    region,
    member_count,
    RANK() OVER (PARTITION BY is_subsidized ORDER BY member_count DESC) AS rank_within_subsidy
FROM (
    SELECT 
        is_subsidized,
        region,
        COUNT(*) AS member_count
    FROM 
        Members
    GROUP BY 
        is_subsidized, region
) AS sub
ORDER BY 
    is_subsidized;


select Distinct region from Members;
----using case when ----
SELECT 
    region,
    CASE 
        WHEN is_subsidized = 1 THEN 'True'
        ELSE 'False'
    END AS Is_subsidized,
    COUNT(*) AS countmembers
FROM 
    Members
GROUP BY 
    region,
    CASE 
        WHEN is_subsidized = 1 THEN 'True'
        ELSE 'False'
    END
	order by 
	region;
--------
SELECT 
    region,
    COUNT(CASE WHEN is_subsidized = 1 THEN 1 END) AS subsidized_members,
    COUNT(CASE WHEN is_subsidized = 0 THEN 1 END) AS non_subsidized_members
FROM 
    Members
GROUP BY 
    region;

 with AgeByRegion as (
select 
    region,
    avg(age) as Average_Age
from Members
group by region
)
select 
region,
Average_Age
from AgeByRegion
group by region, Average_Age;
------------------Calculate the total contributions received monthly-----
select contribution_date from Contributions;
CREATE TABLE #Temp_Monthly_Contributions (
    Year INT,
    Month INT,
    total_amount DECIMAL(10,2)
);

INSERT INTO #Temp_Monthly_Contributions (year, month, total_amount)
SELECT 
    YEAR(contribution_date) AS year,
    MONTH(contribution_date) AS month,
    SUM(contribution_amount) AS Total_amount
FROM 
    Contributions
WHERE 
    contribution_date IS NOT NULL 
    AND contribution_amount IS NOT NULL
GROUP BY 
    YEAR(contribution_date),
    MONTH(contribution_date);

SELECT 
    CONCAT(year, '-', FORMAT(DATEFROMPARTS(year, month, 1), 'MMM')) AS year_month,
    total_amount AS monthly_total
FROM 
    #Temp_Monthly_Contributions
ORDER BY 
    year, 
    month;

DROP TABLE #Temp_Monthly_Contributions;
---------using temp table ------
 WITH MonthlyContributions AS (
    SELECT 
        YEAR(contribution_date) AS year,
        MONTH(contribution_date) AS month,
        SUM(contribution_amount) AS total_amount
    FROM 
        Contributions
    WHERE 
        contribution_date IS NOT NULL 
        AND contribution_amount IS NOT NULL
    GROUP BY 
        YEAR(contribution_date),
        MONTH(contribution_date)
)
SELECT 
    CONCAT(year, '-', FORMAT(DATEFROMPARTS(year, month, 1), 'MMMM')) AS year_month,
    FORMAT(total_amount, 'N2') AS monthly_total
FROM 
    MonthlyContributions
ORDER BY 
    year, 
    month;
Identify members who have penalties greater than 100 KES

SELECT 
    m.full_name,
    c.member_id,
    sum(round(c.penalty_applied,0)) as penalty
FROM 
    Members m
INNER JOIN 
    contributions c ON m.member_id = c.member_id
where penalty_applied >100
group by m.full_name, C.member_id
ORDER BY m.full_name DESC;

SELECT TOP 5
    employer_id, 
    COUNT(employer_id) AS employer_count,
    SUM(round(contribution_amount,0)) AS total_contribution_amount
FROM 
   contributions
WHERE 
    employer_id IS NOT NULL
    AND contribution_amount IS NOT NULL
GROUP BY 
    employer_id
ORDER BY 
    total_contribution_amount DESC;

SELECT 
    employer_id, 
    COUNT(employer_id) AS employer_count
FROM 
    contributions
GROUP BY 
    employer_id
HAVING 
    COUNT(employer_id) > 2;
--------Which types of healthcare services are most utilized?
select Distinct service_type from healthcare_services;

SELECT 
    service_type,
    COUNT(service_type) AS utilization_count
FROM 
    Healthcare_Services
WHERE 
    service_type IS NOT NULL
GROUP BY 
    service_type
ORDER BY 
    utilization_count DESC;

--------Calculate the average out-of-pocket expenses per service type and region.
----the first analysis was doen from the providers analysis.
select
    h.service_type,
    p.region,
    round(avg(h.out_of_pocket),0) as avg_out_of_pocket
from healthcare_services h
join providers p
on h.provider_id = p.provider_id
group by h.service_type, p.region
order by avg_out_of_pocket desc;

SELECT 
    hs.service_type,
    m.region,
    ROUND(AVG(hs.out_of_pocket), 2) AS avg_out_of_pocket_expense
FROM 
    Healthcare_Services hs
INNER JOIN 
    Members m ON hs.member_id = m.member_id
WHERE 
    hs.out_of_pocket IS NOT NULL
    AND hs.service_type IS NOT NULL
    AND m.region IS NOT NULL
GROUP BY 
    hs.service_type,
    m.region
ORDER BY 
    hs.service_type,
    m.region;


	SELECT 
    hs.service_type,
    m.region,
    ROUND(AVG(hs.out_of_pocket), 2) AS avg_out_of_pocket_expense
FROM 
    Healthcare_Services hs
INNER JOIN 
    Members m ON hs.member_id = m.member_id

GROUP BY 
    hs.service_type,
    m.region
ORDER BY 
    hs.service_type,
    m.region;

	SELECT 
    hs.service_type,
    m.region,
    ROUND(AVG(hs.out_of_pocket), 2) AS avg_out_of_pocket_expense
FROM 
    Healthcare_Services hs
INNER JOIN 
    Members m ON hs.member_id = m.member_id
WHERE 
    hs.out_of_pocket IS NOT NULL
    AND hs.service_type IS NOT NULL
    AND m.region IS NOT NULL
GROUP BY 
    hs.service_type,
    m.region
ORDER BY 
    hs.service_type,
    m.region;

---------Find members with the highest total healthcare costs but lowest coverage. (Use Subqueries)
select cost_total,cost_covered from Healthcare_services;



SELECT TOP 10
    member_id,
    cost_total,
    cost_covered,
    percentage_coverage
FROM (
    SELECT 
        member_id,
        cost_total,
        cost_covered,
        round(cost_covered * 100.0 /(cost_total),2) AS percentage_coverage
    FROM Healthcare_Services
) AS sub
WHERE percentage_coverage < 51
ORDER BY cost_total DESC;
SELECT TOP 10
    member_id,
    cost_total,
    cost_covered,
    percentage_coverage
FROM (
    SELECT 
        member_id,
        cost_total,
        cost_covered,
        (cost_covered * 100.0 / NULLIF(cost_total, 0)) AS percentage_coverage
    FROM Healthcare_Services
) AS sub
ORDER BY cost_total DESC, percentage_coverage ASC;
-------4. Provider Performance:
----- List providers with the highest number of services offered.
SELECT 
    p.provider_id,
    p.provider_name,
    COUNT(hs.service_id) AS service_count
FROM 
    Providers p
INNER JOIN 
    Healthcare_Services hs ON p.provider_id = hs.provider_id
GROUP BY 
    p.provider_id,
    p.provider_name
ORDER BY 
    service_count DESC;


----- Find providers accredited within the last 2 years and compare their claim approval rates
with RecentProviders as (
select provider_id
from providers
where accreditation_date >= dateadd(year, -2, getdate())
),
ClaimStats as (
select 
    c.provider_id,
    c.claim_status,
    count(*) as claim_count
from claims c
join RecentProviders r
on c.provider_id = r.provider_id
group by c.provider_id, c.claim_status
)
select 
    provider_id,
    sum(case when claim_status = 'Approved' then claim_count else 0 end) as approved,
    sum(claim_count) as total,
    round(sum(case when claim_status = 'Approved' then claim_count else 0 end) * 100.0 / sum(claim_count), 2) as approval_rate
from ClaimStats
group by provider_id;

SELECT 
    p.provider_id,
    p.provider_name,
    COUNT(c.claim_id) AS total_claims,
    SUM(CASE WHEN c.claim_status = 'Approved' THEN 1 ELSE 0 END) AS approved_claims,
    ROUND(
        100.0 * SUM(CASE WHEN c.claim_status = 'Approved' THEN 1 ELSE 0 END) / COUNT(c.claim_id), 
        2
    ) AS approval_rate_percentage
FROM 
    Providers p
JOIN 
    Claims c ON p.provider_id = c.provider_id
WHERE 
    p.accreditation_date >= DATEADD(YEAR, -2, GETDATE())
GROUP BY 
    p.provider_id, p.provider_name
ORDER BY 
    approval_rate_percentage DESC;
-------------------------What is the total claim amount by claim status (Approved, Pending, Rejected)?

SELECT 
    claim_status,
    SUM(claim_amount) AS total_claim_amount
FROM 
    Claims
GROUP BY 
    claim_status;

------------Identify discrepancies where claim amount does not match the covered amount for services.
SELECT 
    c.claim_id,
    c.service_id,
    c.claim_amount,
    hs.cost_covered,
    (c.claim_amount - hs.cost_covered) AS discrepancy_amount
FROM 
    Claims c
JOIN 
    Healthcare_Services hs ON c.service_id = hs.service_id
WHERE 
    c.claim_amount != hs.cost_covered;


-------- What is the average satisfaction score by region?

	SELECT 
    m.region,
    AVG(s.satisfaction_score) AS avg_satisfaction_score
FROM 
    Surveys s
JOIN 
    Members m ON s.member_id = m.member_id
GROUP BY 
    m.region
ORDER BY 
    avg_satisfaction_score DESC;

------ Is there a correlation between trust levels and satisfaction scores? (Consider using CASE WHEN for categorization)
SELECT 
 trust_category,
    AVG(satisfaction_score) AS avg_satisfaction_score
FROM (
    SELECT 
        satisfaction_score,
        CASE 
            WHEN trust_level = ('High') THEN 'High Trust'
            WHEN trust_level =('Medium') THEN 'Medium Trust'
            WHEN trust_level = ('Low') THEN 'Low Trust'
            ELSE 'Unknown'
        END AS trust_category
    FROM 
        Surveys
) AS categorized
GROUP BY 
    trust_category
ORDER BY 
    avg_satisfaction_score DESC;

select
    trust_level,
    cast(avg(satisfaction_score) as decimal(5,2)) as avg_satisfaction
from surveys
group by trust_level

--------------------How many legal cases are pending?

SELECT 
    COUNT(*) AS pending_cases
FROM 
    Legal_Cases
WHERE 
    status = 'Pending';

---------------- List legal cases by impact level and find the average filing duration from filing date to today
SELECT case_id,
    impact_level,
    AVG(DATEDIFF(DAY, filing_date, GETDATE())) AS avg_days_open
FROM 
    Legal_Cases
GROUP BY 
    impact_level, case_id
ORDER BY 
    avg_days_open DESC;

-------Create a member healthcare utilization profile (number of services, average costs, satisfaction level) using JOINs across multiple tables

SELECT 
    m.member_id,
    m.full_name,
    COUNT(hs.service_id) AS total_services_used,
    AVG(hs.cost_total) AS avg_total_cost,
    AVG(hs.out_of_pocket) AS avg_out_of_pocket,
    AVG(s.satisfaction_score) AS avg_satisfaction_score
FROM 
    Members m
LEFT JOIN 
    Healthcare_Services hs ON m.member_id = hs.member_id
LEFT JOIN 
    Surveys s ON m.member_id = s.member_id
GROUP BY 
    m.member_id, m.full_name
ORDER BY 
    total_services_used DESC;

-- High Penalty Members
SELECT 
    m.member_id,
    m.full_name,
    'High Penalty' AS risk_reason
FROM 
    Members m
JOIN 
    Contributions c ON m.member_id = c.member_id
GROUP BY 
    m.member_id, m.full_name
HAVING 
    SUM(c.penalty_applied) > 1000

UNION

-- Low Satisfaction Members
SELECT 
    m.member_id,
    m.full_name,
    'Low Satisfaction' AS risk_reason
FROM 
    Members m
JOIN 
    Surveys s ON m.member_id = s.member_id
GROUP BY 
    m.member_id, m.full_name
HAVING 
    AVG(s.satisfaction_score) < 3;

select member_id, 'High Penalty' as risk_reason, avg(penalty_applied) as risk_value
from contributions
where penalty_applied > 100
group by member_id
union
select member_id, 'Low Satisfaction' as risk_reason, avg(Satisfaction_score)as risk_value 
from surveys
where satisfaction_score < 3
group by member_id
----------visualization
select income_level,count(memeber_id) as Members_distribution
from members
group by income_level
order by income_level desc;
-------Members by employment status or subsidy status across regions
select employment_status, 
is_subsidized as subsidy_status,
count(member_id) as Total_members
from Members
group by employment_status, is_subsidized
order by Total_members;

---📌 Line Chart with Moving Average: Monthly contributions with trend
select
    format(contribution_date, 'MM') as Month,
    sum(contribution_amount) as total_contributions
from Contributions
group by format(contribution_date, 'MM');


select 







