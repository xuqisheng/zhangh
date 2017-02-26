if exists(select 1 from sysobjects where type ='P' and name ='p_cyj_audit_create_remark')
	drop proc p_cyj_audit_create_remark;

create proc p_cyj_audit_create_remark
	@type  char(4),     /* act, pos, bos*/
	@empno char(10), 
	@shift char(1)
as
---------------------------------------------------------------------------------------------------
--
--		����������ɵ���������˱�ע
--
--		������˼�¼, ��¼ǰ̨,����,�ͷ�,����,ϴ�µ���ϸ��, ��ÿ��������¼, ���au_remark
--		au_remark ������Ϊ aubdate + type +��auaccnt + aunumber
--		��˱�����ʱ����au_remark,  ҹ��ʱ���յ���au_hremark, ����û���ɵĲ���au_remark 
--		���պ�������˱�ע�����au_remark, ����������ʷ����au_hremark
--																												cyj 2003/10/23					
---------------------------------------------------------------------------------------------------

declare 
	@shiftstr 			char(10),
	@pccodes				char(100),
	@bdate 				datetime
if rtrim(ltrim(@shift)) = null
	select @shiftstr ='1234567890'
else
	select @shiftstr = @shift
select @bdate = bdate1 from sysdata

select @pccodes = value from sysoption where catalog = 'audit' and item = 'pccode_not_need_audit_remark'
if @@rowcount = 0 
	begin
	insert into sysoption(catalog,item,value,remark) select 'audit','pccode_not_need_audit_remark','', '����Ҫ����˼�¼��pccode��'
	select @pccodes = ''
	end

select @empno = rtrim(ltrim(@empno)) 
if @empno =''
	select @empno = null
if @type = 'act' 
	begin
	create table #account
	(
		accnt 		char(10),
		number 		int
	)
	insert into #account select accnt,number from account 
	where (empno = @empno or @empno = null) and charindex(shift,@shiftstr ) > 0 and bdate = @bdate  and  crradjt <> 'LT'	and charindex(pccode, @pccodes) = 0 
	insert into au_remark(aubdate, auaccnt, aunumber, type, ncheck,dcheck )
	select @bdate, accnt, number, 'act', 'N','N' from #account a
	where  not exists(select 1 from au_remark where  type ='act' and aubdate = @bdate and auaccnt = a.accnt and aunumber = a.number)
	end
else if  @type = 'pos' 
	begin
	create table #pos_menu
	(
		menu 		char(10)
	)
	insert into #pos_menu select menu from pos_menu 
	where (empno3 = @empno or @empno = null) and charindex(shift,@shiftstr ) > 0
	insert into au_remark(aubdate, auaccnt, aunumber, type, ncheck,dcheck )
	select @bdate, menu, 0, 'pos', 'N','N'  from #pos_menu a
	where  not exists(select 1 from au_remark where auaccnt = a.menu  and type ='pos' and aunumber = 0)
	end
else if  @type = 'bos' 
	begin
	create table #bos_account
	(
		setnumb 		char(10),
		code        char(5)
	)
	insert into #bos_account select setnumb, code from bos_account 
	where (empno = @empno or @empno = null) and charindex(shift,@shiftstr ) > 0 and bdate = @bdate

	insert into au_remark(aubdate, auaccnt, aunumber, type, ncheck,dcheck )
	select  @bdate, setnumb, ascii(substring(a.code,1,1))+ascii(substring(a.code,2,1))+ascii(substring(a.code,3,1)), 'bos', 'N','N'  from #bos_account a
	where not exists(select 1 from au_remark where auaccnt = a.setnumb  and type ='bos' and aunumber = ascii(substring(a.code,1,1))+ascii(substring(a.code,2,1))+ascii(substring(a.code,3,1)) )
end
;

