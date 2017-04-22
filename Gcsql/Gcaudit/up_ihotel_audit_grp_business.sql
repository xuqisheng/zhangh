/*
----each----:[#p@up_ihotel_audit_grp_business]
*/
DELIMITER $$
 
DROP PROCEDURE IF EXISTS `up_ihotel_audit_grp_business`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_audit_grp_business`(
	IN arg_hotel_group_id	BIGINT,
	IN arg_hotel_id		BIGINT,
	OUT arg_ret			INT,
	OUT arg_msg			VARCHAR(255)
)
BEGIN
	-- ---------------------------------------------------------------
	-- 夜审过程- 集团分析相关数据生成
	-- 	
	-- ---------------------------------------------------------------
	
	DECLARE var_bdate		DATETIME;
	DECLARE var_bfdate 		DATETIME;
	DECLARE var_begin_mdate	DATETIME;
	
	SET arg_ret = 1, arg_msg = 'OK';
	
	SELECT DATE_ADD(set_value,INTERVAL -1 DAY) INTO var_bdate FROM sys_option WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND catalog = 'system' AND item = 'biz_date';

	SET var_bfdate = DATE_ADD(var_bdate,INTERVAL -1 DAY);
	SET var_begin_mdate = IFNULL((SELECT begin_date FROM biz_month WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND begin_date<=var_bdate AND end_date>=var_bdate),'');
	
	DELETE FROM rep_grp_business_d WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND statis_date = var_bdate;
	DELETE FROM rep_grp_income_d WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND statis_date = var_bdate;

	INSERT INTO rep_grp_business_d(hotel_group_id,hotel_id,statis_date,room_total,room_sold,night,persons,rental_rates,room_avg,revpar)
	SELECT hotel_group_id,hotel_id,var_bdate,SUM(rooms_total),SUM(sold_fit + sold_grp + sold_long),SUM(sold_fit + sold_grp + sold_long),SUM(people_fit + people_grp + people_long),
		ROUND(SUM(sold_fit + sold_grp + sold_long)*100/SUM(rooms_total),2),ROUND(SUM(rev_fit + rev_grp + rev_long)/SUM(sold_fit + sold_grp + sold_long),2),ROUND(SUM(rev_fit + rev_grp + rev_long)/SUM(rooms_total),2)
	FROM rep_rmsale_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND rep_type = 'B';

	INSERT INTO rep_grp_income_d(hotel_group_id,hotel_id,statis_date,income_rm,income_pos,income_mt,income_en,income_sp,income_ot,income_ttl)
	SELECT hotel_group_id,hotel_id,var_bdate,SUM(rev_rm),SUM(rev_fb),SUM(rev_mt),SUM(rev_en),SUM(rev_sp),SUM(rev_ot),SUM(rev_total)
		FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND code_type='MARKET';

	IF EXISTS(SELECT 1 FROM rep_grp_business_m WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND statis_month = DATE_FORMAT(var_bdate,'%Y-%m')) THEN
		BEGIN
			DELETE FROM rep_grp_business_m WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND statis_month = DATE_FORMAT(var_bdate,'%Y-%m');
			INSERT INTO rep_grp_business_m(hotel_group_id,hotel_id,statis_month,room_total,room_sold,night,persons,rental_rates,room_avg,revpar)
				SELECT hotel_group_id,hotel_id,DATE_FORMAT(var_bdate,'%Y-%m'),SUM(rooms_total),SUM(sold_fit + sold_grp + sold_long),SUM(sold_fit + sold_grp + sold_long),SUM(people_fit + people_grp + people_long),ROUND(SUM(sold_fit + sold_grp + sold_long)*100/SUM(rooms_total),2),ROUND(SUM(rev_fit + rev_grp + rev_long)/SUM(sold_fit + sold_grp + sold_long),2),ROUND(SUM(rev_fit + rev_grp + rev_long)/SUM(rooms_total),2)
				FROM rep_rmsale_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date >= var_begin_mdate AND biz_date <= var_bdate AND rep_type = 'B';	
		END;
	ELSE
		BEGIN
			INSERT INTO rep_grp_business_m(hotel_group_id,hotel_id,statis_month,room_total,room_sold,night,persons,rental_rates,room_avg,revpar)
				SELECT hotel_group_id,hotel_id,DATE_FORMAT(var_bdate,'%Y-%m'),SUM(rooms_total),SUM(sold_fit + sold_grp + sold_long),SUM(sold_fit + sold_grp + sold_long),SUM(people_fit + people_grp + people_long),ROUND(SUM(sold_fit + sold_grp + sold_long)*100/SUM(rooms_total),2),ROUND(SUM(rev_fit + rev_grp + rev_long)/SUM(sold_fit + sold_grp + sold_long),2),ROUND(SUM(rev_fit + rev_grp + rev_long)/SUM(rooms_total),2)
				FROM rep_rmsale_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date >= var_begin_mdate AND biz_date <= var_bdate AND rep_type = 'B';	
		END;
	END IF;
	
	IF EXISTS(SELECT 1 FROM rep_grp_income_m WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND statis_month = DATE_FORMAT(var_bdate,'%Y-%m')) THEN
		BEGIN
			DELETE FROM rep_grp_income_m WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND statis_month = DATE_FORMAT(var_bdate,'%Y-%m');
			INSERT INTO rep_grp_income_m(hotel_group_id,hotel_id,statis_month,income_rm,income_pos,income_mt,income_en,income_sp,income_ot,income_ttl)
			SELECT hotel_group_id,hotel_id,DATE_FORMAT(var_bdate,'%Y-%m'),SUM(rev_rm),SUM(rev_fb),SUM(rev_mt),SUM(rev_en),SUM(rev_sp),SUM(rev_ot),SUM(rev_total)
				FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date >= var_begin_mdate AND biz_date <= var_bdate AND code_type='MARKET';
		END;
	ELSE
		BEGIN
			INSERT INTO rep_grp_income_m(hotel_group_id,hotel_id,statis_month,income_rm,income_pos,income_mt,income_en,income_sp,income_ot,income_ttl)
			SELECT hotel_group_id,hotel_id,DATE_FORMAT(var_bdate,'%Y-%m'),SUM(rev_rm),SUM(rev_fb),SUM(rev_mt),SUM(rev_en),SUM(rev_sp),SUM(rev_ot),SUM(rev_total)
				FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date >= var_begin_mdate AND biz_date <= var_bdate AND code_type='MARKET';
		END;
	END IF;
	
END$$

DELIMITER ;