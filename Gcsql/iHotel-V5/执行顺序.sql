一、管道迁移前工作
	1.西软foxhis库先作dump备份
	2.管道迁移后,migrate_xc 也做备份
	3.iHotel被屏蔽的夜审检查是否打开
	4.检查消费账市场码、来源码是否存在
	5.检查无效状态(N、X、W)是否存在账务,若存在无效状态的账务,必须事先处理;
		select a.accnt,a.sta,a.roomno,a.arr,a.dep,SUM(b.charge-b.credit) as balance from master a,account b 
			where a.accnt=b.accnt and a.sta not in ('R','I','S','O','H') group by a.accnt having(SUM(b.charge-b.credit))<>0;
	6.检查是否存在无效的预订资源	
		select a.* from rsvgrp a where not exists (select 1 from typim b where a.type=b.type);
		delete from rsvgrp where not exists (select 1 from typim b where rsvgrp.type=b.type);
		
		select a.* FROM rsvdtl a where not exists (select 1 from typim b where a.type=b.type);
		delete from rsvdtl where not exists (select 1 from typim b where rsvdtl.type=b.type);
	7.检查AR账里主单余额与明细余额是否一致,若X5版本，需要检查AR账是否已全部审核
		SELECT a.accnt,a.balance,b.accnt1,b.balance1 FROM (SELECT accnt,SUM(rmb_db-depr_cr-addrmb) AS balance FROM armst GROUP BY accnt) AS a,
		(SELECT accnt accnt1,SUM(charge-credit) balance1 FROM account GROUP BY accnt) AS b
		WHERE a.accnt = b.accnt1 AND a.balance <> b.balance1;
	8.能够自动产生费用的相关接口是否停用,比如:电话、VOD、餐饮接口等等
	9.连接正式库开始管道迁移;
	10.迁移完成后，针对migrate_xc作一次dump：./mdump migrate_xc
	11.执行升级脚本时，注意夜审前升级和夜审后的初始化过程时间 (目前我这边习惯于西软夜审后迁移数据,余额修复以实际为主)
	12.检查联房主账号是否在当前主单表里存在
		select 'I',a.pcrec,count(1) from master a where a.pcrec not in (select b.accnt from master b ) and a.pcrec<>'' and a.sta='I' group by a.pcrec having (count(1))>1 ;
		select 'S',a.pcrec,count(1) from master a where a.pcrec not in (select b.accnt from master b ) and a.pcrec<>'' and a.sta='S' group by a.pcrec having (count(1))>1 ;

		-- 事先修改
		select * from master WHERE pcrec = ?;
	
		-- 事后修改	
		SELECT * FROM up_map_accnt WHERE hotel_id=9 AND accnt_old IN ('F402260108','F402250184','F402250185');
		SELECT * FROM master_base WHERE id IN (?,?);
		

二、管道迁移后，数据迁移前工作
	1、检查相关管道是否迁移完全(hgstinf,hgstinf_xh,cusinf,master,guest..);
	2、为相关表建立索引：
			CREATE INDEX index_xc ON migrate_xc.hgstinf(ident);
			CREATE INDEX index_xc ON migrate_xc.account(accntof);
	3.检查iHotel相关是否建立必要的索引;
			CREATE INDEX index_cm ON guest_base(hotel_group_id,hotel_id,name,id_no);
			CREATE INDEX index_cm ON company_base(hotel_group_id,hotel_id,name);
			CREATE INDEX index_cm ON ar_account(hotel_group_id,hotel_id,ta_code);
			CREATE INDEX index_cm ON ar_detail(hotel_group_id,hotel_id,ta_code);
			

	/* ====================================================================
		方法一:在Pietty中执行事例
		岷山应用服务器:ssh ms131
		脚本执行前检查营业日期及 up_map_code 表
	   ==================================================================== */
		./seecfg "call ihotel_up_code_init_v5(1,105)" portal
		./seecfg "call ihotel_up_guest_fit_v5(1,105)" portal
		./seecfg "call ihotel_up_company_v5(1,105)" portal
		./seecfg "call ihotel_up_master_ha_v5(1,105)" portal
		./seecfg "call ihotel_up_master_r_v5(1,105)" portal
		./seecfg "call ihotel_up_master_si_v5(1,105)" portal
		./seecfg "call ihotel_up_grpmst_si_v5(1,105)" portal
		./seecfg "call ihotel_up_rmrsv_rsv_src_v5(1,105)" portal
		./seecfg "call ihotel_up_fo_account_v5(1,105)" portal
		./seecfg "call ihotel_up_armst_v5(1,105)" portal
		./seecfg "call ihotel_up_code_maint_v5(1,105)" portal
		
	F6房态图 ---> 帮助  --->  重建
	数据整理 ---> 重建客房状态 ---> 客房资源重建 ---> 房价重建
	参数配置 ---> 已退房未结账和检查数据一致性 --> 停用 --> 第一晚夜审再打开

	-- 夜审后(第二天),开始管道迁移(gc_migrate_v5_report.pbl),迁移完成后，逐步以下过程
	./seecfg "call ihotel_up_report_import_v5(1,105)" portal

	-- 执行ihotel_up_mstbalance,修复余额表
		
	三、数据迁移后工作
		1.F6房态图 ---> 帮助  --->  重建
		  数据整理 ---> 重建客房状态 ---> 客房资源重建 ---> 房价重建
		  参数配置 ---> 已退房未结账和检查数据一致性 --> 停用
		2.针对多选的包价进行手工修改;
			SELECT id,rmno,packages FROM master_base WHERE hotel_group_id = 1 AND hotel_id = 105 AND packages REGEXP '[,]';
			SELECT id,rmno,packages FROM rsv_src WHERE hotel_group_id = 1 AND hotel_id = 105 AND packages REGEXP '[,]';
		3.协议单位条目数及内容检查;
		4.维修房、锁定房、临时态、特殊要求修改;
		5.定义账户、允许记账修改;
		6.检查各模块、状态余额;
		-- 检查主单各状态数目、余额
		-- 西软(PB查看)
		select class,sta,count(1) from master group by class,sta order by class,sta;
		select class,sta,count(1) from grpmst group by class,sta order by class,sta;
		select class,sta,sum(rmb_db-depr_cr-addrmb) from master group by class,sta order by class,sta;
		select class,sta,sum(rmb_db-depr_cr-addrmb) from grpmst group by class,sta order by class,sta;
		select sum(rmb_db-depr_cr-addrmb) from master;
		select sum(rmb_db-depr_cr-addrmb) from grpmst;
		select sum(charge-credit) from account where accnt not like 'AR%';
		select count(1) from account;
			
		-- iHotel(SQLyog查看)
		SELECT rsv_class,sta,COUNT(1) FROM master_base WHERE hotel_group_id = 1 AND hotel_id = 105 GROUP BY rsv_class,sta ORDER BY rsv_class,sta;
		SELECT rsv_class,sta,SUM(charge-pay) FROM master_base WHERE hotel_group_id = 1 AND hotel_id = 105 GROUP BY rsv_class,sta ORDER BY rsv_class,sta;
		SELECT SUM(charge-pay) FROM master_base WHERE hotel_group_id = 1 AND hotel_id = 105;
		SELECT SUM(charge-pay) FROM account WHERE hotel_group_id = 1 AND hotel_id = 105;
		SELECT COUNT(1) FROM account WHERE hotel_group_id = 1 AND hotel_id = 105;
			
		-- 检查AR余额、数目
		-- 西软(PB查看)		
		select tag0,COUNT(1) from armst group by tag0;
		select sum(charge-credit) from account where accnt not like 'AR%';
		select sum(rmb_db-depr_cr-addrmb) from armst;
		-- iHotel(SQLyog查看)
		SELECT ar_category,SUM(charge-pay) FROM ar_master WHERE hotel_group_id = 1 AND hotel_id = 105 AND sta='I' GROUP BY ar_category ORDER BY ar_category;
		SELECT ar_category,COUNT(1) FROM ar_master WHERE hotel_group_id = 1 AND hotel_id = 105 AND sta='I' GROUP BY ar_category ORDER BY ar_category;	
		SELECT 1,SUM(charge-pay) FROM ar_master WHERE hotel_group_id = 1 AND hotel_id = 105
		UNION ALL
		SELECT 2,SUM(charge + charge0 - pay - pay0) FROM ar_account WHERE hotel_group_id = 1 AND hotel_id = 105;
		
		-- 查看同住是否正确
		SELECT id,rmno,master_id,rsv_no FROM master_base AS a WHERE hotel_group_id=1 AND hotel_id = 105 AND rsv_class =  'F' AND sta = 'I' AND rsv_id <> id
		AND EXISTS (SELECT 1 FROM master_base WHERE hotel_group_id=1 AND hotel_id = 105 AND rsv_class =  'F' AND sta = 'I' AND rsv_id <> id
		AND rmno = a.rmno AND master_id <> a.master_id);
		-- 检查主单房型是否和实际一致
		SELECT a.id,a.rsv_id,a.rmtype,b.rmtype,c.code_old,c.code_new FROM master_base a,room_no b,up_map_code c 
		WHERE a.hotel_group_id = 1 AND a.hotel_id = 105 AND b.hotel_group_id = 1 AND
		b.hotel_id = 105 AND c.hotel_group_id = 1 AND c.hotel_id = 105 AND c.cat = 'rmtype' AND b.rmtype = c.code_new
		AND a.rmno = b.code AND a.rmtype <> b.rmtype;
		
		-- 检查是否存在未匹配的费用码或付款码
		SELECT * FROM account a WHERE a.hotel_group_id = 1 AND a.hotel_id = 105 
			AND NOT EXISTS(SELECT 1 FROM code_transaction b WHERE b.hotel_group_id=1 AND b.hotel_id=105 AND b.is_halt='F' AND a.ta_code=b.code);
		SELECT * FROM ar_account a WHERE a.hotel_group_id = 1 AND a.hotel_id = 105 
			AND NOT EXISTS(SELECT 1 FROM code_transaction b WHERE b.hotel_group_id=1 AND b.hotel_id=105 AND b.is_halt='F' AND a.ta_code=b.code);	
		SELECT * FROM ar_detail a WHERE a.hotel_group_id = 1 AND a.hotel_id = 105 
			AND NOT EXISTS(SELECT 1 FROM code_transaction b WHERE b.hotel_group_id=1 AND b.hotel_id=105 AND b.is_halt='F' AND a.ta_code=b.code);
		-- 检查arrange_code是否未更新
		SELECT * FROM ar_account a,code_transaction b WHERE a.hotel_group_id = 1 AND a.hotel_id = 105 AND b.hotel_group_id = 1 AND b.hotel_id = 105
			AND a.arrage_code = '' AND a.ta_code = b.code;
		SELECT * FROM account a,code_transaction b WHERE a.hotel_group_id = 1 AND a.hotel_id = 105 AND b.hotel_group_id = 1 AND b.hotel_id = 105
			AND a.arrange_code = '' AND a.ta_code = b.code;
		SELECT * FROM ar_detail a,code_transaction b WHERE a.hotel_group_id = 1 AND a.hotel_id = 105 AND b.hotel_group_id = 1 AND b.hotel_id = 105
			AND a.arrange_code = '' AND a.ta_code = b.code;
			
		-- 检查联房情况
		SELECT accnt,TYPE,sta,roomno,pcrec FROM migrate_xc.master WHERE sta IN('I','O','S') AND pcrec <> '' 
		AND pcrec NOT IN (SELECT LEFT(accnt_old,7) FROM up_map_accnt WHERE hotel_group_id = 1 AND hotel_id = 105 
		AND accnt_type IN ('master_si','master_r','consume')) AND sta <> 'O' ORDER BY sta,roomno;
			
	数据导入后对照原系统房态图作相应修改
	客房中心和商务中心对应的accnt要修改

	1.消费帐的个数，余额
	2.在住客人的个人，余额，信用
	3.挂S账的账户余额，信用
	4.AR账户的个数，余额
	5.房类资源(房态图，客房可用)
	
	/* ====================================================================
		导入销售员
	   ==================================================================== */	
	1、saleid表导入到中间库
	2、建立与原系统一样的分组(若不一样，需要建议对照表)
	3、需要导入到sales_man和sales_man_business

	INSERT INTO sales_man (hotel_group_id, hotel_id, CODE, NAME, last_name, first_name, name2, name3, extension,territory, 
	extra_flag, is_fulltime, join_date, date_begin, date_end, sex, id_code, id_no, LANGUAGE, 
	birth, nation, country, state, town, street, zipcode, mobile, phone, fax, website, email, remark, 
	pic_photo, pic_sign, list_order, create_user, create_datetime, modify_user, modify_datetime) 
	SELECT 2,0,CODE,descript,'','','','','','NA','000000000000000000000000000000','T',NULL,NULL,NULL,'1','01',NULL,'C',
	NULL,'CN','CN',NULL,NULL,NULL,NULL,NULL,'',NULL,NULL,NULL,NULL,NULL,NULL,'0','ADMIN',NOW(),'ADMIN',NOW()
	FROM migrate_xc.saleid;	 
	 
	INSERT INTO sales_man_business (hotel_group_id, hotel_id, sales_man, sta, dept, job, 
	sales_group, login_user, create_user, create_datetime, modify_user, modify_datetime) 
	SELECT 2,9,CODE,'I',IF(grp='A','X01','A01'),NULL,grp,empno,'ADMIN',NOW(),'ADMIN',NOW()
	FROM migrate_xc.saleid;	
	
	/*=============修改2014.5.5==============*/
	SELECT c.ref,c.roomno,c.ref2,a.ta_descript,a.rmno,a.ta_remark FROM  ar_account a,up_map_accnt b,migrate_xc.account c 
		WHERE a.hotel_group_id=1 AND a.hotel_id=105 AND b.hotel_group_id=1 AND b.hotel_id=105 AND a.accnt=2204
		AND a.accnt=b.accnt_new AND b.accnt_old=c.accnt AND a.number=c.number AND b.accnt_type='armst';
		
		
DROP TABLE migrate_xc.account;
DROP TABLE migrate_xc.accredit;
DROP TABLE migrate_xc.armst;
DROP TABLE migrate_xc.cusdef;
DROP TABLE migrate_xc.cusinf;
DROP TABLE migrate_xc.grpmst;
DROP TABLE migrate_xc.guest;
DROP TABLE migrate_xc.hgstinf;
DROP TABLE migrate_xc.hgstinf_xh;
DROP TABLE migrate_xc.jierep;
DROP TABLE migrate_xc.jourrep;
DROP TABLE migrate_xc.master;
DROP TABLE migrate_xc.message;
DROP TABLE migrate_xc.rsvdtl;
DROP TABLE migrate_xc.rsvgrp;		