drop proc p_cq_newpos_pccode_condgp;
create proc p_cq_newpos_pccode_condgp
	 @bdate     datetime,
    @bdate1    datetime,
    @pccodes    char(255)
as
-------------------------------------------------------------------------------------------------
--
--		综合分析：按营业点统计餐厅成本
--
-------------------------------------------------------------------------------------------------
declare
      @pccode    char(5),
      @i         integer,
      @condgp    char(4),
      @amount    money,
		
		@option	  char(1)


create  table #cond
(
      pccode    	char(5)     not null,
      descript  	char(10)    not null,
		condgp      char(4)    	not null,
      descript1 	char(40)   	not null,
		amount     	money    	default 0
)

select @option = rtrim(value) from sysoption where catalog ='pos' and item = 'cost_hxsale_report'
if @@rowcount = 0 
	begin
	insert into sysoption select 'pos', 'cost_hxsale_report', 'n', '计算餐饮成本是否采用配料成本'
	select @option = 'n'
	end
if charindex(rtrim(@option) , 'tTyY') > 0
	begin
	select @i = 2
	declare c_cur cursor for select code from pos_condgp where dish_use = 'F' order by code
	select @pccode = substring(@pccodes,@i,3)
	while @pccode <> '' and @pccode is not null
		 begin
		 open c_cur
		 fetch c_cur into @condgp
		 while @@sqlstatus = 0
			  begin
			  select @amount = isnull(sum(a.amount0),0) from pos_hsale a,pos_hmenu b,pos_condst c where a.menu=b.menu and a.condid = c.condid and b.pccode=@pccode and
					 a.bdate >= @bdate and a.bdate <= @bdate1 and charindex(@condgp,c.condgp) >0
			  insert #cond select @pccode,'',@condgp,'',@amount
			  fetch c_cur into @condgp
			  end
		 close c_cur
		 select @i = @i + 4
		 select @pccode = substring(@pccodes,@i,3)
		 end
	update #cond set descript = a.descript from pos_pccode a where #cond.pccode=a.pccode
	update #cond set descript1 = a.descript from pos_condgp a where #cond.condgp = a.code
	end 
else
	begin
	select @i = 2
	declare c_cur cursor for select plucode from pos_plucode where pluid = (select convert(integer,value) from sysoption where 
		catalog = 'pos' and item = 'pluid') order by plucode
	select @pccode = substring(@pccodes,@i,3)
	while @pccode <> '' and @pccode is not null
		 begin
		 open c_cur
		 fetch c_cur into @condgp
		 while @@sqlstatus = 0
			  begin
			  select @amount = isnull(sum(a.number*d.cost),0) from pos_hdish a,pos_hmenu b, pos_price d where a.menu=b.menu  and b.pccode=@pccode and a.id = d.id and a.pinumber = d.inumber and 
						 b.bdate >= @bdate and b.bdate <= @bdate1 and b.sta='3'	and charindex(a.sta, '03579AM') >0 and rtrim(a.plucode) = rtrim(@condgp)
			  insert #cond select @pccode,'',@condgp,'',@amount
			  fetch c_cur into @condgp
			  end
		 close c_cur
		 select @i = @i + 4
		 select @pccode = substring(@pccodes,@i,3)
		 end
	update #cond set descript = a.descript from pos_pccode a where #cond.pccode=a.pccode
	update #cond set descript1 = a.descript from pos_plucode a where rtrim(#cond.condgp) = rtrim(a.plucode)
	end

select * from #cond order by pccode,condgp

return 0

;