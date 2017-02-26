drop  proc p_gds_pos_detail_jie_link;
create proc p_gds_pos_detail_jie_link
	@pc_id		char(4),
	@bdate		datetime,
	@flag			char(1)	=  '0'
as
---------------------------------------------------------------------------
--
-- 关于‘组合菜’的报表项目分摊
--		组合菜: 早餐, 婚宴, 工作餐, ......
--		形成 pos_detail_jie_link		--- 包含处理分摊
--				------ 状态为冲账的排除  type = (1,2,4,6,8) + 1
--
---------------------------------------------------------------------------

delete pos_detail_jie_link where pc_id = @pc_id
select * into #pos_detail_jie from pos_detail_jie where 1=2

if @flag = '0'
	insert pos_detail_jie_link (	pc_id, pccode,shift,empno,menu,code,name1,id,type,amount0,amount1,amount2,amount3,reason3,special,tocode,date)
		select @pc_id, a.pccode, a.shift, a.empno, a.menu, a.code, a.name1, a.id, a.type,
					a.amount0, a.amount1, a.amount2, a.amount3, a.reason3, a.special, a.tocode,@bdate
			from pos_detail_jie a where a.date = @bdate
else
	begin

	insert pos_detail_jie_link (	pc_id, pccode,shift,empno,menu,code,name1,id,type,amount0,amount1,amount2,amount3,reason3,special,tocode,date)
		select @pc_id, a.pccode, a.shift, a.empno, a.menu, a.code, a.name1, a.id, a.type,
					a.amount0, a.amount1, a.amount2, a.amount3, a.reason3, a.special, a.tocode,@bdate
			from pos_detail_jie a where a.date = @bdate
				and type<>'2' and type<>'3' and type<>'5' and type<>'7' and type<>'9'
				and not exists(select 1 from pos_plu_sep b,pos_dish c where a.id = c.inumber and c.id = b.id)
				--and not exists(select 1 from pos_plu_sep b where a.deptno+a.pccode like b.pccode+'%' and a.code like b.code+'%')


	declare @menu char(10), @code char(15), @id integer, @type char(3), @reason3 char(3)
	declare @pos int,@count int, @itemcode char(3), @deptno char(2),@pccode char(3),@itempart money
	declare @amount0 money, @amount1 money, @amount2 money, @amount3 money
	declare @samount0 money, @samount1 money, @samount2 money, @samount3 money
	declare @tamount0 money, @tamount1 money, @tamount2 money, @tamount3 money
	declare @keypccode varchar(5), @keycode varchar(15),@tag char(1)

	declare c_sep cursor for
		select a.deptno,a.pccode,a.menu,a.code,a.id,a.type,a.reason3,
				a.amount0,a.amount1,a.amount2,a.amount3
		from pos_detail_jie a
		where a.date=@bdate
			and a.type<>'2' and a.type<>'3' and a.type<>'5' and a.type<>'7' and a.type<>'9'
			and exists(select 1 from pos_plu_sep b,pos_dish c where a.id = c.inumber and c.id = b.id)
		order by a.menu,a.code,a.id,a.type,a.reason3
	open c_sep
	fetch c_sep into @deptno,@pccode,@menu,@code,@id,@type,@reason3,@amount0,@amount1,@amount2,@amount3
	while @@sqlstatus = 0
		begin
		select @pos=0,@itemcode='',@itempart=0
		select @samount0=0,@samount1=0,@samount2=0,@samount3=0
		select @tamount0=0,@tamount1=0,@tamount2=0,@tamount3=0

		delete #pos_detail_jie
		insert #pos_detail_jie select * from pos_detail_jie
			where date=@bdate and menu=@menu and code=@code and id=@id and type=@type and reason3=@reason3
		select @keypccode=max(pccode), @keycode=max(code) from pos_plu_sep where @deptno+@pccode like pccode+'%' and @code like code+'%'
		select @tag = min(tag) from pos_plu_sep where pccode=@keypccode and code=@keycode
		select @count = count(1) from pos_plu_sep where pccode=@keypccode and code=@keycode and itemcode>@itemcode and itempart>0
		while (@tag='%' and @count>1) or (@tag<>'%' and @count>0)
			begin
				select @itemcode = min(itemcode) from pos_plu_sep where pccode=@keypccode and code=@keycode and itemcode>@itemcode
				select @itempart = itempart from pos_plu_sep where pccode=@keypccode and code=@keycode and itemcode=@itemcode

				if @tag = '%'
					select @samount0 = round(@amount0 * @itempart, 2),@samount1 = round(@amount1 * @itempart, 2),
							@samount2 = round(@amount2 * @itempart, 2),@samount3 = round(@amount3 * @itempart, 2)
				else
					select @samount0 = @itempart, @samount1 = 0, @samount2 = 0, @samount3 = 0

				select @tamount0=@tamount0+@samount0,@tamount1=@tamount1+@samount1,
						@tamount2=@tamount2+@samount2,@tamount3=@tamount3+@samount3
				select @pos = @pos + 1
				insert pos_detail_jie_link (	pc_id, pccode,shift,empno,menu,code,name1,id,type,amount0,amount1,amount2,amount3,reason3,special,tocode,date)
					select @pc_id,pccode,shift,empno,menu,code,name1,id*1000+@pos,type,@samount0,@samount1, @samount2, @samount3, reason3, special, @itemcode,@bdate
						from #pos_detail_jie
			select @count = count(1) from pos_plu_sep where pccode=@keypccode and code=@keycode and itemcode>@itemcode and itempart>0
			end


		select @pos = @pos + 1
		if @tag = '%'
			select @itemcode = max(itemcode) from pos_plu_sep where pccode=@keypccode and code=@keycode
		else
			select @itemcode = max(itemcode) from pos_plu_sep where pccode=@keypccode and code=@keycode and itempart<0
		insert pos_detail_jie_link (	pc_id, pccode,shift,empno,menu,code,name1,id,type,amount0,amount1,amount2,amount3,reason3,special,tocode,date)
			select @pc_id,pccode,shift,empno,menu,code,name1,id*1000+@pos,type,amount0-@tamount0,amount1-@tamount1, amount2-@tamount2, amount3-@tamount3, reason3, special, @itemcode,@bdate
				from #pos_detail_jie

		fetch c_sep into @deptno,@pccode,@menu,@code,@id,@type,@reason3,@amount0,@amount1,@amount2,@amount3
		end
	close c_sep
	deallocate cursor c_sep
	end

return 0
;