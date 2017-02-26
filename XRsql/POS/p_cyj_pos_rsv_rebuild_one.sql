drop  proc p_cyj_pos_rsv_rebuild_one;
create proc p_cyj_pos_rsv_rebuild_one
	@resno		char(10)					                  
as

declare
	@tableno				char(6),
	@bdate				datetime,
	@shift				char(1),
	@pccode				char(3),
	@guest				int,       				         
	@tables				int,       				     
	@piccnt				int,       				     
	@blockcnt			int,       				     
	@menu_reserve		char(1)

if @resno > '' 
	begin
//	if exists(select 1 from pos_menu where menu = @resno and sta in('2', '5'))
//		select @menu_reserve = 'm', @tableno = tableno, @tables = tables, @pccode = pccode, @bdate = bdate, @shift = shift, @guest = guest from pos_menu where menu = @resno
//	else if exists(select 1 from pos_reserve where resno = @resno and sta in('1', '2'))
//		select @menu_reserve = 'r', @tableno = tableno, @tables = tables, @pccode = pccode, @bdate = convert(datetime,convert(char(10), date0, 1)), @shift = shift, @guest = guest from pos_reserve where resno = @resno
//	else
//		return
//
//	delete pos_rsvdtl where resno = @resno 
//	insert into pos_rsvdtl(resno, pccode, tableno, bdate, shift, quantity, guest)
//		select @resno, @pccode, '', @bdate, @shift, @tables, @guest
//	                                         
//	insert into pos_rsvdtl(resno, pccode, tableno, bdate, shift, quantity, guest)
//		select @resno, @pccode, tableno, @bdate, @shift,  1, 0 from pos_tblav 
//		where menu = @resno and datediff(day, bdate,@bdate) =0 and shift = @shift and charindex(sta, '17') > 0
//	select @piccnt = sum(quantity) from pos_rsvdtl where resno = @resno and rtrim(tableno) is null and datediff(day, bdate,@bdate) =0 and shift = @shift
//	if @piccnt > @tables                                    
//		update pos_rsvdtl set quantity = @piccnt where resno = @resno and rtrim(tableno) is null  and datediff(day, bdate,@bdate) =0 and shift = @shift
//													 
//	select @piccnt = sum(quantity) from pos_rsvdtl where pccode = @pccode and datediff(day, bdate,@bdate) =0 and shift = @shift and tableno > ''
//	select @blockcnt = sum(quantity) from pos_rsvdtl where pccode = @pccode and datediff(day, bdate,@bdate) =0 and shift = @shift and rtrim(tableno) is null
//	if not exists(select 1 from pos_rsvpc where pccode = @pccode and datediff(day, bdate,@bdate) =0 and shift = @shift)
//		insert into pos_rsvpc select @pccode, @bdate, @shift, @blockcnt, @piccnt, @guest
//	update pos_rsvpc set blockcnt = @blockcnt, piccnt = @piccnt
//		where pccode = @pccode and datediff(day,bdate,@bdate) =0 and shift = @shift

	                              
	if @menu_reserve = 'm'
		update pos_menu set tables = (select count(1) from pos_tblav b where b.menu = @resno and b.sta ='7' ) from pos_menu a where a.menu = @resno
	end

;