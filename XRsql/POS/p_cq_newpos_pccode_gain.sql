drop proc p_cq_newpos_pccode_gain;
create proc p_cq_newpos_pccode_gain
	 @bdate1     datetime,
    @bdate2     datetime,
    @pccodes    char(255),
    @status     char(1)
as
-------------------------------------------------------------------------------------------------
--
--		综合分析：餐厅营业额、成本、利润
--
-------------------------------------------------------------------------------------------------
declare
      @pccode    char(5),
      @i         integer,
      @month 	  integer,
      @amount1   money,
 		@amount2   money,
      @amount3   money,
      @bdate     datetime,
      @firstday  datetime,
      @lastday   datetime, 
		@option	  char(10)              -- 是否采用配料成本计算

create  table #amount
(
      pccode    char(5)     not null,
      descript  char(10)    not null,
		month     integer    not null ,
      descript1 char(10)   not null,
		amount1     money    default 0 ,			--成本金额
      amount2     money    default 0 ,			--营业金额
      amount3     money    default 0 ,			--利润

)
select @option = rtrim(value) from sysoption where catalog ='pos' and item = 'cost_hxsale_report'
if @@rowcount = 0 
	begin
	insert into sysoption(catalog,item,value,remark) select 'pos', 'cost_hxsale_report', 'n', '计算餐饮成本是否采用配料成本'
	select @option = 'n'
	end

select @bdate = bdate from sysdata
if @status = 'M'
	begin
		select @i = 2
		declare c_cur cursor for select month,firstday,lastday from firstdays where datediff(yy,firstday,@bdate)=0 and datediff(mm,lastday,@bdate)>=0
		select @pccode = substring(@pccodes,@i,3)
		while @pccode <> '' and @pccode is not null
			 begin
			 open c_cur
			 fetch c_cur into @month,@firstday,@lastday
			 while @@sqlstatus = 0
				  begin
				  if charindex(rtrim(@option) , 'tTyY') > 0 
						select @amount1 = isnull(sum(a.amount0),0) from pos_hsale a,pos_hmenu b where a.menu=b.menu  and b.pccode=@pccode and
						 b.bdate >= @firstday and b.bdate <= @lastday and b.sta='3'
					else
						select @amount1 = isnull(sum(a.number*d.cost),0) from pos_hdish a,pos_hmenu b, pos_price d where a.menu=b.menu  and b.pccode=@pccode and a.id = d.id and a.pinumber = d.inumber and 
						 b.bdate >= @firstday and b.bdate <= @lastday and b.sta='3'	and charindex(a.sta, '03579AM') >0
			
              select @amount2 = isnull(sum(a.amount),0) from pos_hmenu a where  a.pccode=@pccode and a.bdate >= @firstday and a.bdate <= @lastday and a.sta='3'
              select @amount3 = @amount2 - @amount1
				  insert #amount select @pccode,'',@month,rtrim(convert(char(2),@month))+'月',@amount1,@amount2,@amount3
				  fetch c_cur into @month,@firstday,@lastday
				  end
			 close c_cur
			 select @i = @i + 4
			 select @pccode = substring(@pccodes,@i,3)
			 end
      update #amount set descript = a.descript from pos_pccode a where #amount.pccode=a.pccode
	end
else
   begin
	select @i = 2
		select @pccode = substring(@pccodes,@i,3)
		while @pccode <> '' and @pccode is not null
			 begin
		  	if charindex(rtrim(@option) , 'tTyY') > 0 
		   	 select @amount1 = isnull(sum(a.amount),0) from pos_hsale a,pos_hmenu b where a.menu=b.menu  and b.pccode=@pccode and
					 b.bdate >= @bdate1 and b.bdate <= @bdate2 and b.sta='3'
			else
				select @amount1 = isnull(sum(a.number*d.cost),0) from pos_hdish a,pos_hmenu b, pos_price d where a.menu=b.menu  and b.pccode=@pccode and  a.id = d.id and a.pinumber = d.inumber and
				 b.bdate >= @bdate1 and b.bdate <=  @bdate2 and b.sta='3'	and charindex(a.sta, '03579AM') >0

		    select @amount2 = isnull(sum(a.amount),0) from pos_hmenu a where  a.pccode=@pccode and a.bdate >= @bdate1 and a.bdate <= @bdate2 and a.sta='3'
		    select @amount3 = @amount2 - @amount1
		    insert #amount select @pccode,'',15, '该段时间', @amount1,@amount2,@amount3
			 select @i = @i + 4
			 select @pccode = substring(@pccodes,@i,3)
			 end
      update #amount set descript = a.descript from pos_pccode a where #amount.pccode=a.pccode
   end




select * from #amount order by pccode,month

return 0;
