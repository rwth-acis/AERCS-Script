-- Create the table CANOPY_CITESEER_DBLP where the clusters will be put
CREATE TABLE CANOPY_CITESEER_DBLP
(
  CITESEER_ID NUMBER(10,0),
  DBLP_ID NUMBER(10,0),
  CANOPY_ID NUMBER(10,0)
);

-- Create the first set from CITESEER_PAPER_CURSOR
CREATE TABLE CITESEER_PAPER_CURSOR 
AS
SELECT  max(P.ID) as CITESEER_ID,
max(P.TITLE)||'.' as CITESEER_TITLE,
LISTAGG(TRIM(LOWER(SUBSTR(A.NAME,INSTR (A.NAME, ' ', -1)))), '') WITHIN GROUP (ORDER BY TRIM(LOWER(SUBSTR(A.NAME,INSTR (A.NAME, ' ', -1))))) as CITESEER_AUTHOR,
LISTAGG(TRIM(LOWER(SUBSTR(A.NAME,1,INSTR (A.NAME, ' ', 1)))), '') WITHIN GROUP (ORDER BY TRIM(LOWER(SUBSTR(A.NAME,1,INSTR (A.NAME, ' ', 1))))) as CITESEER_AUTHOR_LEFT
FROM CITESEER.AUTHOR_PAPER AP
            INNER JOIN CITESEER.AUTHOR A
                       ON AP.AUTHOR_ID = A.ID 
            INNER JOIN CITESEER.PAPER P
                       ON AP.PAPER_ID = P.ID
        WHERE P.TITLE LIKE 'X%'
        GROUP BY P.ID;

DECLARE 
  T1 INTEGER := '82'; -- Loose distance threshold
  T2 INTEGER := '89'; -- Tight distance threshold
  d_id NUMBER(10,0);
  d_title VARCHAR2(4000 BYTE);
  d_author VARCHAR2(4000 BYTE);
  canopy_id  NUMBER(10,0) := 1;


-- Create the cursor which will iterate on the second set (papers of DBLP)
CURSOR dblp_cursor 
IS
SELECT max(P.ID) as DBLP_ID,
max(P.TITLE) as DBLP_TITLE,
LISTAGG(TRIM(LOWER(SUBSTR(A.NAME,INSTR (A.NAME, ' ', -1)))), '') WITHIN GROUP (ORDER BY TRIM(LOWER(SUBSTR(A.NAME,INSTR (A.NAME, ' ', -1))))) as DBLP_AUTHOR
FROM AERCS_TT.AUTHOR_MEDIA AM
    INNER JOIN AERCS_TT.AUTHOR A
               ON AM.AUTHOR_ID = A.ID 
    INNER JOIN AERCS_TT.PAPER P
               ON AM.MEDIA_ID = P.ID
WHERE P.TITLE LIKE 'X%'
GROUP BY AM.MEDIA_ID;

-- START CURSOR ON DBLP 
-- IF T1 OK INSERT ALL INTO THE MATCH_TABLE
-- IF T2 OK REMOVE ALL FROM CITESEER_MAINTAIN
BEGIN
   OPEN dblp_cursor;
   LOOP
      FETCH dblp_cursor into d_id, d_title, d_author;
      EXIT WHEN dblp_cursor%notfound;
      
      -- For each point left in the set, assign it to the new canopy if the distance less than the loose distance T1
      INSERT INTO CANOPY_CITESEER_DBLP(CITESEER_ID,DBLP_ID,CANOPY_ID)
      SELECT C.CITESEER_ID, d_id, canopy_id
        FROM CITESEER.CITESEER_PAPER_CURSOR C
        WHERE UTL_MATCH.jaro_winkler_similarity(LOWER(d_title),LOWER(C.CITESEER_TITLE)) > T1
        AND( UTL_MATCH.jaro_winkler_similarity(C.CITESEER_AUTHOR,d_author) > T1
        OR UTL_MATCH.jaro_winkler_similarity(C.CITESEER_AUTHOR_LEFT,d_author) > T1);
        
      
      -- If the distance of the point is additionally less than the tight distance T2, remove it from the original set.
      DELETE FROM CITESEER.CITESEER_PAPER_CURSOR C
      WHERE UTL_MATCH.jaro_winkler_similarity(LOWER(d_title),LOWER(C.CITESEER_TITLE)) > T2
        AND( UTL_MATCH.jaro_winkler_similarity(C.CITESEER_AUTHOR,d_author) > T2
        OR UTL_MATCH.jaro_winkler_similarity(C.CITESEER_AUTHOR_LEFT,d_author) > T2);
      
      -- Set the cluster id for the next cluster
      canopy_id := canopy_id + 1;
      
   END LOOP;
   CLOSE dblp_cursor;
END;

  
select max(dp.id), max(cp.id), max(dp.title), max(cp.title),
LISTAGG(TRIM(LOWER(SUBSTR(da.NAME,INSTR (da.NAME, ' ', -1)))), '') WITHIN GROUP (ORDER BY TRIM(LOWER(SUBSTR(da.NAME,INSTR (da.NAME, ' ', -1))))) as DBLP_AUTHOR,
LISTAGG(TRIM(LOWER(SUBSTR(ca.NAME,INSTR (ca.NAME, ' ', -1)))), '') WITHIN GROUP (ORDER BY TRIM(LOWER(SUBSTR(ca.NAME,INSTR (ca.NAME, ' ', -1))))) as CITESEER_AUTHOR,
LISTAGG(TRIM(LOWER(SUBSTR(ca.NAME,1,INSTR (ca.NAME, ' ', 1)))), '') WITHIN GROUP (ORDER BY TRIM(LOWER(SUBSTR(ca.NAME,1,INSTR (ca.NAME, ' ', 1))))) as CITESEER_AUTHOR_LEFT
from aercs_tt.paper dp
      inner join citeseer.CANOPY_CITESEER_DBLP ccd
                  on dp.id = ccd.dblp_id
      inner join citeseer.paper cp
                  on ccd.citeseer_id = cp.id
      inner join citeseer.author_paper cap
                  on cap.paper_id = cp.id
      inner join citeseer.author ca
                  on cap.author_id = ca.id
      inner join aercs_tt.author_media am
                  on dp.id = am.media_id
      inner join aercs_tt.author da
                  on am.author_id = da.id
group by dp.id,cp.id;
                  