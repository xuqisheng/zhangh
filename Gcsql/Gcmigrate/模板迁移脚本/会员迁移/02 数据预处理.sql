DELIMITER $$

 
DROP PROCEDURE IF EXISTS `up_ihotel_up_member`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_up_member`(
	INOUT var_return VARCHAR(128)  -- 返回空串表示成功，否则表示失败  
)
label_0:
BEGIN
	-- 示例：
-- 	DECLARE var_hotel_descript VARCHAR(60);
-- 	DECLARE var_feecode_descript VARCHAR(60);
-- 	DECLARE var_feecode_descript_en VARCHAR(60);
-- 	
-- 	SELECT descript_short INTO var_hotel_descript FROM hotel_group WHERE id = var_hotel_group_id;
-- 	SELECT descript,descript_en INTO var_feecode_descript,var_feecode_descript_en FROM code_transaction WHERE hotel_group_id = var_hotel_group_id AND hotel_id = 0 AND code = var_feecode;
-- 	
		
 	
 
	/*
	预处理	
 		将原数据准备到membercard表中
		1、核查hotel_group_id,hotel_id、card_type字段内容
	*/	
 	TRUNCATE TABLE migrate_db.membercard;	
--     DELETE FROM migrate_db.membercard WHERE card_no = '1001710';
      --  储值卡
      -- 检查卡号重复
/*       SELECT t.sno,COUNT(1)
	FROM (
		SELECT am.accnt ,am.artag1,g.sno
		FROM ar_master am LEFT JOIN guest g ON am.haccnt = g.no
		WHERE am.artag1 IN ('5','B')  and g.sno = ''
		GROUP BY am.accnt  ORDER BY am.accnt
	) t GROUP BY t.sno HAVING COUNT(1) > 1      ；  
      */
      
	INSERT INTO migrate_db.membercard
	(hotel_group_id,hotel_id,iss_hotel,biz_date,cno,card_no,card_no2,sta,
	card_type,card_level,card_src,card_name,src,ratecode,posmode,date_begin,date_end,`PASSWORD`,salesman,crc,remark,
	araccnt,create_user,create_datetime,modify_user,modify_datetime,
	point_pay,point_charge,point_last_num,pay,charge,last_num,pay_code,
	hno,hname,hlname,hfname,hname2,hname3,hname_combine,sex,LANGUAGE,birth,nation,id_code,id_no,hremark,
	hcreate_user,hcreate_datetime,hmodify_user,hmodify_datetime,mobile,phone,email,
	country,state,city,division,street,zipcode
	)
	SELECT
		118,10135,'ZSYQJD','2016-4-18',NULL,TRIM(a.kno),a.kno,'I',
		IF(TRIM(a.card_type) IS NULL,'VIPA',a.card_type),IF(TRIM(a.card_type) IS NULL,'VIP1',a.card_type),'01',TRIM(a.name),'','','',a.begin_,a.end_,'',a.salesman,'','',
		'','ADMIN_YQ',NOW(),'ADMIN_YQ',NOW(),
		a.point,0,0,a.balance,0,0,'9900',
		a.kno,TRIM(a.name),TRIM(a.name),TRIM(a.name),TRIM(a.name),TRIM(a.name),TRIM(a.name),'1','C',NULL,'CN','01',IFNULL(a.idno,''),'',
		'ADMIN_YQ',NOW(),'ADMIN',NOW(),a.mobile,'','',
		'CN','','','','',''
	FROM migrate_db.vipcard a ;
	
 
	-- 发展来源
	UPDATE migrate_db.membercard a SET a.card_src = '01';
--  	-- 房价码
-- 	UPDATE migrate_db.membercard a,portal.up_map_code b SET a.ratecode = b.code_new
-- 	WHERE b.hotel_group_id = 1 AND b.hotel_id = 1 AND b.code = 'ratecode' AND b.code_old = a.ratecode;
	-- 餐饮模式
-- 	UPDATE migrate_db.membercard a,portal.up_map_code b SET a.posmode = b.code_new
-- 	WHERE b.hotel_group_id = 1 AND b.hotel_id = 1 AND b.code = 'ratecode' AND b.code_old = a.posmode;
	-- 翻译销售员sale //请对照：sales_man.code
-- 	UPDATE migrate_db.membercard a,portal.up_map_code b SET a.salesman = b.code_new WHERE b.hotel_group_id = 2 AND b.hotel_id = 9
-- 	AND b.cat = 'sales_man' AND   b.code_old = a.salesman;

	-- 卡等级
-- 	UPDATE migrate_db.membercard a,portal.up_map_code b SET a.card_level = b.code_new WHERE b.hotel_group_id = 1 AND b.hotel_id = 1 
-- 	AND b.cat = 'card_level' AND   b.code_old = a.card_level;
	
    	
 	-- 导入帐户余额信息
--  	UPDATE migrate_db.membercard m ,(SELECT accnt,SUM(rmb_db-addrmb) charge, depr_cr AS credit FROM migrate_db.armst GROUP BY accnt )ar 
--  	SET m.pay = ar.credit ,m.charge = ar.charge -- m.last_num = ar.lastnumb
--  	WHERE m.araccnt = ar.accnt;
--  	
--  	UPDATE migrate_db.membercard m ,(SELECT araccnt,MIN(card_no) card_no FROM membercard GROUP BY araccnt HAVING COUNT(1) > 1) b SET m.charge = 0,m.pay = 0
-- 		WHERE m.card_no = b.card_no;
-- 	-- 处理一人多卡
--  	UPDATE migrate_db.membercard m ,(SELECT araccnt,MIN(hno) hno FROM membercard GROUP BY araccnt HAVING COUNT(1) > 1) b SET m.hno = b.hno
-- 		WHERE m.araccnt = b.araccnt;		
		
	-- 翻译证件类型 id_code
-- 	UPDATE migrate_db.membercard m,portal.up_map_code map 
-- 	SET m.id_code = code_new
-- 	WHERE map.hotel_group_id = 1 AND map.hotel_id = 1 AND map.cat = 'idcode' AND m.id_code = map.code_old ;

	-- 原西软账务系统中，存在多卡共用一账号时，西软系统中一账户多卡没有从属关系，ihotel要求有从属关系
 	-- 主卡的card_master字段填null，附卡填主卡的card_id_temp,
 	-- 手工或程序方式填写card_master字段，并将附卡的帐户余额（set pay=0、charge=0）清零
	-- 检测语句
--   UPDATE migrate_db.membercard SET pay=0,charge=0 WHERE card_master IS NOT NULL;	
 	
 	
	
	-- 指定hotel_id,iss_hotel //请对照：hotel.id。酒店编号;请对照：hotel.code。发卡酒店代码
	-- 对照表up_map_code中的code字段用于区别各种类型代码
	
	-- select distinct hotel_id ,iss_hotel  from migrate_db.membercard order by hotel_id
	
	
	
	-- 指定 guest_id ，前提为有超哥导入的客史
--   	UPDATE migrate_db.membercard mc,portal.up_map_accnt map 
--  	SET mc.guest_id = map.accnt_new
--  	WHERE mc.hno = map.accnt_old AND map.hotel_group_id = 1 AND map.hotel_id = 1  AND map.accnt_type = 'GUEST_FIT';
--  	-- 翻译代码卡状态 //状态=R=初始 I-有效,X-销卡,L-挂失,M-损坏,O-停用 S=休眠
	-- 若为西软系统，此句跳过；若其它PMS系统，核查卡状态建立对照表
--  	UPDATE migrate_db.membercard mc,portal.up_map_accnt map 
--  	SET mc.company_id = map.accnt_new
--  	WHERE mc.cno = map.accnt_old AND map.hotel_group_id = 1 AND map.hotel_id = 1  AND map.accnt_type = 'COMPANY';
 	
	-- 翻译卡计划和等级card_type,card_level // 请对照,card_type.code 请对照，card_level.code
	-- 
	
	-- 翻译发卡来源 card_src//请对照，code_base.parent_code = 'card_src'
	-- 
	
	-- 翻译或填写房价码 ,餐娱码ratecode,posmode //请对照：code_ratecode房价码；请对照：code_base.parent_code = 'pos_mode'餐娱码
	-- 
	-- UPDATE migrate_db.membercard SET ratecode = 
	-- UPDATE migrate_db.membercard SET posmode = 
	
	
	
	-- 翻译性别 sex//请对照：code_base.parent_code = 'card_src'
	-- 
	
	-- 翻译语言 language//请对照：code_base.parent_code = 'language',语言
	-- 
 	

	
	-- 翻译国籍、国家 nation、country // 请对照：code_country.code。国籍
-- 	UPDATE migrate_db.membercard mc,up_map_code map 
-- 	SET mc.nation = code_new
-- 	WHERE map.hotel_id = 0 AND map.code = 'nation' AND mc.nation = map.code_old ;
	
-- 	UPDATE migrate_db.membercard mc,up_map_code map 
-- 	SET mc.country = code_new
-- 	WHERE map.hotel_id = 0 AND map.code = 'nation' AND mc.country = map.code_old ;
	
	-- 翻译地址中的省、市、区域state,city,division // 请对照：code_province.code。code_city.code。code_city.division。
-- 	UPDATE migrate_db.membercard mc,up_map_code map 
-- 	SET mc.state = code_new
-- 	WHERE map.hotel_id = 0 AND map.code = 'province' AND mc.state = map.code_old ;
	-- 在membercard中验证卡数量、积分余额、储值余额
	-- 卡总数
-- 	SELECT card_level,COUNT(1) ,SUM(point_pay),SUM(point_charge),SUM(point_pay- point_charge),SUM(pay),SUM(charge),SUM(pay - charge) FROM migrate_db.membercard GROUP BY card_type,card_level
-- 	UNION 
-- 	SELECT '',COUNT(1) ,SUM(point_pay),SUM(point_charge),SUM(point_pay- point_charge),SUM(pay),SUM(charge),SUM(pay - charge) FROM migrate_db.membercard ;
-- 		
--         -- 清空正式表,看情况执行
 
	BEGIN
-- 		SET @procresult = 0 ;
		SET var_return = '';
		LEAVE label_0 ;
	END ;
	
END$$

DELIMITER ;