DELIMITER $$
SET sql_notes = 0$$
DROP PROCEDURE IF EXISTS `up_ihotel_mobile_rpt3`$$
CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_mobile_rpt3`(
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
	DECLARE var_date 			DATETIME;
	DECLARE var_date_end 		DATETIME;
	DECLARE var_amt1			DECIMAL(20,2); 
	DECLARE var_amt2			DECIMAL(20,2); 
	
	DROP TEMPORARY TABLE IF EXISTS tt_output;
	CREATE TEMPORARY TABLE tt_output (
		biz_date	DATETIME,			-- 日期 
		rmttl 		INT,				-- 总房数
		rmocc 		INT,				-- 用房数
		rmocc2 		DECIMAL(20,2),		-- 出租率
		rtavg		DECIMAL(20,2),		-- 平均房价
		rmrev		DECIMAL(20,2)		-- 客房收入
	); 
	DROP TEMPORARY TABLE IF EXISTS tt_hotel;
	CREATE TEMPORARY TABLE tt_hotel (
		hotel_group_id	BIGINT(16),
		hotel_id		BIGINT(16),
		rm_ttl			INT, 
		KEY index1(hotel_group_id, hotel_id)
	); 
	DROP TEMPORARY TABLE IF EXISTS tt_data;
	CREATE TEMPORARY TABLE tt_data (
		hotel_group_id	BIGINT(16),
		hotel_id		BIGINT(16),
		biz_date	DATETIME,			-- 日期 
		rmttl 		INT,				-- 总房数
		rmocc 		INT,				-- 用房数
		rmrev		DECIMAL(20,2),		-- 客房收入
		KEY index1(hotel_group_id, hotel_id, biz_date)
	); 
	DROP TEMPORARY TABLE IF EXISTS tt_datasum;
	CREATE TEMPORARY TABLE tt_datasum (
		biz_date	DATETIME,			-- 日期 
		rmttl 		INT,				-- 总房数
		rmocc 		INT,				-- 用房数
		rmrev		DECIMAL(20,2),		-- 客房收入
		KEY index1(biz_date)
	); 

	-- 起始日期不能小于今天 
	IF arg_date < CURDATE() THEN 
		SET arg_date = CURDATE(); 
	END IF; 
	
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
	UPDATE tt_hotel a SET a.rm_ttl = IFNULL((SELECT COUNT(b.code) FROM room_no b WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id), 0); 

	-- --------------------------------------------------
	-- 数据计算 
	-- --------------------------------------------------
	SET var_date = arg_date; 
	SET var_date_end = ADDDATE(arg_date, 10); 
	WHILE var_date < var_date_end DO 
		BEGIN
			INSERT INTO tt_output(biz_date, rmttl, rmocc, rmocc2, rtavg, rmrev) VALUES (var_date, 0, 0, 0, 0, 0);
			INSERT INTO tt_data(hotel_group_id, hotel_id, biz_date, rmttl, rmocc, rmrev) 
				SELECT hotel_group_id, hotel_id, var_date, rm_ttl, 0, 0 FROM tt_hotel;
		
		SET var_date = ADDDATE(var_date, 1); 
		END; 
	END WHILE; 
	
	UPDATE tt_data a SET a.rmocc = IFNULL((SELECT SUM(b.sure_book_num+b.unsure_book_num) FROM rsv_rmtype_total b WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.biz_date=b.occ_date), 0); 
	UPDATE tt_data a SET a.rmrev = IFNULL((SELECT SUM(b.real_rate*b.rmnum) FROM rsv_rate b, rsv_src c, master_base d 
				WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.biz_date=b.rsv_date
					AND c.hotel_group_id=b.hotel_group_id AND c.hotel_id=b.hotel_id 
					AND d.hotel_group_id=b.hotel_group_id AND d.hotel_id=b.hotel_id 
					AND b.rsv_src_id=c.id AND c.accnt=d.id 
				), 0); 
	
	INSERT INTO tt_datasum(biz_date, rmttl, rmocc, rmrev) SELECT biz_date, SUM(rmttl), SUM(rmocc), SUM(rmrev) FROM tt_data GROUP BY biz_date; 

	UPDATE tt_output a, tt_datasum b SET a.rmttl=b.rmttl, a.rmocc=b.rmocc, a.rmrev=b.rmrev WHERE a.biz_date=b.biz_date; 
	UPDATE tt_output SET rmocc2 = ROUND(rmocc/rmttl, 4), rtavg=ROUND(rmrev/rmocc,2); 
	
	-- output 
--  	SELECT biz_date, rmocc, rmocc2, rtavg, rmrev
--  		FROM tt_output ORDER BY biz_date; 
 	SELECT biz_date, rmocc, CONCAT(CONVERT(ROUND(rmocc2*100,2), CHAR(10)), '%') AS rmocc2, rtavg, rmrev
 		FROM tt_output ORDER BY biz_date; 

	-- finished 
	DROP TEMPORARY TABLE IF EXISTS tt_output;
	DROP TEMPORARY TABLE IF EXISTS tt_hotel;
	DROP TEMPORARY TABLE IF EXISTS tt_data;
	DROP TEMPORARY TABLE IF EXISTS tt_datasum;
	
END$$

DELIMITER ;

