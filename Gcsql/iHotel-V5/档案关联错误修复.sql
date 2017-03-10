DROP TABLE profile_haccnt;
CREATE TABLE profile_haccnt
(	accnt	VARCHAR(10),
	sta	VARCHAR(2),
	roomno	VARCHAR(5),
	accnt2	VARCHAR(10),
	NAME	VARCHAR(50),
	haccnt	VARCHAR(10),
	accnt_old	VARCHAR(10),
	accnt_new	BIGINT
)
CREATE INDEX index1 ON ()
INSERT INTO profile_haccnt(accnt,sta,roomno,accnt2,NAME,haccnt,accnt_old,accnt_new)
SELECT a.accnt,a.sta,a.roomno,b.accnt,b.name,b.haccnt ,c.accnt_old,c.accnt_new FROM migrate_gm.master a ,migrate_gm.guest b,up_map_accnt c WHERE a.accnt = b.accnt
AND c.hotel_group_id = 2 AND c.hotel_id = 15 AND c.accnt_type = 'GUEST_FIT' AND c.accnt_old = b.haccnt;

SELECT a.id,a.rmno,a.rmtype,b.id,b.profile_id,a.crs_no,c.accnt,c.accnt_old,c.accnt_new FROM master_base a,master_guest b,profile_haccnt c WHERE a.hotel_group_id = 2 AND a.hotel_id = 15 AND b.hotel_group_id = 2 
AND b.hotel_id = 15 AND a.id = b.id  AND a.crs_no = c.accnt AND a.sta = 'I';

UPDATE master_base a,master_guest b,profile_haccnt c SET b.profile_id = c.accnt_new
WHERE a.hotel_group_id = 2 AND a.hotel_id = 15 AND b.hotel_group_id = 2 
AND b.hotel_id = 15 AND a.id = b.id  AND a.crs_no = c.accnt  ;

SELECT * FROM up_map_accnt WHERE hotel_group_id = 2 AND hotel_id = 15 AND accnt_new = 855991;
SELECT * FROM up_map_accnt WHERE hotel_group_id = 2 AND hotel_id = 15 AND accnt_new = 947140;

SELECT a.id,a.rmno,a.sta,a.rmtype,b.id,b.name,b.profile_id,a.crs_no FROM master_base a,master_guest b  WHERE a.hotel_group_id = 2 AND a.hotel_id = 15 AND b.hotel_group_id = 2 
AND b.hotel_id = 15 AND a.id = b.id  