SET SQL_SAFE_UPDATES = 0;
 ##data cleaning##

##1.Checking for Duplicates###
SELECT Country, ISO, Sex, Year, COUNT(*)
FROM cleaned_diabetes
GROUP BY Country, ISO, Sex, Year
HAVING COUNT(*) > 1;

###2.Checking for null values###
SELECT * FROM cleaned_diabetes
WHERE Country IS NULL
OR ISO IS NULL
OR Sex IS NULL
OR Year IS NULL
OR `AgeStd_Diabetes_18+` IS NULL
OR `AgeStd_Diab_L95_18+` IS NULL
OR `AgeStd_Diab_L95_v2_18+` IS NULL
OR `AgeStd_Treated_30+` IS NULL
OR `AgeStd_Treat_L95_30+` IS NULL
OR `AgeStd_Treat_U95_30+` IS NULL
OR `Crude_Diabetes_18+` IS NULL
OR `Crude_Diab_L95_18+` IS NULL
OR `Crude_Diab_U95_18+` IS NULL
OR `Crude_Treated_30+` IS NULL
OR `Crude_Treat_L95_30+` IS NULL
OR `Crude_Treat_U95_30+` IS NULL;

##3.negative values###
SELECT * FROM cleaned_diabetes
WHERE `AgeStd_Diabetes_18+` < 0
OR `AgeStd_Treated_30+` < 0
OR `Crude_Diabetes_18+` < 0
OR `Crude_Treated_30+` < 0;

##4.Normalize percentage columns##

UPDATE cleaned_diabetes
SET
`AgeStd_Diabetes_18+` = `AgeStd_Diabetes_18+` * 100,
`AgeStd_Treated_30+` = `AgeStd_Treated_30+` * 100,
`Crude_Diabetes_18+` = `Crude_Diabetes_18+` * 100,
`AgeStd_Diab_L95_18+` = `AgeStd_Diab_L95_18+` * 100,
`AgeStd_Diab_L95_v2_18+` = `AgeStd_Diab_L95_v2_18+` * 100,
`AgeStd_Treat_L95_30+` = `AgeStd_Treat_L95_30+` * 100,
`AgeStd_Treat_U95_30+` = `AgeStd_Treat_U95_30+` * 100,
`Crude_Diab_L95_18+` = `Crude_Diab_L95_18+` * 100,
`Crude_Diab_U95_18+` = `Crude_Diab_U95_18+` * 100,
`Crude_Treated_30+` = `Crude_Treated_30+` * 100,
`Crude_Treat_L95_30+` = `Crude_Treat_L95_30+` * 100,
`Crude_Treat_U95_30+` = `Crude_Treat_U95_30+` * 100;


##checking incorrect confidence intervals(lower bound should be less than upper bound)

UPDATE cleaned_diabetes
SET `AgeStd_Diab_L95_18+` = `AgeStd_Diab_L95_v2_18+`
WHERE `AgeStd_Diab_L95_18+` > `AgeStd_Diab_L95_v2_18+`;

UPDATE cleaned_diabetes
SET `AgeStd_Treat_L95_30+` = `AgeStd_Treat_U95_30+`
WHERE `AgeStd_Treat_L95_30+` > `AgeStd_Treat_U95_30+`;

UPDATE cleaned_diabetes
SET `Crude_Diab_L95_18+` = `Crude_Diab_U95_18+`
WHERE `Crude_Diab_L95_18+` > `Crude_Diab_U95_18+`;

UPDATE cleaned_diabetes
SET `Crude_Treat_L95_30+` = `Crude_Treat_U95_30+`
WHERE `Crude_Treat_L95_30+` > `Crude_Treat_U95_30+`;

##ex1:How has the age-standardized prevalence of diabetes (AgeStd_Diabetes_18+) in Egypt changed from 1990 to 2022, and what are the differences between men and women??

SELECT year, sex, 
`AgeStd_Diabetes_18+` AS diabetes_prevalence
FROM cleaned_diabetes
WHERE country = 'Egypt'
ORDER BY year, sex;
    
##ex2:What are the differences in diabetes prevalence (AgeStd_Diabetes_18+) and treatment rates (AgeStd_Treated_30+) between men and women in Egypt from 1990 to 2022?

SELECT `Year`, `Sex`, `AgeStd_Diabetes_18+`, `AgeStd_Treated_30+`
FROM `cleaned_diabetes`
WHERE `Year` BETWEEN 1990 AND 2022
ORDER BY `Year`, `Sex`;

##ex3:What proportion of people with diabetes in Egypt remain untreated, and how has this proportion changed from 2000 to 2021?

SELECT `Year`, `Sex`, `AgeStd_Diabetes_18+`, `AgeStd_Treated_30+`,
(1 - (`AgeStd_Treated_30+` / `AgeStd_Diabetes_18+`)) * 100 AS `Untreated_Percentage`
FROM `cleaned_diabetes`
WHERE `Year` BETWEEN 2000 AND 2021
ORDER BY `Year`, `Sex`;

##ex4:How has the uncertainty in diabetes prevalence estimates (AgeStd_Diabetes_18+) changed over time in Egypt, and are there significant differences between men and women?
SELECT `Year`, `Sex`, `AgeStd_Diabetes_18+`, `AgeStd_Diab_L95_18+` AS `Lower_Bound`, `AgeStd_Diab_L95_v2_18+` AS `Upper_Bound`, 
(`AgeStd_Diab_L95_v2_18+` - `AgeStd_Diab_L95_18+`) AS `Uncertainty_Range`
FROM `cleaned_diabetes`
WHERE `Year` BETWEEN 1990 AND 2022
ORDER BY `Year`, `Sex`;

##ex5:How do crude diabetes prevalence rates (Crude_Diabetes_18+) compare to age-standardized rates (AgeStd_Diabetes_18+) in Egypt from 1990 to 2022?
SELECT `Year`, `AgeStd_Diabetes_18+`, `Crude_Diabetes_18+`, (`AgeStd_Diabetes_18+` - `Crude_Diabetes_18+`) AS `Difference`
FROM `cleaned_diabetes`
WHERE `Year` BETWEEN 1990 AND 2022
ORDER BY `Year`;

##ex6:What percentage of people with diabetes in Egypt receive treatment (AgeStd_Treated_30+), and how has this percentage changed from 1990 to 2022?
SELECT `Year`, (`AgeStd_Treated_30+` / `AgeStd_Diabetes_18+`) * 100 AS `Treatment_Percentage`
FROM `Cleaned_Diabetes`
WHERE `Year` BETWEEN 1990 AND 2022
ORDER BY `Year`;

##ex7:year with the highest and lowest diabetes prevalence.
(SELECT `Year`, `AgeStd_Diabetes_18+` AS `Prevalence`, 'Highest' AS `Type`
FROM `cleaned_diabetes`
ORDER BY `AgeStd_Diabetes_18+` DESC
LIMIT 1)
UNION ALL
(SELECT `Year`, `AgeStd_Diabetes_18+` AS `Prevalence`, 'Lowest' AS `Type`
FROM `cleaned_diabetes`
ORDER BY `AgeStd_Diabetes_18+` ASC
    LIMIT 1
);

##ex8:Compare treatment rates over the years.
SELECT `Year`,AVG(`Crude_Treated_30+`) AS `Avg_Treatment_Rate`
FROM `cleaned_diabetes`
GROUP BY `Year`
ORDER BY `Year`;

##9:Check if treatment rates increase when prevalence is higher.

SELECT `Year`,AVG(`Crude_Diabetes_18+`) AS `Avg_Diabetes_Prevalence`,AVG(`Crude_Treated_30+`) AS `Avg_Treatment_Rate`
FROM `cleaned_diabetes`
GROUP BY `Year`
ORDER BY `Year`;

##10:Predict future diabetes prevalence based on past trends.
SELECT `Year`,AVG(`Crude_Diabetes_18+`) 
OVER 
(ORDER BY `Year` ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) AS `Moving_Avg_Prediction`
FROM `cleaned_diabetes`
ORDER BY `Year`;






