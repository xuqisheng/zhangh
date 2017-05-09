DELIMITER $$

USE `portal`$$

DROP PROCEDURE IF EXISTS `up_ihotel_rep_forecast_market_son`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_rep_forecast_market_son`(
	IN arg_hotel_group_id	INT,
	IN arg_hotel_id			INT,
	IN arg_begin_date		DATETIME,
	IN arg_end_date			DATETIME
)
BEGIN
	DECLARE var_biz_date	DATETIME;
	
	-- SET var_biz_date = arg_begin_date;
	-- 三亚五号 市场码预测报表[间]
	
	SELECT biz_date INTO var_biz_date FROM audit_flag WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;
		
	DROP TABLE IF EXISTS tmp_forecast_day;
	CREATE TABLE tmp_forecast_day(
		hotel_group_id		INT,
		hotel_id			INT,
		biz_date			DATETIME,
		market_code			VARCHAR(20),
		market_name			VARCHAR(50) DEFAULT '',
		index_code			VARCHAR(20),
		index_name			VARCHAR(50) DEFAULT '',
		amount				DECIMAL(12,2) NOT NULL DEFAULT 0.00,
		KEY index1(hotel_group_id,hotel_id,market_code),
		KEY index2(hotel_group_id,hotel_id,biz_date,index_code),
		KEY index3(hotel_group_id,hotel_id,index_code)
	);
	
	DROP TABLE IF EXISTS tmp_forecast_day_son;
	CREATE TABLE tmp_forecast_day_son(
		hotel_group_id		INT,
		hotel_id			INT,
		biz_date			DATETIME,
		market_code			VARCHAR(20),
		market_name			VARCHAR(50) DEFAULT '',
		index_code			VARCHAR(20),
		index_name			VARCHAR(50) DEFAULT '',
		amount				DECIMAL(12,2) NOT NULL DEFAULT 0.00,
		rmtype				VARCHAR(20),
		KEY index1(hotel_group_id,hotel_id,market_code),
		KEY index2(hotel_group_id,hotel_id,rmtype)
	);
	
	DROP TEMPORARY TABLE IF EXISTS tmp_rmtype_son;
	CREATE TEMPORARY TABLE tmp_rmtype_son (
		rmtype		VARCHAR(5),
		descript	VARCHAR(60),
		quan		INT,
		KEY index1(rmtype)
	);
	INSERT INTO tmp_rmtype_son (rmtype,quan)
		SELECT DISTINCT rmtype,rmnum FROM (
			SELECT a.rmtype AS rmtype,a.code AS aa,b.code AS bb,COUNT(1) AS rmnum FROM room_no a
			LEFT JOIN room_no b ON b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.parent_code=a.code
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.parent_code='' GROUP BY a.code
			UNION
			SELECT a.rmtype AS rmtype,a.code AS aa,b.code AS bb,COUNT(1) AS rmnum FROM room_no a
			LEFT JOIN room_no b ON b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.parent_code=a.code
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.parent_code<>'' GROUP BY a.code ORDER BY rmtype) AS aa;
	
	WHILE arg_begin_date <= arg_end_date DO
		BEGIN
					
			IF arg_begin_date = var_biz_date THEN				
				-- 房数1
				INSERT INTO tmp_forecast_day_son(hotel_group_id,hotel_id,biz_date,market_code,market_name,index_code,index_name,amount,rmtype)
					SELECT arg_hotel_group_id,arg_hotel_id,arg_begin_date,b.market,'','A1_rmnum1','房数',IFNULL(SUM(b.rmnum),0),b.rmtype
						FROM master_base a,rsv_src b WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.id = b.accnt AND a.id = a.rsv_id
							AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.occ_flag IN ('RF','RG') AND arg_begin_date >= b.arr_date 
							AND arg_begin_date < b.dep_date GROUP BY b.rmtype,b.market;	
				-- 房数2
				INSERT INTO tmp_forecast_day_son(hotel_group_id,hotel_id,biz_date,market_code,market_name,index_code,index_name,amount,rmtype)
					SELECT arg_hotel_group_id,arg_hotel_id,arg_begin_date,b.market,'','A1_rmnum2','房数',COUNT(DISTINCT a.master_id,a.rmno_son),b.rmtype
						FROM master_base a,rsv_src b WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.id = b.accnt AND a.id <> a.rsv_id
							AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.occ_flag = 'MF' AND arg_begin_date >= b.arr_date 
								AND arg_begin_date < b.dep_date AND a.rsv_class = 'F' GROUP BY b.rmtype,b.market;
			ELSE
				-- 房数1
				INSERT INTO tmp_forecast_day_son(hotel_group_id,hotel_id,biz_date,market_code,market_name,index_code,index_name,amount,rmtype)
					SELECT arg_hotel_group_id,arg_hotel_id,arg_begin_date,b.market,'','A1_rmnum1','房数',IFNULL(SUM(b.rmnum),0),b.rmtype
						FROM master_base a,rsv_src b WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.id = b.accnt AND a.id = a.rsv_id
							AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.occ_flag IN ('RF','RG') AND arg_begin_date >= b.arr_date 
							AND arg_begin_date < b.dep_date GROUP BY b.rmtype,b.market;	
				-- 房数2
				INSERT INTO tmp_forecast_day_son(hotel_group_id,hotel_id,biz_date,market_code,market_name,index_code,index_name,amount,rmtype)
					SELECT arg_hotel_group_id,arg_hotel_id,arg_begin_date,b.market,'','A1_rmnum2','房数',COUNT(DISTINCT a.master_id),b.rmtype
						FROM master_base a,rsv_src b WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.id = b.accnt AND a.id <> a.rsv_id
							AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.occ_flag = 'MF' AND arg_begin_date >= b.arr_date 
								AND arg_begin_date < b.dep_date AND a.rsv_class = 'F' GROUP BY b.rmtype,b.market;
			END IF;
			
			INSERT INTO tmp_forecast_day(hotel_group_id,hotel_id,biz_date,market_code,market_name,index_code,index_name,amount)
				SELECT arg_hotel_group_id,arg_hotel_id,b.biz_date,b.market_code,b.market_name,b.index_code,b.index_name,IF(b.biz_date = var_biz_date,b.amount,a.quan*b.amount)
				FROM tmp_rmtype_son a,tmp_forecast_day_son b WHERE a.rmtype=b.rmtype AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id 
				AND b.biz_date=arg_begin_date AND b.index_code IN ('A1_rmnum1','A1_rmnum2');			
				
				
			INSERT INTO tmp_forecast_day(hotel_group_id,hotel_id,biz_date,market_code,market_name,index_code,index_name,amount)		
			SELECT arg_hotel_group_id,arg_hotel_id,arg_begin_date,a.code,a.descript,'A1_rmnum1','房数',0
					FROM code_base a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.parent_code='market_code' AND a.is_halt='F'
						AND NOT EXISTS(SELECT 1 FROM tmp_forecast_day b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.code=b.market_code AND b.biz_date=arg_begin_date AND b.index_code='A1_rmnum1');				
			
			INSERT INTO tmp_forecast_day(hotel_group_id,hotel_id,biz_date,market_code,market_name,index_code,index_name,amount)		
			SELECT arg_hotel_group_id,arg_hotel_id,arg_begin_date,a.code,a.descript,'A1_rmnum2','房数',0
					FROM code_base a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.parent_code='market_code' AND a.is_halt='F'
						AND NOT EXISTS(SELECT 1 FROM tmp_forecast_day b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.code=b.market_code AND b.biz_date=arg_begin_date AND b.index_code='A1_rmnum2');
								
			-- 房费
			INSERT INTO tmp_forecast_day(hotel_group_id,hotel_id,biz_date,market_code,market_name,index_code,index_name,amount)
				SELECT arg_hotel_group_id,arg_hotel_id,arg_begin_date,a.market,'','A4_rmrate','房费',IFNULL(SUM(IFNULL(b.real_share_rate,a.real_rate) * a.rmnum),0)
					FROM rsv_src a LEFT JOIN rsv_rate AS b ON b.rsv_src_id = a.id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.rsv_date = arg_begin_date,master_base c  
					WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND arg_begin_date >= a.arr_date AND arg_begin_date < a.dep_date 
						AND c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = arg_hotel_id AND a.accnt = c.id AND a.occ_flag IN ('MF','RG','RF') GROUP BY a.market;
						
			INSERT INTO tmp_forecast_day(hotel_group_id,hotel_id,biz_date,market_code,market_name,index_code,index_name,amount)		
			SELECT arg_hotel_group_id,arg_hotel_id,arg_begin_date,a.code,a.descript,'A4_rmrate','房费',0
					FROM code_base a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.parent_code='market_code' AND a.is_halt='F'
						AND NOT EXISTS(SELECT 1 FROM tmp_forecast_day b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.code=b.market_code AND b.biz_date=arg_begin_date AND b.index_code='A4_rmrate');						
						
			-- 均价
			INSERT INTO tmp_forecast_day(hotel_group_id,hotel_id,biz_date,market_code,market_name,index_code,index_name,amount)
				SELECT arg_hotel_group_id,arg_hotel_id,arg_begin_date,CODE,'','A3_adr','均价',0
					FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code='market_code' AND is_halt='F';
			
			-- 人数
			INSERT INTO tmp_forecast_day(hotel_group_id,hotel_id,biz_date,market_code,market_name,index_code,index_name,amount)
				SELECT arg_hotel_group_id,arg_hotel_id,arg_begin_date,CODE,'','A5_people','人数',0
					FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code='market_code' AND is_halt='F';
					
			-- 早餐
			INSERT INTO tmp_forecast_day(hotel_group_id,hotel_id,biz_date,market_code,market_name,index_code,index_name,amount)
				SELECT arg_hotel_group_id,arg_hotel_id,arg_begin_date,CODE,'','A6_package','早餐',0
					FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code='market_code' AND is_halt='F';
			
			-- 净房费
			INSERT INTO tmp_forecast_day(hotel_group_id,hotel_id,biz_date,market_code,market_name,index_code,index_name,amount)
				SELECT arg_hotel_group_id,arg_hotel_id,arg_begin_date,CODE,'','A7_netted','净房费',0
					FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code='market_code' AND is_halt='F';
			
			SET arg_begin_date = DATE_ADD(arg_begin_date,INTERVAL 1 DAY);	
			
		END;
	END WHILE;
	
	INSERT INTO tmp_forecast_day(hotel_group_id,hotel_id,biz_date,market_code,market_name,index_code,index_name,amount)
		SELECT arg_hotel_group_id,arg_hotel_id,biz_date,market_code,market_name,'A1_rmnum',index_name,SUM(amount)
			FROM tmp_forecast_day 
			WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND index_code IN ('A1_rmnum1','A1_rmnum2')
			GROUP BY biz_date,market_code;
			
	DELETE FROM tmp_forecast_day WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND index_code IN ('A1_rmnum1','A1_rmnum2');
	
	INSERT INTO tmp_forecast_day(hotel_group_id,hotel_id,biz_date,market_code,market_name,index_code,index_name,amount)
		SELECT arg_hotel_group_id,arg_hotel_id,'2099-12-31',market_code,market_name,index_code,index_name,SUM(amount)
			FROM tmp_forecast_day
			WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id
			GROUP BY market_code,index_code;
			
	INSERT INTO tmp_forecast_day(hotel_group_id,hotel_id,biz_date,market_code,market_name,index_code,index_name,amount)
		SELECT arg_hotel_group_id,arg_hotel_id,biz_date,'合计','合计',index_code,index_name,SUM(amount)
			FROM tmp_forecast_day 
			WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id
			GROUP BY biz_date,index_code;
	UPDATE tmp_forecast_day a,code_base b SET a.market_name = b.descript WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id
	 AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.market_code=b.code AND b.parent_code='market_code' AND b.is_halt='F';	
	UPDATE tmp_forecast_day a,
		(SELECT biz_date,market_code,amount FROM tmp_forecast_day WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND index_code='A1_rmnum') AS b,
		(SELECT biz_date,market_code,amount FROM tmp_forecast_day WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND index_code='A4_rmrate') AS c
	SET a.amount = IF(b.amount<>0,ROUND(c.amount/b.amount,2),0)
		WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.index_code='A3_adr' AND a.biz_date=b.biz_date AND a.biz_date=c.biz_date AND a.market_code=b.market_code AND a.market_code=c.market_code;
	
	UPDATE tmp_forecast_day a,
		(SELECT biz_date,market_code,amount FROM tmp_forecast_day WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND index_code='A1_rmnum') AS b
	SET a.amount = b.amount * 2
		WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.index_code='A5_people' AND a.biz_date=b.biz_date AND a.market_code=b.market_code;
	
	UPDATE tmp_forecast_day a,
		(SELECT biz_date,market_code,amount FROM tmp_forecast_day WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND index_code='A5_people') AS b
	SET a.amount = b.amount * 68
		WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.index_code='A6_package' AND a.biz_date=b.biz_date AND a.market_code=b.market_code;
	
	UPDATE tmp_forecast_day a,
		(SELECT biz_date,market_code,amount FROM tmp_forecast_day WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND index_code='A4_rmrate') AS b,
		(SELECT biz_date,market_code,amount FROM tmp_forecast_day WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND index_code='A6_package') AS c
	SET a.amount = (b.amount - c.amount) 
		WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.index_code='A7_netted' AND a.biz_date=b.biz_date AND a.biz_date=c.biz_date AND a.market_code=b.market_code AND a.market_code=c.market_code;
	
	SELECT biz_date,market_code,market_name,CONCAT(SUBSTRING(index_code,1,2),index_name) AS index_code,index_name,amount FROM tmp_forecast_day ORDER BY biz_date,market_code,index_code;
	
 END$$

DELIMITER ;