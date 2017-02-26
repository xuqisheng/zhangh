
if exists(select * from sysobjects where name = "p_av_res_dotbmp_tip" and type = 'P')
	drop proc p_av_res_dotbmp_tip
;
create proc  p_av_res_dotbmp_tip
	@folios 	 varchar(255),				              ---传进来的参数为folio+'#'+folio+'#'
	@langid   int = 0
as
begin
	declare
		@accnt	  char(10),
		@folio     char(10),
		@name      varchar(30),
		@sta		  char(1),
		@remark    varchar(100),
		@fzr		  varchar(20),
		@arrdep	  varchar(100),
		@class     char(7),
		@unit      varchar(100),
		@tableno   varchar(100),
		@descript1 varchar(30),
		@descript  varchar(30),
		@pccode    varchar(30),
		@resid     char(10),
		@sfld      varchar(30),
		@qty       integer,
		@fld       integer,
		@len		  integer,
		@tabs      integer,  
		@avname    varchar(30),
		@guests    integer   
	
	create table #tips
	(
		tips		varchar(255) 		not null,
		len		int default 0 		not null
	)
	
	
	while datalength (@folios) >= 10
	begin
		select @folio = substring(@folios,1,10),@folios = substring(@folios,12,datalength(@folios))
		if substring(@folio,1,1) = 'M'
		begin
			if exists(select 1 from res_av where folio = @folio)
			begin
				select @accnt = accnt,@remark = summary,@resid = resid,@qty = qty,@sta = sta,
						 @arrdep = convert(char(5),stime,1)+'   [ '+substring(convert(char(20),stime,108),1,5)+" -> "+substring(convert(char(20),etime,108),1,5) +' ] ',
						 @fld = sfield,@fzr = worker
					from res_av  where folio = @folio
				select @name = name from guest where no = (select haccnt from master where accnt = @accnt)
			end
			else
			begin
				select @accnt = accnt,@remark = summary,@resid = resid,@qty = qty,@sta = sta,
						 @arrdep = convert(char(5),stime,1)+'   [ '+substring(convert(char(20),stime,108),1,5)+" -> "+substring(convert(char(20),etime,108),1,5) +' ] ',
						@fld = sfield,@fzr = worker
					from res_av_h where folio = @folio
				select @name = name from guest where no = (select haccnt from hmaster where accnt = @accnt)
			end
			
			if @fzr = null or @fzr = ''
				select @fzr = '_'
			if @remark = null or @remark = ''
				select @remark = '_'
			if @langid = 0
				select @avname = rtrim(descript) from basecode where cat = 'dict_status.avs' and code = @sta
			else
				select @avname = rtrim(descript1) from basecode where cat = 'dict_status.avs' and code = @sta
			
			insert #tips select ' 0^ 电脑单号: %1^' +@folio  ,25
			if datalength(@name) > 1
				insert #tips select ' 0^ 宾客帐号:%1^ ' +@accnt +'  '+@name ,datalength(@name)+15
			insert #tips select ' 0^ 会 议 室:%1  %2      ☆数量: ^'  + rtrim(name) +'^'+convert(char(3),@qty), 0  from res_plu where resid = @resid
			insert #tips select ' 0^ 预定时间:%1^ '  +@arrdep,0
			insert #tips select ' 0^ 摘    要: %1^'  +@remark,0
			if @fld = 1
				select @sfld = '  场次: 上午'
			if @fld = 2
				select @sfld = '  场次: 下午'
			if @fld = 3
				select @sfld = '  场次: 晚上'
			insert #tips select ' 0^ 负 责 人:%1   '+ @sfld +'^' +@fzr  ,0
			insert #tips select replicate('-',60), 0   
		end
			
		if substring(@folio,1,1) = 'O'
		begin
			select @arrdep = convert(char(5),stime,1)+' - '+substring(convert(char(20),stime,108),1,5)+"->"	+convert(char(5),etime,1)+' - '+substring(convert(char(20),etime,108),1,5),
					@qty = qty,@fzr = worker,@remark = summary, @resid = resid
				from res_ooo where folio = @folio
			if @fzr = null or @fzr = ''
				select @fzr = '_'
			if @remark = null or @remark = ''
				select @remark = '_'
			
			insert #tips select '  0^电脑单号:%1^ ' +@folio  , 16
			insert #tips select '  0^会 议 室: %1 %2    ☆数量:^ ' + rtrim(name) +'^'+convert(char(3),@qty), 0  from res_plu where resid = @resid
			insert #tips select '  0^维修时间: %1^' +@arrdep , 0
			insert #tips select '  0^维修内容: %1^' +@remark , 0
			insert #tips select '  0^维 修 人: %1^' +@fzr , 0
			insert #tips select replicate('-',60), 0   
		end
		
		if substring(@folio,1,1) = 'R'
		begin
			if exists(select 1 from pos_reserve where resno = @folio)
			begin
				select @name = name,@unit = unit,@pccode = pccode,@tableno = tableno,@tabs = tables,@guests = guest
					from pos_reserve where resno = @folio
			end
			else
			begin
				select @name = name, @unit = unit, @pccode = pccode, @tableno = tableno, @tabs = tables, @guests = guest
					from pos_hreserve where resno = @folio
			end
			select @descript1 = descript1 from pos_tblsta where tableno = @tableno
			if @descript1 <> null  and @descript1 <> ''
				select @tableno =   @tableno +'   '+@descript1
			else
				select @tableno =  @tableno +'   '
			select @tableno = @tableno + '^ '+convert(char(3),@tabs)+'^ '+convert(char(4),@guests)
			select @descript = descript from pos_pccode where pccode = @pccode
			
			if @name = null or @name = ''
				select @name = '_'
			if @unit = null or @unit = ''
				select @unit = '_'
			if @descript = null or @descript = ''
				select @descript = '_'

			insert #tips select ' 0^ 电脑单号: ' +@folio  , 16
			insert #tips select ' 0^ 台   号:  %1 桌数:  %2  人数:%3   营 业 点: %4^'+@tableno   +'^'+  @descript ,  20
			insert #tips select ' 0^ 预 定 人: %1^ ' +@name   , 16
			insert #tips select ' 0^ 预定单位: %1^ ' +@unit   , 16
			insert #tips select replicate('-',60), 0   
		end
		select @len = max(datalength(tips)) from #tips where tips <> '─────────────────────────────────────────'
		update #tips set len = @len
			
	end
			
	select tips, len from #tips
	return 0
end
;
		
