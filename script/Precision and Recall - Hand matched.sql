/*------------------ PRECISION AND RECALL FOR "TITLE FIRST AUTHOR SECOND" -----------------------------*/
--True positives
SELECT COUNT(*)
FROM "CITESEER"."HAND_MATCHED_DATASET"  pm
    INNER JOIN (
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
--812


--True positives + False positives 
SELECT COUNT(*)
FROM (
  SELECT *
  FROM RESULT_MATCH80
  WHERE (AUTHOR_JWS >= 75 OR AUTHOR_JWS_LEFT >=75 )
        AND TITLE_JWS >= 90
  UNION
  SELECT *
  FROM RESULT_MATCH80
  WHERE (AUTHOR_JWS >= 60 OR AUTHOR_JWS_LEFT >=60 )
        AND TITLE_JWS >= 95
 ) presult;


--872

--precision = 812/872 = 0.9312



--True positives + False negatives 
SELECT COUNT(*)
FROM "CITESEER"."HAND_MATCHED_DATASET" pm
--1038

--recall = 812/1038 = 0.7823

/*------------------------------------------------------------------------------------------------------*/


/*---------------------- PRECISION AND RECALL FOR "CANOPY CLUSTERING" ------------------------------------*/

select * from CANOPY_CITESEER_DBLP


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
      and cp.title LIKE 'X%'  
      and (p.year <= 2010 or p.year is null)
      and (cp.year <= 2009 or cp.year is null);
--757

--True positives + False positives 
SELECT COUNT(*)
FROM CANOPY_CITESEER_DBLP canopy
inner join aercs_tt.paper dp
on canopy.dblp_id = dp.id
inner join citeseer.paper cp
on canopy.citeseer_id = cp.id
where 
 (dp.year <= 2010 or dp.year is null)
      and (cp.year <= 2009 or cp.year is null);

--1479

--precision = 757/1479 = 0.5118


--True positives + False negatives 
SELECT COUNT(*)
FROM aercs_tt.paper_mapping pm
    INNER JOIN aercs_tt.paper p
              ON pm.DBLP_ID = p.ID
    INNER JOIN paper cp
              ON pm.CITESEER_ID = cp.id  
WHERE p.title LIKE 'X%' and cp.title LIKE 'X%';
--953

--recall = 757/953 = 0.7943