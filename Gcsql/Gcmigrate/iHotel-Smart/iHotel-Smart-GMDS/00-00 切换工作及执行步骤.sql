	һ���ܵ�Ǩ��ǰ����
		1.����������г��롢��Դ���Ƿ����;
		2.�����Ч״̬(N��X��W)�Ƿ��������;
			select a.accnt,a.sta,a.roomno,a.arr,a.dep,SUM(b.charge-b.credit) as balance from master a,account b 
				where a.accnt=b.accnt and a.sta not in ('R','I','S','O') group by a.accnt having(SUM(b.charge-b.credit))<>0;
						
		3.���AR�˹��������Ƿ�ʧ;
			SELECT * FROM master a WHERE NOT EXISTS (SELECT 1 FROM guest b WHERE a.haccnt=b.no AND b.class='R') AND accnt LIKE 'AR%';
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
		9.Ǩ����ɺ����migrate_db��һ��dump��./mdump migrate_db
		10.ִ�������ű�ʱ��ע��ҹ��ǰ������ҹ���ĳ�ʼ������ʱ��;
		
		11.����������˺��Ƿ��ڵ�ǰ�����������
		select 'I',a.pcrec,count(1) from master a where a.pcrec not in (select b.accnt from master b ) and a.pcrec<>'' and a.sta='I' group by a.pcrec having (count(1))>1 ;
		select 'S',a.pcrec,count(1) from master a where a.pcrec not in (select b.accnt from master b ) and a.pcrec<>'' and a.sta='S' group by a.pcrec having (count(1))>1 ;

		select * from master WHERE pcrec IN ();
				
		SELECT * FROM up_map_accnt WHERE hotel_id=9 AND accnt_old IN ('F402260108','F402250184','F402250185');

		SELECT * FROM master_base WHERE id IN (?,?);
				
		
	�����ܵ�Ǩ�ƺ�����Ǩ��ǰ����
		1.�����ر��Ƿ�ܵ�Ǩ����ȫ;
		2.Ϊ��ر�������;
			CREATE INDEX index_bs ON migrate_db.guest(class,ident);
			CREATE INDEX index_bs ON migrate_db.account(accntof);
			CREATE INDEX haccnt ON migrate_db.master(haccnt);

		3.���iHotel����Ƿ�����Ҫ������;
			CREATE INDEX index_bs ON guest_base(hotel_group_id,hotel_id,name,id_no);
			CREATE INDEX index_bs ON company_base(hotel_group_id,hotel_id,name);
			CREATE INDEX index_bs ON ar_account(hotel_group_id,hotel_id,ta_code);
			CREATE INDEX index_bs ON ar_detail(hotel_group_id,hotel_id,ta_code);
			CREATE INDEX index_bs ON guest_base(hotel_group_id,company_id); -- ��ʷ����Э�鵥λ��Э�鵥λ�Ÿ���

	/* ====================================================================
	   ����һ:��Pietty��ִ������ 
	   ==================================================================== */
      -- CALL up_exec('up_ihotel_init','9')

		
		./seecfg "call up_ihotel_up_code_init(2,9,'2016-9-26')" portal_pms
		./seecfg "call up_ihotel_up_guest_fit(2,9)" portal_pms
		./seecfg "call up_ihotel_up_guest_grp(2,9)" portal_pms
	   
		./seecfg "call up_ihotel_up_company(2,9)" portal_group

		./seecfg "call up_ihotel_up_master_ha(2,9)" portal_pms
		./seecfg "call up_ihotel_up_master_r(2,9)" portal_pms
		./seecfg "call up_ihotel_up_master_si(2,9)" portal_pms
		./seecfg "call up_ihotel_up_rmrsv_rsv_src(2,9)" portal_pms
		./seecfg "call up_ihotel_up_fo_account(2,9)" portal_pms
		./seecfg "call up_ihotel_up_armst(2,9)" portal_pms
		
		./seecfg "call ihotel_up_code_maint(2,9)" portal_pms		
		./seecfg "call up_ihotel_rsvrate_reb(2,9,@a)" portal_pms		
		
		
	��������Ǩ�ƺ���
		1.F6��̬ͼ ---> ����  --->  �ؽ� -- --> �������� ---> ��Դ�ؽ� �� �ͷ�״̬�ؽ�


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
		select class,sta,count(1) from master where accnt not like 'AR%' group by class,sta order by class,sta;
		select class,sta,sum(charge-credit) from master where accnt not like 'AR%' group by class,sta order by class,sta;
		select sum(charge-credit) from master where accnt not like 'AR%';
		select sum(charge-credit) from account where accnt not like 'AR%';
		select count(1) from account where accnt not like 'AR%';
			
		-- iHotel(SQLyog�鿴)
		SELECT rsv_class,sta,COUNT(1) FROM master_base WHERE hotel_group_id = 2 AND hotel_id = 9 GROUP BY rsv_class,sta ORDER BY 		rsv_class,sta;
		SELECT rsv_class,sta,SUM(charge-pay) FROM master_base WHERE hotel_group_id = 2 AND hotel_id = 9 GROUP BY rsv_class,sta ORDER BY 		rsv_class,sta;
		SELECT SUM(charge-pay) FROM master_base WHERE hotel_group_id = 2 AND hotel_id = 9;
		SELECT SUM(charge-pay) FROM account WHERE hotel_group_id = 2 AND hotel_id = 9;
		SELECT COUNT(1) FROM account WHERE hotel_group_id = 2 AND hotel_id = 9;
			
			
		-- ���AR����Ŀ
		-- ����(PB�鿴)
		select class,sta,count(1) from master where accnt like 'AR%' group by class,sta order by class,sta;
		select class,sta,sum(charge-credit) from master where accnt like 'AR%' group by class,sta order by class,sta;
		select sum(charge-credit) from master where accnt like 'AR%';
		select sum(charge-credit) from account where accnt like 'AR%';
		select count(1) from account where accnt like 'AR%';
		-- iHotel(SQLyog�鿴)
		SELECT ar_category,SUM(charge-pay) FROM ar_master WHERE hotel_group_id = 2 AND hotel_id = 9 AND sta='I' GROUP BY ar_category ORDER BY 		ar_category;
		SELECT ar_category,COUNT(1) FROM ar_master WHERE hotel_group_id = 2 AND hotel_id = 9 AND sta='I' GROUP BY ar_category ORDER BY ar_category;	
		SELECT 1,SUM(charge-pay) FROM ar_master WHERE hotel_group_id = 2 AND hotel_id = 9
		UNION ALL
		SELECT 2,SUM(charge + charge0 - pay - pay0) FROM ar_account WHERE hotel_group_id = 2 AND hotel_id = 9;
			
	���ݵ�������ԭϵͳ��̬ͼ����Ӧ�޸�
	�ͷ����ĺ��������Ķ�Ӧ��accntҪ�޸�

	1.�����ʵĸ��������
	2.��ס���˵ĸ��ˣ�������
	3.��S�˵��˻�������
	4.AR�˻��ĸ��������
	5.������Դ(��̬ͼ���ͷ�����)
	
	�ġ�iHotel��һҹ��������޸�
		./seecfg "call ihotel_up_bal_maint(2,9)" portal_pms

	��飺
	1����Ͱ����Զ�����
	SELECT * FROM sys_option WHERE hotel_id = 9 AND catalog = 'account' AND item = 'package_chargeoff_mode'��
	2��Ӧ���ʹ������ÿ���
	3����������������ã�
	4�����ŷ����������ã�