DELIMITER $$

DROP PROCEDURE IF EXISTS `ihotel_up_code_maint_v5`$$

CREATE DEFINER=`root`@`%` PROCEDURE `ihotel_up_code_maint_v5`(
	arg_hotel_group_id	BIGINT(16),
	arg_hotel_id		BIGINT(16)
)
SQL SECURITY INVOKER
label_0:
BEGIN

	DELETE FROM up_status WHERE hotel_id=arg_hotel_id AND up_step='maint';
	INSERT INTO up_status(hotel_id, up_step, time_begin, time_end, time_long, remark) VALUES(arg_hotel_id, 'maint', NOW(), NULL, 0, ''); 
		
	-- 预订号补全：否则入住页面有问题
	UPDATE master_base SET rsv_no=TRIM(CONVERT(id,CHAR(20))) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (rsv_no='' OR rsv_no IS NULL );

	-- 更新 master_base.rsv_man 预订人
	UPDATE master_base a,master_guest b SET a.rsv_man=b.name WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.id=b.id AND a.rsv_man='';	
	
	UPDATE master_base a,up_map_code b SET a.rmtype = b.code_new WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.cat = 'rmtype' AND a.rmtype = b.code_old;
	UPDATE rsv_src a,up_map_code b SET a.rmtype = b.code_new WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.cat = 'rmtype' AND a.rmtype = b.code_old;

	UPDATE master_base a,up_map_code b SET a.up_rmtype = b.code_new WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.cat = 'rmtype' AND a.up_rmtype = b.code_old AND a.up_rmtype<>'';
	UPDATE rsv_src a,up_map_code b SET a.up_rmtype = b.code_new WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.cat = 'rmtype' AND a.up_rmtype = b.code_old AND a.up_rmtype<>'';
	
	UPDATE master_base a,room_no b SET a.building = b.building WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.rmtype = b.rmtype;
	UPDATE master_guest SET birth = NULL WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND birth='0000-00-00 00:00:00';

	UPDATE rsv_src SET rsv_arr_date = DATE_ADD(rsv_arr_date, INTERVAL 12 HOUR) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND EXTRACT(HOUR FROM rsv_arr_date) = 0;
	UPDATE rsv_src SET rsv_dep_date = DATE_ADD(rsv_dep_date, INTERVAL 18 HOUR) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND EXTRACT(HOUR FROM rsv_dep_date) = 0;

	-- 房价码	
	UPDATE master_base a,up_map_code b SET a.ratecode = b.code_new WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id = b.hotel_id AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.cat = 'ratecode' AND b.code_old = a.ratecode; 
	UPDATE master_base SET ratecode = 'RACK' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id = arg_hotel_id AND ratecode = '';
	
	UPDATE rsv_src a,up_map_code b SET a.ratecode = b.code_new WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id = b.hotel_id AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.cat = 'ratecode' AND b.code_old = a.ratecode; 
	UPDATE rsv_src SET ratecode = 'RACK' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id = arg_hotel_id AND ratecode = '';
	
 	-- 付款方式
	UPDATE master_base a,up_map_code b SET a.pay_code = b.code_new WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id = b.hotel_id AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.cat = 'paymth' AND b.code_old = a.pay_code; 
	UPDATE master_base SET pay_code ='10001' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND pay_code = '';
	-- 市场来源
 	UPDATE master_base a,up_map_code b SET a.market = b.code_new WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id = b.hotel_id AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.cat = 'mktcode' AND b.code_old = a.market; 
 	UPDATE master_base a,up_map_code b SET a.market = b.code_new WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id = b.hotel_id AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.cat = 'mktcode_g' AND b.code_old = a.market;
	UPDATE master_base SET market = 'WAK' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id = arg_hotel_id AND market = '';
 
	
	UPDATE master_base a,up_map_code b SET a.src = b.code_new WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id = b.hotel_id AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.cat = 'srccode' AND b.code_old = a.src; 
	UPDATE master_base SET src = 'WAK' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id = arg_hotel_id AND src = '';

 	UPDATE rsv_src a,up_map_code b SET a.market = b.code_new WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id = b.hotel_id AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.cat = 'mktcode' AND b.code_old = a.market; 
 	UPDATE rsv_src a,up_map_code b SET a.market = b.code_new WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id = b.hotel_id AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.cat = 'mktcode_g' AND b.code_old = a.market; 	
	UPDATE rsv_src SET market = 'WAK' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id = arg_hotel_id AND market = '';
	UPDATE rsv_src a,up_map_code b SET a.src = b.code_new WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id = b.hotel_id AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.cat = 'srccode' AND b.code_old = a.src; 
	UPDATE rsv_src SET src = 'WAK' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id = arg_hotel_id AND src = '';
	-- 销售员
	UPDATE master_base a,up_map_code b SET a.salesman = b.code_new WHERE b.cat = 'salesman' AND a.salesman = b.code_old AND a.salesman<>'' AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id;
	-- 国籍国家
 	UPDATE master_guest a,up_map_code b SET a.country = b.code_new WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.hotel_group_id=b.hotel_group_id AND a.hotel_id = b.hotel_id AND b.cat = 'country' AND b.code_old = a.country; 
	UPDATE master_guest a,up_map_code b SET a.nation = b.code_new WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.hotel_group_id=b.hotel_group_id AND a.hotel_id = b.hotel_id AND b.cat = 'nation' AND b.code_old = a.nation; 
 	-- 证件类型
 	UPDATE master_guest a,up_map_code b SET a.id_code = b.code_new WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.hotel_group_id=b.hotel_group_id AND a.hotel_id = b.hotel_id AND b.cat = 'idcode' AND b.code_old = a.id_code; 
 	-- 保密级别
 	UPDATE master_base a,up_map_code b SET a.is_secret = b.code_new WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.hotel_group_id=b.hotel_group_id AND a.hotel_id = b.hotel_id AND b.cat = 'secret' AND b.code_old = a.is_secret; 
	-- 优惠理由
	UPDATE master_base a,up_map_code b SET a.dsc_reason = b.code_new WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.cat = 'reason' AND b.code_old = a.dsc_reason ;
	UPDATE rsv_src a,up_map_code b SET a.dsc_reason = b.code_new WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.cat = 'reason' AND b.code_old = a.dsc_reason ;
	-- 楼栋更新
  	UPDATE master_base a  SET a.building = 'A' WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id ;

	-- 信用部分	(针对V系列，此处有点问题，同住客人会多一倍，要特殊处理下)
	DELETE FROM accredit WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id; 

	INSERT INTO accredit (hotel_group_id,hotel_id,accnt,accnt_type,number,ta_code,card_no,
				  expiry_date,cur_exchg_no,auth_no,amount,amount_foreign,amount_use,tag,
				  create_user,create_biz_date,create_cashier,create_datetime,
				  use_user,use_biz_date,use_cashier,use_datetime,
				  partout_flag,close_id,modify_user,modify_datetime,is_online)
	SELECT a.hotel_group_id,a.hotel_id,a.id,'F',c.number - 1,c.paycode,c.cardno,
				  NULL,c.foliono,c.creditno,c.amount,0,0,'R',
				 c.empno1,DATE(c.log_date1),c.shift1,c.log_date1,
				  c.empno1,DATE(c.log_date1),c.shift1,NULL,
				  NULL,NULL,c.empno1,c.log_date1,'F'
				  FROM master_base a,up_map_accnt b,migrate_xc.accredit c 
				  WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id 
				  AND a.sta IN ('I','S') AND a.id=b.accnt_new AND b.accnt_type IN ('consume','master_si') AND LEFT(b.accnt_old,7)=c.accnt AND c.tag= '0'
	UNION 
	SELECT a.hotel_group_id,a.hotel_id,a.id,'R',c.number - 1,c.paycode,c.cardno,
				  NULL,c.foliono,c.creditno,c.amount,0,0,'R',
				  c.empno1,DATE(c.log_date1),c.shift1,c.log_date1,
				  c.empno1,DATE(c.log_date1),c.shift1,NULL,
				  NULL,NULL,c.empno1,c.log_date1,'F'
				  FROM master_base a,up_map_accnt b,migrate_xc.accredit c 
				  WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id
				  AND a.sta ='R' AND a.id=b.accnt_new AND b.accnt_type='master_r' AND LEFT(b.accnt_old,7)=c.accnt AND c.tag='0';
						
	UPDATE accredit a, up_map_code b SET a.ta_code=b.code_new WHERE a.hotel_group_id = b.hotel_group_id AND a.hotel_id= b.hotel_id AND a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.cat='paymth' AND a.ta_code=b.code_old;

	-- 主单余额，定金修复		
	UPDATE master_base a SET a.charge=IFNULL((SELECT SUM(b.charge) FROM account b WHERE a.id=b.accnt AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id),0) WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id;
	UPDATE master_base a SET a.pay=IFNULL((SELECT SUM(b.pay) FROM account b WHERE a.id=b.accnt AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id),0) WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id;
	UPDATE master_base a SET a.credit=IFNULL((SELECT SUM(b.amount) FROM accredit b WHERE a.id=b.accnt AND b.accnt_type='F' AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id),0) WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id;

	-- 修复打开团队主单账务时报错	
	UPDATE master_base SET master_id = id ,grp_accnt = id WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND rsv_class = 'G';

	-- 产生允许记账
	INSERT INTO account_sub (hotel_group_id,hotel_id,TYPE,tag,accnt_type,accnt,rmno,guest_id,to_accnt_type,to_accnt,to_rmno,NAME,
	ta_codes,pay_code,begin_datetime,end_datetime,remark,create_user,create_datetime,modify_user,modify_datetime)
	SELECT arg_hotel_group_id,arg_hotel_id,'POSTING','','MASTER',id,'',0,NULL,NULL,'','',
	'*','',arr,dep,'',create_user,create_datetime,modify_user,modify_datetime
	FROM master_base WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id
	AND id NOT IN (SELECT c.accnt FROM account_sub c WHERE c.hotel_group_id=arg_hotel_group_id AND c.hotel_id=arg_hotel_id AND c.type='POSTING');  

	UPDATE master_base SET extra_flag='001000000000000000000000000000',posting_flag ='1' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;
	UPDATE account_sub SET accnt_type = 'MASTER' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND accnt_type = 'consume';
		
	-- 产生基本分账户
	INSERT INTO account_sub(hotel_group_id,hotel_id,TYPE,tag,accnt_type,accnt,rmno,guest_id,to_accnt_type,to_accnt,to_rmno,NAME,
	ta_codes,pay_code,begin_datetime,end_datetime,remark,create_user,create_datetime,modify_user,modify_datetime)
	SELECT arg_hotel_group_id,arg_hotel_id,'SUBACCNT','SYS_FIX','MASTER',id,'',0,NULL,NULL,'','',
	'*','',arr,dep,'',create_user,create_datetime,modify_user,modify_datetime
	FROM master_base WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id
	AND id NOT IN (SELECT c.accnt FROM account_sub c WHERE c.hotel_group_id=arg_hotel_group_id AND c.hotel_id=arg_hotel_id AND c.type='SUBACCNT' AND c.tag='SYS_FIX');  

	UPDATE account_sub a,master_guest b SET a.name=b.name 
	WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id
	AND a.accnt=b.id AND a.type='SUBACCNT' AND a.tag='SYS_FIX' ;

	-- 防止消费账联房
	UPDATE master_base SET master_id=id WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND rsv_class='H';
	-- 修复 master_base 中的 rsv_id,master_id	
	UPDATE master_base a,rsv_src b SET a.rsv_id=a.id WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id
		AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.sta='R' AND a.id=b.accnt AND b.occ_flag IN ('RF','RG');
		
	UPDATE master_base SET rsv_id = id WHERE hotel_group_id = hotel_group_id AND hotel_id = arg_hotel_id AND sta IN ('I','O','S') AND rsv_class='G';
	UPDATE master_base SET master_id=id WHERE hotel_group_id = hotel_group_id AND hotel_id = arg_hotel_id AND sta='R' AND rsv_class<>'H';

	-- 更新包价
	UPDATE master_base a ,up_map_code b SET a.packages = b.code_new WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.cat = 'package' AND a.packages = b.code_old;	
	UPDATE rsv_src a ,up_map_code b SET a.packages = b.code_new WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.cat = 'package' AND a.packages = b.code_old;		

	-- 修复同住方案
	DROP TEMPORARY TABLE IF EXISTS tmp_master_id;
	CREATE TEMPORARY TABLE tmp_master_id(
	    hotel_group_id  BIGINT(16),
		hotel_id 	BIGINT(16),
		accnt		VARCHAR(15),
		master_id	BIGINT(16),
		KEY index1 (hotel_group_id,hotel_id,accnt),
		KEY index2 (hotel_group_id,hotel_id,master_id)
	);
	
	INSERT INTO tmp_master_id(hotel_group_id,hotel_id,accnt,master_id)
	SELECT hotel_group_id,hotel_id,LEFT(accnt_old,7),MIN(accnt_new) FROM up_map_accnt WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND accnt_type IN('master_si','master_r')
	GROUP BY LEFT(accnt_old,7) HAVING COUNT(1) > 1;

	UPDATE  master_base a,tmp_master_id b,up_map_accnt c SET 
	a.master_id = b.master_id 
	WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id
	AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id
	AND c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = arg_hotel_id AND c.accnt_type IN('master_r','master_si') AND LEFT(c.accnt_old,7) = b.accnt AND c.accnt_new = a.id;

	UPDATE master_base SET master_id = id WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND rsv_class = 'F' AND master_id = 0;	

	-- 直接根据原系统帐号产生,修复联房
	UPDATE master_base a,up_map_accnt b,migrate_xc.master c,up_map_accnt d
	SET a.link_id=d.accnt_new 
	WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id 
	AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id 
	AND d.hotel_group_id=arg_hotel_group_id AND d.hotel_id=arg_hotel_id 
	AND a.id=b.accnt_new AND b.accnt_type IN ('master_si','master_r','consume') 
	AND c.pcrec=SUBSTRING(d.accnt_old,1,7) AND d.accnt_type IN ('master_si','master_r','consume') 
	AND SUBSTRING(b.accnt_old,1,7)=c.accnt AND c.pcrec<>'';		 

	UPDATE master_base SET link_id=id WHERE hotel_group_id= arg_hotel_group_id AND hotel_id= arg_hotel_id AND (link_id=0 OR link_id IS NULL);  
	UPDATE master_base SET pkg_link_id=link_id WHERE hotel_group_id= arg_hotel_group_id AND hotel_id= arg_hotel_id; 
	-- 团队主单与成员的信息关联
	UPDATE master_base a,up_map_accnt b,migrate_xc.master c,up_map_accnt d SET a.grp_accnt=d.accnt_new
	WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.hotel_group_id=d.hotel_group_id AND a.hotel_id=d.hotel_id
	AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id
	AND a.id=b.accnt_new AND b.accnt_type IN ('master_si','master_r') AND d.accnt_type ='grpmst' 
	AND SUBSTRING(b.accnt_old,1,7)=c.accnt AND c.groupno=SUBSTRING(d.accnt_old,1,7);
	-- 修复打开团队主单账务时报错	
	UPDATE master_base SET master_id = id ,grp_accnt = id WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND rsv_class = 'G';
		
	-- 为重建房价准备
	DELETE FROM rsv_rate WHERE hotel_group_id =arg_hotel_group_id AND hotel_id = arg_hotel_id;
	UPDATE rsv_src SET rack_rate=0 WHERE hotel_group_id =arg_hotel_group_id AND hotel_id = arg_hotel_id AND rack_rate IS NULL;
	UPDATE rsv_src SET nego_rate=0 WHERE hotel_group_id =arg_hotel_group_id AND hotel_id = arg_hotel_id AND nego_rate IS NULL;
	UPDATE rsv_src SET real_rate=0 WHERE hotel_group_id =arg_hotel_group_id AND hotel_id = arg_hotel_id AND real_rate IS NULL;
	
	UPDATE company_base SET name_combine=REPLACE(name_combine,' ','');
	UPDATE guest_base SET name_combine=REPLACE(name_combine,' ','');
	
	DROP TEMPORARY TABLE IF EXISTS tmp_master_id;
	
	UPDATE up_status SET time_end=NOW() WHERE hotel_id=arg_hotel_id AND up_step='maint';
	UPDATE up_status SET time_long=TIMESTAMPDIFF(MINUTE,time_begin,time_end) WHERE hotel_id=arg_hotel_id AND up_step='maint';
		
END$$

DELIMITER ;