---------------------------------------------------------
--  标准版弃用，替代过程=p_cq_audit_create_cms
---------------------------------------------------------

if  exists(select * from sysobjects where name = "p_tcr_audit_cms")
	drop proc p_tcr_audit_cms
;
//create proc p_tcr_audit_cms
//as
//---------------------------------------------------------
//-- 夜间调整 cms_rec = 佣金计算 
//--
//-- 处理时机：夜审过程中，如果需要马上扣减房费，需要放在夜审前
//-- 问题如下：
//--		1、针对cusno,agent,source分别处理，可能导致重复
//--		2、rmtype_s 并没有针对性处理 
//--		3、upmode 阶梯返佣时间段 也没有针对性处理 
//--
//--  标准版弃用，替代过程=p_cq_audit_create_cms
//---------------------------------------------------------
//declare
//	@bdate			datetime,
//	@bfdate			datetime,
//	@duringaudit	char(1),
//	@accnt			char(10),
//	@cmscode			char(10),
//	@upmode			char(1),
//	@rmtype_s		char(1),
//	@pri				integer,
//	@cmscode_detail char(10),
//	@unit				 char(1),
//	@type				 char(1),
//	@rmtype			 varchar(30),
//	@amount			 money,
//	@dayuse			 char(1),
//	@uproom1			 integer,@upamount1      money,
//	@uproom2			 integer,@upamount2      money,
//	@uproom3			 integer,@upamount3      money,
//	@uproom4			 integer,@upamount4      money,		
//	@uproom5			 integer,@upamount5      money,		
//	@uproom6			 integer,@upamount6      money,		
//	@uproom7			 integer,@upamount7      money,
//	@upamount       money,
//	@week           varchar(30),@weeknow    char(1),
//	@rmmode         char(8), @nights		    integer,
//	@datecond		 varchar(80),@ret        integer
//
//select @duringaudit = audit from gate
//select @bdate = bdate from sysdata
//
//update cms_rec set type = a.type from rmsta a where cms_rec.bdate = @bdate and cms_rec.roomno=a.roomno
//
//declare c_cmscode_link cursor for select pri,cmscode from cmscode_link where code=@cmscode order by pri
//
//declare c_cms_rec cursor for select distinct cusno,cmscode from cms_rec where cusno<>''
//	and bdate = @bdate and sta = 'I' 
//open c_cms_rec
//fetch c_cms_rec into @accnt, @cmscode
//while @@sqlstatus = 0
//	begin
//		select @upmode = upmode , @rmtype_s = rmtype_s from cmscode where code = @cmscode
//		open c_cmscode_link
//		fetch c_cmscode_link into @pri, @cmscode_detail
//		while @@sqlstatus = 0
//			begin
//				select @unit = unit,@type=type,@rmtype=rmtype,@amount=amount,@dayuse=dayuse,
//							@uproom1=uproom1,@upamount1=upamount1,@uproom2=uproom2,@upamount2=upamount2,
//							@uproom3=uproom3,@upamount3=upamount3,@uproom4=uproom4,@upamount4=upamount4,
//							@uproom5=uproom5,@upamount5=upamount5,@uproom6=uproom6,@upamount6=upamount6,
//							@uproom7=uproom7,@datecond = datecond 
//					from cms_defitem where no=@cmscode_detail
//				if rtrim(@datecond) is null
//					select @week = '1234567'
//				else
//					select @week = substring(@datecond,charindex('w:',lower(@datecond))+2,datalength(@datecond)-2)
//				select @weeknow = convert(char(1), datepart(weekday, @bdate)-1)
//				if @weeknow = '0'
//					select @weeknow = '7'
//
//				if @dayuse = 'T'
//					select @rmmode = 'JPBNbj'
//				else
//					select @rmmode = 'JjBb'
//						
//				if @uproom1=0
//					begin
//					if @unit = '0'	and @type='0'
//						update cms_rec set cms0 = rmrate*@amount*w_or_h,cmsunit=@unit,cmstype=@type,cmsdetail=@cmscode_detail where bdate = @bdate and cusno=@accnt and cmscode=@cmscode and (charindex(type,@rmtype)>0 or rtrim(@rmtype) is null) and sta = 'I'  and rtrim(cmsdetail) is null and charindex(@weeknow,@week)>0 and charindex(substring(mode,1,1),@rmmode)>0
//					else if 	@unit = '0'	and @type='1'
//						update cms_rec set cms0 = @amount*w_or_h,cmsunit=@unit,cmstype=@type,cmsdetail=@cmscode_detail where bdate = @bdate and cusno=@accnt and cmscode=@cmscode and (charindex(type,@rmtype)>0 or rtrim(@rmtype) is null) and sta = 'I'  and rtrim(cmsdetail) is null and charindex(@weeknow,@week)>0 and charindex(substring(mode,1,1),@rmmode)>0
//					else if 	@unit = '1'	and @type='0'
//						update cms_rec set cms0 = rmrate*@amount*w_or_h,cmsunit=@unit,cmstype=@type,cmsdetail=@cmscode_detail where bdate = @bdate and datediff(day,arr,bdate) = 0 and cusno=@accnt and cmscode=@cmscode and (charindex(type,@rmtype)>0 or rtrim(@rmtype) is null) and sta = 'I' and rtrim(cmsdetail) is null and charindex(@weeknow,@week)>0 and charindex(substring(mode,1,1),@rmmode)>0
//					else if 	@unit = '1'	and @type='1'
//						update cms_rec set cms0 = @amount*w_or_h,cmsunit=@unit,cmstype=@type,cmsdetail=@cmscode_detail where bdate = @bdate and datediff(day,arr,bdate) = 0 and cusno=@accnt and cmscode=@cmscode and (charindex(type,@rmtype)>0 or rtrim(@rmtype) is null) and sta = 'I' and rtrim(cmsdetail) is null and charindex(@weeknow,@week)>0 and charindex(substring(mode,1,1),@rmmode)>0
//					end
//				else
//					begin
//					if @upmode = 'M' and @rmtype_s = 'F'
//						begin
//						select @nights = sum(w_or_h) from cms_rec where cusno = @accnt and cmscode=@cmscode and datepart(month,bdate) = datepart(month,@bdate) and datepart(year,bdate) = datepart(year,@bdate) and sta='I' and cmsunit<>'1'
//						if @nights <  @uproom1
//							begin
//							if @unit = '0'	and @type='0'
//								update cms_rec set cms0 = rmrate*@amount*w_or_h,cmsunit=@unit,cmstype=@type,cmsdetail=@cmscode_detail where bdate = @bdate and cusno=@accnt and cmscode=@cmscode and (charindex(type,@rmtype)>0 or rtrim(@rmtype) is null) and sta = 'I'  and rtrim(cmsdetail) is null and charindex(@weeknow,@week)>0 and charindex(substring(mode,1,1),@rmmode)>0
//							else if 	@unit = '0'	and @type='1'
//								update cms_rec set cms0 = @amount*w_or_h,cmsunit=@unit,cmstype=@type,cmsdetail=@cmscode_detail where bdate = @bdate and cusno=@accnt and cmscode=@cmscode and (charindex(type,@rmtype)>0 or rtrim(@rmtype) is null) and sta = 'I'  and rtrim(cmsdetail) is null and charindex(@weeknow,@week)>0 and charindex(substring(mode,1,1),@rmmode)>0
//							else if 	@unit = '1' and @type='0'
//								update cms_rec set cms0 = rmrate*@amount*w_or_h,cmsunit=@unit,cmstype=@type,cmsdetail=@cmscode_detail where bdate = @bdate and datediff(day,arr,bdate) = 0 and cusno=@accnt and cmscode=@cmscode and (charindex(type,@rmtype)>0 or rtrim(@rmtype) is null) and sta = 'I' and rtrim(cmsdetail) is null and charindex(@weeknow,@week)>0 and charindex(substring(mode,1,1),@rmmode)>0
//							else if 	@unit = '1' and @type='1'
//								update cms_rec set cms0 = @amount*w_or_h,cmsunit=@unit,cmstype=@type,cmsdetail=@cmscode_detail where bdate = @bdate and datediff(day,arr,bdate) = 0 and cusno=@accnt and cmscode=@cmscode and (charindex(type,@rmtype)>0 or rtrim(@rmtype) is null) and sta = 'I' and rtrim(cmsdetail) is null and charindex(@weeknow,@week)>0 and charindex(substring(mode,1,1),@rmmode)>0
//							end
//						else if @nights >=  @uproom1 and (@nights< @uproom2 or @uproom2 = 0)
//							select @upamount = @upamount1
//						else if @nights >=  @uproom2 and (@nights< @uproom3 or @uproom3 = 0)
//							select @upamount = @upamount2
//						else if @nights >=  @uproom3 and (@nights< @uproom4 or @uproom4 = 0)
//							select @upamount = @upamount3
//						else if @nights >=  @uproom4 and (@nights< @uproom5 or @uproom5 = 0)
//							select @upamount = @upamount4
//						else if @nights >=  @uproom5 and (@nights< @uproom6 or @uproom6 = 0)
//							select @upamount = @upamount5
//						else if @nights >=  @uproom6 and (@nights< @uproom7 or @uproom7 = 0)
//							select @upamount = @upamount6
//						else if @nights >=  @uproom7 
//							select @upamount = @upamount7
//						if @nights >=  @uproom1	
//							if @unit = '0'	and @type='0'
//								begin
//								update cms_rec set cms=cms0,changed = getdate() where cusno=@accnt and cmscode=@cmscode and datepart(month,bdate) = datepart(month,@bdate) and datepart(year,bdate) = datepart(year,@bdate) and (charindex(type,@rmtype)>0 or rtrim(@rmtype) is null) and sta = 'I'  and charindex(@weeknow,@week)>0 and charindex(substring(mode,1,1),@rmmode)>0 and cms0<>rmrate*@upamount*w_or_h
//								update cms_rec set cms0 = rmrate*@upamount*w_or_h,cmsunit=@unit,cmstype=@type,cmsdetail=@cmscode_detail,changed = getdate(),back='F' where cusno=@accnt and cmscode=@cmscode and datepart(month,bdate) = datepart(month,@bdate) and datepart(year,bdate) = datepart(year,@bdate) and (charindex(type,@rmtype)>0 or rtrim(@rmtype) is null) and sta = 'I'  and charindex(@weeknow,@week)>0 and charindex(substring(mode,1,1),@rmmode)>0 and cms0<>rmrate*@upamount*w_or_h
//								end
//							else if 	@unit = '0'	and @type='1'
//								begin
//								update cms_rec set cms=cms0,changed = getdate() where cusno=@accnt and cmscode=@cmscode and datepart(month,bdate) = datepart(month,@bdate) and datepart(year,bdate) = datepart(year,@bdate) and (charindex(type,@rmtype)>0 or rtrim(@rmtype) is null) and sta = 'I'  and charindex(@weeknow,@week)>0 and charindex(substring(mode,1,1),@rmmode)>0 and cms0<>@upamount*w_or_h
//								update cms_rec set cms0 = @upamount*w_or_h,cmsunit=@unit,cmstype=@type,cmsdetail=@cmscode_detail,changed = getdate(),back='F' where cusno=@accnt and cmscode=@cmscode and datepart(month,bdate) = datepart(month,@bdate) and datepart(year,bdate) = datepart(year,@bdate) and (charindex(type,@rmtype)>0 or rtrim(@rmtype) is null) and sta = 'I'  and charindex(@weeknow,@week)>0 and charindex(substring(mode,1,1),@rmmode)>0 and cms0<>@upamount*w_or_h
//								end
//						end			
//				  end	
//			fetch c_cmscode_link into @pri, @cmscode_detail
//			end
//		close c_cmscode_link
//	fetch c_cms_rec into @accnt, @cmscode
//	end
//close c_cms_rec
//
//declare c_cms_rec1 cursor for select distinct agent,cmscode from cms_rec where agent<>''
//	and bdate = @bdate and sta = 'I' 
//open c_cms_rec1
//fetch c_cms_rec1 into @accnt, @cmscode
//while @@sqlstatus = 0
//	begin
//		select @upmode = upmode , @rmtype_s = rmtype_s from cmscode where code = @cmscode
//		open c_cmscode_link
//		fetch c_cmscode_link into @pri, @cmscode_detail
//		while @@sqlstatus = 0
//			begin
//				select @unit = unit,@type=type,@rmtype=rmtype,@amount=amount,@dayuse=dayuse,
//						@uproom1=uproom1,@upamount1=upamount1,@uproom2=uproom2,@upamount2=upamount2,
//						@uproom3=uproom3,@upamount3=upamount3,@uproom4=uproom4,@upamount4=upamount4,
//						@uproom5=uproom5,@upamount5=upamount5,@uproom6=uproom6,@upamount6=upamount6,
//						@uproom7=uproom7,@datecond = datecond 
//					from cms_defitem where no=@cmscode_detail
//				if rtrim(@datecond) is null
//					select @week = '1234567'
//				else
//					select @week = substring(@datecond,charindex('w:',lower(@datecond))+2,datalength(@datecond)-2)
//				select @weeknow = convert(char(1), datepart(weekday, @bdate)-1)
//				if @weeknow = '0'
//					select @weeknow = '7'
//				if @dayuse = 'T'
//					select @rmmode = 'JPBNbj'
//				else
//					select @rmmode = 'JjBb'
//						
//				if @uproom1=0
//					begin
//					if @unit = '0'	and @type='0'
//						update cms_rec set cms0 = rmrate*@amount*w_or_h,cmsunit=@unit,cmstype=@type,cmsdetail=@cmscode_detail where bdate = @bdate and agent=@accnt and cmscode=@cmscode and (charindex(type,@rmtype)>0 or rtrim(@rmtype) is null) and sta = 'I'  and rtrim(cmsdetail) is null and charindex(@weeknow,@week)>0 and charindex(substring(mode,1,1),@rmmode)>0
//					else if 	@unit = '0'	and @type='1'
//						update cms_rec set cms0 = @amount*w_or_h,cmsunit=@unit,cmstype=@type,cmsdetail=@cmscode_detail where bdate = @bdate and agent=@accnt and cmscode=@cmscode and (charindex(type,@rmtype)>0 or rtrim(@rmtype) is null) and sta = 'I'  and rtrim(cmsdetail) is null and charindex(@weeknow,@week)>0 and charindex(substring(mode,1,1),@rmmode)>0
//					else if 	@unit = '1'	and @type='0'
//						update cms_rec set cms0 = rmrate*@amount*w_or_h,cmsunit=@unit,cmstype=@type,cmsdetail=@cmscode_detail where bdate = @bdate and datediff(day,arr,bdate) = 0 and agent=@accnt and cmscode=@cmscode and (charindex(type,@rmtype)>0 or rtrim(@rmtype) is null) and sta = 'I' and rtrim(cmsdetail) is null and charindex(@weeknow,@week)>0 and charindex(substring(mode,1,1),@rmmode)>0
//					else if 	@unit = '1'	and @type='1'
//						update cms_rec set cms0 = @amount*w_or_h,cmsunit=@unit,cmstype=@type,cmsdetail=@cmscode_detail where bdate = @bdate and datediff(day,arr,bdate) = 0 and agent=@accnt and cmscode=@cmscode and (charindex(type,@rmtype)>0 or rtrim(@rmtype) is null) and sta = 'I' and rtrim(cmsdetail) is null and charindex(@weeknow,@week)>0 and charindex(substring(mode,1,1),@rmmode)>0
//					end
//				else
//					begin
//					if @upmode = 'M' and @rmtype_s = 'F'
//						begin
//						select @nights = sum(w_or_h) from cms_rec where agent = @accnt and cmscode=@cmscode and datepart(month,bdate) = datepart(month,@bdate) and datepart(year,bdate) = datepart(year,@bdate) and sta='I' and cmsunit<>'1'
//						if @nights <  @uproom1
//							begin
//							if @unit = '0'	and @type='0'
//								update cms_rec set cms0 = rmrate*@amount*w_or_h,cmsunit=@unit,cmstype=@type,cmsdetail=@cmscode_detail where bdate = @bdate and agent=@accnt and cmscode=@cmscode and (charindex(type,@rmtype)>0 or rtrim(@rmtype) is null) and sta = 'I'  and rtrim(cmsdetail) is null and charindex(@weeknow,@week)>0 and charindex(substring(mode,1,1),@rmmode)>0
//							else if 	@unit = '0'	and @type='1'
//								update cms_rec set cms0 = @amount*w_or_h,cmsunit=@unit,cmstype=@type,cmsdetail=@cmscode_detail where bdate = @bdate and agent=@accnt and cmscode=@cmscode and (charindex(type,@rmtype)>0 or rtrim(@rmtype) is null) and sta = 'I'  and rtrim(cmsdetail) is null and charindex(@weeknow,@week)>0 and charindex(substring(mode,1,1),@rmmode)>0
//							else if 	@unit = '1' and @type='0'
//								update cms_rec set cms0 = rmrate*@amount*w_or_h,cmsunit=@unit,cmstype=@type,cmsdetail=@cmscode_detail where bdate = @bdate and datediff(day,arr,bdate) = 0 and agent=@accnt and cmscode=@cmscode and (charindex(type,@rmtype)>0 or rtrim(@rmtype) is null) and sta = 'I' and rtrim(cmsdetail) is null and charindex(@weeknow,@week)>0 and charindex(substring(mode,1,1),@rmmode)>0
//							else if 	@unit = '1' and @type='1'
//								update cms_rec set cms0 = @amount*w_or_h,cmsunit=@unit,cmstype=@type,cmsdetail=@cmscode_detail where bdate = @bdate and datediff(day,arr,bdate) = 0 and agent=@accnt and cmscode=@cmscode and (charindex(type,@rmtype)>0 or rtrim(@rmtype) is null) and sta = 'I' and rtrim(cmsdetail) is null and charindex(@weeknow,@week)>0 and charindex(substring(mode,1,1),@rmmode)>0
//							end
//						else if @nights >=  @uproom1 and (@nights< @uproom2 or @uproom2 = 0)
//							select @upamount = @upamount1
//						else if @nights >=  @uproom2 and (@nights< @uproom3 or @uproom3 = 0)
//							select @upamount = @upamount2
//						else if @nights >=  @uproom3 and (@nights< @uproom4 or @uproom4 = 0)
//							select @upamount = @upamount3
//						else if @nights >=  @uproom4 and (@nights< @uproom5 or @uproom5 = 0)
//							select @upamount = @upamount4
//						else if @nights >=  @uproom5 and (@nights< @uproom6 or @uproom6 = 0)
//							select @upamount = @upamount5
//						else if @nights >=  @uproom6 and (@nights< @uproom7 or @uproom7 = 0)
//							select @upamount = @upamount6
//						else if @nights >=  @uproom7 
//							select @upamount = @upamount7
//						if @nights >=  @uproom1	
//							if @unit = '0'	and @type='0'
//								begin
//								update cms_rec set cms=cms0,changed = getdate() where agent=@accnt and cmscode=@cmscode and datepart(month,bdate) = datepart(month,@bdate) and datepart(year,bdate) = datepart(year,@bdate) and (charindex(type,@rmtype)>0 or rtrim(@rmtype) is null) and sta = 'I'  and charindex(@weeknow,@week)>0 and charindex(substring(mode,1,1),@rmmode)>0 and cms0<>rmrate*@upamount*w_or_h
//								update cms_rec set cms0 = rmrate*@upamount*w_or_h,cmsunit=@unit,cmstype=@type,cmsdetail=@cmscode_detail,changed = getdate(),back='F' where agent=@accnt and cmscode=@cmscode and datepart(month,bdate) = datepart(month,@bdate) and datepart(year,bdate) = datepart(year,@bdate) and (charindex(type,@rmtype)>0 or rtrim(@rmtype) is null) and sta = 'I'  and charindex(@weeknow,@week)>0 and charindex(substring(mode,1,1),@rmmode)>0 and cms0<>rmrate*@upamount*w_or_h
//								end
//							else if 	@unit = '0'	and @type='1'
//								begin
//								update cms_rec set cms=cms0,changed = getdate() where agent=@accnt and cmscode=@cmscode and datepart(month,bdate) = datepart(month,@bdate) and datepart(year,bdate) = datepart(year,@bdate) and (charindex(type,@rmtype)>0 or rtrim(@rmtype) is null) and sta = 'I'  and charindex(@weeknow,@week)>0 and charindex(substring(mode,1,1),@rmmode)>0 and cms0<>@upamount*w_or_h
//								update cms_rec set cms0 = @upamount*w_or_h,cmsunit=@unit,cmstype=@type,cmsdetail=@cmscode_detail,changed = getdate(),back='F' where agent=@accnt and cmscode=@cmscode and datepart(month,bdate) = datepart(month,@bdate) and datepart(year,bdate) = datepart(year,@bdate) and (charindex(type,@rmtype)>0 or rtrim(@rmtype) is null) and sta = 'I'  and charindex(@weeknow,@week)>0 and charindex(substring(mode,1,1),@rmmode)>0 and cms0<>@upamount*w_or_h
//								end
//
//						end			
//					end
//			fetch c_cmscode_link into @pri, @cmscode_detail
//			end
//		close c_cmscode_link
//	fetch c_cms_rec1 into @accnt, @cmscode
//	end
//close c_cms_rec1
//
//
//declare c_cms_rec2 cursor for select distinct source,cmscode from cms_rec where source<>''
//	and bdate = @bdate and sta = 'I' 
//open c_cms_rec2
//fetch c_cms_rec2 into @accnt, @cmscode
//while @@sqlstatus = 0
//	begin
//		select @upmode = upmode , @rmtype_s = rmtype_s from cmscode where code = @cmscode
//		open c_cmscode_link
//		fetch c_cmscode_link into @pri, @cmscode_detail
//		while @@sqlstatus = 0
//			begin
//				select @unit = unit,@type=type,@rmtype=rmtype,@amount=amount,@dayuse=dayuse,
//						@uproom1=uproom1,@upamount1=upamount1,@uproom2=uproom2,@upamount2=upamount2,
//						@uproom3=uproom3,@upamount3=upamount3,@uproom4=uproom4,@upamount4=upamount4,
//						@uproom5=uproom5,@upamount5=upamount5,@uproom6=uproom6,@upamount6=upamount6,
//						@uproom7=uproom7,@datecond = datecond 
//					from cms_defitem where no=@cmscode_detail
//--				insert into test values (@accnt, @cmscode,'1'+@cmscode_detail+'-'+@upmode+'-'+@rmtype_s,convert(char(10),@uproom1))
//				if rtrim(@datecond) is null
//					select @week = '1234567'
//				else
//					select @week = substring(@datecond,charindex('w:',lower(@datecond))+2,datalength(@datecond)-2)
//				select @weeknow = convert(char(1), datepart(weekday, @bdate)-1)
//				if @weeknow = '0'
//					select @weeknow = '7'
//				if @dayuse = 'T'
//					select @rmmode = 'JPBNbj'
//				else
//					select @rmmode = 'JjBb'
//						
//				if @uproom1=0
//					begin
//--						insert into test values (@accnt, @cmscode,'2'+@cmscode_detail+'-'+@upmode+'-'+@rmtype_s+'-'+@rmtype+'-'+@rmmode,rtrim(convert(char(10),@uproom1))+'-'+@unit+'-'+@type+'-'+convert(char(6),@amount))
//					if @unit = '0'	and @type='0'
//						update cms_rec set cms0 = rmrate*@amount*w_or_h,cmsunit=@unit,cmstype=@type,cmsdetail=@cmscode_detail where bdate = @bdate and source=@accnt and cmscode=@cmscode and (charindex(type,@rmtype)>0 or rtrim(@rmtype) is null) and sta = 'I'  and rtrim(cmsdetail) is null and charindex(@weeknow,@week)>0 and charindex(substring(mode,1,1),@rmmode)>0
//					else if 	@unit = '0'	and @type='1'
//						update cms_rec set cms0 = @amount*w_or_h,cmsunit=@unit,cmstype=@type,cmsdetail=@cmscode_detail where bdate = @bdate and source=@accnt and cmscode=@cmscode and (charindex(type,@rmtype)>0 or rtrim(@rmtype) is null) and sta = 'I'  and rtrim(cmsdetail) is null and charindex(@weeknow,@week)>0 and charindex(substring(mode,1,1),@rmmode)>0
//					else if 	@unit = '1'	and @type='0'
//						update cms_rec set cms0 = rmrate*@amount*w_or_h,cmsunit=@unit,cmstype=@type,cmsdetail=@cmscode_detail where bdate = @bdate and datediff(day,arr,bdate) = 0 and source=@accnt and cmscode=@cmscode and (charindex(type,@rmtype)>0 or rtrim(@rmtype) is null) and sta = 'I' and rtrim(cmsdetail) is null and charindex(@weeknow,@week)>0 and charindex(substring(mode,1,1),@rmmode)>0
//					else if 	@unit = '1'	and @type='1'
//						update cms_rec set cms0 = @amount*w_or_h,cmsunit=@unit,cmstype=@type,cmsdetail=@cmscode_detail where bdate = @bdate and datediff(day,arr,bdate) = 0 and source=@accnt and cmscode=@cmscode and (charindex(type,@rmtype)>0 or rtrim(@rmtype) is null) and sta = 'I' and rtrim(cmsdetail) is null and charindex(@weeknow,@week)>0 and charindex(substring(mode,1,1),@rmmode)>0
//					end
//				else
//					begin
//--						insert into test values (@accnt, @cmscode,'3'+@cmscode_detail+'-'+@upmode+'-'+@rmtype_s,'')
//					if @upmode = 'M' and @rmtype_s = 'F'
//						begin
//						select @nights = sum(w_or_h) from cms_rec where source = @accnt and cmscode=@cmscode and datepart(month,bdate) = datepart(month,@bdate) and datepart(year,bdate) = datepart(year,@bdate) and sta='I' and cmsunit<>'1'
//--						insert into test values (@accnt, @cmscode,'4'+@cmscode_detail+'-'+@weeknow+'-'+@week,convert(char(10),@nights)+'-'+convert(char(10),@uproom1))
//						if @nights <  @uproom1
//							begin
//							if @unit = '0'	and @type='0'
//								update cms_rec set cms0 = rmrate*@amount*w_or_h,cmsunit=@unit,cmstype=@type,cmsdetail=@cmscode_detail where bdate = @bdate and source=@accnt and cmscode=@cmscode and (charindex(type,@rmtype)>0 or rtrim(@rmtype) is null) and sta = 'I'  and rtrim(cmsdetail) is null and charindex(@weeknow,@week)>0 and charindex(substring(mode,1,1),@rmmode)>0
//							else if 	@unit = '0'	and @type='1'
//								update cms_rec set cms0 = @amount*w_or_h,cmsunit=@unit,cmstype=@type,cmsdetail=@cmscode_detail where bdate = @bdate and source=@accnt and cmscode=@cmscode and (charindex(type,@rmtype)>0 or rtrim(@rmtype) is null) and sta = 'I'  and rtrim(cmsdetail) is null and charindex(@weeknow,@week)>0 and charindex(substring(mode,1,1),@rmmode)>0
//							else if 	@unit = '1' and @type='0'
//								update cms_rec set cms0 = rmrate*@amount*w_or_h,cmsunit=@unit,cmstype=@type,cmsdetail=@cmscode_detail where bdate = @bdate and datediff(day,arr,bdate) = 0 and source=@accnt and cmscode=@cmscode and (charindex(type,@rmtype)>0 or rtrim(@rmtype) is null) and sta = 'I' and rtrim(cmsdetail) is null and charindex(@weeknow,@week)>0 and charindex(substring(mode,1,1),@rmmode)>0
//							else if 	@unit = '1' and @type='1'
//								update cms_rec set cms0 = @amount*w_or_h,cmsunit=@unit,cmstype=@type,cmsdetail=@cmscode_detail where bdate = @bdate and datediff(day,arr,bdate) = 0 and source=@accnt and cmscode=@cmscode and (charindex(type,@rmtype)>0 or rtrim(@rmtype) is null) and sta = 'I' and rtrim(cmsdetail) is null and charindex(@weeknow,@week)>0 and charindex(substring(mode,1,1),@rmmode)>0
//							end
//						else if @nights >=  @uproom1 and (@nights< @uproom2 or @uproom2 = 0)
//							select @upamount = @upamount1
//						else if @nights >=  @uproom2 and (@nights< @uproom3 or @uproom3 = 0)
//							select @upamount = @upamount2
//						else if @nights >=  @uproom3 and (@nights< @uproom4 or @uproom4 = 0)
//							select @upamount = @upamount3
//						else if @nights >=  @uproom4 and (@nights< @uproom5 or @uproom5 = 0)
//							select @upamount = @upamount4
//						else if @nights >=  @uproom5 and (@nights< @uproom6 or @uproom6 = 0)
//							select @upamount = @upamount5
//						else if @nights >=  @uproom6 and (@nights< @uproom7 or @uproom7 = 0)
//							select @upamount = @upamount6
//						else if @nights >=  @uproom7 
//							select @upamount = @upamount7
//
//						if @nights >=  @uproom1	
//							if @unit = '0'	and @type='0'
//								begin
//--								insert into test values (@accnt, @cmscode,'5'+@cmscode_detail+'-'+@upmode+'-'+@rmtype_s,convert(char(10),@nights)+'-'+convert(char(10),@upamount))
//								update cms_rec set cms=cms0,changed = getdate() where source=@accnt and cmscode=@cmscode and datepart(month,bdate) = datepart(month,@bdate) and datepart(year,bdate) = datepart(year,@bdate) and (charindex(type,@rmtype)>0 or rtrim(@rmtype) is null) and sta = 'I'  and charindex(@weeknow,@week)>0 and charindex(substring(mode,1,1),@rmmode)>0 and cms0<>rmrate*@upamount*w_or_h
//								update cms_rec set cms0 = rmrate*@upamount*w_or_h,cmsunit=@unit,cmstype=@type,cmsdetail=@cmscode_detail,changed = getdate(),back='F' where source=@accnt and cmscode=@cmscode and datepart(month,bdate) = datepart(month,@bdate) and datepart(year,bdate) = datepart(year,@bdate) and (charindex(type,@rmtype)>0 or rtrim(@rmtype) is null) and sta = 'I'  and charindex(@weeknow,@week)>0 and charindex(substring(mode,1,1),@rmmode)>0 and cms0<>rmrate*@upamount*w_or_h
//								end
//							else if 	@unit = '0'	and @type='1'
//								begin
//--								insert into test values (@accnt, @cmscode,'5'+@cmscode_detail+'-'+@upmode+'-'+@rmtype_s,convert(char(10),@nights)+'-'+convert(char(10),@upamount))
//								update cms_rec set cms=cms0,changed = getdate() where source=@accnt and cmscode=@cmscode and datepart(month,bdate) = datepart(month,@bdate) and datepart(year,bdate) = datepart(year,@bdate) and (charindex(type,@rmtype)>0 or rtrim(@rmtype) is null) and sta = 'I'  and charindex(@weeknow,@week)>0 and charindex(substring(mode,1,1),@rmmode)>0 and cms0<>@upamount*w_or_h
//								update cms_rec set cms0 = @upamount*w_or_h,cmsunit=@unit,cmstype=@type,cmsdetail=@cmscode_detail,changed = getdate(),back='F' where source=@accnt and cmscode=@cmscode and datepart(month,bdate) = datepart(month,@bdate) and datepart(year,bdate) = datepart(year,@bdate) and (charindex(type,@rmtype)>0 or rtrim(@rmtype) is null) and sta = 'I'  and charindex(@weeknow,@week)>0 and charindex(substring(mode,1,1),@rmmode)>0 and cms0<>@upamount*w_or_h
//								end
//						end			
//					end
//			fetch c_cmscode_link into @pri, @cmscode_detail
//			end
//		close c_cmscode_link
//	fetch c_cms_rec2 into @accnt, @cmscode
//	end
//close c_cms_rec2
//
//deallocate cursor c_cmscode_link
//deallocate cursor c_cms_rec
//deallocate cursor c_cms_rec1
//deallocate cursor c_cms_rec2
//
//select @ret
//return 0
//;
//