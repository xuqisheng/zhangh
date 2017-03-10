	一、管道迁移前工作
		1.检查消费账市场码、来源码是否存在;
		2.检查无效状态(N、X、W)是否存在账务;
			select a.accnt,a.sta,a.roomno,a.arr,a.dep,SUM(b.charge-b.credit) as balance from master a,account b 
				where a.accnt=b.accnt and a.sta not in ('R','I','S','O') group by a.accnt having(SUM(b.charge-b.credit))<>0;
						
		3.检查AR账关联档案是否丢失;
			SELECT * FROM master a WHERE NOT EXISTS (SELECT 1 FROM guest b WHERE a.haccnt=b.no AND b.class='R') AND accnt LIKE 'AR%';
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
		9.迁移完成后，针对migrate_db作一次dump：./mdump migrate_db
		10.执行升级脚本时，注意夜审前升级和夜审后的初始化过程时间;
		
		11.检查联房主账号是否在当前主单表里存在
		select 'I',a.pcrec,count(1) from master a where a.pcrec not in (select b.accnt from master b ) and a.pcrec<>'' and a.sta='I' group by a.pcrec having (count(1))>1 ;
		select 'S',a.pcrec,count(1) from master a where a.pcrec not in (select b.accnt from master b ) and a.pcrec<>'' and a.sta='S' group by a.pcrec having (count(1))>1 ;

		select * from master WHERE pcrec IN ();
				
		SELECT * FROM up_map_accnt WHERE hotel_id=9 AND accnt_old IN ('F402260108','F402250184','F402250185');

		SELECT * FROM master_base WHERE id IN (?,?);
				
		
	二、管道迁移后，数据迁移前工作
		1.检查相关表是否管道迁移完全;
		2.为相关表建立索引;
			CREATE INDEX index_bs 	ON migrate_db.guest(class,ident);
			CREATE INDEX accntof 	ON migrate_db.account(accntof);
			CREATE INDEX haccnt 	ON migrate_db.master(haccnt);
			CREATE INDEX exp_s2 	ON migrate_db.master(exp_s2);

	/* ====================================================================
	   方法一:在Pietty中执行事例 
	   ==================================================================== */
		-- 第一批
			-- 120 机子 jdglfoxhis 京华
			-- 京华有云POS，检查夜审是否已过
			./seecfg "call up_ihotel_up_xr_divide(120,'jdglfoxhis')" portal_ipms
			./seecfg "call up_ihotel_up_exec_all('2016-10-27',2,15)" portal_ipms		
			
			-- 90 机子
			./seecfg "call up_ihotel_up_xr_divide(90,'hfoxhis')" portal_ipms
			
			./seecfg "call up_ihotel_up_exec_all('2016-10-27',2,30)" portal_ipms
			./seecfg "call up_ihotel_up_exec_all('2016-10-27',2,31)" portal_ipms
			./seecfg "call up_ihotel_up_exec_all('2016-10-27',2,32)" portal_ipms
			
			-- 120 机子
			./seecfg "call up_ihotel_up_xr_divide(120,'foxhis')" portal_ipms
			
			./seecfg "call up_ihotel_up_exec_all('2016-10-27',2,17)" portal_ipms
			./seecfg "call up_ihotel_up_exec_all('2016-10-27',2,23)" portal_ipms
			./seecfg "call up_ihotel_up_exec_all('2016-10-27',2,24)" portal_ipms
			./seecfg "call up_ihotel_up_exec_all('2016-10-27',2,25)" portal_ipms
			./seecfg "call up_ihotel_up_exec_all('2016-10-27',2,26)" portal_ipms
			./seecfg "call up_ihotel_up_exec_all('2016-10-27',2,27)" portal_ipms
			./seecfg "call up_ihotel_up_exec_all('2016-10-27',2,28)" portal_ipms
			./seecfg "call up_ihotel_up_exec_all('2016-10-27',2,29)" portal_ipms

		-- 第二批
			-- 12 机子
			./seecfg "call up_ihotel_up_xr_divide(12,'foxhis')" portal_ipms
			
			./seecfg "call up_ihotel_up_exec_all('2016-11-1',2,41)" portal_ipms
			./seecfg "call up_ihotel_up_exec_all('2016-11-1',2,42)" portal_ipms
			./seecfg "call up_ihotel_up_exec_all('2016-11-1',2,43)" portal_ipms
			./seecfg "call up_ihotel_up_exec_all('2016-11-1',2,44)" portal_ipms
			./seecfg "call up_ihotel_up_exec_all('2016-11-1',2,45)" portal_ipms
			./seecfg "call up_ihotel_up_exec_all('2016-11-1',2,46)" portal_ipms
			./seecfg "call up_ihotel_up_exec_all('2016-11-1',2,47)" portal_ipms
			./seecfg "call up_ihotel_up_exec_all('2016-11-1',2,48)" portal_ipms			

			-- 9 机子
			./seecfg "call up_ihotel_up_xr_divide(9,'foxhis5')" portal_ipms
			
			./seecfg "call up_ihotel_up_exec_all('2016-11-1',2,35)" portal_ipms
			./seecfg "call up_ihotel_up_exec_all('2016-11-1',2,36)" portal_ipms
			./seecfg "call up_ihotel_up_exec_all('2016-11-1',2,37)" portal_ipms
			./seecfg "call up_ihotel_up_exec_all('2016-11-1',2,38)" portal_ipms
			./seecfg "call up_ihotel_up_exec_all('2016-11-1',2,39)" portal_ipms
			./seecfg "call up_ihotel_up_exec_all('2016-11-1',2,40)" portal_ipms		
		
		
	三、数据迁移后工作
		1.F6房态图 ---> 帮助  --->  重建 -- --> 
		  数据整理 ---> 客房状态重建 和 客房资源重建

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
		select class,sta,count(1) from master where accnt not like 'AR%' group by class,sta order by class,sta;
		select class,sta,sum(charge-credit) from master where accnt not like 'AR%' group by class,sta order by class,sta;
		select sum(charge-credit) from master where accnt not like 'AR%';
		select sum(charge-credit) from account where accnt not like 'AR%';
		select count(1) from account where accnt not like 'AR%';
			
		-- iHotel(SQLyog查看)
		SELECT rsv_class,sta,COUNT(1) FROM master_base WHERE hotel_group_id = 2 AND hotel_id = 9 GROUP BY rsv_class,sta ORDER BY 		rsv_class,sta;
		SELECT rsv_class,sta,SUM(charge-pay) FROM master_base WHERE hotel_group_id = 2 AND hotel_id = 9 GROUP BY rsv_class,sta ORDER BY 		rsv_class,sta;
		SELECT SUM(charge-pay) FROM master_base WHERE hotel_group_id = 2 AND hotel_id = 9;
		SELECT SUM(charge-pay) FROM account WHERE hotel_group_id = 2 AND hotel_id = 9;
		SELECT COUNT(1) FROM account WHERE hotel_group_id = 2 AND hotel_id = 9;
			
			
		-- 检查AR余额、数目
		-- 西软(PB查看)
		select class,sta,count(1) from master where accnt like 'AR%' group by class,sta order by class,sta;
		select class,sta,sum(charge-credit) from master where accnt like 'AR%' group by class,sta order by class,sta;
		select sum(charge-credit) from master where accnt like 'AR%';
		select sum(charge-credit) from account where accnt like 'AR%';
		select count(1) from account where accnt like 'AR%';
		-- iHotel(SQLyog查看)
		SELECT ar_category,SUM(charge-pay) FROM ar_master WHERE hotel_group_id = 2 AND hotel_id = 9 AND sta='I' GROUP BY ar_category ORDER BY 		ar_category;
		SELECT ar_category,COUNT(1) FROM ar_master WHERE hotel_group_id = 2 AND hotel_id = 9 AND sta='I' GROUP BY ar_category ORDER BY ar_category;	
		SELECT 1,SUM(charge-pay) FROM ar_master WHERE hotel_group_id = 2 AND hotel_id = 9
		UNION ALL
		SELECT 2,SUM(charge + charge0 - pay - pay0) FROM ar_account WHERE hotel_group_id = 2 AND hotel_id = 9;
			
	数据导入后对照原系统房态图作相应修改
	客房中心和商务中心对应的accnt要修改

	1.消费帐的个数，余额
	2.在住客人的个人，余额，信用
	3.挂S账的账户余额，信用
	4.AR账户的个数，余额
	5.房类资源(房态图，客房可用)
	
	四、iHotel第一夜审后的余额修复
		./seecfg "call ihotel_up_bal_maint(2,9)" portal_ipms

	检查：
	1、早餐包价自动核销
	SELECT * FROM sys_option WHERE hotel_id = 9 AND catalog = 'account' AND item = 'package_chargeoff_mode'；
	2、应收帐管理信用卡；
	3、房类分析过程启用；
	4、集团分析过程启用；