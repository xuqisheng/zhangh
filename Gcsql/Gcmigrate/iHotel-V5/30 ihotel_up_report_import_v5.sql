DELIMITER $$

DROP PROCEDURE IF EXISTS `ihotel_up_report_import_v5`$$

CREATE DEFINER=`root`@`%` PROCEDURE `ihotel_up_report_import_v5`(
	arg_hotel_group_id	BIGINT(16),
	arg_hotel_id		BIGINT(16)
)
SQL SECURITY INVOKER
label_0:
BEGIN
	DECLARE var_biz_date DATETIME;
	DECLARE var_bfdate DATETIME;
	
	-- SELECT biz_date INTO var_biz_date FROM audit_flag WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;	
	-- SET var_bfdate = ADDDATE(var_biz_date, -1);

	-- SET var_biz_date='2014-5-5';
	-- SET var_bfdate='2014-5-4';

	-- 房类分析统计表
	DELETE FROM rep_rmsale WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM rep_rmsale_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	ALTER TABLE migrate_xc.yrmsalerep_new ADD code_new VARCHAR(10) AFTER code;
	UPDATE migrate_xc.yrmsalerep_new SET code_new = TRIM(code);	
	UPDATE migrate_xc.yrmsalerep_new a,up_map_code b SET a.code_new = b.code_new WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id = arg_hotel_id
		AND a.code_new = b.code_old AND a.gkey = 't' AND a.hall='1' AND b.cat='rmtype';		
	
	INSERT INTO rep_rmsale(hotel_group_id,hotel_id,biz_date,rep_type,building,code,descript,descript_en,
		rooms_total,rooms_ooo,rooms_os,rooms_hse,rooms_avl,rooms_vac,sold_fit,sold_grp,sold_long,sold_ent,sold_added, 
		rev_fit,rev_grp,rev_long,people_fit,people_grp,people_long)
	SELECT arg_hotel_group_id, arg_hotel_id,date,gkey,hall,TRIM(code_new),descript,descript, 
		SUM(ttl),SUM(mnt),0, SUM(htl), SUM(avl), SUM(vac), SUM(soldf), SUM(soldg+soldc), SUM(soldl), SUM(ent), SUM(ext), 
		SUM(incomef), SUM(incomeg+incomec), SUM(incomel), SUM(gstf), SUM(gstg+gstc), SUM(gstl)
	FROM migrate_xc.yrmsalerep_new WHERE date >= '2012-01-01' AND code NOT LIKE '%{{{%' GROUP BY date,gkey,hall,code_new;
	
	UPDATE rep_rmsale SET rep_type = 'B' WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND rep_type ='h';
	UPDATE rep_rmsale SET rep_type = 'F' WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND rep_type ='f';
	UPDATE rep_rmsale SET rep_type = 'T' WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND rep_type ='t';
	UPDATE rep_rmsale SET code = TRIM(code) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	UPDATE rep_rmsale SET building = 'A' WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND building='1';
	UPDATE rep_rmsale SET code = 'A' WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND code='1' AND rep_type='B';
		
	UPDATE rep_rmsale a,room_type b SET a.descript=b.descript,a.descript_en=b.descript_en WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id = arg_hotel_id
		AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.code=b.code AND a.rep_type='T';
	
	INSERT INTO rep_rmsale_history SELECT * FROM rep_rmsale WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM rep_rmsale WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date < var_bfdate;
	
	-- 境内统计报表
	DELETE FROM guest_sta_inland WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;	
	DELETE FROM guest_sta_inland_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	INSERT INTO guest_sta_inland (hotel_group_id, hotel_id, DATE, guest_class, where_from, descript, descript1, 
		list_order, dtc, dgc, dmc, dtt, dgt, dmt, mtc, mgc, mmc, mtt, mgt, mmt, ytc, ygc, ymc, ytt, ygt, ymt)
	SELECT arg_hotel_group_id, arg_hotel_id,DATE,TRIM(gclass),TRIM(wfrom),descript,descript,0,dtc,dgc,0 ,dtt,dgt,0 ,mtc,mgc,0 ,mtt,mgt,0 ,ytc,ygc,0 ,ytt,ygt,0
			FROM migrate_xc.ygststa1 WHERE DATE >='2012-01-01';	
	UPDATE guest_sta_inland SET guest_class = '40' WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = '41'; 
	UPDATE guest_sta_inland SET guest_class = '50' WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = '51';

	INSERT INTO guest_sta_inland_history(id, hotel_group_id,hotel_id,date,guest_class,where_from,descript,descript1,list_order, 
		dtc,dgc,dmc,dtt,dgt,dmt,mtc,mgc,mmc,mtt,mgt,mmt,ytc,ygc,ymc,ytt,ygt,ymt)
	SELECT id,hotel_group_id,hotel_id,DATE,guest_class,where_from,descript,descript1,list_order, 
		dtc,dgc,dmc,dtt,dgt,dmt,mtc,mgc,mmc,mtt,mgt, mmt, ytc, ygc, ymc, ytt, ygt, ymt
	FROM guest_sta_inland WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM guest_sta_inland WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND DATE < var_bfdate;
	
	-- 境外统计报表
	UPDATE migrate_xc.ygststa SET gclass='2',order_='01' WHERE gclass='2' AND order_='' AND nation='' AND descript='省  内';
	UPDATE migrate_xc.ygststa SET gclass='2',order_='02' WHERE gclass='3' AND order_='' AND nation='' AND descript='省  外';
	UPDATE migrate_xc.ygststa SET gclass='3',order_='' WHERE gclass='4' AND order_='' AND nation='' AND descript='---境外---';
	
	DELETE FROM guest_sta_overseas WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;	
	DELETE FROM guest_sta_overseas_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	INSERT INTO guest_sta_overseas(hotel_group_id, hotel_id, DATE, guest_class, nation, list_order, descript, descript1, 
		sequence,dtc, dgc, dmc, dtt, dgt, dmt, mtc, mgc, mmc, mtt, mgt, mmt, ytc, ygc, ymc, ytt, ygt, ymt)	
	SELECT arg_hotel_group_id, arg_hotel_id,DATE,TRIM(gclass),TRIM(nation),order_,descript,descript,0,dtc,dgc,0 ,dtt,dgt,0 ,mtc,mgc,0 ,mtt,mgt,0 ,ytc,ygc,0 ,ytt,ygt,0
			FROM migrate_xc.ygststa WHERE DATE>='2012-01-01';	
			
	UPDATE guest_sta_overseas a,up_map_code b SET a.nation = b.code_new WHERE a.hotel_group_id = b.hotel_group_id AND a.hotel_id = b.hotel_id 
		AND a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.cat = 'nation' AND b.code_old = a.nation; 
	UPDATE guest_sta_overseas SET nation = 'AD' WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND nation ='AND';
	UPDATE guest_sta_overseas SET nation = 'PS' WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND nation ='PSE';
	UPDATE guest_sta_overseas SET nation = 'TP' WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND nation ='TLS';
	UPDATE guest_sta_overseas SET nation = 'SF' WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND nation ='SCG';

	UPDATE guest_sta_overseas a SET guest_class = '3' WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class ='4';
	INSERT INTO guest_sta_overseas_history(id, hotel_group_id, hotel_id, DATE, guest_class, nation, list_order, descript, descript1, sequence, 
		dtc, dgc, dmc, dtt, dgt, dmt, mtc, mgc, mmc, mtt, mgt, mmt, ytc, ygc, ymc, ytt, ygt, ymt)
	SELECT id, hotel_group_id, hotel_id, DATE, guest_class, nation, list_order, descript, descript1, sequence, 
		dtc, dgc, dmc, dtt, dgt, dmt, mtc, mgc, mmc, mtt, mgt, mmt, ytc, ygc, ymc, ytt, ygt, ymt
	FROM guest_sta_overseas WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM guest_sta_overseas WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND DATE < var_bfdate;
	
	-- 市场码分析报表
	ALTER TABLE migrate_xc.ymktsummaryrep ADD CODE VARCHAR(10) AFTER descript1;
	ALTER TABLE migrate_xc.ymktsummaryrep ADD code_category VARCHAR(30) AFTER CODE;
	DELETE FROM rep_revenue_type WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;	
	DELETE FROM rep_revenue_type_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM rep_revenue_type_detail WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	UPDATE migrate_xc.ymktsummaryrep a,up_map_code b SET a.code = b.code_new 
		WHERE a.class = 'A' AND b.cat = 'mktcode' AND TRIM(a.class1) = b.code_old AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id; 
	UPDATE migrate_xc.ymktsummaryrep a,up_map_code b SET a.code = b.code_new 
		WHERE a.class IN ('M','G') AND b.cat = 'mktcode_g' AND TRIM(a.class1) = b.code_old AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id; 

	UPDATE migrate_xc.ymktsummaryrep a,code_base b,code_base c SET a.code_category = b.descript 
		WHERE b.hotel_group_id = c.hotel_group_id AND b.hotel_id = c.hotel_id AND b.parent_code = 'market_category' 
			AND c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = arg_hotel_id AND c.parent_code = 'market_code' 
				AND c.code_category = b.code AND a.code = c.code;

	INSERT INTO rep_revenue_type(hotel_group_id, hotel_id, biz_date, code_type, code_category, code, rev_total, rev_rm, rooms_total, people_total)
	SELECT  arg_hotel_group_id, arg_hotel_id, DATE,'MARKET', code_category, CODE, SUM(tincome), SUM(rincome), SUM(rquan), SUM(pquan)
		FROM migrate_xc.ymktsummaryrep WHERE DATE >= '2012-01-01' GROUP BY date,code;

	INSERT INTO rep_revenue_type_history(hotel_group_id, hotel_id, id, biz_date, code_type, code_category, code, rev_total, rev_rm, 
		rev_rm_srv, rev_rm_pkg, rev_fb, rooms_total, rooms_arr, rooms_dep, rooms_noshow, rooms_cxl, people_total,people_arr, people_dep)
	SELECT hotel_group_id, hotel_id, id, biz_date, code_type, code_category, code, rev_total, rev_rm, 
		rev_rm_srv, rev_rm_pkg, rev_fb, rooms_total, rooms_arr, rooms_dep, rooms_noshow, rooms_cxl, people_total,people_arr, people_dep
	FROM rep_revenue_type WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM rep_revenue_type WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date < var_bfdate;
	
	-- 营业日报表
	DELETE FROM rep_jour WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM rep_jour_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	
	INSERT INTO rep_jour(hotel_group_id,hotel_id,biz_date,code,descript,descript_en,DAY,MONTH,YEAR,list_order)
		SELECT arg_hotel_group_id, arg_hotel_id,DATE,TRIM(class),descript,'',DAY,MONTH,YEAR,0 FROM migrate_xc.yjourrep WHERE DATE >='2012-01-01';

	INSERT INTO rep_jour_history(hotel_group_id,hotel_id,biz_date,code,descript,descript_en,day,month,year,list_order)
		SELECT hotel_group_id, hotel_id, biz_date, code, descript, descript_en, DAY, MONTH, YEAR, list_order
		FROM rep_jour WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;

	DELETE FROM rep_jour WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	
	INSERT INTO rep_jour(hotel_group_id,hotel_id,biz_date,code,descript,descript_en,DAY,MONTH,YEAR,list_order)
		SELECT arg_hotel_group_id,arg_hotel_id,var_bfdate,code,descript,descript_en,0,0,0,list_order
			FROM rep_jour_rule WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
			
	UPDATE rep_jour a,rep_jour_history b SET a.day = b.day,a.month = b.month,a.year = b.year WHERE a.hotel_group_id = b.hotel_group_id AND a.hotel_id = b.hotel_id
		AND a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.code = b.code AND b.biz_date = var_bfdate;
	
	DELETE FROM rep_jour_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_bfdate;
	INSERT INTO rep_jour_history(hotel_group_id,hotel_id,biz_date,code,descript,descript_en,day,month,year,list_order)
		SELECT hotel_group_id, hotel_id, biz_date, code, descript, descript_en, DAY, MONTH, YEAR, list_order
		FROM rep_jour WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;

	UPDATE rep_jour_history a,rep_jour_rule b SET a.list_order=b.list_order 
		WHERE a.hotel_group_id = b.hotel_group_id AND a.hotel_id = b.hotel_id AND a.hotel_group_id = 1 AND a.hotel_id = 105 AND a.code = b.code;		
	
	-- 导入前代码更新
	UPDATE migrate_xc.yjierep SET class = '998' WHERE class = '090';
	-- 稽核底表 (原先底表相关表索引有误，需要重建)
	-- rep_jie	
	DELETE FROM rep_jie WHERE hotel_group_id = -1 AND hotel_id = -1;
	INSERT INTO rep_jie(hotel_group_id,hotel_id,biz_date,orderno,itemno,modeno,classno,descript,descript1,rectype,toop,toclass,sequence,
		day01,day02,day03,day04,day05,day06,day07,day08,day09,day99,month01,month02,month03,month04,month05,month06,month07,month08,month09,month99)
	SELECT -1,-1,var_bfdate,orderno,itemno,modeno,classno,descript,descript1,rectype,toop,toclass,sequence,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		FROM rep_jie WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id ORDER BY classno;	
	
	DELETE FROM rep_jie WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM rep_jie_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	
	INSERT INTO rep_jie(hotel_group_id, hotel_id, biz_date, orderno,itemno,modeno,classno,descript,descript1,rectype,toop,toclass,sequence,
		day01,day02,day03,day04,day05,day06,day07,day08,day09,day99,month01,month02,month03,month04,month05,month06,month07,month08,month09,month99)
	SELECT arg_hotel_group_id, arg_hotel_id,DATE,'F',NULL,MODE,TRIM(class),descript,descript,rectype,toop,toclass,NULL, 
		day01,day02,day03,day04,day05,day06,day07,day08,day09,day99,month01,month02,month03,month04,month05,month06,month07,month08,month09,month99
	FROM migrate_xc.yjierep WHERE DATE >= '2012-01-01';
	
	INSERT INTO rep_jie_history SELECT * FROM rep_jie WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM rep_jie WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;

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

	INSERT INTO rep_dai(hotel_group_id,hotel_id,biz_date,orderno,itemno,modeno,classno,descript,descript1,sequence, 
	credit01,credit02,credit03,credit04,credit05,credit06,credit07,sumcre,last_bl,debit,credit,till_bl, 
	credit01m,credit02m,credit03m,credit04m,credit05m,credit06m,credit07m,sumcrem,last_blm,debitm,creditm,till_blm)
	SELECT arg_hotel_group_id, arg_hotel_id,DATE,order_,itemno,MODE,class,descript,descript,NULL, 
		credit01,credit02,credit03,credit04,credit05,credit06,credit07,sumcre,last_bl,debit,credit,till_bl, 
		credit01m,credit02m,credit03m,credit04m,credit05m,credit06m,credit07m,sumcrem,last_blm,debitm,creditm,till_blm
	 FROM migrate_xc.ydairep WHERE DATE >= '2012-01-01' AND class IN('01010','01020','01999','02000','03000','04000','08000','09000');
	 
	INSERT INTO rep_dai(hotel_group_id,hotel_id,biz_date,orderno,itemno,modeno,classno,descript,descript1,sequence, 
	credit01,credit02,credit03,credit04,credit05,credit06,credit07,sumcre,last_bl,debit,credit,till_bl, 
	credit01m,credit02m,credit03m,credit04m,credit05m,credit06m,credit07m,sumcrem,last_blm,debitm,creditm,till_blm)
	SELECT arg_hotel_group_id, arg_hotel_id,DATE,order_,itemno,MODE,'01998',descript,descript,NULL, 
		credit01,credit02,credit03,credit04,credit05,credit06,credit07,sumcre,last_bl,debit,credit,till_bl, 
		credit01m,credit02m,credit03m,credit04m,credit05m,credit06m,credit07m,sumcrem,last_blm,debitm,creditm,till_blm
	 FROM migrate_xc.ydairep WHERE DATE >= '2012-01-01' AND class='0105'; 
	
	INSERT INTO rep_dai_history SELECT * FROM rep_dai WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM rep_dai WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;	
		 
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
	
	INSERT INTO rep_jiedai(hotel_group_id,hotel_id,biz_date,orderno,itemno,modeno,classno,descript,descript1,sequence, 
		last_charge,last_credit,charge,credit,apply,till_charge,till_credit,last_chargem,last_creditm,chargem,creditm,applym,till_chargem,till_creditm)
	SELECT arg_hotel_group_id, arg_hotel_id,DATE,order_,itemno,MODE,'02F',descript,descript,NULL, 
		last_bl, 0, debit, credit, 0, till_bl, 0, last_blm, 0, debitm, creditm, 0, till_blm, 0
	FROM migrate_xc.ydairep WHERE DATE >= '2012-01-01' AND class = '02000';

	INSERT INTO rep_jiedai(hotel_group_id,hotel_id, biz_date,orderno, itemno, modeno, classno, descript, descript1, sequence, 
		last_charge,last_credit,charge,credit,apply,till_charge,till_credit,last_chargem,last_creditm,chargem,creditm,applym,till_chargem, till_creditm)
	SELECT arg_hotel_group_id, arg_hotel_id, DATE,order_,itemno,MODE,'03A',descript,descript,NULL, 
		last_bl, 0, debit, credit, 0, till_bl, 0, last_blm, 0, debitm, creditm, 0, till_blm, 0
	FROM migrate_xc.ydairep WHERE DATE >= '2012-01-01' AND class = '03000';
	
	INSERT INTO rep_jiedai_history SELECT * FROM rep_jiedai WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	DELETE FROM rep_jiedai WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;	
	
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