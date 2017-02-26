if exists(select 1 from sysobjects where name='p_cyj_pos_detail' and type ='P')
	drop proc p_cyj_pos_detail;
create proc p_cyj_pos_detail
	@as_menu				char(10), 			                          
	@date					datetime				              
as
--------------------------------------------------------------------------------------------------------
--
--	 服务费和税取自dish.code = Z,Y
--	 菜的金额 = amount - dsc
--	 单菜款待特殊处理 pos_dish.special = 'E'	
--	 #dai.distribute 5.0从paymth.distribute char(4) 取, x5从pccode.deptno8 char(3), 取时前面加 'T'
--
--------------------------------------------------------------------------------------------------------

declare
	@bdate				datetime, 	
	@id					int,		            
                                  
   @master_menu		char(10),			          
   @pcrec				varchar(20), 		          
   @menu					char(10), 			          
	@deptno				char(2), 			          
	@pccode				char(3), 			          
	@posno				char(2), 			          
	@shift				char(1), 
	@empno				char(10), 
	@paid					char(1), 
	@sta					char(1), 
	@pay_sta				char(1), 			                             
	@mode					char(3), 			        
	@dsc_rate			money, 				          
	@serve_rate			money, 				            
	@tax_rate			money, 				            
                                  
	@sort					char(4), 			        
	@code					char(6), 			        
	@plucode				char(2),
   @modcode          char(15),
	@plu_code			char(10),			                            
	@inumber				integer, 			            
	@type					char(1), 			                                                         
	@name1				char(20), 			            
	@name2				char(20), 			            
	@number				money, 				        
	@amount0				money, 				          
	@dsc_amount			money, 				            
	@amount				money, 				                
	@amount1				money, 				                                        
	@amount2				money, 				                                
	@amount3				money, 				                                
	@amount4				money, 				    
	@dsc					money,
	@srv					money,
	@srv0					money,
	@srv_dsc				money,
	@tax					money,
	@tax_dsc				money,
	@serve0				money, 				            
	@serve1				money, 				                                          
	@serve2				money, 				                                  
	@serve3				money, 				                                  
	@tax0					money, 				            
	@tax1					money, 				                                          
	@tax2					money, 				                                  
	@tax3					money, 				                                  
	@taxs1				money,
	@taxs2				money,
	@taxs3				money,
	@reason				char(3), 			
	@reason1				char(3), 			                        
	@reason2				char(3), 			                      
	@reason3				char(3), 			                                          
   @special				char(1), 			              
	@credit				money,
                      
   @i						integer, 
	@distribute			char(3), 
   @tocode				char(3), 			                        
   @paycode				char(5), 
   @payent				char(5), 
   @jamount				money, 
   @thispart			money, 
	@jsrv					money,
	@jtax					money,
	@thispart1			money,
	@thispart2			money,
	@diffpart			money,
	@dtmp1				money,
	@dtmp2				money,
	@damount				money,
	@sumpart				money,
	@sumpart_srv		money,
	@sumsrv				money,
	@sumpart_tax		money,
	@sumtax				money,
	@divval				money,
	@p_menu				char(11),
	@entpost				char(1),					-- 单菜款待付款码已经跳过 ＝D
	@reason3_ent		char(3),
	@dtmp					money,
	@stmp					char(10),
	@dsc_one				money						-- 单菜款待金额

create table #menu
(
	menu			char(10)		not null, 				            
	charge		money			default 0 not null 	         
)
create unique index #menu on #menu (menu)

select * into #hmenu from pos_hmenu where 1=2
create index index1 on #menu(menu)
select * into #pos_menu from pos_menu where 1=2
select * into #dish from pos_dish where 1=2
select * into #pay from pos_pay where 1=2

   
create table #jie
(
	menu			char(10)		not null, 				            
	inumber		integer		not null, 				              
	amount		money			default 0 not null, 	          
	srv			money			default 0, 
	tax			money			default 0, 
	special		char(1)		not null,				                      
	reason		char(3)		not null 				              
)
create unique index #jie on #jie (menu, inumber)
declare c_jie cursor for select menu, inumber, amount, srv, tax, special from #jie where amount <> 0 order by menu,inumber 
   
create table #dai
(
	paycode		char(5)		default '', 				                            
	distribute	char(4)		default '', 				                                    
	amount		money			default 0,		 
	reason3		char(3)		default '',
	ent_one		char(1)		default ''             -- 单菜款待对应付款
)	 
create unique index #dai on #dai (paycode, reason3)
declare c_dai cursor for select paycode, distribute, ent_one,sum(amount), reason3 from #dai where amount <> 0 and ent_one = ''
	group by paycode, distribute, reason3, ent_one
	order by paycode, distribute, reason3, ent_one

create table #jiedai_ent      -- 临时存放单菜款待
(
	menu			char(10)		not null, 				          
	inumber		integer		not null, 				             
	paycode		char(5)		default '', 			                        
	amount		money			default 0, 
	srv			money			default 0, 
	tax			money			default 0, 
	reason3		char(3)		default ''				                  
)	 
create unique index #jiedai_ent on #jiedai_ent (menu, inumber, paycode, reason3)
   
create table #jiedai
(
	menu			char(10)		not null, 				          
	inumber		integer		not null, 				             
	paycode		char(5)		default '', 			                        
	amount		money			default 0, 
	srv			money			default 0, 
	tax			money			default 0, 
	reason3		char(3)		default ''				                  
)	 
create unique index #jiedai on #jiedai (menu, inumber, paycode, reason3)

declare c_jiedai cursor for select menu, inumber from #jiedai where paycode = @paycode and reason3 = @reason3 order by menu,inumber
   
select @bdate = bdate1 from sysdata
if ltrim(rtrim(@as_menu)) is null
	select @p_menu = '%'
else
	select @p_menu = @as_menu + '%'

if @date = @bdate																								        
	begin
	-- 考虑结账时，单个餐单构建
	select @pcrec = pcrec from pos_menu where menu = @as_menu
	insert into #pos_menu select * from  pos_menu where menu like @p_menu or (pcrec = @pcrec and pcrec >'')
	insert into #dish select a.*  from pos_dish a, #pos_menu b where a.menu=b.menu
	insert into #pay select a.* from pos_pay  a, #pos_menu b where a.menu=b.menu

	declare c_master_menu cursor for
		select distinct menu, pcrec, paid from #pos_menu where menu like @p_menu and (pcrec = '' or pcrec is null)
		union select pcrec, pcrec, paid from #pos_menu where menu like @p_menu and (pcrec <> '' and pcrec is not null)
	   order by menu
	declare c_menu cursor for
		select menu, pccode, shift, empno3, paid, deptno, posno, mode, reason, dsc_rate, serve_rate, tax_rate, bdate
		from #pos_menu where menu = @master_menu or (pcrec = @pcrec and @pcrec >'')
		order by menu
	declare c_dish cursor for
		select id,plucode,sort, code, name1, inumber, number, amount, dsc, srv0,srv_dsc,tax0,tax_dsc,special, reason, sta
		from #dish where menu = @menu and charindex(sta, '03579A') >0 order by code, id                                   
	declare c_pay cursor for                                                    
		select paycode, number, amount, sta, reason    
		from #pay where menu = @menu and charindex(sta, '23') > 0 and crradjt='NR' order by paycode, number  
                                         
	end
else																												        
	begin
	insert into #hmenu select * from pos_hmenu where bdate = @date 

	select @pcrec = pcrec from pos_hmenu where menu = @as_menu

	declare c_master_menu cursor for
		select distinct menu, pcrec, paid from #hmenu where menu like @p_menu and (pcrec = '' or pcrec is null)
		union select pcrec, pcrec, paid from #hmenu where menu like @p_menu and pcrec <> '' and pcrec is not null
		order by menu
	declare c_menu cursor for
		select menu, pccode, shift, empno3, paid, deptno, posno, mode, reason, dsc_rate, serve_rate, tax_rate, bdate
		from #hmenu where menu = @master_menu or (pcrec = @pcrec and @pcrec >'')
		order by menu
	declare c_dish cursor for
		select id,plucode,sort, code, name1, inumber, number, amount, dsc, srv0,srv_dsc,tax0,tax_dsc,special, reason, sta
		from pos_hdish where menu = @menu  and charindex(sta, '03579A') >0 order by code, id                                   
	declare c_pay cursor for       
		select paycode, number, amount, sta, reason    
		from pos_hpay where menu = @menu and charindex(sta, '23') > 0 and crradjt='NR' order by paycode, number  
	end


if (select substring(ltrim(rtrim(@p_menu)),1,1)) = '%' or ltrim(rtrim(@p_menu)) is null
	begin 
	delete pos_detail_jie where date = @date
	delete pos_detail_dai where date = @date 
   end
else           --  对jie,dai 删除时注意是否有连单
	if @date = @bdate																								        
		begin
		delete pos_detail_jie where date = @date and menu like @p_menu or menu in(select menu from #pos_menu where pcrec = @pcrec and @pcrec >'')
		delete pos_detail_dai where date = @date and menu like @p_menu or menu in(select menu from #pos_menu where pcrec = @pcrec and @pcrec >'')
		end
	else
		begin
		delete pos_detail_jie where date = @date and menu like @p_menu or menu in(select menu from #hmenu where pcrec = @pcrec and @pcrec >'')
		delete pos_detail_dai where date = @date and menu like @p_menu or menu in(select menu from #hmenu where pcrec = @pcrec and @pcrec >'')
		end

                      
open c_master_menu
fetch c_master_menu into @master_menu, @pcrec, @paid
while @@sqlstatus =0
   begin
	if @paid <> '1' or exists (select 1 from pos_detail_jie where date = @date and menu = @master_menu)
		begin
		fetch c_master_menu into @master_menu, @pcrec, @paid
		continue
		end
   truncate table #jie 
   truncate table #dai
   truncate table #jiedai
	open c_menu
	fetch c_menu into @menu, @pccode, @shift, @empno, @paid, @deptno, @posno, @mode, @reason1, @dsc_rate, @serve_rate, @tax_rate, @date
	while @@sqlstatus =0
	   begin

		open c_dish
		fetch c_dish into @id,@plucode,@sort, @code, @name1, @inumber, @number, @amount, @dsc, @srv,@srv_dsc,@tax,@tax_dsc,@special, @reason3, @sta
		while @@sqlstatus = 0
			begin
         select @modcode=@plucode + @sort + @code   
			if substring(@code, 1, 4) = '' or @sta in ('B', 'C') -- or 	( @amount = 0  ) 
				begin
				fetch c_dish into @id,@plucode,@sort, @code, @name1, @inumber, @number, @amount, @dsc, @srv,@srv_dsc,@tax,@tax_dsc,@special, @reason3, @sta
				continue
				end
			else
				begin
				           
				if not exists (select 1 from #menu where menu = @menu)
					insert #menu (menu, charge) values (@menu, @amount -  @dsc )
				else
					update #menu set charge = charge + @amount - @dsc where menu = @menu
				select @serve0 = 0, @tax0 = 0, @serve1 = 0, @tax1 = 0, @serve2 = 0, @tax2 = 0, @serve3 = 0, @tax3 = 0, @type = '0'
                                                   
				if @special = 'T'                                 -- 特殊类只用于零头处理，统计时等同于普通类 cyj 04.11.23
					select @special = 'N'
				if @special = 'T'
					select @amount3 =  - @amount, @amount1 = 0, @amount2 = 0, @amount = 0
				else if  @special = 'X'
					select @amount3 = @dsc, @amount1 = 0, @amount2 = 0
				else
					begin
                                    
					if @sta > '0' and @sta <= '9'                          
						begin
						select @type = convert(char(1), convert(int, @sta) + 1)
						select @amount3 = @dsc
						exec p_gl_pos_create_discount	@deptno,@pccode,@mode,@modcode,@amount,@dsc_rate,@result = @dsc_amount output
						select @dsc_amount = @amount - @dsc_amount
						select @amount3 = @amount3 - @dsc_amount
						end
					else
						select @amount3 = 0, @dsc_amount = @dsc
					if @sta <> 'A'       -- 如果是零头，不必计算折扣和服务费
						begin
						exec p_gl_pos_get_discount	@deptno, @pccode, @mode, @modcode, @amount, @dsc_amount, @dsc_rate, @result1 = @amount1 output, @result2 = @amount2 output, @result3 = @reason2 output
						exec p_gl_pos_get_serve		@deptno, @pccode, @mode, @modcode, @amount, @amount1, @amount2, @serve_rate, @result0 = @serve0 output, @result1 = @serve1 output, @result2 = @serve2 output
						exec p_gl_pos_get_tax		@deptno, @pccode, @mode, @modcode, @amount, @amount1, @amount2, @tax_rate, @result0 = @tax0 output, @result1 = @tax1 output, @result2 = @tax2 output
						end
					else
						select @amount1=0, @amount2=0, @amount3=0, @serve0=0, @serve1=0, @serve2=0,@serve3=0, @tax0=0, @tax1=0, @tax2=0, @tax3=0
					end

           	if @code = 'Y' or @code = 'Z'  --  服务费，税@amount存放的是净值
					select @amount = @amount + @dsc              
            -- 服务费，税统一倒扣                                           
				insert #jie (menu, inumber, amount, srv, tax, special, reason) values (@menu, @inumber, @amount - @dsc,  @srv - @srv_dsc,  @tax - @tax_dsc, @special,@reason3 )

				if @code ='Y' or @code='Z' 
					select @tocode = '050'
				else
					begin
					select @plu_code =  rtrim(isnull(rtrim(ltrim(@sort)), '')) + @code     --cq modify in 'dfhs'  
					exec p_cq_pos_get_item_code @pccode, @plu_code,@id, @tocode out   
					end
                                   
				insert pos_detail_jie values(@date, @deptno, @posno, @pccode, @shift, @empno, @menu, @modcode, @inumber, @type, @name1, @name2, @number, isnull(@amount, 0), isnull(@amount1, 0), isnull(@amount2, 0), isnull(@amount3,0), 
					isnull(@srv, 0), isnull(@serve1, 0), isnull(@srv_dsc, 0), isnull(@serve3, 0), isnull(@tax, 0), isnull(@tax1, 0), isnull(@tax_dsc, 0), isnull(@tax3, 0), @reason2, @reason1, @reason3, @special, @tocode)
				end  
			fetch c_dish into @id,@plucode,@sort, @code, @name1, @inumber, @number, @amount, @dsc, @srv,@srv_dsc,@tax,@tax_dsc,@special, @reason3, @sta
			end
		close c_dish

		open c_pay
		fetch c_pay into  @paycode, @number, @amount, @pay_sta,@reason
		while @@sqlstatus = 0 
			begin
			if not exists (select 1 from pccode where rtrim(pccode) = @paycode and deptno8 > '')
				select @reason = ''
			if @pay_sta = '2'
				select @reason = '定',@reason3 = '定'
			              
			select @paycode = deptno1 from pccode where rtrim(deptno1) = @paycode 
			if not exists (select 1 from #dai where paycode = @paycode and reason3 = @reason)
				insert #dai (paycode, amount, reason3) values (@paycode, @amount, @reason)
			else
				update #dai set amount = amount + @amount where paycode = @paycode and reason3 = @reason
			fetch c_pay into  @paycode, @number, @amount, @pay_sta,@reason
			end
		close c_pay
		fetch c_menu into @menu, @pccode, @shift, @empno, @paid, @deptno, @posno, @mode, @reason1, @dsc_rate, @serve_rate, @tax_rate, @date
		end
	close c_menu
	                           
	update #dai set distribute = 'T' + pccode.deptno8
		from pccode where pccode.pccode = #dai.paycode and substring(pccode.deptno8,1, 1) > ''
-- 单菜款待处理            
	select @entpost =''
	select @dsc_one = isnull(sum(amount+srv+tax),0) from #jie where special = 'E'
	if @dsc_one > 0     -- 有单菜款待
		begin
		open c_dai
		fetch c_dai into @paycode, @distribute, @stmp, @damount, @reason3
		while @@sqlstatus = 0
			begin
			if substring(@distribute, 1, 1) = 'T' and @damount = @dsc_one and @entpost <> 'P'
				begin
				update #dai set ent_one ='P'  where paycode = @paycode and reason3 = @reason3
				select @entpost ='P', @payent = @paycode   -- 单菜款待付款已经找到
				end
				if substring(@distribute, 1, 1) = 'T' and @damount >= @dsc_one 
					select @payent = @paycode, @reason3_ent = @reason3
				fetch c_dai into @paycode, @distribute, @stmp, @damount, @reason3
			end
			close c_dai
			if @entpost <>'P'        -- 找不到和单菜款待金额一样的款待付款，则对款待付款金额扣减
				begin
				update #dai set amount = amount - @dsc_one where  paycode = @payent and reason3 = @reason3_ent 
				select @entpost = 'P'	
				end
			-- 单菜款待插入jiedai, 单菜款待dish的服务费和税都为0
			select @reason = min(reason) from #jie where special = 'E' 

			insert #jiedai_ent (menu, inumber, paycode, amount, srv, tax, reason3) 
				select menu, inumber, @payent, amount, srv, tax, reason from #jie where  special = 'E' and amount <> 0

			insert pos_detail_jie (date, deptno, posno, pccode, shift, empno, menu, code, id, type, name1, name2, number, amount0, amount1, amount2, amount3, 
				serve0, serve1, serve2, serve3, tax0, tax1, tax2, tax3, reason1, reason2,reason3, special, tocode)
			select date, a.deptno, a.posno,a.pccode, a.shift, a.empno, a.menu, a.code, a.id, isnull(b.paycode,''), a.name1, a.name2,a.number,a.amount0,a.amount1,a.amount2, isnull(b.amount,0),
				a.serve0,a.serve1,a.serve2,isnull(b.srv, 0),a.tax0,a.tax1,a.tax2,isnull(b.tax, 0),a.reason1,a.reason2, isnull(b.reason3,''),a.special, a.tocode
				from pos_detail_jie a, #jiedai_ent b where a.date = @date and a.menu = b.menu and a.id = b.inumber
		end	
	delete #jie where special ='E'

	select @i = 0
	while @i < 2
		begin
		if exists ( select 1 from #dai where ((@i = 0 and substring(distribute, 1, 1) = 'T') or (@i = 1 and substring(distribute, 1, 1) <> 'T')) and amount <> 0 )
			begin
			select @credit = isnull(sum(amount), 0) from #dai
			if @credit <> 0
				begin
				select @dsc = isnull(sum(amount+srv+tax),0) from #jie where special = 'E'
				open c_dai
				fetch c_dai into @paycode, @distribute, @entpost, @damount, @reason3
				while @@sqlstatus = 0
					begin
					if @entpost='P' or (@i = 0 and substring(@distribute, 1, 1) <> 'T' ) or (@i = 1 and substring(@distribute, 1, 1) = 'T')
						begin
						fetch c_dai into @paycode, @distribute, @entpost, @damount, @reason3
						continue
						end
					select @sumpart = 0, @sumpart_srv = 0, @sumpart_tax = 0, @sumsrv = 0, @sumtax = 0, @divval = @damount / (@credit - @dsc_one)

					open c_jie
					fetch c_jie into @menu, @inumber, @jamount, @jsrv, @jtax, @special
					while @@sqlstatus = 0
						begin
						if	@special = 'E'
							begin
							fetch c_jie into @menu, @inumber, @jamount, @jsrv, @jtax, @special
							continue
							end
						select @thispart = round( @jamount * @divval , 2)
						select @thispart1 = round( @jsrv * @divval , 2)
						select @thispart2 = round( @jtax * @divval , 2)
						select @sumpart  = @sumpart + @thispart, @sumpart_srv  = @sumpart_srv + @thispart1,@sumpart_tax  = @sumpart_tax + @thispart2
						select @sumsrv = @sumsrv + @jsrv,@sumtax = @sumtax + @jtax
						insert #jiedai (menu, inumber, paycode, amount, srv, tax, reason3) values (@menu, @inumber, @paycode, @thispart, @thispart1, @thispart2, @reason3)
						fetch c_jie into @menu, @inumber, @jamount, @jsrv, @jtax, @special
						end
					close c_jie

					--  补差额
					select @diffpart = @damount  - @sumpart
					if @diffpart <> 0
						begin 
						open c_jiedai
						fetch c_jiedai into @menu, @inumber
						while @@sqlstatus = 0
							begin
							update #jiedai set amount = amount + @diffpart
								where menu = @menu and inumber = @inumber and paycode = @paycode and reason3 = @reason3
							if @@rowcount = 1
								break
							fetch c_jiedai into @menu, @inumber
							end
						close c_jiedai
						end 
					--  补差额-srv
					select @diffpart = round( @sumsrv * @divval , 2)  - @sumpart_srv
					if @diffpart <> 0
						begin 
						open c_jiedai
						fetch c_jiedai into @menu, @inumber
						while @@sqlstatus = 0
							begin
							update #jiedai set srv = srv + @diffpart
								where menu = @menu and inumber = @inumber and paycode = @paycode and reason3 = @reason3 and inumber<>2 and inumber<>3
							if @@rowcount = 1
								break
							fetch c_jiedai into @menu, @inumber
							end
						close c_jiedai
						end 
					--  补差额-tax
					select @diffpart = round( @sumtax * @divval , 2)  - @sumpart_tax
					if @diffpart <> 0
						begin 
						open c_jiedai
						fetch c_jiedai into @menu, @inumber
						while @@sqlstatus = 0
							begin
							update #jiedai set tax = tax + @diffpart
								where menu = @menu and inumber = @inumber and paycode = @paycode and reason3 = @reason3 and inumber<>2 and inumber<>3
							if @@rowcount = 1
								break
							fetch c_jiedai into @menu, @inumber
							end
						close c_jiedai
						end 
					fetch c_dai into @paycode, @distribute, @entpost, @damount, @reason3
					end
				close c_dai

				if @i = 0  -- 折扣款待分摊
					insert pos_detail_jie (date, deptno, posno, pccode, shift, empno, menu, code, id, type, name1, name2, number, amount0, amount1, amount2, amount3, 
						serve0, serve1, serve2, serve3, tax0, tax1, tax2, tax3, reason1, reason2,reason3, special, tocode)
					select date, a.deptno, a.posno,a.pccode, a.shift, a.empno, a.menu, a.code, a.id, isnull(b.paycode,''), a.name1, a.name2,a.number,a.amount0,a.amount1,a.amount2, isnull(b.amount,0),
						a.serve0,a.serve1,a.serve2,isnull(b.srv, 0),a.tax0,a.tax1,a.tax2,isnull(b.tax, 0),a.reason1,a.reason2, isnull(b.reason3,''),a.special, a.tocode
						from pos_detail_jie a, #jiedai b where a.date = @date and a.menu = b.menu and a.id = b.inumber

				insert pos_detail_dai (date, menu, paycode, amount, reason3)
				select @date, menu, paycode, sum(amount), reason3 from #jiedai group by menu, paycode, reason3

				-- 单菜款待计入pos_detail_dai
				if exists(select 1 from pos_detail_dai a,#jiedai_ent b where a.menu = b.menu and a.paycode=b.paycode and a.reason3=b.reason3 )
					update pos_detail_dai set amount = a.amount + b.amount from pos_detail_dai a,#jiedai_ent b where a.menu = b.menu and a.paycode=b.paycode and a.reason3=b.reason3 
				else
					insert pos_detail_dai (date, menu, paycode, amount, reason3)
					select @date, menu, paycode, sum(amount), reason3 from #jiedai_ent group by menu, paycode,reason3 order by menu, paycode,reason3


				truncate table #jiedai
				truncate table #jiedai_ent
				end
			end
		select @i = @i + 1
		end


		if not exists ( select 1 from pos_detail_dai where date = @date and menu = @menu  )
			insert pos_detail_dai (date, menu, paycode, amount, reason3)
			select @date, @menu, paycode, sum(amount), reason3 from #dai group by paycode, reason3
		if exists ( select 1 from pos_detail_dai where date = @date and menu = @menu ) and
			not exists ( select 1 from pos_detail_jie where date = @date and menu = @menu )
			begin
			select @tocode = min(code) from pos_itemdef where pccode = @pccode
                                                                                                                
			insert pos_detail_jie values(@date, @deptno, @posno, @pccode, @shift, @empno, @menu, '', 0, '', '', '', 0, 0, 0, 0, 0, 
				0, 0, 0, 0, 0, 0, 0, 0, '', '', '', 'N', @tocode)
			end
	exec p_cyj_pos_detail_dai_adj @master_menu
	fetch c_master_menu into @master_menu, @pcrec, @paid
	end
close c_master_menu
   
deallocate cursor c_master_menu
deallocate cursor c_menu
deallocate cursor c_dish
deallocate cursor c_pay
deallocate cursor c_jie
deallocate cursor c_dai
deallocate cursor c_jiedai
                     

return 0
;