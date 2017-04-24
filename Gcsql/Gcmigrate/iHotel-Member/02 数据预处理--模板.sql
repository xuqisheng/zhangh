
DELIMITER $$

DROP PROCEDURE IF EXISTS up_ihotel_up_member$$

CREATE DEFINER=root@% PROCEDURE up_ihotel_up_member(
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
	
 	TRUNCATE TABLE migrate_db.membercard;	
 
	/*
	预处理	
	*/
	ALTER TABLE vipcard ADD KEY vipcard_hno (hno);
	
 	
	/*
		将原数据准备到membercard表中
		1、核查hotel_group_id,hotel_id、card_type字段内容
	*/	
	INSERT INTO migrate_db.membercard
	(hotel_group_id,hotel_id,iss_hotel,biz_date,card_no,card_no2,sta,
	card_type,card_level,card_src,card_name,ratecode,posmode,date_begin,date_end,PASSWORD,salesman,crc,remark,
	araccnt,create_user,create_datetime,modify_user,modify_datetime,
	point_pay,point_charge,point_last_num,
	hno,hname,hlname,hfname,hname2,hname3,hname_combine,sex,LANGUAGE,birth,nation,id_code,id_no,hremark,
	hcreate_user,hcreate_datetime,hmodify_user,hmodify_datetime,mobile,phone,email,
	country,state,city,division,street,zipcode,loginPW
	)
	SELECT
		1,0,v.hotelid,'2012-11-20',v.no,v.sno,v.sta,
		'B',v.class,v.src,v.name,v.code1,v.code2,v.arr,v.dep,v.password,v.saleid,v.crc,v.ref,
		v.araccnt1,v.ciby,v.citime,v.cby,v.changed,
		v.credit,v.charge,0,
		g.no,g.name,g.lname,g.fname,g.name2,g.name3,g.name+g.name2+g.name3,g.sex,'C',g.birth,g.nation,g.idcls,g.ident,g.remark,
		g.crtby,g.crttime,g.cby,g.changed,g.mobile,g.fax,g.email,
		g.country,g.state,g.city,'',g.street,g.zip,''
	FROM migrate_db.vipcard v LEFT JOIN migrate_db.guest  g ON  v.hno = g.no 
	;
 	
 	-- 导入帐户余额信息
 	UPDATE migrate_db.membercard m ,migrate_db.ar_master ar 
 	SET m.pay = ar.credit ,m.charge = ar.charge -- ,m.last_num = ar.lastnumb
 	WHERE m.araccnt = ar.accnt;
 	
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
	
	UPDATE migrate_db.membercard mc,up_map_code map 
	SET mc.hotel_id = code_new_id,iss_hotel = code_new 
	WHERE map.hotel_id = 0 AND map.code = 'hotel_id' AND mc.iss_hotel = map.code_old ;
	-- select distinct hotel_id ,iss_hotel  from migrate_db.membercard order by hotel_id
	
	
	
	-- 指定 guest_id ，前提为有超哥导入的客史
-- 	update migrate_db.membercard mc,up_map_accnt map 
-- 	set mc.guest_id = map.accnt_new
-- 	where mc.hno = map.accnt_old and map.hotel_id = 4
	
	-- 翻译代码卡状态 //状态=R=初始 I-有效,X-销卡,L-挂失,M-损坏,O-停用 S=休眠
	-- 若为西软系统，此句跳过；若其它PMS系统，核查卡状态建立对照表
	
	-- 翻译卡计划和等级card_type,card_level // 请对照,card_type.code 请对照，card_level.code
	-- 
	
	-- 翻译发卡来源 card_src//请对照，code_base.parent_code = 'card_src'
	-- 
	
	-- 翻译或填写房价码 ,餐娱码ratecode,posmode //请对照：code_ratecode房价码；请对照：code_base.parent_code = 'pos_mode'餐娱码
	-- 
	-- UPDATE membercard SET ratecode = 
	-- UPDATE membercard SET posmode = 
	
	-- 翻译销售员sale //请对照：sales_man.code
	-- 
	
	-- 翻译性别 sex//请对照：code_base.parent_code = 'card_src'
	-- 
	
	-- 翻译语言 language//请对照：code_base.parent_code = 'language',语言
	-- 
	
	-- 翻译证件类型 id_code
	UPDATE migrate_db.membercard mc,up_map_code map 
	SET mc.id_code = code_new
	WHERE map.hotel_id = 0 AND map.code = 'idcode' AND mc.id_code = map.code_old ;
	
	-- 翻译国籍、国家 nation、country // 请对照：code_country.code。国籍
	UPDATE migrate_db.membercard mc,up_map_code map 
	SET mc.nation = code_new
	WHERE map.hotel_id = 0 AND map.code = 'nation' AND mc.nation = map.code_old ;
	
	UPDATE migrate_db.membercard mc,up_map_code map 
	SET mc.country = code_new
	WHERE map.hotel_id = 0 AND map.code = 'nation' AND mc.country = map.code_old ;

	
	-- 翻译地址中的省、市、区域state,city,division // 请对照：code_province.code。code_city.code。code_city.division。
	UPDATE migrate_db.membercard mc,up_map_code map 
	SET mc.state = code_new
	WHERE map.hotel_id = 0 AND map.code = 'province' AND mc.state = map.code_old ;

	-- 在membercard中验证卡数量、积分余额、储值余额
	-- 卡总数
	SELECT card_type,card_level,COUNT(1) tl FROM membercard
	GROUP BY card_type,card_level
	UNION ALL
	SELECT '','',COUNT(1) FROM membercard;
	-- 积分总数
	SELECT SUM(point_pay) ,SUM(point_charge) ,SUM(point_pay - point_charge) balance FROM membercard;
        -- 储值卡余额、冻结数
	SELECT SUM(pay) ,SUM(charge) ,SUM(pay - charge) balance ,SUM(freeze) FROM membercard;
		
	BEGIN
-- 		SET @procresult = 0 ;
		SET var_return = '';
		LEAVE label_0 ;
	END ;
	
END$$

DELIMITER ;

CALL up_ihotel_up_member(@v);