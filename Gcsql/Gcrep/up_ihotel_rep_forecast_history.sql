DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_rep_forecast_history`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_rep_forecast_history`(
	IN arg_hotel_group_id	INT,
	IN arg_hotel_id			INT,
	IN arg_begin_date		DATETIME,
	IN arg_end_date			DATETIME
)
    SQL SECURITY INVOKER
label_0:
BEGIN

	-- Histroy And Forecast Report
	DECLARE done_cursor 	INT DEFAULT 0 ;
	DECLARE var_bdate		DATETIME;
	DECLARE var_amount		DECIMAL(12,2);
	DECLARE var_amount1		DECIMAL(12,2);
	DECLARE var_amount2		DECIMAL(12,2);
	DECLARE var_amount3		DECIMAL(12,2);
	DECLARE var_amount4		DECIMAL(12,2);
	DECLARE var_int			INT;
			
	SELECT biz_date1 INTO var_bdate FROM audit_flag WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;
	
	DROP TABLE IF EXISTS rep_forecast_history;
	CREATE TABLE rep_forecast_history (
	    hotel_group_id 	INT NOT NULL,
		hotel_id 		INT NOT NULL,
		classno			CHAR(1),
		biz_date		DATETIME NOT NULL,
		rm_ttl			INT NOT NULL DEFAULT '0',
		rm_rent			INT NOT NULL DEFAULT '0',
		rm_avl			INT NOT NULL DEFAULT '0',
		rm_sold			DECIMAL(12,2) NOT NULL DEFAULT '0.00',
		rm_free			INT NOT NULL DEFAULT '0',
		rm_hse			INT NOT NULL DEFAULT '0',
		rm_ooo			INT NOT NULL DEFAULT '0',
		rm_tmp			INT NOT NULL DEFAULT '0',
		rm_arr			INT NOT NULL DEFAULT '0',
		rm_sta			INT NOT NULL DEFAULT '0',
		rm_dep			INT NOT NULL DEFAULT '0',
		rm_pickup		INT NOT NULL DEFAULT '0',
		rm_occ			DECIMAL(12,2) NOT NULL DEFAULT '0.00',
		rm_avg			DECIMAL(12,2) NOT NULL DEFAULT '0.00',
		rm_par			DECIMAL(12,2) NOT NULL DEFAULT '0.00',
		rev_rm			DECIMAL(12,2) NOT NULL DEFAULT '0.00',			
		KEY index1 (hotel_group_id,hotel_id,biz_date,classno)
	);	
		
	WHILE arg_begin_date <= arg_end_date DO
		BEGIN
		
			IF arg_begin_date < var_bdate THEN
				INSERT INTO rep_forecast_history(hotel_group_id,hotel_id,classno,biz_date)
					SELECT arg_hotel_group_id,arg_hotel_id,'A',arg_begin_date;
			ELSE
				INSERT INTO rep_forecast_history(hotel_group_id,hotel_id,classno,biz_date)
					SELECT arg_hotel_group_id,arg_hotel_id,'B',arg_begin_date;			
			END IF;
		
			IF arg_begin_date < var_bdate THEN	-- 开始日期至营业日期
				BEGIN
					UPDATE rep_forecast_history a,rep_audit_index_history b SET a.rm_ttl=IFNULL(b.amount,0) WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.biz_date = arg_begin_date AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.biz_date = arg_begin_date AND b.audit_index='rm_ttl';
					UPDATE rep_forecast_history a,rep_audit_index_history b SET a.rm_avl=IFNULL(b.amount,0) WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.biz_date = arg_begin_date AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.biz_date = arg_begin_date AND b.audit_index='rm_avl';
					UPDATE rep_forecast_history a,rep_audit_index_history b SET a.rm_sold=IFNULL(b.amount,0) WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.biz_date = arg_begin_date AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.biz_date = arg_begin_date AND b.audit_index='rm_sold';
					UPDATE rep_forecast_history a,rep_audit_index_history b SET a.rm_tmp=IFNULL(b.amount,0) WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.biz_date = arg_begin_date AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.biz_date = arg_begin_date AND b.audit_index='rm_tmp';					
					UPDATE rep_forecast_history a,rep_audit_index_history b SET a.rm_free=IFNULL(b.amount,0) WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.biz_date = arg_begin_date AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.biz_date = arg_begin_date AND b.audit_index='rm_free';
					UPDATE rep_forecast_history a,rep_audit_index_history b SET a.rm_hse=IFNULL(b.amount,0) WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.biz_date = arg_begin_date AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.biz_date = arg_begin_date AND b.audit_index='rm_hse';
					UPDATE rep_forecast_history a,rep_audit_index_history b SET a.rm_ooo=IFNULL(b.amount,0) WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.biz_date = arg_begin_date AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.biz_date = arg_begin_date AND b.audit_index='rm_ooo';
					UPDATE rep_forecast_history a,rep_audit_index_history b SET a.rm_arr=IFNULL(b.amount,0) WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.biz_date = arg_begin_date AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.biz_date = arg_begin_date AND b.audit_index='rm_sold_arr';
					UPDATE rep_forecast_history a,rep_audit_index_history b SET a.rm_sta=IFNULL(b.amount,0) WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.biz_date = arg_begin_date AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.biz_date = arg_begin_date AND b.audit_index='rm_sold_sta';
					UPDATE rep_forecast_history a,rep_audit_index_history b SET a.rm_dep=IFNULL(b.amount,0) WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.biz_date = arg_begin_date AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.biz_date = arg_begin_date AND b.audit_index='rm_sold_dep';
					UPDATE rep_forecast_history a,rep_audit_index_history b SET a.rev_rm=IFNULL(b.amount,0) WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.biz_date = arg_begin_date AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.biz_date = arg_begin_date AND b.audit_index='rev_rm';
					UPDATE rep_forecast_history a,rep_audit_index_history b SET a.rm_pickup=IFNULL(b.amount,0) WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.biz_date = arg_begin_date AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.biz_date = arg_begin_date AND b.audit_index='rm_pickup';
					SELECT rm_ttl INTO var_amount1 FROM rep_forecast_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = arg_begin_date;
					SELECT rm_sold INTO var_amount2 FROM rep_forecast_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = arg_begin_date;
					UPDATE rep_forecast_history SET rm_rent=var_amount1 - var_amount2 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = arg_begin_date;
			
				END;
			ELSE								-- 营业日期至结束日期
				BEGIN
					CALL up_ihotel_forecast_index_detail(arg_hotel_group_id,arg_hotel_id,arg_begin_date,'%','Total Rooms',var_amount); -- 总房数
					UPDATE rep_forecast_history SET rm_ttl=var_amount WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = arg_begin_date;				
					CALL up_ihotel_forecast_index_detail(arg_hotel_group_id,arg_hotel_id,arg_begin_date,'%','Room to Rent',var_amount); -- 可卖房
					UPDATE rep_forecast_history SET rm_rent=var_amount WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = arg_begin_date;					
					CALL up_ihotel_forecast_index_detail(arg_hotel_group_id,arg_hotel_id,arg_begin_date,'%','Available Rooms',var_amount); -- 可用房
					UPDATE rep_forecast_history SET rm_avl=var_amount WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = arg_begin_date;	
					CALL up_ihotel_forecast_index_detail(arg_hotel_group_id,arg_hotel_id,arg_begin_date,'%','Actual Rooms',var_amount); -- 已售房
					UPDATE rep_forecast_history SET rm_sold=var_amount WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = arg_begin_date;					
					CALL up_ihotel_forecast_index_detail(arg_hotel_group_id,arg_hotel_id,arg_begin_date,'%','COM',var_amount); -- 免费房
					UPDATE rep_forecast_history SET rm_free=var_amount WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = arg_begin_date;
					CALL up_ihotel_forecast_index_detail(arg_hotel_group_id,arg_hotel_id,arg_begin_date,'%','HSE',var_amount); -- 自用房
					UPDATE rep_forecast_history SET rm_hse=var_amount WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = arg_begin_date;					
					CALL up_ihotel_forecast_index_detail(arg_hotel_group_id,arg_hotel_id,arg_begin_date,'%','Out of Order',var_amount); -- 维修房
					UPDATE rep_forecast_history SET rm_ooo=var_amount WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = arg_begin_date;
					CALL up_ihotel_forecast_index_detail(arg_hotel_group_id,arg_hotel_id,arg_begin_date,'%','Out of TMP',var_amount); -- 临时态
					UPDATE rep_forecast_history SET rm_tmp=var_amount WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = arg_begin_date;					
					CALL up_ihotel_forecast_index_detail(arg_hotel_group_id,arg_hotel_id,arg_begin_date,'%','Occupied In Arr',var_amount); -- 预订房间数
					UPDATE rep_forecast_history SET rm_arr=var_amount WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = arg_begin_date;	
					CALL up_ihotel_forecast_index_detail(arg_hotel_group_id,arg_hotel_id,arg_begin_date,'%','Occupied In Sta',var_amount); -- 在住房间数
					UPDATE rep_forecast_history SET rm_sta=var_amount WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = arg_begin_date;
					CALL up_ihotel_forecast_index_detail(arg_hotel_group_id,arg_hotel_id,arg_begin_date,'%','Occupied In Dep',var_amount); -- 离店房间数
					UPDATE rep_forecast_history SET rm_dep=var_amount WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = arg_begin_date;	
					CALL up_ihotel_forecast_index_detail(arg_hotel_group_id,arg_hotel_id,arg_begin_date,'%','Day Use',var_amount); -- 当日pickup
					UPDATE rep_forecast_history SET rm_pickup=var_amount WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = arg_begin_date;
					CALL up_ihotel_forecast_index_detail(arg_hotel_group_id,arg_hotel_id,arg_begin_date,'%','Room Revenue',var_amount); -- 预订房费收入
					UPDATE rep_forecast_history SET rev_rm=var_amount WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = arg_begin_date;					
				
				END;
			END IF;
			
			
			SELECT rev_rm INTO var_amount1 FROM rep_forecast_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = arg_begin_date;
			SELECT rm_sold INTO var_amount2 FROM rep_forecast_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = arg_begin_date;
			SELECT rm_hse INTO var_amount3 FROM rep_forecast_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = arg_begin_date;
			UPDATE rep_forecast_history SET rm_avg=IF((var_amount2 - var_amount3)<>0,ROUND(var_amount1/(var_amount2 - var_amount3),2),0) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = arg_begin_date;					
			
			SELECT rm_ttl INTO var_amount1 FROM rep_forecast_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = arg_begin_date;
			SELECT rm_sold INTO var_amount2 FROM rep_forecast_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = arg_begin_date;
			SELECT rm_hse INTO var_amount3 FROM rep_forecast_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = arg_begin_date;
			SELECT rm_ooo INTO var_amount4 FROM rep_forecast_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = arg_begin_date;
			UPDATE rep_forecast_history SET rm_occ=IF((var_amount1 - var_amount3 - var_amount4)<>0,ROUND((var_amount2 - rm_hse)*100/(var_amount1 - var_amount3 - var_amount4),2),0) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = arg_begin_date;
			SELECT rm_avg INTO var_amount1 FROM rep_forecast_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = arg_begin_date;
			SELECT rm_occ INTO var_amount2 FROM rep_forecast_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = arg_begin_date;
			UPDATE rep_forecast_history SET rm_par=rm_avg*rm_occ/100 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = arg_begin_date;			
		
		-- Next Date
		SET arg_begin_date = ADDDATE(arg_begin_date,INTERVAL 1 DAY);
		END;
	END WHILE;
	
	
	SELECT classno,biz_date,rm_ttl,rm_rent,rm_avl,rm_sold,rm_free,rm_hse,rm_ooo,rm_tmp,rm_arr,rm_sta,rm_dep,rm_pickup,rm_occ,rm_avg,rm_par,rev_rm
		FROM rep_forecast_history WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id ORDER BY biz_date;
	
	DROP TABLE rep_forecast_history;
	
END$$

DELIMITER ;