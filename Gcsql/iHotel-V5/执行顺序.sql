һ���ܵ�Ǩ��ǰ����
	1.����foxhis������dump����
	2.�ܵ�Ǩ�ƺ�,migrate_xc Ҳ������
	3.iHotel�����ε�ҹ�����Ƿ��
	4.����������г��롢��Դ���Ƿ����
	5.�����Ч״̬(N��X��W)�Ƿ��������,��������Ч״̬������,�������ȴ���;
		select a.accnt,a.sta,a.roomno,a.arr,a.dep,SUM(b.charge-b.credit) as balance from master a,account b 
			where a.accnt=b.accnt and a.sta not in ('R','I','S','O','H') group by a.accnt having(SUM(b.charge-b.credit))<>0;
	6.����Ƿ������Ч��Ԥ����Դ	
		select a.* from rsvgrp a where not exists (select 1 from typim b where a.type=b.type);
		delete from rsvgrp where not exists (select 1 from typim b where rsvgrp.type=b.type);
		
		select a.* FROM rsvdtl a where not exists (select 1 from typim b where a.type=b.type);
		delete from rsvdtl where not exists (select 1 from typim b where rsvdtl.type=b.type);
	7.���AR���������������ϸ����Ƿ�һ��,��X5�汾����Ҫ���AR���Ƿ���ȫ�����
		SELECT a.accnt,a.balance,b.accnt1,b.balance1 FROM (SELECT accnt,SUM(rmb_db-depr_cr-addrmb) AS balance FROM armst GROUP BY accnt) AS a,
		(SELECT accnt accnt1,SUM(charge-credit) balance1 FROM account GROUP BY accnt) AS b
		WHERE a.accnt = b.accnt1 AND a.balance <> b.balance1;
	8.�ܹ��Զ��������õ���ؽӿ��Ƿ�ͣ��,����:�绰��VOD�������ӿڵȵ�
	9.������ʽ�⿪ʼ�ܵ�Ǩ��;
	10.Ǩ����ɺ����migrate_xc��һ��dump��./mdump migrate_xc
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
	1�������عܵ��Ƿ�Ǩ����ȫ(hgstinf,hgstinf_xh,cusinf,master,guest..);
	2��Ϊ��ر���������
			CREATE INDEX index_xc ON migrate_xc.hgstinf(ident);
			CREATE INDEX index_xc ON migrate_xc.account(accntof);
	3.���iHotel����Ƿ�����Ҫ������;
			CREATE INDEX index_cm ON guest_base(hotel_group_id,hotel_id,name,id_no);
			CREATE INDEX index_cm ON company_base(hotel_group_id,hotel_id,name);
			CREATE INDEX index_cm ON ar_account(hotel_group_id,hotel_id,ta_code);
			CREATE INDEX index_cm ON ar_detail(hotel_group_id,hotel_id,ta_code);
			

	/* ====================================================================
		����һ:��Pietty��ִ������
		�ɽӦ�÷�����:ssh ms131
		�ű�ִ��ǰ���Ӫҵ���ڼ� up_map_code ��
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
		
	F6��̬ͼ ---> ����  --->  �ؽ�
	�������� ---> �ؽ��ͷ�״̬ ---> �ͷ���Դ�ؽ� ---> �����ؽ�
	�������� ---> ���˷�δ���˺ͼ������һ���� --> ͣ�� --> ��һ��ҹ���ٴ�

	-- ҹ���(�ڶ���),��ʼ�ܵ�Ǩ��(gc_migrate_v5_report.pbl),Ǩ����ɺ������¹���
	./seecfg "call ihotel_up_report_import_v5(1,105)" portal

	-- ִ��ihotel_up_mstbalance,�޸�����
		
	��������Ǩ�ƺ���
		1.F6��̬ͼ ---> ����  --->  �ؽ�
		  �������� ---> �ؽ��ͷ�״̬ ---> �ͷ���Դ�ؽ� ---> �����ؽ�
		  �������� ---> ���˷�δ���˺ͼ������һ���� --> ͣ��
		2.��Զ�ѡ�İ��۽����ֹ��޸�;
			SELECT id,rmno,packages FROM master_base WHERE hotel_group_id = 1 AND hotel_id = 105 AND packages REGEXP '[,]';
			SELECT id,rmno,packages FROM rsv_src WHERE hotel_group_id = 1 AND hotel_id = 105 AND packages REGEXP '[,]';
		3.Э�鵥λ��Ŀ�������ݼ��;
		4.ά�޷�������������ʱ̬������Ҫ���޸�;
		5.�����˻�����������޸�;
		6.����ģ�顢״̬���;
		-- ���������״̬��Ŀ�����
		-- ����(PB�鿴)
		select class,sta,count(1) from master group by class,sta order by class,sta;
		select class,sta,count(1) from grpmst group by class,sta order by class,sta;
		select class,sta,sum(rmb_db-depr_cr-addrmb) from master group by class,sta order by class,sta;
		select class,sta,sum(rmb_db-depr_cr-addrmb) from grpmst group by class,sta order by class,sta;
		select sum(rmb_db-depr_cr-addrmb) from master;
		select sum(rmb_db-depr_cr-addrmb) from grpmst;
		select sum(charge-credit) from account where accnt not like 'AR%';
		select count(1) from account;
			
		-- iHotel(SQLyog�鿴)
		SELECT rsv_class,sta,COUNT(1) FROM master_base WHERE hotel_group_id = 1 AND hotel_id = 105 GROUP BY rsv_class,sta ORDER BY rsv_class,sta;
		SELECT rsv_class,sta,SUM(charge-pay) FROM master_base WHERE hotel_group_id = 1 AND hotel_id = 105 GROUP BY rsv_class,sta ORDER BY rsv_class,sta;
		SELECT SUM(charge-pay) FROM master_base WHERE hotel_group_id = 1 AND hotel_id = 105;
		SELECT SUM(charge-pay) FROM account WHERE hotel_group_id = 1 AND hotel_id = 105;
		SELECT COUNT(1) FROM account WHERE hotel_group_id = 1 AND hotel_id = 105;
			
		-- ���AR����Ŀ
		-- ����(PB�鿴)		
		select tag0,COUNT(1) from armst group by tag0;
		select sum(charge-credit) from account where accnt not like 'AR%';
		select sum(rmb_db-depr_cr-addrmb) from armst;
		-- iHotel(SQLyog�鿴)
		SELECT ar_category,SUM(charge-pay) FROM ar_master WHERE hotel_group_id = 1 AND hotel_id = 105 AND sta='I' GROUP BY ar_category ORDER BY ar_category;
		SELECT ar_category,COUNT(1) FROM ar_master WHERE hotel_group_id = 1 AND hotel_id = 105 AND sta='I' GROUP BY ar_category ORDER BY ar_category;	
		SELECT 1,SUM(charge-pay) FROM ar_master WHERE hotel_group_id = 1 AND hotel_id = 105
		UNION ALL
		SELECT 2,SUM(charge + charge0 - pay - pay0) FROM ar_account WHERE hotel_group_id = 1 AND hotel_id = 105;
		
		-- �鿴ͬס�Ƿ���ȷ
		SELECT id,rmno,master_id,rsv_no FROM master_base AS a WHERE hotel_group_id=1 AND hotel_id = 105 AND rsv_class =  'F' AND sta = 'I' AND rsv_id <> id
		AND EXISTS (SELECT 1 FROM master_base WHERE hotel_group_id=1 AND hotel_id = 105 AND rsv_class =  'F' AND sta = 'I' AND rsv_id <> id
		AND rmno = a.rmno AND master_id <> a.master_id);
		-- ������������Ƿ��ʵ��һ��
		SELECT a.id,a.rsv_id,a.rmtype,b.rmtype,c.code_old,c.code_new FROM master_base a,room_no b,up_map_code c 
		WHERE a.hotel_group_id = 1 AND a.hotel_id = 105 AND b.hotel_group_id = 1 AND
		b.hotel_id = 105 AND c.hotel_group_id = 1 AND c.hotel_id = 105 AND c.cat = 'rmtype' AND b.rmtype = c.code_new
		AND a.rmno = b.code AND a.rmtype <> b.rmtype;
		
		-- ����Ƿ����δƥ��ķ�����򸶿���
		SELECT * FROM account a WHERE a.hotel_group_id = 1 AND a.hotel_id = 105 
			AND NOT EXISTS(SELECT 1 FROM code_transaction b WHERE b.hotel_group_id=1 AND b.hotel_id=105 AND b.is_halt='F' AND a.ta_code=b.code);
		SELECT * FROM ar_account a WHERE a.hotel_group_id = 1 AND a.hotel_id = 105 
			AND NOT EXISTS(SELECT 1 FROM code_transaction b WHERE b.hotel_group_id=1 AND b.hotel_id=105 AND b.is_halt='F' AND a.ta_code=b.code);	
		SELECT * FROM ar_detail a WHERE a.hotel_group_id = 1 AND a.hotel_id = 105 
			AND NOT EXISTS(SELECT 1 FROM code_transaction b WHERE b.hotel_group_id=1 AND b.hotel_id=105 AND b.is_halt='F' AND a.ta_code=b.code);
		-- ���arrange_code�Ƿ�δ����
		SELECT * FROM ar_account a,code_transaction b WHERE a.hotel_group_id = 1 AND a.hotel_id = 105 AND b.hotel_group_id = 1 AND b.hotel_id = 105
			AND a.arrage_code = '' AND a.ta_code = b.code;
		SELECT * FROM account a,code_transaction b WHERE a.hotel_group_id = 1 AND a.hotel_id = 105 AND b.hotel_group_id = 1 AND b.hotel_id = 105
			AND a.arrange_code = '' AND a.ta_code = b.code;
		SELECT * FROM ar_detail a,code_transaction b WHERE a.hotel_group_id = 1 AND a.hotel_id = 105 AND b.hotel_group_id = 1 AND b.hotel_id = 105
			AND a.arrange_code = '' AND a.ta_code = b.code;
			
		-- ����������
		SELECT accnt,TYPE,sta,roomno,pcrec FROM migrate_xc.master WHERE sta IN('I','O','S') AND pcrec <> '' 
		AND pcrec NOT IN (SELECT LEFT(accnt_old,7) FROM up_map_accnt WHERE hotel_group_id = 1 AND hotel_id = 105 
		AND accnt_type IN ('master_si','master_r','consume')) AND sta <> 'O' ORDER BY sta,roomno;
			
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
	FROM migrate_xc.saleid;	 
	 
	INSERT INTO sales_man_business (hotel_group_id, hotel_id, sales_man, sta, dept, job, 
	sales_group, login_user, create_user, create_datetime, modify_user, modify_datetime) 
	SELECT 2,9,CODE,'I',IF(grp='A','X01','A01'),NULL,grp,empno,'ADMIN',NOW(),'ADMIN',NOW()
	FROM migrate_xc.saleid;	
	
	/*=============�޸�2014.5.5==============*/
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