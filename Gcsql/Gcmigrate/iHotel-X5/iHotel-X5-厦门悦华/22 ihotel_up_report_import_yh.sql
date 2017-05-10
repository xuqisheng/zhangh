DELIMITER $$

DROP PROCEDURE IF EXISTS `ihotel_up_report_import_x5`$$

CREATE DEFINER=`root`@`%` PROCEDURE `ihotel_up_report_import_x5`(
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

	-- 客房营业报表 rmsalerep  <--> rep_rmsale
	DELETE FROM rep_rmsale WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM rep_rmsale_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	
	CREATE TABLE migrate_db.yrmsalerep_narada SELECT * FROM migrate_db.yrmsalerep_new WHERE 1=2;
	
	INSERT INTO migrate_db.yrmsalerep_narada
	SELECT DATE,gkey,hall,CODE,descript,SUM(ttl),SUM(mnt),SUM(htl),SUM(avl),SUM(vac),SUM(soldf),SUM(soldg),SUM(soldc),SUM(soldl),SUM(ent),SUM(ext),
		SUM(incomef),SUM(incomeg),SUM(incomec),SUM(incomel),SUM(gstf),SUM(gstg),SUM(gstc),SUM(gstl),SUM(soldf_r),SUM(soldf_w),SUM(soldg_r),SUM(soldg_w),SUM(soldc_r),SUM(soldc_w),SUM(arrf),SUM(arrg),SUM(arrc),SUM(arrl),SUM(arrf_r),SUM(arrf_w),SUM(arrg_r),SUM(arrg_w),SUM(arrc_r),SUM(arrc_w)
		FROM migrate_db.yrmsalerep GROUP BY DATE,gkey,CODE;
		
	UPDATE migrate_db.yrmsalerep_narada SET hall = 'A' WHERE hall <> '{';
	
	INSERT INTO rep_rmsale(hotel_group_id,hotel_id,biz_date,rep_type,building,CODE,descript,descript_en,
		rooms_total,rooms_ooo,rooms_os,rooms_hse,rooms_avl,rooms_vac,sold_fit,sold_grp,sold_long,sold_ent,sold_added,
		rev_fit,rev_grp,rev_long,people_fit,people_grp,people_long)
	SELECT arg_hotel_group_id,arg_hotel_id,date,gkey,hall,code,descript,descript,
		SUM(ttl),SUM(mnt),0,SUM(htl),SUM(avl),SUM(vac),SUM(soldf),SUM(soldg+soldc),SUM(soldl),SUM(ent),SUM(ext),
		SUM(incomef),SUM(incomeg+incomec),SUM(incomel),SUM(gstf),SUM(gstg+gstc),SUM(gstl)
	FROM migrate_db.yrmsalerep WHERE date >= '2012-01-01' AND CODE NOT LIKE '%{{{%' GROUP BY date,gkey,hall,code;
	
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
			FROM migrate_db.ygststa1 WHERE DATE >='2012-01-01';	
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
			FROM migrate_db.ygststa WHERE DATE>='2012-01-01';	
			
	UPDATE guest_sta_overseas a,up_map_code b SET a.nation = b.code_new WHERE a.hotel_group_id = b.hotel_group_id AND a.hotel_id = b.hotel_id 
		AND a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.cat = 'nation' AND b.code_old = a.nation; 

	UPDATE guest_sta_overseas a SET guest_class = '3' WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class ='4';
	INSERT INTO guest_sta_overseas_history(id,hotel_group_id,hotel_id,DATE,guest_class,nation,list_order,descript,descript1,sequence,
		dtc,dgc,dmc,dtt,dgt,dmt,mtc,mgc,mmc,mtt,mgt,mmt,ytc,ygc,ymc,ytt,ygt,ymt)
	SELECT id,hotel_group_id,hotel_id,DATE,guest_class,nation,list_order,descript,descript1,sequence,
		dtc,dgc,dmc,dtt,dgt,dmt,mtc,mgc,mmc,mtt,mgt,mmt,ytc,ygc,ymc,ytt,ygt,ymt
	FROM guest_sta_overseas WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM guest_sta_overseas WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND DATE < var_bfdate;
	
	-- 销售分析汇总表
	-- M:market市场码	S:source来源码  C:channel渠道码	R:ratecode房价码 L:restype预订类型	G:gtype大房类
	ALTER TABLE migrate_db.ymktsummaryrep ADD code_category VARCHAR(30) AFTER code;
	DELETE FROM rep_revenue_type WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;	
	DELETE FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM migrate_db.ymktsummaryrep WHERE class='G';
	DELETE FROM migrate_db.ymktsummaryrep WHERE grp='z' AND code='zzz';

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
		FROM migrate_db.ymktsummaryrep WHERE DATE >= '2012-01-01' AND class='M' GROUP BY date,class,code
	UNION ALL
	SELECT  arg_hotel_group_id,arg_hotel_id,DATE,'SOURCE',code_category,'OTH',SUM(tincome),SUM(rincome),SUM(rquan),SUM(pquan),SUM(rarr),SUM(rdep),SUM(noshow),SUM(cxl),SUM(parr),SUM(pdep)
		FROM migrate_db.ymktsummaryrep WHERE DATE >= '2012-01-01' AND class='S' GROUP BY date,class
	UNION ALL
	SELECT  arg_hotel_group_id,arg_hotel_id,DATE,'CHANNEL',code_category,code,SUM(tincome),SUM(rincome),SUM(rquan),SUM(pquan),SUM(rarr),SUM(rdep),SUM(noshow),SUM(cxl),SUM(parr),SUM(pdep)
		FROM migrate_db.ymktsummaryrep WHERE DATE >= '2012-01-01' AND class='C' GROUP BY date,class,code		
	UNION ALL
	SELECT  arg_hotel_group_id,arg_hotel_id,DATE,'RATECODE',code_category,code,SUM(tincome),SUM(rincome),SUM(rquan),SUM(pquan),SUM(rarr),SUM(rdep),SUM(noshow),SUM(cxl),SUM(parr),SUM(pdep)
		FROM migrate_db.ymktsummaryrep WHERE DATE >= '2012-01-01' AND class='R' GROUP BY date,class,code;
	
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
		SELECT arg_hotel_group_id,arg_hotel_id,DATE,class,descript,descript1,day,month,year,day_rebate,rebate_month,rebate_year,'T',0 
		FROM migrate_db.yjourrep WHERE DATE >='2012-01-01';

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
	
	
	-- 导入前代码更新
	UPDATE migrate_db.yjierep SET class = '998' WHERE class = '090' AND mode='E';
	-- 稽核底表 rep_jie	
	DELETE FROM rep_jie WHERE hotel_group_id = -1 AND hotel_id = -1;
	INSERT INTO rep_jie(hotel_group_id,hotel_id,biz_date,orderno,itemno,modeno,classno,descript,descript1,rectype,toop,toclass,sequence,
		day01,day02,day03,day04,day05,day06,day07,day08,day09,day99,month01,month02,month03,month04,month05,month06,month07,month08,month09,month99)
	SELECT -1,-1,var_bfdate,orderno,itemno,modeno,classno,descript,descript1,rectype,toop,toclass,sequence,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		FROM rep_jie WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id ORDER BY classno;	
	
	DELETE FROM rep_jie WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM rep_jie_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	
	INSERT INTO rep_jie_history(hotel_group_id,hotel_id,biz_date,orderno,itemno,modeno,classno,descript,descript1,rectype,toop,toclass,sequence,
		day01,day02,day03,day04,day05,day06,day07,day08,day09,day99,month01,month02,month03,month04,month05,month06,month07,month08,month09,month99)
	SELECT arg_hotel_group_id,arg_hotel_id,DATE,'F',NULL,MODE,class,descript,descript,rectype,toop,toclass,NULL,
		day01,day02,day03,day04,day05,day06,day07,day08,day09,day99,month01,month02,month03,month04,month05,month06,month07,month08,month09,month99
	FROM migrate_db.yjierep WHERE DATE >= '2012-01-01';	

	INSERT INTO rep_jie(hotel_group_id,hotel_id,biz_date,orderno,itemno,modeno,classno,descript,descript1,rectype,toop,toclass,sequence,
		day01,day02,day03,day04,day05,day06,day07,day08,day09,day99,month01,month02,month03,month04,month05,month06,month07,month08,month09,month99)
	SELECT arg_hotel_group_id,arg_hotel_id,biz_date,orderno,itemno,modeno,classno,descript,descript1,rectype,toop,toclass,sequence,
		day01,day02,day03,day04,day05,day06,day07,day08,day09,day99,month01,month02,month03,month04,month05,month06,month07,month08,month09,month99
		FROM rep_jie WHERE hotel_group_id = -1 AND hotel_id = -1 ORDER BY classno;

	UPDATE rep_jie a,rep_jie_history b SET a.day01 = b.day01,a.day02 = b.day02,a.day03 = b.day03,a.day04 = b.day04,a.day05 = b.day05,
		a.day06 = b.day06,a.day07 = b.day07,a.day08 = b.day08,a.day09 = b.day09,a.day99 = b.day99,a.month01 = b.month01,a.month02 = b.month02,a.month03 = b.month03,a.month04 = b.month04,a.month05 = b.month05,
		a.month06 = b.month06,a.month07 = b.month07,a.month08 = b.month08,a.month09 = b.month09,a.month99 = b.month99
	WHERE a.hotel_group_id = b.hotel_group_id AND a.hotel_id = b.hotel_id AND a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id 
	AND a.biz_date = b.biz_date AND a.biz_date = var_bfdate AND a.classno = b.classno;
		
	DELETE FROM rep_jie_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bfdate;
			
	INSERT INTO rep_jie_history SELECT * FROM rep_jie WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM rep_jie WHERE hotel_group_id = -1 AND hotel_id = -1;
	
	-- rep_dai
	DELETE FROM rep_dai WHERE hotel_group_id = -1 AND hotel_id = -1;
	INSERT INTO rep_dai(hotel_group_id,hotel_id,biz_date,orderno,itemno,modeno,classno,descript,descript1,sequence,
		credit01,credit02,credit03,credit04,credit05,credit06,credit07,sumcre,last_bl,debit,credit,till_bl,
		credit01m,credit02m,credit03m,credit04m,credit05m,credit06m,credit07m,sumcrem,last_blm,debitm,creditm,till_blm)
	SELECT -1,-1,var_bfdate,'',0,'',classno,descript,descript1,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	FROM rep_dai WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id ORDER BY classno;
	
	DELETE FROM rep_dai WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM rep_dai_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	
	INSERT INTO rep_dai_history(hotel_group_id,hotel_id,biz_date,orderno,itemno,modeno,classno,descript,descript1,sequence,
	credit01,credit02,credit03,credit04,credit05,credit06,credit07,sumcre,last_bl,debit,credit,till_bl,
	credit01m,credit02m,credit03m,credit04m,credit05m,credit06m,credit07m,sumcrem,last_blm,debitm,creditm,till_blm)
	SELECT arg_hotel_group_id,arg_hotel_id,DATE,'',itemno,MODE,'01020','   前 厅','  Front Office',sequence,
		SUM(credit01),SUM(credit02),SUM(credit03),SUM(credit04),SUM(credit05),SUM(credit06),SUM(credit07),SUM(sumcre),SUM(last_bl),SUM(debit),SUM(credit),SUM(till_bl),
		SUM(credit01m),SUM(credit02m),SUM(credit03m),SUM(credit04m),SUM(credit05m),SUM(credit06m),SUM(credit07m),SUM(sumcrem),SUM(last_blm),SUM(debitm),SUM(creditm),SUM(till_blm)
	 FROM migrate_db.ydairep WHERE DATE >= '2012-01-01' AND class IN ('01020','0130','01998') GROUP BY DATE ORDER BY date,class;	
 
	INSERT INTO rep_dai_history(hotel_group_id,hotel_id,biz_date,orderno,itemno,modeno,classno,descript,descript1,sequence,
	credit01,credit02,credit03,credit04,credit05,credit06,credit07,sumcre,last_bl,debit,credit,till_bl,
	credit01m,credit02m,credit03m,credit04m,credit05m,credit06m,credit07m,sumcrem,last_blm,debitm,creditm,till_blm)
	SELECT arg_hotel_group_id,arg_hotel_id,DATE,order_,itemno,MODE,'01998',descript,descript1,sequence,
		credit01,credit02,credit03,credit04,credit05,credit06,credit07,sumcre,last_bl,debit,credit,till_bl,
		credit01m,credit02m,credit03m,credit04m,credit05m,credit06m,credit07m,sumcrem,last_blm,debitm,creditm,till_blm
	 FROM migrate_db.ydairep WHERE DATE >= '2012-01-01' AND class='0120' ORDER BY date,class;
	
	INSERT INTO rep_dai_history(hotel_group_id,hotel_id,biz_date,orderno,itemno,modeno,classno,descript,descript1,sequence,
	credit01,credit02,credit03,credit04,credit05,credit06,credit07,sumcre,last_bl,debit,credit,till_bl,
	credit01m,credit02m,credit03m,credit04m,credit05m,credit06m,credit07m,sumcrem,last_blm,debitm,creditm,till_blm)
	SELECT arg_hotel_group_id,arg_hotel_id,DATE,order_,itemno,MODE,class,descript,descript,sequence,
		credit01,credit02,credit03,credit04,credit05,credit06,credit07,sumcre,last_bl,debit,credit,till_bl,
		credit01m,credit02m,credit03m,credit04m,credit05m,credit06m,credit07m,sumcrem,last_blm,debitm,creditm,till_blm
	 FROM migrate_db.ydairep WHERE DATE >= '2012-01-01' AND class NOT IN ('01020','0130','01998','0120') ORDER BY date,class;
	 
	INSERT INTO rep_dai(hotel_group_id,hotel_id,biz_date,orderno,itemno,modeno,classno,descript,descript1,sequence,
		credit01,credit02,credit03,credit04,credit05,credit06,credit07,sumcre,last_bl,debit,credit,till_bl,
		credit01m,credit02m,credit03m,credit04m,credit05m,credit06m,credit07m,sumcrem,last_blm,debitm,creditm,till_blm)
	SELECT arg_hotel_group_id,arg_hotel_id,biz_date,orderno,itemno,modeno,classno,descript,descript1,sequence,
		credit01,credit02,credit03,credit04,credit05,credit06,credit07,sumcre,last_bl,debit,credit,till_bl,
		credit01m,credit02m,credit03m,credit04m,credit05m,credit06m,credit07m,sumcrem,last_blm,debitm,creditm,till_blm
	FROM rep_dai WHERE hotel_group_id = -1 AND hotel_id = -1 ORDER BY classno;
	
	UPDATE rep_dai a,rep_dai_history b SET a.credit01 = b.credit01,a.credit02 = b.credit02,a.credit03 = b.credit03,a.credit04 = b.credit04,a.credit05 = b.credit05,
		a.credit06 = b.credit06,a.credit07 = b.credit07,a.sumcre = b.sumcre,a.last_bl = b.last_bl,a.debit = b.debit,a.credit = b.credit,a.till_bl = b.till_bl,
		a.credit01m = b.credit01m,a.credit02m = b.credit02m,a.credit03m = b.credit03m,a.credit04m = b.credit04m,a.credit05m = b.credit05m,
		a.credit06m = b.credit06m,a.credit07m = b.credit07m,a.sumcrem = b.sumcrem,a.last_blm = b.last_blm,a.debitm = b.debitm,a.creditm = b.creditm,a.till_blm = b.till_blm
	WHERE a.hotel_group_id = b.hotel_group_id AND a.hotel_id = b.hotel_id AND a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id 
	AND a.biz_date = b.biz_date AND a.biz_date = var_bfdate AND a.classno = b.classno;		
	
	DELETE FROM rep_dai_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bfdate;
	INSERT INTO rep_dai_history SELECT * FROM rep_dai WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM rep_dai WHERE hotel_group_id = -1 AND hotel_id = -1;
		
	-- rep_jiedai
	DELETE FROM rep_jiedai WHERE hotel_group_id = -1 AND hotel_id = -1;
	INSERT INTO rep_jiedai(hotel_group_id,hotel_id,biz_date,orderno,itemno,modeno,classno,descript,descript1,sequence,
		last_charge,last_credit,charge,credit,apply,till_charge,till_credit,last_chargem,last_creditm,chargem,creditm,applym,till_chargem,till_creditm)
	SELECT -1,-1,var_bfdate,orderno,itemno,modeno,classno,descript,descript1,sequence,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0
	FROM rep_jiedai WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id ORDER BY classno;
	
	DELETE FROM rep_jiedai WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM rep_jiedai_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	INSERT INTO rep_jiedai_history(hotel_group_id,hotel_id,biz_date,orderno,itemno,modeno,classno,descript,descript1,sequence,
		last_charge,last_credit,charge,credit,apply,till_charge,till_credit,last_chargem,last_creditm,chargem,creditm,applym,till_chargem,till_creditm)
	SELECT arg_hotel_group_id,arg_hotel_id,DATE,order_,itemno,MODE,class,descript,descript,NULL,
		last_charge,last_credit,charge,credit,apply,till_charge,till_credit,last_chargem,last_creditm,chargem,creditm,applym,till_chargem,till_creditm
	FROM migrate_db.yjiedai WHERE DATE >= '2012-01-01' AND class IN('02C','02F') ORDER BY DATE,class;
	
	INSERT INTO rep_jiedai_history(hotel_group_id,hotel_id,biz_date,orderno,itemno,modeno,classno,descript,descript1,sequence,
		last_charge,last_credit,charge,credit,apply,till_charge,till_credit,last_chargem,last_creditm,chargem,creditm,applym,till_chargem,till_creditm)
	SELECT arg_hotel_group_id,arg_hotel_id,DATE,order_,itemno,MODE,'03A','应收账','应收账',NULL,
		SUM(last_charge),SUM(last_credit),SUM(charge),SUM(credit),SUM(apply),SUM(till_charge),SUM(till_credit),
		SUM(last_chargem),SUM(last_creditm),SUM(chargem),SUM(creditm),SUM(applym),SUM(till_chargem),SUM(till_creditm)
	FROM migrate_db.yjiedai WHERE DATE >= '2012-01-01' AND class IN('03A','03C','03D') GROUP BY date ORDER BY DATE,class;
	
	INSERT INTO rep_jiedai_history(hotel_group_id,hotel_id,biz_date,orderno,itemno,modeno,classno,descript,descript1,sequence,
		last_charge,last_credit,charge,credit,apply,till_charge,till_credit,last_chargem,last_creditm,chargem,creditm,applym,till_chargem,till_creditm)
	SELECT arg_hotel_group_id,arg_hotel_id,DATE,order_,itemno,MODE,'02G','团体','团体',NULL,
		SUM(last_charge),SUM(last_credit),SUM(charge),SUM(credit),SUM(apply),SUM(till_charge),SUM(till_credit),
		SUM(last_chargem),SUM(last_creditm),SUM(chargem),SUM(creditm),SUM(applym),SUM(till_chargem),SUM(till_creditm)
	FROM migrate_db.yjiedai WHERE DATE >= '2012-01-01' AND class IN('02G','02M') GROUP BY date ORDER BY DATE,class;
	
	INSERT INTO rep_jiedai(hotel_group_id,hotel_id,biz_date,orderno,itemno,modeno,classno,descript,descript1,sequence,
		last_charge,last_credit,charge,credit,apply,till_charge,till_credit,last_chargem,last_creditm,chargem,creditm,applym,till_chargem,till_creditm)
	SELECT arg_hotel_group_id,arg_hotel_id,biz_date,orderno,itemno,modeno,classno,descript,descript1,sequence,
		last_charge,last_credit,charge,credit,apply,till_charge,till_credit,last_chargem,last_creditm,chargem,creditm,applym,till_chargem,till_creditm
	FROM rep_jiedai WHERE hotel_group_id = -1 AND hotel_id = -1 ORDER BY classno;	
	
	UPDATE rep_jiedai a,rep_jiedai_history b SET a.last_charge = b.last_charge,a.last_credit=b.last_credit,a.charge=b.charge,a.credit=b.credit,
		a.apply=b.apply,a.till_charge=b.till_charge,a.till_credit=b.till_credit,a.last_chargem=b.last_chargem,a.chargem=b.chargem,
		a.creditm=b.creditm,a.applym=b.applym,a.till_chargem=b.till_chargem,a.till_creditm=b.till_creditm
	WHERE a.hotel_group_id = b.hotel_group_id AND a.hotel_id = b.hotel_id AND a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id 
	AND a.biz_date = b.biz_date AND a.biz_date = var_bfdate AND a.classno = b.classno;
	
	DELETE FROM rep_jiedai_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bfdate;
	INSERT INTO rep_jiedai_history SELECT * FROM rep_jiedai WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM rep_jiedai WHERE hotel_group_id = -1 AND hotel_id = -1;	
	
END$$

DELIMITER ;