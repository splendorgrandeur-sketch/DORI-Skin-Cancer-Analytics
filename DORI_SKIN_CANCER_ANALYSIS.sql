--DORI_Skin_Cancer_Analysis

--TASK 1. PATIENT DEMOGRAPHIC RISK ANALYSIS
--T1.1. AGE GROUP WITH THE HIGHEST NUMBER OF SKIN CANCER DIAGNOSIS
BREAKDOWN CHECK_RELEVANT_TABLE
---DIM 1 CHECK_RELEVANT_TABLE
SELECT*
FROM table1;

--DIM 2 CHECK_RELEVANT_TABLE
SELECT*
FROM table2;

---AGE RANGE
SELECT
		MIN (age) AS Youngest,
		MAX (age) AS Oldest
FROM table1;

--AGE GROUP
SELECT *,
		CASE
		WHEN age BETWEEN 6 AND 23 THEN 'Children & Young Adults'
		WHEN age BETWEEN 24 AND 41 THEN 'Young Adults'
		WHEN age BETWEEN 42 AND 59 THEN 'Middle-Aged Adults'
		WHEN age BETWEEN 60 AND 77 THEN 'Adults'
		WHEN age BETWEEN 78 AND 94 THEN 'Elderly Adults'
		END AS "Age Group"

ANSWER:
SELECT
	CASE
		WHEN age BETWEEN 6 AND 23 THEN 'Children & Young Adults'
		WHEN age BETWEEN 24 AND 41 THEN 'Young Adults'
		WHEN age BETWEEN 42 AND 59 THEN 'Middle-Aged Adults'
		WHEN age BETWEEN 60 AND 77 THEN 'Adults'
		WHEN age BETWEEN 78 AND 94 THEN 'Elderly Adults'
		END AS "Age Group",
		COUNT (*) AS patients_with_skin_cancer_history
FROM table1 
WHERE skin_cancer_history = 'true'
GROUP BY "Age Group"
ORDER BY patients_with_skin_cancer_history DESC;

--T1.2. What is the distribution of diagnosis between male and female patients
BREAKDOWN
Alias for table1 is p & Alias for table2 is l
ANSWER
SELECT p.gender,
	COUNT (*) AS diagnosis_count
FROM table1 P
JOIN table2 l 
ON p.patient_id = l.patient_id
GROUP BY p.gender
ORDER BY diagnosis_count DESC;

GENDER DISTRIBUTION BY PERCENTAGE
SELECT
    p.gender,
    COUNT(*) AS diagnosis_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_total
FROM table1 p
JOIN table2 l ON p.patient_id = l.patient_id
GROUP BY p.gender
ORDER BY diagnosis_count DESC;

--T1.3. Which body regions record the highest number of patients with malignant diagnoses?
BREAKDOWN
retrieve diagnostic
SELECT DISTINCT diagnostic FROM table2;

categorizing them
CREATE VIEW lesion_with_category AS
SELECT
    *,
    CASE
        WHEN diagnostic IN ('MEL', 'SCC', 'BCC') THEN 'Malignant'
        WHEN diagnostic = 'ACK' THEN 'Pre-cancerous'
        WHEN diagnostic IN ('SEK', 'NEV') THEN 'Benign'
    END AS diagnostic_category
FROM table2;

creating the category analysis
SELECT DISTINCT
	diagnostic,
	diagnostic_category
FROM lesion_with_category
ORDER BY diagnostic_category;

ANSWER
SELECT
    region,
    COUNT(*) AS malignant_diagnosis_count
FROM lesion_with_category
WHERE diagnostic_category = 'Malignant'
GROUP BY region
ORDER BY malignant_diagnosis_count DESC;

--T1.4. How many patients have a previous history of skin cancer?
SELECT 
	Count(*) AS patients_with_skin_cancer_history
FROM table1 
WHERE skin_cancer_history = 'true'

--   TASK 2: LESION GROWTH & DIAGNOSIS ANALYSIS
--T2.1 Which diagnosis category appears most frequently?
BREAKDOWN
lesion_with_category
SELECT
    diagnostic_category,
    COUNT(*) AS total_cases
FROM lesion_with_category
GROUP BY diagnostic_category
ORDER BY total_cases DESC;

ANSWER
SELECT
    diagnostic,
    COUNT(*) AS total_cases
FROM table2
GROUP BY diagnostic
ORDER BY total_cases DESC;

--T2.2 How many lesions were reported as growing over time?
BREAKDOWN CHECK_RELEVANT_TABLE
SELECT*
FROM table2;

ANSWER
SELECT
    COUNT(*) AS growing_lesions
FROM table2
WHERE grew = TRUE;

--T2.3 Which symptoms are most commonly associated with lesions?`
BREAKDOWN
LEGION_SYMPTOMS 
SELECT DISTINCT
    itch,
    hurt,
    changed,
    bleed,
    elevation
FROM table2;

SELECT
    SUM(CASE WHEN itch      THEN 1 ELSE 0 END) AS itch_count,
    SUM(CASE WHEN hurt      THEN 1 ELSE 0 END) AS hurt_count,
    SUM(CASE WHEN changed   THEN 1 ELSE 0 END) AS changed_count,
    SUM(CASE WHEN bleed     THEN 1 ELSE 0 END) AS bleed_count,
    SUM(CASE WHEN elevation THEN 1 ELSE 0 END) AS elevation_count
FROM table2;

ALTERNATIVELY

SELECT 'Itch' AS symptom, COUNT(*) AS symptom_count FROM table2 WHERE itch = TRUE
UNION ALL
SELECT 'Hurt', COUNT(*) FROM table2 WHERE hurt = TRUE
UNION ALL
SELECT 'Changed', COUNT(*) FROM table2 WHERE changed = TRUE
UNION ALL
SELECT 'Bleed', COUNT(*) FROM table2 WHERE bleed = TRUE
UNION ALL
SELECT 'Elevation', COUNT(*) FROM table2 WHERE elevation = TRUE
ORDER BY symptom_count DESC;

SELECT
    COUNT(*) FILTER (WHERE itch      = TRUE) AS itch_count,
    COUNT(*) FILTER (WHERE hurt      = TRUE) AS hurt_count,
    COUNT(*) FILTER (WHERE changed   = TRUE) AS changed_count,
    COUNT(*) FILTER (WHERE bleed     = TRUE) AS bleed_count,
    COUNT(*) FILTER (WHERE elevation = TRUE) AS elevation_count
FROM table2;


--T2.4 How many lesions were biopsied before diagnosis confirmation?
SELECT
    COUNT(*) AS biopsied_lesions
FROM table2
WHERE biopsed = TRUE;

--T2.5 Which diagnosis type has the highest average lesion diameter?
BREAKDOWN CHECK_RELEVANT_TABLE
SELECT *
FROM table2;

SELECT
    diagnostic,
    ROUND(((AVG(diameter_1) + AVG(diameter_2)) / 2)::numeric, 2) AS avg_diameter
FROM table2
GROUP BY diagnostic
ORDER BY avg_diameter DESC;

SELECT
    diagnostic,
    (AVG(diameter_1) + AVG(diameter_2)) / 2 AS avg_diameter
FROM table2
GROUP BY diagnostic
ORDER BY avg_diameter DESC;

--T3.Which body region has the highest number of diagnosed cases?
--T3.1 BODY REGIONS WITH HIGHEST DIAGNOSED CASES
SELECT
    region,
    COUNT(*) AS case_count
FROM table2
GROUP BY region
ORDER BY case_count DESC;

--T3.2. How many patients lack access to piped water?
BREAKDOWN CHECK_RELEVANT_TABLE
SELECT *
FROM table1;

SELECT *
FROM table2;

ANSWERS 
SELECT
    COUNT(*) AS no_piped_water
FROM table1
WHERE has_piped_water = FALSE;

--T3.3. How many patients do not have access to sewage systems?
BREAKDOWN CHECK_RELEVANT_TABLE
SELECT *
FROM table1;

ANSWER
SELECT
      COUNT(*) AS No_sewage_system
FROM table1
WHERE has_sewage_system = false;

--T3.4. Which body regions report the highest number of biopsied lesions?
SELECT
    region,
    COUNT(*) AS biopsied_count
FROM table2
WHERE biopsed = TRUE
GROUP BY region
ORDER BY biopsied_count DESC;

--T3.5. Is there a relationship between poor sanitation access and severe diagnosis outcomes?
SELECT
    CASE
        WHEN p.has_piped_water = FALSE OR p.has_sewage_system = FALSE
            THEN 'Poor Sanitation'
        ELSE 'Adequate Sanitation'
    END AS sanitation_status,
    COUNT(*) AS total_diagnoses,
    COUNT(*) FILTER (WHERE l.diagnostic_category = 'Malignant') AS malignant_count,
    100.0 * COUNT(*) FILTER (WHERE l.diagnostic_category = 'Malignant') / COUNT(*) AS malignant_rate_pct
FROM table1 p
JOIN lesion_with_category l ON p.patient_id = l.patient_id
GROUP BY sanitation_status
ORDER BY malignant_rate_pct DESC;

--TASK 4. Lifestyle & Behavioural Risk Analysis
--T4.1. How many patients are smokers?
BREAKDOWN CHECK_RELEVANT_TABLE
SELECT *
FROM table1;

SELECT
      COUNT(*) AS smokers
FROM table1
WHERE smoke = true;

--T4.2. How many patients consume alcohol regularly?
BREAKDOWN CHECK_RELEVANT_TABLE
SELECT *
FROM table1;

SELECT
      COUNT(*) AS  Alchoholics
FROM table1
WHERE drink = true;

--T4.3.Which diagnosis types are most common among smokers?
BREAKDOWN CHECK_RELEVANT_TABLE
SELECT *
FROM table1;

SELECT *
FROM table2;

SELECT
    l.diagnostic,
    COUNT(*) AS total_cases
FROM table1 p
JOIN lesion_with_category l ON p.patient_id = l.patient_id
WHERE p.smoke = TRUE
GROUP BY l.diagnostic
ORDER BY total_cases DESC;

SELECT
    l.diagnostic,
    COUNT(*) AS total_cases
FROM table1 p
JOIN table2 l ON p.patient_id = l.patient_id
WHERE p.smoke = TRUE
GROUP BY l.diagnostic
ORDER BY total_cases DESC;

--T4.4. What percentage of smokers also consume alcohol?
SELECT
    100.0 * COUNT(*) FILTER (WHERE drink = TRUE) / COUNT(*) AS pct_smokers_who_also_drink
FROM table1
WHERE smoke = TRUE;

GENDER PERCENTAGE (Nice Add_on)
SELECT
    100.0 * COUNT(*) FILTER (WHERE gender = 'MALE' AND drink = TRUE)
        / COUNT(*) FILTER (WHERE gender = 'MALE') AS male_pct_smokers_who_drink,
    100.0 * COUNT(*) FILTER (WHERE gender = 'FEMALE' AND drink = TRUE)
        / COUNT(*) FILTER (WHERE gender = 'FEMALE') AS female_pct_smokers_who_drink
FROM table1
WHERE smoke = TRUE;

--T4.5. Are patients who both smoke and drink more likely to develop malignant conditions?
SELECT
    CASE
        WHEN p.smoke = TRUE  AND p.drink = TRUE  THEN 'Smokers & Drinkers'
        WHEN p.smoke = TRUE  AND p.drink = FALSE THEN 'Smokers Only'
        WHEN p.smoke = FALSE AND p.drink = TRUE  THEN 'Drinkers Only'
        ELSE 'Neither'
    END AS lifestyle_group,
    COUNT(*) AS total_diagnoses,
    COUNT(*) FILTER (WHERE l.diagnostic_category = 'Malignant') AS malignant_count,
    100.0 * COUNT(*) FILTER (WHERE l.diagnostic_category = 'Malignant') / COUNT(*) AS malignant_rate_pct
FROM table1 p
JOIN lesion_with_category l ON p.patient_id = l.patient_id
GROUP BY lifestyle_group
ORDER BY malignant_rate_pct DESC;

ALTERNATIVELY
SELECT
    (p.smoke AND p.drink) AS smokes_and_drinks,
    COUNT(*) AS total_diagnoses,
    COUNT(*) FILTER (WHERE l.diagnostic_category = 'Malignant') AS malignant_count,
    100.0 * COUNT(*) FILTER (WHERE l.diagnostic_category = 'Malignant') / COUNT(*) AS malignant_rate_pct
FROM table1 p
JOIN lesion_with_category l ON p.patient_id = l.patient_id
GROUP BY smokes_and_drinks
ORDER BY malignant_rate_pct DESC;

--T4.6. Which lifestyle factor has the strongest relationship with severe diagnosis outcomes?
SELECT
    'Smoking' AS risk_factor,
    100.0 * COUNT(*) FILTER (WHERE l.diagnostic_category = 'Malignant') / COUNT(*) AS malignant_rate_pct
FROM table1 p JOIN lesion_with_category l ON p.patient_id = l.patient_id
WHERE p.smoke = TRUE

UNION ALL

SELECT
    'Alcohol Consumption',
    100.0 * COUNT(*) FILTER (WHERE l.diagnostic_category = 'Malignant') / COUNT(*)
FROM table1 p JOIN lesion_with_category l ON p.patient_id = l.patient_id
WHERE p.drink = TRUE

UNION ALL

SELECT
    'Pesticide Exposure',
    100.0 * COUNT(*) FILTER (WHERE l.diagnostic_category = 'Malignant') / COUNT(*)
FROM table1 p JOIN lesion_with_category l ON p.patient_id = l.patient_id
WHERE p.pesticide = TRUE

UNION ALL

SELECT
    'Family Cancer History',
    100.0 * COUNT(*) FILTER (WHERE l.diagnostic_category = 'Malignant') / COUNT(*)
FROM table1 p JOIN lesion_with_category l ON p.patient_id = l.patient_id
WHERE p.cancer_history = TRUE

ORDER BY malignant_rate_pct DESC;

ALTERNATIVELY

SELECT
    100.0 * COUNT(*) FILTER (WHERE p.smoke = TRUE AND l.diagnostic_category = 'Malignant')
        / COUNT(*) FILTER (WHERE p.smoke = TRUE) AS smoking_malignant_pct,

    100.0 * COUNT(*) FILTER (WHERE p.drink = TRUE AND l.diagnostic_category = 'Malignant')
        / COUNT(*) FILTER (WHERE p.drink = TRUE) AS alcohol_malignant_pct,

    100.0 * COUNT(*) FILTER (WHERE p.pesticide = TRUE AND l.diagnostic_category = 'Malignant')
        / COUNT(*) FILTER (WHERE p.pesticide = TRUE) AS pesticide_malignant_pct,

    100.0 * COUNT(*) FILTER (WHERE p.cancer_history = TRUE AND l.diagnostic_category = 'Malignant')
        / COUNT(*) FILTER (WHERE p.cancer_history = TRUE) AS family_history_malignant_pct
FROM table1 p
JOIN lesion_with_category l ON p.patient_id = l.patient_id;