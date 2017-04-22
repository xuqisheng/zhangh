DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_rep_herton_jour`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_rep_herton_jour`(
	IN arg_hotel_group_id 	INT,
	IN arg_hotel_id 		INT,
	IN arg_date_begin		DATETIME,
	IN arg_date_end			DATETIME
    )
    SQL SECURITY INVOKER
label_0:
BEGIN
	DECLARE var_sql 		VARCHAR(800);
	DECLARE var_num			INT;
	DECLARE var_amount		DECIMAL(12,2);
	DECLARE var_number1		DECIMAL(12,2);
	DECLARE var_number2		DECIMAL(12,2);
	DECLARE var_bdate		DATETIME;
	DECLARE var_bizdate		DATETIME;
	DECLARE var_fmtdate		VARCHAR(10);
	DECLARE var_week		VARCHAR(10);
	
	DROP TEMPORARY TABLE IF EXISTS tmp_herton_jour;
	CREATE TEMPORARY TABLE tmp_herton_jour (
		hotel_group_id 	INT 	NOT NULL,
		hotel_id 		INT 	NOT NULL,
		classno			VARCHAR(10),
		descript		VARCHAR(20),
		amount1			VARCHAR(10) NOT NULL DEFAULT 0,
		amount2			VARCHAR(10) NOT NULL DEFAULT 0,
		amount3			VARCHAR(10) NOT NULL DEFAULT 0,
		amount4			VARCHAR(10) NOT NULL DEFAULT 0,
		amount5			VARCHAR(10) NOT NULL DEFAULT 0,
		amount6			VARCHAR(10) NOT NULL DEFAULT 0,
		amount7			VARCHAR(10) NOT NULL DEFAULT 0,
		amount8			VARCHAR(10) NOT NULL DEFAULT 0,
		amount9			VARCHAR(10) NOT NULL DEFAULT 0,
		amount10		VARCHAR(10) NOT NULL DEFAULT 0,
		amount11		VARCHAR(10) NOT NULL DEFAULT 0,
		amount12		VARCHAR(10) NOT NULL DEFAULT 0,
		amount13		VARCHAR(10) NOT NULL DEFAULT 0,
		amount14		VARCHAR(10) NOT NULL DEFAULT 0,
		amount15		VARCHAR(10) NOT NULL DEFAULT 0,
		amount16		VARCHAR(10) NOT NULL DEFAULT 0,
		amount17		VARCHAR(10) NOT NULL DEFAULT 0,
		amount18		VARCHAR(10) NOT NULL DEFAULT 0,
		amount19		VARCHAR(10) NOT NULL DEFAULT 0,
		amount20		VARCHAR(10) NOT NULL DEFAULT 0,
		amount21		VARCHAR(10) NOT NULL DEFAULT 0,
		amount22		VARCHAR(10) NOT NULL DEFAULT 0,
		amount23		VARCHAR(10) NOT NULL DEFAULT 0,
		amount24		VARCHAR(10) NOT NULL DEFAULT 0,
		amount25		VARCHAR(10) NOT NULL DEFAULT 0,
		amount26		VARCHAR(10) NOT NULL DEFAULT 0,
		amount27		VARCHAR(10) NOT NULL DEFAULT 0,
		amount28		VARCHAR(10) NOT NULL DEFAULT 0,
		amount29		VARCHAR(10) NOT NULL DEFAULT 0,
		amount30		VARCHAR(10) NOT NULL DEFAULT 0,
		amount31		VARCHAR(10) NOT NULL DEFAULT 0,
		amount99		VARCHAR(10) NOT NULL DEFAULT 0,
		KEY index1(hotel_group_id,hotel_id,classno)
	);
	
	INSERT INTO tmp_herton_jour(hotel_group_id,hotel_id,classno,descript) 
		VALUES
		(arg_hotel_group_id,arg_hotel_id,'0100',' 日期'),
		(arg_hotel_group_id,arg_hotel_id,'1000',' 星期'),
		(arg_hotel_group_id,arg_hotel_id,'1010','可卖房'),
		(arg_hotel_group_id,arg_hotel_id,'1020','总间夜'),
		(arg_hotel_group_id,arg_hotel_id,'1030','维修房'),
		(arg_hotel_group_id,arg_hotel_id,'1040','入住率'),
		(arg_hotel_group_id,arg_hotel_id,'1050','平均房价'),
		(arg_hotel_group_id,arg_hotel_id,'1060','客房收入'),
		(arg_hotel_group_id,arg_hotel_id,'1070','餐饮收入'),
		(arg_hotel_group_id,arg_hotel_id,'1080','其他收入'),
		(arg_hotel_group_id,arg_hotel_id,'1090','总收入'),
		(arg_hotel_group_id,arg_hotel_id,'2000','间夜量'),
		(arg_hotel_group_id,arg_hotel_id,'2010','  前台散客'),
		(arg_hotel_group_id,arg_hotel_id,'2020','  集团网站'),
		(arg_hotel_group_id,arg_hotel_id,'2030','  商务协议'),
		(arg_hotel_group_id,arg_hotel_id,'2040','  政府散客'),
		(arg_hotel_group_id,arg_hotel_id,'2050','  长住客'),
		(arg_hotel_group_id,arg_hotel_id,'2060','  旅行社散客'),
		(arg_hotel_group_id,arg_hotel_id,'2070','  网络散客'),
		(arg_hotel_group_id,arg_hotel_id,'2080','  商务会议团'),
		(arg_hotel_group_id,arg_hotel_id,'2090','  政府会议团'),
		(arg_hotel_group_id,arg_hotel_id,'2100','  旅行团'),
		(arg_hotel_group_id,arg_hotel_id,'2110','  免费房'),
		(arg_hotel_group_id,arg_hotel_id,'2120','  自用房'),
		(arg_hotel_group_id,arg_hotel_id,'2130','  钟点房'),
		(arg_hotel_group_id,arg_hotel_id,'3000','平均房价'),
		(arg_hotel_group_id,arg_hotel_id,'3010','  前台散客'),
		(arg_hotel_group_id,arg_hotel_id,'3020','  集团网站'),
		(arg_hotel_group_id,arg_hotel_id,'3030','  商务协议'),
		(arg_hotel_group_id,arg_hotel_id,'3040','  政府散客'),
		(arg_hotel_group_id,arg_hotel_id,'3050','  长住客'),
		(arg_hotel_group_id,arg_hotel_id,'3060','  旅行社散客'),
		(arg_hotel_group_id,arg_hotel_id,'3070','  网络散客'),
		(arg_hotel_group_id,arg_hotel_id,'3080','  商务会议团'),
		(arg_hotel_group_id,arg_hotel_id,'3090','  政府会议团'),
		(arg_hotel_group_id,arg_hotel_id,'3100','  旅行团'),
		(arg_hotel_group_id,arg_hotel_id,'3110','  免费房'),
		(arg_hotel_group_id,arg_hotel_id,'3120','  自用房'),
		(arg_hotel_group_id,arg_hotel_id,'3130','  钟点房'),
		(arg_hotel_group_id,arg_hotel_id,'5000','房费收入'),
		(arg_hotel_group_id,arg_hotel_id,'5010','  前台散客'),
		(arg_hotel_group_id,arg_hotel_id,'5020','  集团网站'),
		(arg_hotel_group_id,arg_hotel_id,'5030','  商务协议'),
		(arg_hotel_group_id,arg_hotel_id,'5040','  政府散客'),
		(arg_hotel_group_id,arg_hotel_id,'5050','  长住客'),
		(arg_hotel_group_id,arg_hotel_id,'5060','  旅行社散客'),
		(arg_hotel_group_id,arg_hotel_id,'5070','  网络散客'),
		(arg_hotel_group_id,arg_hotel_id,'5080','  商务会议团'),
		(arg_hotel_group_id,arg_hotel_id,'5090','  政府会议团'),
		(arg_hotel_group_id,arg_hotel_id,'5100','  旅行团'),
		(arg_hotel_group_id,arg_hotel_id,'5110','  免费房'),
		(arg_hotel_group_id,arg_hotel_id,'5120','  自用房'),
		(arg_hotel_group_id,arg_hotel_id,'5130','  钟点房');
	
	SELECT biz_date INTO var_bdate FROM audit_flag WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	
	IF arg_date_end > ADDDATE(var_bdate, -1) THEN
		SET arg_date_end = ADDDATE(var_bdate, -1);
	END IF;

	IF DATEDIFF(arg_date_end,arg_date_begin) > 13 THEN
		SET arg_date_end = ADDDATE(arg_date_begin,13);
	END IF;
	
	SET var_num = 1;
	SET var_bizdate = arg_date_begin;	
	
	WHILE var_bizdate <= arg_date_end DO
		BEGIN			

			-- 日期
			SET var_fmtdate = DATE_FORMAT(var_bizdate,'%m-%d');
			SET var_sql = CONCAT('UPDATE tmp_herton_jour',' SET ','amount',var_num,' = \'',var_fmtdate,'\' WHERE hotel_group_id = ',arg_hotel_group_id,' AND hotel_id = ',arg_hotel_id,' AND classno = ','0100');					
			SET @exec_sql = var_sql;  
			PREPARE stmt FROM @exec_sql;
			EXECUTE stmt;		
			
			-- 星期
			CALL up_ihotel_getchinaweek(var_bizdate,var_week);
			SET var_sql = CONCAT('UPDATE tmp_herton_jour',' SET ','amount',var_num,' = \'',var_week,'\' WHERE hotel_group_id = ',arg_hotel_group_id,' AND hotel_id = ',arg_hotel_id,' AND classno = ','1000');					
			SET @exec_sql = var_sql;  
			PREPARE stmt FROM @exec_sql;
			EXECUTE stmt;
			
			-- 可卖房
			SELECT IFNULL(SUM(rooms_avl),0) INTO var_amount FROM rep_rmsale_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND rep_type='B' AND biz_date = var_bizdate;
			SET var_sql = CONCAT('UPDATE tmp_herton_jour',' SET ','amount',var_num,' = \'',var_amount,'\' WHERE hotel_group_id = ',arg_hotel_group_id,' AND hotel_id = ',arg_hotel_id,' AND classno = ','1010');					
			SET @exec_sql = var_sql;  
			PREPARE stmt FROM @exec_sql;
			EXECUTE stmt;
			
			-- 总间夜
			-- SELECT IFNULL(SUM(sold_fit + sold_grp + sold_long + sold_ent + rooms_hse),0) INTO var_amount FROM rep_rmsale_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND rep_type='B' AND biz_date = var_bizdate;
			SELECT IFNULL(SUM(rooms_total),0) INTO var_amount FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET';			
			SET var_sql = CONCAT('UPDATE tmp_herton_jour',' SET ','amount',var_num,' = \'',var_amount,'\' WHERE hotel_group_id = ',arg_hotel_group_id,' AND hotel_id = ',arg_hotel_id,' AND classno = ','1020');					
			SET @exec_sql = var_sql;  
			PREPARE stmt FROM @exec_sql;
			EXECUTE stmt;

			-- 维修房
			SELECT IFNULL(SUM(rooms_ooo),0) INTO var_amount FROM rep_rmsale_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND rep_type='B' AND biz_date = var_bizdate;
			SET var_sql = CONCAT('UPDATE tmp_herton_jour',' SET ','amount',var_num,' = \'',var_amount,'\' WHERE hotel_group_id = ',arg_hotel_group_id,' AND hotel_id = ',arg_hotel_id,' AND classno = ','1030');					
			SET @exec_sql = var_sql;  
			PREPARE stmt FROM @exec_sql;
			EXECUTE stmt;

			-- 入住率
			SELECT IFNULL(SUM(rooms_avl),0) INTO var_number1 FROM rep_rmsale_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND rep_type='B' AND biz_date = var_bizdate;			
			SELECT IFNULL(SUM(rooms_total),0) INTO var_number2 FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET';
			SET var_amount = IF(var_number1=0,0,ROUND(var_number2*100/var_number1,2));
			SET var_sql = CONCAT('UPDATE tmp_herton_jour',' SET ','amount',var_num,' = \'',var_amount,'\' WHERE hotel_group_id = ',arg_hotel_group_id,' AND hotel_id = ',arg_hotel_id,' AND classno = ','1040');					
			SET @exec_sql = var_sql;  
			PREPARE stmt FROM @exec_sql;
			EXECUTE stmt;			
			
			-- 平均房价
			SELECT IFNULL(SUM(rooms_total),0) INTO var_number1 FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET';
			SELECT IFNULL(SUM(rev_rm),0) INTO var_number2 FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET';
			SET var_amount = IF(var_number1=0,0,ROUND(var_number2/var_number1,2));
			SET var_sql = CONCAT('UPDATE tmp_herton_jour',' SET ','amount',var_num,' = \'',var_amount,'\' WHERE hotel_group_id = ',arg_hotel_group_id,' AND hotel_id = ',arg_hotel_id,' AND classno = ','1050');					
			SET @exec_sql = var_sql;  
			PREPARE stmt FROM @exec_sql;
			EXECUTE stmt;
			
			-- 客房收入
			SELECT IFNULL(SUM(day),0) INTO var_amount FROM rep_jour_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code='000005';
			SET var_sql = CONCAT('UPDATE tmp_herton_jour',' SET ','amount',var_num,' = \'',var_amount,'\' WHERE hotel_group_id = ',arg_hotel_group_id,' AND hotel_id = ',arg_hotel_id,' AND classno = ','1060');					
			SET @exec_sql = var_sql;  
			PREPARE stmt FROM @exec_sql;
			EXECUTE stmt;			
			
			-- 餐饮收入
			SELECT IFNULL(SUM(day),0) INTO var_amount FROM rep_jour_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code='000010';
			SET var_sql = CONCAT('UPDATE tmp_herton_jour',' SET ','amount',var_num,' = \'',var_amount,'\' WHERE hotel_group_id = ',arg_hotel_group_id,' AND hotel_id = ',arg_hotel_id,' AND classno = ','1070');					
			SET @exec_sql = var_sql;  
			PREPARE stmt FROM @exec_sql;
			EXECUTE stmt;			
			
			-- 其他收入
			SELECT IFNULL(SUM(day),0) INTO var_number1 FROM rep_jour_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code='000005';
			SELECT IFNULL(SUM(day),0) INTO var_number2 FROM rep_jour_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code='000010';
			SELECT IFNULL(SUM(day),0) INTO var_amount FROM rep_jour_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code='000090';
			SET var_amount = var_amount - var_number1 - var_number2;
			SET var_sql = CONCAT('UPDATE tmp_herton_jour',' SET ','amount',var_num,' = \'',var_amount,'\' WHERE hotel_group_id = ',arg_hotel_group_id,' AND hotel_id = ',arg_hotel_id,' AND classno = ','1080');					
			SET @exec_sql = var_sql;  
			PREPARE stmt FROM @exec_sql;
			EXECUTE stmt;
			
			-- 总收入
			SELECT IFNULL(SUM(day),0) INTO var_amount FROM rep_jour_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code='000090';
			SET var_sql = CONCAT('UPDATE tmp_herton_jour',' SET ','amount',var_num,' = \'',var_amount,'\' WHERE hotel_group_id = ',arg_hotel_group_id,' AND hotel_id = ',arg_hotel_id,' AND classno = ','1090');					
			SET @exec_sql = var_sql;  
			PREPARE stmt FROM @exec_sql;
			EXECUTE stmt;			
			
			-- 间夜量
			SELECT IFNULL(SUM(rooms_total),0) INTO var_amount FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET';
			SET var_sql = CONCAT('UPDATE tmp_herton_jour',' SET ','amount',var_num,' = \'',var_amount,'\' WHERE hotel_group_id = ',arg_hotel_group_id,' AND hotel_id = ',arg_hotel_id,' AND classno = ','2000');					
			SET @exec_sql = var_sql;  
			PREPARE stmt FROM @exec_sql;
			EXECUTE stmt;			

			-- 前台散客
			SELECT IFNULL(SUM(rooms_total),0) INTO var_amount FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET' AND code IN ('DIS','YJ','TAX','MEM');
			SET var_sql = CONCAT('UPDATE tmp_herton_jour',' SET ','amount',var_num,' = \'',var_amount,'\' WHERE hotel_group_id = ',arg_hotel_group_id,' AND hotel_id = ',arg_hotel_id,' AND classno = ','2010');					
			SET @exec_sql = var_sql;  
			PREPARE stmt FROM @exec_sql;
			EXECUTE stmt;			
			
			-- 集团网站
			SELECT IFNULL(SUM(rooms_total),0) INTO var_amount FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET' AND code IN ('WEB','APP');
			SET var_sql = CONCAT('UPDATE tmp_herton_jour',' SET ','amount',var_num,' = \'',var_amount,'\' WHERE hotel_group_id = ',arg_hotel_group_id,' AND hotel_id = ',arg_hotel_id,' AND classno = ','2020');					
			SET @exec_sql = var_sql;  
			PREPARE stmt FROM @exec_sql;
			EXECUTE stmt;

			-- 商务协议
			SELECT IFNULL(SUM(rooms_total),0) INTO var_amount FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET' AND code IN ('COR','WEG');
			SET var_sql = CONCAT('UPDATE tmp_herton_jour',' SET ','amount',var_num,' = \'',var_amount,'\' WHERE hotel_group_id = ',arg_hotel_group_id,' AND hotel_id = ',arg_hotel_id,' AND classno = ','2030');					
			SET @exec_sql = var_sql;  
			PREPARE stmt FROM @exec_sql;
			EXECUTE stmt;			
			
			-- 政府散客
			SELECT IFNULL(SUM(rooms_total),0) INTO var_amount FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET' AND code IN ('GMG');
			SET var_sql = CONCAT('UPDATE tmp_herton_jour',' SET ','amount',var_num,' = \'',var_amount,'\' WHERE hotel_group_id = ',arg_hotel_group_id,' AND hotel_id = ',arg_hotel_id,' AND classno = ','2040');					
			SET @exec_sql = var_sql;  
			PREPARE stmt FROM @exec_sql;
			EXECUTE stmt;

			-- 长住客
			SELECT IFNULL(SUM(rooms_total),0) INTO var_amount FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET' AND code IN ('LON');
			SET var_sql = CONCAT('UPDATE tmp_herton_jour',' SET ','amount',var_num,' = \'',var_amount,'\' WHERE hotel_group_id = ',arg_hotel_group_id,' AND hotel_id = ',arg_hotel_id,' AND classno = ','2050');					
			SET @exec_sql = var_sql;  
			PREPARE stmt FROM @exec_sql;
			EXECUTE stmt;
			
			-- 旅行社散客
			SELECT IFNULL(SUM(rooms_total),0) INTO var_amount FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET' AND code IN ('S1','S2');
			SET var_sql = CONCAT('UPDATE tmp_herton_jour',' SET ','amount',var_num,' = \'',var_amount,'\' WHERE hotel_group_id = ',arg_hotel_group_id,' AND hotel_id = ',arg_hotel_id,' AND classno = ','2060');					
			SET @exec_sql = var_sql;  
			PREPARE stmt FROM @exec_sql;
			EXECUTE stmt;			
			
			-- 网络散客
			SELECT IFNULL(SUM(rooms_total),0) INTO var_amount FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET' AND code IN ('NET','NET1');
			SET var_sql = CONCAT('UPDATE tmp_herton_jour',' SET ','amount',var_num,' = \'',var_amount,'\' WHERE hotel_group_id = ',arg_hotel_group_id,' AND hotel_id = ',arg_hotel_id,' AND classno = ','2070');					
			SET @exec_sql = var_sql;  
			PREPARE stmt FROM @exec_sql;
			EXECUTE stmt;			
			
			-- 商务会议团
			SELECT IFNULL(SUM(rooms_total),0) INTO var_amount FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET' AND code IN ('MET');
			SET var_sql = CONCAT('UPDATE tmp_herton_jour',' SET ','amount',var_num,' = \'',var_amount,'\' WHERE hotel_group_id = ',arg_hotel_group_id,' AND hotel_id = ',arg_hotel_id,' AND classno = ','2080');					
			SET @exec_sql = var_sql;  
			PREPARE stmt FROM @exec_sql;
			EXECUTE stmt;			
			
			-- 政府会议团
			SELECT IFNULL(SUM(rooms_total),0) INTO var_amount FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET' AND code IN ('GOM');
			SET var_sql = CONCAT('UPDATE tmp_herton_jour',' SET ','amount',var_num,' = \'',var_amount,'\' WHERE hotel_group_id = ',arg_hotel_group_id,' AND hotel_id = ',arg_hotel_id,' AND classno = ','2090');					
			SET @exec_sql = var_sql;  
			PREPARE stmt FROM @exec_sql;
			EXECUTE stmt;			
			
			-- 旅行团
			SELECT IFNULL(SUM(rooms_total),0) INTO var_amount FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET' AND code IN ('T1','T2');
			SET var_sql = CONCAT('UPDATE tmp_herton_jour',' SET ','amount',var_num,' = \'',var_amount,'\' WHERE hotel_group_id = ',arg_hotel_group_id,' AND hotel_id = ',arg_hotel_id,' AND classno = ','2100');					
			SET @exec_sql = var_sql;  
			PREPARE stmt FROM @exec_sql;
			EXECUTE stmt;	
			
			-- 免费房
			SELECT IFNULL(SUM(rooms_total),0) INTO var_amount FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET' AND code IN ('COM','ENT');
			SET var_sql = CONCAT('UPDATE tmp_herton_jour',' SET ','amount',var_num,' = \'',var_amount,'\' WHERE hotel_group_id = ',arg_hotel_group_id,' AND hotel_id = ',arg_hotel_id,' AND classno = ','2110');					
			SET @exec_sql = var_sql;  
			PREPARE stmt FROM @exec_sql;
			EXECUTE stmt;			
			
			-- 自用房
			SELECT IFNULL(SUM(rooms_total),0) INTO var_amount FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET' AND code IN ('HSE');
			SET var_sql = CONCAT('UPDATE tmp_herton_jour',' SET ','amount',var_num,' = \'',var_amount,'\' WHERE hotel_group_id = ',arg_hotel_group_id,' AND hotel_id = ',arg_hotel_id,' AND classno = ','2120');					
			SET @exec_sql = var_sql;  
			PREPARE stmt FROM @exec_sql;
			EXECUTE stmt;

			-- 钟点房
			SELECT IFNULL(SUM(rooms_total),0) INTO var_amount FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET' AND code IN ('HRS');
			SET var_sql = CONCAT('UPDATE tmp_herton_jour',' SET ','amount',var_num,' = \'',var_amount,'\' WHERE hotel_group_id = ',arg_hotel_group_id,' AND hotel_id = ',arg_hotel_id,' AND classno = ','2130');					
			SET @exec_sql = var_sql;  
			PREPARE stmt FROM @exec_sql;
			EXECUTE stmt;			
			
			
			-- 平均房价
			SELECT IFNULL(SUM(rooms_total),0) INTO var_number1 FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET';
			SELECT IFNULL(SUM(rev_rm),0) INTO var_number2 FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET';
			SET var_amount = IF(var_number1=0,0,ROUND(var_number2/var_number1,2));
			SET var_sql = CONCAT('UPDATE tmp_herton_jour',' SET ','amount',var_num,' = \'',var_amount,'\' WHERE hotel_group_id = ',arg_hotel_group_id,' AND hotel_id = ',arg_hotel_id,' AND classno = ','3000');					
			SET @exec_sql = var_sql;  
			PREPARE stmt FROM @exec_sql;
			EXECUTE stmt;			
			
			-- 前台散客
			SELECT IFNULL(SUM(rooms_total),0) INTO var_number1 FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET' AND code IN ('DIS','YJ','TAX','MEM');
			SELECT IFNULL(SUM(rev_rm),0) INTO var_number2 FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET' AND code IN ('DIS','YJ','TAX','MEM');
			SET var_amount = IF(var_number1=0,0,ROUND(var_number2/var_number1,2));
			SET var_sql = CONCAT('UPDATE tmp_herton_jour',' SET ','amount',var_num,' = \'',var_amount,'\' WHERE hotel_group_id = ',arg_hotel_group_id,' AND hotel_id = ',arg_hotel_id,' AND classno = ','3010');					
			SET @exec_sql = var_sql;  
			PREPARE stmt FROM @exec_sql;
			EXECUTE stmt;			
			
			-- 集团网站
			SELECT IFNULL(SUM(rooms_total),0) INTO var_number1 FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET' AND code IN ('WEB','APP');
			SELECT IFNULL(SUM(rev_rm),0) INTO var_number2 FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET' AND code IN ('WEB','APP');
			SET var_amount = IF(var_number1=0,0,ROUND(var_number2/var_number1,2));			
			SET var_sql = CONCAT('UPDATE tmp_herton_jour',' SET ','amount',var_num,' = \'',var_amount,'\' WHERE hotel_group_id = ',arg_hotel_group_id,' AND hotel_id = ',arg_hotel_id,' AND classno = ','3020');					
			SET @exec_sql = var_sql;  
			PREPARE stmt FROM @exec_sql;
			EXECUTE stmt;

			-- 商务协议
			SELECT IFNULL(SUM(rooms_total),0) INTO var_number1 FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET' AND code IN ('COR','WEG');
			SELECT IFNULL(SUM(rev_rm),0) INTO var_number2 FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET' AND code IN ('COR','WEG');			
			SET var_amount = IF(var_number1=0,0,ROUND(var_number2/var_number1,2));
			SET var_sql = CONCAT('UPDATE tmp_herton_jour',' SET ','amount',var_num,' = \'',var_amount,'\' WHERE hotel_group_id = ',arg_hotel_group_id,' AND hotel_id = ',arg_hotel_id,' AND classno = ','3030');					
			SET @exec_sql = var_sql;  
			PREPARE stmt FROM @exec_sql;
			EXECUTE stmt;			
			
			-- 政府散客
			SELECT IFNULL(SUM(rooms_total),0) INTO var_number1 FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET' AND code IN ('GMG');
			SELECT IFNULL(SUM(rev_rm),0) INTO var_number2 FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET' AND code IN ('GMG');			
			SET var_amount = IF(var_number1=0,0,ROUND(var_number2/var_number1,2));
			SET var_sql = CONCAT('UPDATE tmp_herton_jour',' SET ','amount',var_num,' = \'',var_amount,'\' WHERE hotel_group_id = ',arg_hotel_group_id,' AND hotel_id = ',arg_hotel_id,' AND classno = ','3040');					
			SET @exec_sql = var_sql;  
			PREPARE stmt FROM @exec_sql;
			EXECUTE stmt;

			-- 长住客
			SELECT IFNULL(SUM(rooms_total),0) INTO var_number1 FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET' AND code IN ('LON');
			SELECT IFNULL(SUM(rev_rm),0) INTO var_number2 FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET' AND code IN ('LON');			
			SET var_amount = IF(var_number1=0,0,ROUND(var_number2/var_number1,2));
			SET var_sql = CONCAT('UPDATE tmp_herton_jour',' SET ','amount',var_num,' = \'',var_amount,'\' WHERE hotel_group_id = ',arg_hotel_group_id,' AND hotel_id = ',arg_hotel_id,' AND classno = ','3050');					
			SET @exec_sql = var_sql;  
			PREPARE stmt FROM @exec_sql;
			EXECUTE stmt;
			
			-- 旅行社散客
			SELECT IFNULL(SUM(rooms_total),0) INTO var_number1 FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET' AND code IN ('S1','S2');
			SELECT IFNULL(SUM(rev_rm),0) INTO var_number2 FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET' AND code IN ('S1','S2');			
			SET var_amount = IF(var_number1=0,0,ROUND(var_number2/var_number1,2));
			SET var_sql = CONCAT('UPDATE tmp_herton_jour',' SET ','amount',var_num,' = \'',var_amount,'\' WHERE hotel_group_id = ',arg_hotel_group_id,' AND hotel_id = ',arg_hotel_id,' AND classno = ','3060');					
			SET @exec_sql = var_sql;  
			PREPARE stmt FROM @exec_sql;
			EXECUTE stmt;			
			
			-- 网络散客
			SELECT IFNULL(SUM(rooms_total),0) INTO var_number1 FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET' AND code IN ('NET','NET1');
			SELECT IFNULL(SUM(rev_rm),0) INTO var_number2 FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET' AND code IN ('NET','NET1');			
			SET var_amount = IF(var_number1=0,0,ROUND(var_number2/var_number1,2));
			SET var_sql = CONCAT('UPDATE tmp_herton_jour',' SET ','amount',var_num,' = \'',var_amount,'\' WHERE hotel_group_id = ',arg_hotel_group_id,' AND hotel_id = ',arg_hotel_id,' AND classno = ','3070');					
			SET @exec_sql = var_sql;  
			PREPARE stmt FROM @exec_sql;
			EXECUTE stmt;			
			
			-- 商务会议团
			SELECT IFNULL(SUM(rooms_total),0) INTO var_number1 FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET' AND code IN ('MET');
			SELECT IFNULL(SUM(rev_rm),0) INTO var_number2 FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET' AND code IN ('MET');			
			SET var_amount = IF(var_number1=0,0,ROUND(var_number2/var_number1,2));
			SET var_sql = CONCAT('UPDATE tmp_herton_jour',' SET ','amount',var_num,' = \'',var_amount,'\' WHERE hotel_group_id = ',arg_hotel_group_id,' AND hotel_id = ',arg_hotel_id,' AND classno = ','3080');					
			SET @exec_sql = var_sql;  
			PREPARE stmt FROM @exec_sql;
			EXECUTE stmt;			
			
			-- 政府会议团
			SELECT IFNULL(SUM(rooms_total),0) INTO var_number1 FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET' AND code IN ('GOM');
			SELECT IFNULL(SUM(rev_rm),0) INTO var_number2 FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET' AND code IN ('GOM');			
			SET var_amount = IF(var_number1=0,0,ROUND(var_number2/var_number1,2));
			SET var_sql = CONCAT('UPDATE tmp_herton_jour',' SET ','amount',var_num,' = \'',var_amount,'\' WHERE hotel_group_id = ',arg_hotel_group_id,' AND hotel_id = ',arg_hotel_id,' AND classno = ','3090');					
			SET @exec_sql = var_sql;  
			PREPARE stmt FROM @exec_sql;
			EXECUTE stmt;			
			
			-- 旅行团
			SELECT IFNULL(SUM(rooms_total),0) INTO var_number1 FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET' AND code IN ('T1','T2');
			SELECT IFNULL(SUM(rev_rm),0) INTO var_number2 FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET' AND code IN ('T1','T2');			
			SET var_amount = IF(var_number1=0,0,ROUND(var_number2/var_number1,2));
			SET var_sql = CONCAT('UPDATE tmp_herton_jour',' SET ','amount',var_num,' = \'',var_amount,'\' WHERE hotel_group_id = ',arg_hotel_group_id,' AND hotel_id = ',arg_hotel_id,' AND classno = ','3100');					
			SET @exec_sql = var_sql;  
			PREPARE stmt FROM @exec_sql;
			EXECUTE stmt;
						
			-- 免费房
			SELECT IFNULL(SUM(rooms_total),0) INTO var_number1 FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET' AND code IN ('COM','ENT');
			SELECT IFNULL(SUM(rev_rm),0) INTO var_number2 FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET' AND code IN ('COM','ENT');			
			SET var_amount = IF(var_number1=0,0,ROUND(var_number2/var_number1,2));
			SET var_sql = CONCAT('UPDATE tmp_herton_jour',' SET ','amount',var_num,' = \'',var_amount,'\' WHERE hotel_group_id = ',arg_hotel_group_id,' AND hotel_id = ',arg_hotel_id,' AND classno = ','3110');					
			SET @exec_sql = var_sql;  
			PREPARE stmt FROM @exec_sql;
			EXECUTE stmt;			
			
			-- 自用房
			SELECT IFNULL(SUM(rooms_total),0) INTO var_number1 FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET' AND code IN ('HSE');
			SELECT IFNULL(SUM(rev_rm),0) INTO var_number2 FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET' AND code IN ('HSE');			
			SET var_amount = IF(var_number1=0,0,ROUND(var_number2/var_number1,2));
			SET var_sql = CONCAT('UPDATE tmp_herton_jour',' SET ','amount',var_num,' = \'',var_amount,'\' WHERE hotel_group_id = ',arg_hotel_group_id,' AND hotel_id = ',arg_hotel_id,' AND classno = ','3120');					
			SET @exec_sql = var_sql;  
			PREPARE stmt FROM @exec_sql;
			EXECUTE stmt;

			-- 钟点房
			SELECT IFNULL(SUM(rooms_total),0) INTO var_number1 FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET' AND code IN ('HRS');
			SELECT IFNULL(SUM(rev_rm),0) INTO var_number2 FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET' AND code IN ('HRS');
			SET var_amount = IF(var_number1=0,0,ROUND(var_number2/var_number1,2));
			SET var_sql = CONCAT('UPDATE tmp_herton_jour',' SET ','amount',var_num,' = \'',var_amount,'\' WHERE hotel_group_id = ',arg_hotel_group_id,' AND hotel_id = ',arg_hotel_id,' AND classno = ','3130');					
			SET @exec_sql = var_sql;  
			PREPARE stmt FROM @exec_sql;
			EXECUTE stmt;
			
			-- 房费收入
			SELECT IFNULL(SUM(rev_rm),0) INTO var_amount FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET';
			SET var_sql = CONCAT('UPDATE tmp_herton_jour',' SET ','amount',var_num,' = \'',var_amount,'\' WHERE hotel_group_id = ',arg_hotel_group_id,' AND hotel_id = ',arg_hotel_id,' AND classno = ','5000');					
			SET @exec_sql = var_sql;  
			PREPARE stmt FROM @exec_sql;
			EXECUTE stmt;
			-- 前台散客
			SELECT IFNULL(SUM(rev_rm),0) INTO var_amount FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET' AND code IN ('DIS','YJ','TAX','MEM');			
			SET var_sql = CONCAT('UPDATE tmp_herton_jour',' SET ','amount',var_num,' = \'',var_amount,'\' WHERE hotel_group_id = ',arg_hotel_group_id,' AND hotel_id = ',arg_hotel_id,' AND classno = ','5010');					
			SET @exec_sql = var_sql;  
			PREPARE stmt FROM @exec_sql;
			EXECUTE stmt;			
			
			-- 集团网站
			SELECT IFNULL(SUM(rev_rm),0) INTO var_amount FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET' AND code IN ('WEB','APP');						
			SET var_sql = CONCAT('UPDATE tmp_herton_jour',' SET ','amount',var_num,' = \'',var_amount,'\' WHERE hotel_group_id = ',arg_hotel_group_id,' AND hotel_id = ',arg_hotel_id,' AND classno = ','5020');					
			SET @exec_sql = var_sql;  
			PREPARE stmt FROM @exec_sql;
			EXECUTE stmt;

			-- 商务协议
			SELECT IFNULL(SUM(rev_rm),0) INTO var_amount FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET' AND code IN ('COR','WEG');			
			SET var_sql = CONCAT('UPDATE tmp_herton_jour',' SET ','amount',var_num,' = \'',var_amount,'\' WHERE hotel_group_id = ',arg_hotel_group_id,' AND hotel_id = ',arg_hotel_id,' AND classno = ','5030');					
			SET @exec_sql = var_sql;  
			PREPARE stmt FROM @exec_sql;
			EXECUTE stmt;			
			
			-- 政府散客
			SELECT IFNULL(SUM(rev_rm),0) INTO var_amount FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET' AND code IN ('GMG');			
			SET var_sql = CONCAT('UPDATE tmp_herton_jour',' SET ','amount',var_num,' = \'',var_amount,'\' WHERE hotel_group_id = ',arg_hotel_group_id,' AND hotel_id = ',arg_hotel_id,' AND classno = ','5040');					
			SET @exec_sql = var_sql;  
			PREPARE stmt FROM @exec_sql;
			EXECUTE stmt;

			-- 长住客
			SELECT IFNULL(SUM(rev_rm),0) INTO var_amount FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET' AND code IN ('LON');			
			
			SET var_sql = CONCAT('UPDATE tmp_herton_jour',' SET ','amount',var_num,' = \'',var_amount,'\' WHERE hotel_group_id = ',arg_hotel_group_id,' AND hotel_id = ',arg_hotel_id,' AND classno = ','5050');					
			SET @exec_sql = var_sql;  
			PREPARE stmt FROM @exec_sql;
			EXECUTE stmt;
			
			-- 旅行社散客
			SELECT IFNULL(SUM(rev_rm),0) INTO var_amount FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET' AND code IN ('S1','S2');			
			SET var_sql = CONCAT('UPDATE tmp_herton_jour',' SET ','amount',var_num,' = \'',var_amount,'\' WHERE hotel_group_id = ',arg_hotel_group_id,' AND hotel_id = ',arg_hotel_id,' AND classno = ','5060');					
			SET @exec_sql = var_sql;  
			PREPARE stmt FROM @exec_sql;
			EXECUTE stmt;			
			
			-- 网络散客
			SELECT IFNULL(SUM(rev_rm),0) INTO var_amount FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET' AND code IN ('NET','NET1');			
			SET var_sql = CONCAT('UPDATE tmp_herton_jour',' SET ','amount',var_num,' = \'',var_amount,'\' WHERE hotel_group_id = ',arg_hotel_group_id,' AND hotel_id = ',arg_hotel_id,' AND classno = ','5070');					
			SET @exec_sql = var_sql;  
			PREPARE stmt FROM @exec_sql;
			EXECUTE stmt;			
			
			-- 商务会议团
			SELECT IFNULL(SUM(rev_rm),0) INTO var_amount FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET' AND code IN ('MET');			
			SET var_sql = CONCAT('UPDATE tmp_herton_jour',' SET ','amount',var_num,' = \'',var_amount,'\' WHERE hotel_group_id = ',arg_hotel_group_id,' AND hotel_id = ',arg_hotel_id,' AND classno = ','5080');					
			SET @exec_sql = var_sql;  
			PREPARE stmt FROM @exec_sql;
			EXECUTE stmt;			
			
			-- 政府会议团
			SELECT IFNULL(SUM(rev_rm),0) INTO var_amount FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET' AND code IN ('GOM');			
			SET var_sql = CONCAT('UPDATE tmp_herton_jour',' SET ','amount',var_num,' = \'',var_amount,'\' WHERE hotel_group_id = ',arg_hotel_group_id,' AND hotel_id = ',arg_hotel_id,' AND classno = ','5090');					
			SET @exec_sql = var_sql;  
			PREPARE stmt FROM @exec_sql;
			EXECUTE stmt;			
			
			-- 旅行团
			SELECT IFNULL(SUM(rev_rm),0) INTO var_amount FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET' AND code IN ('T1','T2');			
			SET var_sql = CONCAT('UPDATE tmp_herton_jour',' SET ','amount',var_num,' = \'',var_amount,'\' WHERE hotel_group_id = ',arg_hotel_group_id,' AND hotel_id = ',arg_hotel_id,' AND classno = ','5100');					
			SET @exec_sql = var_sql;  
			PREPARE stmt FROM @exec_sql;
			EXECUTE stmt;
						
			-- 免费房
			SELECT IFNULL(SUM(rev_rm),0) INTO var_amount FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET' AND code IN ('COM','ENT');			
			SET var_sql = CONCAT('UPDATE tmp_herton_jour',' SET ','amount',var_num,' = \'',var_amount,'\' WHERE hotel_group_id = ',arg_hotel_group_id,' AND hotel_id = ',arg_hotel_id,' AND classno = ','5110');					
			SET @exec_sql = var_sql;  
			PREPARE stmt FROM @exec_sql;
			EXECUTE stmt;			
			
			-- 自用房
			SELECT IFNULL(SUM(rev_rm),0) INTO var_amount FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET' AND code IN ('HSE');			
			SET var_sql = CONCAT('UPDATE tmp_herton_jour',' SET ','amount',var_num,' = \'',var_amount,'\' WHERE hotel_group_id = ',arg_hotel_group_id,' AND hotel_id = ',arg_hotel_id,' AND classno = ','5120');					
			SET @exec_sql = var_sql;  
			PREPARE stmt FROM @exec_sql;
			EXECUTE stmt;

			-- 钟点房
			SELECT IFNULL(SUM(rev_rm),0) INTO var_amount FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bizdate AND code_type='MARKET' AND code IN ('HRS');			
			SET var_sql = CONCAT('UPDATE tmp_herton_jour',' SET ','amount',var_num,' = \'',var_amount,'\' WHERE hotel_group_id = ',arg_hotel_group_id,' AND hotel_id = ',arg_hotel_id,' AND classno = ','5130');					
			SET @exec_sql = var_sql;  
			PREPARE stmt FROM @exec_sql;
			EXECUTE stmt;			
	
			SET var_num = var_num + 1;
			SET var_bizdate = ADDDATE(var_bizdate,1);
			
		END ;
	END WHILE ;	
	
	UPDATE tmp_herton_jour SET amount99 = '合计' WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND classno IN ('1000','0100');
	UPDATE tmp_herton_jour SET amount99 = amount1 + amount2 + amount3 + amount4 + amount5 + amount6 + amount7 + amount8 + amount9 + amount10
		 + amount11 + amount12 + amount13 + amount14 + amount15 + amount16 + amount17 + amount18 + amount19 + amount20
		 + amount21 + amount22 + amount23 + amount24 + amount25 + amount26 + amount27 + amount28 + amount29 + amount30 + amount31
		 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND classno NOT IN ('1000','1040','1050','0100') AND classno NOT LIKE '3%';
	
	SELECT amount99 INTO var_number1 FROM tmp_herton_jour WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND classno = '1020';
	SELECT amount99 INTO var_number2 FROM tmp_herton_jour WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND classno = '1010';
	UPDATE tmp_herton_jour SET amount99 = IF(var_number1=0,0,ROUND(var_number2*100/var_number1,2)) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND classno = '1040';
	
	SELECT amount99 INTO var_number1 FROM tmp_herton_jour WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND classno = '1020';
	SELECT amount99 INTO var_number2 FROM tmp_herton_jour WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND classno = '5000';
	UPDATE tmp_herton_jour SET amount99 = IF(var_number1=0,0,ROUND(var_number2/var_number1,2)) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND classno IN ('1050','3000');
	
	SET var_num = 10;
	WHILE var_num <= 130 DO
		BEGIN	
			IF var_num < 100 THEN
				SELECT amount99 INTO var_number1 FROM tmp_herton_jour WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND classno =  CONCAT('20',var_num);
				SELECT amount99 INTO var_number2 FROM tmp_herton_jour WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND classno =  CONCAT('50',var_num);
				UPDATE tmp_herton_jour SET amount99 = IF(var_number1=0,0,ROUND(var_number2/var_number1,2)) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND classno = CONCAT('30',var_num);
			ELSE
				SELECT amount99 INTO var_number1 FROM tmp_herton_jour WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND classno =  CONCAT('2',var_num);
				SELECT amount99 INTO var_number2 FROM tmp_herton_jour WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND classno =  CONCAT('5',var_num);
				UPDATE tmp_herton_jour SET amount99 = IF(var_number1=0,0,ROUND(var_number2/var_number1,2)) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND classno = CONCAT('3',var_num);				
			END IF;
	
			SET var_num = var_num + 10;
		END ;
	END WHILE ;	
	
	SELECT descript,amount1,amount2,amount3,amount4,amount5,amount6,amount7,amount8,amount9,amount10,
		amount11,amount12,amount13,amount14,amount15,amount16,amount17,amount18,amount19,amount20,
		amount21,amount22,amount23,amount24,amount25,amount26,amount27,amount28,amount29,amount30,amount31,amount99
	FROM tmp_herton_jour WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND classno NOT LIKE '5%' ORDER BY classno;

	DROP TEMPORARY TABLE IF EXISTS tmp_herton_jour;
	
END$$

DELIMITER ;