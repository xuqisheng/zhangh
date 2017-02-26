if exists(select 1 from sysobjects where name = 'p_cyj_audit_remark' and type = 'P')
	drop proc p_cyj_audit_remark;

create proc p_cyj_audit_remark
as
---------------------------------------------------------------------------------------------
--
--  ҹ������au_remark
--			au_remark, au_hremark ��Ӧaccount,haccount
---------------------------------------------------------------------------------------------
declare	
		@bdate			datetime,     
		@pccodes			char(100)           -- -- ��Ҫ��˵Ŀ�Ŀ

declare
		@lic_buy_1		varchar(255),
		@lic_buy_2		varchar(255)
select @lic_buy_1 = isnull((select value from sysoption where catalog='hotel' and item='lic_buy.1'), '')
select @lic_buy_2 = isnull((select value from sysoption where catalog='hotel' and item='lic_buy.2'), '')
if charindex(',check,', @lic_buy_1) = 0 and charindex(',check,', @lic_buy_2) > 0
	return 

-- -- �˹���ֻ����ҹ����ִ��, �����ظ�ִ��
if not exists(select 1 from gate where audit = 'T')
	return

select @pccodes = value from sysoption where catalog = 'audit' and item = 'pccode_not_need_audit_remark'
if @@rowcount = 0 
	insert into sysoption(catalog,item,value,remark) select 'audit','pccode_not_need_audit_remark','', '����Ҫ����˼�¼��pccode��'

select @bdate = bdate from sysdata

-- -- ��˱�ע������ʷ����
insert into au_hremark select * from au_remark where aubdate = dateadd(day, -1, @bdate)
delete au_remark from au_remark where aubdate = dateadd(day, -1, @bdate)

-- -- ����ǰ̨����˱�ע                                   
insert into au_remark(aubdate, auaccnt, aunumber, type, ncheck,dcheck )
	select  @bdate, accnt, number, 'act', 'N','N' from gltemp a
	where not exists(select 1 from au_remark where type ='act' and auaccnt = a.accnt and aunumber = a.number and aubdate = @bdate)
	and charindex(pccode, @pccodes) = 0 
                        
-- -- ���ɲ�������˱�ע                                   
insert into au_remark(aubdate, auaccnt, aunumber, type, ncheck,dcheck )
	select @bdate, menu, 0, 'pos', 'N','N'  from pos_tmenu a
	where  not exists(select 1 from au_remark where auaccnt = a.menu  and type ='pos' and aubdate = @bdate)
	order by a.menu

-- -- ����bos����˱�ע                                   
create table #bos_account
(
	setnumb 		char(10),
	number		int
)
--insert into #bos_account select  setnumb,convert(int, substring(code, 2, 3)) from bos_haccount  where bdate = @bdate
insert into #bos_account select distinct setnumb,1 from bos_haccount  where bdate = @bdate
insert into au_remark(aubdate, auaccnt,aunumber, type, ncheck,dcheck )
	select @bdate, setnumb, number, 'bos', 'N','N'  from #bos_account a
	where  not exists(select 1 from au_remark where auaccnt = a.setnumb  and type ='bos' and aubdate = @bdate)
                                                          
return 0;
