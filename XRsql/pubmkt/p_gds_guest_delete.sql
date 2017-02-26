
if object_id('p_gds_guest_delete') is not null
	drop proc p_gds_guest_delete;
create proc p_gds_guest_delete
	@no			char(7),
	@empno		char(10),
	@retmode		char(1) = 'S',
	@msg			varchar(60) output 
as
------------------------------------------------------------------------------------
--		����ɾ�� 
-- 
-- 	1. ���ﲻ���� p_gds_guest_del_check �ж��ˣ���Ϊ������ɾ��Ҳ�����Ҫɾ���� 
--
--		2. ������Щ��ʹ�õ��� 
--		     select a.id, a.name, b.name from syscolumns a, sysobjects b 
--			      where a.name='haccnt' and a.id=b.id	order by b.name 
--
--    3. �����ɾ��ǰ�жϣ���÷ֽ�Ϊ���ģ����жϣ�����ǰ̨���������������ɣ�õ�
--       ÿ��ģ����ж�һ�� Proc�� �ṹ������ 
------------------------------------------------------------------------------------ 
declare
	@ret			int,
	@class		char(1),
	@quickno		char(7)

select @ret=0, @msg=''  
if @retmode is null 
	select @retmode='R' 

-- ���ٵǼǵ���
select @quickno=isnull((select substring(value,1,7) from sysoption where catalog='reserve' and item='default_guestid'), '')
if @quickno = @no 
begin
	select @ret=1, @msg='���ٵǼǵ���������ɾ��'
	goto gout
end

-----------------------
-- ɾ���ж� 
-----------------------
-- �Ƿ����
select @class=class from guest where no=@no 
if @@rowcount=0
begin
	if exists(select 1 from guest_del where no=@no) 
		select @ret=1, @msg='%1�Ѿ�ɾ��^����'
	else
		select @ret=1, @msg='%1�����ڣ�����^����'
	goto gout
end

-- ����ж� 
--if @class in ('C', 'R')
--begin
--	select @ret=1, @msg='��Ǹ�������ʻ���Ӧ���ʻ��ĵ�������ɾ��'
--	goto gout
--end

-- master 
if exists(select 1 from master where haccnt=@no or cusno=@no or agent=@no or source=@no ) 
begin
	select @ret=1, @msg='�������ڵ�ǰʹ�ã�����ɾ��'
	goto gout
end
-- sc_master 
if exists(select 1 from sc_master where haccnt=@no or cusno=@no or agent=@no or source=@no ) 
begin
	select @ret=1, @msg='�������ڵ�ǰʹ�ã�����ɾ��'
	goto gout
end
-- ar_master 
if exists(select 1 from ar_master where haccnt=@no) 
begin
	select @ret=1, @msg='�������ڵ�ǰʹ�ã�����ɾ��'
	goto gout
end
-- vipcard 
if exists(select 1 from vipcard where hno=@no or cno=@no or kno=@no) 
begin
	select @ret=1, @msg='�������ڵ�ǰʹ�ã�����ɾ��'
	goto gout
end
-- pos_menu
if exists(select 1 from pos_menu where haccnt=@no or cusno=@no) 
begin
	select @ret=1, @msg='�������ڵ�ǰʹ�ã�����ɾ��'
	goto gout
end
-- pos_reserve
if exists(select 1 from pos_reserve where haccnt=@no or cusno=@no) 
begin
	select @ret=1, @msg='�������ڵ�ǰʹ�ã�����ɾ��'
	goto gout
end
-- sp_menu
if exists(select 1 from sp_menu where haccnt=@no or cusno=@no) 
begin
	select @ret=1, @msg='�������ڵ�ǰʹ�ã�����ɾ��'
	goto gout
end
-- sp_reserve
if exists(select 1 from sp_reserve where haccnt=@no or cusno=@no) 
begin
	select @ret=1, @msg='�������ڵ�ǰʹ�ã�����ɾ��'
	goto gout
end
-- turnaway
if exists(select 1 from turnaway where haccnt=@no) 
begin
	select @ret=1, @msg='�������ڵ�ǰʹ�ã�����ɾ��'
	goto gout
end


-----------------------
-- ɾ����ʼ 
-----------------------
begin tran 
save tran gst_del 

update guest set sta='X', cby=@empno, changed=getdate(), logmark=logmark+1 where no=@no 
insert guest_del select * from guest where no=@no 
if @@rowcount=0 
begin
	select @ret=1, @msg='ɾ����������'
	goto gout_s
end
else
begin
	delete guest where no=@no 
end

gout_s:
if @ret<>0 
	rollback tran gst_del
else
begin
	delete guest_del_flag where no=@no 
	delete guest_extra where no=@no 
	delete argst where no=@no 
end 
commit

gout:
if @retmode = 'S'
	select @ret, @msg
return @ret
;
