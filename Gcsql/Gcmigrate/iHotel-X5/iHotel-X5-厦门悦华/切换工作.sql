	һ���ܵ�Ǩ��ǰ����
		
		1.����������г��롢��Դ���Ƿ����;
		2.�����Ч״̬(N��X��W)�Ƿ��������;
			select a.accnt,a.sta,a.roomno,a.arr,a.dep,SUM(b.charge-b.credit) as balance from master a,account b 
				where a.accnt=b.accnt and a.sta not in ('R','I','S','O') group by a.accnt having(SUM(b.charge-b.credit))<>0;
		3.���AR�˹��������Ƿ�ʧ;
			select * from ar_master a where not exists (select 1 from guest b where a.haccnt=b.no AND b.class='R');
		4.���AR���������������ϸ����Ƿ�һ��
			SELECT a.accnt,a.balance,b.accnt1,b.balance1 FROM (SELECT accnt,SUM(charge - credit) AS balance FROM ar_master GROUP BY accnt) AS a,
			(SELECT accnt accnt1,SUM(charge+charge0 - charge9 - credit0 -credit + credit9) balance1 FROM ar_detail GROUP BY accnt) AS b
			WHERE a.accnt = b.accnt1 AND a.balance <> b.balance1;
		5.���AR���Ƿ��Դ���δ��˵�AR��;
		6.����ʱ��ͣ���Զ��������õ���ؽӿ�:�绰�ӿڡ�VOD�ӿڡ������ӿ�;
		7.��ϵͳ��һ��dump����;
			6.1 ����dump (192.168.88.100):./dump foxhis ������dump��ɺ󣬿��ڷ�����(192.168.88.99)����ftp:./fptg 192.168.88.100 foxhis
			6.2 ���sqledit����,�Ƿ�ָ����ʽ��;
		8.������ʽ�⿪ʼ�ܵ�Ǩ��;
		9.Ǩ����ɺ����migrate_xmyh��һ��dump��./mdump migrate_xmyh
		10.ִ�������ű�ʱ��ע��ҹ��ǰ������ҹ���ĳ�ʼ������ʱ��;
		
		11.����������˺��Ƿ��ڵ�ǰ�����������
		select 'I',a.pcrec,count(1) from master a where a.pcrec not in (select b.accnt from master b ) and a.pcrec<>'' and a.sta='I' group by a.pcrec having (count(1))>1 ;
		select 'S',a.pcrec,count(1) from master a where a.pcrec not in (select b.accnt from master b ) and a.pcrec<>'' and a.sta='S' group by a.pcrec having (count(1))>1 ;

		select * from master WHERE pcrec = ?;			
				
		SELECT * FROM up_map_accnt WHERE hotel_id=1 AND accnt_old IN ('F402260108','F402250184','F402250185');

		SELECT * FROM master_base WHERE id IN (?,?);
		

		1����ʷ��������2013.1.1��֮�������෿���롢��ס��������2��
		2��Э�鵥λ�������Ŀ������Ĺ�˾��
				
		
	�����ܵ�Ǩ�ƺ�����Ǩ��ǰ����
		1.�����ر��Ƿ�ܵ�Ǩ����ȫ;
		2.Ϊ��ر�������;
			CREATE INDEX index_yh ON migrate_xmyh.guest(class,ident);
			CREATE INDEX index_yh ON migrate_xmyh.account(accntof);
		3.���iHotel����Ƿ�����Ҫ������;
			CREATE INDEX index_yh1 ON guest_base(hotel_group_id,hotel_id,name,id_no);
			CREATE INDEX index_yh ON company_base(hotel_group_id,hotel_id,name);
			CREATE INDEX index_yh ON ar_account(hotel_group_id,hotel_id,ta_code);
			CREATE INDEX index_yh ON ar_detail(hotel_group_id,hotel_id,ta_code);
			CREATE INDEX index_yh ON guest_base(hotel_group_id,company_id); -- ��ʷ����Э�鵥λ��Э�鵥λ�Ÿ���

	/* ====================================================================
	   ����һ:��Pietty��ִ������ 
	   ==================================================================== */
		== ��������
		./seecfg "call up_ihotel_up_code_init_yh(1,1)" portal
		./seecfg "call up_ihotel_up_guest_fit_yh(1,1)" portal
		./seecfg "call up_ihotel_up_guest_grp_yh(1,1)" portal
		./seecfg "call up_ihotel_up_company_yh(1,1)" portal
		== Ͷ�߼�¼Ǩ�� �ŷ�Ҫ�����
		
		./seecfg "call up_ihotel_up_master_ha_yh(1,1)" portal
		./seecfg "call up_ihotel_up_master_r_yh(1,1)" portal
		./seecfg "call up_ihotel_up_master_si_yh(1,1)" portal
		./seecfg "call up_ihotel_up_rmrsv_rsv_src_yh(1,1)" portal
		./seecfg "call up_ihotel_up_fo_account_yh(1,1)" portal
		./seecfg "call up_ihotel_up_armst_yh(1,1)" portal
		./seecfg "call up_ihotel_up_code_maint_yh(1,1)" portal
		== ��ʷ��¼��Ϣ
		./seecfg "call ihotel_up_gold(1,1)" portal
		./seecfg "call ihotel_up_guest_xfttl_x5(1,1)" portal
		
		
		./seecfg "call ihotel_master_history_x5(1,1)" portal
	
	F6��̬ͼ ---> ����  --->  �ؽ�
	�������� ---> �ؽ��ͷ�״̬ ---> �ͷ���Դ�ؽ� ---> �����ؽ�

	-- ҹ���(�ڶ���),��ʼ�ܵ�Ǩ��(gc_migrate_x5_report.pbl),Ǩ����ɺ������¹���
		CALL portal.ihotel_up_report_import_x5(1,1);
	-- ִ��ihotel_up_mstbalance,�޸�����
		
	��������Ǩ�ƺ���
		1.F6��̬ͼ ---> ����  --->  �ؽ�
		  �������� ---> �ؽ��ͷ�״̬ ---> �ͷ���Դ�ؽ� ---> �����ؽ�
		  �������� ---> ���˷�δ���˺ͼ������һ���� --> ͣ��
		2.��Զ�ѡ�İ��۽����ֹ��޸�;
			SELECT id,rmno,packages FROM master_base WHERE hotel_group_id = 2 AND hotel_id = 9 AND packages REGEXP '[,]';
			SELECT id,rmno,packages FROM rsv_src WHERE hotel_group_id = 2 AND hotel_id = 9 AND packages REGEXP '[,]';
		3.Э�鵥λ��Ŀ�������ݼ��;
		4.ά�޷�������������ʱ̬������Ҫ���޸�;
		5.�����˻�����������޸�;
		6.����ģ�顢״̬���;
		-- ���������״̬��Ŀ�����
		-- ����(PB�鿴)
		select class,sta,count(1) from master group by class,sta order by class,sta;
		select class,sta,sum(charge-credit) from master group by class,sta order by class,sta;
		select sum(charge-credit) from master;
		select sum(charge-credit) from account;
		select count(1) from account;
			
		-- iHotel(SQLyog�鿴)
			SELECT rsv_class,sta,COUNT(1) FROM master_base WHERE hotel_group_id = 1 AND hotel_id = 1 GROUP BY rsv_class,sta ORDER BY 		rsv_class,sta;
		SELECT rsv_class,sta,SUM(charge-pay) FROM master_base WHERE hotel_group_id = 1 AND hotel_id = 1 GROUP BY rsv_class,sta ORDER BY 		rsv_class,sta;
		SELECT SUM(charge-pay) FROM master_base WHERE hotel_group_id = 1 AND hotel_id = 1;
		SELECT SUM(charge-pay) FROM account WHERE hotel_group_id = 1 AND hotel_id = 1;
		SELECT COUNT(1) FROM account WHERE hotel_group_id = 1 AND hotel_id = 1;
			
			
		-- ���AR����Ŀ
		-- ����(PB�鿴)
		select artag1,sum(charge-credit) from ar_master where sta='I' group by artag1 order by artag1;
		select artag1,count(1) from ar_master where sta='I' group by artag1 order by artag1;
		select sum(charge-credit) from ar_master where sta='I' ;
		select 1,sum(charge-credit) from ar_master where sta='I'  
		union all
		select 2,sum(a.charge + a.charge0 - a.credit - a.credit0) from ar_detail a,ar_master b where a.accnt=b.accnt ; 
		-- iHotel(SQLyog�鿴)
		SELECT ar_category,SUM(charge-pay) FROM ar_master WHERE hotel_group_id = 1 AND hotel_id = 1 AND sta='I' GROUP BY ar_category ORDER BY 		ar_category;
		SELECT ar_category,COUNT(1) FROM ar_master WHERE hotel_group_id = 1 AND hotel_id = 1 AND sta='I' GROUP BY ar_category ORDER BY ar_category;	
		SELECT 1,SUM(charge-pay) FROM ar_master WHERE hotel_group_id = 1 AND hotel_id = 1
		UNION ALL
		SELECT 2,SUM(charge + charge0 - pay - pay0) FROM ar_account WHERE hotel_group_id = 1 AND hotel_id = 1;
			
	���ݵ�������ԭϵͳ��̬ͼ����Ӧ�޸�
	�ͷ����ĺ��������Ķ�Ӧ��accntҪ�޸�

	1.�����ʵĸ��������
	2.��ס���˵ĸ��ˣ�������
	3.��S�˵��˻�������
	4.AR�˻��ĸ��������
	5.������Դ(��̬ͼ���ͷ�����)
	
	/* ====================================================================
		��������Ա
	   ==================================================================== */	
	1��saleid���뵽�м��
	2��������ԭϵͳһ���ķ���(����һ������Ҫ������ձ�)
	3����Ҫ���뵽sales_man��sales_man_business

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


	��飺
	1����Ͱ����Զ�����
	SELECT * FROM sys_option WHERE hotel_id = 13 AND catalog = 'account' AND item = 'package_chargeoff_mode'��
	2��Ӧ���ʹ������ÿ���
	3����������������ã�
	4�����ŷ����������ã�