if exists(select 1 from sysobjects where name = 'p_cq_pos_get_printer' and type = 'P')
	drop proc p_cq_pos_get_printer;

create proc p_cq_pos_get_printer
	@pccode		char(3),
	@id			integer,
	@kitchen		char(20) output,
	@mode			char(1)	= ''         -- 'S' ��select @kitchen
as
declare
		@plucode		char(6),
		@pluid		integer


select @pluid = convert(integer,value) from sysoption where catalog = 'pos' and item = 'pluid'
select @plucode = plucode+sort from pos_plu where id = @id 
--���ұ����ڸ�Ӫҵ���Ƿ��ж���
if exists(select 1 from pos_prnscope where pccode = @pccode and id = @id and pluid = @pluid)	  
	select @kitchen = kitchens from pos_prnscope where pccode = @pccode and id = @id and pluid = @pluid
else
	begin
--���ұ����Ƿ���Ĭ�ϵĶ���
	if exists(select 1 from pos_prnscope where pccode = '###' and id = @id and pluid = @pluid)	  
		select @kitchen = kitchens from pos_prnscope where pccode = '###' and id = @id and pluid = @pluid
	else
		begin
--�����ұ��˶�Ӧ�����ڸ�Ӫҵ���Ƿ��ж���
		if exists(select 1 from pos_prnscope where pccode = @pccode and plucode+plusort = @plucode and pluid = @pluid and id = 0)	  
			select @kitchen = kitchens from pos_prnscope where pccode = @pccode and plucode+plusort = @plucode and pluid = @pluid and id = 0
		else
			begin
--����ұ��˶�Ӧ�����Ƿ���Ĭ�϶���
			if exists(select 1 from pos_prnscope where pccode = '###' and plucode+plusort = @plucode and pluid = @pluid and id = 0)	  
				select @kitchen = kitchens from pos_prnscope where pccode = '###' and plucode+plusort = @plucode and pluid = @pluid and id = 0
			else
				select @kitchen = ''
			end
		end
	end

if @mode = 'S' 
	select @kitchen

return 0
;


	