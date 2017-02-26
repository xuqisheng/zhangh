
if exists(select 1 from sysobjects where name = 'p_cyj_pos_ktprn_record' and type ='P')
	drop proc p_cyj_pos_ktprn_record;
create proc p_cyj_pos_ktprn_record
	@menu		char(10),
	@code		char(3),					-- pos_printer.code
	@prntype	char(10)					-- pos_dishcard.changed
as
-- ��¼������ӡÿ̨��ӡ����ӡ���, ��window��������ӡ��־�ȶԣ�������û��©��
declare
	@bdate		datetime,
	@prnname		char(30),
	@inumber		int,
	@id			int

select @bdate = bdate from sysdata
select @prnname = substring(name, 1, 30) from pos_printer where code = @code
if @@rowcount = 0 
	begin
	select @id = 0, @prnname = ''
	end
else
	begin
	select @inumber = sequence from basecode where cat = 'pos_kitchenprint' and code = @prnname
	if @@rowcount = 0 -- ���û�м�¼��̨��ӡ�����
		begin
		insert into basecode (cat,code,descript,descript1,sequence) select 'pos_kitchenprint',@prnname,@prnname,@prnname,1
		select @inumber = 1
		end
	update basecode set sequence = sequence  + 1 where cat = 'pos_kitchenprint' and code = @prnname
	select @id = @inumber
	insert pos_ktprn(bdate,menu,code,prnname,prntype,inumber,logdate) select @bdate,@menu,@code,@prnname,@prntype,@id,getdate()
	end 

select @id;
