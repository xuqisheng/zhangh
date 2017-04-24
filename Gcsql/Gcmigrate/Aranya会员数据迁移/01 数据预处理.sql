DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_migrate_member_pre`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_migrate_member_pre`(
	IN arg_hotel_group_id	INT,
	IN arg_hotel_id			INT
)
label_0:
BEGIN
	DECLARE var_hotel_descript 	VARCHAR(60);
	DECLARE var_hotel_code	 	VARCHAR(60);
	DECLARE var_group_code	 	VARCHAR(60);
	DECLARE var_bdate 			DATETIME;
	
	SELECT descript_short INTO var_hotel_descript FROM hotel WHERE hotel_group_id = arg_hotel_group_id AND id = arg_hotel_id;
	SELECT code INTO var_hotel_code FROM hotel WHERE hotel_group_id = arg_hotel_group_id AND id = arg_hotel_id;

	SELECT code INTO var_group_code FROM hotel_group WHERE hotel_group_id = arg_hotel_group_id;
	
	/*
	预处理	
	*/
	SELECT DATE(set_value) INTO var_bdate FROM sys_option WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND item='biz_date' ;
	
	/*
		将原数据准备到aranya_member_data表中
		1、核查hotel_group_id,hotel_id、card_type字段内容
	*/	
	TRUNCATE TABLE aranya_member_data;
	INSERT INTO aranya_member_data
	    (hotel_group_id,hotel_id,iss_hotel,biz_date,card_no,card_no2,sta,
		card_type,card_level,card_src,card_name,ratecode,posmode,date_begin,date_end,password,salesman,crc,remark,
		araccnt,create_user,create_datetime,modify_user,modify_datetime,
		point_pay,point_charge,point_last_num,pay,charge
		hno,hname,hlname,hfname,hname2,hname3,hname_combine,sex,LANGUAGE,birth,nation,id_code,id_no,hremark,
		hcreate_user,hcreate_datetime,hmodify_user,hmodify_datetime,mobile,phone,email,
		country,state,city,division,street,zipcode,loginpw)
	SELECT arg_hotel_group_id,arg_hotel_id,var_group_code,var_bdate,vch_vipkh,VCH_VIPBH,'I',
		vch_viplx,'','1',vch_khxm,'','',dat_fkrq,dat_yxrq,'888888','',IFNULL(vch_no,''),IFNULL(vch_bz,''),
		guid,'Aranya',dat_fkrq,'Aranya',dat_fkrq,
		0,0,0,MON_YE,MON_XF,
		'',vch_khxm,vch_khxm,vch_khxm,vch_khxm,vch_khxm,concat(vch_khxm,vch_khxm,vch_khxm),IF(vch_xb='男',1,IF(vch_xb='女',2,'')),'C',IFNULL(dat_sr,''),'CN','02',IFNULL(vch_zjbh,''),'',
		'Aranya',dat_fkrq,'Aranya',dat_fkrq,IFNULL(VCH_SJHM,''),'','',
		'','','','','','',''
	FROM TV_VIPXX;	



	-- 原西软账务系统中，存在多卡共用一账号时，西软系统中一账户多卡没有从属关系，ihotel要求有从属关系
 	-- 主卡的card_master字段填null，附卡填主卡的 card_id_temp,
 	-- 手工或程序方式填写card_master字段，并将附卡的帐户余额（set pay=0、charge=0）清零
	-- 检测语句
-- 	 SELECT t.*,a.card_no,a.sta,a.araccnt,a.pay,a.charge,a.card_id_temp,a.card_master FROM aranya_member_data a,(
-- 	 SELECT araccnt FROM aranya_member_data WHERE araccnt <> '' GROUP BY araccnt HAVING COUNT(araccnt) > 1
-- 	 ) t WHERE a.araccnt = t.araccnt ORDER BY a.araccnt,a.card_no;

	UPDATE aranya_member_data	



--   UPDATE aranya_member_data SET pay=0,charge=0 WHERE card_master IS NOT NULL;
	
	-- 指定hotel_id,iss_hotel //请对照：hotel.id。酒店编号;请对照：hotel.code。发卡酒店代码
	-- 对照表up_map_code中的code字段用于区别各种类型代码
	UPDATE aranya_member_data SET iss_hotel=var_hotel_code WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;
	-- select distinct hotel_id ,iss_hotel  from aranya_member_data order by hotel_id	
	
	-- 指定 guest_id ，前提为有超哥导入的客史
	UPDATE aranya_member_data a,up_map_accnt b SET a.guest_id = b.accnt_new
		WHERE a.hno = b.accnt_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id = arg_hotel_id 
		AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.accnt_type='GUEST_FIT';
	
	-- 翻译代码卡状态 //状态=R=初始 I-有效,X-销卡,L-挂失,M-损坏,O-停用 S=休眠
	-- 若为西软系统，此句跳过；若其它PMS系统，核查卡状态建立对照表
	
	-- 翻译卡计划和等级 card_type,card_level 请对照,card_type.code 请对照，card_level.code
	UPDATE aranya_member_data SET card_type='YW-CZ',card_level='YW-CZ-A' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND card_type = 'E';
	UPDATE aranya_member_data SET card_type='YW-YY',card_level='YW-YY-A' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND card_type = 'A';	
	
	-- 翻译发卡来源 card_src//请对照，code_base.parent_code = 'card_src'
	
	
	-- 指定期初付款码 aranya_member_data.pay_code //请对照,code_transaction.code
	
	UPDATE aranya_member_data SET pay_code='9000' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id = arg_hotel_id;
	
	-- 翻译或填写房价码 ,餐娱码ratecode,posmode //请对照：code_ratecode房价码；请对照：code_base.parent_code = 'pos_mode'餐娱码
	-- 
	-- UPDATE aranya_member_data SET ratecode = 
	-- UPDATE aranya_member_data SET posmode = 
	
	-- 翻译销售员 sale //请对照：sales_man.code
	-- 
	
	-- 翻译性别 sex//请对照：code_base.parent_code = 'card_src'
	-- 
	
	-- 翻译语言 language//请对照：code_base.parent_code = 'language',语言
	-- 
	/*
	-- 翻译证件类型 id_code
	UPDATE aranya_member_data mc,up_map_code map 
	SET mc.id_code = code_new
	WHERE map.hotel_group_id=2 AND map.hotel_id = 14 AND map.code = 'idcode' AND mc.id_code = map.code_old;
	
	-- 翻译国籍、国家 nation、country // 请对照：code_country.code。国籍
	UPDATE aranya_member_data mc,up_map_code map 
	SET mc.nation = code_new
	WHERE map.hotel_group_id=2 AND map.hotel_id = 14 AND map.code = 'nation' AND mc.nation = map.code_old ;
	
	UPDATE aranya_member_data mc,up_map_code map 
	SET mc.country = code_new
	WHERE map.hotel_group_id=2 AND map.hotel_id = 14 AND map.code = 'nation' AND mc.country = map.code_old ;

	
	-- 翻译地址中的省、市、区域state,city,division // 请对照：code_province.code。code_city.code。code_city.division。
	UPDATE aranya_member_data mc,up_map_code map 
	SET mc.state = code_new
	WHERE map.hotel_id = 14 AND map.code = 'province' AND mc.state = map.code_old ;
	*/
	-- 在aranya_member_data中验证卡数量、积分余额、储值余额
	-- 卡总数
	SELECT card_type,card_level,COUNT(1) tl FROM aranya_member_data WHERE hotel_group_id=arg_hotel_group_id AND hotel_id = arg_hotel_id
	GROUP BY card_type,card_level
	UNION ALL
	SELECT '','',COUNT(1) FROM aranya_member_data WHERE hotel_group_id=arg_hotel_group_id AND hotel_id = arg_hotel_id;
	-- 积分总数
	SELECT SUM(point_pay) ,SUM(point_charge),SUM(point_pay - point_charge) balance FROM aranya_member_data WHERE hotel_group_id=arg_hotel_group_id AND hotel_id = arg_hotel_id;
    -- 储值卡余额、冻结数
	SELECT SUM(pay) ,SUM(charge) ,SUM(pay - charge) balance ,SUM(freeze) FROM aranya_member_data WHERE hotel_group_id=arg_hotel_group_id AND hotel_id = arg_hotel_id;
		
	
END$$

DELIMITER ;

-- CALL up_ihotel_migrate_member_pre(2,14);