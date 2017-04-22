DELIMITER $$

DROP PROCEDURE IF EXISTS `ihotel_up_report_import`$$

CREATE DEFINER=`root`@`%` PROCEDURE `ihotel_up_report_import`(
	arg_hotel_group_id	BIGINT(16),
	arg_hotel_id		BIGINT(16)
)
SQL SECURITY INVOKER
label_0:
BEGIN
	DECLARE var_biz_date DATETIME;
	DECLARE var_bfdate DATETIME;
	
	SELECT biz_date INTO var_biz_date FROM audit_flag WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;	
	SET var_bfdate = ADDDATE(var_biz_date,-1);

	-- 营业日报表
	DELETE FROM rep_jour WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM rep_jour_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	
	INSERT INTO rep_jour(hotel_group_id,hotel_id,biz_date,code,descript,descript_en,day,month,year,rebate_day,rebate_month,rebate_year,is_show,list_order)
		SELECT arg_hotel_group_id,arg_hotel_id,DATE,class,descript,descript1,day,month,year,day_rebate,month_rebate,year_rebate,'T',0 
		FROM migrate_db.yjourrep_01 WHERE DATE >='2015-01-01';

	INSERT INTO rep_jour_history(hotel_group_id,hotel_id,biz_date,code,descript,descript_en,day,month,year,rebate_day,rebate_month,rebate_year,is_show,list_order)
		SELECT hotel_group_id,hotel_id,biz_date,code,descript,descript_en,day,month,year,rebate_day,rebate_month,rebate_year,is_show,list_order
		FROM rep_jour WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;

	DELETE FROM rep_jour WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	
	INSERT INTO rep_jour(hotel_group_id,hotel_id,biz_date,CODE,descript,descript_en,DAY,MONTH,YEAR,rebate_day,rebate_month,rebate_year,is_show,list_order)
		SELECT arg_hotel_group_id,arg_hotel_id,var_bfdate,code,descript,descript_en,0,0,0,0,0,0,'T',list_order
			FROM rep_jour_rule WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
			
	UPDATE rep_jour a,rep_jour_history b SET a.day = b.day,a.month = b.month,a.year = b.year,a.rebate_day = b.rebate_day,a.rebate_month = b.rebate_month,a.rebate_year=b.rebate_year WHERE a.hotel_group_id = b.hotel_group_id AND a.hotel_id = b.hotel_id
		AND a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.code = b.code AND b.biz_date = var_bfdate;
	
	DELETE FROM rep_jour_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bfdate;
	INSERT INTO rep_jour_history(hotel_group_id,hotel_id,biz_date,code,descript,descript_en,day,month,year,rebate_day,rebate_month,rebate_year,is_show,list_order)
		SELECT hotel_group_id,hotel_id,biz_date,CODE,descript,descript_en,DAY,MONTH,YEAR,rebate_day,rebate_month,rebate_year,is_show,list_order
		FROM rep_jour WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;	
	
	UPDATE rep_jour_history a,rep_jour_rule b SET a.list_order=b.list_order WHERE a.hotel_group_id = b.hotel_group_id AND a.hotel_id = b.hotel_id AND a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.code = b.code;
	UPDATE rep_jour a,rep_jour_rule b SET a.list_order=b.list_order WHERE a.hotel_group_id = b.hotel_group_id AND a.hotel_id = b.hotel_id AND a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.code = b.code;	
	
	
END$$

DELIMITER ;

-- yjourrep_01
CALL ihotel_up_report_import(2,42);

DROP PROCEDURE IF EXISTS `ihotel_up_report_import`;
