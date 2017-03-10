DELIMITER $$

DROP PROCEDURE IF EXISTS `ihotel_up_member_pre`$$

CREATE DEFINER=`root`@`%` PROCEDURE `ihotel_up_member_pre`(
	IN arg_hotel_group_id	INT,
	IN arg_hotel_id			INT
)
label_0:
BEGIN
	DECLARE var_hotel_descript 	VARCHAR(60);
	DECLARE var_hotel_code	 	VARCHAR(60);
	DECLARE var_bdate 			DATETIME;
	
	SELECT descript_short INTO var_hotel_descript FROM hotel WHERE hotel_group_id = arg_hotel_group_id AND id = arg_hotel_id;
	SELECT code INTO var_hotel_code FROM hotel WHERE hotel_group_id = arg_hotel_group_id AND id = arg_hotel_id;
	
	/*
	预处理	
	*/
	SET @procresult = 1;
	ALTER TABLE migrate_yw.vipcard ADD KEY vipcard_kno (kno);
	
	SELECT biz_date1 INTO var_bdate FROM audit_flag WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;
	
	/*
		将原数据准备到membercard表中
		1、核查hotel_group_id,hotel_id、card_type字段内容
	*/	
	TRUNCATE TABLE migrate_yw.membercard;
	INSERT INTO migrate_yw.membercard
	(hotel_group_id,hotel_id,iss_hotel,biz_date,card_no,card_no2,sta,
		card_type,card_level,card_src,card_name,ratecode,posmode,date_begin,date_end,password,salesman,crc,remark,
		araccnt,create_user,create_datetime,modify_user,modify_datetime,
		point_pay,point_charge,point_last_num,
		hno,hname,hlname,hfname,hname2,hname3,hname_combine,sex,LANGUAGE,birth,nation,id_code,id_no,hremark,
		hcreate_user,hcreate_datetime,hmodify_user,hmodify_datetime,mobile,phone,email,
		country,state,city,division,street,zipcode,loginpw)
	SELECT
		arg_hotel_group_id,arg_hotel_id,a.hotelid,var_bdate,a.sno,a.no,a.sta,
		a.type,'','5',a.name,'','',a.arr,a.dep,a.password,a.saleid,a.crc,a.ref,
		a.araccnt1,a.ciby,a.citime,a.cby,a.changed,
		a.credit,a.charge,0,
		g.no,g.name,g.lname,g.fname,g.name2,g.name3,concat(g.name,g.name2,g.name3),g.sex,'C',g.birth,g.nation,g.idcls,g.ident,g.remark,
		g.crtby,g.crttime,g.cby,g.changed,g.mobile,g.fax,g.email,
		g.country,g.state,g.city,'',g.street,g.zip,''
	FROM migrate_yw.vipcard a LEFT JOIN migrate_yw.guest g ON a.hno = g.no WHERE a.type IN ('C','E') AND a.sta='I';
 	
 	-- 导入帐户余额信息
 	UPDATE migrate_yw.membercard a ,migrate_yw.ar_master b 
 	SET a.pay = b.credit ,a.charge = b.charge -- ,a.last_num = b.lastnumb
 	WHERE a.araccnt = b.accnt AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id;
	
	/* 检查余额是否一致
 	SELECT SUM(charge-pay) FROM membercard
 	UNION ALL
 	SELECT SUM(charge-credit) FROM ar_master WHERE artag1='3';	
 	*/
	-- 原西软账务系统中，存在多卡共用一账号时，西软系统中一账户多卡没有从属关系，ihotel要求有从属关系
 	-- 主卡的card_master字段填null，附卡填主卡的card_id_temp,
 	-- 手工或程序方式填写card_master字段，并将附卡的帐户余额（set pay=0、charge=0）清零
	-- 检测语句
-- 	 SELECT t.*,a.card_no,a.sta,a.araccnt,a.pay,a.charge,a.card_id_temp,a.card_master FROM membercard a,(
-- 	 SELECT araccnt FROM membercard WHERE araccnt <> '' GROUP BY araccnt HAVING COUNT(araccnt) > 1
-- 	 ) t WHERE a.araccnt = t.araccnt ORDER BY a.araccnt,a.card_no;	

--   UPDATE membercard SET pay=0,charge=0 WHERE card_master IS NOT NULL;
	
	-- 指定hotel_id,iss_hotel //请对照：hotel.id。酒店编号;请对照：hotel.code。发卡酒店代码
	-- 对照表up_map_code中的code字段用于区别各种类型代码
	UPDATE migrate_yw.membercard SET iss_hotel=var_hotel_code WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;
	-- select distinct hotel_id ,iss_hotel  from migrate_yw.membercard order by hotel_id	
	
	-- 指定 guest_id ，前提为有超哥导入的客史
	UPDATE migrate_yw.membercard a,up_map_accnt b SET a.guest_id = b.accnt_new
		WHERE a.hno = b.accnt_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id = arg_hotel_id 
		AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.accnt_type='GUEST_FIT';
	
	-- 翻译代码卡状态 //状态=R=初始 I-有效,X-销卡,L-挂失,M-损坏,O-停用 S=休眠
	-- 若为西软系统，此句跳过；若其它PMS系统，核查卡状态建立对照表
	
	-- 翻译卡计划和等级 card_type,card_level 请对照,card_type.code 请对照，card_level.code
	UPDATE migrate_yw.membercard SET card_type='YW-CZ',card_level='YW-CZ-A' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND card_type = 'E';
	UPDATE migrate_yw.membercard SET card_type='YW-YY',card_level='YW-YY-A' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND card_type = 'A';	
	
	-- 翻译发卡来源 card_src//请对照，code_base.parent_code = 'card_src'
	
	
	-- 指定期初付款码 membercard.pay_code //请对照,code_transaction.code
	
	UPDATE migrate_yw.membercard SET pay_code='9000' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id = arg_hotel_id;
	
	-- 翻译或填写房价码 ,餐娱码ratecode,posmode //请对照：code_ratecode房价码；请对照：code_base.parent_code = 'pos_mode'餐娱码
	-- 
	-- UPDATE membercard SET ratecode = 
	-- UPDATE membercard SET posmode = 
	
	-- 翻译销售员 sale //请对照：sales_man.code
	-- 
	
	-- 翻译性别 sex//请对照：code_base.parent_code = 'card_src'
	-- 
	
	-- 翻译语言 language//请对照：code_base.parent_code = 'language',语言
	-- 
	/*
	-- 翻译证件类型 id_code
	UPDATE migrate_yw.membercard mc,up_map_code map 
	SET mc.id_code = code_new
	WHERE map.hotel_group_id=2 AND map.hotel_id = 14 AND map.code = 'idcode' AND mc.id_code = map.code_old;
	
	-- 翻译国籍、国家 nation、country // 请对照：code_country.code。国籍
	UPDATE migrate_yw.membercard mc,up_map_code map 
	SET mc.nation = code_new
	WHERE map.hotel_group_id=2 AND map.hotel_id = 14 AND map.code = 'nation' AND mc.nation = map.code_old ;
	
	UPDATE migrate_yw.membercard mc,up_map_code map 
	SET mc.country = code_new
	WHERE map.hotel_group_id=2 AND map.hotel_id = 14 AND map.code = 'nation' AND mc.country = map.code_old ;

	
	-- 翻译地址中的省、市、区域state,city,division // 请对照：code_province.code。code_city.code。code_city.division。
	UPDATE migrate_yw.membercard mc,up_map_code map 
	SET mc.state = code_new
	WHERE map.hotel_id = 14 AND map.code = 'province' AND mc.state = map.code_old ;
	*/
	-- 在membercard中验证卡数量、积分余额、储值余额
	-- 卡总数
	SELECT card_type,card_level,COUNT(1) tl FROM migrate_yw.membercard WHERE hotel_group_id=arg_hotel_group_id AND hotel_id = arg_hotel_id
	GROUP BY card_type,card_level
	UNION ALL
	SELECT '','',COUNT(1) FROM migrate_yw.membercard WHERE hotel_group_id=arg_hotel_group_id AND hotel_id = arg_hotel_id;
	-- 积分总数
	SELECT SUM(point_pay) ,SUM(point_charge),SUM(point_pay - point_charge) balance FROM migrate_yw.membercard WHERE hotel_group_id=arg_hotel_group_id AND hotel_id = arg_hotel_id;
    -- 储值卡余额、冻结数
	SELECT SUM(pay) ,SUM(charge) ,SUM(pay - charge) balance ,SUM(freeze) FROM migrate_yw.membercard WHERE hotel_group_id=arg_hotel_group_id AND hotel_id = arg_hotel_id;
		
	BEGIN
 		SET @procresult = 0;
		LEAVE label_0 ;
	END ;
	
END$$

DELIMITER ;

-- CALL ihotel_up_member_pre(2,14);