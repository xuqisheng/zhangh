DELIMITER $$
SET sql_notes = 0$$
DROP PROCEDURE IF EXISTS `up_ihotel_mobile_rpt2`$$
CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_mobile_rpt2`(
	IN arg_hotel_group_id	INT,
	IN arg_aim				VARCHAR(1024),	-- 选择的对象。集团，或者类型，或者区域，或者某（些）酒店  
	IN arg_date				DATETIME		-- 指定日期 
)
SQL SECURITY INVOKER # added by mode utility
label_0:
BEGIN
	-- -----------------------------------------------------
	-- 分析数据  
	-- -----------------------------------------------------
	-- 郭迪胜 2015.6.28
	-- -----------------------------------------------------
	-- 注意：
	-- 参数 arg_aim 的说明
	-- 		传入的数据是一个类型+代码。 冒号分割 
	-- 			整个集团，传入0 
	-- 			按照管理类型传入，比如选择“直营店(代码=A)”，传入 100:A。 
	-- 			按照品牌类型传入，比如选择“高端品牌(代码=H)”，传入 110:H。 
	-- 			传入某个酒店，则传入 200:HTLCODE
	-- 	   暂时考虑单选，以后需要考虑多选或者负责选择的情况 
	-- 
	-- 修改日志 
	-- 2015.mm.dd XXX xxxxxx 
	-- 
	-- 
	-- -----------------------------------------------------

	DECLARE var_pos				INT;
	DECLARE var_count			INT;
	DECLARE var_level			VARCHAR(8);
	DECLARE var_code			VARCHAR(32); 
	DECLARE var_month_begin 	DATETIME;
	DECLARE var_year_begin 		DATETIME;
	DECLARE var_date_begin 		DATETIME;
	DECLARE var_amt1			DECIMAL(20,2); 
	DECLARE var_amt2			DECIMAL(20,2); 
	
	DROP TEMPORARY TABLE IF EXISTS tt_output;
	CREATE TEMPORARY TABLE tt_output (
		CODE 		VARCHAR(32),
		descript 	VARCHAR(60),
		descript_en VARCHAR(60),
		amt_today	DECIMAL(20,2),
		amt_month	DECIMAL(20,2),
		amt_year	DECIMAL(20,2),
		flag		VARCHAR(16),
		list_order	BIGINT(16)
	); 
	DROP TEMPORARY TABLE IF EXISTS tt_hotel;
	CREATE TEMPORARY TABLE tt_hotel (
		hotel_group_id	BIGINT(16),
		hotel_id		BIGINT(16),
		KEY index1(hotel_group_id, hotel_id)
	); 
	DROP TEMPORARY TABLE IF EXISTS tt_data;
	CREATE TEMPORARY TABLE tt_data (
		biz_date	DATETIME,
		CODE 		VARCHAR(32),
		descript 	VARCHAR(60),
		amount		DECIMAL(20,2),
		KEY index1(CODE)
	); 
	DROP TEMPORARY TABLE IF EXISTS tt_datasum;
	CREATE TEMPORARY TABLE tt_datasum (
		CODE 		VARCHAR(32),
		amount		DECIMAL(20,2),
		KEY index1(CODE)
	); 

	-- --------------------------------------------------
	-- 取得酒店结果集 
	-- --------------------------------------------------
	SET var_pos = POSITION(':' IN arg_aim); 
	SET var_level = LEFT(arg_aim, var_pos - 1); 
	SET var_code = SUBSTRING(arg_aim, var_pos + 1); 
	IF var_level = '0' THEN 
		INSERT INTO tt_hotel(hotel_group_id, hotel_id) SELECT hotel_group_id, id FROM hotel WHERE hotel_group_id=arg_hotel_group_id AND sta='I'; 
	ELSEIF var_level = '100' THEN 
		INSERT INTO tt_hotel(hotel_group_id, hotel_id) SELECT a.hotel_group_id, a.id FROM hotel a
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.manage_type=var_code; 
	ELSEIF var_level = '200' THEN 
		INSERT INTO tt_hotel(hotel_group_id, hotel_id) SELECT a.hotel_group_id, a.id FROM hotel a
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.code=var_code; 
	END IF; 
	-- 如果酒店结果集没有任何数据，则直接返回空 
	-- ? 
	
	-- --------------------------------------------------
	-- 取得本月、本年的其实日期 
	-- --------------------------------------------------
	SET var_month_begin = ADDDATE(arg_date, DAYOFMONTH(arg_date)*-1+1); 
	SET var_year_begin = ADDDATE(arg_date, DAYOFYEAR(arg_date)*-1+1); 

	-- --------------------------------------------------
	-- 插入基础数据 
	-- --------------------------------------------------
	INSERT INTO tt_output(CODE, descript, descript_en, amt_today, amt_month, amt_year, flag, list_order) VALUES
		('rev_rm', '客房收入合计', '', 0, 0, 0, '', 10),
		('rev_rm_fit', '--散客', '', 0, 0, 0, '', 20),
		('rev_rm_grp', '--团队', '', 0, 0, 0, '', 30),
		('rev_rm_long', '--长住', '', 0, 0, 0, '', 40),
		('rev_rm_oth', '--其他', '', 0, 0, 0, '', 50),
		('rev_fb', '餐饮收入合计', '', 0, 0, 0, '', 60),
		('rev_oth', '其他收入合计', '', 0, 0, 0, '', 70),
		('rev_ent', '娱乐收入合计', '', 0, 0, 0, '', 70),
		('rev_col', '代收收入合计', '', 0, 0, 0, '', 70),
		('rev_ttl', '酒店收入合计', '', 0, 0, 0, '', 110);

-- rep_jour_history 
-- 客房收入  '10000'
--     散客收入  '10110','10114','10115','10116','10120','10125','10130','10137','10139','10142','10143','10145'
--     团队收入  '10138'
--     长包收入  '10140'
--     其他收入  '10240','10250','10260','10320','10600' 
-- 餐饮 '20000'
-- 娱乐 '30000'
-- 其他 '40000'
-- 代收 '70000'
-- 总收入 '90000' 
	-- --------------------------------------------------
	-- 数据计算  
	-- --------------------------------------------------
	SET var_count = 1; 
	WHILE var_count < 4 DO
		BEGIN 
		DELETE FROM tt_data; 
		DELETE FROM tt_datasum; 
		
		IF var_count = 1 THEN 
			SET var_date_begin = arg_date; 
		ELSEIF var_count = 2 THEN 
			SET var_date_begin = var_month_begin; 
		ELSEIF var_count = 3 THEN 
			SET var_date_begin = var_year_begin; 
		END IF; 

		INSERT INTO tt_data (biz_date, CODE, descript, amount) 
			SELECT a.biz_date, a.code, a.descript, a.day 
				FROM rep_jour_history a, tt_hotel b 
				WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id
					AND a.biz_date>=var_date_begin AND a.biz_date<=arg_date 
					AND CODE IN ('10000','10110','10114','10115','10116','10120','10125','10130','10137','10139','10142','10143','10145','10138','10140','10240','10250','10260','10320','10600','20000','30000','40000','70000','90000'); 
		/*
		INSERT INTO tt_data (biz_date, CODE, descript, amount) 
			SELECT a.biz_date, a.audit_index, a.descript, a.amount 
				FROM rep_audit_index_history a, tt_hotel b 
				WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id
					AND a.biz_date>=var_date_begin AND a.biz_date<=arg_date 
					AND a.audit_index IN ('rev_fb1', 'rev_fb2', 'rev_fb3'); 
		*/
		
		UPDATE tt_data SET CODE='rev_rm' WHERE CODE = '10000';
		UPDATE tt_data SET CODE='rev_rm_fit' WHERE CODE IN ('10110','10114','10115','10116','10120','10125','10130','10137','10139','10142','10143','10145');
		UPDATE tt_data SET CODE='rev_rm_grp' WHERE CODE = '10138';
		UPDATE tt_data SET CODE='rev_rm_long' WHERE CODE = '10140';
		UPDATE tt_data SET CODE='rev_rm_oth' WHERE CODE IN ('10240','10250','10260','10320','10600');
		UPDATE tt_data SET CODE='rev_fb' WHERE CODE = '20000';
		UPDATE tt_data SET CODE='rev_ent' WHERE CODE = '30000';
		UPDATE tt_data SET CODE='rev_oth' WHERE CODE = '40000';
		UPDATE tt_data SET CODE='rev_col' WHERE CODE = '70000';
		UPDATE tt_data SET CODE='rev_ttl' WHERE CODE = '90000';
		INSERT INTO tt_datasum (CODE, amount) SELECT CODE, SUM(amount) FROM tt_data GROUP BY CODE ORDER BY CODE; 

		IF var_count = 1 THEN 
			UPDATE tt_output a, tt_datasum b SET a.amt_today=b.amount WHERE a.code=b.code; 
		ELSEIF var_count = 2 THEN 
			UPDATE tt_output a, tt_datasum b SET a.amt_month=b.amount WHERE a.code=b.code; 
		ELSE
			UPDATE tt_output a, tt_datasum b SET a.amt_year=b.amount WHERE a.code=b.code; 
		END IF; 

		SET var_count = var_count + 1; 
		END; 
	END WHILE; 


	-- output 
	SELECT CODE, descript, descript_en, amt_today, amt_month, amt_year, flag, list_order
		FROM tt_output ORDER BY list_order; 

	-- finished 
	DROP TEMPORARY TABLE IF EXISTS tt_output;
	DROP TEMPORARY TABLE IF EXISTS tt_hotel;
	DROP TEMPORARY TABLE IF EXISTS tt_data;
	DROP TEMPORARY TABLE IF EXISTS tt_datasum;
	
END$$

DELIMITER ;

