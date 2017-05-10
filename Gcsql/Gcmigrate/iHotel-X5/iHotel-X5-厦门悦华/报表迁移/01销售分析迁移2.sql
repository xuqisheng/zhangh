DELETE FROM rep_revenue_market WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date <= '2014.12.07';;
DELETE FROM rep_revenue_market_history WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date <= '2014.12.07';
INSERT INTO `rep_revenue_market` 
	(`hotel_group_id`, 
	`hotel_id`, 
 	`biz_date`, 
	`code_type`, 
	`code_category`, 
	`code`, 
	`rev_total`, 
	`rev_rm`, 
	`rev_rm_srv`, 
	`rev_rm_pkg`, 
	`rev_fb`, 
	`rev_mt`, 
	`rev_en`, 
	`rev_sp`, 
	`rev_ot`, 
	`rooms_total`, 
	`rooms_arr`, 
	`rooms_dep`, 
	`rooms_noshow`, 
	`rooms_cxl`, 
	`people_total`, 
	`people_arr`, 
	`people_dep`
	)
SELECT hotel_group_id, 
	hotel_id, 
 	biz_date, 
	code_type, 
	code_category, 
	CODE, 
	rev_total, 
	rev_rm, 
	rev_rm_srv, 
	rev_rm_pkg, 
	rev_fb, 
	rev_mt, 
	rev_en, 
	rev_sp, 
	rev_ot, 
	rooms_total, 
	rooms_arr, 
	rooms_dep, 
	rooms_noshow, 
	rooms_cxl, 
	people_total, 
	people_arr, 
	people_dep
	FROM rep_revenue_type_history WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date <='2014.12.07';
	
INSERT INTO rep_revenue_market_history SELECT * FROM rep_revenue_market WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date <='2014.12.07';
	
DELETE FROM rep_revenue_market WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date <= '2014.12.07';
SELECT * FROM rep_revenue_market WHERE hotel_group_id = 1 AND hotel_id = 1;
SELECT * FROM rep_revenue_market_history WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date = '2014.12.07';