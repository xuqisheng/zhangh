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
			6.1 ����dump (192.168.10.6):./dump foxhis ������dump��ɺ󣬿��ڷ�����(192.168.10.16)����ftp:./fptg 192.168.10.6 foxhis
			6.2 ���sqledit����,�Ƿ�ָ����ʽ��;
		8.������ʽ�⿪ʼ�ܵ�Ǩ��;
		11.Ǩ����ɺ����migrate_db��һ��dump��./mdump migrate_db
		10.ִ�������ű�ʱ��ע��ҹ��ǰ������ҹ���ĳ�ʼ������ʱ��;
		
		11.����������˺��Ƿ��ڵ�ǰ�����������
		select 'I',a.pcrec,count(1) from master a where a.pcrec not in (select b.accnt from master b ) and a.pcrec<>'' and a.sta='I' group by a.pcrec having (count(1))>1 ;
		select 'S',a.pcrec,count(1) from master a where a.pcrec not in (select b.accnt from master b ) and a.pcrec<>'' and a.sta='S' group by a.pcrec having (count(1))>1 ;

		select * from master WHERE pcrec = ?;			
				
		SELECT * FROM up_map_accnt WHERE hotel_id=11 AND accnt_old IN ('F11E0200511');

		SELECT * FROM master_base WHERE id IN (?,?);				
		
	�����ܵ�Ǩ�ƺ�����Ǩ��ǰ����
		1.�����ر��Ƿ�ܵ�Ǩ����ȫ;
		2.Ϊ��ر�������;
			CREATE INDEX index_x5 ON migrate_db.guest(class,ident,mobile,phone);
			CREATE INDEX index_x5 ON migrate_db.account(accntof);
	/* ===============================================================
	   ����һ:��Pietty��ִ������ 
	   =============================================================== */
		./seecfg "call ihotel_up_code_init_x5(2,11,'2016-11-21')" portal_pms
		./seecfg "call ihotel_up_guest_fit_x5(2,11)" portal_pms
		./seecfg "call ihotel_up_guest_grp_x5(2,11)" portal_pms
		
		./seecfg "call ihotel_up_company_x5(2,11)" portal_group
		
		./seecfg "call ihotel_up_master_ha_x5(2,11)" portal_pms
		./seecfg "call ihotel_up_master_r_x5(2,11)" portal_pms
		./seecfg "call ihotel_up_master_si_x5(2,11)" portal_pms
		./seecfg "call ihotel_up_rmrsv_rsv_src_x5(2,11)" portal_pms
		./seecfg "call ihotel_up_fo_account_x5(2,11)" portal_pms
		./seecfg "call ihotel_up_armst_x5(2,11)" portal_pms
		./seecfg "call ihotel_up_code_maint_x5(2,11)" portal_pms
		
		
		./seecfg "call ihotel_up_guest_xfttl_x5(2,11)" portal_pms		
		
		
		./seecfg "call ihotel_master_history_x5(2,11)" portal_pms
		./seecfg "call ihotel_up_guest_cusxf_x5(2,11)" portal_pms
		
	F6��̬ͼ ---> ����  --->  �ؽ�
	�������� ---> �ؽ��ͷ�״̬ ---> �ͷ���Դ�ؽ� ---> �����ؽ�

	-- ҹ���(�ڶ���),��ʼ�ܵ�Ǩ��(gc_migrate_db_report.pbl),Ǩ����ɺ������¹���
		CALL portal_pms.ihotel_up_report_import_x5(2,11);
	-- ִ��ihotel_up_mstbalance,�޸�����
		
	��������Ǩ�ƺ���
		1.F6��̬ͼ ---> ����  --->  �ؽ�
		  �������� ---> �ؽ��ͷ�״̬ ---> �ͷ���Դ�ؽ� ---> �����ؽ�
		  �������� ---> ���˷�δ���˺ͼ������һ���� --> ͣ��
		2.��Զ�ѡ�İ��۽����ֹ��޸�;
			SELECT id,rmno,packages FROM master_base WHERE hotel_group_id = 2 AND hotel_id = 11 AND packages REGEXP '[,]';
			SELECT id,rmno,packages FROM rsv_src WHERE hotel_group_id = 2 AND hotel_id = 11 AND packages REGEXP '[,]';
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
		SELECT rsv_class,sta,COUNT(1) FROM master_base WHERE hotel_group_id = 2 AND hotel_id = 11 GROUP BY rsv_class,sta ORDER BY rsv_class,sta;
		SELECT rsv_class,sta,SUM(charge-pay) FROM master_base WHERE hotel_group_id = 2 AND hotel_id = 11 GROUP BY rsv_class,sta ORDER BY rsv_class,sta;
		SELECT SUM(charge-pay) FROM master_base WHERE hotel_group_id = 2 AND hotel_id = 11;
		SELECT SUM(charge-pay) FROM account WHERE hotel_group_id = 2 AND hotel_id = 11;
		SELECT COUNT(1) FROM account WHERE hotel_group_id = 2 AND hotel_id = 11;
			
		-- ���AR����Ŀ
		-- ����(PB�鿴)
		select artag1,sum(charge-credit) from ar_master where sta='I' group by artag1 order by artag1;
		select artag1,count(1) from ar_master where sta='I' group by artag1 order by artag1;
		select sum(charge-credit) from ar_master where sta='I' AND artag1 NOT IN ('5','B');
		select 1,sum(charge-credit) from ar_master where sta='I' and artag1 NOT IN ('5','B')
		union all
		select 2,sum(a.charge + a.charge0 - a.credit - a.credit0) from ar_detail a,ar_master b where a.accnt=b.accnt and b.artag1 not in ('LO'); 
		-- iHotel(SQLyog�鿴)
		SELECT ar_category,SUM(charge-pay) FROM ar_master WHERE hotel_group_id = 2 AND hotel_id = 11 AND sta='I' GROUP BY ar_category ORDER BY ar_category;
		SELECT ar_category,COUNT(1) FROM ar_master WHERE hotel_group_id = 2 AND hotel_id = 11 AND sta='I' GROUP BY ar_category ORDER BY ar_category;	
		SELECT 1,SUM(charge-pay) FROM ar_master WHERE hotel_group_id = 2 AND hotel_id = 11
		UNION ALL
		SELECT 2,SUM(charge + charge0 - pay - pay0) FROM ar_account WHERE hotel_group_id = 2 AND hotel_id = 11;
			
	���ݵ�������ԭϵͳ��̬ͼ����Ӧ�޸�
	�ͷ����ĺ��������Ķ�Ӧ��accntҪ�޸�

	1.�����ʵĸ��������
	2.��ס���˵ĸ��ˣ�������
	3.��S�˵��˻�������
	4.AR�˻��ĸ��������
	5.������Դ(��̬ͼ���ͷ�����)
	