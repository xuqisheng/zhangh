CREATE INDEX index1 ON migrate_db.master(haccnt);
DELETE FROM tmp_map_accnt;
CREATE TABLE tmp_map_accnt(
	accnt	VARCHAR(15),
	haccnt	VARCHAR(10)
	
);
INSERT INTO tmp_map_accnt(accnt,haccnt)
SELECT a.accnt,a.haccnt FROM migrate_db.master a,up_map_accnt b WHERE b.hotel_group_id = 167 AND b.hotel_id = 10197 AND (b.accnt_type ='GUEST_FIT'
OR b.accnt_type = 'GUEST_GRP')
AND b.accnt_old = a.haccnt  ;

SELECT * FROM migrate_db.master WHERE haccnt NOT IN
(SELECT a.haccnt FROM tmp_map_accnt a)

SELECT * FROM migrate_db.master a WHERE a.haccnt NOT IN(SELECT accnt_old FROM up_map_accnt WHERE hotel_group_id = 167
AND hotel_id = 10197 AND (accnt_type = 'GUEST_FIT' OR accnt_type = 'GUEST_GRP'))