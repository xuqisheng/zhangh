	一、管道迁移前工作
		1.西软foxhis库先作dump备份
		2.管道迁移后,migrate_xc 也做备份
		3.iHotel被屏蔽的夜审检查是否打开		
		4.检查消费账市场码、来源码是否存在;
		5.检查无效状态(N、X、W)是否存在账务;
			select a.accnt,a.sta,a.roomno,a.arr,a.dep,SUM(b.charge-b.credit) as balance from master a,account b 
				where a.accnt=b.accnt and a.sta not in ('R','I','S','O') group by a.accnt having(SUM(b.charge-b.credit))<>0;
		6.检查AR账关联档案是否丢失;
			select * from master a where not exists(select 1 from guest b where a.haccnt=b.no AND b.class='R') and a.accnt like 'AR%';		
		7.检查主单余额与明细余额是否一致,包括宾客、消费账、AR账
			SELECT a.accnt,a.balance,b.accnt1,b.balance1 FROM (SELECT accnt,SUM(charge - credit) AS balance FROM master GROUP BY accnt) AS a,
			(SELECT accnt accnt1,SUM(charge-credit) balance1 FROM account GROUP BY accnt) AS b
			WHERE a.accnt = b.accnt1 AND a.balance <> b.balance1;
		8.能够自动产生费用的相关接口是否停用,比如:电话、VOD、餐饮接口等等
		9.连接正式库开始管道迁移;
		10.迁移完成后，针对migrate_xc作一次dump：./mdump migrate_yl
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
		1.检查相关表是否管道迁移完全;
		2.为相关表建立索引;
			CREATE INDEX index_yl ON migrate_yl.guest(class,ident);
			CREATE INDEX index_yl ON migrate_yl.account(accntof);
		3.检查iHotel相关是否建立必要的索引;
			CREATE INDEX index_d1 ON guest_base(hotel_group_id,hotel_id,name,id_no);
			CREATE INDEX index_d2 ON guest_base(hotel_group_id,hotel_id,company_id);
			CREATE INDEX index_d ON company_base(hotel_group_id,hotel_id,name);
			CREATE INDEX index_d ON ar_account(hotel_group_id,hotel_id,ta_code);
			CREATE INDEX index_d ON ar_detail(hotel_group_id,hotel_id,ta_code);
			

	/* ====================================================================
	   方法一:在 Pietty 中执行事例 
	   ==================================================================== */
		./seecfg "call ihotel_up_code_init_smart(1,111)" portal
		./seecfg "call ihotel_up_guest_fit_smart(1,111)" portal
		./seecfg "call ihotel_up_guest_grp_smart(1,111)" portal
		./seecfg "call ihotel_up_company_smart(1,111)" portal
		./seecfg "call ihotel_up_master_ha_smart(1,111)" portal
		./seecfg "call ihotel_up_master_r_smart(1,111)" portal
		./seecfg "call ihotel_up_master_si_smart(1,111)" portal
		./seecfg "call ihotel_up_rmrsv_rsv_src_smart(1,111)" portal
		./seecfg "call ihotel_up_fo_account_smart(1,111)" portal
		./seecfg "call ihotel_up_armst_smart(1,111)" portal
		./seecfg "call ihotel_up_code_maint_smart(1,111)" portal
		./seecfg "call ihotel_up_guest_xfttl_smart(1,111)" portal
		
		
	F6房态图 ---> 帮助  --->  重建
	数据整理 ---> 重建客房状态 ---> 客房资源重建 ---> 房价重建

	-- 夜审后(第二天),开始管道迁移(gc_migrate_smart_report.pbl),迁移完成后，逐步以下过程
		CALL portal.ihotel_up_report_import_smart(1,111);
	-- 执行ihotel_up_mstbalance,修复余额表
		
	三、数据迁移后工作
		1.F6房态图 ---> 帮助  --->  重建
		  数据整理 ---> 重建客房状态 ---> 客房资源重建 ---> 房价重建
		  参数配置 ---> 已退房未结账和检查数据一致性 --> 停用  --> 第一夜审后再打开
		2.针对多选的包价进行手工修改;
			SELECT id,rmno,packages FROM master_base WHERE hotel_group_id = 1 AND hotel_id = 111 AND packages REGEXP '[,]';
			SELECT id,rmno,packages FROM rsv_src WHERE hotel_group_id = 1 AND hotel_id = 111 AND packages REGEXP '[,]';
		3.协议单位条目数及内容检查;
		4.维修房、锁定房、临时态、特殊要求修改;
		5.定义账户、允许记账修改;
		6.检查各模块、状态余额;
		-- 检查主单各状态数目、余额
		-- 西软(PB查看)
		select class,sta,count(1) from master where accnt not like 'AR%' group by class,sta order by class,sta;
		select class,sta,sum(charge-credit) from master where accnt not like 'AR%' group by class,sta order by class,sta;
		select sum(charge-credit) from master where accnt not like 'AR%';
		select sum(charge-credit) from account where accnt not like 'AR%';
		select count(1) from account where accnt not like 'AR%';
			
		-- iHotel(SQLyog查看)
		SELECT rsv_class,sta,COUNT(1) FROM master_base WHERE hotel_group_id = 1 AND hotel_id = 111 GROUP BY rsv_class,sta ORDER BY rsv_class,sta;
		SELECT rsv_class,sta,SUM(charge-pay) FROM master_base WHERE hotel_group_id = 1 AND hotel_id = 111 GROUP BY rsv_class,sta ORDER BY rsv_class,sta;
		SELECT SUM(charge-pay) FROM master_base WHERE hotel_group_id = 1 AND hotel_id = 111;
		SELECT SUM(charge-pay) FROM account WHERE hotel_group_id = 1 AND hotel_id = 111;
		SELECT COUNT(1) FROM account WHERE hotel_group_id = 1 AND hotel_id = 111;
			
		-- 检查AR余额、数目
		-- 西软(PB查看)
		select artag1,sta,count(1) from master where accnt like 'AR%' group by artag1,sta order by artag1,sta;
		select artag1,sta,sum(charge-credit) from master where accnt like 'AR%' group by artag1,sta order by artag1,sta;
		select sum(charge-credit) from master where accnt like 'AR%';
		select sum(charge-credit) from account where accnt like 'AR%';
		select count(1) from account where accnt like 'AR%';
		-- iHotel(SQLyog查看)
		SELECT ar_category,SUM(charge-pay) FROM ar_master WHERE hotel_group_id = 1 AND hotel_id = 111 AND sta='I' GROUP BY ar_category ORDER BY ar_category;
		SELECT ar_category,COUNT(1) FROM ar_master WHERE hotel_group_id = 1 AND hotel_id = 111 AND sta='I' GROUP BY ar_category ORDER BY ar_category;	
		SELECT 1,SUM(charge-pay) FROM ar_master WHERE hotel_group_id = 1 AND hotel_id = 111
		UNION ALL
		SELECT 2,SUM(charge + charge0 - pay - pay0) FROM ar_account WHERE hotel_group_id = 1 AND hotel_id = 111;
			
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
	FROM migrate_yl.saleid;	 
	 
	INSERT INTO sales_man_business (hotel_group_id, hotel_id, sales_man, sta, dept, job, 
	sales_group, login_user, create_user, create_datetime, modify_user, modify_datetime) 
	SELECT 1,111,CODE,'I',IF(grp='A','X01','A01'),NULL,grp,empno,'ADMIN',NOW(),'ADMIN',NOW()
	FROM migrate_yl.saleid;
	
	X5 | Smart | C7 需要对照码类别
	channel 渠道码
	idcode  证件类别
	mktcode 市场码
	srccode 来源码
	pccode  费用码
	paymth  付款码
	ratecode 房价码
	package  包价
	restype  预订类型
	rmtype   房类
	saleman 销售员
	reason   优惠理由
	country  国家
	nation   国籍


	V系列 需要对照码类别
	idcode  证件类别
	mktcode 散客市场码
	mktcode_g 团队市场码
	pccode  费用码
	paymth  付款码
	ratecode 房价码
	rmtype   房类
	salesman 销售员
	reason   优惠理由
	country  国家
	nation   国籍	