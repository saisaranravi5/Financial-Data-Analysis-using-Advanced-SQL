USE financial_analysis;
SELECT * from financial_data_cleaned;
--1
SELECT company_name AS Company, industry, profitMargins,
CASE WHEN profitMargins > 0.20 THEN "High Profitability"
WHEN profitMargins BETWEEN 0.10 AND 0.20 THEN "Moderate"
ELSE "Low"
END AS profitability_tier
FROM financial_data_cleaned
ORDER BY profitMargins DESC;
--2
SELECT 
    industry,
    ROUND(AVG(ebitdaMargins), 3) AS avg_ebitda_margin
FROM financial_data_cleaned
GROUP BY industry
ORDER BY avg_ebitda_margin DESC;
--3
SELECT *
FROM (
    SELECT 
        company_name,
        industry,
        returnOnEquity,
        RANK() OVER (PARTITION BY industry ORDER BY returnOnEquity DESC) AS equity_rank
    FROM financial_data_cleaned
) ranked
WHERE equity_rank <= 3;
--4
SELECT 
    company_name,
    grossMargins,
    operatingMargins,
    ebitdaMargins
FROM financial_data_cleaned
WHERE 
    grossMargins > 0.25 AND
    operatingMargins > 0.25 AND
    ebitdaMargins > 0.25;
--5 Identify Companies with High Cash Conversion Efficiency
SELECT 
    company_name,
    industry,
    operatingCashflow,
    freeCashflow,
    ROUND(freeCashflow * 1.0 / NULLIF(operatingCashflow, 0), 3) AS cash_conversion_efficiency
FROM financial_data_cleaned
WHERE operatingCashflow != 0
  AND freeCashflow * 1.0 / operatingCashflow > 1
ORDER BY cash_conversion_efficiency DESC;
--2_1
SELECT 
    company_name,
    pegRatio,
    CASE 
        WHEN pegRatio < 1 THEN 'Undervalued Growth'
        WHEN pegRatio BETWEEN 1 AND 2 THEN 'Fairly Valued'
        ELSE 'Overvalued'
    END AS valuation_category
FROM financial_data_cleaned
WHERE pegRatio IS NOT NULL
ORDER BY pegRatio;
--2_2
SELECT *
FROM (
SELECT company_name, industry, revenueGrowth, RANK() OVER(PARTITION BY industry ORDER BY revenueGrowth DESC) AS growth_rank
FROM financial_data_cleaned
)ranked
WHERE growth_rank = 1;
--2_3
SELECT 
    company_name,
    earningsQuarterlyGrowth,
    NTILE(4) OVER (ORDER BY earningsQuarterlyGrowth DESC) AS earnings_growth_quartile
FROM financial_data_cleaned;
--2_4
SELECT 
    company_name,
    revenueGrowth,
    pegRatio,
    CASE 
        WHEN revenueGrowth > 0.20 AND pegRatio < 2 THEN 'Growth Stock'
        WHEN revenueGrowth < 0.10 AND pegRatio < 1 THEN 'Value Stock'
        ELSE 'Neutral'
    END AS growth_style
FROM financial_data_cleaned
WHERE pegRatio IS NOT NULL;
--2_5
WITH industry_avg_growth AS (
    SELECT 
        industry,
        ROUND(AVG(revenueGrowth),2) AS avg_industry_growth
    FROM financial_data_cleaned
    GROUP BY industry
)
SELECT 
    f.company_name,
    f.industry,
    f.revenueGrowth,
    i.avg_industry_growth
FROM financial_data_cleaned f
JOIN industry_avg_growth i
  ON f.industry = i.industry
WHERE f.revenueGrowth > i.avg_industry_growth;
--3_1
SELECT 
    company_name,
    industry,
    priceToBook,
    bookValue
FROM financial_data_cleaned
WHERE priceToBook < 1
ORDER BY priceToBook;
--3_2
SELECT *
FROM (
    SELECT 
        company_name,
        industry,
        trailingEps,
        RANK() OVER (PARTITION BY industry ORDER BY trailingEps DESC) AS eps_rank
    FROM financial_data_cleaned
) ranked
WHERE eps_rank = 1;
--3_3
SELECT 
    company_name,
    forwardPE,
    priceToBook,
    ROUND((COALESCE(forwardPE, 0) + COALESCE(priceToBook, 0)) / 2, 2) AS valuation_score
FROM financial_data_cleaned
WHERE forwardPE IS NOT NULL AND priceToBook IS NOT NULL
ORDER BY valuation_score;
--3_4
WITH industry_avg_pe AS (
    SELECT industry, ROUND(AVG(forwardPE),2) AS avg_pe
    FROM financial_data_cleaned
    WHERE forwardPE IS NOT NULL
    GROUP BY industry
)
SELECT 
    f.company_name,
    f.industry,
    f.forwardPE,
    i.avg_pe
FROM financial_data_cleaned f
JOIN industry_avg_pe i ON f.industry = i.industry
WHERE f.forwardPE < i.avg_pe;
--3_5
SELECT 
    company_name,
    enterpriseValue,
    trailingEps,
    ROUND(CASE 
        WHEN trailingEps != 0 THEN enterpriseValue / trailingEps
        ELSE NULL
    END, 2) AS valuation_per_eps
FROM financial_data_cleaned
WHERE trailingEps IS NOT NULL;
--4_1
SELECT 
    company_name,
    industry,
    sharesOutstanding
FROM financial_data_cleaned
WHERE sharesOutstanding IS NOT NULL
ORDER BY sharesOutstanding DESC
LIMIT 10;
--4_2
SELECT 
    industry,
    ROUND(AVG(heldPercentInsiders), 2) AS avg_insider_holding
FROM financial_data_cleaned
WHERE heldPercentInsiders IS NOT NULL
GROUP BY industry
ORDER BY avg_insider_holding DESC;
--4_3 
SELECT 
    company_name, sharesOutstanding, heldPercentInsiders
FROM financial_data_cleaned
WHERE heldPercentInsiders < 0.05 AND sharesOutstanding > 3000
ORDER BY sharesOutstanding DESC;

--4_4
SELECT 
    company_name,
    heldPercentInsiders,
    CASE 
        WHEN heldPercentInsiders >= 0.3 THEN 'High Insider Control'
        WHEN heldPercentInsiders BETWEEN 0.1 AND 0.3 THEN 'Moderate Control'
        ELSE 'Low Insider Control'
    END AS control_category
FROM financial_data_cleaned
WHERE heldPercentInsiders IS NOT NULL 
ORDER BY heldPercentInsiders DESC;
--4_5
SELECT 
    company_name,
    sharesOutstanding,
    heldPercentInsiders,
    currentPrice,
    ROUND(sharesOutstanding * heldPercentInsiders, 2) AS insider_owned_shares,
    ROUND(sharesOutstanding * heldPercentInsiders * currentPrice, 2) AS insider_holding_value_usd
FROM financial_data_cleaned
WHERE sharesOutstanding IS NOT NULL 
  AND heldPercentInsiders IS NOT NULL 
  AND currentPrice IS NOT NULL
ORDER BY insider_holding_value_usd DESC
LIMIT 10;
--5_1
SELECT industry, ROUND(AVG(revenueGrowth),3) AS avg_revenue_growth
FROM financial_data_cleaned
WHERE revenueGrowth IS NOT NULL
GROUP BY industry
ORDER BY avg_revenue_growth DESC;
--5_2
SELECT *
FROM (
    SELECT 
        company_name,
        industry,
        operatingMargins,
        RANK() OVER (PARTITION BY industry ORDER BY operatingMargins DESC) AS op_rank
    FROM financial_data_cleaned
    WHERE operatingMargins IS NOT NULL
) ranked
WHERE op_rank = 1;
--5_3
SELECT 
    industry,
    COUNT(*) AS undervalued_growth_stocks
FROM financial_data_cleaned
WHERE pegRatio < 1
GROUP BY industry
ORDER BY undervalued_growth_stocks DESC;
--5_4
WITH industry_avg_pe AS (
    SELECT industry, ROUND(AVG(forwardPE),3) AS industry_pe
    FROM financial_data_cleaned
    WHERE forwardPE IS NOT NULL
    GROUP BY industry
),
overall_pe AS (
    SELECT ROUND(AVG(forwardPE),3) AS total_avg_pe
    FROM financial_data_cleaned
    WHERE forwardPE IS NOT NULL
)
SELECT 
    i.industry,
    i.industry_pe,
    o.total_avg_pe,
    CASE 
        WHEN i.industry_pe > o.total_avg_pe THEN 'Overvalued'
        ELSE 'Undervalued'
    END AS valuation_flag
FROM industry_avg_pe i, overall_pe o
ORDER BY i.industry_pe DESC;
--5_5
SELECT 
    industry,
    COUNT(*) AS high_margin_firms
FROM financial_data_cleaned
WHERE ebitdaMargins > 0.3
GROUP BY industry
ORDER BY high_margin_firms DESC;


 
