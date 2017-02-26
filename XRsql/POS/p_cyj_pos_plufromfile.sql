if exists(select 1 from sysobjects where name='p_cyj_pos_plufromfile' and type ='P')
	drop  proc p_cyj_pos_plufromfile;
create proc p_cyj_pos_plufromfile
	@pludes			char(40),
	@empno			char(10),
	@option			char(1)		 -- 'T' 保留原有对应关系如报表项定义、厨房定义
as
------------------------------------------------------------------------------------------
--  菜谱从文本文件导入，文件导入的临时存放区是pos_plu_file, 从这个文件生成pos_plucode,
--  pos_sort_all, pos_plu_all, pos_price
------------------------------------------------------------------------------------------

declare	
	@pluid				int,         -- 菜谱号
	@pluidold			int,
	@plucode				char(2),
	@plucodeold			char(2),
	@sort					char(4),
	@code					char(6),
	@sortold				char(4),
	@sortdes				char(30),
	@sta					char(1),
	@special				char(1),
	@helpcode			char(10),
	@ii					int,
	@id					int,
	@inumber				int,
	@cdate				datetime,
	@name1				char(30),
	@name2				char(50),
	@unit1				char(4),
	@price1				char(10),
	@unit2				char(4),
	@price2				char(10),
	@unit3				char(4),
	@price3				char(10),
	@unit4				char(4),
	@price4				char(10),
	@unit5				char(4),
	@price5				char(10),
	@cost_f				money,
	@condgp1				varchar(100),
	@condgp2				varchar(100),
	@tocode				varchar(100),
	@ret					int,
	@msg					char(100)


select @cdate = getdate(), @plucodeold = ''
create table #plufile(
	pccode 	char(3)			default ''	not null,
	pcdes 	char(16)			default ''	not null,
	plucode	char(2)			default ''	not null,
	pludes 	char(100)		default ''	not null,
	sort	 	char(4)			default ''	not null,
	sort_des char(100)		default ''	not null,
	code		char(6)			default ''	null,
	id			int	,
	name1 char(100)			default ''	not null,
	name2 char(100)			default ''	null,
	unit1 char(10)				default ''	null,
	price1 char(10)			default ''	null,
	unit2 char(10)				default ''	null,
	price2 char(10)			default ''	null,
	unit3 char(10)				default ''	null,
	price3 char(10)			default ''	null,
	unit4 char(10)				default ''	null,
	price4 char(10)			default ''	null,
	unit5 char(10)				default ''	null,
	price5 char(10)			default ''	null
)
-- 原来在用菜谱号
select @pluidold = convert(int, value) from sysoption where catalog='pos' and item ='pluid'
select @ret = 0, @msg = ''

insert into #plufile select * from pos_plu_file
begin tran
save  tran t_plu_file

select @pluid = max(pluid) + 1 from pos_pluid 
if @pluid = 0 or @pluid is null
	select @pluid = 1
insert into pos_pluid select @pluid, @pludes, getdate()

-- 倒菜本
declare c_plucode cursor for select distinct plucode,pludes from #plufile order by plucode
open c_plucode 
fetch c_plucode into @plucode,@pludes
while @@sqlstatus = 0
	begin
	if not exists(select 1 from pos_plucode where pluid = @pluid and plucode=@plucode)
		insert into pos_plucode(pluid,plucode,descript,descript1) select  @pluid,@plucode,@pludes, '' 
	else
		begin
		close c_plucode
		deallocate cursor c_plucode
		select @ret = 1 , @msg = '菜本代码有误: '+@plucode+':'+@pludes
		goto loop_
		end
	fetch c_plucode into @plucode,@pludes
	end
close c_plucode
deallocate cursor c_plucode

-- 倒菜类
declare c_sort cursor for select distinct plucode,sort,sort_des from #plufile order by plucode,sort
open c_sort 
fetch c_sort into @plucode,@sort,@sortdes
while @@sqlstatus = 0
	begin
	if exists(select 1 from pos_sort_all where pluid = @pluid and plucode=@plucode and sort=@sort)
		begin
		close c_sort
		deallocate cursor c_sort
		select @ret = 1 , @msg = '菜类代码有误: '+@sort + ':' + @sortdes
		goto loop_
		end

	if @option = 'T'
		select @tocode=tocode,@condgp1=condgp1,@condgp2=condgp2,@cost_f=cost_f from pos_sort_all where pluid=@pluidold and plucode=@plucode and sort=@sort
	else
		select @tocode='',@condgp1='',@condgp2='' ,@cost_f = 0

	insert into pos_sort_all(pluid,plucode,sort,name1,name2,condgp1,condgp2,tocode,cost_f,empno,date,halt,logmark)
		select @pluid,@plucode,@sort,@sortdes,'',@condgp1,@condgp2,@tocode,@cost_f,@empno,@cdate,'F',1

	fetch c_sort into @plucode,@sort,@sortdes
	end
close c_sort
deallocate cursor c_sort

-- 倒菜
declare c_plu cursor for select distinct plucode,sort,code,name1,name2,unit1,price1,unit2,price2,unit3,price3,unit4,price4,unit5,price5 from #plufile order by plucode,sort
open c_plu
fetch c_plu into @plucode,@sort,@code,@name1,@name2,@unit1,@price1,@unit2,@price2,@unit3,@price3,@unit4,@price4,@unit5,@price5
while @@sqlstatus = 0 
	begin
	if exists(select 1 from pos_plu_all where pluid = @pluid and plucode=@plucode and sort=@sort and code=@code)
		begin
		close c_plu
		deallocate cursor c_plu
		select @ret = 1 , @msg = '菜代码有误: '+convert(varchar, @pluid) + ':'+ @code + ':' + @name1
		goto loop_
		end
	if @sortold <> @sort
		select @ii = 1 
	else
		select @ii = @ii + 1
	exec p_gds_genzjm @name1,@helpcode output
	select @id = max(id) + 1 from pos_plu_all
	if @id = 0 or @id is null
		select @id = 1

--	select @code = substring(@sort, 1, 3)+substring('000'+convert(varchar, @ii), datalength('000'+convert(varchar, @ii)) - 2, 3)
	insert into pos_plu_all(pluid,plucode,sort,code,id,name1,name2,helpcode,helpcode1,menu,special,sta,timecode,th_sort,p_number,picpath,condgp1,condgp2,tocode,empno,date,logmark)
	select @pluid,@plucode,@sort,@code,@id,@name1,@name2,@helpcode,'','11111','N','0','','',1,'','','','',@empno,@cdate,1
	select @inumber = 1 
	-- 菜价
	if rtrim(ltrim(@unit1))  is not null
		begin
		if not exists(select 1 from pos_price where id = @id and inumber = @inumber)
			begin
			insert into pos_price(pccode,id,inumber,unit,price,cost,cost_f,halt,logmark,empno,logdate) 	
			select '###',@id,@inumber,@unit1,convert(money,@price1),0,0,'F',1,@empno,@cdate
			select @inumber = @inumber + 1
			end
		else
			update pos_price set unit = @unit1, price = convert(money,@price1) where  id = @id and inumber = @inumber
		end
	if rtrim(ltrim(@unit2))  is not null
		begin
		if not exists(select 1 from pos_price where id = @id and inumber = @inumber)
			begin
			insert into pos_price(pccode,id,inumber,unit,price,cost,cost_f,halt,logmark,empno,logdate) 	
			select '###',@id,@inumber,@unit2,convert(money,@price2),0,0,'F',1,@empno,@cdate
			select @inumber = @inumber + 1
			end
		else
			update pos_price set unit = @unit2, price = convert(money,@price2) where  id = @id and inumber = @inumber
		end
	if rtrim(ltrim(@unit3))  is not null
		begin
		if not exists(select 1 from pos_price where id = @id and inumber = @inumber)
			begin
			insert into pos_price(pccode,id,inumber,unit,price,cost,cost_f,halt,logmark,empno,logdate) 	
			select '###',@id,@inumber,@unit3,convert(money,@price3),0,0,'F',1,@empno,@cdate
			select @inumber = @inumber + 1
			end
		else
			update pos_price set unit = @unit3, price = convert(money,@price3) where  id = @id and inumber = @inumber
		end
	if rtrim(ltrim(@unit4))  is not null
		begin
		if not exists(select 1 from pos_price where id = @id and inumber = @inumber)
			begin
			insert into pos_price(pccode,id,inumber,unit,price,cost,cost_f,halt,logmark,empno,logdate) 	
			select '###',@id,@inumber,@unit4,convert(money,@price4),0,0,'F',1,@empno,@cdate
			select @inumber = @inumber + 1
			end
		else
			update pos_price set unit = @unit4, price = convert(money,@price4) where  id = @id and inumber = @inumber
		end
	if rtrim(ltrim(@unit5))  is not null
		begin
		if not exists(select 1 from pos_price where id = @id and inumber = @inumber)
			begin
			insert into pos_price(pccode,id,inumber,unit,price,cost,cost_f,halt,logmark,empno,logdate) 	
			select '###',@id,@inumber,@unit5,convert(money,@price5),0,0,'F',1,@empno,@cdate
			select @inumber = @inumber + 1
			end
		else
			update pos_price set unit = @unit5, price = convert(money,@price5) where  id = @id and inumber = @inumber
		end
	select @sortold = @sort, @id = @id + 1
	fetch c_plu into @plucode,@sort,@code,@name1,@name2,@unit1,@price1,@unit2,@price2,@unit3,@price3,@unit4,@price4,@unit5,@price5
	end
close c_plu
deallocate cursor c_plu
loop_:
if @ret <> 0 
	rollback tran
commit tran 
select @pluid, @ret, @msg
;