//====================================================================
// Database Administration - 2.2.SYT SQL Server 4.x.foxhis3.dbo
// Reason: 
//--------------------------------------------------------------------
// Modified By: wz		Date: 2003.7.1
//--------------------------------------------------------------------
//实现当前和历史库存的查询
//====================================================================

if exists (select 1 from sysobjects where name = 'p_wz_bos_kc_cx_rep')
	drop proc p_wz_bos_kc_cx_rep;

create Proc  p_wz_bos_kc_cx_rep
	@modu			varchar(2)     , 
	@pccode0		varChar(60) = '',
	@site0		varchar(5) = '',
	@code0		varchar(8) = '',
	@begin_		DateTime			,
	@end_			DateTime

as
declare
	@ret 			integer,
	@msg 			varchar(60) ,
	@sysdate		datetime ,
	@id			char(6) ,
	@begin0     datetime

create table #bos_detail_temp	
(	pccode      char(5)  	not null,
	site			char(5)		not null,
	code			char(8)		not null,
	id				char(6)		not null,
	ii				int			not null,
	flag			char(2)		not null,
	descript		varchar(20)	    null,
	folio			char(10)	   not null,
	sfolio		varchar(20)     null,
	fid			int 			default 0	not null,
	rsite			char(5)  	default ''  not null,
	bdate			datetime		not null,
	act_date		datetime 	not null,
	log_date		datetime 	not null,
	empno			char(3)		    null,

	number		money	 default 0	 ,
	amount0		money  default 0	 ,
	amount		money  default 0	 ,
	disc			money  default 0	 ,
	profit		money  default 0	 ,

	gnumber		money  default 0 	 ,
	gamount0		money  default 0 	 ,
	gamount		money  default 0   ,
	gprofit		money  default 0 	 ,
	price0		money  default 0	 ,
	price1 		money	 default 0
	)
create index index1 on #bos_detail_temp(pccode,site, code,flag)


create table #bos_store_temp (
		spccode  	char(5)	not null,
		ssite	  		char(5)	not null,    			         
		scode	  		char(8)	not null,				       
		number0 		money 	default 0 	,	           
		samount0		money 	default 0 	,
		sale0			money 	default 0 	,
		profit0 		money 	default 0	,
		number1		money 	default 0	,	       
		amount1		money 	default 0	,
		sale1			money 	default 0 	,
		profit1		money 	default 0 	,
		number2  	money 	default 0 	,	       
		amount2		money 	default 0 	,
		sale2			money 	default 0 	,
		profit2		money	   default 0	,
		number3 		money 	default 0 	,	       
		amount3		money 	default 0	,
		sale3			money 	default 0 	,
		profit3		money 	default 0 	,
		number4		money 	default 0 	,	       
		amount4		money 	default 0 	,
		sale4			money 	default 0	,
		profit4		money 	default 0 	,  
		number5		money 	default 0 	,	        
		amount5		money 	default 0 	,
		sale5	   	money 	default 0 	,
		disc			money		default 0	,
		profit5		money 	default 0 	,
		number6		money 	default 0 	,	       
		amount6		money 	default 0 	,
		sale6			money 	default 0 	,
		profit6 		money 	default 0 	,
		number7		money 	default 0 	,	            
		amount7		money 	default 0 	,
		sale7			money 	default 0 	,
		profit7		money 	default 0 	,
		number8		money 	default 0	,	            
		amount8		money 	default 0	,
		sale8			money 	default 0	,
		profit8		money 	default 0	,
		number9		money 	default 0 	,	       
		amount9		money 	default 0 	,
		sale9		   money 	default 0	,
		profit9		money 	default 0 	,
		price0		money   	default 0	,
		price1 		money	 	default 0
)
//create unique index index1 on #bos_detail_temp(pccode,site,code,bdate)

create table #store_temp (
		spccode  	char(5)	not null,
		ssite	  		char(5)	not null,    			         
		scode	  		char(8)	not null,				       
		number0 		money 	default 0 	,	           
		samount0		money 	default 0 	,
		sale0			money 	default 0 	,
		profit0 		money 	default 0	,
		number1		money 	default 0	,	       
		amount1		money 	default 0	,
		sale1			money 	default 0 	,
		profit1		money 	default 0 	,
		number2  	money 	default 0 	,	       
		amount2		money 	default 0 	,
		sale2			money 	default 0 	,
		profit2		money	   default 0	,
		number3 		money 	default 0 	,	       
		amount3		money 	default 0	,
		sale3			money 	default 0 	,
		profit3		money 	default 0 	,
		number4		money 	default 0 	,	       
		amount4		money 	default 0 	,
		sale4			money 	default 0	,
		profit4		money 	default 0 	,  
		number5		money 	default 0 	,	        
		amount5		money 	default 0 	,
		sale5	   	money 	default 0 	,
		disc			money		default 0	,
		profit5		money 	default 0 	,
		number6		money 	default 0 	,	       
		amount6		money 	default 0 	,
		sale6			money 	default 0 	,
		profit6 		money 	default 0 	,
		number7		money 	default 0 	,	            
		amount7		money 	default 0 	,
		sale7			money 	default 0 	,
		profit7		money 	default 0 	,
		number8		money 	default 0	,	            
		amount8		money 	default 0	,
		sale8			money 	default 0	,
		profit8		money 	default 0	,
		number9		money 	default 0 	,	       
		amount9		money 	default 0 	,
		sale9		   money 	default 0	,
		profit9		money 	default 0 	,
		price0		money    default 0	,
		price1 		money	   default 0
)
//create unique index index1 on #bos_detail_temp(pccode,site,code,bdate)


		select @ret = 0 , @msg = ''
		select @sysdate = bdate1  from  sysdata                     
		select @id = id from bos_kcdate where begin_ = (select Max(begin_) from bos_kcdate where @begin_ > =begin_)

		if datediff( day , @end_ , @begin_ ) > 0
				select @ret = 1 , @msg = '日期输入出错，截止时间必须大于开始时间！'
		if datediff (day , @sysdate , @end_ ) > 0 
				select @end_ = @sysdate
		
		if rtrim(@code0) = null or @code0 = ''
			select @code0 = '%'
		else
			select @code0 = @code0 + '%'
		if rtrim(@pccode0) = null or @pccode0 = ''
			select @pccode0 = '%' 
		else
			select @pccode0 = @pccode0 + '%'
		if rtrim(@site0) = null or @site0 = ''
			select @site0 = '%'
		else
			select @site0 = @site0 +'%'

--当前库存物品查询
if @begin_ > = @sysdate 
begin
	insert #bos_store_temp
		select a.pccode,a.site,a.code,a.number0,a.amount0,a.sale0,a.profit0,a.number1,a.amount1,a.sale1,a.profit1,a.number2,a.amount2,a.sale2,a.profit2,
		 a.number3 ,a.amount3,a.sale3,a.profit3,a.number4,a.amount4,a.sale4,a.profit4,a.number5,a.amount5,a.sale5,a.disc,a.profit5,a.number6,a.amount6,
		 a.sale6,a.profit6,a.number7,a.amount7,a.sale7,a.profit7,a.number8,a.amount8,a.sale8,a.profit8,a.number9,a.amount9,a.sale9,a.profit9,a.price0,a.price1 
		 from bos_store a 
		 where  a.pccode like @pccode0 
				and a.code like @code0	
				and a.site like @site0
	
end 
--历史库存查询	
else
	begin
//--插入临时表bos_detail数据
		if exists(select 1 from bos_hstore where id = @id)
			insert into #store_temp(spccode,ssite,scode,number0,samount0,sale0,profit0,price0,price1)  
				select pccode,site,code,number0,amount0,sale0,profit0,price0,price1 from bos_hstore
				where  id = @id
					and code like @code0  
					and pccode like @pccode0 
					and site like @site0 
		else
			insert into #store_temp(spccode,ssite,scode,number0,samount0,sale0,profit0,price0,price1)  
				select pccode,site,code,number0,amount0,sale0,profit0,price0,price1 from bos_store
				where  id = @id
					and code like @code0  
					and pccode like @pccode0 
					and site like @site0 
				
		if exists(select 1 from bos_hdetail where id = @id)
		begin
			insert into #store_temp(spccode,ssite,scode,number1,amount1,sale1,profit1,price0,price1)  
				select pccode,site,code,number,amount0,amount,profit,price0,price1 from bos_hdetail
					where flag = '入'
						and act_date < @begin_ 
						and id = @id
						and code like	@code0
						and pccode like @pccode0 
						and site like @site0 
			insert into #store_temp(spccode,ssite,scode,number2,amount2,sale2,profit2,price0,price1)  
				select pccode,site,code,number,amount0,amount,profit,price0,price1 from bos_hdetail
					where flag = '损'
						and act_date < @begin_ 
						and id = @id
						and code like	@code0
						and pccode like @pccode0 
						and site like @site0 
			insert into #store_temp(spccode,ssite,scode,number3,amount3,sale3,profit3,price0,price1)  
				select pccode,site,code,number,amount0,amount,profit,price0,price1 from bos_hdetail
					where flag = '盘'
						and act_date < @begin_ 
						and id = @id
						and code like	@code0
						and pccode like @pccode0 
						and site like @site0 
			insert into #store_temp(spccode,ssite,scode,number4,amount4,sale4,profit4,price0,price1)  
				select pccode,site,code,number,amount0,amount,profit,price0,price1 from bos_hdetail
					where flag = '调'
						and act_date < @begin_ 
						and id = @id
						and code like	@code0
						and pccode like @pccode0 
						and site like @site0 
			insert into #store_temp(spccode,ssite,scode,number5,amount5,sale5,disc,profit5,price0,price1)  
				select pccode,site,code,number,amount0,amount,disc,profit,price0,price1 from bos_hdetail
					where flag = '售'
						and act_date < @begin_ 
						and id = @id
						and code like	@code0
						and pccode like @pccode0 
						and site like @site0 
			insert into #store_temp(spccode,ssite,scode,number6,amount6,sale6,profit6,price0,price1)  
				select pccode,site,code,number,amount0,amount,profit,price0,price1 from bos_hdetail
					where flag = '领'
						and act_date < @begin_ 
						and id = @id
						and code like	@code0
						and pccode like @pccode0 
						and site like @site0
			insert into #store_temp(spccode,ssite,scode,number7,amount7,sale7,profit7,price0,price1)  
				select pccode,site,code,number,amount0,amount,profit,price0,price1 from bos_hdetail
					where flag = '内'
						and act_date < @begin_ 
						and id = @id
						and code like	@code0
						and pccode like @pccode0 
						and site like @site0  
			insert into #store_temp(spccode,ssite,scode,number7,amount7,sale7,profit7,price0,price1)  
				select pccode,site,code,number,amount0,amount,profit,price0,price1 from bos_hdetail
					where flag = '外'
						and act_date < @begin_ 
						and id = @id
						and code like	@code0
						and pccode like @pccode0 
						and site like @site0 
		end
		else
		begin
			insert into #store_temp(spccode,ssite,scode,number1,amount1,sale1,profit1,price0,price1)  
				select pccode,site,code,number,amount0,amount,profit,price0,price1 from bos_detail
					where flag = '入'
						and act_date < @begin_ 
						and id = @id
						and code like	@code0
						and pccode like @pccode0 
						and site like @site0 
			insert into #store_temp(spccode,ssite,scode,number2,amount2,sale2,profit2,price0,price1)  
				select pccode,site,code,number,amount0,amount,profit,price0,price1 from bos_detail
					where flag = '损'
						and act_date < @begin_ 
						and id = @id
						and code like	@code0
						and pccode like @pccode0 
						and site like @site0 
			insert into #store_temp(spccode,ssite,scode,number3,amount3,sale3,profit3,price0,price1)  
				select pccode,site,code,number,amount0,amount,profit,price0,price1 from bos_detail
					where flag = '盘'
						and act_date < @begin_ 
						and id = @id
						and code like	@code0
						and pccode like @pccode0 
						and site like @site0 
			insert into #store_temp(spccode,ssite,scode,number4,amount4,sale4,profit4,price0,price1)  
				select pccode,site,code,number,amount0,amount,profit,price0,price1 from bos_detail
					where flag = '调'
						and act_date < @begin_ 
						and id = @id
						and code like	@code0
						and pccode like @pccode0 
						and site like @site0 
			insert into #store_temp(spccode,ssite,scode,number5,amount5,sale5,disc,profit5,price0,price1)  
				select pccode,site,code,number,amount0,amount,disc,profit,price0,price1 from bos_detail
					where flag = '售'
						and act_date < @begin_ 
						and id = @id
						and code like	@code0
						and pccode like @pccode0 
						and site like @site0 
			insert into #store_temp(spccode,ssite,scode,number6,amount6,sale6,profit6,price0,price1)  
				select pccode,site,code,number,amount0,amount,profit,price0,price1 from bos_detail
					where flag = '领'
						and act_date < @begin_ 
						and id = @id
						and code like	@code0
						and pccode like @pccode0 
						and site like @site0
			insert into #store_temp(spccode,ssite,scode,number7,amount7,sale7,profit7,price0,price1)  
				select pccode,site,code,number,amount0,amount,profit,price0,price1 from bos_detail
					where flag = '内'
						and act_date < @begin_ 
						and id = @id
						and code like	@code0
						and pccode like @pccode0 
						and site like @site0  
			insert into #store_temp(spccode,ssite,scode,number7,amount7,sale7,profit7,price0,price1)  
				select pccode,site,code,number,amount0,amount,profit,price0,price1 from bos_detail
					where flag = '外'
						and act_date < @begin_ 
						and id = @id
						and code like	@code0
						and pccode like @pccode0 
						and site like @site0 
		end
		
		
		// create real bos_store_temp
		insert #bos_store_temp 
			select spccode,ssite,scode,sum(number0),sum(samount0),sum(sale0),sum(profit0),
				sum(number1),sum(amount1),sum(sale1),sum(profit1),
				sum(number2),sum(amount2),sum(sale2),sum(profit2),
				sum(number3),sum(amount3),sum(sale3),sum(profit3),
				sum(number4),sum(amount4),sum(sale4),sum(profit4),
				sum(number5),sum(amount5),sum(sale5),sum(disc),sum(profit5),
				sum(number6),sum(amount6),sum(sale6),sum(profit6),
				sum(number7),sum(amount7),sum(sale7),sum(profit7),
				sum(number8),sum(amount8),sum(sale8),sum(profit8),
				sum(number9),sum(amount9),sum(sale9),sum(profit9),price0,price1
				from #store_temp
				group by spccode, ssite, scode
		update #bos_store_temp set number9=number0 + number1 - number2 + number3 - number4 - number5 + number6,
			amount9 = samount0 + amount1 - amount2 + amount3 - amount4 - amount5 + amount6,
			sale9 =sale0 + sale1 - sale2 + sale3 - sale4 - sale5 + sale6,
			profit9 = profit0 + profit1 - profit2 + profit3 - profit4 - profit5 + profit6  
		where spccode like @pccode0 and scode like @code0 and ssite like @site0
		
		--delete 
		delete #store_temp
		
		--step2
		if exists(select 1 from bos_hdetail where act_date>=@begin_ and act_date<=@end_)
		begin
			insert into #store_temp(spccode,ssite,scode,number0,samount0,sale0,profit0,price0,price1)  
				select spccode,ssite,scode,number9,amount9,sale9,profit9,price0,price1 from #bos_store_temp
				where  scode like @code0  
					and spccode like @pccode0 
					and ssite like @site0 
			insert into #store_temp(spccode,ssite,scode,number1,amount1,sale1,profit1,price0,price1)  
				select pccode,site,code,number,amount0,amount,profit,price0,price1 from bos_hdetail
					where flag = '入'
						and act_date >= @begin_ and act_date <=@end_ 
						and code like	@code0
						and pccode like @pccode0 
						and site like @site0 
			insert into #store_temp(spccode,ssite,scode,number2,amount2,sale2,profit2,price0,price1)  
				select pccode,site,code,number,amount0,amount,profit,price0,price1 from bos_hdetail
					where flag = '损'
						and act_date >= @begin_ and act_date <=@end_ 
						and code like	@code0
						and pccode like @pccode0 
						and site like @site0 
			insert into #store_temp(spccode,ssite,scode,number3,amount3,sale3,profit3,price0,price1)  
				select pccode,site,code,number,amount0,amount,profit,price0,price1 from bos_hdetail
					where flag = '盘'
						and act_date >= @begin_ and act_date <=@end_ 
						and code like	@code0
						and pccode like @pccode0 
						and site like @site0 
			insert into #store_temp(spccode,ssite,scode,number4,amount4,sale4,profit4,price0,price1)  
				select pccode,site,code,number,amount0,amount,profit,price0,price1 from bos_hdetail
					where flag = '调'
						and act_date >= @begin_ and act_date <=@end_ 
						and code like	@code0
						and pccode like @pccode0 
						and site like @site0 
			insert into #store_temp(spccode,ssite,scode,number5,amount5,sale5,profit5,price0,price1)  
				select pccode,site,code,number,amount0,amount,profit,price0,price1 from bos_hdetail
					where flag = '售'
						and act_date >= @begin_ and act_date <=@end_ 
						and code like	@code0
						and pccode like @pccode0 
						and site like @site0 
			insert into #store_temp(spccode,ssite,scode,number6,amount6,sale6,profit6,price0,price1)  
				select pccode,site,code,number,amount0,amount,profit,price0,price1 from bos_hdetail
					where flag = '领'
						and act_date >= @begin_ and act_date <=@end_ 
						and code like	@code0
						and pccode like @pccode0 
						and site like @site0
			insert into #store_temp(spccode,ssite,scode,number7,amount7,sale7,profit7,price0,price1)  
				select pccode,site,code,number,amount0,amount,profit,price0,price1 from bos_hdetail
					where flag = '内'
						and act_date >= @begin_ and act_date <=@end_ 
						and code like	@code0
						and pccode like @pccode0 
						and site like @site0  
			insert into #store_temp(spccode,ssite,scode,number7,amount7,sale7,profit7,price0,price1)  
				select pccode,site,code,number,amount0,amount,profit,price0,price1 from bos_hdetail
					where flag = '外'
						and act_date >= @begin_ and act_date <=@end_ 
						and code like	@code0
						and pccode like @pccode0 
						and site like @site0 
		
		end
		else
		begin
			insert into #store_temp(spccode,ssite,scode,number0,samount0,sale0,profit0,price0,price1)  
				select spccode,ssite,scode,number9,amount9,sale9,profit9,price0,price1 from #bos_store_temp
				where  scode like @code0  
					and spccode like @pccode0 
					and ssite like @site0 
			insert into #store_temp(spccode,ssite,scode,number1,amount1,sale1,profit1,price0,price1)  
				select pccode,site,code,number,amount0,amount,profit,price0,price1 from bos_detail
					where flag = '入'
						and act_date >= @begin_ and act_date <=@end_ 
						and code like	@code0
						and pccode like @pccode0 
						and site like @site0 
			insert into #store_temp(spccode,ssite,scode,number2,amount2,sale2,profit2,price0,price1)  
				select pccode,site,code,number,amount0,amount,profit,price0,price1 from bos_detail
					where flag = '损'
						and act_date >= @begin_ and act_date <=@end_ 
						and code like	@code0
						and pccode like @pccode0 
						and site like @site0 
			insert into #store_temp(spccode,ssite,scode,number3,amount3,sale3,profit3,price0,price1)  
				select pccode,site,code,number,amount0,amount,profit,price0,price1 from bos_detail
					where flag = '盘'
						and act_date >= @begin_ and act_date <=@end_ 
						and code like	@code0
						and pccode like @pccode0 
						and site like @site0 
			insert into #store_temp(spccode,ssite,scode,number4,amount4,sale4,profit4,price0,price1)  
				select pccode,site,code,number,amount0,amount,profit,price0,price1 from bos_detail
					where flag = '调'
						and act_date >= @begin_ and act_date <=@end_ 
						and code like	@code0
						and pccode like @pccode0 
						and site like @site0 
			insert into #store_temp(spccode,ssite,scode,number5,amount5,sale5,profit5,price0,price1)  
				select pccode,site,code,number,amount0,amount,profit,price0,price1 from bos_detail
					where flag = '售'
						and act_date >= @begin_ and act_date <=@end_ 
						and code like	@code0
						and pccode like @pccode0 
						and site like @site0 
			insert into #store_temp(spccode,ssite,scode,number6,amount6,sale6,profit6,price0,price1)  
				select pccode,site,code,number,amount0,amount,profit,price0,price1 from bos_detail
					where flag = '领'
						and act_date >= @begin_ and act_date <=@end_ 
						and code like	@code0
						and pccode like @pccode0 
						and site like @site0
			insert into #store_temp(spccode,ssite,scode,number7,amount7,sale7,profit7,price0,price1)  
				select pccode,site,code,number,amount0,amount,profit,price0,price1 from bos_detail
					where flag = '内'
						and act_date >= @begin_ and act_date <=@end_ 
						and code like	@code0
						and pccode like @pccode0 
						and site like @site0  
			insert into #store_temp(spccode,ssite,scode,number7,amount7,sale7,profit7,price0,price1)  
				select pccode,site,code,number,amount0,amount,profit,price0,price1 from bos_detail
					where flag = '外'
						and act_date >= @begin_ and act_date <=@end_ 
						and code like	@code0
						and pccode like @pccode0 
						and site like @site0 
			
		end
		
		delete #bos_store_temp
		
		insert #bos_store_temp 
			select spccode,ssite,scode,sum(number0),sum(samount0),sum(sale0),sum(profit0),
				sum(number1),sum(amount1),sum(sale1),sum(profit1),
				sum(number2),sum(amount2),sum(sale2),sum(profit2),
				sum(number3),sum(amount3),sum(sale3),sum(profit3),
				sum(number4),sum(amount4),sum(sale4),sum(profit4),
				sum(number5),sum(amount5),sum(sale5),sum(disc),sum(profit5),
				sum(number6),sum(amount6),sum(sale6),sum(profit6),
				sum(number7),sum(amount7),sum(sale7),sum(profit7),
				sum(number8),sum(amount8),sum(sale8),sum(profit8),
				sum(number9),sum(amount9),sum(sale9),sum(profit9),price0,price1
				from #store_temp
				group by spccode, ssite, scode
		
		update #bos_store_temp set number9=number0 + number1 - number2 + number3 - number4 - number5 + number6,
			amount9 = samount0 + amount1 - amount2 + amount3 - amount4 - amount5 + amount6,
			sale9 =sale0 + sale1 - sale2 + sale3 - sale4 - sale5 + sale6,
			profit9 = profit0 + profit1 - profit2 + profit3 - profit4 - profit5 + profit6  
			where spccode like @pccode0 and scode like @code0  and ssite like @site0
		
	end		 
	
	select distinct a.ssite,a.scode,c.descript,b.name,a.number0,a.number1 'ru',a.number2 'sun',a.number3 'pan',
				a.number4 'diao',a.number5 'shou',a.number6 'ling',profit9,a.price0,a.price1,a.number9
	from #bos_store_temp a ,bos_plu b, bos_site c
	where a.scode like @code0 and a.spccode like @pccode0 and a.ssite like @site0
		and a.scode = b.code and a.spccode = b.pccode
		and b.pccode = c.pccode and a.ssite = c.site
	

return 0 
;