drop proc p_cq_pos_get_item_code;
create proc p_cq_pos_get_item_code
		@pccode	char(3), 
		@code		char(15),
		@id		integer,
		@ret		char(3) out

as
declare
		@tocode		char(3),
		@plucode		char(2),
		@sort			char(4),
		@pluid		int

select @pluid = pluid,@plucode=plucode,@sort = sort from pos_plu_all where id = @id
--先检查pos_plu_all是否有定义
if exists(select 1 from pos_plu_all where id = @id and tocode <> '' and tocode is not null)
	begin
	if exists(select 1 from pos_itemdef a,pos_plu_all b where a.pccode = @pccode and charindex(a.code,b.tocode)>0 and b.id = @id)
		select @ret = min(a.code) from pos_itemdef a,pos_plu_all b where a.pccode = @pccode and charindex(a.code,b.tocode)>0 and b.id = @id
	else
		select @ret = null
	end
else
	begin
	--如果pos_plu_all未定义则看所属类别是否有定义
	if exists(select 1 from pos_sort_all where pluid = @pluid and plucode =@plucode and sort = @sort and tocode <> '' and tocode is not null and halt = 'F')
		begin
		if exists(select 1 from pos_itemdef a,pos_sort_all b where a.pccode = @pccode and charindex(a.code,b.tocode)>0 and b.pluid = @pluid and b.plucode=@plucode and b.sort = @sort)
			select @ret = min(a.code) from pos_itemdef a,pos_sort_all b where a.pccode = @pccode and charindex(a.code,b.tocode)>0 and b.pluid = @pluid and plucode=@plucode and b.sort = @sort
		else
			select @ret = null
		end
	--都未定义的情况,取原来的定义方式
	else
		begin
		exec p_gl_pos_get_item_code @pccode, @code, @tocode out
		select @ret = @tocode
		end
	end

if @ret = NULL
	select @ret = '099'

return 0

;