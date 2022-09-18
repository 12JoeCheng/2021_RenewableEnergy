USE Profolio_project;

SELECT *
FROM renewablesenergy;

-- 整理與選取資料

DROP TEMPORARY TABLE IF EXISTS countries_table;

CREATE TEMPORARY TABLE countries_table (
	Entity VARCHAR (255),
    Code VARCHAR(255),
    Year INTEGER,
    PercentofRenewables DOUBLE
);

INSERT INTO countries_table
SELECT Entity, Code ,Year, PercentofRenewables
FROM renewablesenergy
WHERE Entity NOT LIKE '%(BP)' 
AND Code != ''
AND Entity != 'World'
ORDER BY 1;


-- 1965~2021各國每年平均電力來源於再生能源比例

SELECT Entity, AVG(PercentofRenewables) as AveragePercent
FROM countries_table
GROUP BY Entity;


-- 1965~2021各大洲每年平均電力來源於再生能源比例

SELECT Entity, AVG(PercentofRenewables) as AveragePercentage
FROM renewablesenergy
WHERE Entity NOT LIKE '%(BP)' 
AND Entity NOT IN ('European Union (27)', 
					'High-income countries' , 
					'Lower-middle-income countries', 
					'Upper-middle-income countries', 
					'World')
AND Code = ''
GROUP BY Entity;


-- 2021各大洲平均電力來源於再生能源比例

SELECT Entity, PercentofRenewables as 2021Percentage
FROM renewablesenergy
WHERE Entity NOT LIKE '%(BP)' 
AND Entity NOT IN ('European Union (27)', 
					'High-income countries' , 
					'Lower-middle-income countries', 
					'Upper-middle-income countries', 
					'World')
AND Code = ''
AND Year = 2021;
-- GROUP BY Entity;


-- 2021各國電力來源於再生能源比例

SELECT Entity, PercentofRenewables as 2021Percentage
FROM countries_table
WHERE Year = 2021;


-- 各國歷年的再生能源比例變化
-- 利用CTE

WITH RelativeChagne (Entity, Year, PercentofRenewables, LastYearPercent) AS
(
SELECT Entity,
       Year,
       PercentofRenewables AS ThisYearPercent,
       LAG(PercentofRenewables) OVER ( ORDER BY Entity ) AS LastYearPercent
       -- (PercentofRenewables - LAG(PercentofRenewables))*100 / LAG(PercentofRenewables) OVER ( ORDER BY Entity ) AS ChangefromLastYear
FROM   profolio_project.countries_table
)
SELECT Entity,
       Year,
       PercentofRenewables AS ThisYearPercent,
       (PercentofRenewables - LastYearPercent) *100 / LAG(PercentofRenewables) OVER ( ORDER BY Entity ) AS ChangefromLastYearPercentage
FROM	RelativeChagne;


-- 各大洲再生能源各年比例與歷年變化
-- 利用CTE

WITH ContinentRelativeChagne (Entity, Code, Year, PercentofRenewables, LastYearPercent) AS
(
SELECT 	Entity,
		Code,
		Year,
		PercentofRenewables AS ThisYearPercent,
		LAG(PercentofRenewables) OVER ( ORDER BY Entity ) AS LastYearPercent
		-- (PercentofRenewables - LAG(PercentofRenewables))*100 / LAG(PercentofRenewables) OVER ( ORDER BY Entity ) AS ChangefromLastYear
FROM   	profolio_project.renewablesenergy
WHERE 	Entity NOT LIKE '%(BP)' 
AND 	Entity NOT IN ('European Union (27)', 
					'High-income countries' , 
					'Lower-middle-income countries', 
					'Upper-middle-income countries', 
					'World')
AND 	Code = ''
)
SELECT 	Entity,
		Code,
		Year,
		PercentofRenewables AS ThisYearPercent,
		(PercentofRenewables - LastYearPercent) *100 / LAG(PercentofRenewables) OVER ( ORDER BY Entity ) AS ChangefromLastYearPercentage
FROM	ContinentRelativeChagne
WHERE 	Entity NOT LIKE '%(BP)' 
AND 	Entity NOT IN ('European Union (27)', 
					'High-income countries' , 
					'Lower-middle-income countries', 
					'Upper-middle-income countries', 
					'World')
AND 	Code = '';



-- 全球再生能源各年比例與歷年變化
-- 利用CTE

WITH WorldRelativeChagne (Entity, Year, PercentofRenewables, LastYearPercent) AS
(
SELECT Entity,
       Year,
       PercentofRenewables AS ThisYearPercent,
       LAG(PercentofRenewables) OVER ( ORDER BY Entity ) AS LastYearPercent
       -- (PercentofRenewables - LAG(PercentofRenewables))*100 / LAG(PercentofRenewables) OVER ( ORDER BY Entity ) AS ChangefromLastYear
FROM   profolio_project.countries_table
WHERE Entity = 'World'
)
SELECT Entity,
       Year,
       PercentofRenewables AS ThisYearPercent,
       (PercentofRenewables - LastYearPercent) *100 / LAG(PercentofRenewables) OVER ( ORDER BY Entity ) AS ChangefromLastYearPercentage
FROM	WorldRelativeChagne
WHERE Entity = 'World';



-- Creating View 
-- View 無法使用TEMP_TABLE所以直接創一個TABLE

DROP TABLE IF EXISTS c_table;
CREATE TABLE c_table (
	Entity VARCHAR (255),
    Code VARCHAR(255),
    Year INTEGER,
    PercentofRenewables DOUBLE
);
INSERT INTO c_table
SELECT Entity, Code ,Year, PercentofRenewables
FROM renewablesenergy
WHERE Entity NOT LIKE '%(BP)' 
AND Entity != 'World'
AND Code != ''; 


-- 1

CREATE VIEW CountriesAVGRatio AS
SELECT Entity, AVG(PercentofRenewables) as AveragePercent
FROM c_table
GROUP BY Entity;


-- 2

CREATE VIEW ContinentsAVGRatio AS
SELECT Entity, AVG(PercentofRenewables) as AveragePercentage
FROM renewablesenergy
WHERE Entity NOT LIKE '%(BP)' 
AND Entity NOT IN ('European Union (27)', 
					'High-income countries' , 
					'Lower-middle-income countries', 
					'Upper-middle-income countries', 
					'World')
AND Code = ''
GROUP BY Entity;


-- 3

CREATE VIEW 2021ContinentsAVGRatio AS
SELECT Entity, PercentofRenewables as 2021Percentage
FROM renewablesenergy
WHERE Entity NOT LIKE '%(BP)' 
AND Entity NOT IN ('European Union (27)', 
					'High-income countries' , 
					'Lower-middle-income countries', 
					'Upper-middle-income countries', 
					'World')
AND Code = ''
AND Year = 2021;


-- 4

CREATE VIEW 2021CountriesAVGRatio AS
SELECT Entity, PercentofRenewables as 2021Percentage
FROM c_table
WHERE Year = 2021;


-- 5

CREATE VIEW CounrtriesChangeofEachYears AS
WITH RelativeChagne (Entity, Year, PercentofRenewables, LastYearPercent) AS
(
SELECT Entity,
       Year,
       PercentofRenewables AS ThisYearPercent,
       LAG(PercentofRenewables) OVER ( ORDER BY Entity ) AS LastYearPercent
       -- (PercentofRenewables - LAG(PercentofRenewables))*100 / LAG(PercentofRenewables) OVER ( ORDER BY Entity ) AS ChangefromLastYear
FROM   profolio_project.c_table
)
SELECT Entity,
       Year,
       PercentofRenewables AS ThisYearPercent,
       (PercentofRenewables - LastYearPercent) *100 / LAG(PercentofRenewables) OVER ( ORDER BY Entity ) AS ChangefromLastYearPercentage
FROM	RelativeChagne;


-- 6

CREATE VIEW ContinentsChangeofEachYears AS
WITH ContinentRelativeChagne (Entity, Code, Year, PercentofRenewables, LastYearPercent) AS
(
SELECT 	Entity,
		Code,
		Year,
		PercentofRenewables AS ThisYearPercent,
		LAG(PercentofRenewables) OVER ( ORDER BY Entity ) AS LastYearPercent
		-- (PercentofRenewables - LAG(PercentofRenewables))*100 / LAG(PercentofRenewables) OVER ( ORDER BY Entity ) AS ChangefromLastYear
FROM   	profolio_project.renewablesenergy
WHERE 	Entity NOT LIKE '%(BP)' 
AND 	Entity NOT IN ('European Union (27)', 
					'High-income countries' , 
					'Lower-middle-income countries', 
					'Upper-middle-income countries', 
					'World')
AND 	Code = ''
)
SELECT 	Entity,
		Code,
		Year,
		PercentofRenewables AS ThisYearPercent,
		(PercentofRenewables - LastYearPercent) *100 / LAG(PercentofRenewables) OVER ( ORDER BY Entity ) AS ChangefromLastYearPercentage
FROM	ContinentRelativeChagne
WHERE 	Entity NOT LIKE '%(BP)' 
AND 	Entity NOT IN ('European Union (27)', 
					'High-income countries' , 
					'Lower-middle-income countries', 
					'Upper-middle-income countries', 
					'World')
AND 	Code = '';


-- 7
CREATE VIEW WorldChangeofEachYears AS
WITH WorldRelativeChagne (Entity, Year, PercentofRenewables, LastYearPercent) AS
(
SELECT Entity,
       Year,
       PercentofRenewables AS ThisYearPercent,
       LAG(PercentofRenewables) OVER ( ORDER BY Entity ) AS LastYearPercent
       -- (PercentofRenewables - LAG(PercentofRenewables))*100 / LAG(PercentofRenewables) OVER ( ORDER BY Entity ) AS ChangefromLastYear
FROM   profolio_project.c_table
WHERE Entity = 'World'
)
SELECT Entity,
       Year,
       PercentofRenewables AS ThisYearPercent,
       (PercentofRenewables - LastYearPercent) *100 / LAG(PercentofRenewables) OVER ( ORDER BY Entity ) AS ChangefromLastYearPercentage
FROM	WorldRelativeChagne
WHERE Entity = 'World';

