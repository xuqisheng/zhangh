DELIMITER $$
SET sql_notes = 0$$
DROP PROCEDURE IF EXISTS `up_ihotel_mobile_rpt1`$$
CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_mobile_rpt1`(
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
		amt_today	VARCHAR(32),
		amt_month	VARCHAR(32),
		amt_year	VARCHAR(32),
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
		('rm_ttl', '总客房数', '', '', '', '', '', 10),
		('rm_avl', '可用房数', '', '', '', '', '', 20),
		('rm_ooo', '维修房数', '', '', '', '', '', 30),
		('rm_sold', '出租房数', '', '', '', '', '', 50),
		('rev_rm', '房租收入', '', '', '', '', '', 40),
		('occ', '出租率', '', '', '', '', '', 60),
		('avg', '平均房价', '', '', '', '', '', 70),
		('revpar', 'RevPar', '', '', '', '', '', 80),
		('rm_hse', '自用房数', '', '', '', '', '', 90);

		
	/*
	rm_ttl  80100
	rm_avl	80120
	rm_ooo	80110
	rm_sold 80200
    rm_hse  80130
	*/	
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
					AND code IN ('80100','80120','80110','80200','80130','10100');

		UPDATE tt_data SET code = 'rm_ttl',descript='总客房数' WHERE code='80100';
		UPDATE tt_data SET code = 'rm_avl',descript='可用房数' WHERE code='80120';
		UPDATE tt_data SET code = 'rm_ooo',descript='维修房数' WHERE code='80110';
		UPDATE tt_data SET code = 'rm_sold',descript='出租房数' WHERE code='80200';
		UPDATE tt_data SET code = 'rm_hse',descript='自用房数' WHERE code='80130';
		UPDATE tt_data SET code = 'rev_rm',descript='房租收入' WHERE code='10100';
		
		INSERT INTO tt_datasum (CODE, amount) SELECT CODE, SUM(amount) FROM tt_data GROUP BY CODE ORDER BY CODE; 

		IF var_count = 1 THEN 
			UPDATE tt_output a, tt_datasum b SET a.amt_today=CONVERT(ROUND(b.amount,0),CHAR(10)) WHERE a.code=b.code AND a.code IN ('rm_ttl', 'rm_avl', 'rm_ooo', 'rm_sold', 'rm_hse'); 
			UPDATE tt_output a, tt_datasum b SET a.amt_today=CONVERT(ROUND(b.amount,2),CHAR(10)) WHERE a.code=b.code AND a.code IN ('rev_rm'); 
		ELSEIF var_count = 2 THEN 
			UPDATE tt_output a, tt_datasum b SET a.amt_month=CONVERT(ROUND(b.amount,0),CHAR(10)) WHERE a.code=b.code AND a.code IN ('rm_ttl', 'rm_avl', 'rm_ooo', 'rm_sold', 'rm_hse'); 
			UPDATE tt_output a, tt_datasum b SET a.amt_month=CONVERT(ROUND(b.amount,2),CHAR(10)) WHERE a.code=b.code AND a.code IN ('rev_rm'); 
		ELSE
			UPDATE tt_output a, tt_datasum b SET a.amt_year=CONVERT(ROUND(b.amount,0),CHAR(10)) WHERE a.code=b.code AND a.code IN ('rm_ttl', 'rm_avl', 'rm_ooo', 'rm_sold', 'rm_hse'); 
			UPDATE tt_output a, tt_datasum b SET a.amt_year=CONVERT(ROUND(b.amount,2),CHAR(10)) WHERE a.code=b.code AND a.code IN ('rev_rm'); 
		END IF; 
		
		SELECT amount INTO var_amt1 FROM tt_datasum WHERE CODE='rm_sold' LIMIT 1;
		SELECT amount INTO var_amt2 FROM tt_datasum WHERE CODE='rm_ttl' LIMIT 1; 
		IF var_count = 1 THEN 
			UPDATE tt_output SET amt_today = CONCAT(CONVERT(ROUND(var_amt1*100/var_amt2, 2),CHAR(10)),'%') WHERE CODE='occ'; 
		ELSEIF var_count = 2 THEN 
			UPDATE tt_output SET amt_month = CONCAT(CONVERT(ROUND(var_amt1*100/var_amt2, 2),CHAR(10)),'%') WHERE CODE='occ'; 
		ELSE
			UPDATE tt_output SET amt_year = CONCAT(CONVERT(ROUND(var_amt1*100/var_amt2, 2),CHAR(10)),'%') WHERE CODE='occ'; 
		END IF; 

		SELECT amount INTO var_amt1 FROM tt_datasum WHERE CODE='rm_sold' LIMIT 1;
		SELECT amount INTO var_amt2 FROM tt_datasum WHERE CODE='rev_rm' LIMIT 1; 
		IF var_count = 1 THEN 
			UPDATE tt_output SET amt_today = CONVERT(ROUND(var_amt2/var_amt1, 2), CHAR(16)) WHERE CODE='avg'; 
		ELSEIF var_count = 2 THEN 
			UPDATE tt_output SET amt_month = CONVERT(ROUND(var_amt2/var_amt1, 2), CHAR(16)) WHERE CODE='avg'; 
		ELSE
			UPDATE tt_output SET amt_year = CONVERT(ROUND(var_amt2/var_amt1, 2), CHAR(16)) WHERE CODE='avg'; 
		END IF; 

		SELECT amount INTO var_amt1 FROM tt_datasum WHERE CODE='rm_avl' LIMIT 1;
		SELECT amount INTO var_amt2 FROM tt_datasum WHERE CODE='rev_rm' LIMIT 1; 
		IF var_count = 1 THEN 
			UPDATE tt_output SET amt_today = CONVERT(ROUND(var_amt2/var_amt1, 2), CHAR(16)) WHERE CODE='revpar'; 
		ELSEIF var_count = 2 THEN 
			UPDATE tt_output SET amt_month = CONVERT(ROUND(var_amt2/var_amt1, 2), CHAR(16)) WHERE CODE='revpar'; 
		ELSE
			UPDATE tt_output SET amt_year = CONVERT(ROUND(var_amt2/var_amt1, 2), CHAR(16)) WHERE CODE='revpar'; 
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

/*
CALL up_ihotel_mobile_rpt1(1, '0:aaa', '2015-06-20'); 
CALL up_ihotel_mobile_rpt1(1, '100:1', '2015-06-20'); 
CALL up_ihotel_mobile_rpt1(1, '200:AT532001', '2015-06-20'); 
*/
