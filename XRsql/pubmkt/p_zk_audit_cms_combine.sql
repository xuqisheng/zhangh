
if  exists(select * from sysobjects where name = "p_zk_audit_cms_combine")
	drop  proc p_zk_audit_cms_combine;
create proc p_zk_audit_cms_combine

	@pc_id			char(4)
as
---------------------------------------------------------
-- 佣金计算 = 更新 cms_rec
--
-- 处理时机：夜审过程中，如果需要马上扣减房费，需要放在夜审前
--
---------------------------------------------------------
declare
	@bdate			datetime,
	@bfdate			datetime,
	@duringaudit	char(1),
	@accnt			char(10),
	@cmscode			char(10),
	@cms_code		char(10),
	@upmode			char(1),
	@rmtype_s		char(1),
	@pri				integer,
	@cmscode_detail char(10),
	@unit				 char(1),
	@type				 char(1),
	@rm_type			 char(5),
	@rmtype			 varchar(255),   --  varchar(30)  xia 
	@amount			 money,
	@dayuse			 char(2),
	@uproom1			 money, 		@upamount1      money,
	@uproom2			 money, 		@upamount2      money,
	@uproom3			 money, 		@upamount3      money,
	@uproom4			 money, 		@upamount4     money,
	@uproom5			 money, 		@upamount5      money,
	@uproom6			 money, 		@upamount6      money,
	@uproom7			 money, 		@upamount7      money,
	@upamount       money,
	@week           varchar(30),
	@weeknow    	 char(1),
	@rmmode         char(8),
	@nights		    integer,
	@datecond		 varchar(80),
	@ret        	 integer,
	@id				 int,
	@id2				 int,
	@roomno			 char(5),
	@belong			 char(10),
	@tm_accnt		 char(10),
	@rmrate			 money,
	@mode				 char(10)



select @ret = 0
select @duringaudit = audit from gate
if exists(select 1 from gate where audit = 'T')
	select @bdate = bdate from sysdata
else
	select @bdate = bdate from accthead
 
create table #roomno (id		integer	 not null,
							 roomno  char(5)   not null,
							 accnt   char(10)  not null,
							 belong	char(10)	 not null,
							 cmscode		char(10)		 not null,
							 mode    char(10)		not null)



-- 开始计算 cmsdetail='' 表示还没有开始计算.  这里特别去掉 bdate 的限制条件
declare c_cms_rec cursor for select id,belong,cmscode,type,accnt,roomno,rmrate,mode
	from cms_rec where sta = 'I' and (cmsdetail='' or cmsdetail is null)	and isaudit='F' and bdate = @bdate and rmrate <> 0 order by mode,id
open c_cms_rec
fetch c_cms_rec into @id,@belong,@cmscode,@rm_type,@accnt,@roomno,@rmrate,@mode
while @@sqlstatus = 0
begin
	if not exists(select 1 from #roomno where roomno = @roomno and belong = @belong and cmscode = @cmscode)
		insert #roomno select @id,@roomno,@accnt,@belong,@cmscode,@mode
	else
		begin
		select @tm_accnt  = accnt from #roomno where roomno = @roomno and belong = @belong and cmscode = @cmscode
		select @id2 = id from #roomno where roomno = @roomno and belong = @belong and cmscode = @cmscode

		select @upmode = upmode , @rmtype_s = rmtype_s from cmscode where code = @cmscode
		select @weeknow = convert(char(1), datepart(weekday, @bdate)-1)
		if @weeknow = '0'
			select @weeknow = '7'
		exec p_cq_cmscode_judge	@rm_type,@cmscode,@weeknow,@bdate,@cms_code out
		select @dayuse = dayuse from cms_defitem where no = @cms_code
		if @cms_code <> '' and ((@mode like 'N%' and substring(@dayuse,1,1) = 'T') or (@mode like 'P%' and substring(@dayuse,2,1) = 'T') or charindex(substring(@mode,1,1),'JjBb') > 0)
			begin
			update cms_rec set rmrate = rmrate + @rmrate,ref = ref + '合并自账号:'+@accnt + '营业日期:' + convert(char(10),@bdate,111) where id = @id2
				and ((mode like 'N%' and substring(@dayuse,1,1) = 'T') or (mode like 'P%' and substring(@dayuse,2,1) = 'T') or charindex(substring(mode,1,1),'JjBb') > 0)
			update cms_rec set rmrate = rmrate - @rmrate,ref = ref + '合并到账号:'+@tm_accnt + '营业日期:' + convert(char(10),@bdate,111) where id = @id
				and ((mode like 'N%' and substring(@dayuse,1,1) = 'T') or (mode like 'P%' and substring(@dayuse,2,1) = 'T') or charindex(substring(mode,1,1),'JjBb') > 0)
			end
		end
	select @id = 0,@accnt = '',@cmscode = '',@rm_type = '',@accnt = '',@roomno = '',@rmrate = 0
	fetch c_cms_rec into @id,@accnt,@cmscode,@rm_type,@accnt,@roomno,@rmrate,@mode
end
close c_cms_rec
deallocate cursor c_cms_rec
drop table #roomno

return 0;
