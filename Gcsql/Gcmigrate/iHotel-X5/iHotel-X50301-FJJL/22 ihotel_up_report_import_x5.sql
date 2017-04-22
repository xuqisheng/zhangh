DELIMITER $$

DROP PROCEDURE IF EXISTS `ihotel_up_report_import_x5`$$

CREATE DEFINER=`root`@`%` PROCEDURE `ihotel_up_report_import_x5`(
	arg_hotel_group_id	INT,
	arg_hotel_id		INT
)
SQL SECURITY INVOKER
label_0:
BEGIN
	DECLARE var_biz_date DATETIME;
	DECLARE var_bfdate DATETIME;
	
	SELECT biz_date INTO var_biz_date FROM audit_flag WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;	
	SET var_bfdate = ADDDATE(var_biz_date,-1);

	-- 客房营业报表 rmsalerep  <--> rep_rmsale
	DELETE FROM rep_rmsale WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM rep_rmsale_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	
	UPDATE migrate_db.yrmsalerep_new a,up_map_code b SET a.code = b.code_new 
		WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.gkey = 't' AND a.hall = 'A'
			AND a.code = b.code_old AND b.code = 'typim';
	
	CREATE TABLE migrate_db.yrmsalerep SELECT * FROM migrate_db.yrmsalerep_new WHERE 1=2;
	
	INSERT INTO migrate_db.yrmsalerep
	SELECT DATE,gkey,hall,CODE,descript,SUM(ttl),SUM(mnt),SUM(htl),SUM(avl),SUM(vac),SUM(soldf),SUM(soldg),SUM(soldc),SUM(soldl),SUM(ent),SUM(ext),
		SUM(incomef),SUM(incomeg),SUM(incomec),SUM(incomel),SUM(gstf),SUM(gstg),SUM(gstc),SUM(gstl),SUM(soldf_r),SUM(soldf_w),SUM(soldg_r),SUM(soldg_w),SUM(soldc_r),SUM(soldc_w),SUM(arrf),SUM(arrg),SUM(arrc),SUM(arrl),SUM(arrf_r),SUM(arrf_w),SUM(arrg_r),SUM(arrg_w),SUM(arrc_r),SUM(arrc_w)
		FROM migrate_db.yrmsalerep_new GROUP BY DATE,gkey,CODE;
		
	UPDATE migrate_db.yrmsalerep SET hall = 'A' WHERE hall <> '{';
	
	INSERT INTO rep_rmsale(hotel_group_id,hotel_id,biz_date,rep_type,building,CODE,descript,descript_en,
		rooms_total,rooms_ooo,rooms_os,rooms_hse,rooms_avl,rooms_vac,sold_fit,sold_grp,sold_long,sold_ent,sold_added,
		rev_fit,rev_grp,rev_long,people_fit,people_grp,people_long)
	SELECT arg_hotel_group_id,arg_hotel_id,date,gkey,hall,code,descript,descript,
		SUM(ttl),SUM(mnt),0,SUM(htl),SUM(avl),SUM(vac),SUM(soldf),SUM(soldg+soldc),SUM(soldl),SUM(ent),SUM(ext),
		SUM(incomef),SUM(incomeg+incomec),SUM(incomel),SUM(gstf),SUM(gstg+gstc),SUM(gstl)
	FROM migrate_db.yrmsalerep WHERE date >= '2015-01-01' AND CODE NOT LIKE '%{{{%' GROUP BY date,gkey,hall,code;
	
	UPDATE rep_rmsale SET rep_type = 'B' WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND rep_type ='h';
	UPDATE rep_rmsale SET rep_type = 'F' WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND rep_type ='f';
	UPDATE rep_rmsale SET rep_type = 'T' WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND rep_type ='t';
	UPDATE rep_rmsale SET code = LTRIM(CODE) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	
	INSERT INTO rep_rmsale_history SELECT * FROM rep_rmsale WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM rep_rmsale WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date < var_bfdate;
	
	-- 境内统计报表
	DELETE FROM guest_sta_inland WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;	
	DELETE FROM guest_sta_inland_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	INSERT INTO guest_sta_inland (hotel_group_id,hotel_id,DATE,guest_class,where_from,descript,descript1,
		list_order,dtc,dgc,dmc,dtt,dgt,dmt,mtc,mgc,mmc,mtt,mgt,mmt,ytc,ygc,ymc,ytt,ygt,ymt)
	SELECT arg_hotel_group_id,arg_hotel_id,DATE,gclass,wfrom,descript,'','',dtc,dgc,0 ,dtt,dgt,0 ,mtc,mgc,0 ,mtt,mgt,0 ,ytc,ygc,0 ,ytt,ygt,0
			FROM migrate_db.ygststa1 WHERE DATE >='2015-01-01';	
	UPDATE guest_sta_inland SET guest_class = '40' WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = '41'; 
	UPDATE guest_sta_inland SET guest_class = '50' WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = '51';

	INSERT INTO guest_sta_inland_history(id,hotel_group_id,hotel_id,date,guest_class,where_from,descript,descript1,list_order,
		dtc,dgc,dmc,dtt,dgt,dmt,mtc,mgc,mmc,mtt,mgt,mmt,ytc,ygc,ymc,ytt,ygt,ymt)
	SELECT id,hotel_group_id,hotel_id,DATE,guest_class,where_from,descript,descript1,list_order,
		dtc,dgc,dmc,dtt,dgt,dmt,mtc,mgc,mmc,mtt,mgt,mmt,ytc,ygc,ymc,ytt,ygt,ymt
	FROM guest_sta_inland WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM guest_sta_inland WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND DATE < var_bfdate;
	
	-- 境外统计报表
	DELETE FROM guest_sta_overseas WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;	
	DELETE FROM guest_sta_overseas_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	INSERT INTO guest_sta_overseas(hotel_group_id,hotel_id,DATE,guest_class,nation,list_order,descript,descript1,
		sequence,dtc,dgc,dmc,dtt,dgt,dmt,mtc,mgc,mmc,mtt,mgt,mmt,ytc,ygc,ymc,ytt,ygt,ymt)	
	SELECT arg_hotel_group_id,arg_hotel_id,DATE,gclass,nation,order_,descript,'','',dtc,dgc,0 ,dtt,dgt,0 ,mtc,mgc,0 ,mtt,mgt,0 ,ytc,ygc,0 ,ytt,ygt,0
			FROM migrate_db.ygststa WHERE DATE>='2015-01-01';	
			
	-- UPDATE guest_sta_overseas a,up_map_code b SET a.nation = b.code_new WHERE a.hotel_group_id = b.hotel_group_id AND a.hotel_id = b.hotel_id 
	--	AND a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.cat = 'nation' AND b.code_old = a.nation; 

	UPDATE guest_sta_overseas a SET guest_class = '3' WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class ='4';
	INSERT INTO guest_sta_overseas_history(id,hotel_group_id,hotel_id,DATE,guest_class,nation,list_order,descript,descript1,sequence,
		dtc,dgc,dmc,dtt,dgt,dmt,mtc,mgc,mmc,mtt,mgt,mmt,ytc,ygc,ymc,ytt,ygt,ymt)
	SELECT id,hotel_group_id,hotel_id,DATE,guest_class,nation,list_order,descript,descript1,sequence,
		dtc,dgc,dmc,dtt,dgt,dmt,mtc,mgc,mmc,mtt,mgt,mmt,ytc,ygc,ymc,ytt,ygt,ymt
	FROM guest_sta_overseas WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM guest_sta_overseas WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND DATE < var_bfdate;
	
	-- 导入指标数，用于销售分析报表处理
	DELETE FROM rep_audit_index WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;	
	DELETE FROM rep_audit_index_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;

	INSERT INTO rep_audit_index(hotel_group_id,hotel_id,biz_date,audit_index,descript,descript_en,amount,amount_m,amount_y,list_order)
		SELECT arg_hotel_group_id,arg_hotel_id,date,class,descript,descript1,amount,amount_m,amount_y,sequence
			FROM migrate_db.yaudit_impdata;
			
	UPDATE rep_audit_index SET audit_index = 'rm_avl' WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND audit_index = 'avl';
	UPDATE rep_audit_index SET audit_index = 'rm_ttl' WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND audit_index = 'ttl';	
	UPDATE rep_audit_index SET audit_index = 'rm_sold' WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND audit_index = 'occ';
	UPDATE rep_audit_index SET audit_index = 'rm_oos' WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND audit_index = 'oos';
	UPDATE rep_audit_index SET audit_index = 'rm_ooo' WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND audit_index = 'ooo';
	UPDATE rep_audit_index SET audit_index = 'rm_hse' WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND audit_index = 'htl';
	UPDATE rep_audit_index SET audit_index = 'rm_com' WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND audit_index = 'free';
	
	INSERT INTO rep_audit_index_history SELECT * FROM rep_audit_index WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM rep_audit_index WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date < var_bfdate;
	
	-- 销售分析汇总表
	-- M:market市场码	S:source来源码  C:channel渠道码	R:ratecode房价码 L:restype预订类型	G:gtype大房类
	ALTER TABLE migrate_db.ymktsummaryrep ADD code_category VARCHAR(30) AFTER code;
	DELETE FROM rep_revenue_type WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;	
	DELETE FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM migrate_db.ymktsummaryrep WHERE class='G';
	DELETE FROM migrate_db.ymktsummaryrep WHERE grp='z' AND code='zzz';

	DROP INDEX ymktsummaryrep_x ON migrate_db.ymktsummaryrep;
	ALTER TABLE migrate_db.ymktsummaryrep ADD INDEX ymktsummaryrep_x(date,class,grp,code);

	UPDATE migrate_db.ymktsummaryrep a,up_map_code b SET a.code = b.code_new 
		WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.class='M'
			AND a.code = b.code_old AND b.code = 'mktcode';
			
	UPDATE migrate_db.ymktsummaryrep a,up_map_code b SET a.code = b.code_new 
		WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.class='S'
			AND a.code = b.code_old AND b.code = 'srccode';	

	UPDATE migrate_db.ymktsummaryrep a,up_map_code b SET a.code = b.code_new 
		WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.class='C'
			AND a.code = b.code_old AND b.code = 'channel';			
			
	UPDATE migrate_db.ymktsummaryrep a,up_map_code b SET a.code = b.code_new 
		WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.class='R'
			AND a.code = b.code_old AND b.code = 'ratecode';			

	UPDATE migrate_db.ymktsummaryrep a,code_base b,code_base c SET a.code_category = b.descript 
		WHERE b.hotel_group_id = c.hotel_group_id AND b.hotel_id = c.hotel_id AND b.parent_code = 'market_category' 
			AND c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = arg_hotel_id AND c.parent_code = 'market_code' 
				AND c.code_category = b.code AND a.code = c.code AND a.class='M';
	UPDATE migrate_db.ymktsummaryrep a,code_base b,code_base c SET a.code_category = b.descript 
		WHERE b.hotel_group_id = c.hotel_group_id AND b.hotel_id = c.hotel_id AND b.parent_code = 'src_cat' 
			AND c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = arg_hotel_id AND c.parent_code = 'src_code' 
				AND c.code_category = b.code AND a.code = c.code AND a.class='S';
	UPDATE migrate_db.ymktsummaryrep a,code_base b SET a.code_category = b.descript 
		WHERE b.parent_code = 'channel' AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id 
			AND a.code = b.code AND a.class='C';
	UPDATE migrate_db.ymktsummaryrep a,code_ratecode b SET a.code_category = b.descript 
		WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id 
			AND a.code = b.code AND a.class='R';			
		
	INSERT INTO rep_revenue_type(hotel_group_id,hotel_id,biz_date,code_type,code_category,code,rev_total,rev_rm,rooms_total,people_total,rooms_arr,rooms_dep,rooms_noshow,rooms_cxl,people_arr,people_dep)
	SELECT  arg_hotel_group_id,arg_hotel_id,DATE,'MARKET',code_category,code,SUM(tincome),SUM(rincome),SUM(rquan),SUM(pquan),SUM(rarr),SUM(rdep),SUM(noshow),SUM(cxl),SUM(parr),SUM(pdep)
		FROM migrate_db.ymktsummaryrep WHERE DATE >= '2015-01-01' AND class='M' GROUP BY date,class,code
	UNION ALL
	SELECT  arg_hotel_group_id,arg_hotel_id,DATE,'SOURCE',code_category,'OTH',SUM(tincome),SUM(rincome),SUM(rquan),SUM(pquan),SUM(rarr),SUM(rdep),SUM(noshow),SUM(cxl),SUM(parr),SUM(pdep)
		FROM migrate_db.ymktsummaryrep WHERE DATE >= '2015-01-01' AND class='S' GROUP BY date,class
	UNION ALL
	SELECT  arg_hotel_group_id,arg_hotel_id,DATE,'CHANNEL',code_category,code,SUM(tincome),SUM(rincome),SUM(rquan),SUM(pquan),SUM(rarr),SUM(rdep),SUM(noshow),SUM(cxl),SUM(parr),SUM(pdep)
		FROM migrate_db.ymktsummaryrep WHERE DATE >= '2015-01-01' AND class='C' GROUP BY date,class,code		
	UNION ALL
	SELECT  arg_hotel_group_id,arg_hotel_id,DATE,'RATECODE',code_category,code,SUM(tincome),SUM(rincome),SUM(rquan),SUM(pquan),SUM(rarr),SUM(rdep),SUM(noshow),SUM(cxl),SUM(parr),SUM(pdep)
		FROM migrate_db.ymktsummaryrep WHERE DATE >= '2015-01-01' AND class='R' GROUP BY date,class,code;
	
	INSERT INTO rep_revenue_type_history(hotel_group_id,hotel_id,id,biz_date,code_type,code_category,code,rev_total,rev_rm,
		rev_rm_srv,rev_rm_pkg,rev_fb,rooms_total,rooms_arr,rooms_dep,rooms_noshow,rooms_cxl,people_total,people_arr,people_dep)
	SELECT hotel_group_id,hotel_id,id,biz_date,code_type,code_category,code,rev_total,rev_rm,
		rev_rm_srv,rev_rm_pkg,rev_fb,rooms_total,rooms_arr,rooms_dep,rooms_noshow,rooms_cxl,people_total,people_arr,people_dep
	FROM rep_revenue_type WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM rep_revenue_type WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date < var_bfdate;
	
	-- 销售分析明细表 | X5 明细表只保留一段时间，导入无意
	DELETE FROM rep_revenue_type_detail WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
		
	
	-- 营业日报表
	DELETE FROM rep_jour WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM rep_jour_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	
	INSERT INTO rep_jour(hotel_group_id,hotel_id,biz_date,code,descript,descript_en,day,month,year,rebate_day,rebate_month,rebate_year,is_show,list_order)
		SELECT arg_hotel_group_id,arg_hotel_id,DATE,class,descript,descript1,day,month,year,day_rebate,month_rebate,year_rebate,'T',0 
		FROM migrate_db.yjourrep WHERE DATE >='2015-01-01';

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
	
	UPDATE rep_jour_history a,rep_jour_rule b SET a.list_order=b.list_order,a.is_show = b.is_show WHERE a.hotel_group_id = b.hotel_group_id AND a.hotel_id = b.hotel_id AND a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.code = b.code;
	UPDATE rep_jour a,rep_jour_rule b SET a.list_order=b.list_order WHERE a.hotel_group_id = b.hotel_group_id AND a.hotel_id = b.hotel_id AND a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.code = b.code;	

		
END$$

DELIMITER ;