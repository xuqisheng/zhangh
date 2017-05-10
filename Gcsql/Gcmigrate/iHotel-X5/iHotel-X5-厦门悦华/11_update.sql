-- 预订号补全：否则入住页面有问题
UPDATE master_base SET rsv_no=crs_no WHERE hotel_group_id = 1 AND hotel_id = 1 AND (rsv_no='' OR rsv_no IS NULL ) AND NOT (crs_no='' OR crs_no IS NULL); 
UPDATE master_base SET rsv_no=TRIM(CONVERT(id,CHAR(20))) WHERE hotel_group_id = 1 AND hotel_id = 1 AND (rsv_no='' OR rsv_no IS NULL );
-- 优化纯预留离日到日
UPDATE rsv_src SET rsv_arr_date = DATE_ADD(rsv_arr_date,INTERVAL 18 HOUR) WHERE hotel_group_id = 1 AND hotel_id = 1 AND EXTRACT(HOUR FROM rsv_arr_date) = 0;
UPDATE rsv_src SET rsv_dep_date = DATE_ADD(rsv_dep_date,INTERVAL 12 HOUR) WHERE hotel_group_id = 1 AND hotel_id = 1 AND EXTRACT(HOUR FROM rsv_dep_date) = 0;
SELECT rsv_arr_date, rsv_dep_date FROM rsv_src WHERE hotel_group_id= 1 AND hotel_id=1;    


-- 更新 master_base.rsv_man 预订人
UPDATE master_base a,master_guest b SET a.rsv_man=b.name WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.id=b.id AND a.rsv_man='';	
-- 房类修改
-- UPDATE master_base a,up_map_code b SET a.rmtype = b.code_new WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND b.hotel_group_id = 1 AND b.hotel_id = 1 AND b.code = 'rmtype' AND a.rmtype = b.code_old;
-- UPDATE rsv_src a,up_map_code b SET a.rmtype = b.code_new WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND b.hotel_group_id = 1 AND b.hotel_id = 1 AND b.code = 'rmtype' AND a.rmtype = b.code_old;

-- UPDATE master_base a,up_map_code b SET a.up_rmtype = b.code_new WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND b.hotel_group_id = 1 AND b.hotel_id = 1 AND b.code = 'rmtype' AND a.up_rmtype = b.code_old AND a.up_rmtype<>'';
-- UPDATE rsv_src a,up_map_code b SET a.up_rmtype = b.code_new WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND b.hotel_group_id = 1 AND b.hotel_id = 1 AND b.code = 'rmtype' AND a.up_rmtype = b.code_old AND a.up_rmtype<>'';
-- 楼栋修改
UPDATE master_base a,room_no b SET a.building = b.building WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND b.hotel_group_id = 1 AND b.hotel_id = 1 AND a.rmtype = b.rmtype;
-- 生日修改
UPDATE master_guest SET birth = NULL WHERE hotel_group_id = 1 AND hotel_id = 1 AND birth='0000-00-00 00:00:00';
-- 信用部分(小陈哥说number要减一)	
DELETE FROM accredit WHERE hotel_group_id = 1 AND hotel_id = 1;	
INSERT INTO accredit(hotel_group_id,hotel_id,accnt,accnt_type,number,ta_code,card_no,expiry_date,cur_exchg_no,
		auth_no,amount,amount_foreign,amount_use,tag,create_user,create_biz_date,create_cashier,create_datetime,
		use_user,use_biz_date,use_cashier,use_datetime,partout_flag,close_id,modify_user,modify_datetime,is_online)
SELECT a.hotel_group_id,a.hotel_id,a.id,'F',c.number - 1,c.pccode,c.cardno,c.expiry_date,'',c.creditno,
		c.amount,0,0,'R',c.empno1,c.bdate1,CONVERT(c.shift1,SIGNED),c.log_date1,NULL,NULL,NULL,NULL,
		NULL,NULL,c.empno1,c.log_date1,'F'
		FROM master_base a,up_map_accnt b,migrate_xmyh.accredit c
		WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND b.hotel_group_id = 1 AND b.hotel_id = 1 
		AND a.sta IN('I','S','O') AND a.id=b.accnt_new AND b.accnt_type='master_si' AND b.accnt_old=c.accnt AND c.tag='0'
UNION ALL
SELECT a.hotel_group_id,a.hotel_id,a.id,'R',c.number - 1,c.pccode,c.cardno,c.expiry_date,'',c.creditno,
		c.amount,0,0,'R',c.empno1,c.bdate1,CONVERT(c.shift1,SIGNED),c.log_date1,NULL,NULL,NULL,NULL,
		NULL,NULL,c.empno1,c.log_date1,'F'
		FROM master_base a,up_map_accnt b,migrate_xmyh.accredit c
		WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND b.hotel_group_id = 1 AND b.hotel_id = 1 
		AND a.sta IN('R','X','N') AND a.id=b.accnt_new AND b.accnt_type='master_r' AND b.accnt_old=c.accnt AND c.tag='0'
UNION ALL
SELECT a.hotel_group_id,a.hotel_id,a.id,'F',c.number - 1,c.pccode,c.cardno,c.expiry_date,'',c.creditno,
		c.amount,0,0,'R',c.empno1,c.bdate1,CONVERT(c.shift1,SIGNED),c.log_date1,NULL,NULL,NULL,NULL,
		NULL,NULL,c.empno1,c.log_date1,'F'
		FROM master_base a,up_map_accnt b,migrate_xmyh.accredit c
		WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND b.hotel_group_id = 1 AND b.hotel_id = 1 
		AND a.sta IN('R','X','N','I','S','O') AND a.id=b.accnt_new AND b.accnt_type='consume' AND b.accnt_old=c.accnt AND c.tag='0'		
UNION ALL
SELECT a.hotel_group_id,a.hotel_id,a.id,'A',c.number -1 ,c.pccode,c.cardno,c.expiry_date,'',c.creditno,
		c.amount,0,0,'R',c.empno1,c.bdate1,CONVERT(c.shift1,SIGNED),c.log_date1,NULL,NULL,NULL,NULL,
		NULL,NULL,c.empno1,c.log_date1,'F'
		FROM ar_master a,up_map_accnt b,migrate_xmyh.accredit c
		WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND b.hotel_group_id = 1 AND b.hotel_id = 1
		AND a.sta IN ('I','O') AND a.id = b.accnt_new AND b.accnt_type='armst' AND b.accnt_old=c.accnt AND c.tag='0';

UPDATE accredit a,up_map_code b SET a.ta_code=b.code_new WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND b.hotel_group_id = 1 AND b.hotel_id = 1 AND b.code='paymth' AND a.ta_code=b.code_old;
SELECT * FROM accredit WHERE accnt = 11189;
SELECT * FROM accredit WHERE accnt = 11190;

-- select sum(charge-pay) from master_base where hotel_id = 1;
-- select sum(charge - pay) from account where hotel_group_id = 1 and hotel_id = 1;
-- -- 主单余额，定金修复		
UPDATE master_base a SET a.charge=IFNULL((SELECT SUM(b.charge) FROM account b WHERE a.id=b.accnt AND b.hotel_group_id = 1 AND b.hotel_id = 1),0) WHERE a.hotel_group_id = 1 AND a.hotel_id = 1;
UPDATE master_base a SET a.pay=IFNULL((SELECT SUM(b.pay) FROM account b WHERE a.id=b.accnt AND b.hotel_group_id = 1 AND b.hotel_id = 1),0) WHERE a.hotel_group_id = 1 AND a.hotel_id = 1;
UPDATE master_base a SET a.credit=IFNULL((SELECT SUM(b.amount) FROM accredit b WHERE a.id=b.accnt AND (b.accnt_type='F' OR b.accnt_type = 'R') AND b.hotel_group_id = 1 AND b.hotel_id = 1),0) WHERE a.hotel_group_id = 1 AND a.hotel_id = 1;


SELECT * FROM accredit WHERE hotel_id = 1;
-- AR主单信用修复
UPDATE ar_master a SET a.credit=IFNULL((SELECT SUM(b.amount) FROM accredit b WHERE a.id=b.accnt AND b.accnt_type='A' AND b.hotel_group_id = 1 AND b.hotel_id = 1),0) WHERE a.hotel_group_id = 1 AND a.hotel_id = 1;


-- 修复相关代码
UPDATE master_base SET pay_code ='CA' WHERE hotel_group_id = 1 AND hotel_id = 1 AND pay_code = '';
-- UPDATE master_base SET market = 'RAC' WHERE hotel_group_id = 1 AND hotel_id = 1 AND market = '';
-- UPDATE master_base SET src = 'WKG' WHERE hotel_group_id = 1 AND hotel_id = 1 AND src = '';
-- UPDATE master_base SET ratecode = 'RAC' WHERE hotel_group_id = 1 AND hotel_id = 1 AND ratecode = '';
-- UPDATE master_base a,up_map_code b SET a.salesman = b.code_new WHERE b.code = 'salesman' AND a.salesman = b.code_old AND a.salesman<>'' AND b.hotel_group_id = 1 AND b.hotel_id = 1 AND a.hotel_group_id=b.hotel_group_id AND a.hotel_id = 0;
-- UPDATE master_base a,up_map_code b SET a.pay_code = b.code_new WHERE a.pay_code = b.code_old AND b.code='paymth' AND a.hotel_group_id = 1 AND a.hotel_id = 1 AND b.hotel_group_id = 1 AND b.hotel_id = 1;
-- UPDATE master_base SET pay_code = 'CA' WHERE pay_code = '' AND hotel_group_id = 1 AND hotel_id = 1;
-- UPDATE master_base SET dsc_reason = 'OO' WHERE hotel_group_id = 1 AND hotel_id = 1 AND rack_rate <> real_rate AND dsc_reason = '' ;	
-- 修复打开团队主单账务时报错	
UPDATE master_base SET  master_id = id ,grp_accnt = id WHERE hotel_group_id = 1 AND hotel_id = 1 AND rsv_class = 'G';
UPDATE master_base SET crs_no='' WHERE hotel_group_id = 1 AND hotel_id = 1 AND rsv_no=crs_no;
-- 费用码和付款码中英对照翻译
UPDATE account a,code_transaction b SET a.ta_descript_en = b.descript_en WHERE a.ta_code=b.code AND a.ta_code <> '' AND a.hotel_group_id = 1 AND a.hotel_id = 1 AND b.hotel_group_id = 1 AND b.hotel_id = 1;

-- 产生允许记账
-- new 导入西软的subaccnt
SELECT * FROM master_base a ,up_map_accnt b WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND
a.id = b.accnt_new AND b.hotel_group_id = 1 AND b.hotel_id = 1
AND (b.accnt_type = 'master_r' OR b.accnt_type = 'master_si');

SELECT * FROM account_sub a ,up_map_accnt b WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND a.accnt_type = 'MASTER' AND a.type = 'POSTING'
AND a.accnt = b.accnt_new AND b.hotel_group_id = 1 AND b.hotel_id = 1
AND (b.accnt_type = 'master_r' OR b.accnt_type = 'master_si');
DELETE a FROM account_sub a ,up_map_accnt b WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND a.accnt_type = 'MASTER' AND a.type = 'POSTING'
AND a.accnt = b.accnt_new AND b.hotel_group_id = 1 AND b.hotel_id = 1
AND (b.accnt_type = 'master_r' OR b.accnt_type = 'master_si');

INSERT INTO account_sub (hotel_group_id,hotel_id,TYPE,tag,accnt_type,accnt,rmno,guest_id,to_accnt_type,to_accnt,to_rmno,NAME,
		ta_codes,pay_code,begin_datetime,end_datetime,remark,create_user,create_datetime,modify_user,modify_datetime)
	SELECT 1,1,'POSTING','USER','MASTER',a.id,'',NULL,NULL,NULL,'','',
		IF(c.pccodes='','.',c.pccodes),'',a.arr,a.dep,'','ADMIN',NOW(),'ADMIN',NOW()
	FROM master_base a,up_map_accnt b,migrate_xmyh.subaccnt c WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND a.sta IN ('I','S','O','R')
	AND a.id = b.accnt_new AND b.hotel_group_id = 1 AND b.hotel_id = 1 AND b.accnt_type IN('master_r','master_si') AND b.accnt_old = c.accnt
	AND c.accnt NOT LIKE 'AR%' AND c.type = '0'
	AND a.id NOT IN (SELECT c.accnt FROM account_sub c WHERE c.hotel_group_id = 1 AND c.hotel_id = 1 AND c.type='POSTING');  

UPDATE master_base SET extra_flag='001000000000000000000000000000' WHERE hotel_group_id = 1 AND hotel_id = 1 AND sta IN ('I','S','O','R');

UPDATE master_base a,account_sub b SET a.extra_flag='000000000000000000000000000000' WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND a.id = b.accnt
AND b.hotel_group_id = 1 AND b.hotel_id = 1 AND b.type = 'POSTING' AND b.accnt_type = 'MASTER' AND b.ta_codes = '.' AND
a.sta IN ('I','S','O','R');

UPDATE master_base a,account_sub b SET a.extra_flag='002000000000000000000000000000' WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND a.id = b.accnt
AND b.hotel_group_id = 1 AND b.hotel_id = 1 AND b.type = 'POSTING' AND b.accnt_type = 'MASTER' AND b.ta_codes NOT IN('.','*') AND
a.sta IN ('I','S','O','R');
SELECT * FROM master_base WHERE hotel_group_id = 1 AND hotel_id = 1 AND LENGTH(extra_flag) <> 30;

-- new end -------	
	
/*INSERT INTO account_sub (hotel_group_id,hotel_id,TYPE,tag,accnt_type,accnt,rmno,guest_id,to_accnt_type,to_accnt,to_rmno,NAME,
		ta_codes,pay_code,begin_datetime,end_datetime,remark,create_user,create_datetime,modify_user,modify_datetime)
	SELECT 1,1,'POSTING','','MASTER',id,'',0,NULL,NULL,'','',
		'*','',arr,dep,'','ADMIN',NOW(),'ADMIN',NOW()
	FROM master_base WHERE hotel_group_id = 1 AND hotel_id = 1 AND sta IN ('I','S','O','R')
	AND id NOT IN (SELECT c.accnt FROM account_sub c WHERE c.hotel_group_id = 1 AND c.hotel_id = 1 AND c.type='POSTING');  

UPDATE master_base SET extra_flag='001000000000000000000000000000',posting_flag ='1' WHERE hotel_group_id = 1 AND hotel_id = 1 AND sta IN ('I','S','O');
*/
/*
INSERT INTO account_sub (hotel_group_id,hotel_id,TYPE,tag,accnt_type,accnt,rmno,guest_id,to_accnt_type,to_accnt,to_rmno,NAME,
		ta_codes,pay_code,begin_datetime,end_datetime,remark,create_user,create_datetime,modify_user,modify_datetime)
SELECT 1,1,'POSTING','USER','RESRV',id,'',0,NULL,NULL,'','',
		'*','',arr,dep,'','ADMIN',NOW(),'ADMIN',NOW()
	FROM master_base WHERE hotel_group_id=1 AND hotel_id=1 AND sta IN ('R','X','N')
	AND id NOT IN (SELECT c.accnt FROM account_sub c WHERE c.hotel_group_id=1 AND c.hotel_id=1 AND c.type='POSTING');  
UPDATE master_base SET extra_flag='001000000000000000000000000000'  WHERE hotel_group_id = 1 AND hotel_id = 1 AND sta IN ('R','X','N');
*/ 
UPDATE account_sub SET accnt_type = 'MASTER' WHERE hotel_group_id = 1 AND hotel_id = 1 AND accnt_type = 'consume';

-- 产生基本分账户
-- new
 INSERT INTO account_sub (hotel_group_id,hotel_id,TYPE,tag,accnt_type,accnt,rmno,guest_id,to_accnt_type,to_accnt,to_rmno,NAME,
			  ta_codes,pay_code,begin_datetime,end_datetime,remark,create_user,create_datetime,modify_user,modify_datetime)
	SELECT 1,1,'SUBACCNT','SYS_FIX','MASTER',id,'',0,NULL,NULL,'','',
		'*','',arr,dep,'','ADMIN',NOW(),'ADMIN',NOW()
	FROM master_base WHERE hotel_group_id = 1 AND hotel_id = 1
	AND id NOT IN (SELECT c.accnt FROM account_sub c WHERE c.hotel_group_id = 1 AND c.hotel_id = 1 AND c.type='SUBACCNT' AND c.tag='SYS_FIX');  

UPDATE account_sub a,master_guest b SET a.name=b.name,a.guest_id = b.profile_id
	WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND b.hotel_group_id = 1 AND b.hotel_id = 1
	AND a.accnt=b.id AND a.type='SUBACCNT' AND a.tag='SYS_FIX' ;

 INSERT INTO account_sub (hotel_group_id,hotel_id,TYPE,tag,accnt_type,accnt,rmno,guest_id,to_accnt_type,to_accnt,to_rmno,NAME,
			  ta_codes,pay_code,begin_datetime,end_datetime,remark,create_user,create_datetime,modify_user,modify_datetime)
	SELECT 1,1,'SUBACCNT','USER','MASTER',a.id,'30',66,NULL,NULL,'',c.name,
		c.pccodes,'',c.starting_time,c.closing_time,c.ref,c.cby,c.changed,c.cby,c.changed
	FROM master_base a,up_map_accnt b,migrate_xmyh.subaccnt c WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND a.id = b.accnt_new AND b.hotel_group_id = 1 AND b.hotel_id = 1 
	AND b.accnt_type IN('master_r','master_si') AND b.accnt_old = c.accnt AND c.type = '5' AND c.tag = '2'
	AND a.id NOT IN (SELECT c.accnt FROM account_sub c WHERE c.hotel_group_id = 1 AND c.hotel_id = 1 AND c.type='SUBACCNT' AND c.tag='USER');  

SELECT a.id,a.rmno,a.extra_flag,LENGTH(CONCAT(SUBSTRING(a.extra_flag,1,4),b.num,SUBSTRING(a.extra_flag,6,25))) FROM master_base a,(SELECT accnt,COUNT(1) AS num FROM account_sub WHERE hotel_group_id = 1 AND hotel_id = 1 AND TYPE = 'SUBACCNT' AND tag = 'USER' GROUP BY accnt ) b 
WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND a.id = b.accnt;
-- 费用码替换
-- SELECT DISTINCT pccodes FROM migrate_xmyh.subaccnt WHERE TYPE = '5' AND tag = '2';
-- select distinct ta_codes FROM account_sub WHERE hotel_group_id = 1 AND hotel_id = 1 AND TYPE = 'SUBACCNT' AND tag = 'USER';
-- select replace(ta_codes,'1000','0001') from account_sub where hotel_group_id = 1 and hotel_id = 1 and type = 'SUBACCNT' and tag = 'USER';
-- update account_sub set ta_codes = replace(ta_codes,'1000','1000') WHERE hotel_group_id = 1 AND hotel_id = 1 AND TYPE = 'SUBACCNT' AND tag = 'USER';
 SELECT LENGTH('001000000000000000000000000000')

UPDATE master_base a,(SELECT accnt,COUNT(1) AS num FROM account_sub WHERE hotel_group_id = 1 AND hotel_id = 1 AND TYPE = 'SUBACCNT' AND tag = 'USER' GROUP BY accnt ) b SET a.extra_flag = CONCAT(SUBSTRING(a.extra_flag,1,4),b.num,SUBSTRING(a.extra_flag,6,25))
WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND a.id = b.accnt;

SELECT  * FROM master_base WHERE LENGTH(extra_flag) <> 30;
-- new end ------------
-- INSERT INTO account_sub (hotel_group_id,hotel_id,TYPE,tag,accnt_type,accnt,rmno,guest_id,to_accnt_type,to_accnt,to_rmno,NAME,
-- 		ta_codes,pay_code,begin_datetime,end_datetime,remark,create_user,create_datetime,modify_user,modify_datetime)
-- 	SELECT 1,1,'POSTING','USER','RESRV',id,'',0,NULL,NULL,'','',
-- 		'*','',arr,dep,'','ADMIN',NOW(),'ADMIN',NOW()
-- 	FROM master_base WHERE hotel_group_id = 1 AND hotel_id = 1 AND sc_flag<>'' AND sc_flag IS NOT NULL AND sta IN ('R','X','N'); 
-- 
-- INSERT INTO account_sub (hotel_group_id,hotel_id,TYPE,tag,accnt_type,accnt,rmno,guest_id,to_accnt_type,to_accnt,to_rmno,NAME,
-- 		ta_codes,pay_code,begin_datetime,end_datetime,remark,create_user,create_datetime,modify_user,modify_datetime)
-- 	SELECT 1,1,'POSTING','USER','MASTER',id,'',0,NULL,NULL,'','',
-- 		'*','',arr,dep,'','ADMIN',NOW(),'ADMIN',NOW()
-- 	FROM master_base WHERE hotel_group_id = 1 AND hotel_id = 1 AND sc_flag<>'' AND sc_flag IS NOT NULL AND sta IN ('I','S','O'); 
-- 
/*INSERT INTO account_sub (hotel_group_id,hotel_id,TYPE,tag,accnt_type,accnt,rmno,guest_id,to_accnt_type,to_accnt,to_rmno,NAME,
			  ta_codes,pay_code,begin_datetime,end_datetime,remark,create_user,create_datetime,modify_user,modify_datetime)
	SELECT 1,1,'SUBACCNT','SYS_FIX','MASTER',id,'',0,NULL,NULL,'','',
		'*','',arr,dep,'','ADMIN',NOW(),'ADMIN',NOW()
	FROM master_base WHERE hotel_group_id = 1 AND hotel_id = 1
	AND id NOT IN (SELECT c.accnt FROM account_sub c WHERE c.hotel_group_id = 1 AND c.hotel_id = 1 AND c.type='SUBACCNT' AND c.tag='SYS_FIX');  

UPDATE account_sub a,master_guest b SET a.name=b.name 
	WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND b.hotel_group_id = 1 AND b.hotel_id = 1
	AND a.accnt=b.id AND a.type='SUBACCNT' AND a.tag='SYS_FIX' ;
*/
-- 产生团体付费
 
-- 团体付费 
 INSERT INTO account_sub (hotel_group_id,hotel_id,TYPE,tag,accnt_type,accnt,rmno,guest_id,to_accnt_type,to_accnt,to_rmno,NAME,
			  ta_codes,pay_code,begin_datetime,end_datetime,remark,create_user,create_datetime,modify_user,modify_datetime)
	SELECT 1,1,'SUBACCNT','SYS_MOD','MASTER',id,rmno,NULL,'FO',grp_accnt,'','团体付费',
		'.','','2000-01-01','2050-01-01','团体付费','ADMIN',NOW(),'ADMIN',NOW()
	FROM master_base WHERE hotel_group_id = 1 AND hotel_id = 1 AND id <> rsv_id AND grp_accnt <> 0
	AND id NOT IN (SELECT c.accnt FROM account_sub c WHERE c.hotel_group_id = 1 AND c.hotel_id = 1 AND c.type='SUBACCNT' AND c.tag='SYS_MOD');  


SELECT 1,1,'SUBACCNT','SYS_MOD','MASTER',id,rmno,NULL,'FO',grp_accnt,'','团体付费',
	'.','','2000-01-01','2050-01-01','团体付费','ADMIN',NOW(),'ADMIN',NOW()
FROM master_base WHERE hotel_group_id = 1 AND hotel_id = 1 AND id <> rsv_id AND grp_accnt <> 0
AND id   IN (SELECT c.accnt FROM account_sub c WHERE c.hotel_group_id = 1 AND c.hotel_id = 1 AND c.type='SUBACCNT' AND c.tag='SYS_MOD');  


SELECT * FROM master_base WHERE hotel_group_id = 1 AND hotel_id = 1 AND id <> rsv_id
AND grp_accnt <> 0;



  -- 修复 master_base 中的 rsv_id,master_id	
UPDATE master_base a,rsv_src b SET a.rsv_id=a.id WHERE a.hotel_group_id = 1 AND a.hotel_id = 1
	AND b.hotel_group_id = 1 AND b.hotel_id = 1 AND a.sta='R' AND a.id=b.accnt AND b.occ_flag IN ('RF','RG');
	
UPDATE master_base SET rsv_id = id WHERE hotel_group_id = 1 AND hotel_id = 1 AND sta IN ('I','O','S','R') AND rsv_class='G';
UPDATE master_base SET master_id=id WHERE hotel_group_id = 1 AND hotel_id = 1 AND sta='R' AND rsv_class<>'H';

-- 更新包价
-- UPDATE master_base a ,up_map_code b SET a.packages = b.code_new WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND b.hotel_group_id = 1 AND b.hotel_id = 1 AND b.code = 'package' AND a.packages = b.code_old;	
-- UPDATE rsv_src a ,up_map_code b SET a.packages = b.code_new WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND b.hotel_group_id = 1 AND b.hotel_id = 1 AND b.code = 'package' AND a.packages = b.code_old;		

-- 修复同住
UPDATE master_base a,up_map_accnt b,migrate_xmyh.master c,up_map_accnt d SET master_id=d.accnt_new
WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND b.hotel_group_id = 1 
	AND b.hotel_id = 1 AND d.hotel_group_id = 1 AND d.hotel_id = 1
	AND a.id=b.accnt_new AND (b.accnt_type ='master_si' OR b.accnt_type = 'master_r')AND (d.accnt_type ='master_si' OR d.accnt_type ='master_r')  
	AND b.accnt_old=c.accnt AND c.master<>'' AND c.master = d.accnt_old;

-- 修复联房
	UPDATE master_base a,up_map_accnt b,migrate_xmyh.master c,up_map_accnt d
	SET a.link_id=d.accnt_new 
		WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 
		AND b.hotel_group_id = 1 AND b.hotel_id = 1 
		AND d.hotel_group_id = 1 AND d.hotel_id = 1 
		AND a.id=b.accnt_new AND b.accnt_type IN ('master_si','master_r','consume') 
		AND c.pcrec=d.accnt_old AND d.accnt_type IN ('master_si','master_r','consume') 
		AND b.accnt_old=c.accnt AND c.pcrec<>''; 

 
 
-- 团队主单与成员的信息关联
UPDATE master_base SET grp_accnt = id WHERE hotel_group_id = 1 AND hotel_id = 1 AND rsv_class = 'G';

UPDATE master_base a,up_map_accnt b,migrate_xmyh.master c,up_map_accnt d SET a.grp_accnt=d.accnt_new,a.rsv_id=d.accnt_new
WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND b.hotel_group_id = 1 AND b.hotel_id = 1
	AND d.hotel_group_id = 1 AND d.hotel_id = 1 AND a.id=b.accnt_new AND b.accnt_type IN ('master_si','master_r') AND d.accnt_type IN ('master_si','master_r') 
	AND b.accnt_old=c.accnt AND c.groupno=d.accnt_old;	
-- 更改团队成员是否预订单
SELECT * FROM master_base WHERE hotel_group_id = 1 AND hotel_id = 1 AND grp_accnt > 0 AND
id <> rsv_id AND is_resrv = 'T';
UPDATE master_base SET is_resrv = 'F' WHERE hotel_group_id = 1 AND hotel_id = 1 AND grp_accnt > 0 AND
id <> rsv_id AND is_resrv = 'T';
 -- 补录 master_base.is_resrv
SELECT * FROM master_base WHERE rsv_class IN ('F','G') AND id = rsv_id AND is_resrv = 'F'; 
UPDATE master_base SET is_resrv = 'T' WHERE rsv_class IN ('F','G') AND id = rsv_id AND is_resrv = 'F'; 

-- 处理合并结账的 arrange_code,防止夜审报错
UPDATE account SET arrange_code = '99' WHERE ta_code='9' AND arrange_code='' AND hotel_group_id = 1 AND hotel_id = 1;
	
-- 为重建房价准备
DELETE FROM rsv_rate WHERE hotel_group_id = 1 AND hotel_id = 1;
UPDATE rsv_src SET rack_rate=0 WHERE hotel_group_id = 1 AND hotel_id = 1 AND rack_rate IS NULL;
UPDATE rsv_src SET nego_rate=0 WHERE hotel_group_id = 1 AND hotel_id = 1 AND nego_rate IS NULL;
UPDATE rsv_src SET real_rate=0 WHERE hotel_group_id = 1 AND hotel_id = 1 AND real_rate IS NULL;

UPDATE code_cache SET modify_datetime = NOW() WHERE hotel_group_id = 1 AND hotel_id = 1;

-- 补录master_stalog.rsv_user及rsv_datetime
SELECT * FROM master_stalog WHERE rsv_datetime IS NULL AND ci_datetime IS NOT NULL; 
UPDATE master_stalog SET rsv_user = ci_user,rsv_datetime = ci_datetime WHERE hotel_group_id = 1 AND hotel_id = 1 AND rsv_datetime IS NULL AND ci_datetime IS NOT NULL; 
 
-- 电话等级
SELECT COUNT(1) FROM master_base a ,migrate_xmyh.master b WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND a.sc_flag = b.accnt;

-- UPDATE  SET a.extra_flag = CONCAT(SUBSTRING(a.extra_flag,1,11),SUBSTRING(b.extra,6,1),SUBSTRING(a.extra_flag,12,18))


SELECT CONCAT(SUBSTRING(a.extra_flag,1,11),SUBSTRING(b.extra,6,1),SUBSTRING(a.extra_flag,13,18)),a.id,a.extra_flag,b.accnt,b.extra,c.accnt_old,c.accnt_new FROM master_base a ,migrate_xmyh.master b,up_map_accnt c WHERE 
a.hotel_group_id = 1 AND a.hotel_id = 1 AND a.id = c.accnt_new AND (c.accnt_type = 'master_r' OR c.accnt_type = 'master_si')
AND c.hotel_group_id = 1 AND c.hotel_id = 1 AND c.accnt_old = b.accnt;
-- 01
UPDATE  master_base a ,migrate_xmyh.master b,up_map_accnt c SET a.extra_flag = CONCAT(SUBSTRING(a.extra_flag,1,11),SUBSTRING(b.extra,6,1),SUBSTRING(a.extra_flag,12,18))
WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND a.id = c.accnt_new AND (c.accnt_type = 'master_r' OR c.accnt_type = 'master_si')
AND c.hotel_group_id = 1 AND c.hotel_id = 1 AND c.accnt_old = b.accnt;

SELECT a.id,a.extra_flag,CONCAT(SUBSTRING(a.extra_flag,1,11),b.code_new,SUBSTRING(a.extra_flag,13,18)),b.* FROM master_base a,up_map_code b WHERE b.hotel_group_id = 1 AND b.hotel_id = 1 AND 
b.code = 'phone_grade' AND b.code_old = SUBSTRING(a.extra_flag,12,1);
-- 02
UPDATE  master_base a,up_map_code b SET a.extra_flag = CONCAT(SUBSTRING(a.extra_flag,1,11),b.code_new,SUBSTRING(a.extra_flag,13,18))
WHERE b.hotel_group_id = 1 AND b.hotel_id = 1 AND 
b.code = 'phone_grade' AND b.code_old = SUBSTRING(a.extra_flag,12,1);
SELECT  * FROM master_base WHERE LENGTH(extra_flag) <> 30;
-- 接机送机导入 车型对照
SELECT * FROM master_arrdep WHERE hotel_group_id = 1 AND hotel_id = 1;
DELETE FROM master_arrdep WHERE hotel_group_id = 1 AND hotel_id = 1;
INSERT INTO master_arrdep (hotel_group_id,hotel_id, master_type,master_id,trans_type,trans_date,trans_info,trans_car,
	trans_rate,trans_adult,trans_dest,extra_info,create_user,create_datetime,modify_user,modify_datetime)
SELECT 	1, 1, IF(b.accnt_type = 'master_r','RESRV','MASTER'),b.accnt_new, 'ARR',a.arrdate,a.arrinfo,a.arrcar,
	a.arrrate, '1', '','',a.cby,a.changed,a.cby,a.changed
	FROM  migrate_xmyh.master a,up_map_accnt b  WHERE b.hotel_group_id = 1 AND b.hotel_id = 1 AND 
	(b.accnt_type = 'master_r' OR b.accnt_type = 'master_si') AND b.accnt_old = a.accnt 
	AND (a.arrinfo <> '' OR a.arrcar <> '')  ;

INSERT INTO master_arrdep (hotel_group_id,hotel_id, master_type,master_id,trans_type,trans_date,trans_info,trans_car,
	trans_rate,trans_adult,trans_dest,extra_info,create_user,create_datetime,modify_user,modify_datetime)
SELECT 	1, 1, IF(b.accnt_type = 'master_r','RESRV','MASTER'),b.accnt_new, 'DEP',a.depdate,a.depinfo,a.depcar,
	a.deprate, '1', '','',a.cby,a.changed,a.cby,a.changed
	FROM  migrate_xmyh.master a,up_map_accnt b WHERE b.hotel_group_id = 1 AND b.hotel_id = 1 AND 
	(b.accnt_type = 'master_r' OR b.accnt_type = 'master_si') AND b.accnt_old = a.accnt 
	AND (a.depinfo <> '' OR a.depcar <> '') ;

UPDATE	master_arrdep a,rsv_src b SET a.master_type = 'MASTER' WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 
AND a.master_id = b.accnt AND b.hotel_group_id = 1 AND b.hotel_id = 1 AND b.occ_flag = 'MF' AND a.master_type = 'RESRV';
SELECT * FROM rsv_src WHERE hotel_id = 1 AND accnt = 11284;	
SELECT * FROM master_arrdep WHERE hotel_group_id = 1 AND hotel_id = 1 AND master_id = 11284;
SELECT * FROM master_arrdep WHERE hotel_group_id = 1 AND hotel_id = 1 AND master_id = 11229;

SELECT * FROM up_map_code WHERE hotel_id = 1 AND CODE = 'car';	
UPDATE 	master_arrdep a,up_map_code b SET a.trans_car = b.code_new WHERE a.hotel_group_id = 1
AND a.hotel_id = 1 AND a.trans_car = b.code_old AND b.hotel_group_id = 1 AND b.hotel_id = 1 AND b.code = 'car';
-- 拾到物品导入
INSERT INTO lost_found_reg(hotel_group_id,hotel_id, bill_no,sta,goods_grade,goods_class,goods_name,remark,amount,pick_man,
	pick_address,pick_date,pick_descript,rep_man,rep_date,rep_phone,rep_address,host_guest_id,host_name,host_mobile,get_guest_id,
	get_name,get_idcls,get_ident,get_date,get_reason,get_phone,get_address,audit_user,lost_found_rep_id,lost_found_rep_bill_no,create_user,create_datetime,modify_user,modify_datetime)
SELECT  1,1,a.folio,'I',a.grade,a.class,a.goods,IF(a.refer <> '',CONCAT(a.descript,'//',a.refer),a.descript),a.amount,a.pick_man, 
	a.pick_add,a.pick_date,a.pick_thing,a.rep_man,a.rep_date,a.rep_phone,a.rep_address,NULL,NULL,NULL,NULL, 
	NULL,NULL, NULL,NULL, NULL,NULL,NULL,NULL,NULL, NULL,a.empno,a.date,a.empno,a.date
	FROM migrate_xmyh.swreg a ORDER BY a.folio;
SELECT * FROM lost_found_reg;
SELECT * FROM lost_found_reg WHERE goods_name LIKE '%红色%';
SELECT * FROM lost_found_reg WHERE goods_class = '0';

SELECT * FROM up_map_code WHERE hotel_id = 1 AND CODE = 'sw_class';

UPDATE lost_found_reg a,up_map_code b SET a.goods_class = b.code_new WHERE a.hotel_group_id = 1 AND a.hotel_id = 1
AND a.goods_class = b.code_old; 

-- 更新早餐账户
SELECT * FROM code_package a, migrate_xmyh.package b,up_map_accnt c WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND a.code = b.code
AND c.accnt_old = b.accnt AND c.hotel_group_id = 1 AND c.hotel_id = 1 AND c.accnt_type = 'consume';

UPDATE  code_package a, migrate_xmyh.package b,up_map_accnt c SET a.accnt = c.accnt_new
 WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND a.code = b.code
AND c.accnt_old = b.accnt AND c.hotel_group_id = 1 AND c.hotel_id = 1 AND c.accnt_type = 'consume';

SELECT DISTINCT accnt_type FROM up_map_accnt WHERE hotel_id = 1 AND accnt_type = 'consume';
SELECT * FROM migrate_xmyh.package;

-- 上门散客		 
SELECT * FROM master_base a,migrate_xmyh.master b WHERE a.sc_flag = b.accnt
AND SUBSTRING(b.extra,9,1) = '1';

UPDATE master_base a,migrate_xmyh.master b SET a.is_walkin = 'T'
WHERE a.sc_flag = b.accnt
AND SUBSTRING(b.extra,9,1) = '1' AND a.hotel_group_id = 1 AND a.hotel_id = 1;

-- 检查主单房型是否和实际一致
SELECT a.id,a.rsv_id,a.rmtype,b.rmtype,c.code_old,c.code_new FROM master_base a,room_no b,up_map_code c WHERE a.hotel_group_id = 1 AND a.hotel_id = 15 AND b.hotel_group_id = 1 AND
b.hotel_id = 1 AND c.hotel_group_id = 1 AND c.hotel_id = 1 AND c.code = 'rmtype' AND b.rmtype = c.remark
AND a.rmno = b.code AND a.rmtype <> b.rmtype
;


  