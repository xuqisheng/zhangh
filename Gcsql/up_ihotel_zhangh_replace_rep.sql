DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_zhangh_replace_rep`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_zhangh_replace_rep`(
	IN arg_hotel_group_id	INT,
	IN arg_origin_hotelid	INT,
	IN arg_target_hotelid	INT
	)
    SQL SECURITY INVOKER
label_0:
BEGIN
	-- ==========================================================================================================
	-- 用途：以某家酒店为标准报表模板替换同集团某家酒店或同集团其它全部酒店
	-- 解释: CALL up_ihotel_zhangh_replace_rep(集团id,模板酒店id,目标酒店id)
	--       此过程最先适用于四川岷山,注意某中特殊性
	--		 若将(1=1)替换为指定hotel_id，即可针对指定范围内hotel_id替换
	--       比如:(hotel_id <=100 OR hotel_id>=130) AND hotel_id>1
	-- 范例: CALL up_ihotel_zhangh_replace_rep(1,104,10) 以104为模板替换10酒店
	-- 范例: CALL up_ihotel_zhangh_replace_rep(1,104,NULL) 以104为模板替换除104酒店外其它酒店
	-- 
	-- 作者：
	-- ===========================================================================================================
	--	报表类别
	DELETE FROM report_category WHERE hotel_group_id = arg_hotel_group_id AND hotel_id <> arg_origin_hotelid AND IF(arg_target_hotelid IS NOT NULL,hotel_id = arg_target_hotelid,(1=1));
	INSERT INTO report_category (hotel_group_id,hotel_id,code,descript,descript_en,is_sys,is_halt,list_order,create_user,create_datetime,modify_user,modify_datetime,is_dispatch)
		SELECT a.hotel_group_id,b.id,a.code,a.descript,a.descript_en,a.is_sys,a.is_halt,a.list_order,a.create_user,a.create_datetime,a.modify_user,a.modify_datetime,a.is_dispatch
		FROM report_category a,hotel b WHERE a.hotel_group_id=arg_hotel_group_id AND b.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_origin_hotelid AND a.is_halt='F' AND b.id <> arg_origin_hotelid AND IF(arg_target_hotelid IS NOT NULL,b.id = arg_target_hotelid,(1=1));
		
	--	快捷报表类别
	DELETE FROM report_express_code WHERE hotel_group_id = arg_hotel_group_id AND hotel_id <> arg_origin_hotelid AND IF(arg_target_hotelid IS NOT NULL,hotel_id = arg_target_hotelid,(1=1));
	INSERT INTO report_express_code (param_form_name,hotel_group_id,hotel_id,code,descript,descript_en,is_sys,is_halt,list_order,create_user,create_datetime,modify_user,modify_datetime,is_dispatch)
		SELECT a.param_form_name,a.hotel_group_id,b.id,a.code,a.descript,a.descript_en,a.is_sys,a.is_halt,a.list_order,a.create_user,a.create_datetime,a.modify_user,a.modify_datetime,a.is_dispatch
		FROM report_express_code a,hotel b WHERE a.hotel_group_id=arg_hotel_group_id AND b.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_origin_hotelid AND a.is_halt='F' AND b.id <> arg_origin_hotelid AND IF(arg_target_hotelid IS NOT NULL,b.id = arg_target_hotelid,(1=1));
		
	--	快捷报表
	DELETE FROM report_express_define WHERE hotel_group_id = arg_hotel_group_id AND hotel_id <> arg_origin_hotelid AND IF(arg_target_hotelid IS NOT NULL,hotel_id = arg_target_hotelid,(1=1));
	INSERT INTO report_express_define (hotel_group_id,hotel_id,report_code,print_num,is_halt,list_order,create_user,create_datetime,modify_user,modify_datetime,category_code,is_dispatch)
		SELECT a.hotel_group_id,b.id,a.report_code,a.print_num,a.is_halt,a.list_order,a.create_user,a.create_datetime,a.modify_user,a.modify_datetime,a.category_code,a.is_dispatch
		FROM report_express_define a,hotel b WHERE a.hotel_group_id=arg_hotel_group_id AND b.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_origin_hotelid AND a.is_halt='F' AND b.id <> arg_origin_hotelid AND IF(arg_target_hotelid IS NOT NULL,b.id = arg_target_hotelid,(1=1));
	
	--	报表中心
	DELETE FROM report_center WHERE hotel_group_id = arg_hotel_group_id AND rep_category<>'LPS' AND hotel_id <> arg_origin_hotelid AND IF(arg_target_hotelid IS NOT NULL,hotel_id = arg_target_hotelid,(1=1));	
	INSERT INTO report_center(hotel_group_id,hotel_id,rep_category,list_split,rep_type,code,alias_code,descript,descript_en,remark,allow_appcode,rep_define,param_win,lic_code,is_orientation,is_sys,is_halt,list_order,create_user,create_datetime,modify_user,modify_datetime,is_dispatch)
		SELECT a.hotel_group_id,b.id,a.rep_category,a.list_split,a.rep_type,a.code,a.alias_code,a.descript,a.descript_en,a.remark,a.allow_appcode,a.rep_define,a.param_win,a.lic_code,a.is_orientation,a.is_sys,a.is_halt,a.list_order,a.create_user,a.create_datetime,a.modify_user,a.modify_datetime,a.is_dispatch
		FROM report_center a,hotel b WHERE a.hotel_group_id=arg_hotel_group_id AND b.hotel_group_id=arg_hotel_group_id AND a.is_halt='F' AND a.rep_category<>'LPS' AND a.hotel_id=arg_origin_hotelid AND b.id <> arg_origin_hotelid AND IF(arg_target_hotelid IS NOT NULL,b.id = arg_target_hotelid,(1=1));
	
	
	DELETE FROM report_center WHERE hotel_group_id = arg_hotel_group_id AND rep_category<>'LPS' AND code IN ('SYS-CM1','SYS-U006-9') AND hotel_id <> arg_origin_hotelid AND IF(arg_target_hotelid IS NOT NULL,hotel_id = arg_target_hotelid,(1=1));	
	UPDATE report_center SET descript='销售分析明细报表2' WHERE hotel_group_id = arg_hotel_group_id AND rep_category<>'LPS' AND code='SYS-U006-4' AND hotel_id <> arg_origin_hotelid AND IF(arg_target_hotelid IS NOT NULL,hotel_id = arg_target_hotelid,(1=1));	
	UPDATE report_center SET descript='销售分析区间报表2' WHERE hotel_group_id = arg_hotel_group_id AND rep_category<>'LPS' AND code='SYS-U006-6' AND hotel_id <> arg_origin_hotelid AND IF(arg_target_hotelid IS NOT NULL,hotel_id = arg_target_hotelid,(1=1));
	
	-- 给每一个角色添加全部报表的权限
	DELETE FROM user_auth_cfg_role_rep WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_target_hotelid;	
	INSERT INTO user_auth_cfg_role_rep (hotel_group_id,hotel_id,save_id,role_code,rep_code,rep_level,create_user,create_datetime,modify_user,modify_datetime)
	SELECT a.hotel_group_id,a.hotel_id,NULL,b.code,a.code,3,'ADMIN',NOW(),'ADMIN',NOW()
		FROM report_center a,user_role b WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_target_hotelid AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_target_hotelid AND a.is_halt='F' AND b.is_halt='F';
		
	-- 以某一家酒店为模板进行报表赋权
	/*
	INSERT INTO user_auth_cfg_role_rep (hotel_group_id,hotel_id,save_id,role_code,rep_code,rep_level,create_user,create_datetime,modify_user,modify_datetime)
	SELECT a.hotel_group_id,b.id,a.save_id,a.role_code,a.rep_code,a.rep_level,'ADMIN',NOW(),'ADMIN',NOW()
		FROM user_auth_cfg_role_rep a,hotel b WHERE a.hotel_group_id=arg_hotel_group_id AND b.hotel_group_id=arg_hotel_group_id AND a.hotel_id=1 AND IF(arg_target_hotelid IS NOT NULL,b.id = arg_target_hotelid,(b.id <=100 OR b.id>=130) AND b.id>1 AND b.id<>16);
	*/
	
END$$

DELIMITER ;

-- CALL up_ihotel_zhangh_replace_rep(1,104,10);
-- CALL up_ihotel_zhangh_replace_rep(1,104,NULL);
-- DROP PROCEDURE IF EXISTS `up_ihotel_zhangh_replace_rep`;