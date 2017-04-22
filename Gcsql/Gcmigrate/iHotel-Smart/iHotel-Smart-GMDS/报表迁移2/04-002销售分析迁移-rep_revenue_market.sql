SELECT * FROM portal.rep_revenue_market WHERE hotel_group_id = 1 AND hotel_id = 5 AND biz_date <= '2015.11.04';
SELECT * FROM portal.rep_revenue_market_history WHERE hotel_group_id = 1 AND hotel_id = 5 AND biz_date <= '2015.11.04';

DELETE FROM portal.rep_revenue_market WHERE hotel_group_id = 1 AND hotel_id = 5 AND biz_date <= '2015.11.04';
DELETE FROM portal.rep_revenue_market_history WHERE hotel_group_id = 1 AND hotel_id = 5 AND biz_date <= '2015.11.04';

INSERT INTO portal.rep_revenue_market
	(hotel_group_id, 
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
	FROM portal.rep_revenue_type_history WHERE hotel_group_id = 1 AND hotel_id = 5 AND biz_date <='2015.11.04';
	
INSERT INTO portal.rep_revenue_market_history SELECT * FROM portal.rep_revenue_market WHERE hotel_group_id = 1 AND hotel_id = 5 AND biz_date <='2015.11.04';
	
DELETE FROM portal.rep_revenue_market WHERE hotel_group_id = 1 AND hotel_id = 5 AND biz_date <= '2015.11.04';

SELECT * FROM portal.rep_revenue_market WHERE hotel_group_id = 1 AND hotel_id = 5;
SELECT DISTINCT biz_date FROM portal.rep_revenue_market_history WHERE hotel_group_id = 1 AND hotel_id = 5 ;