if exists(select 1 from sysobjects where name='p_cyj_pos_plu_printe' and type ='P')
	drop  proc p_cyj_pos_plu_printe;
create proc p_cyj_pos_plu_printe
	@tag				char(1),             -- 1 - 菜谱， 2 - 菜类
	@pluid			integer,
	@plucode			varchar(255),        -- 菜本
	@sort				varchar(255),        -- 菜类 
	@flags			varchar(2)   			-- 单项状态
as
---------------------------------------------------------------------------
-- 菜谱打印
---------------------------------------------------------------------------
declare		
	@id				int,
	@plu_code		char(2),
	@sort_code		char(4),
	@kitchen			char(3),
	@kitchens		varchar(20),
	@kitchens_des	char(20)

if datalength(@plucode ) = 255
	select @plucode = ''

if @tag ='1'       -- 菜谱打印部分
	begin
	create table #plulist(
		pluid					int,
		plucode				char(2),
		sort					char(4),
		id						int,
		plucode_des			char(20),			
		sort_name			char(20),			
		plu_code				char(6),
		plu_name1			char(30),
		plu_name2			char(50),
		plu_helpcode		char(10),
		pccode				char(3),
		unit					char(4),
		price					money,
		cost					money,
		kitchen				varchar(20),     -- 厨房打印机码
		kitchen_des			varchar(40),     -- 厨房打印机
		flags					char(20)
	)
	insert into #plulist
	select a.pluid,a.plucode,a.sort,a.id,b.descript,e.name1, a.code,a.name1,a.name2, a.helpcode, f.pccode,f.unit, f.price, f.cost,'','',a.flag0+a.flag1+a.flag2+a.flag3+a.flag4+a.flag5+a.flag6+a.flag8+a.flag9+a.flag10+a.flag11+a.flag12+a.flag13+a.flag14+a.flag15+a.flag16+a.flag17+a.flag18+a.flag19
		from  pos_plu a, pos_plucode b,pos_sort e,pos_price f
		where a.plucode = e.plucode   and b.plucode=a.plucode and a.id = f.id and f.halt = 'F' and a.sta ='0' 
		and a.sort = e.sort and charindex(a.plucode+e.sort,@sort)=0 and (charindex(a.plucode,@plucode)>0 or @plucode='')
		and b.pluid=@pluid and a.pluid=@pluid 
	 order by a.plucode, a.code, f.pccode, f.inumber
	
	if @flags = '0' 
		delete #plulist where substring(flags, 1, 1) <>'T'
	else if @flags = '1' 
		delete #plulist where substring(flags, 2, 1) <>'T'
	else if @flags = '2' 
		delete #plulist where substring(flags, 3, 1) <>'T'
	else if @flags = '3' 
		delete #plulist where substring(flags, 4, 1) <>'T'
	else if @flags = '4' 
		delete #plulist where substring(flags, 5, 1) <>'T'
	else if @flags = '5' 
		delete #plulist where substring(flags, 6, 1) <>'T'
	else if @flags = '6' 
		delete #plulist where substring(flags, 7, 1) <>'T'
	else if @flags = '7' 
		delete #plulist where substring(flags, 8, 1) <>'T'
	else if @flags = '8' 
		delete #plulist where substring(flags, 9, 1) <>'T'
	else if @flags = '9' 
		delete #plulist where substring(flags, 10, 1) <>'T'
	else if @flags = '10' 
		delete #plulist where substring(flags, 11, 1) <>'T'
	else if @flags = '11' 
		delete #plulist where substring(flags, 12, 1) <>'T'
	else if @flags = '12' 
		delete #plulist where substring(flags, 13, 1) <>'T'
	else if @flags = '13' 
		delete #plulist where substring(flags, 14, 1) <>'T'
	else if @flags = '14' 
		delete #plulist where substring(flags, 15, 1) <>'T'
	else if @flags = '15' 
		delete #plulist where substring(flags, 16, 1) <>'T'
	else if @flags = '16' 
		delete #plulist where substring(flags, 17, 1) <>'T'
	else if @flags = '17' 
		delete #plulist where substring(flags, 18, 1) <>'T'
	else if @flags = '18' 
		delete #plulist where substring(flags, 19, 1) <>'T'
	else if @flags = '19' 
		delete #plulist where substring(flags, 20, 1) <>'T'
	
	update #plulist set kitchen = b.kitchens from #plulist a, pos_prnscope b where a.pluid=b.pluid and a.plucode=b.plucode and plusort=b.plusort
	update #plulist set kitchen = b.kitchens from #plulist a, pos_prnscope b where a.id=b.id and b.pccode='###'
	declare c_cur cursor for select id,kitchen from #plulist where datalength(rtrim(ltrim(kitchen)))>4
	open c_cur
	fetch c_cur into @id,@kitchens
	while @@sqlstatus = 0 
		begin
		select @kitchens_des = ''		
		while  charindex('#',@kitchens)>0
			begin
			select @kitchen = substring(@kitchens, 1, charindex('#',@kitchens) - 1)
			select @kitchens = substring(@kitchens, charindex('#',@kitchens) + 1, datalength(@kitchens) - charindex('#',@kitchens))
			select @kitchens_des = rtrim(ltrim(@kitchens_des)) + rtrim(descript) + '#' from pos_printer where code=@kitchen
			end
		if @kitchens_des<>''
			update #plulist set kitchen_des = @kitchens_des where id=@id
		fetch c_cur into @id,@kitchens
		end
	close c_cur
	deallocate cursor c_cur
	update #plulist set kitchen_des = b.descript from #plulist a, pos_printer b where charindex(b.code,a.kitchen)>0 and a.kitchen_des=''
	select plucode_des,sort_name,plu_code,plu_name1,plu_name2,plu_helpcode,pccode,unit,price,cost,kitchen_des from #plulist
	order by  plucode, plu_code, pccode
	end
else if @tag='2' 		-- 菜类打印部分
	begin
	create table #sortlist(
		pluid					int,
		plucode				char(2),
		plucode_des			char(20),			
		sort					char(4),
		sort_name1			char(20),			
		sort_name2			char(30),			
		kitchen				char(20),     		-- 厨房打印机码
		kitchen_des			varchar(40)      	-- 厨房打印机
	)

	insert into #sortlist select e.pluid,e.plucode,b.descript,e.sort,e.name1,e.name2,'',''
	 from  pos_plucode b,pos_sort e where b.plucode = e.plucode and b.pluid=@pluid and e.pluid=@pluid and (charindex(e.plucode,@plucode)>0 or @plucode='')
	order by b.plucode, e.sort

	update #sortlist set kitchen = b.kitchens from #sortlist a, pos_prnscope b where a.pluid=b.pluid and a.plucode=b.plucode and a.sort=b.plusort
	declare c_cur_sort cursor for select plucode,sort,kitchen from #sortlist where datalength(rtrim(ltrim(kitchen)))>4
	open c_cur_sort
	fetch c_cur_sort into @plu_code,@sort_code,@kitchens
	while @@sqlstatus = 0 
		begin
		select @kitchens_des = ''		
		while  charindex('#',@kitchens)>0
			begin
			select @kitchen = substring(@kitchens, 1, charindex('#',@kitchens) - 1)
			select @kitchens = substring(@kitchens, charindex('#',@kitchens) + 1, datalength(@kitchens) - charindex('#',@kitchens))
			select @kitchens_des = rtrim(ltrim(@kitchens_des)) + rtrim(descript) + '#' from pos_printer where code=@kitchen
			end
		if @kitchens_des<>''
			update #sortlist set kitchen_des = @kitchens_des where pluid=@pluid and plucode=@plu_code and sort=@sort_code
		fetch c_cur_sort into @plu_code,@sort_code,@kitchens
		end
	close c_cur_sort
	deallocate cursor c_cur_sort
	update #sortlist set kitchen_des = b.descript from #sortlist a, pos_printer b where charindex(b.code,a.kitchen)>0 and a.kitchen_des=''
	select plucode_des,sort,sort_name1,sort_name2,kitchen_des from #sortlist
	end
;
