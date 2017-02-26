
if exists(select 1 from sysobjects where name ='p_cyj_pos_change_sysplu' and type = 'P')
	drop proc p_cyj_pos_change_sysplu;
create proc p_cyj_pos_change_sysplu
		@pluid		integer			-- ���õĲ��׺�
as
-----------------------------------------------------------------------------------------------
-- ��ǰʹ�ò����滻
-----------------------------------------------------------------------------------------------
declare
	@settime		char(30),
	@setdate		datetime

select @settime =rtrim(substring(value,1,30)) from sysoption where catalog='hotel' and item='init_warning'
if @@rowcount=0 
begin
	insert sysoption(catalog,item,value,usermod) values('hotel', 'init_warning', '2000/1/1 10:00:00', 'F') 
	select @settime=null
end
else
begin
	if @settime is not null 
	begin
		select @setdate=convert(datetime,@settime)
		if @setdate is null 
			select @settime = null
		else if abs(datediff(ss,@settime,getdate())) > 5   -- 5 ��֮�ڱ�������ִ�� 
			select @settime = null
	end 
end
if @settime = null 
begin
	-- ---------------------------------------------------------------------------------------
	--	��¼ִ��ʱ��
	-- ---------------------------------------------------------------------------------------
	select @settime = convert(char(10), getdate(), 111)+' '+convert(char(8), getdate(), 8)
	if not exists(select 1 from sysoption where catalog='hotel' and item='init_warning')
		insert sysoption (catalog,item,value) select 'hotel','init_warning',''
	update sysoption set value=@settime where catalog='hotel' and item='init_warning'

	-- ����
	delete gdsmsg 
	insert gdsmsg select '�ر��ر�����: ��ȷ��Ҫ�л����� !!!'
	insert gdsmsg select '' 
	insert gdsmsg select '�������ȫȷ�ϣ�������ִ�иù��̣�ף������ !' 
	select * from gdsmsg 
	delete gdsmsg 
	return 1
end
if not exists(select 1 from pos_pluid where pluid = @pluid)
	begin
	select '�����ڲ���: ' + convert(varchar, @pluid)
	return 1
	end

begin tran
save  tran tr_plu
delete pos_plu 
delete pos_sort

insert into pos_sort select * from  pos_sort_all where pluid = @pluid
insert into pos_plu select  * from  pos_plu_all where pluid = @pluid

update sysoption set value = convert(varchar, @pluid) where catalog='pos' and item = 'pluid'

commit tr_plu
;
