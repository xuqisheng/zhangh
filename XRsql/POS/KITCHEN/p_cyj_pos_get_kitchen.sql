if exists (select 1 from sysobjects where name='p_cyj_pos_get_kitchen' and type='P')
	drop procedure p_cyj_pos_get_kitchen;

create proc p_cyj_pos_get_kitchen
	@menu			char(10),
	@id			int,						--菜号 pos_plu.id
	@kitchens 	char(20)	output 
as
------------------------------------------------------------------------------------------------
--
--  得到所点的菜对应的厨房
--																										2003/10/28	cyj
------------------------------------------------------------------------------------------------
declare
	@pluid		int,
	@plucodes	char(6),
	@plucode		char(2),
	@sort			char(4),
	@pccode		char(3),
	@flag			char(10),
	@ret			int,
	@msg			char(60)

select @ret = 0, @msg = 'ok', @kitchens=''
select @pccode=pccode from pos_menu where menu=@menu
if @@rowcount = 0
begin
	select @ret=1, @msg='菜单不存在'
	return @ret
end

if exists(select 1  from  pos_prnscope where id = @id)                 -- 存在单个菜定义
	select @kitchens = kitchens from  pos_prnscope where id = @id
else
	begin
	select @pluid = pluid,@plucode = plucode,@sort=sort from pos_plu where id = @id
	select @plucodes = null
	select @plucodes = max(plucode+plusort) from pos_prnscope
		where @pccode like rtrim(pccode) + '%' and @plucode + @sort like rtrim(plucode+plusort) + '%' and pluid = @pluid

	if @plucodes is not null
		select @kitchens = kitchens from pos_prnscope where pccode = @pccode	and plucode + plusort = @plucodes and pluid = @pluid
	else
		begin
		select @plucodes = max(plucode+plusort) from pos_prnscope
			where pccode = '###' and @plucode + @sort like rtrim(plucode+plusort) + '%' and pluid = @pluid
		if @plucodes is not null
			select @kitchens = kitchens from pos_prnscope where pccode = '###' and plucode + plusort = @plucodes and pluid = @pluid
		else
			select @ret = 1, @msg='匹配错误', @kitchens = ''
		end
	end
return @ret;
