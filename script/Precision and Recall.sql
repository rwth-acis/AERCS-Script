/*------------------ PRECISION AND RECALL FOR "TITLE FIRST AUTHOR SECOND" -----------------------------*/
--True positives
SELECT COUNT(*)
FROM aercs_tt.paper_mapping pm
    INNER JOIN aercs_tt.paper p
              ON pm.DBLP_ID = p.ID
    INNER JOIN paper cp
              ON pm.CITESEER_ID = cp.id  
    INNER JOIN (
                SELECT *
                FROM RESULT_MATCH80
                WHERE ((AUTHOR_JWS BETWEEN 85 AND 100) OR (AUTHOR_JWS_LEFT BETWEEN 85 AND 100))
                      AND TITLE_JWS < 90
                UNION
                SELECT *
                FROM RESULT_MATCH80
                WHERE (AUTHOR_JWS >= 75 OR AUTHOR_JWS_LEFT >=75 )
                      AND TITLE_JWS >= 90
                UNION
                SELECT *
                FROM RESULT_MATCH80
                WHERE (AUTHOR_JWS >= 60 OR AUTHOR_JWS_LEFT >=60 )
                      AND TITLE_JWS >= 95
                ) presult
            ON presult.dblp_id = pm.dblp_id and presult.citeseer_id = pm.citeseer_id   
    WHERE
      p.title LIKE 'X%' 
      and cp.title LIKE 'X%'  
      and (p.year <= 2010 or p.year is null)
      and (cp.year <= 2009 or cp.year is null);
--890

--True positives + False positives 
SELECT COUNT(*)
FROM (
  SELECT *
  FROM RESULT_MATCH80
  WHERE ((AUTHOR_JWS BETWEEN 85 AND 100) OR (AUTHOR_JWS_LEFT BETWEEN 85 AND 100))
        AND TITLE_JWS < 90
  UNION
  SELECT *
  FROM RESULT_MATCH80
  WHERE (AUTHOR_JWS >= 75 OR AUTHOR_JWS_LEFT >=75 )
        AND TITLE_JWS >= 90
  UNION
  SELECT *
  FROM RESULT_MATCH80
  WHERE (AUTHOR_JWS >= 60 OR AUTHOR_JWS_LEFT >=60 )
        AND TITLE_JWS >= 95
  ) presult
 INNER JOIN aercs_tt.paper dp
    on presult.dblp_id = dp.id
 INNER JOIN citeseer.paper cp
    on presult.citeseer_id = cp.id
where 
 (dp.year <= 2010 or dp.year is null)
      and (cp.year <= 2009 or cp.year is null);
--1899

--precision = 890/1899 = 0.4687



--True positives + False negatives 
SELECT COUNT(*)
FROM aercs_tt.paper_mapping pm
    INNER JOIN aercs_tt.paper p
              ON pm.DBLP_ID = p.ID
    INNER JOIN paper cp
              ON pm.CITESEER_ID = cp.id  
WHERE 
    p.title LIKE 'X%' 
    AND cp.title LIKE 'X%';  
--953

--recall = 890/953 = 0.9339

/*--------------------------------------------------------------------------------------------------------*/


/*---------------------- PRECISION AND RECALL FOR "CANOPY CLUSTERING" ------------------------------------*/



--True positives
SELECT COUNT(*)
FROM aercs_tt.paper_mapping pm
    INNER JOIN aercs_tt.paper p
              ON pm.DBLP_ID = p.ID
    INNER JOIN paper cp
              ON pm.CITESEER_ID = cp.id  
    INNER JOIN CANOPY_CITESEER_DBLP canopy
    ON canopy.dblp_id = pm.dblp_id and canopy.citeseer_id = pm.citeseer_id
    WHERE
      p.title LIKE 'X%' 
      AND cp.title LIKE 'X%'  
      AND (p.year <= 2010 OR p.year is null)
      AND (cp.year <= 2009 OR cp.year is null);  
--757

--True positives + False positives 
SELECT COUNT(*)
FROM CANOPY_CITESEER_DBLP canopy
INNER JOIN aercs_tt.paper dp
ON canopy.dblp_id = dp.id
INNER JOIN citeseer.paper cp
ON canopy.citeseer_id = cp.id
WHERE
 (dp.year <= 2010 OR dp.year IS NULL)
      and (cp.year <= 2009 OR cp.year IS NULL);
--1479

--precision = 757/1479 = 0.5118


--True positives + False negatives 
SELECT COUNT(*)
FROM aercs_tt.paper_mapping pm
    INNER JOIN aercs_tt.paper p
              ON pm.DBLP_ID = p.ID
    INNER JOIN paper cp
              ON pm.CITESEER_ID = cp.id  
WHERE p.title LIKE 'X%' AND cp.title LIKE 'X%';  
--953

--recall = 757/953 = 0.7943
/*--------------------------------------------------------------------------------------------------------*/