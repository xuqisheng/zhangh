/*
----each----:[#p@up_ihotel_audit_grp_analyse]
*/
DELIMITER $$
 
DROP PROCEDURE IF EXISTS `up_ihotel_audit_grp_analyse`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_audit_grp_analyse`(
	IN arg_hotel_group_id	INT,
	IN arg_hotel_id			INT,
	IN arg_type				CHAR(1),	-- H:酒店	G:集团
	OUT arg_ret				INT,
	OUT arg_msg				VARCHAR(255)
)
BEGIN
	-- ==============================================
	-- 酒店夜审过程- 集团分析相关数据生成
	-- 作者:张惠
	-- ==============================================
	DECLARE var_bdate		DATETIME;
	DECLARE var_room_avl	DECIMAL(12,2);
	DECLARE var_room_sold	DECIMAL(12,2);
	
	DECLARE var_rev_ttl		DECIMAL(12,2);
	DECLARE var_rev_rm		DECIMAL(12,2);
	DECLARE var_rev_fb		DECIMAL(12,2);
	DECLARE var_rev_ot		DECIMAL(12,2);
	
	DECLARE var_hotel_code	VARCHAR(20);
	
	SET arg_ret = 1, arg_msg = 'OK';
	
	SELECT ADDDATE(biz_date,-1) INTO var_bdate FROM audit_flag WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	
	SELECT code INTO var_hotel_code FROM hotel WHERE hotel_group_id = arg_hotel_group_id AND id = arg_hotel_id;
	
	IF arg_type = 'H' THEN
		BEGIN
			-- 经营情况分析表 grp_manage_detail
			DELETE FROM grp_manage_detail WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate;
			

			SELECT day INTO var_room_avl FROM rep_jour_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND code='rm_avl';
			SELECT day INTO var_room_sold FROM rep_jour_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND code='rm_sold';			
	
			SELECT day INTO var_rev_ttl FROM rep_jour_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND code='rev_total';			
			SELECT day INTO var_rev_rm FROM rep_jour_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND code='rev_rm';
			SELECT day INTO var_rev_fb FROM rep_jour_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND code='rev_fb';		

			/*
			SELECT SUM(rooms_total - rooms_ooo) INTO var_room_avl FROM rep_rmsale_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = arg_date_begin AND rep_type='B';
			SELECT SUM(rooms_total) INTO var_room_sold FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = arg_date_begin AND code_type='MARKET' AND code NOT IN ('HSE','COM');
			
			INSERT INTO grp_manage_detail(hotel_group_id,hotel_id,biz_date,income_rm,income_pos,income_ot,income_ttl,rental_rates,room_avg,rev_par,room_avl,room_sold)
			SELECT hotel_group_id,hotel_id,biz_date,SUM(rev_rm+rev_rm_srv+rev_rm_pkg),SUM(rev_fb),SUM(rev_mt+rev_en+rev_sp+rev_ot),SUM(rev_total),0,0,0,var_room_avl,var_room_sold
				FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = arg_date_begin AND code_type='MARKET';
			*/			
	
			SET var_rev_ot = var_rev_ttl - var_rev_rm - var_rev_fb;
			
			INSERT INTO grp_manage_detail(hotel_group_id,hotel_id,biz_date,income_rm,income_pos,income_ot,income_ttl,rental_rates,room_avg,rev_par,room_avl,room_sold)
			SELECT arg_hotel_group_id,arg_hotel_id,var_bdate,var_rev_rm,var_rev_fb,var_rev_ot,var_rev_ttl,0,0,0,var_room_avl,var_room_sold;
				
			UPDATE grp_manage_detail SET rental_rates = ROUND(room_sold*100/room_avl,2) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND room_avl<>0;
			UPDATE grp_manage_detail SET room_avg = ROUND(income_rm/room_sold,2) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND room_sold<>0;	
			UPDATE grp_manage_detail SET rev_par = ROUND(rental_rates*room_avg/100,2) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate;
			UPDATE grp_manage_detail SET income_ot = income_ttl - income_rm - income_pos WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate;			
					
			-- 销售情况分析表 grp_sales_detail
			DELETE FROM grp_sales_detail WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate;
			
			INSERT INTO grp_sales_detail(hotel_group_id,hotel_id,biz_date,type,classstr,classdesc,section,sectiondesc,income,nights,persons)
			SELECT hotel_group_id,hotel_id,biz_date,code_type,'','',code,'',rev_rm+rev_rm_srv+rev_rm_pkg,rooms_total,people_total FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate;
			
			DELETE FROM grp_sales_detail WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND income=0 AND nights=0 AND persons=0;
			
			-- 市场码更新
			UPDATE grp_sales_detail a,code_base b SET a.sectiondesc=b.descript,a.classstr=b.code_category WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.biz_date = var_bdate AND a.type='MARKET' AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.parent_code ='market_code' AND a.section=b.code;	
			UPDATE grp_sales_detail a,code_base b SET a.classdesc=b.descript WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.biz_date = var_bdate AND a.type='MARKET' AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = 0 AND b.parent_code ='market_category' AND a.classstr=b.code;
			
			-- 来源码更新
			UPDATE grp_sales_detail a,code_base b SET a.sectiondesc=b.descript,a.classstr=b.code_category WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.biz_date = var_bdate AND a.type='SOURCE' AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.parent_code ='src_code' AND a.section=b.code;	
			UPDATE grp_sales_detail a,code_base b SET a.classdesc=b.descript WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.biz_date = var_bdate AND a.type='SOURCE' AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = 0 AND b.parent_code ='src_cat' AND a.classstr=b.code;	
			
			-- 渠道码更新
			UPDATE grp_sales_detail a,code_base b SET a.sectiondesc=b.descript WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.biz_date = var_bdate AND a.type='CHANNEL' AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.parent_code ='channel' AND a.section=b.code;
			UPDATE grp_sales_detail SET classstr=section,classdesc=sectiondesc WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND type='CHANNEL';
			
			-- 预订类型更新
			UPDATE grp_sales_detail a,code_rsv_type b SET a.sectiondesc=b.descript WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.biz_date = var_bdate AND a.type='RESTYPE' AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.section=b.code;
			UPDATE grp_sales_detail SET classstr=section,classdesc=sectiondesc WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND type='RESTYPE';
			
			-- 房价码更新
			UPDATE grp_sales_detail a,code_ratecode b SET a.sectiondesc=b.descript,a.classstr=b.category WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.biz_date = var_bdate AND a.type='RATECODE' AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.section=b.code;	
			UPDATE grp_sales_detail a,code_base b SET a.classdesc=b.descript WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.biz_date = var_bdate AND a.type='RATECODE' AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = 0 AND b.parent_code ='ratecode_categroy' AND a.classstr=b.code;	

			UPDATE grp_sales_detail SET type='CHANEL' WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND type='CHANNEL';
			UPDATE grp_sales_detail SET type='RSV_TYPE' WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND type='RESTYPE';				
			
			-- 挂账情况分析表 grp_suspend_detail
			DELETE FROM grp_suspend_detail WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate;	
			
			INSERT INTO grp_suspend_detail(hotel_group_id,hotel_id,biz_date,ar_amount,s_amount,t_amount)
				SELECT arg_hotel_group_id,arg_hotel_id,var_bdate,(SELECT SUM(charge-pay) FROM ar_master_till WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id),IFNULL(SUM(charge-pay),0),0
					FROM master_base_till WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND sta='S';
			UPDATE grp_suspend_detail SET t_amount = ar_amount + s_amount WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate;
			
			
			-- 协议单位数量分析表 grp_company_detail
			DELETE FROM grp_company_detail WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate;
			
			INSERT INTO grp_company_detail(hotel_group_id,hotel_id,biz_date,sales_man,sys_class,class_descr,number_add,number_all)
				SELECT hotel_group_id,hotel_id,var_bdate,saleman,sys_cat,'',0,COUNT(1) FROM company_type WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND sta<>'X' GROUP BY saleman,sys_cat;
			UPDATE grp_company_detail SET class_descr='协议单位' WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND sys_class='C';
			UPDATE grp_company_detail SET class_descr='旅行社' WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND sys_class='A';
			UPDATE grp_company_detail SET class_descr='订房中心' WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND sys_class='S';
			
			UPDATE grp_company_detail a SET a.number_add=IFNULL((SELECT COUNT(1) FROM company_type b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.sys_class=b.sys_cat AND a.sales_man=b.saleman AND DATE(create_datetime)=var_bdate GROUP BY b.saleman,b.sys_cat),0) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate;
			
			
			-- 协议单位数量分析表
			DELETE FROM grp_company_perfor_detail WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate;
			INSERT INTO grp_company_perfor_detail(hotel_group_id,hotel_id,biz_date,company_id,company_class,company_name,nights,persons,room_avg,room_charge,pos_charge,ot_charge,ttl_charge,avg_charge)
			SELECT hotel_group_id,hotel_id,biz_date,company_id,'C','',SUM(nights2),SUM(IF(nights<>0,adult,0)),0,SUM(production_rm),SUM(production_fb),SUM(production_mt+production_en+production_sp+production_ot),SUM(production_ttl),0 FROM production_detail WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND master_type IN ('master','pos') AND company_id<>0 GROUP BY company_id
			UNION ALL
			SELECT hotel_group_id,hotel_id,biz_date,agent_id,'A','',SUM(nights2),SUM(IF(nights<>0,adult,0)),0,SUM(production_rm),SUM(production_fb),SUM(production_mt+production_en+production_sp+production_ot),SUM(production_ttl),0 FROM production_detail WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND master_type IN ('master','pos') AND agent_id<>0 GROUP BY agent_id
			UNION ALL
			SELECT hotel_group_id,hotel_id,biz_date,source_id,'S','',SUM(nights2),SUM(IF(nights<>0,adult,0)),0,SUM(production_rm),SUM(production_fb),SUM(production_mt+production_en+production_sp+production_ot),SUM(production_ttl),0 FROM production_detail WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND master_type IN ('master','pos') AND source_id<>0 GROUP BY source_id;
			
			DELETE FROM grp_company_perfor_detail WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND nights=0 AND persons=0 AND room_charge=0 AND pos_charge=0 AND ot_charge=0 AND ttl_charge=0;
			UPDATE grp_company_perfor_detail a,company_base b SET a.company_name=b.name WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND b.hotel_group_id=arg_hotel_group_id AND a.biz_date=var_bdate AND a.company_id=b.id;
			
			UPDATE grp_company_perfor_detail SET room_avg = ROUND(room_charge/nights,2) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND nights<>0;
			UPDATE grp_company_perfor_detail SET avg_charge = ROUND(ttl_charge/persons,2) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate AND persons<>0;
			
			
			-- 协议单位业绩分析表 grp_company_perfor_year
			DELETE FROM grp_company_perfor_year WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND year=YEAR(var_bdate);
			INSERT INTO grp_company_perfor_year (hotel_group_id,hotel_id,company_id,company_class,company_name,year,index_code,month01,month02,month03,month04,month05,month06,month07,month08,month09,month10,month11,month12,month99)
			SELECT hotel_group_id,hotel_id,code,grp,'',year,'1',month01,month02,month03,month04,month05,month06,month07,month08,month09,month10,month11,month12,month99
			FROM statistic_y WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND year=YEAR(var_bdate) AND grp IN ('C','A','S') AND cat='yielddb_rooms_nights'
			UNION ALL
			SELECT hotel_group_id,hotel_id,code,grp,'',year,'2',month01,month02,month03,month04,month05,month06,month07,month08,month09,month10,month11,month12,month99
			FROM statistic_y WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND year=YEAR(var_bdate) AND grp IN ('C','A','S') AND cat='yielddb_persons_adult'		
			UNION ALL
			SELECT hotel_group_id,hotel_id,code,grp,'',year,'3',SUM(month01),SUM(month02),SUM(month03),SUM(month04),SUM(month05),SUM(month06),SUM(month07),SUM(month08),SUM(month09),SUM(month10),SUM(month11),SUM(month12),SUM(month99)
			FROM statistic_y WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND year=YEAR(var_bdate) AND grp IN ('C','A','S') AND cat LIKE  'yielddb_revenus%' GROUP BY grp,code;
			
			UPDATE grp_company_perfor_year a,company_base b SET a.company_name=b.name WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = 0 AND a.company_id=b.id;
			
		END;
	END IF;
	
	IF arg_type = 'G' THEN
		BEGIN
		
			DELETE FROM grp_manage_detail WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate;
			INSERT INTO grp_manage_detail(hotel_group_id,hotel_id,biz_date,income_rm,income_pos,income_ot,income_ttl,rental_rates,room_avg,rev_par,room_avl,room_sold)
			SELECT hotel_group_id,arg_hotel_id,biz_date,SUM(income_rm),SUM(income_pos),SUM(income_ot),SUM(income_ttl),ROUND(SUM(room_sold)*100/SUM(room_avl),2),ROUND(SUM(income_rm)/SUM(room_sold),2),ROUND(SUM(income_rm)/SUM(room_avl),2),SUM(room_avl),SUM(room_sold) FROM grp_manage_detail WHERE hotel_group_id = arg_hotel_group_id AND biz_date = var_bdate GROUP BY biz_date;
				
			DELETE FROM grp_sales_detail WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate;			
			INSERT INTO grp_sales_detail(hotel_group_id,hotel_id,biz_date,type,classstr,classdesc,section,sectiondesc,income,nights,persons)
			SELECT hotel_group_id,arg_hotel_id,biz_date,type,classstr,classdesc,section,sectiondesc,SUM(income),SUM(nights),SUM(persons) FROM grp_sales_detail WHERE hotel_group_id = arg_hotel_group_id AND biz_date = var_bdate GROUP BY type,classstr,biz_date;
			
			DELETE FROM grp_suspend_detail WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bdate;			
			INSERT INTO grp_suspend_detail(hotel_group_id,hotel_id,biz_date,ar_amount,s_amount,t_amount)
			SELECT hotel_group_id,arg_hotel_id,biz_date,SUM(ar_amount),SUM(s_amount),SUM(t_amount) FROM grp_suspend_detail WHERE hotel_group_id = arg_hotel_group_id AND biz_date = var_bdate GROUP BY biz_date;
			
			DELETE FROM grp_company_detail WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date=var_bdate;			
			INSERT INTO grp_company_detail(hotel_group_id,hotel_id,biz_date,sales_man,sys_class,class_descr,number_add,number_all)
			SELECT hotel_group_id,arg_hotel_id,biz_date,sales_man,sys_class,class_descr,SUM(number_add),SUM(number_all) FROM grp_company_detail WHERE hotel_group_id = arg_hotel_group_id AND biz_date=var_bdate GROUP BY sales_man,sys_class;

			DELETE FROM grp_company_perfor_detail WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date=var_bdate;
			INSERT INTO grp_company_perfor_detail(hotel_group_id,hotel_id,biz_date,company_id,company_class,company_name,nights,persons,room_avg,room_charge,pos_charge,ot_charge,ttl_charge,avg_charge)
			SELECT hotel_group_id,arg_hotel_id,biz_date,company_id,company_class,company_name,SUM(nights),SUM(persons),ROUND(SUM(room_charge)/SUM(nights),2),SUM(room_charge),SUM(pos_charge),SUM(ot_charge),SUM(ttl_charge),ROUND(SUM(ttl_charge)/SUM(persons),2) FROM grp_company_perfor_detail WHERE hotel_group_id = arg_hotel_group_id AND biz_date=var_bdate GROUP BY company_id,company_class;
			
			DELETE FROM grp_company_perfor_year WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND year=YEAR(var_bdate);
			INSERT INTO grp_company_perfor_year (hotel_group_id,hotel_id,company_id,company_class,company_name,year,index_code,month01,month02,month03,month04,month05,month06,month07,month08,month09,month10,month11,month12,month99)
			SELECT hotel_group_id,arg_hotel_id,company_id,company_class,company_name,year,index_code,SUM(month01),SUM(month02),SUM(month03),SUM(month04),SUM(month05),SUM(month06),SUM(month07),SUM(month08),SUM(month09),SUM(month10),SUM(month11),SUM(month12),SUM(month99) FROM grp_company_perfor_year 
			WHERE hotel_group_id = arg_hotel_group_id AND year=YEAR(var_bdate) GROUP BY index_code,company_id,company_class,year;
			
		END;
	END IF;
	
END$$

DELIMITER ;