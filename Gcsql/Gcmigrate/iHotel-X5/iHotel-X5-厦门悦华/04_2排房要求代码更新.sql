DELETE FROM guest_feature;
DROP TABLE guest_feature;
CREATE TABLE guest_feature(
	NO		VARCHAR(12),
	accnt_new	BIGINT,
	feature		VARCHAR(40),
	feature1	VARCHAR(40),
	feature2	VARCHAR(40) NOT NULL DEFAULT '',
	feature_new	VARCHAR(40) NOT NULL DEFAULT ''
);
CREATE INDEX index1 ON guest_feature(NO);
CREATE INDEX index2 ON guest_feature(accnt_new);

DELETE FROM guest_feature;
SELECT * FROM guest_feature;
INSERT INTO guest_feature(NO,accnt_new,feature,feature1)
SELECT a.no,b.accnt_new,feature,CONCAT(a.feature,',') FROM migrate_xmyh.guest a,up_map_accnt b WHERE b.hotel_group_id = 1 AND b.hotel_id = 1 AND b.accnt_type = 'GUEST_FIT'  AND b.accnt_old = a.no AND a.feature <> '';

CALL up_ihotel_up_feature_transfer(1,1);
SELECT * FROM up_map_code WHERE hotel_id = 1 AND CODE = 'room_feature';

SELECT *   FROM guest_feature;

SELECT SUBSTRING(feature2,1,LENGTH(feature)-1)   FROM guest_feature;

SELECT *,SUBSTRING(feature2,1,LENGTH(feature2)-1) FROM guest_feature

UPDATE guest_feature SET feature_new = SUBSTRING(feature2,1,LENGTH(feature2)-1);

UPDATE guest_prefer a,guest_feature b SET a.feature = b.feature_new WHERE a.hotel_group_id = 1 AND a.hotel_id = 1
AND a.guest_id = b.accnt_new;

SELECT * FROM guest_prefer WHERE feature <> '';
