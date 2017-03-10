CREATE TABLE hgstinf_fir(
	NO	VARCHAR(10),
	NAME	VARCHAR(30),
	fir	VARCHAR(100),
	accnt	VARCHAR(10),
	accnt2	BIGINT
)
CREATE INDEX index1 ON hgstinf_fir(accnt2);
INSERT INTO hgstinf_fir(NO,NAME,fir,accnt,accnt2)
SELECT a.no,a.name,a.fir,b.accnt_old,b.accnt_new FROM migrate_gm.hgstinf a,up_map_accnt b WHERE b.hotel_group_id = 2 AND b.hotel_id = 15 AND 
b.accnt_type = 'GUEST_FIT' AND b.accnt_old = a.no AND a.fir <> '';

SELECT * FROM hgstinf_fir ;
SELECT COUNT(1) FROM hgstinf_fir ; -- 63701 - 725

DELETE   a  FROM hgstinf_fir a,guest_prefer b WHERE  
b.hotel_group_id = 2 AND b.hotel_id = 15 AND
b.guest_id =  a.accnt2;

SELECT a.*,b.* FROM guest_prefer a,hgstinf_fir b WHERE a.hotel_group_id = 2 AND a.hotel_id = 15
AND a.guest_id = b.accnt2;

SELECT * FROM guest_prefer WHERE hotel_id = 15;


INSERT INTO `portal`.`guest_prefer` (`hotel_group_id`, `hotel_id`, 	`guest_id`, `specials`, `amenity`, 
	`feature`, `room_prefer`, `interest`, `prefer_front`, `prefer_fb`, 
	`prefer_other`, `create_user`, `create_datetime`, `modify_user`, 
	`modify_datetime`)
SELECT  2,15, accnt2, '', NULL,	NULL,NULL,NULL,CONCAT(fir,'==='), '','', 'ADMIN', NOW(),'ADMIN', NOW()
FROM hgstinf_fir;

SELECT a.id,a.name,a.profile_id,a.name,a.interest,b.guest_id,b.prefer_front FROM master_guest a,guest_prefer b
WHERE a.hotel_group_id = 2 AND a.hotel_id = 15 AND b.hotel_group_id = 2 AND b.hotel_id = 15
AND a.profile_id = b.guest_id AND a.interest = '';
 
UPDATE master_guest a,guest_prefer b SET a.interest = b.prefer_front
WHERE a.hotel_group_id = 2 AND a.hotel_id = 15 AND b.hotel_group_id = 2 AND b.hotel_id = 15
AND a.profile_id = b.guest_id AND a.interest = '';

