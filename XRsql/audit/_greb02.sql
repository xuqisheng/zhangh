------------------------------------------------------------------
-- (��)��������ҵ���ؽ� -(��)  ִ�в��� 
------------------------------------------------------------------

-- ��� master_income ҲҪ�ؽ������Կ���ִ�� p_cqf_master_income_reb !!!! 

--1. ���� hmst, ���: select * from gdsmsg; 
//exec p_greb01;


--2. ���� hmst ���� 
//if not exists(select 1 from sysindexes where id=object_id('hmst') AND name='accnt1')
//	create index accnt1 on hmst(accnt1);
//if not exists(select 1 from sysindexes where id=object_id('hmst') AND name='haccnt')
//	create index haccnt on hmst(haccnt);
//if not exists(select 1 from sysindexes where id=object_id('hmst') AND name='cusno')
//	create index cusno on hmst(cusno);
//if not exists(select 1 from sysindexes where id=object_id('hmst') AND name='agent')
//	create index agent on hmst(agent);
//if not exists(select 1 from sysindexes where id=object_id('hmst') AND name='source')
//	create index source on hmst(source);


--3. ���� guest_xfttl �Ǽ�  ���: select * from process_flag where flag='guest_reb';    
//exec p_greb02;

--4. �������Ѽ�¼��guest, guest_xfttl  ���: select * from process_flag where flag='guest_reb';     
//exec p_greb03;

--5. �������� 
//delete guest_xfttl where m1=0 and m2=0 and m3=0 and m4=0 and m5=0 and m6=0 and m7=0 and m8=0 and m9=0 and m10=0 and m11=0 and m12=0; 
//update guest_xfttl set ttl = m1+m2+m3+m4+m5+m6+m7+m8+m9+m10+m11+m12;
//IF OBJECT_ID('hmst') IS NOT NULL
//    DROP table hmst;
//IF OBJECT_ID('p_greb01') IS NOT NULL
//    DROP PROCEDURE p_greb01;
//IF OBJECT_ID('p_greb02') IS NOT NULL
//    DROP PROCEDURE p_greb02;
//IF OBJECT_ID('p_greb03') IS NOT NULL
//    DROP PROCEDURE p_greb03;
