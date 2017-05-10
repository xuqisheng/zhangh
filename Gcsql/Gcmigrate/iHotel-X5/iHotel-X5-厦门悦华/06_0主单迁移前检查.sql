CREATE INDEX index2 ON migrate_xmyh.master(haccnt);
DELETE FROM tmp_map_accnt;
CREATE TABLE tmp_map_accnt(
	accnt	VARCHAR(15),
	haccnt	VARCHAR(10)
	
);
INSERT INTO tmp_map_accnt(accnt,haccnt)
SELECT a.accnt,a.haccnt FROM migrate_xmyh.master a,up_map_accnt b WHERE b.hotel_group_id = 1 AND b.hotel_id = 1 AND (b.accnt_type ='GUEST_FIT'
OR b.accnt_type = 'GUEST_GRP')
AND b.accnt_old = a.haccnt  ;

SELECT * FROM migrate_xmyh.master WHERE haccnt NOT IN
(SELECT a.haccnt FROM tmp_map_accnt a)

SELECT * FROM migrate_xmyh.master a WHERE a.haccnt NOT IN(SELECT accnt_old FROM up_map_accnt WHERE hotel_group_id = 1
AND hotel_id = 1 AND (accnt_type = 'GUEST_FIT' OR accnt_type = 'GUEST_GRP'))

SELECT * FROM account WHERE accnt = 12449;

	SELECT b.hotel_group_id,b.hotel_id,b.accnt_new,0,a.number,a.inumber,'02',a.bdate,a.date,a.pccode,
			'','',1,a.charge,0,0,0,0,0,0,
			0,0,a.credit,0,a.shift,a.crradjt,'','','',a.tofrom,a.accntof,NULL,
			a.ref,a.ref,a.ref1,a.ref2,a.roomno,a.groupno,a.mode,IF(a.billno='','',SUBSTR(a.billno,1,1)),IF(a.billno='',NULL,'-1'),'','',NULL,
			NULL,'',NULL,a.empno,a.log_date,a.empno,a.log_date,NULL,NULL
			FROM migrate_xmyh.account a,up_map_accnt b 
			WHERE a.accnt=b.accnt_old AND b.hotel_group_id=1 AND b.hotel_id=1 AND b.accnt_type IN ('master_si','master_r','consume')
			AND  a.accnt = 'F411220120';
			SELECT * FROM up_map_accnt WHERE accnt_type = 'master_si' AND accnt_old = 'F411220120'