/*
----each----:[#p@up_ihotel_audit_grp_analyse_spe]
*/
DELIMITER $$
 
DROP PROCEDURE IF EXISTS `up_ihotel_audit_grp_analyse_spe`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_audit_grp_analyse_spe`(
	IN arg_hotel_group_id	INT,
	IN arg_hotel_id			INT,
	IN arg_type				CHAR(1),
	OUT arg_ret				INT,
	OUT arg_msg				VARCHAR(255)
)
BEGIN
	-- ==============================================
	-- 酒店夜审过程- 集团分析特殊日期数据生成
	-- 作者:张惠
	-- ==============================================
	DECLARE done_cursor 	INT DEFAULT 0;
	DECLARE var_bdate		DATETIME;
	DECLARE var_year		INT;
	DECLARE var_datetype	VARCHAR(20);
	DECLARE var_datecode	VARCHAR(40);
	DECLARE var_datedesc	VARCHAR(80);
	DECLARE var_datebegin	DATETIME;
	DECLARE var_dateend		DATETIME;
	DECLARE var_extra1		VARCHAR(80);
	
	DECLARE c_cursor CURSOR FOR SELECT year,date_type,date_code,date_desc,date_begin,date_end,extra1 FROM special_date WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=0 AND date_end=var_bdate;
	
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done_cursor = 1;
	
	SET arg_ret = 1, arg_msg = 'OK';
	
	SELECT ADDDATE(biz_date,-1) INTO var_bdate FROM audit_flag WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	
	OPEN c_cursor;
	SET done_cursor = 0;
	FETCH c_cursor INTO var_year,var_datetype,var_datecode,var_datedesc,var_datebegin,var_dateend,var_extra1;		
	WHILE done_cursor = 0 DO
		BEGIN		
			IF arg_type = 'H' THEN
				BEGIN
					-- 经营情况分析表(特殊日期) grp_manage_special
					DELETE FROM grp_manage_special WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND year = var_year AND date_type=var_datetype AND date_code=var_datecode;
					
					INSERT INTO grp_manage_special(hotel_group_id,hotel_id,year,date_type,date_code,date_desc,income_rm,income_rm_plan,income_rm_per,
						income_fb,income_fb_plan,income_fb_per,income_ot,income_ot_plan,income_ot_per,income_ttl,income_ttl_plan,income_ttl_per,
						rental_rates,rental_rates_plan,rental_rates_per,room_avg,room_avg_plan,room_avg_per,rev_par,rev_par_plan,rev_par_per,date_short,room_sold,room_avl)
					SELECT hotel_group_id,hotel_id,var_year,var_datetype,var_datecode,var_datedesc,IFNULL(SUM(income_rm),0),0,0,
						IFNULL(SUM(income_pos),0),0,0,IFNULL(SUM(income_ot),0),0,0,IFNULL(SUM(income_ttl),0),0,0,0,0,0,
						0,0,0,0,0,0,var_extra1,IFNULL(SUM(room_sold),0),IFNULL(SUM(room_avl),0) FROM grp_manage_detail WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date>=var_datebegin AND biz_date<=var_dateend;
					
					UPDATE grp_manage_special SET rental_rates = ROUND(room_sold*100/room_avl,2) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND year = var_year AND date_type=var_datetype AND date_code=var_datecode;	
					UPDATE grp_manage_special SET room_avg = ROUND(income_rm/room_sold,2) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND year = var_year AND date_type=var_datetype AND date_code=var_datecode;				
					UPDATE grp_manage_special SET rev_par = ROUND(rental_rates*room_avg/100,2) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND year = var_year AND date_type=var_datetype AND date_code=var_datecode;	 
						
				
					-- 销售情况分析表(特殊日期) grp_sales_special
					DELETE FROM grp_sales_special WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND year = var_year AND date_type=var_datetype AND date_code=var_datecode; 
					INSERT INTO grp_sales_special (hotel_group_id,hotel_id,year,date_type,date_code,date_desc,date_short,type,classstr,classdesc,section,sectiondesc,income,nights,persons)		
					SELECT hotel_group_id,hotel_id,var_year,var_datetype,var_datecode,var_datedesc,var_extra1,type,classstr,classdesc,section,sectiondesc,IFNULL(SUM(income),0),IFNULL(SUM(nights),0),IFNULL(SUM(persons),0)
						FROM grp_sales_detail WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date>=var_datebegin AND biz_date<=var_dateend 
						GROUP BY type,classstr,section;
						
						
					-- 协议单位数量分析表(特殊日期) grp_company_special
					DELETE FROM grp_company_special WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND year = var_year AND date_type=var_datetype AND date_code=var_datecode; 				
					INSERT INTO grp_company_special(hotel_group_id,hotel_id,year,date_type,date_code,date_desc,sales_man,sys_class,class_descr,number_add,number_all)
					SELECT hotel_group_id,hotel_id,var_year,var_datetype,var_datecode,var_datedesc,sales_man,sys_class,class_descr,IFNULL(SUM(number_add),0),IFNULL(SUM(number_all),0)
						FROM grp_company_detail WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date>=var_datebegin AND biz_date<=var_dateend GROUP BY sales_man,sys_class;
						
					
					-- 协议单位业绩分析表(特殊日期) grp_company_perfor_special
					DELETE FROM grp_company_perfor_special WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND year = var_year AND date_type=var_datetype AND date_code=var_datecode;			
					INSERT INTO grp_company_perfor_special(hotel_group_id,hotel_id,year,date_type,date_code,date_desc,date_short,company_id,company_class,company_name,nights,persons,room_avg,room_charge,pos_charge,ot_charge,ttl_charge,avg_charge)
					SELECT hotel_group_id,hotel_id,var_year,var_datetype,var_datecode,var_datedesc,var_extra1,company_id,company_class,company_name,IFNULL(SUM(nights),0),IFNULL(SUM(persons),0),IF(IFNULL(SUM(nights),0)<>0,ROUND(IFNULL(SUM(room_charge),0)/IFNULL(SUM(nights),0),2),0),IFNULL(SUM(room_charge),0),IFNULL(SUM(pos_charge),0),IFNULL(SUM(ot_charge),0),IFNULL(SUM(ttl_charge),0),IF(IFNULL(SUM(nights),0)<>0,ROUND(IFNULL(SUM(ttl_charge),0)/IFNULL(SUM(persons),0),2),0) 
						FROM grp_company_perfor_detail WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date>=var_datebegin AND biz_date<=var_dateend GROUP BY company_id,company_class;	
				END;
			END IF;
					
			IF arg_type = 'G' THEN
				BEGIN
					-- 经营情况分析表(特殊日期) grp_manage_special
					DELETE FROM grp_manage_special WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND year = var_year AND date_type=var_datetype AND date_code=var_datecode;
					
					IF EXISTS(SELECT 1 FROM grp_manage_special WHERE hotel_group_id = arg_hotel_group_id AND year = var_year AND date_type=var_datetype AND date_code=var_datecode) THEN
						INSERT INTO grp_manage_special(hotel_group_id,hotel_id,year,date_type,date_code,date_desc,income_rm,income_rm_plan,income_rm_per,
							income_fb,income_fb_plan,income_fb_per,income_ot,income_ot_plan,income_ot_per,income_ttl,income_ttl_plan,income_ttl_per,
							rental_rates,rental_rates_plan,rental_rates_per,room_avg,room_avg_plan,room_avg_per,rev_par,rev_par_plan,rev_par_per,date_short,room_sold,room_avl)
						SELECT arg_hotel_group_id,arg_hotel_id,year,date_type,date_code,date_desc,IFNULL(SUM(income_rm),0),IFNULL(SUM(income_rm_plan),0),0,
							IFNULL(SUM(income_fb),0),IFNULL(SUM(income_fb_plan),0),0,IFNULL(SUM(income_ot),0),IFNULL(SUM(income_ot_plan),0),0,IFNULL(SUM(income_ttl),0),IFNULL(SUM(income_ttl_plan),0),0,
							0,0,0,0,0,0,0,0,0,date_short,IFNULL(SUM(room_sold),0),IFNULL(SUM(room_avl),0)
							FROM grp_manage_special WHERE hotel_group_id = arg_hotel_group_id AND year = var_year AND date_type=var_datetype AND date_code=var_datecode;
					END IF;
					
					UPDATE grp_manage_special SET rental_rates = ROUND(room_sold*100/room_avl,2) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND year = var_year AND date_type=var_datetype AND date_code=var_datecode;	
					UPDATE grp_manage_special SET room_avg = ROUND(income_rm/room_sold,2) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND year = var_year AND date_type=var_datetype AND date_code=var_datecode;				
					UPDATE grp_manage_special SET rev_par = ROUND(rental_rates*room_avg/100,2) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND year = var_year AND date_type=var_datetype AND date_code=var_datecode;	 
									
					-- 销售情况分析表(特殊日期) grp_sales_special
					DELETE FROM grp_sales_special WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND year = var_year AND date_type=var_datetype AND date_code=var_datecode; 
					IF EXISTS(SELECT 1 FROM grp_sales_special WHERE hotel_group_id = arg_hotel_group_id AND year = var_year AND date_type=var_datetype AND date_code=var_datecode) THEN
						INSERT INTO grp_sales_special (hotel_group_id,hotel_id,year,date_type,date_code,date_desc,date_short,type,classstr,classdesc,section,sectiondesc,income,nights,persons)		
						SELECT arg_hotel_group_id,arg_hotel_id,year,date_type,date_code,date_desc,date_short,type,classstr,classdesc,section,sectiondesc,IFNULL(SUM(income),0),IFNULL(SUM(nights),0),IFNULL(SUM(persons),0)
						FROM grp_sales_special WHERE hotel_group_id = arg_hotel_group_id AND year = var_year AND date_type=var_datetype AND date_code=var_datecode GROUP BY type,classstr,section;					
					END IF;	
					-- 协议单位数量分析表(特殊日期) grp_company_special
					DELETE FROM grp_company_special WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND year = var_year AND date_type=var_datetype AND date_code=var_datecode; 				
					IF EXISTS(SELECT 1 FROM grp_company_special WHERE hotel_group_id = arg_hotel_group_id AND year = var_year AND date_type=var_datetype AND date_code=var_datecode) THEN
						INSERT INTO grp_company_special(hotel_group_id,hotel_id,year,date_type,date_code,date_desc,sales_man,sys_class,class_descr,number_add,number_all)
						SELECT arg_hotel_group_id,arg_hotel_id,year,date_type,date_code,date_desc,sales_man,sys_class,class_descr,IFNULL(SUM(number_add),0),IFNULL(SUM(number_all),0)
						FROM grp_company_special WHERE hotel_group_id = arg_hotel_group_id AND year = var_year AND date_type=var_datetype AND date_code=var_datecode GROUP BY sales_man,sys_class;
					END IF;					
					-- 协议单位业绩分析表(特殊日期) grp_company_perfor_special
					DELETE FROM grp_company_perfor_special WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND year = var_year AND date_type=var_datetype AND date_code=var_datecode;			
					IF EXISTS(SELECT 1 FROM grp_company_perfor_special WHERE hotel_group_id = arg_hotel_group_id AND year = var_year AND date_type=var_datetype AND date_code=var_datecode) THEN
						INSERT INTO grp_company_perfor_special(hotel_group_id,hotel_id,year,date_type,date_code,date_desc,date_short,company_id,company_class,company_name,nights,persons,room_avg,room_charge,pos_charge,ot_charge,ttl_charge,avg_charge)
						SELECT arg_hotel_group_id,arg_hotel_id,year,date_type,date_code,date_desc,date_short,company_id,company_class,company_name,IFNULL(SUM(nights),0),IFNULL(SUM(persons),0),IF(IFNULL(SUM(nights),0)<>0,ROUND(IFNULL(SUM(room_charge),0)/IFNULL(SUM(nights),0),2),0),IFNULL(SUM(room_charge),0),IFNULL(SUM(pos_charge),0),IFNULL(SUM(ot_charge),0),IFNULL(SUM(ttl_charge),0),IF(IFNULL(SUM(nights),0)<>0,ROUND(IFNULL(SUM(ttl_charge),0)/IFNULL(SUM(persons),0),2),0)
						FROM grp_company_perfor_special WHERE hotel_group_id = arg_hotel_group_id AND year = var_year AND date_type=var_datetype AND date_code=var_datecode GROUP BY company_id,company_class;
					END IF;	
				END;
			END IF;
			
		SET done_cursor = 0;
		FETCH c_cursor INTO var_year,var_datetype,var_datecode,var_datedesc,var_datebegin,var_dateend,var_extra1;			
		END;
	END WHILE;
	CLOSE c_cursor;	
	
	
END$$

DELIMITER ;