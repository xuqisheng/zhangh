DELIMITER $$

USE `portal`$$

DROP PROCEDURE IF EXISTS `up_ihotel_forecast_index_detail`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_forecast_index_detail`(
	IN arg_hotel_group_id	BIGINT(16),
	IN arg_hotel_id		BIGINT(16),
	IN arg_biz_date		DATETIME,
	IN arg_types		VARCHAR(255),
	IN arg_index		VARCHAR(50),
	OUT arg_result		DECIMAL(12,2)	
)
    SQL SECURITY INVOKER
label_0:
BEGIN
	-- CALL up_ihotel_forecast_index_detail(arg_hotel_group_id,arg_hotel_id,'2013-08-10','','Total Rooms',var_result);
	DECLARE done_cursor INT DEFAULT 0 ;
	DECLARE var_bdate	DATETIME ;	
	DECLARE var_result1	DECIMAL(12,2);
	DECLARE var_result2	DECIMAL(12,2);
	DECLARE var_result3	DECIMAL(12,2);
	DECLARE var_result4	DECIMAL(12,2);
	DECLARE var_rmtype	VARCHAR(200);
	DECLARE var_rmno	VARCHAR(10);
	DECLARE var_rmsonnum INT;
	
	DECLARE c_ooo CURSOR FOR SELECT rmno FROM room_sta_chg WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND chg_type='OOO' AND bill_sta ='I' AND arg_biz_date >= date_begin AND arg_biz_date < date_end ORDER BY rmno;
	DECLARE c_os CURSOR FOR SELECT rmno FROM room_sta_chg WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND chg_type='OS' AND bill_sta ='I' AND arg_biz_date >= date_begin AND arg_biz_date < date_end ORDER BY rmno;
	DECLARE c_tmp CURSOR FOR SELECT rmno FROM room_sta_chg WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND chg_type='TMP' AND bill_sta ='I' AND DATE(date_begin)=arg_biz_date ORDER BY rmno;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done_cursor = 1;
	
	SELECT biz_date1 INTO var_bdate FROM audit_flag WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;
	SET arg_result = 0,var_result1 =0,var_result2=0,var_result3=0,var_result4=0;
	SET max_sp_recursion_depth=5;
	-- 拼字符串
	IF arg_types='%' THEN
		BEGIN
			SET arg_types='#';
			SELECT IFNULL(MIN(CODE),'') INTO var_rmtype FROM room_type WHERE CODE>'' AND hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;
			WHILE var_rmtype <> '' DO
				BEGIN
					SET arg_types = CONCAT(arg_types,SUBSTRING(var_rmtype, 1, 3),'#');
					SELECT IFNULL(MIN(CODE),'') INTO var_rmtype FROM room_type WHERE CODE>var_rmtype AND hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;
				END;
			END WHILE;
		END;
	ELSEIF CHAR_LENGTH(arg_types)<=3 THEN
		SET arg_types=CONCAT('#',SUBSTRING(CONCAT(arg_types,'   '),1,3),'#');
	END IF;	
	
	IF arg_index = 'Total Rooms' THEN -- 总房数
			SELECT COUNT(1) INTO arg_result FROM room_no WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;
	
	ELSEIF arg_index = 'Out of Order' THEN	-- 维修房
		BEGIN
			OPEN c_ooo;
			FETCH c_ooo INTO var_rmno;
			WHILE done_cursor = 0 DO
				BEGIN
					IF EXISTS (SELECT 1 FROM room_villa_show WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND rmno=var_rmno GROUP BY rmno) THEN
						BEGIN
						SELECT rmson_num INTO var_rmsonnum FROM room_villa_show WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND rmno=var_rmno GROUP BY rmno;
						SET arg_result = arg_result + var_rmsonnum;
						END;
					ELSE
						SET arg_result = arg_result + 1;
					END IF;
				
				SET done_cursor = 0;
				FETCH c_ooo INTO var_rmno;
				END;
			END WHILE;
			CLOSE c_ooo;	
		END;
		
	ELSEIF arg_index = 'Out of Service' THEN	-- 锁定房
		BEGIN
			OPEN c_os;
			FETCH c_os INTO var_rmno;
			WHILE done_cursor = 0 DO
				BEGIN
					IF EXISTS (SELECT 1 FROM room_villa_show WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND rmno=var_rmno GROUP BY rmno) THEN
						BEGIN
						SELECT rmson_num INTO var_rmsonnum FROM room_villa_show WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND rmno=var_rmno GROUP BY rmno;
						SET arg_result = arg_result + var_rmsonnum;
						END;
					ELSE
						SET arg_result = arg_result + 1;
					END IF;
				
				SET done_cursor = 0;
				FETCH c_os INTO var_rmno;
				END;
			END WHILE;
			CLOSE c_os;		
		END;
		
	ELSEIF arg_index = 'Out of TMP' THEN	-- 临时态
		BEGIN
			OPEN c_tmp;
			FETCH c_tmp INTO var_rmno;
			WHILE done_cursor = 0 DO
				BEGIN
					IF EXISTS (SELECT 1 FROM room_villa_show WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND rmno=var_rmno GROUP BY rmno) THEN
						BEGIN
						SELECT rmson_num INTO var_rmsonnum FROM room_villa_show WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND rmno=var_rmno GROUP BY rmno;
						SET arg_result = arg_result + var_rmsonnum;
						END;
					ELSE
						SET arg_result = arg_result + 1;
					END IF;
				
				SET done_cursor = 0;
				FETCH c_tmp INTO var_rmno;
				END;
			END WHILE;
			CLOSE c_tmp;		
		END;		
		
	ELSEIF arg_index = 'Room to Rent' THEN	-- 可卖房
		BEGIN
			CALL up_ihotel_forecast_index_detail(arg_hotel_group_id,arg_hotel_id,arg_biz_date,arg_types,'Total Rooms',var_result1);
			CALL up_ihotel_forecast_index_detail(arg_hotel_group_id,arg_hotel_id,arg_biz_date,arg_types,'Out of Order',var_result2);
			CALL up_ihotel_forecast_index_detail(arg_hotel_group_id,arg_hotel_id,arg_biz_date,arg_types,'Out of Service',var_result3);			
			SELECT SUM(sure_book_num+unsure_book_num) INTO var_result4 FROM rsv_rmtype_total WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND occ_date=arg_biz_date;						
			SET arg_result = var_result1 - var_result2 - var_result3 - var_result4;
		END;
		
	ELSEIF arg_index = 'Clean Room' THEN -- 干净房 | 在住
		SELECT IFNULL(SUM(value1),0) INTO arg_result FROM room_status WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND rsv_index = 'Clean Room' AND biz_date = arg_biz_date AND INSTR(arg_types,rmtype)>0;
	ELSEIF arg_index = 'Clean Room' THEN -- 干净房 | 空闲
		SELECT IFNULL(SUM(value2),0) INTO arg_result FROM room_status WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND rsv_index = 'Clean Room' AND biz_date = arg_biz_date AND INSTR(arg_types,rmtype)>0;
		
	ELSEIF arg_index = 'Dirty Room' THEN -- 脏房 | 在住
		SELECT IFNULL(SUM(value1),0) INTO arg_result FROM room_status WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND rsv_index = 'Dirty Room' AND biz_date = arg_biz_date AND INSTR(arg_types,rmtype)>0;
	ELSEIF arg_index = 'Dirty Room' THEN -- 脏房 | 空闲
		SELECT IFNULL(SUM(value1),0) INTO arg_result FROM room_status WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND rsv_index = 'Dirty Room' AND biz_date = arg_biz_date AND INSTR(arg_types,rmtype)>0;	
		
	ELSEIF arg_index = 'COM' THEN -- 免费房
		SELECT IFNULL(SUM(b.rmnum),0) INTO arg_result FROM master_base a,rsv_src b LEFT JOIN code_base c ON b.hotel_group_id=c.hotel_group_id AND b.hotel_id=c.hotel_id AND b.market=c.code AND c.parent_code='market_code' WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id 
			AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.id=b.accnt AND c.flag='COM' AND b.occ_flag IN ('RF','RG','MF') AND arg_biz_date >= b.arr_date AND arg_biz_date <= b.dep_date;
	ELSEIF arg_index = 'HSE' THEN -- 自用房
		SELECT IFNULL(SUM(b.rmnum),0) INTO arg_result FROM master_base a,rsv_src b LEFT JOIN code_base c ON b.hotel_group_id=c.hotel_group_id AND b.hotel_id=c.hotel_id AND b.market=c.code AND c.parent_code='market_code' WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id 
			AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.id=b.accnt AND c.flag='HSE' AND b.occ_flag IN ('RF','RG','MF') AND arg_biz_date >= b.arr_date AND arg_biz_date <= b.dep_date;	
	ELSEIF arg_index = 'LON' THEN -- 长包房
		SELECT IFNULL(SUM(b.rmnum),0) INTO arg_result FROM master_base a,rsv_src b LEFT JOIN code_base c ON b.hotel_group_id=c.hotel_group_id AND b.hotel_id=c.hotel_id AND b.market=c.code AND c.parent_code='market_code' WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id 
			AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.id=b.accnt AND c.flag='LON' AND b.occ_flag IN ('RF','RG','MF') AND arg_biz_date >= b.arr_date AND arg_biz_date <= b.dep_date;
	/*
	ELSEIF arg_index = 'Occupied In Sta' THEN  -- 本日房数
		BEGIN
			SELECT COUNT(DISTINCT a.master_id,a.rmno) INTO var_result1 FROM master_base a WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id 
				AND a.id<>a.rsv_id AND a.sta='I' AND a.rsv_class IN ('F','D') AND DATE(a.arr) <= arg_biz_date AND DATE(a.dep) > arg_biz_date AND INSTR(arg_types,a.rmtype) > 0;			
			SELECT COUNT(DISTINCT a.master_id,a.rmno) INTO var_result2 FROM master_base a WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id 
				AND a.id<>a.rsv_id AND a.sta='R' AND a.rsv_class='F' AND DATE(a.arr) <= arg_biz_date AND DATE(a.dep) > arg_biz_date AND INSTR(arg_types,a.rmtype) > 0;
			SELECT IFNULL(SUM(b.rmnum),0) INTO var_result3 FROM master_base a,rsv_src b WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id 
				AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.id=b.accnt AND b.occ_flag IN ('RF','RG') AND a.rsv_class IN ('F','G') AND a.sta IN ('R','I')
				AND a.id=a.rsv_id AND  b.arr_date <= arg_biz_date AND b.dep_date > arg_biz_date AND INSTR(arg_types,a.rmtype) > 0;
			
			SET arg_result = var_result1 + var_result2 + var_result3;
		END;	
	*/
		
	ELSEIF arg_index = 'Occupied In Sta' THEN  -- 当前在住 | 房数
		BEGIN
			IF arg_biz_date = var_bdate THEN
				SELECT COUNT(DISTINCT a.master_id,a.rmno) INTO var_result1 FROM master_base a WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.id<>a.rsv_id AND a.sta='I' AND a.rsv_class IN ('F','D') AND DATE(a.arr) <= arg_biz_date AND DATE(a.dep) >= arg_biz_date AND INSTR(arg_types,a.rmtype) > 0;
			ELSE
				SELECT COUNT(DISTINCT a.master_id,a.rmno) INTO var_result1 FROM master_base a WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.id<>a.rsv_id AND a.sta='R' AND a.rsv_class = 'F' AND DATE(a.arr) < arg_biz_date AND DATE(a.dep) >= arg_biz_date AND INSTR(arg_types,a.rmtype) > 0;			
								
				SELECT IFNULL(SUM(b.rmnum),0) INTO var_result2 FROM master_base a,rsv_src b WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.id=b.accnt AND b.occ_flag IN ('RF','RG') AND a.rsv_class IN ('F','G') AND a.id=a.rsv_id AND  b.arr_date < arg_biz_date AND b.dep_date >= arg_biz_date AND INSTR(arg_types,a.rmtype) > 0;
			END IF;	
			
			SET arg_result = var_result1 + var_result2;
		END;
		
	ELSEIF arg_index = 'Occupied In Sta People' THEN  -- 当前在住 | 人数
		BEGIN
			IF arg_biz_date = var_bdate THEN
				SELECT IFNULL(SUM(a.adult+a.children),0) INTO var_result1 FROM master_base a WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.id<>a.rsv_id AND a.sta='I' AND a.rsv_class IN ('F','D') AND DATE(a.arr) <= arg_biz_date AND DATE(a.dep) >= arg_biz_date AND INSTR(arg_types,a.rmtype) > 0;
			ELSE
				SELECT IFNULL(SUM(a.adult+a.children),0) INTO var_result1 FROM master_base a WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.id<>a.rsv_id AND a.sta='R' AND a.rsv_class = 'F' AND DATE(a.arr) < arg_biz_date AND DATE(a.dep) >= arg_biz_date AND INSTR(arg_types,a.rmtype) > 0;			
								
				SELECT IFNULL(SUM((b.adult+b.children) * b.rmnum),0) INTO var_result2 FROM master_base a,rsv_src b WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.id=b.accnt AND b.occ_flag IN ('RF','RG') AND a.rsv_class IN ('F','G') AND a.id=a.rsv_id AND  b.arr_date < arg_biz_date AND b.dep_date >= arg_biz_date AND INSTR(arg_types,a.rmtype) > 0;
			END IF;	
			
			SET arg_result = var_result1 + var_result2;
		END;		
		
	ELSEIF 	arg_index = 'Actual Arrival Rooms' THEN -- 实际到达 | 房数
		SELECT COUNT(DISTINCT a.master_id,a.rmno) INTO arg_result FROM master_base a WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.id<>a.rsv_id AND a.rsv_class = 'F' AND a.is_walkin = 'F' AND a.rsv_id > 0 AND a.sta IN ('I','O','S') AND DATE(a.arr) = arg_biz_date;								

	ELSEIF 	arg_index = 'Actual Arrival People' THEN -- 实际到达 | 人数
		SELECT COUNT(1) INTO arg_result FROM master_base a WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.id<>a.rsv_id AND a.rsv_class = 'F' AND a.is_walkin = 'F' AND a.rsv_id > 0 AND a.sta IN ('I','O','S') AND DATE(a.arr) = arg_biz_date;								
		
	ELSEIF 	arg_index = 'Expected Arrival Rooms' THEN -- 预计到达 | 房数
		BEGIN
			SELECT IFNULL(SUM(rmNum),0) INTO arg_result FROM 
			(SELECT SUM(b.rmnum) AS rmNum,SUM(b.rmnum) AS rmSonNum, SUM((b.adult + a.children)*b.rmnum) AS adult FROM master_base a,rsv_src b WHERE a.id = b.accnt AND a.rsv_class <> 'H' AND a.id = a.rsv_id AND a.sta IN ('R','I') AND b.occ_flag IN ('RF','RG') AND b.arr_date = arg_biz_date AND b.rmnum > 0 AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id               
			UNION ALL                             
			SELECT COUNT(DISTINCT a.master_id,a.rmno) AS rmNum,COUNT(DISTINCT a.master_id,a.rmno,a.rmno_son) AS rmSonNum,SUM(a.adult + a.children) AS adult FROM master_base a WHERE a.rsv_class = 'F' AND a.id <> a.rsv_id AND a.sta = 'R' AND DATE(a.arr) = arg_biz_date  AND a.hotel_group_id = arg_hotel_group_id  AND a.hotel_id = arg_hotel_id               
			) AS temp;
		END;

	ELSEIF 	arg_index = 'Expected Arrival People' THEN -- 预计到达 | 人数
		BEGIN
			SELECT IFNULL(SUM(adult),0) INTO arg_result FROM 
			(SELECT SUM(b.rmnum) AS rmNum,SUM(b.rmnum) AS rmSonNum, SUM((b.adult + a.children)*b.rmnum) AS adult FROM master_base a,rsv_src b WHERE a.id = b.accnt AND a.rsv_class <> 'H' AND a.id = a.rsv_id AND a.sta IN ('R','I') AND b.occ_flag IN ('RF','RG') AND b.arr_date = arg_biz_date AND b.rmnum > 0 AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id               
			UNION ALL                             
			SELECT COUNT(DISTINCT a.master_id,a.rmno) AS rmNum,COUNT(DISTINCT a.master_id,a.rmno,a.rmno_son) AS rmSonNum,SUM(a.adult + a.children) AS adult FROM master_base a WHERE a.rsv_class = 'F' AND a.id <> a.rsv_id AND a.sta = 'R' AND DATE(a.arr) = arg_biz_date  AND a.hotel_group_id = arg_hotel_group_id  AND a.hotel_id = arg_hotel_id               
			) AS temp;
		END;

	ELSEIF arg_index = 'Day Reservation Rooms' THEN -- 当天预订 | 房数
		BEGIN
			SELECT IFNULL(SUM(rmNum),0) AS rmNum INTO arg_result FROM 
			(SELECT SUM(b.rmnum) AS rmNum,SUM(b.rmnum) AS rmSonNum,SUM((b.adult + a.children)*b.rmnum) AS adult FROM master_base a,rsv_src b WHERE a.id = b.accnt AND a.rsv_class <> 'H' AND a.id = a.rsv_id AND b.occ_flag IN ('RF','RG') AND DATE(b.create_datetime) = arg_biz_date AND b.arr_date = arg_biz_date AND b.rmnum > 0 AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id                
			UNION ALL                             
			SELECT COUNT(DISTINCT a.master_id,a.rmno) AS rmNum,COUNT(DISTINCT a.master_id,a.rmno,a.rmno_son) AS rmSonNum,SUM(a.adult + a.children) AS adult FROM master_base a,rsv_src b,master_stalog c WHERE a.rsv_class = 'F' AND a.id <> a.rsv_id AND a.sta IN ('R','I','S','O') AND b.occ_flag = 'MF' AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.accnt = a.id AND b.arr_date = arg_biz_date AND a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND c.id = a.id AND DATE(c.rsv_datetime) = arg_biz_date AND c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = arg_hotel_id 
			) AS temp;		
		END;

	ELSEIF arg_index = 'Day Reservation People' THEN -- 当天预订 | 人数
		BEGIN
			SELECT IFNULL(SUM(adult),0) INTO arg_result FROM 
			(SELECT SUM(b.rmnum) AS rmNum,SUM(b.rmnum) AS rmSonNum,SUM((b.adult + a.children)*b.rmnum) AS adult FROM master_base a,rsv_src b WHERE a.id = b.accnt AND a.rsv_class <> 'H' AND a.id = a.rsv_id AND b.occ_flag IN ('RF','RG') AND DATE(b.create_datetime) = arg_biz_date AND b.arr_date = arg_biz_date AND b.rmnum > 0 AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id                
			UNION ALL                             
			SELECT COUNT(DISTINCT a.master_id,a.rmno) AS rmNum,COUNT(DISTINCT a.master_id,a.rmno,a.rmno_son) AS rmSonNum,SUM(a.adult + a.children) AS adult FROM master_base a,rsv_src b,master_stalog c WHERE a.rsv_class = 'F' AND a.id <> a.rsv_id AND a.sta IN ('R','I','S','O') AND b.occ_flag = 'MF' AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.accnt = a.id AND b.arr_date = arg_biz_date AND a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND c.id = a.id AND DATE(c.rsv_datetime) = arg_biz_date  AND c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = arg_hotel_id 
			) AS temp;
		END;
	ELSEIF arg_index = 'Walk-Ins' THEN -- 当前 Walk-Ins | 房数
		BEGIN	
			IF arg_biz_date = var_bdate THEN
				SELECT COUNT(DISTINCT a.master_id,a.rmno) arg_result FROM master_base a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.id <> a.rsv_id AND a.rsv_class = 'F' AND a.is_walkin = 'T' AND a.sta IN ('I','S','O') AND NOT EXISTS (SELECT m.id FROM master_base_till m WHERE m.hotel_group_id = arg_hotel_group_id  AND m.hotel_id = arg_hotel_id AND m.id = a.id AND m.rsv_class = 'F' AND m.id <> m.rsv_id);
			ELSE
				SET arg_result = 0;
			END IF;
		END;
	ELSEIF arg_index = 'Walk-Ins Persons' THEN -- 当前 Walk-Ins | 人数
		BEGIN	
			IF arg_biz_date = var_bdate THEN
				SELECT IFNULL(SUM(a.adult+a.children),0) arg_result FROM master_base a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.id <> a.rsv_id AND a.rsv_class = 'F' AND a.is_walkin = 'T' AND a.sta IN ('I','S','O') AND NOT EXISTS (SELECT m.id FROM master_base_till m WHERE m.hotel_group_id = arg_hotel_group_id  AND m.hotel_id = arg_hotel_id AND m.id = a.id AND m.rsv_class = 'F' AND m.id <> m.rsv_id);
			ELSE
				SET arg_result = 0;
			END IF;
		END;	
		
	ELSEIF arg_index = 'Actual Dep Rooms' THEN -- 实际离店 | 房数
		BEGIN	
			IF arg_biz_date = var_bdate THEN
				SELECT COUNT(DISTINCT master_id,rmno) INTO arg_result FROM 
				(SELECT a.master_id,a.rmno, a.rmno_son,a.adult, a.children FROM master_base a,master_base_till t WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.id <> a.rsv_id  AND a.rsv_class IN ('F','D')  AND a.sta IN ('O','S') AND a.id = t.id AND t.sta IN ('R','I') AND t.rsv_class IN ('F','D') AND t.hotel_group_id = arg_hotel_group_id AND t.hotel_id = arg_hotel_id AND t.id <> t.rsv_id	
				UNION ALL SELECT a.master_id,a.rmno, a.rmno_son,a.adult, a.children FROM master_base a  WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.id <> a.rsv_id  AND a.rsv_class IN ('F','D') AND a.sta IN ('O','S') AND NOT EXISTS (SELECT 1 FROM master_base_till t WHERE t.hotel_group_id = arg_hotel_group_id AND t.hotel_id = arg_hotel_id AND t.id <> t.rsv_id AND t.id = a.id AND t.rsv_class IN ('F','D' ) ) 
				 ) temp; 
			ELSE
				SET arg_result = 0;
			END IF;
		END;

	ELSEIF arg_index = 'Actual Dep People' THEN -- 实际离店 | 人数
		BEGIN	
			IF arg_biz_date = var_bdate THEN
				SELECT IFNULL(SUM(adult+children),0) INTO arg_result FROM 
				(SELECT a.master_id,a.rmno, a.rmno_son,a.adult, a.children FROM master_base a,master_base_till t WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.id <> a.rsv_id  AND a.rsv_class IN ('F','D')  AND a.sta IN ('O','S') AND a.id = t.id AND t.sta IN ('R','I') AND t.rsv_class IN ('F','D') AND t.hotel_group_id = arg_hotel_group_id AND t.hotel_id = arg_hotel_id AND t.id <> t.rsv_id	
				UNION ALL SELECT a.master_id,a.rmno, a.rmno_son,a.adult, a.children FROM master_base a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.id <> a.rsv_id  AND a.rsv_class IN ('F','D') AND a.sta IN ('O','S') AND NOT EXISTS (SELECT 1 FROM master_base_till t WHERE t.hotel_group_id = arg_hotel_group_id AND t.hotel_id = arg_hotel_id AND t.id <> t.rsv_id AND t.id = a.id AND t.rsv_class IN ('F','D' ) ) 
				 ) temp; 
			ELSE
				SET arg_result = 0;
			END IF;
		END;		
		
	ELSEIF arg_index = 'Expected Dep Rooms' THEN -- 预计离店 | 房数
		SELECT IFNULL(SUM(rmNum),0) INTO arg_result FROM 
		(
		SELECT COUNT(DISTINCT a.master_id,a.rmno) rmNum,COUNT(DISTINCT a.master_id,a.rmno,a.rmno_son) rmSonNum,SUM(a.adult+a.children) AS adult FROM master_base a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.id <> a.rsv_id AND a.sta IN ('I','R') AND (a.rsv_class = 'F' OR a.rsv_class = 'D') AND DATE(a.dep) = arg_biz_date 	   
		UNION ALL
		SELECT IFNULL(SUM(b.rmnum),0) rmNum,0 as rmSonNum,SUM((b.adult + a.children) * b.rmnum) as adult FROM master_base a,rsv_src b WHERE a.id = b.accnt AND a.rsv_class <> 'H' AND a.id = a.rsv_id AND a.sta IN ('R','I')  AND b.occ_flag IN ('RF','RG') AND b.dep_date = arg_biz_date AND b.rmnum > 0 AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id )              
		) AS temp; 			
	ELSEIF arg_index = 'Expected Dep People' THEN -- 预计离店 | 人数
		SELECT IFNULL(SUM(adult),0) INTO arg_result FROM 
		(
		SELECT COUNT(DISTINCT a.master_id,a.rmno) rmNum,COUNT(DISTINCT a.master_id,a.rmno,a.rmno_son) rmSonNum,SUM(a.adult+a.children) AS adult FROM master_base a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.id <> a.rsv_id AND a.sta IN ('I','R') AND (a.rsv_class = 'F' OR a.rsv_class = 'D') AND DATE(a.dep) = arg_biz_date 	   
		UNION ALL
		SELECT IFNULL(SUM(b.rmnum),0) rmNum,0 as rmSonNum,SUM((b.adult + a.children) * b.rmnum) as adult FROM master_base a,rsv_src b WHERE a.id = b.accnt AND a.rsv_class <> 'H' AND a.id = a.rsv_id AND a.sta IN ('R','I')  AND b.occ_flag IN ('RF','RG') AND b.dep_date = arg_biz_date AND b.rmnum > 0 AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id )              
		) AS temp;		

	ELSEIF arg_index = 'Extended Stay Rooms' THEN -- 延住 | 房数
		SELECT COUNT(DISTINCT a.master_id,a.rmno) INTO arg_result FROM master_base a,master_base_till m WHERE a.id = m.id AND a.id <> a.rsv_id AND a.rsv_class = 'F' AND a.sta = 'I' AND m.hotel_group_id = arg_hotel_group_id AND m.hotel_id = arg_hotel_id  AND a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND m.dep >= arg_biz_date AND m.dep < arg_biz_date AND a.dep >= arg_biz_date;				END;
	ELSEIF arg_index = 'Extended Stay People' THEN -- 延住 | 人数
		SELECT IFNULL(SUM(a.adult),0) INTO arg_result FROM master_base a,master_base_till m WHERE a.id = m.id AND a.id <> a.rsv_id AND a.rsv_class = 'F' AND a.sta = 'I' AND m.hotel_group_id = arg_hotel_group_id AND m.hotel_id = arg_hotel_id  AND a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND m.dep >= arg_biz_date AND m.dep < arg_biz_date AND a.dep >= arg_biz_date;
		
	ELSEIF arg_index = 'Early Dep Rooms' THEN -- 提前离店 | 房数
		SELECT COUNT(DISTINCT a.master_id,a.rmno) INTO arg_result FROM master_base a,master_base_till t WHERE a.id = t.id AND a.id <> a.rsv_id AND a.rsv_class IN ('F','D') AND a.sta IN ('O','S') AND t.hotel_group_id = arg_hotel_group_id AND t.hotel_id = arg_hotel_id  AND a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND t.id <> t.rsv_id AND t.rsv_class IN ('F','D') AND t.sta = 'I' AND DATE(t.dep) >= arg_biz_date;		
	ELSEIF arg_index = 'Early Dep People' THEN -- 提前离店 | 人数
		SELECT IFNULL(SUM(a.adult+a.children),0) INTO arg_result FROM master_base a,master_base_till t WHERE a.id = t.id AND a.id <> a.rsv_id AND a.rsv_class IN ('F','D') AND a.sta IN ('O','S') AND t.hotel_group_id = arg_hotel_group_id AND t.hotel_id = arg_hotel_id  AND a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND t.id <> t.rsv_id AND t.rsv_class IN ('F','D') AND t.sta = 'I' AND DATE(t.dep) >= arg_biz_date;

	ELSEIF arg_index = 'DayRent Rooms' THEN -- 日租房 | 房数
		SELECT COUNT(DISTINCT a.master_id,a.rmno) INTO arg_result FROM master_base a WHERE a.id <> a.rsv_id AND (a.rsv_class = 'D' OR (a.rsv_class = 'F' AND DATE(a.arr) = DATE(a.dep))) AND a.sta IN ('R','I') AND a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id  AND DATE(a.arr)>= arg_biz_date;		
	ELSEIF arg_index = 'DayRent People' THEN -- 日租房 | 人数
		SELECT IFNULL(SUM(a.adult+a.children),0) INTO arg_result FROM master_base a WHERE a.id <> a.rsv_id AND (a.rsv_class = 'D' OR (a.rsv_class = 'F' AND DATE(a.arr) = DATE(a.dep))) AND a.sta IN ('R','I') AND a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id  AND DATE(a.arr)>= arg_biz_date;
		
	ELSEIF arg_index = 'Actual Rooms' THEN	-- 本日预测 - 本夜占用 | 房数
		SELECT SUM(sure_book_num+unsure_book_num) INTO arg_result FROM rsv_rmtype_total WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND occ_date=arg_biz_date;									
		
	ELSEIF arg_index = 'Actual People' THEN	-- 本日预测 - 本夜占用 | 人数
		SELECT IFNULL(sum(m.adult+m.children),0) INTO arg_result FROM 
		(SELECT r.id,r.adult,r.children FROM rsv_src r,master_base b WHERE r.accnt=b.id AND b.id <> b.rsv_id AND b.rsv_class = 'F' AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND ( r.arr_date<= arg_biz_date AND r.dep_date> arg_biz_date) AND r.hotel_group_id = arg_hotel_id AND r.hotel_id = arg_hotel_id GROUP BY r.id 
		UNION ALL 
		SELECT r.id,r.adult*r.rmnum,r.children*r.rmnum FROM rsv_src r,master_base d WHERE r.accnt = d.id AND d.rsv_class IN ('F','G') AND d.id = d.rsv_id AND d.hotel_group_id = arg_hotel_group_id AND d.hotel_id = arg_hotel_id AND ( r.arr_date<= arg_biz_date  AND r.dep_date> arg_biz_date ) AND r.occ_flag IN ('RF','RG') AND r.hotel_group_id = arg_hotel_group_id AND r.hotel_id = arg_hotel_id GROUP BY r.id) m;		  			
	
	ELSEIF arg_index = 'Occupied Tonight FIT' THEN -- 本日预测 - 散客
		BEGIN	
			SELECT COUNT(DISTINCT a.rmno,a.master_id) INTO var_result1 FROM rsv_src a,master_base b WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.occ_flag = 'MF' AND a.accnt = b.id AND b.rsv_class = 'F' AND b.rsv_id <> b.id AND b.grp_accnt = 0 AND b.sta IN ('R','I') AND a.arr_date <= arg_biz_date AND a.dep_date > arg_biz_date;
			SELECT IFNULL(SUM(a.rmnum),0) INTO var_result2 FROM rsv_src a, master_base b WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.accnt = b.id AND b.rsv_class <> 'H' AND b.id = b.rsv_id AND a.arr_date <= arg_biz_date AND a.dep_date > arg_biz_date AND a.occ_flag = 'RF' AND b.rsv_class='F';
			SET arg_result = var_result1 + var_result2;
		END;

	ELSEIF arg_index = 'Occupied Tonight GRP' THEN -- 本日预测 - 团队
		BEGIN
			SELECT COUNT(DISTINCT a.rmno,a.master_id) INTO var_result1 FROM rsv_src a,master_base b WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.occ_flag = 'MF' AND a.accnt = b.id AND b.rsv_class = 'F' AND b.rsv_id <> b.id AND b.grp_accnt > 0 AND b.sta IN ('R','I') AND a.arr_date <= arg_biz_date AND a.dep_date > arg_biz_date AND INSTR(arg_types,a.rmtype) > 0;
			SELECT IFNULL(SUM(a.rmnum),0) INTO var_result2 FROM rsv_src a, master_base b WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.accnt = b.id AND b.rsv_class <> 'H' AND b.id = b.rsv_id AND a.arr_date <= arg_biz_date AND a.dep_date > arg_biz_date AND a.occ_flag = 'RG' AND b.rsv_class='G' AND INSTR(arg_types,a.rmtype) > 0;
			
			SET arg_result = var_result1 + var_result2;
		END;	
	
	ELSEIF arg_index = 'Room Revenue' THEN -- 预计客房收入
		SELECT SUM(rate) INTO arg_result FROM
		(SELECT	IFNULL(SUM(IFNULL(b.real_share_rate, a.real_rate) * a.rmnum), 0) rate FROM rsv_src AS a LEFT JOIN rsv_rate AS b ON b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.rsv_src_id = a.id AND b.rsv_date = arg_biz_date WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND ((a.arr_date <= arg_biz_date	AND a.dep_date > ?)	OR (a.arr_date = arg_biz_date AND a.dep_date = ?)) AND (a.occ_flag = 'RF' OR a.occ_flag = 'RG')		
		UNION ALL 
		SELECT IFNULL(SUM(IFNULL(IFNULL(c.real_share_rate, b.real_rate), a.real_rate)) ,0) rate FROM master_base AS a	LEFT JOIN rsv_src AS b ON b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.accnt = a.id AND ((b.arr_date <= arg_biz_date AND b.dep_date > arg_biz_date ) OR (b.arr_date = arg_biz_date AND b.dep_date = ?)) AND b.occ_flag = 'MF' LEFT JOIN rsv_rate AS c ON c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = arg_hotel_id AND c.master_id = a.id AND c.rsv_src_id = b.id AND c.rsv_date = arg_biz_date WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.is_resrv = 'F' AND a.id <> a.rsv_id AND a.rsv_class = 'F' AND a.sta IN('R','I','S') AND ((a.arr <= CONVERT(CONCAT(DATE(arg_biz_date),' ','23:59:59'),DATETIME) AND a.dep > CONVERT(CONCAT(DATE(arg_biz_date),' ','23:59:59'),DATETIME)) OR (a.arr >= CONVERT(CONCAT(DATE(arg_biz_date),' ','00:00:00'),DATETIME) AND a.dep <= CONVERT(CONCAT(DATE(arg_biz_date),' ','23:59:59'),DATETIME)))			
		) AS temp;
	
	ELSEIF arg_index = 'Available Rooms' THEN -- 本夜可用
		SELECT IFNULL(SUM(a.quantity - IFNULL(b.unsure_book_num, 0)- IFNULL(b.sure_book_num, 0)- IFNULL(ooo_num,0) - IFNULL(os_num, 0) - IFNULL(villa_num,0)),0) INTO arg_result FROM room_type a LEFT JOIN rsv_rmtype_total b ON a. CODE = b.rmtype AND b.occ_date = arg_biz_date AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.is_halt = 'F'; 	
	
	ELSEIF arg_index = 'House Overbooking' THEN -- 超预留数
		SELECT IFNULL(SUM(overbook_num),0) INTO arg_result FROM rsv_limit WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND INSTR(arg_types,rmtype)>0;
 				
	ELSEIF arg_index = 'Average Room Rate' THEN -- 平均房价
		BEGIN	
			CALL up_ihotel_forecast_index_detail(arg_hotel_group_id,arg_hotel_id,arg_biz_date,arg_types,'Room Revenue',var_result1);
			CALL up_ihotel_forecast_index_detail(arg_hotel_group_id,arg_hotel_id,arg_biz_date,arg_types,'Actual Rooms',var_result2);
			IF var_result2 <> 0 THEN
				SET arg_result = ROUND(var_result1/var_result2,2);
			ELSE
				SET arg_result = 0;
			END IF;
		END;
	END IF;	
		
END$$

DELIMITER ;