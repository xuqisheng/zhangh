DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_log_query_init`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_log_query_init`(
	IN arg_hotel_group_id	INT,
	IN arg_hotel_id			INT,
	IN var_dbname			VARCHAR(20)
)
    SQL SECURITY INVOKER
label_0:
BEGIN
	-- =========================================================
	-- 日志查询配置初始化
	-- 2016.7
	-- 作者:张惠
	-- =========================================================
	-- 日志大类 | 可自行扩展
	DELETE FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code = 'log_type_class';
	INSERT INTO code_base (hotel_group_id,hotel_id,code,parent_code,descript,descript_en,max_len,flag,code_category,is_sys,is_group,group_code,is_halt,list_order,
		create_user,create_datetime,modify_user,modify_datetime,code_type) VALUES
		(arg_hotel_group_id,arg_hotel_id,'A','log_type_class','预订接待','Reservation','0','','','F','','','F','100','ADMIN',NOW(),'ADMIN',NOW(),''),
		(arg_hotel_group_id,arg_hotel_id,'B','log_type_class','前台账务','Front','0','','','F','','','F','100','ADMIN',NOW(),'ADMIN',NOW(),''),
		(arg_hotel_group_id,arg_hotel_id,'C','log_type_class','会员卡','Member','0','','','F','','','F','100','ADMIN',NOW(),'ADMIN',NOW(),''),
		(arg_hotel_group_id,arg_hotel_id,'D','log_type_class','公关销售','Sale','0','','','F','','','F','100','ADMIN',NOW(),'ADMIN',NOW(),''),
		(arg_hotel_group_id,arg_hotel_id,'E','log_type_class','客房管家','HouseKeeping','0','','','F','','','F','100','ADMIN',NOW(),'ADMIN',NOW(),''),
		(arg_hotel_group_id,arg_hotel_id,'F','log_type_class','应收账','AR','0','','','F','','','F','100','ADMIN',NOW(),'ADMIN',NOW(),''),
		(arg_hotel_group_id,arg_hotel_id,'G','log_type_class','档案','Guest&Company','0','','','F','','','F','100','ADMIN',NOW(),'ADMIN',NOW(),''),
		(arg_hotel_group_id,arg_hotel_id,'H','log_type_class','系统','System','0','','','F','','','F','100','ADMIN',NOW(),'ADMIN',NOW(),''),
		(arg_hotel_group_id,arg_hotel_id,'I','log_type_class','餐饮','POS','0','','','F','','','F','100','ADMIN',NOW(),'ADMIN',NOW(),''),
		(arg_hotel_group_id,arg_hotel_id,'Z','log_type_class','其他','Other','0','','','F','','','F','100','ADMIN',NOW(),'ADMIN',NOW(),'');
	
	-- 日志小类 | 可自行扩展
	DELETE FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code = 'log_type';
	INSERT INTO code_base (hotel_group_id,hotel_id,code,parent_code,descript,descript_en,max_len,flag,code_category,is_sys,is_group,group_code,is_halt,list_order,
		create_user,create_datetime,modify_user,modify_datetime,code_type) VALUES
		(arg_hotel_group_id,arg_hotel_id,'A01','log_type','预订接待','Reservation','0','','A','F','','','F','100','ADMIN',NOW(),'ADMIN',NOW(),''),
		(arg_hotel_group_id,arg_hotel_id,'B01','log_type','前台账务','Front','0','','B','F','','','F','100','ADMIN',NOW(),'ADMIN',NOW(),''),
		(arg_hotel_group_id,arg_hotel_id,'C01','log_type','会员卡-信息','Member','0','','C','F','','','F','100','ADMIN',NOW(),'ADMIN',NOW(),''),
		(arg_hotel_group_id,arg_hotel_id,'C02','log_type','会员卡-卡','Card','0','','C','F','','','F','100','ADMIN',NOW(),'ADMIN',NOW(),''),
		(arg_hotel_group_id,arg_hotel_id,'C03','log_type','电子券','Coupon','0','','C','F','','','F','100','ADMIN',NOW(),'ADMIN',NOW(),''),
		(arg_hotel_group_id,arg_hotel_id,'D01','log_type','公关销售','Sale','0','','D','F','','','F','100','ADMIN',NOW(),'ADMIN',NOW(),''),
		(arg_hotel_group_id,arg_hotel_id,'E01','log_type','客房管家','HouseKeeping','0','','E','F','','','F','100','ADMIN',NOW(),'ADMIN',NOW(),''),
		(arg_hotel_group_id,arg_hotel_id,'F01','log_type','应收账','AR','0','','F','F','','','F','100','ADMIN',NOW(),'ADMIN',NOW(),''),
		(arg_hotel_group_id,arg_hotel_id,'G01','log_type','档案-客史','Guest','0','','G','F','','','F','100','ADMIN',NOW(),'ADMIN',NOW(),''),
		(arg_hotel_group_id,arg_hotel_id,'G02','log_type','档案-协议单位','Company','0','','G','F','','','F','100','ADMIN',NOW(),'ADMIN',NOW(),''),
		(arg_hotel_group_id,arg_hotel_id,'H01','log_type','系统-参数','System Param','0','','H','F','','','F','100','ADMIN',NOW(),'ADMIN',NOW(),''),
		(arg_hotel_group_id,arg_hotel_id,'H02','log_type','系统-代码','System Code','0','','H','F','','','F','100','ADMIN',NOW(),'ADMIN',NOW(),''),
		(arg_hotel_group_id,arg_hotel_id,'H03','log_type','系统-用户','System User','0','','H','F','','','F','100','ADMIN',NOW(),'ADMIN',NOW(),''),
		(arg_hotel_group_id,arg_hotel_id,'I01','log_type','餐饮','POS','0','','I','F','','','F','100','ADMIN',NOW(),'ADMIN',NOW(),''),
		(arg_hotel_group_id,arg_hotel_id,'Z01','log_type','其他','Other','0','','Z','F','','','F','100','ADMIN',NOW(),'ADMIN',NOW(),'');
		
	-- code_dictionary 数据不全,重新生成
	DELETE FROM code_dictionary WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	INSERT INTO code_dictionary(hotel_group_id,hotel_id,app_codes,code,parent_code,descript,descript_en,log_type,data_type,length,pricision,
		code_link,help_code,help_mode,master_table,remark,is_halt,list_order,create_user,create_datetime,modify_user,modify_datetime)
	SELECT arg_hotel_group_id,arg_hotel_id,'',UPPER(column_name),UPPER(table_name),'','','','',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'F','0','Proc',NOW(),'Proc',NOW() 
		FROM information_schema.columns WHERE TABLE_SCHEMA=var_dbname AND table_name NOT LIKE 'tmp%' ORDER BY table_name,ordinal_position;
	
	DELETE FROM code_dictionary WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND code IN ('hotel_group_id','hotel_id');
	
	INSERT INTO code_dictionary(hotel_group_id,hotel_id,app_codes,code,parent_code,descript,descript_en,log_type,data_type,length,pricision,
		code_link,help_code,help_mode,master_table,remark,is_halt,list_order,create_user,create_datetime,modify_user,modify_datetime)
	SELECT arg_hotel_group_id,arg_hotel_id,'',UPPER(table_name),'',table_comment,'','','',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'F','0','Proc',NOW(),'Proc',NOW() 
		FROM information_schema.tables WHERE TABLE_SCHEMA=var_dbname AND table_name NOT LIKE 'tmp%' ORDER BY table_name;
		
	DELETE FROM code_dictionary WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code='' AND code LIKE 'REP%';
	DELETE FROM code_dictionary WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code='' AND code LIKE 'GRP%';
	
	-- 配置日志查询 | 可结合上面的分类进行更详细定义
	UPDATE code_dictionary SET log_type='B01'  WHERE parent_code='' AND code LIKE 'ACCOUNT%';
	UPDATE code_dictionary SET log_type='B01'  WHERE parent_code='' AND code LIKE 'ACCREDIT%';
	UPDATE code_dictionary SET log_type='F01'  WHERE parent_code='' AND code LIKE 'AR%';
	UPDATE code_dictionary SET log_type='C02'  WHERE parent_code='' AND code LIKE 'CARD%';
	UPDATE code_dictionary SET log_type='H02'  WHERE parent_code='' AND code LIKE 'CODE%';
	UPDATE code_dictionary SET log_type='G02'  WHERE parent_code='' AND code LIKE 'COMPANY%';
	UPDATE code_dictionary SET log_type='C03'  WHERE parent_code='' AND code LIKE 'COUPON%';
	UPDATE code_dictionary SET log_type='A01'  WHERE parent_code='' AND code LIKE 'CRS%';
	UPDATE code_dictionary SET log_type='G01'  WHERE parent_code='' AND code LIKE 'GUEST%';
	UPDATE code_dictionary SET log_type='A01'  WHERE parent_code='' AND code LIKE 'MASTER%';
	UPDATE code_dictionary SET log_type='C01'  WHERE parent_code='' AND code LIKE 'MEMBER%';
	UPDATE code_dictionary SET log_type='I01'  WHERE parent_code='' AND code LIKE 'POS%';
	UPDATE code_dictionary SET log_type='E01'  WHERE parent_code='' AND code LIKE 'ROOM%';
	UPDATE code_dictionary SET log_type='A01'  WHERE parent_code='' AND code LIKE 'RSV%';
	UPDATE code_dictionary SET log_type='D01'  WHERE parent_code='' AND code LIKE 'SALES%';
	UPDATE code_dictionary SET log_type='H01'  WHERE parent_code='' AND code LIKE 'SYS%';
	UPDATE code_dictionary SET log_type='H03'  WHERE parent_code='' AND code LIKE 'USER%';
	UPDATE code_dictionary SET log_type='H02'  WHERE parent_code='' AND code LIKE 'WORK%';
	UPDATE code_dictionary SET log_type='H02'  WHERE parent_code='' AND log_type = '';	
	
	-- 删除日志配置表中的某些不重要的字段
	DELETE FROM log_info_config WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND entity_name='ACCOUNT' AND entity_column IN ('ARTICLE_CODE','CHARGE_BASE','CHARGE_DSC','CHARGE_OTH','CHARGE_SRV','CHARGE_TAX','PACKAGE_LIMIT','PKG_NUMBER','SPLIT_FLAG','SPLIT_CASHIER','TRANS_SUBACCNT');
	DELETE FROM log_info_config WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND entity_name IN ('ACCOUNT_CASHIER','ACCOUNT_CLOSE','ACCOUNT_HISTORY','ACCOUNT_RMPOST_PKG','CUR_EXCHANGE','FIXED_CHARGE','HOTEL_GROUP','MASTER_ARRDEP','RESERVE_GUEST','RESRV_BASE','ROOM_TYPE','ACCOUNT_RMPOST','PARTOUT_FLAG','CARD_LEVEL','CARD_LEVEL_EXTRA','CARD_POINT_RULE_DE','CARD_TYPE','COUPON','COUPON_PACKS','GUEST_PREFER','GUEST_RELATION','MEMBER_LINK_ADDR','MEMBER_LINK_BASE','SALES_MAN','COMPANY_BASE','COMPANY_TYPE','GUEST_BASE','GUEST_BLACK','GUEST_LINK_ADDR','GUEST_LINK_BASE','GUEST_TYPE','HOTEL','ACCOUNT');
	DELETE FROM log_info_config WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND entity_name='AR_MASTER' AND entity_column IN ('ARR','AR_CYCLE','BUILDING','CO_MSG','CREDIT_COMPANY','DEP','EMAIL','EXTRA_FLAG','FAX','HOTEL_GROUP_ID','HOTEL_ID','LIMIT_AMT','PAY_CODE','PHONE','REMINDER_MSG');
	DELETE FROM log_info_config WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND entity_name='CODE_RATECODE' AND entity_column IN ('ADDITION','ADV_MAX','ADV_MIN','AMENITIES','CANCEL_RULE','CATEGORY_ID','CMS_CODE','DEPOSIT_RULE','EXTRA_FLAG','HOTEL_GROUP_ID','HOTEL_GROUP_ID','IS_COMPLIMENTARY','IS_DAYUSE','IS_GROUP','IS_HALT','IS_HOUSEUSE','IS_NEGO','IS_SECRET','LIST_ORDER','MULTI','PARENT_CODE','STAY_MAX','STAY_MIN','TA_CODE');
	DELETE FROM log_info_config WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND entity_name='MASTER_BASE' AND entity_column IN ('AMENITIES','ARNO','BIZ_DATE','CMSCODE','CREDIT_COMPANY','DSC_PERCENT','DSC_REASON','EXTRA_FLAG','IS_FIX_RATE','IS_SECRET','IS_SECRET_RATE','LIMIT_AMT','LINK_ID','MEMBER_TYPE','PKG_LINK_ID','PURPOSE','RSV_CLASS','SPECIALS');
	DELETE FROM log_info_config WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND entity_name='MASTER_GUEST' AND entity_column IN ('CAREER','CITY','DIVISION','FIRST_NAME','HOTEL_GROUP_ID','HOTEL_ID','LANGUAGE','LAST_NAME','NAME2','NAME3','NAME_COMBINE','COUNTRY','OCCUPATION','PROFILE_TYPE','RACE','RELIGION','SALUTATION','STATE','TITLE');
	DELETE FROM log_info_config WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND entity_name='REAL_TIME_ROOM_STA' AND entity_column IN ('HOTEL_GROUP_ID','HOTEL_ID','IS_ADD_BED','IS_EXCEED_LIMIT','is_FREE','IS_LIVE','IS_MESSAGE','IS_SECRET','IS_UNION','RMCLASS','RMNO_INNER','IS_ARR','IS_DEP','IS_FOREIGN','IS_TMP','IS_VIP');

END$$

DELIMITER ;

-- CALL up_ihotel_log_query_init(2,18,'portal');
-- DROP PROCEDURE IF EXISTS `up_ihotel_log_query_init`;