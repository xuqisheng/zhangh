drop  proc p_cq_pos_detail_jie_link;
create proc p_cq_pos_detail_jie_link
	@pc_id		char(4),
	@bdate		datetime
as
---------------------------------------------------------------------------
--
-- 关于‘组合菜’的报表项目分摊
--		组合菜: 早餐, 婚宴, 工作餐, ......
--		形成 pos_detail_jie_link		--- 包含处理分摊
--		套菜分摊：
--				1.按定义的百分比分摊
--				2.按定义的金额分摊（重算百分比）,主要考虑打折或服务费引起金额与原金额不一致的情况
--				3.按明细菜的金额分摊（也要算百分比）
--				4.套菜不分摊，直接从pos_detail_jie中取数据
--				------ 状态为冲账的排除  type = (1,2,4,6,8) + 1
--
---------------------------------------------------------------------------

delete pos_detail_jie_link where pc_id = @pc_id
select * into #pos_detail_jie from pos_detail_jie where 1=2

insert pos_detail_jie_link (	pc_id, pccode,shift,empno,menu,code,name1,id,type,amount0,amount1,amount2,amount3,reason3,special,tocode,date)
	select @pc_id, a.pccode, a.shift, a.empno, a.menu, a.code, a.name1, a.id, a.type,
				a.amount0, a.amount1, a.amount2, a.amount3, a.reason3, a.special, a.tocode,@bdate
		from pos_detail_jie a where a.date = @bdate
--			and charindex(rtrim(type),'23579') = 0
			and not exists(select 1 from pos_plu_sep b,pos_dish c where a.menu = c.menu and a.id = c.inumber and c.id = b.id)
			and not exists(select 1 from pos_plu_sep b,pos_hdish c where a.menu = c.menu and a.id = c.inumber and c.id = b.id)
			and not exists(select 1 from pos_dish c where a.menu = c.menu and a.id = c.inumber and substring(c.flag,1,1)='T')
			and not exists(select 1 from pos_hdish c where a.menu = c.menu and a.id = c.inumber and substring(c.flag,1,1)='T')

declare @menu char(10), @code char(15), @id integer, @type char(5), @reason3 char(3),@inumber integer,@plu_id integer
declare @pos int,@count int, @itemcode char(3), @deptno char(2),@pccode char(3),@itempart money,@plu_code char(15)
declare @amount0 money, @amount1 money, @amount2 money, @amount3 money,@total money,@std_amount money
declare @samount0 money, @samount1 money, @samount2 money, @samount3 money
declare @tamount0 money, @tamount1 money, @tamount2 money, @tamount3 money
declare @keypccode varchar(5), @keycode varchar(15),@tag char(1)
declare @shift char(1), @empno char(10), @inumber_dish integer, @special char(1)

declare c_sep cursor for
	select a.deptno,a.pccode,a.menu,a.code,a.id,a.type,a.reason3,
			a.amount0,a.amount1,a.amount2,a.amount3,a.shift,a.empno,a.special
	from pos_detail_jie a
	where a.date=@bdate
--		and charindex(rtrim(a.type),'23579') = 0
		and (exists(select 1 from pos_plu_sep b,pos_dish c where a.menu = c.menu and a.id = c.inumber and c.id = b.id)
		or exists(select 1 from pos_plu_sep b,pos_hdish c where a.menu = c.menu and a.id = c.inumber and c.id = b.id)
		or exists(select 1 from pos_dish c where a.menu = c.menu and a.id = c.inumber and substring(c.flag,1,1)='T')
		or exists(select 1 from pos_hdish c where a.menu = c.menu and a.id = c.inumber and substring(c.flag,1,1)='T')
	)
	order by a.menu,a.code,a.id,a.type,a.reason3


open c_sep
fetch c_sep into @deptno,@pccode,@menu,@code,@inumber,@type,@reason3,@amount0,@amount1,@amount2,@amount3,@shift,@empno,@special
while @@sqlstatus = 0
	begin
	select @pos=0,@itemcode='',@itempart=0
	select @samount0=0,@samount1=0,@samount2=0,@samount3=0
	select @tamount0=0,@tamount1=0,@tamount2=0,@tamount3=0

	delete #pos_detail_jie
	insert #pos_detail_jie select * from pos_detail_jie
		where date=@bdate and menu=@menu and code=@code and id=@inumber and type=@type and reason3=@reason3
	select @id = a.id from pos_dish a where inumber = @inumber and menu = @menu
	if @@rowcount = 0
		select @id = a.id from pos_hdish a where inumber = @inumber and menu = @menu
	select @tag = min(a.tag) from pos_plu_sep a where a.id = @id 
	select @total = isnull(sum(itempart),0) from pos_plu_sep a where a.id = @id
	if charindex(@tag,'%$') > 0 		--按百分比或按金额分摊
		begin
		--特殊情况处理,当总金额为0的情况
		if @total <= 0  
			insert pos_detail_jie_link (	pc_id, pccode,shift,empno,menu,code,name1,id,type,amount0,amount1,amount2,amount3,reason3,special,tocode,date)
			select @pc_id, a.pccode, a.shift, a.empno, a.menu, a.code, a.name1, a.id, a.type,
						a.amount0, a.amount1, a.amount2, a.amount3, a.reason3, a.special, a.tocode,@bdate
				from pos_detail_jie a where date = @bdate and menu = @menu and code = @code
							and id = @inumber and type = @type and reason3 = @reason3
		else
			begin
			select @count = count(1) from pos_plu_sep a where a.id = @id  and a.itemcode > @itemcode and a.itempart>0
			while @count > 0					--此条件已经限制一定是按百分比或按金额分摊
				begin
					select @itemcode = min(a.itemcode) from pos_plu_sep a where a.id = @id  and a.itemcode > @itemcode
					select @itempart = a.itempart from pos_plu_sep a where a.id = @id  and a.itemcode = @itemcode
					if @tag = '%'				--按百分比分摊
						select @samount0 = round(@amount0 * @itempart, 2),@samount1 = round(@amount1 * @itempart, 2),
								 @samount2 = round(@amount2 * @itempart, 2),@samount3 = round(@amount3 * @itempart, 2)
					else
						begin
						if @tag = '$'			--按金额分摊, 还是要算百分比
							--select @samount0 = @itempart, @samount1 = 0, @samount2 = 0, @samount3 = 0	
							select @samount0 = round(@amount0 * @itempart/@total, 2),@samount1 = round(@amount1 * @itempart/@total, 2),
								 @samount2 = round(@amount2 * @itempart/@total, 2),@samount3 = round(@amount3 * @itempart/@total, 2)
						end
		
					select @tamount0=@tamount0+@samount0,@tamount1=@tamount1+@samount1,
							@tamount2=@tamount2+@samount2,@tamount3=@tamount3+@samount3
					select @pos = @pos + 1
					insert pos_detail_jie_link (	pc_id, pccode,shift,empno,menu,code,name1,id,type,amount0,amount1,amount2,amount3,reason3,special,tocode,date)
						select @pc_id,pccode,shift,empno,menu,code,name1,id*1000+@pos,type,@samount0,@samount1, @samount2, @samount3, reason3, special, @itemcode,@bdate
							from #pos_detail_jie
					select @count = count(1) from pos_plu_sep a where a.id = @id  and a.itemcode>@itemcode and a.itempart>0
				end
				--假如金额还有剩余，那么把剩余的金额归到最后的itemcode
				select @pos = @pos + 1
				select @itemcode = max(itemcode) from pos_plu_sep a where  a.id = @id 
				insert pos_detail_jie_link (pc_id, pccode,shift,empno,menu,code,name1,id,type,amount0,amount1,amount2,amount3,reason3,special,tocode,date)
					select @pc_id,pccode,shift,empno,menu,code,name1,id*1000+@pos,type,amount0-@tamount0,amount1-@tamount1, amount2-@tamount2, amount3-@tamount3, reason3, special, @itemcode,@bdate
						from #pos_detail_jie
			end
		end
	else										--按明细金额比例分摊
		begin
		if exists(select 1 from pos_dish where menu = @menu)
			select @total = isnull(sum(amount),0) from pos_dish where menu = @menu and id_master = @inumber and sta = 'M' 
		else
			select @total = isnull(sum(amount),0) from pos_hdish where menu = @menu and id_master = @inumber and sta = 'M' 

		--特殊情况处理,当总金额为0的情况
		if @total <= 0  
			insert pos_detail_jie_link (	pc_id, pccode,shift,empno,menu,code,name1,id,type,amount0,amount1,amount2,amount3,reason3,special,tocode,date)
			select @pc_id, a.pccode, a.shift, a.empno, a.menu, a.code, a.name1, a.id, a.type,
						a.amount0, a.amount1, a.amount2, a.amount3, a.reason3, a.special, a.tocode,@bdate
				from pos_detail_jie a where date = @bdate and menu = @menu and code = @code
							and id = @inumber and type = @type and reason3 = @reason3
		else
			begin
			declare c_std cursor for 
				select sort+code,id,amount,inumber from pos_dish where menu = @menu and id_master = @inumber and sta = 'M' 
				union	select sort+code,id,amount,inumber from pos_hdish where menu = @menu and id_master = @inumber and sta = 'M' 
				order by id
			open c_std
			fetch c_std into @plu_code,@plu_id,@std_amount,@inumber_dish
			while @@sqlstatus = 0
				begin
				exec p_cq_pos_get_item_code @pccode, @plu_code,@plu_id, @itemcode out 

				select @samount0 = round(@amount0 * @std_amount/@total, 2),@samount1 = round(@amount1 * @std_amount/@total, 2),
						 @samount2 = round(@amount2 * @std_amount/@total, 2),@samount3 = round(@amount3 * @std_amount/@total, 2)
	
				select @tamount0=@tamount0+@samount0,@tamount1=@tamount1+@samount1,
							@tamount2=@tamount2+@samount2,@tamount3=@tamount3+@samount3
				select @pos = @pos + 1
				insert pos_detail_jie_link (	pc_id, pccode,shift,empno,menu,code,name1,id,type,amount0,amount1,amount2,amount3,reason3,special,tocode,date)
					select @pc_id,@pccode,@shift,@empno,menu,plucode+sort+code,name1,inumber,@type,@samount0,@samount1, @samount2, @samount3, @reason3, @special, @itemcode,@bdate
						from pos_dish where menu=@menu and inumber = @inumber_dish
				fetch c_std into @plu_code,@plu_id,@std_amount,@inumber_dish
				end
				close c_std
				deallocate cursor c_std	
				--假如金额还有剩余，那么把剩余的金额归到最后的itemcode
				if @amount0 <> @tamount0 or @amount1 <> @tamount1 or @amount2 <> @tamount2 or @amount3 <> @tamount3
					begin
					select @itemcode = max(tocode) from pos_detail_jie_link where pc_id = @pc_id and menu = @menu and id = @id*1000+@pos
					select @pos = @pos + 1
					insert pos_detail_jie_link (	pc_id, pccode,shift,empno,menu,code,name1,id,type,amount0,amount1,amount2,amount3,reason3,special,tocode,date)
						select @pc_id,pccode,shift,empno,menu,code,name1,id*1000+@pos,type,amount0-@tamount0,amount1-@tamount1, amount2-@tamount2, amount3-@tamount3, reason3, special, @itemcode,@bdate
							from #pos_detail_jie
					end
				end	
		end
	fetch c_sep into @deptno,@pccode,@menu,@code,@inumber,@type,@reason3,@amount0,@amount1,@amount2,@amount3,@shift,@empno,@special
	end
close c_sep
deallocate cursor c_sep


return 0
;