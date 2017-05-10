SELECT * FROM master_base WHERE hotel_group_id = 1 AND hotel_id = 1 AND id IN('10786','10784','10856');

SELECT * FROM migrate_xmyh.master WHERE MASTER IN(SELECT accnt FROM migrate_xmyh.master GROUP BY MASTER HAVING COUNT(1)> 1)

SELECT * FROM migrate_xmyh.master WHERE pcrec <> '' GROUP BY MASTER HAVING COUNT(1) > 1;


SELECT * FROM migrate_xmyh.master WHERE accnt = 'F306180032';

SELECT * FROM migrate_xmyh.master WHERE MASTER = 'F306080047';

DELETE FROM tmp_master;
CREATE TABLE tmp_master(
	MASTER	CHAR(12)
);
CREATE INDEX index1 ON tmp_master(MASTER);
INSERT INTO tmp_master(MASTER)
SELECT MASTER FROM migrate_xmyh.master   GROUP BY MASTER HAVING COUNT(1) > 1;

SELECT a.accnt,a.master,a.roomno,a.pcrec,a.sta FROM  migrate_xmyh.master a,tmp_master b WHERE a.master = b.master
AND a.pcrec = '' AND a.master IN
(SELECT a.master FROM  migrate_xmyh.master a,tmp_master b WHERE a.master = b.master
AND a.pcrec <> '' );


-- 
SELECT accnt,MASTER,pcrec FROM migrate_xmyh.master WHERE accnt = 'F411210291';

SELECT accnt,MASTER,pcrec  FROM migrate_xmyh.master WHERE MASTER = 'F411200265';

SELECT * FROM migrate_xmyh.master WHERE pcrec = 'F411180201';

SELECT accnt,MASTER,pcrec  FROM migrate_xmyh.master WHERE MASTER = 'F412010034';

SELECT a.id,a.master_id,a.link_id FROM master_base a,migrate_xmyh.master b WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND 
a.sc_flag = b.accnt AND (b.pcrec = 'F412050002' OR b.master = 'F412010034');