	һ���ܵ�Ǩ��ǰ����
		1.����foxhis������dump����
		2.�ܵ�Ǩ�ƺ�,migrate_xc Ҳ������
		3.iHotel�����ε�ҹ�����Ƿ��		
		4.����������г��롢��Դ���Ƿ����;
		5.�����Ч״̬(N��X��W)�Ƿ��������;
			select a.accnt,a.sta,a.roomno,a.arr,a.dep,SUM(b.charge-b.credit) as balance from master a,account b 
				where a.accnt=b.accnt and a.sta not in ('R','I','S','O') group by a.accnt having(SUM(b.charge-b.credit))<>0;
		6.���AR�˹��������Ƿ�ʧ;
			select * from master a where not exists(select 1 from guest b where a.haccnt=b.no AND b.class='R') and a.accnt like 'AR%';		
		7.��������������ϸ����Ƿ�һ��,�������͡������ˡ�AR��
			SELECT a.accnt,a.balance,b.accnt1,b.balance1 FROM (SELECT accnt,SUM(charge - credit) AS balance FROM master GROUP BY accnt) AS a,
			(SELECT accnt accnt1,SUM(charge-credit) balance1 FROM account GROUP BY accnt) AS b
			WHERE a.accnt = b.accnt1 AND a.balance <> b.balance1;
		8.�ܹ��Զ��������õ���ؽӿ��Ƿ�ͣ��,����:�绰��VOD�������ӿڵȵ�
		9.������ʽ�⿪ʼ�ܵ�Ǩ��;
		10.Ǩ����ɺ����migrate_xc��һ��dump��./mdump migrate_yl
		11.ִ�������ű�ʱ��ע��ҹ��ǰ������ҹ���ĳ�ʼ������ʱ�� (Ŀǰ�����ϰ��������ҹ���Ǩ������,����޸���ʵ��Ϊ��)
		12.����������˺��Ƿ��ڵ�ǰ�����������
		select 'I',a.pcrec,count(1) from master a where a.pcrec not in (select b.accnt from master b ) and a.pcrec<>'' and a.sta='I' group by a.pcrec having (count(1))>1 ;
		select 'S',a.pcrec,count(1) from master a where a.pcrec not in (select b.accnt from master b ) and a.pcrec<>'' and a.sta='S' group by a.pcrec having (count(1))>1 ;

		-- �����޸�
		select * from master WHERE pcrec = ?;
	
		-- �º��޸�	
		SELECT * FROM up_map_accnt WHERE hotel_id=9 AND accnt_old IN ('F402260108','F402250184','F402250185');
		SELECT * FROM master_base WHERE id IN (?,?);				
		
	�����ܵ�Ǩ�ƺ�����Ǩ��ǰ����
		1.�����ر��Ƿ�ܵ�Ǩ����ȫ;
		2.Ϊ��ر�������;
			CREATE INDEX index_yl ON migrate_yl.guest(class,ident);
			CREATE INDEX index_yl ON migrate_yl.account(accntof);
		3.���iHotel����Ƿ�����Ҫ������;
			CREATE INDEX index_d1 ON guest_base(hotel_group_id,hotel_id,name,id_no);
			CREATE INDEX index_d2 ON guest_base(hotel_group_id,hotel_id,company_id);
			CREATE INDEX index_d ON company_base(hotel_group_id,hotel_id,name);
			CREATE INDEX index_d ON ar_account(hotel_group_id,hotel_id,ta_code);
			CREATE INDEX index_d ON ar_detail(hotel_group_id,hotel_id,ta_code);
			

	/* ====================================================================
	   ����һ:�� Pietty ��ִ������ 
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
		
		
	F6��̬ͼ ---> ����  --->  �ؽ�
	�������� ---> �ؽ��ͷ�״̬ ---> �ͷ���Դ�ؽ� ---> �����ؽ�

	-- ҹ���(�ڶ���),��ʼ�ܵ�Ǩ��(gc_migrate_smart_report.pbl),Ǩ����ɺ������¹���
		CALL portal.ihotel_up_report_import_smart(1,111);
	-- ִ��ihotel_up_mstbalance,�޸�����
		
	��������Ǩ�ƺ���
		1.F6��̬ͼ ---> ����  --->  �ؽ�
		  �������� ---> �ؽ��ͷ�״̬ ---> �ͷ���Դ�ؽ� ---> �����ؽ�
		  �������� ---> ���˷�δ���˺ͼ������һ���� --> ͣ��  --> ��һҹ����ٴ�
		2.��Զ�ѡ�İ��۽����ֹ��޸�;
			SELECT id,rmno,packages FROM master_base WHERE hotel_group_id = 1 AND hotel_id = 111 AND packages REGEXP '[,]';
			SELECT id,rmno,packages FROM rsv_src WHERE hotel_group_id = 1 AND hotel_id = 111 AND packages REGEXP '[,]';
		3.Э�鵥λ��Ŀ�������ݼ��;
		4.ά�޷�������������ʱ̬������Ҫ���޸�;
		5.�����˻�����������޸�;
		6.����ģ�顢״̬���;
		-- ���������״̬��Ŀ�����
		-- ����(PB�鿴)
		select class,sta,count(1) from master where accnt not like 'AR%' group by class,sta order by class,sta;
		select class,sta,sum(charge-credit) from master where accnt not like 'AR%' group by class,sta order by class,sta;
		select sum(charge-credit) from master where accnt not like 'AR%';
		select sum(charge-credit) from account where accnt not like 'AR%';
		select count(1) from account where accnt not like 'AR%';
			
		-- iHotel(SQLyog�鿴)
		SELECT rsv_class,sta,COUNT(1) FROM master_base WHERE hotel_group_id = 1 AND hotel_id = 111 GROUP BY rsv_class,sta ORDER BY rsv_class,sta;
		SELECT rsv_class,sta,SUM(charge-pay) FROM master_base WHERE hotel_group_id = 1 AND hotel_id = 111 GROUP BY rsv_class,sta ORDER BY rsv_class,sta;
		SELECT SUM(charge-pay) FROM master_base WHERE hotel_group_id = 1 AND hotel_id = 111;
		SELECT SUM(charge-pay) FROM account WHERE hotel_group_id = 1 AND hotel_id = 111;
		SELECT COUNT(1) FROM account WHERE hotel_group_id = 1 AND hotel_id = 111;
			
		-- ���AR����Ŀ
		-- ����(PB�鿴)
		select artag1,sta,count(1) from master where accnt like 'AR%' group by artag1,sta order by artag1,sta;
		select artag1,sta,sum(charge-credit) from master where accnt like 'AR%' group by artag1,sta order by artag1,sta;
		select sum(charge-credit) from master where accnt like 'AR%';
		select sum(charge-credit) from account where accnt like 'AR%';
		select count(1) from account where accnt like 'AR%';
		-- iHotel(SQLyog�鿴)
		SELECT ar_category,SUM(charge-pay) FROM ar_master WHERE hotel_group_id = 1 AND hotel_id = 111 AND sta='I' GROUP BY ar_category ORDER BY ar_category;
		SELECT ar_category,COUNT(1) FROM ar_master WHERE hotel_group_id = 1 AND hotel_id = 111 AND sta='I' GROUP BY ar_category ORDER BY ar_category;	
		SELECT 1,SUM(charge-pay) FROM ar_master WHERE hotel_group_id = 1 AND hotel_id = 111
		UNION ALL
		SELECT 2,SUM(charge + charge0 - pay - pay0) FROM ar_account WHERE hotel_group_id = 1 AND hotel_id = 111;
			
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
	FROM migrate_yl.saleid;	 
	 
	INSERT INTO sales_man_business (hotel_group_id, hotel_id, sales_man, sta, dept, job, 
	sales_group, login_user, create_user, create_datetime, modify_user, modify_datetime) 
	SELECT 1,111,CODE,'I',IF(grp='A','X01','A01'),NULL,grp,empno,'ADMIN',NOW(),'ADMIN',NOW()
	FROM migrate_yl.saleid;
	
	X5 | Smart | C7 ��Ҫ���������
	channel ������
	idcode  ֤�����
	mktcode �г���
	srccode ��Դ��
	pccode  ������
	paymth  ������
	ratecode ������
	package  ����
	restype  Ԥ������
	rmtype   ����
	saleman ����Ա
	reason   �Ż�����
	country  ����
	nation   ����


	Vϵ�� ��Ҫ���������
	idcode  ֤�����
	mktcode ɢ���г���
	mktcode_g �Ŷ��г���
	pccode  ������
	paymth  ������
	ratecode ������
	rmtype   ����
	salesman ����Ա
	reason   �Ż�����
	country  ����
	nation   ����	