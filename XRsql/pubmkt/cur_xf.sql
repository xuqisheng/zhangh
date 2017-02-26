
------------------------------------------------------------------------------------
-- 2008.4.12  �����ݣ��� act_bal ��������ݲ��룬ͬʱ���Ӹ���ͳ�ƴ��� 
------------------------------------------------------------------------------------

if exists(select 1 from sysobjects where name='cus_xf' and type='U')
	drop table cus_xf;
CREATE TABLE cus_xf 
(
	date    	datetime 					not null,

	actcls  	char(1)  	default 'F'	 not null,		-- �˻����� F, P, B
	accnt		char(10)						not null,		-- ǰ̨�˺š��������š�bos���ŵȵ�
   sta		char(1)  	default '' not null,
   name     varchar(50) default '' null,

	master	char(10)		default ''	not null,		-- ǰ̨�ж�ͬס
	groupno	char(10)		default ''	not null,		-- ǰ̨�˺ų�Ա�������˺�

	type		char(5)		default ''	not null,		-- ����
	up_type	char(5)     default ''	null,  			-- ���ĸ�������������  
	up_reason char(3)		default ''	not null,  		-- ����ԭ��  
	roomno	char(5)		default ''	not null,
	rmreason	char(1)		default ''	not null,		-- �������� 
	rmrate	money			default 0	not null,		-- ���䱨�� 
	setrate	money			default 0	not null,		-- ���Żݼ��Ż�����һ�����ʵ�ʷ��� 
	rtreason	char(3)		default ''	not null,		-- �����Ż�����(cf.rtreason.dbf) 

	bdate		datetime	   				not null,		-- ��ʱ��Ӫҵ����
	arr		datetime	   				not null,		-- ��������=arrival 
	dep		datetime	   				not null,		-- �������=departure 

	haccnt	char(7)		default ''	not null,
	cusno		char(7)		default ''	not null,
	agent		char(7)		default ''	not null,
	source	char(7)		default ''	not null,
	contact 	char(7) 		default ''	not null,		-- ��ϵ�� 
	saleid  	char(12) 	default ''	not null,
	country	char(3)		default ''	not null,		-- ��Ҫ���� haccnt	��ס�ع���
	nation	char(3)		default ''	not null,		-- ��Ҫ���� haccnt	����

	market	char(3)		default ''	not null,		-- ���ͷ���ָ�ꡣ������ָ��Ҳ���Է�������
	src		char(3)		default ''	not null,
	channel	char(3)		default ''	not null,
	restype	char(3)		default '' 	not null,		-- Ԥ����� 

	artag1		char(3)		default '' 	not null,	-- 
	artag2		char(3)		default '' 	not null,	-- 

	ratecode		varchar(10)		default ''	not null,	-- ������ 
	cmscode		varchar(10)		default ''	not null,	-- Ӷ���� 
	cardcode		varchar(10)		default ''	not null,	-- ��Ա������ 
	cardno		varchar(20)		default ''	not null,	-- ��Ա������ 

	rmnum		int			default 0 	not null,
	gstno		int			default 0 	not null,
	children	int			default 0	not null,			-- С�� 

	t_arr   	char(1)  	default 'F'	 not null,			-- ���յ�
	t_dep   	char(1)  	default 'F'	 not null,			-- ������

	i_days  	money    	default 0 	not null,
	x_times 	money    	default 0 	not null,
	n_times 	money    	default 0 	not null,

	lastd			money			default 0 not null,		-- ����
	lastc			money			default 0 not null,		-- ����
	lastbl		money			default 0 not null,		-- ����

-- �����ʻ��Լ����ѣ�������ת�� 
	xf_rm      	money    	default 0 	not null,			-- �ͷ�-�Ѿ��������°���
	xf_rm_svc  	money    	default 0 	not null,			-- �ͷ�-�����
	xf_rm_bf   	money    	default 0 	not null,			-- �ͷ�-���
	xf_rm_cms  	money    	default 0 	not null,			-- �ͷ�-Ӷ��
	xf_rm_lau  	money    	default 0 	not null,			-- �ͷ�-ϴ��
	xf_rm_opak 	money    	default 0 	not null,			-- �ͷ�-��������
	xf_fb      	money    	default 0 	not null,			-- ����
	xf_mt      	money    	default 0 	not null,			-- ����
	xf_en      	money    	default 0 	not null,			-- ����
	xf_sp      	money    	default 0 	not null,			-- �̳�
	xf_dot   	money    	default 0 	not null,			-- ��������
	xf_dtl     	money    	default 0 	not null,			-- ����ϼ�

-- �����ʻ��ʻ��仯������ת�� 
	rm      	money    	default 0 	not null,			-- �ͷ�-�Ѿ��������°���
	rm_svc  	money    	default 0 	not null,			-- �ͷ�-�����
	rm_bf   	money    	default 0 	not null,			-- �ͷ�-���
	rm_cms  	money    	default 0 	not null,			-- �ͷ�-Ӷ��
	rm_lau  	money    	default 0 	not null,			-- �ͷ�-ϴ��
	rm_opak 	money    	default 0 	not null,			-- �ͷ�-��������
	fb      	money    	default 0 	not null,			-- ����
	mt      	money    	default 0 	not null,			-- ����
	en      	money    	default 0 	not null,			-- ����
	sp      	money    	default 0 	not null,			-- �̳�
	dot   	money    	default 0 	not null,			-- ��������
	dtl     	money    	default 0 	not null,			-- ����ϼ�

	t_rm      	money    	default 0 	not null,			-- �ͷ�-�Ѿ��������°���
	t_rm_svc  	money    	default 0 	not null,			-- �ͷ�-�����
	t_rm_bf   	money    	default 0 	not null,			-- �ͷ�-���
	t_rm_cms  	money    	default 0 	not null,			-- �ͷ�-Ӷ��
	t_rm_lau  	money    	default 0 	not null,			-- �ͷ�-ϴ��
	t_rm_opak 	money    	default 0 	not null,			-- �ͷ�-��������
	t_fb      	money    	default 0 	not null,			-- ����
	t_mt      	money    	default 0 	not null,			-- ����
	t_en      	money    	default 0 	not null,			-- ����
	t_sp      	money    	default 0 	not null,			-- �̳�
	t_dot   		money    	default 0 	not null,			-- ��������
	t_dtl     	money    	default 0 	not null,			-- ����ϼ�

	rmb     	money    	default 0 	not null,			-- �ֽ�
	chk     	money    	default 0 	not null,			-- ֧Ʊ
	card1   	money    	default 0 	not null,			-- ���ڿ�
	card2   	money    	default 0 	not null,			-- ���⿨
	ar     	money    	default 0 	not null,			-- ����
	ticket  	money    	default 0 	not null,			-- ����ȯ
	dscent  	money    	default 0 	not null,			-- ����ۿ�
	cot     	money    	default 0 	not null,			-- �����տ�
	ctl     	money    	default 0 	not null,			-- �տ�ϼ�

	t_rmb     	money    	default 0 	not null,			-- �ֽ�
	t_chk     	money    	default 0 	not null,			-- ֧Ʊ
	t_card1   	money    	default 0 	not null,			-- ���ڿ�
	t_card2   	money    	default 0 	not null,			-- ���⿨
	t_ar     	money    	default 0 	not null,			-- ����
	t_ticket  	money    	default 0 	not null,			-- ����ȯ
	t_dscent  	money    	default 0 	not null,			-- ����ۿ�
	t_cot     	money    	default 0 	not null,			-- �����տ�
	t_ctl     	money    	default 0 	not null,			-- �տ�ϼ�

	tilld			money			default 0 not null,			-- ������� 
	tillc			money			default 0 not null,
	tillbl		money			default 0 not null
);
exec sp_primarykey cus_xf,actcls,accnt;
create unique index index1 on cus_xf(actcls,accnt);



if exists(select 1 from sysobjects where name='ycus_xf' and type='U')
	drop table ycus_xf;
CREATE TABLE ycus_xf 
(
	date    	datetime 					not null,

	actcls  	char(1)  	default 'F'	 not null,		-- �˻����� F, P, B
	accnt		char(10)						not null,		-- ǰ̨�˺š��������š�bos���ŵȵ�
   sta		char(1)  	default '' not null,
   name     varchar(50) default '' null,

	master	char(10)		default ''	not null,		-- ǰ̨�ж�ͬס
	groupno	char(10)		default ''	not null,		-- ǰ̨�˺ų�Ա�������˺�

	type		char(5)		default ''	not null,		-- ����
	up_type	char(5)     default ''	null,  			-- ���ĸ�������������  
	up_reason char(3)		default ''	not null,  		-- ����ԭ��  
	roomno	char(5)		default ''	not null,
	rmreason	char(1)		default ''	not null,		-- �������� 
	rmrate	money			default 0	not null,		-- ���䱨�� 
	setrate	money			default 0	not null,		-- ���Żݼ��Ż�����һ�����ʵ�ʷ��� 
	rtreason	char(3)		default ''	not null,		-- �����Ż�����(cf.rtreason.dbf) 

	bdate		datetime	   				not null,		-- ��ʱ��Ӫҵ����
	arr		datetime	   				not null,		-- ��������=arrival 
	dep		datetime	   				not null,		-- �������=departure 

	haccnt	char(7)		default ''	not null,
	cusno		char(7)		default ''	not null,
	agent		char(7)		default ''	not null,
	source	char(7)		default ''	not null,
	contact 	char(7) 		default ''	not null,		-- ��ϵ�� 
	saleid  	char(12) 	default ''	not null,
	country	char(3)		default ''	not null,		-- ��Ҫ���� haccnt
	nation	char(3)		default ''	not null,		-- ��Ҫ���� haccnt

	market	char(3)		default ''	not null,		-- ���ͷ���ָ�ꡣ������ָ��Ҳ���Է�������
	src		char(3)		default ''	not null,
	channel	char(3)		default ''	not null,
	restype	char(3)		default '' 	not null,		-- Ԥ����� 

	artag1		char(3)		default '' 	not null,	-- 
	artag2		char(3)		default '' 	not null,	-- 

	ratecode		varchar(10)		default ''	not null,	-- ������ 
	cmscode		varchar(10)		default ''	not null,	-- Ӷ���� 
	cardcode		varchar(10)		default ''	not null,	-- ��Ա������ 
	cardno		varchar(20)		default ''	not null,	-- ��Ա������ 

	rmnum		int			default 0 	not null,
	gstno		int			default 0 	not null,
	children	int			default 0	not null,			-- С�� 

	t_arr   	char(1)  	default 'F'	 not null,			-- ���յ�
	t_dep   	char(1)  	default 'F'	 not null,			-- ������

	i_days  	money    	default 0 	not null,
	x_times 	money    	default 0 	not null,
	n_times 	money    	default 0 	not null,

	lastd			money			default 0 not null,		-- ����
	lastc			money			default 0 not null,		-- ����
	lastbl		money			default 0 not null,		-- ����

-- �����ʻ��Լ����ѣ�������ת�� 
	xf_rm      	money    	default 0 	not null,			-- �ͷ�-�Ѿ��������°���
	xf_rm_svc  	money    	default 0 	not null,			-- �ͷ�-�����
	xf_rm_bf   	money    	default 0 	not null,			-- �ͷ�-���
	xf_rm_cms  	money    	default 0 	not null,			-- �ͷ�-Ӷ��
	xf_rm_lau  	money    	default 0 	not null,			-- �ͷ�-ϴ��
	xf_rm_opak 	money    	default 0 	not null,			-- �ͷ�-��������
	xf_fb      	money    	default 0 	not null,			-- ����
	xf_mt      	money    	default 0 	not null,			-- ����
	xf_en      	money    	default 0 	not null,			-- ����
	xf_sp      	money    	default 0 	not null,			-- �̳�
	xf_dot   	money    	default 0 	not null,			-- ��������
	xf_dtl     	money    	default 0 	not null,			-- ����ϼ�

-- �����ʻ��ʻ��仯������ת�� 
	rm      	money    	default 0 	not null,			-- �ͷ�-�Ѿ��������°���
	rm_svc  	money    	default 0 	not null,			-- �ͷ�-�����
	rm_bf   	money    	default 0 	not null,			-- �ͷ�-���
	rm_cms  	money    	default 0 	not null,			-- �ͷ�-Ӷ��
	rm_lau  	money    	default 0 	not null,			-- �ͷ�-ϴ��
	rm_opak 	money    	default 0 	not null,			-- �ͷ�-��������
	fb      	money    	default 0 	not null,			-- ����
	mt      	money    	default 0 	not null,			-- ����
	en      	money    	default 0 	not null,			-- ����
	sp      	money    	default 0 	not null,			-- �̳�
	dot   	money    	default 0 	not null,			-- ��������
	dtl     	money    	default 0 	not null,			-- ����ϼ�

	t_rm      	money    	default 0 	not null,			-- �ͷ�-�Ѿ��������°���
	t_rm_svc  	money    	default 0 	not null,			-- �ͷ�-�����
	t_rm_bf   	money    	default 0 	not null,			-- �ͷ�-���
	t_rm_cms  	money    	default 0 	not null,			-- �ͷ�-Ӷ��
	t_rm_lau  	money    	default 0 	not null,			-- �ͷ�-ϴ��
	t_rm_opak 	money    	default 0 	not null,			-- �ͷ�-��������
	t_fb      	money    	default 0 	not null,			-- ����
	t_mt      	money    	default 0 	not null,			-- ����
	t_en      	money    	default 0 	not null,			-- ����
	t_sp      	money    	default 0 	not null,			-- �̳�
	t_dot   		money    	default 0 	not null,			-- ��������
	t_dtl     	money    	default 0 	not null,			-- ����ϼ�

	rmb     	money    	default 0 	not null,			-- �ֽ�
	chk     	money    	default 0 	not null,			-- ֧Ʊ
	card1   	money    	default 0 	not null,			-- ���ڿ�
	card2   	money    	default 0 	not null,			-- ���⿨
	ar     	money    	default 0 	not null,			-- ����
	ticket  	money    	default 0 	not null,			-- ����ȯ
	dscent  	money    	default 0 	not null,			-- ����ۿ�
	cot     	money    	default 0 	not null,			-- �����տ�
	ctl     	money    	default 0 	not null,			-- �տ�ϼ�

	t_rmb     	money    	default 0 	not null,			-- �ֽ�
	t_chk     	money    	default 0 	not null,			-- ֧Ʊ
	t_card1   	money    	default 0 	not null,			-- ���ڿ�
	t_card2   	money    	default 0 	not null,			-- ���⿨
	t_ar     	money    	default 0 	not null,			-- ����
	t_ticket  	money    	default 0 	not null,			-- ����ȯ
	t_dscent  	money    	default 0 	not null,			-- ����ۿ�
	t_cot     	money    	default 0 	not null,			-- �����տ�
	t_ctl     	money    	default 0 	not null,			-- �տ�ϼ�

	tilld			money			default 0 not null,			-- ������� 
	tillc			money			default 0 not null,
	tillbl		money			default 0 not null
);
exec sp_primarykey ycus_xf,date,actcls,accnt;
create unique index index1 on ycus_xf(date,actcls,accnt);
create index index2 on ycus_xf(haccnt);
create index index3 on ycus_xf(cusno);
create index index4 on ycus_xf(agent);
create index index5 on ycus_xf(source);
create index index6 on ycus_xf(saleid);
create index index7 on ycus_xf(market);
create index index8 on ycus_xf(src);
create index index9 on ycus_xf(channel);
create index index10 on ycus_xf(country);


-- ------------ cus_xf ��ṹ���� ������ master, t_dep    2004/10/7 gds
--
--
-- 1. backup data 
--exec sp_rename cus_xf, a_cus_xf;
--exec sp_rename ycus_xf, a_ycus_xf;
--
-- 2. create new stru.
--   exec the up sql.
--
-- 3. restore data
--insert cus_xf select date,actcls,accnt,'',groupno,haccnt,cusno,agent,source,cardno,saleid,
--	market,src,channel,t_arr,'F',gstno,i_days,x_times,n_times,rm,fb,en,sp,ot,ttl,yj,zc from a_cus_xf;
--insert ycus_xf select date,actcls,accnt,'',groupno,haccnt,cusno,agent,source,cardno,saleid,
--	market,src,channel,t_arr,'F',gstno,i_days,x_times,n_times,rm,fb,en,sp,ot,ttl,yj,zc from a_ycus_xf;
--
-- 4. update .master
--update cus_xf set master=a.master from master a where cus_xf.actcls='F' and cus_xf.accnt=a.accnt;
--update cus_xf set master=a.master from hmaster a where cus_xf.actcls='F' and cus_xf.accnt=a.accnt;
--update ycus_xf set master=a.master from master a where ycus_xf.actcls='F' and ycus_xf.accnt=a.accnt;
--update ycus_xf set master=a.master from hmaster a where ycus_xf.actcls='F' and ycus_xf.accnt=a.accnt;
--
-- 5. update .t_dep
--update cus_xf set t_dep='T' from master a where cus_xf.actcls='F' and cus_xf.accnt=a.accnt and datediff(dd,cus_xf.date,a.dep)=0;
--update cus_xf set t_dep='T' from hmaster a where cus_xf.actcls='F' and cus_xf.accnt=a.accnt and datediff(dd,cus_xf.date,a.dep)=0;
--update ycus_xf set t_dep='T' from master a where ycus_xf.actcls='F' and ycus_xf.accnt=a.accnt and datediff(dd,ycus_xf.date,a.dep)=0;
--update ycus_xf set t_dep='T' from hmaster a where ycus_xf.actcls='F' and ycus_xf.accnt=a.accnt and datediff(dd,ycus_xf.date,a.dep)=0;
--
-- 6. correct .t_arr
--update  cus_xf set t_arr='F' from  master  a where  cus_xf.actcls='F'  and  cus_xf.accnt=a.accnt and  cus_xf.t_arr='T' and datediff(dd, cus_xf.date,a.dep)=0;
--update  cus_xf set t_arr='F' from hmaster  a where  cus_xf.actcls='F'  and  cus_xf.accnt=a.accnt and  cus_xf.t_arr='T' and datediff(dd, cus_xf.date,a.dep)=0;
--update ycus_xf set t_arr='F' from  master  a where ycus_xf.actcls='F'  and ycus_xf.accnt=a.accnt and ycus_xf.t_arr='T' and datediff(dd,ycus_xf.date,a.dep)=0;
--update ycus_xf set t_arr='F' from hmaster  a where ycus_xf.actcls='F'  and ycus_xf.accnt=a.accnt and ycus_xf.t_arr='T' and datediff(dd,ycus_xf.date,a.dep)=0;
--
-- 7. maintance
--update statistics cus_xf;
--update statistics ycus_xf;
--
-- 8. view data
--select * from cus_xf;
--select * from ycus_xf;
--
--
--