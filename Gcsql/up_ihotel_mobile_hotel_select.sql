DELIMITER $$
SET sql_notes = 0$$
DROP PROCEDURE IF EXISTS `up_ihotel_mobile_hotel_select`$$
CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_mobile_hotel_select`(
	IN arg_hotel_group_id	INT,
	IN arg_option			VARCHAR(32)	-- 数据模式，缺省按照管理类型  
)
SQL SECURITY INVOKER # added by mode utility
label_0:
BEGIN
	-- -----------------------------------------------------
	-- 生成手机PMS酒店选择数据 
	-- -----------------------------------------------------
	-- 郭迪胜 2015.6.28
	-- -----------------------------------------------------
	-- 注意：
	-- 
	-- 修改日志 
	-- 2015.mm.dd XXX xxxxxx 
	-- 
	-- 
	-- -----------------------------------------------------
	
	DROP TEMPORARY TABLE IF EXISTS tt_hotel_list;
	CREATE TEMPORARY TABLE tt_hotel_list (
		list_level 	INT(10),      -- 0=根部（集团） 100-199=分类节点 200=酒店节点 
		list_id 	BIGINT(16),   -- 对应各自表单的真实id
		list_code 	VARCHAR(20),  -- 对应各自表单的真实code
		list_node	VARCHAR(20),  -- 
		sta 		CHAR(2),      -- R=初始 H=停用 I=在用
		descript 	VARCHAR(60),
		descript_en VARCHAR(60),
		list_order	BIGINT(16) AUTO_INCREMENT,
		PRIMARY KEY(list_order)
	); 
	DROP TEMPORARY TABLE IF EXISTS tt_hotel_list2;
	CREATE TEMPORARY TABLE tt_hotel_list2 (
		list_node	VARCHAR(20),
		list_order	BIGINT(16)
	); 

	-- hotel 
	INSERT INTO tt_hotel_list (list_level, list_id, list_code, list_node, sta, descript, descript_en) 
		SELECT 200, a.id, a.CODE, a.manage_type, a.sta, CONCAT('→→', a.descript), CONCAT('→→', a.descript_en) FROM hotel a, code_base b 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_group_id=arg_hotel_group_id AND b.hotel_id=0 
				AND b.parent_code ='hotel_manage_type' AND a.manage_type=b.code
				ORDER BY b.list_order, b.code, a.list_order, a.code; 
	UPDATE tt_hotel_list SET list_order=list_order * 10 ORDER BY list_order DESC;
	 
	-- manage_type 
	INSERT INTO tt_hotel_list2(list_node, list_order) SELECT n.list_node, MIN(n.list_order) FROM tt_hotel_list n GROUP BY n.list_node; 
	INSERT INTO tt_hotel_list (list_level, list_id, list_code, sta, descript, descript_en, list_order) 
		SELECT 100, id, CODE, IF(is_halt='F', 'I', 'H'), CONCAT('〓', descript), CONCAT('〓', descript_en), b.list_order-1
			FROM code_base a, tt_hotel_list2 b 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=0 AND a.parent_code ='hotel_manage_type' AND a.code=b.list_node; 

	-- grp 
	INSERT INTO tt_hotel_list (list_level, list_id, list_code, sta, descript, descript_en, list_order) 
		SELECT 0, id, CODE, sta, descript, descript_en, 1 FROM hotel_group WHERE id=arg_hotel_group_id; 

	-- output 
	SELECT list_level, list_id, list_code, sta, descript, descript_en, list_order
		FROM tt_hotel_list ORDER BY list_order; 

	-- finished 
	DROP TEMPORARY TABLE IF EXISTS tt_hotel_list;
	DROP TEMPORARY TABLE IF EXISTS tt_hotel_list2;
	
END$$

DELIMITER ;

