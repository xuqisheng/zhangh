DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_forecast_index_detail`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_forecast_index_detail`(
	IN arg_hotel_group_id	INT,
	IN arg_hotel_id		    INT,
	IN arg_biz_date		    DATETIME,
	IN arg_types		    VARCHAR(255),
	IN arg_index		    VARCHAR(50),
	OUT arg_result		    DECIMAL(12,2)
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
	ELSEIF arg_index = 'Actual Rooms' THEN	-- 占用房
		BEGIN
			SELECT SUM(sure_book_num+unsure_book_num) INTO var_result1 FROM rsv_rmtype_total WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND occ_date=arg_biz_date;
			SET arg_result = var_result1;
		END;

	ELSEIF arg_index = 'COM' THEN -- 免费房
		SELECT IFNULL(SUM(b.rmnum),0) INTO arg_result FROM master_base a,rsv_src b LEFT JOIN code_base c ON b.hotel_group_id=c.hotel_group_id AND b.hotel_id=c.hotel_id AND b.market=c.code AND c.parent_code='market_code' WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id
			AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.id=b.accnt AND c.flag='COM' AND b.occ_flag IN ('RF','RG','MF') AND arg_biz_date >= b.arr_date AND arg_biz_date <= b.dep_date;
	ELSEIF arg_index = 'HSE' THEN -- 自用房
		SELECT IFNULL(SUM(b.rmnum),0) INTO arg_result FROM master_base a,rsv_src b LEFT JOIN code_base c ON b.hotel_group_id=c.hotel_group_id AND b.hotel_id=c.hotel_id AND b.market=c.code AND c.parent_code='market_code' WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id
			AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.id=b.accnt AND c.flag='HSE' AND b.occ_flag IN ('RF','RG','MF') AND arg_biz_date >= b.arr_date AND arg_biz_date <= b.dep_date;

	ELSEIF arg_index = 'LON' THEN -- 长包房
		SELECT IFNULL(SUM(b.rmnum),0) INTO arg_result FROM master_base a,rsv_src b LEFT JOIN code_base c ON b.hotel_group_id=c.hotel_group_id AND b.hotel_id=c.hotel_id AND b.market=c.code AND c.parent_code='market_code' WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id
			AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.id=b.accnt AND c.flag='LON' AND b.occ_flag IN ('RF','RG','MF') AND arg_biz_date >= b.arr_date AND arg_biz_date <= b.dep_date;
	ELSEIF arg_index = 'Definite Reservations' THEN -- 确认预订
		SELECT IFNULL(SUM(b.rmnum),0) INTO arg_result FROM master_base a,rsv_src b WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id
			AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.id=b.accnt AND INSTR(arg_types,b.rmtype)>0 AND a.is_sure='T' AND a.rsv_class IN ('F','G') AND b.occ_flag IN ('RF','RG') AND b.arr_date=arg_biz_date AND b.rmnum > 0;

	ELSEIF arg_index = 'Tentative Reservation' THEN -- 非确认预订
		SELECT IFNULL(SUM(b.rmnum),0) INTO arg_result FROM master_base a,rsv_src b WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id
			AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.id=b.accnt AND INSTR(arg_types,b.rmtype)>0 AND a.is_sure='F' AND a.rsv_class IN ('F','G') AND b.occ_flag IN ('RF','RG') AND b.arr_date=arg_biz_date AND b.rmnum > 0;
	ELSEIF arg_index = 'Total Reserved' THEN -- 总预订 = 确认预订 + 非确认预订
		BEGIN
			CALL up_ihotel_forecast_index_detail(arg_hotel_group_id,arg_hotel_id,arg_biz_date,arg_types,'Definite Reservations',var_result1);
			CALL up_ihotel_forecast_index_detail(arg_hotel_group_id,arg_hotel_id,arg_biz_date,arg_types,'Tentative Reservation',var_result2);
			SET arg_result = var_result1 + var_result2;
		END;

	ELSEIF arg_index = 'Available Rooms' THEN -- 可用房 = 可卖房 - 确认预订客房
		BEGIN
			CALL up_ihotel_forecast_index_detail(arg_hotel_group_id,arg_hotel_id,arg_biz_date,arg_types,'Room to Rent',var_result1);
			CALL up_ihotel_forecast_index_detail(arg_hotel_group_id,arg_hotel_id,arg_biz_date,arg_types,'Definite Reservations',var_result2);
			SET arg_result = var_result1 - var_result2;
		END;

	ELSEIF arg_index = 'Available Rooms' THEN -- 最小可用房 = 可卖房 - 确认预订 - 非确认预订
		BEGIN
			CALL up_ihotel_forecast_index_detail(arg_hotel_group_id,arg_hotel_id,arg_biz_date,arg_types,'Room to Rent',var_result1);
			CALL up_ihotel_forecast_index_detail(arg_hotel_group_id,arg_hotel_id,arg_biz_date,arg_types,'Definite Reservations',var_result2);
			CALL up_ihotel_forecast_index_detail(arg_hotel_group_id,arg_hotel_id,arg_biz_date,arg_types,'Tentative Reservation',var_result3);
			SET arg_result = var_result1 - var_result2 - var_result3;
		END;

	ELSEIF arg_index = 'House Overbooking' THEN -- 超预留数
		SELECT IFNULL(SUM(overbook_num),0) INTO arg_result FROM rsv_limit WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND INSTR(arg_types,rmtype)>0;

	ELSEIF arg_index = 'Rooms to Sell' THEN -- 可订房 = 可用房 + 超预留数目
		BEGIN
			CALL up_ihotel_forecast_index_detail(arg_hotel_group_id,arg_hotel_id,arg_biz_date,arg_types,'Available Rooms',var_result1);
			CALL up_ihotel_forecast_index_detail(arg_hotel_group_id,arg_hotel_id,arg_biz_date,arg_types,'House Overbooking',var_result2);
			SET arg_result = var_result1 + var_result2;
		END;

	ELSEIF 	arg_index = 'Arrival Rooms' THEN -- 未分房 + 分房
		BEGIN
			SELECT IFNULL(SUM(rmnum),0) INTO var_result1 FROM rsv_src WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND arr_date = arg_biz_date AND arr_date <> dep_date AND occ_flag IN ('RF','RG','MF') AND INSTR(arg_types,rmtype) > 0 AND rmno = '';
			SELECT IFNULL(COUNT(DISTINCT rmno),0) INTO var_result2 FROM rsv_src WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND arr_date = arg_biz_date AND arr_date <> dep_date AND occ_flag IN ('RF','RG','MF') AND INSTR(arg_types,rmtype) > 0 ;
			SET arg_result = var_result1 + var_result2;
		END;
	ELSEIF arg_index = 'Over Reserved' THEN -- diff = 总预订房 - 可卖房
		BEGIN
			CALL up_ihotel_forecast_index_detail(arg_hotel_group_id,arg_hotel_id,arg_biz_date,arg_types,'Total Reserved',var_result1);
			CALL up_ihotel_forecast_index_detail(arg_hotel_group_id,arg_hotel_id,arg_biz_date,arg_types,'Room to Rent',var_result2);
			IF var_result1 > var_result2 THEN
				SET arg_result = var_result1 - var_result2;
			ELSE
				SET arg_result = 0;
			END IF;
		END;

	ELSEIF arg_index = 'Day Use' THEN -- 当日抵离 | 房数
		BEGIN
			SELECT IFNULL(SUM(rmnum),0) INTO var_result1 FROM rsv_src WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND arr_date = dep_date AND arr_date = arg_biz_date AND occ_flag IN ('RF','RG','MF') AND INSTR(arg_types,rmtype) > 0 AND rmno = '';
			SELECT IFNULL(COUNT(DISTINCT rmno),0) INTO var_result2 FROM rsv_src WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND arr_date = dep_date AND arr_date = arg_biz_date AND occ_flag IN ('RF','RG','MF') AND INSTR(arg_types,rmtype) > 0 AND rmno <> '';
			SET arg_result = var_result1 + var_result2;
		END;

	ELSEIF arg_index = 'Day Use Persons' THEN -- 当日抵离 | 人数
		BEGIN
		SELECT IFNULL(SUM(adult*rmnum),0) INTO arg_result FROM rsv_src WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND arr_date = dep_date AND arr_date = arg_biz_date AND occ_flag IN ('RF','RG','MF') AND INSTR(arg_types,rmtype) > 0;
		END;

	ELSEIF arg_index = 'Occupied In Sta' THEN  -- 当日在住 | 房数
		BEGIN
			IF arg_biz_date = var_bdate THEN
				SELECT COUNT(DISTINCT a.master_id,a.rmno) INTO var_result1 FROM master_base a WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.id<>a.rsv_id AND a.sta='I' AND a.rsv_class IN ('F','D') AND DATE(a.arr) <= arg_biz_date AND DATE(a.dep) >= arg_biz_date AND INSTR(arg_types,a.rmtype) > 0;
			ELSE
				SELECT COUNT(DISTINCT a.master_id,a.rmno) INTO var_result1 FROM master_base a WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.id<>a.rsv_id AND a.sta='I' AND a.rsv_class IN ('F','D') AND DATE(a.arr) <= arg_biz_date AND DATE(a.dep) >= arg_biz_date AND INSTR(arg_types,a.rmtype) > 0;
				SELECT COUNT(DISTINCT a.master_id,a.rmno) INTO var_result2 FROM master_base a WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.id<>a.rsv_id AND a.sta='R' AND a.rsv_class='F' AND DATE(a.arr) < arg_biz_date AND DATE(a.dep) >= arg_biz_date AND INSTR(arg_types,a.rmtype) > 0;
				SELECT IFNULL(SUM(b.rmnum),0) INTO var_result3 FROM master_base a,rsv_src b WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.id=b.accnt AND b.occ_flag IN ('RF','RG') AND a.rsv_class IN ('F','G') AND a.id=a.rsv_id AND  b.arr_date < arg_biz_date AND b.dep_date>=arg_biz_date AND INSTR(arg_types,a.rmtype) > 0;
			END IF;

			SET arg_result = var_result1 + var_result2 + var_result3;
		END;
	ELSEIF arg_index = 'Occupied In Sta FIT' THEN  -- 当日在住 | 房数 | 散客
		BEGIN
			IF arg_biz_date = var_bdate THEN
				SELECT COUNT(DISTINCT a.master_id,a.rmno) INTO var_result1 FROM master_base a WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.id<>a.rsv_id AND a.sta='I' AND a.rsv_class IN ('F','D') AND a.grp_accnt=0 AND DATE(a.arr) <= arg_biz_date AND DATE(a.dep) >= arg_biz_date AND INSTR(arg_types,a.rmtype) > 0;
			ELSE
				SELECT COUNT(DISTINCT a.master_id,a.rmno) INTO var_result1 FROM master_base a WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.id<>a.rsv_id AND a.sta='I' AND a.rsv_class IN ('F','D') AND a.grp_accnt=0 AND DATE(a.arr) <= arg_biz_date AND DATE(a.dep) >= arg_biz_date AND INSTR(arg_types,a.rmtype) > 0;
				SELECT COUNT(DISTINCT a.master_id,a.rmno) INTO var_result2 FROM master_base a WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.id<>a.rsv_id AND a.sta='R' AND a.rsv_class='F' AND a.grp_accnt=0 AND DATE(a.arr) < arg_biz_date AND DATE(a.dep) >= arg_biz_date AND INSTR(arg_types,a.rmtype) > 0;

				SELECT IFNULL(SUM(b.rmnum),0) INTO var_result3 FROM master_base a,rsv_src b WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.id=b.accnt AND b.occ_flag ='RF' AND a.rsv_class IN ('F','G') AND a.grp_accnt=0 AND a.id=a.rsv_id AND  b.arr_date < arg_biz_date AND b.dep_date>=arg_biz_date AND INSTR(arg_types,a.rmtype) > 0;
			END IF;

			SET arg_result = var_result1 + var_result2 + var_result3;
		END;
	ELSEIF arg_index = 'Occupied In Sta GRP' THEN  -- 当日在住 | 房数 | 团队
		BEGIN
			IF arg_biz_date = var_bdate THEN
				SELECT COUNT(DISTINCT a.master_id,a.rmno) INTO var_result1 FROM master_base a WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.id<>a.rsv_id AND a.sta='I' AND a.rsv_class IN ('F','D') AND a.grp_accnt<>0 AND DATE(a.arr) <= arg_biz_date AND DATE(a.dep) >= arg_biz_date AND INSTR(arg_types,a.rmtype) > 0;
			ELSE
				SELECT COUNT(DISTINCT a.master_id,a.rmno) INTO var_result1 FROM master_base a WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.id<>a.rsv_id AND a.sta='I' AND a.rsv_class IN ('F','D') AND a.grp_accnt<>0 AND DATE(a.arr) <= arg_biz_date AND DATE(a.dep) >= arg_biz_date AND INSTR(arg_types,a.rmtype) > 0;
				SELECT COUNT(DISTINCT a.master_id,a.rmno) INTO var_result2 FROM master_base a WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.id<>a.rsv_id AND a.sta='R' AND a.rsv_class='F' AND a.grp_accnt<>0 AND DATE(a.arr) < arg_biz_date AND DATE(a.dep) >= arg_biz_date AND INSTR(arg_types,a.rmtype) > 0;

				SELECT IFNULL(SUM(b.rmnum),0) INTO var_result3 FROM master_base a,rsv_src b WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.id=b.accnt AND b.occ_flag ='RF' AND a.rsv_class IN ('F','G') AND a.grp_accnt<>0 AND a.id=a.rsv_id AND  b.arr_date < arg_biz_date AND b.dep_date>=arg_biz_date AND INSTR(arg_types,a.rmtype) > 0;
			END IF;

			SET arg_result = var_result1 + var_result2 + var_result3;
		END;
	ELSEIF arg_index = 'Occupied In Arr' THEN -- 当日预抵 | 房数
		BEGIN
			SELECT IFNULL(SUM(b.rmnum),0) INTO var_result1 FROM master_base a,rsv_src b WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.id=b.accnt AND b.occ_flag IN ('RF','RG') AND a.rsv_class<>'H' AND a.sta IN ('R','I') AND a.id=a.rsv_id AND b.rmnum>0 AND b.arr_date = arg_biz_date AND INSTR(arg_types,a.rmtype) > 0;
			SELECT COUNT(DISTINCT a.master_id,a.rmno) INTO var_result2 FROM master_base a WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.id<>a.rsv_id AND a.rsv_class='F' AND a.sta='R' AND DATE(a.arr) = arg_biz_date AND INSTR(arg_types,a.rmtype) > 0;
			SET arg_result = var_result1 + var_result2;
		END;

	ELSEIF arg_index = 'Occupied In Dep' THEN  -- 当日预离 | 房数
		BEGIN
			SELECT COUNT(DISTINCT a.master_id,a.rmno) INTO var_result1 FROM master_base a WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.id<>a.rsv_id AND a.sta IN ('R','I') AND a.rsv_class IN ('F','D') AND DATE(a.dep) = arg_biz_date AND INSTR(arg_types,a.rmtype) > 0;
			SELECT IFNULL(SUM(b.rmnum),0) INTO var_result2 FROM master_base a,rsv_src b WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.id=b.accnt AND a.id=a.rsv_id AND a.sta IN ('R','I') AND b.occ_flag IN ('RF','RG') AND b.rmnum>0 AND b.dep_date=arg_biz_date AND a.rsv_class<>'H' AND INSTR(arg_types,a.rmtype) > 0;

			SET arg_result = var_result1 + var_result2;
		END;

	ELSEIF arg_index = 'Occupancy' THEN -- 出租率 = 确认预订客房 / 可卖房
		BEGIN
			CALL up_ihotel_forecast_index_detail(arg_hotel_group_id,arg_hotel_id,arg_biz_date,arg_types,'Definite Reservations',var_result1);
			CALL up_ihotel_forecast_index_detail(arg_hotel_group_id,arg_hotel_id,arg_biz_date,arg_types,'Room to Rent',var_result2);
			IF var_result2 <> 0 THEN
				SET arg_result = ROUND(var_result1*100/var_result2,2);
			ELSE
				SET arg_result = 0;
			END IF;
		END;

	ELSEIF arg_index = 'Maximum Occ' THEN -- 最大出租率 = (确认预订客房 + 非确认预订) / 可卖房
		BEGIN
			CALL up_ihotel_forecast_index_detail(arg_hotel_group_id,arg_hotel_id,arg_biz_date,arg_types,'Definite Reservations',var_result1);
			CALL up_ihotel_forecast_index_detail(arg_hotel_group_id,arg_hotel_id,arg_biz_date,arg_types,'Tentative Reservation',var_result2);
			CALL up_ihotel_forecast_index_detail(arg_hotel_group_id,arg_hotel_id,arg_biz_date,arg_types,'Room to Rent',var_result3);
			IF var_result3 <> 0 THEN
				SET arg_result = ROUND((var_result1+var_result2)*100/var_result3,2);
			ELSE
				SET arg_result = 0;
			END IF;
		END;

	ELSEIF arg_index = 'Departure Rooms' THEN -- 当日离店客房
		BEGIN
			SELECT IFNULL(SUM(rmnum),0) INTO var_result1 FROM rsv_src WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND arr_date <> dep_date AND dep_date = arg_biz_date AND occ_flag IN ('RF','RG','MF') AND rmno = '' AND INSTR(arg_types,rmtype) > 0;
			SELECT IFNULL(COUNT(DISTINCT(b.rmno)),0) INTO var_result2 FROM master_base a,rsv_src b WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND INSTR(arg_types,b.rmtype) > 0 AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.id=b.accnt AND b.occ_flag IN ('RF','RG','MF') AND b.rmno <> '' AND b.arr_date <> b.dep_date AND b.dep_date = arg_biz_date;

			SET arg_result = var_result1 + var_result2;
		END;

	ELSEIF arg_index = 'Occupied Tonight NOT HU' THEN -- 过夜客房(不含自用房)
		SELECT IFNULL(SUM(b.rmnum),0) INTO arg_result FROM master_base a,rsv_src b LEFT JOIN code_base c ON b.hotel_group_id=c.hotel_group_id AND b.hotel_id=c.hotel_id AND b.market=c.code AND c.parent_code='market_code' WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND INSTR(arg_types,b.rmtype) > 0
			AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.id=b.accnt AND c.flag<>'HSE' AND b.occ_flag IN ('RF','RG','MF') AND arg_biz_date >= b.arr_date AND arg_biz_date <= b.dep_date;

	ELSEIF arg_index = 'Occupied Tonight' THEN -- 过夜客房(所有)
		SELECT IFNULL(SUM(rmnum),0) INTO arg_result FROM rsv_src WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND INSTR(arg_types,rmtype) > 0 AND occ_flag IN ('RF','RG','MF') AND arg_biz_date >= arr_date AND arg_biz_date <= dep_date;
	ELSEIF arg_index = 'Occupied Tonight FIT' THEN -- 过夜客房(散客)
		BEGIN
			SELECT IFNULL(SUM(rmnum),0) INTO var_result1 FROM rsv_src WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND INSTR(arg_types,rmtype) > 0 AND occ_flag ='RF' AND arg_biz_date >= arr_date AND arg_biz_date <= dep_date;
			SELECT IFNULL(SUM(b.rmnum),0) INTO var_result2 FROM master_base a,rsv_src b WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND INSTR(arg_types,b.rmtype) > 0 AND a.grp_accnt = 0
				AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.id=b.accnt AND c.flag<>'HSE' AND b.occ_flag ='MF' AND arg_biz_date >= b.arr_date AND arg_biz_date <= b.dep_date;
			SET arg_result = var_result1 + var_result2;
		END;

	ELSEIF arg_index = 'Occupied Tonight GRP' THEN -- 过夜客房(团队)
		BEGIN
			SELECT IFNULL(SUM(rmnum),0) INTO var_result1 FROM rsv_src WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND INSTR(arg_types,rmtype) > 0 AND occ_flag ='RG' AND arg_biz_date >= arr_date AND arg_biz_date <= dep_date;
			SELECT IFNULL(SUM(b.rmnum),0) INTO var_result2 FROM master_base a,rsv_src b WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND INSTR(arg_types,b.rmtype) > 0 AND a.grp_accnt <> 0
				AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.id=b.accnt AND c.flag<>'HSE' AND b.occ_flag ='MF' AND arg_biz_date >= b.arr_date AND arg_biz_date <= b.dep_date;
			SET arg_result = var_result1 + var_result2;
		END;

	ELSEIF arg_index = 'People In Hotel NOT HU' THEN -- 过夜客人(不含自用房)
		SELECT IFNULL(SUM(b.rmnum*b.adult),0) INTO arg_result FROM master_base a,rsv_src b LEFT JOIN code_base c ON b.hotel_group_id=c.hotel_group_id AND b.hotel_id=c.hotel_id AND b.market=c.code AND c.parent_code='market_code' WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND INSTR(arg_types,b.rmtype) > 0
			AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.id=b.accnt AND c.flag<>'HSE' AND b.occ_flag IN ('RF','RG','MF') AND arg_biz_date >= b.arr_date AND arg_biz_date <= b.dep_date;

	ELSEIF arg_index = 'People In Hotel' THEN -- 过夜客人(所有)
		SELECT IFNULL(SUM(rmnum*adult),0) INTO arg_result FROM rsv_src WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND INSTR(arg_types,rmtype) > 0 AND occ_flag IN ('RF','RG','MF') AND arg_biz_date >= arr_date AND arg_biz_date <= dep_date;
	ELSEIF arg_index = 'People In Hotel FIT' THEN -- 过夜客人(散客)
		BEGIN
			SELECT IFNULL(SUM(rmnum*adult),0) INTO var_result1 FROM rsv_src WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND INSTR(arg_types,rmtype) > 0 AND occ_flag ='RF' AND arg_biz_date >= arr_date AND arg_biz_date <= dep_date;
			SELECT IFNULL(SUM(b.rmnum*b.adult),0) INTO var_result2 FROM master_base a,rsv_src b WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND INSTR(arg_types,b.rmtype) > 0 AND a.grp_accnt = 0
				AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.id=b.accnt AND c.flag<>'HSE' AND b.occ_flag ='MF' AND arg_biz_date >= b.arr_date AND arg_biz_date <= b.dep_date;
			SET arg_result = var_result1 + var_result2;
		END;

	ELSEIF arg_index = 'People In Hotel GRP' THEN -- 过夜客人(团队)
		BEGIN
			SELECT IFNULL(SUM(rmnum*adult),0) INTO var_result1 FROM rsv_src WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND INSTR(arg_types,rmtype) > 0 AND occ_flag ='RG' AND arg_biz_date >= arr_date AND arg_biz_date <= dep_date;
			SELECT IFNULL(SUM(b.rmnum*b.adult),0) INTO var_result2 FROM master_base a,rsv_src b WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND INSTR(arg_types,b.rmtype) > 0 AND a.grp_accnt <> 0
				AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.id=b.accnt AND c.flag<>'HSE' AND b.occ_flag ='MF' AND arg_biz_date >= b.arr_date AND arg_biz_date <= b.dep_date;
			SET arg_result = var_result1 + var_result2;
		END;
	ELSEIF arg_index = 'Walk-Ins' THEN -- 当前 Walk-Ins | 房数
		SELECT IFNULL(SUM(b.rmnum),0) INTO arg_result FROM master_base a,rsv_src b WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.sta = 'I' AND a.rsv_class = 'F'
			AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.id=b.accnt AND INSTR(arg_types,b.rmtype)>0 AND a.is_walkin='T'  AND b.occ_flag = 'MF' AND arg_biz_date >= b.arr_date AND arg_biz_date <= b.dep_date;
	ELSEIF arg_index = 'Walk-Ins Persons' THEN -- 当前 Walk-Ins | 人数
		SELECT IFNULL(SUM(b.rmnum*b.adult),0) INTO arg_result FROM master_base a,rsv_src b WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.sta = 'I' AND a.rsv_class = 'F'
			AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.id=b.accnt AND INSTR(arg_types,b.rmtype)>0 AND a.is_walkin='T'  AND b.occ_flag = 'MF' AND arg_biz_date >= b.arr_date AND arg_biz_date <= b.dep_date;
	ELSEIF arg_index = 'Room Revenue' THEN -- 预计客房收入
		SELECT IFNULL(SUM(IFNULL(b.real_share_rate,a.real_rate) * a.rmnum),0) INTO arg_result FROM rsv_src a LEFT JOIN rsv_rate b ON b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.rsv_src_id = a.id AND b.rsv_date=arg_biz_date WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.arr_date <= arg_biz_date AND a.dep_date > arg_biz_date AND a.occ_flag IN ('RF','RG','MF') AND INSTR(arg_types,a.rmtype) > 0;

	ELSEIF arg_index = 'Average Room Rate' THEN -- 平均房价
			CALL up_ihotel_forecast_index_detail(arg_hotel_group_id,arg_hotel_id,arg_biz_date,arg_types,'Room Revenue',var_result1);
			CALL up_ihotel_forecast_index_detail(arg_hotel_group_id,arg_hotel_id,arg_biz_date,arg_types,'Occupied Tonight',var_result2);
			IF var_result2 <> 0 THEN
				SET arg_result = ROUND(var_result1/var_result2,2);
			ELSE
				SET arg_result = 0;
			END IF;
	END IF;



END$$

DELIMITER ;