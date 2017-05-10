	一、管道迁移前工作
		
		1.检查消费账市场码、来源码是否存在;
		2.检查无效状态(N、X、W)是否存在账务;
			select a.accnt,a.sta,a.roomno,a.arr,a.dep,SUM(b.charge-b.credit) as balance from master a,account b 
				where a.accnt=b.accnt and a.sta not in ('R','I','S','O') group by a.accnt having(SUM(b.charge-b.credit))<>0;
		3.检查AR账关联档案是否丢失;
			select * from ar_master a where not exists (select 1 from guest b where a.haccnt=b.no AND b.class='R');
		4.检查AR账里主单余额与明细余额是否一致
			SELECT a.accnt,a.balance,b.accnt1,b.balance1 FROM (SELECT accnt,SUM(charge - credit) AS balance FROM ar_master GROUP BY accnt) AS a,
			(SELECT accnt accnt1,SUM(charge+charge0 - charge9 - credit0 -credit + credit9) balance1 FROM ar_detail GROUP BY accnt) AS b
			WHERE a.accnt = b.accnt1 AND a.balance <> b.balance1;
		5.检查AR账是否仍存在未审核的AR账;
		6.到点时，停用自动产生费用的相关接口:电话接口、VOD接口、餐饮接口;
		7.老系统作一次dump备份;
			6.1 主服dump (192.168.88.100):./dump foxhis ；主服dump完成后，可在服务器(192.168.88.99)进行ftp:./fptg 192.168.88.100 foxhis
			6.2 检查sqledit配置,是否指向正式库;
		8.连接正式库开始管道迁移;
		9.迁移完成后，针对migrate_xmyh作一次dump：./mdump migrate_xmyh
		10.执行升级脚本时，注意夜审前升级和夜审后的初始化过程时间;
		
		11.检查联房主账号是否在当前主单表里存在
		select 'I',a.pcrec,count(1) from master a where a.pcrec not in (select b.accnt from master b ) and a.pcrec<>'' and a.sta='I' group by a.pcrec having (count(1))>1 ;
		select 'S',a.pcrec,count(1) from master a where a.pcrec not in (select b.accnt from master b ) and a.pcrec<>'' and a.sta='S' group by a.pcrec having (count(1))>1 ;

		select * from master WHERE pcrec = ?;			
				
		SELECT * FROM up_map_accnt WHERE hotel_id=1 AND accnt_old IN ('F402260108','F402250184','F402250185');

		SELECT * FROM master_base WHERE id IN (?,?);
		

		1、客史整理，包括2013.1.1日之后，政府类房价码、入住次数大于2次
		2、协议单位整理，悦心卡关联的公司；
				
		
	二、管道迁移后，数据迁移前工作
		1.检查相关表是否管道迁移完全;
		2.为相关表建立索引;
			CREATE INDEX index_yh ON migrate_xmyh.guest(class,ident);
			CREATE INDEX index_yh ON migrate_xmyh.account(accntof);
		3.检查iHotel相关是否建立必要的索引;
			CREATE INDEX index_yh1 ON guest_base(hotel_group_id,hotel_id,name,id_no);
			CREATE INDEX index_yh ON company_base(hotel_group_id,hotel_id,name);
			CREATE INDEX index_yh ON ar_account(hotel_group_id,hotel_id,ta_code);
			CREATE INDEX index_yh ON ar_detail(hotel_group_id,hotel_id,ta_code);
			CREATE INDEX index_yh ON guest_base(hotel_group_id,company_id); -- 客史关联协议单位的协议单位号更新

	/* ====================================================================
	   方法一:在Pietty中执行事例 
	   ==================================================================== */
		== 档案整理
		./seecfg "call up_ihotel_up_code_init_yh(1,1)" portal
		./seecfg "call up_ihotel_up_guest_fit_yh(1,1)" portal
		./seecfg "call up_ihotel_up_guest_grp_yh(1,1)" portal
		./seecfg "call up_ihotel_up_company_yh(1,1)" portal
		== 投诉记录迁移 排房要求更新
		
		./seecfg "call up_ihotel_up_master_ha_yh(1,1)" portal
		./seecfg "call up_ihotel_up_master_r_yh(1,1)" portal
		./seecfg "call up_ihotel_up_master_si_yh(1,1)" portal
		./seecfg "call up_ihotel_up_rmrsv_rsv_src_yh(1,1)" portal
		./seecfg "call up_ihotel_up_fo_account_yh(1,1)" portal
		./seecfg "call up_ihotel_up_armst_yh(1,1)" portal
		./seecfg "call up_ihotel_up_code_maint_yh(1,1)" portal
		== 历史记录信息
		./seecfg "call ihotel_up_gold(1,1)" portal
		./seecfg "call ihotel_up_guest_xfttl_x5(1,1)" portal
		
		
		./seecfg "call ihotel_master_history_x5(1,1)" portal
	
	F6房态图 ---> 帮助  --->  重建
	数据整理 ---> 重建客房状态 ---> 客房资源重建 ---> 房价重建

	-- 夜审后(第二天),开始管道迁移(gc_migrate_x5_report.pbl),迁移完成后，逐步以下过程
		CALL portal.ihotel_up_report_import_x5(1,1);
	-- 执行ihotel_up_mstbalance,修复余额表
		
	三、数据迁移后工作
		1.F6房态图 ---> 帮助  --->  重建
		  数据整理 ---> 重建客房状态 ---> 客房资源重建 ---> 房价重建
		  参数配置 ---> 已退房未结账和检查数据一致性 --> 停用
		2.针对多选的包价进行手工修改;
			SELECT id,rmno,packages FROM master_base WHERE hotel_group_id = 2 AND hotel_id = 9 AND packages REGEXP '[,]';
			SELECT id,rmno,packages FROM rsv_src WHERE hotel_group_id = 2 AND hotel_id = 9 AND packages REGEXP '[,]';
		3.协议单位条目数及内容检查;
		4.维修房、锁定房、临时态、特殊要求修改;
		5.定义账户、允许记账修改;
		6.检查各模块、状态余额;
		-- 检查主单各状态数目、余额
		-- 西软(PB查看)
		select class,sta,count(1) from master group by class,sta order by class,sta;
		select class,sta,sum(charge-credit) from master group by class,sta order by class,sta;
		select sum(charge-credit) from master;
		select sum(charge-credit) from account;
		select count(1) from account;
			
		-- iHotel(SQLyog查看)
			SELECT rsv_class,sta,COUNT(1) FROM master_base WHERE hotel_group_id = 1 AND hotel_id = 1 GROUP BY rsv_class,sta ORDER BY 		rsv_class,sta;
		SELECT rsv_class,sta,SUM(charge-pay) FROM master_base WHERE hotel_group_id = 1 AND hotel_id = 1 GROUP BY rsv_class,sta ORDER BY 		rsv_class,sta;
		SELECT SUM(charge-pay) FROM master_base WHERE hotel_group_id = 1 AND hotel_id = 1;
		SELECT SUM(charge-pay) FROM account WHERE hotel_group_id = 1 AND hotel_id = 1;
		SELECT COUNT(1) FROM account WHERE hotel_group_id = 1 AND hotel_id = 1;
			
			
		-- 检查AR余额、数目
		-- 西软(PB查看)
		select artag1,sum(charge-credit) from ar_master where sta='I' group by artag1 order by artag1;
		select artag1,count(1) from ar_master where sta='I' group by artag1 order by artag1;
		select sum(charge-credit) from ar_master where sta='I' ;
		select 1,sum(charge-credit) from ar_master where sta='I'  
		union all
		select 2,sum(a.charge + a.charge0 - a.credit - a.credit0) from ar_detail a,ar_master b where a.accnt=b.accnt ; 
		-- iHotel(SQLyog查看)
		SELECT ar_category,SUM(charge-pay) FROM ar_master WHERE hotel_group_id = 1 AND hotel_id = 1 AND sta='I' GROUP BY ar_category ORDER BY 		ar_category;
		SELECT ar_category,COUNT(1) FROM ar_master WHERE hotel_group_id = 1 AND hotel_id = 1 AND sta='I' GROUP BY ar_category ORDER BY ar_category;	
		SELECT 1,SUM(charge-pay) FROM ar_master WHERE hotel_group_id = 1 AND hotel_id = 1
		UNION ALL
		SELECT 2,SUM(charge + charge0 - pay - pay0) FROM ar_account WHERE hotel_group_id = 1 AND hotel_id = 1;
			
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
	FROM migrate_xmyh.saleid;	 
	 
	INSERT INTO sales_man_business (hotel_group_id, hotel_id, sales_man, sta, dept, job, 
	sales_group, login_user, create_user, create_datetime, modify_user, modify_datetime) 
	SELECT 1,1,CODE,'I',IF(grp='A','X01','A01'),NULL,grp,empno,'ADMIN',NOW(),'ADMIN',NOW()
	FROM migrate_xmyh.saleid;


	检查：
	1、早餐包价自动核销
	SELECT * FROM sys_option WHERE hotel_id = 13 AND catalog = 'account' AND item = 'package_chargeoff_mode'；
	2、应收帐管理信用卡；
	3、房类分析过程启用；
	4、集团分析过程启用；