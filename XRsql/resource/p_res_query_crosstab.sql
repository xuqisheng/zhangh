/*
	 用于查询资源的预定情况显示内容!,
*/

if exists (select 1 from sysobjects where name = 'p_res_query_crosstab'  and type = 'P')
	drop procedure p_res_query_crosstab;

create  procedure p_res_query_crosstab
   @code     char(10),
	@date     datetime,
	@mode		 char(3),
	@day_num	 char(2),	                  -----show day
	@langid	 int = 0  
as
	declare
		@resid	   char(10),
		@name       varchar(60),
		@name1      varchar(60),
		@descript   varchar(20),
		@title      varchar(15),
		@total   	integer,             -----总数量
		@use        integer,             -----使用数量
		@ooo        integer,             -----维修数量
		@begin      datetime,            -----显示开始时间
		@end        datetime,        		-----显示结束时间
		@dt_tmp     datetime,        		-----临时时间
		@diff_mi    integer,             -----显示间隔时间差
		@row        integer,             -----临时计算用行数
		@ls_type    char(10),         		-----临时参数
		@from 		char(10),
		@to			char(10),
		@des			char(10),
		@des1			char(10),
		@tmp			char(20),
		@day			integer ,
		@i				integer ,
		@row_id		integer

	create table #querytmp
	(
		pcid        char(4)      not null,  		----站点
		name        char(80)     not null,  		----名称
		total  integer      default 0 null, 	---总数
		descript    varchar(10)  not null,  		----显示内容
		title       char(30)     null,      		----标题
		folio       char(10)     null       		----单号
	)

	select @day = convert(integer,@day_num)			---为显示的天数
	select @i = 1
	select @row_id = 1
	
	declare c_mode cursor for
		select des,des1,from_,to_ from res_show_def where code = @mode order by code,seg
	
	declare	c_resid cursor for
		select resid,name,ename from res_plu where sortid = @code order by resid
	
while @i < = @day
begin
	open c_mode
	fetch c_mode into @des,@des1,@from,@to 
	while @@sqlstatus = 0
	begin
		select @begin = convert(datetime,convert(char(10),@date,111)+''+ @from),@end = convert(datetime,convert(char(10),@date,111)+''+ @to)
		open 	c_resid
		fetch c_resid into @resid,@name,@name1
		while @@sqlstatus = 0
			begin
	
			if @mode = 'A03'					--如果是按时段就显示一天！
				select @day = 1
	
			 select @total = qty from res_plu where resid =@resid
			if @mode = 'A01'
			begin
				select @use = sum(qty) from res_av where resid=@resid and charindex(sta,'RI')>0 and
					( datediff(dd,stime,@date) >= 0 and datediff(dd,@date,etime)>=0)
					-- ( datediff(dd,@date,stime) = 0 or datediff(dd,dateadd(dd,-1,@date),stime)=0)
				select @ooo  = sum(qty) from res_ooo where resid=@resid and sta <>'X' and
					( datediff(dd,stime,@date) >= 0 and datediff(dd,@date,etime)>=0)
					-- ( datediff(dd,@date,stime) = 0 or datediff(dd,dateadd(dd,-1,@date),stime)=0)
			end
			if @mode = 'A02'
			begin
			 select @use = sum(qty) from res_av where resid=@resid and charindex(sta,'RI')>0 and
					 stime < @begin and @begin <= etime
			 select @ooo  = sum(qty) from res_ooo where resid=@resid and sta <>'X'
					and stime < @begin and @begin <= etime
			end
			if @mode = 'A03'
			begin
			 select @use = sum(qty) from res_av where resid=@resid and charindex(sta,'RI')>0 and
					 stime < @begin and @begin <= etime
			 select @ooo  = sum(qty) from res_ooo where resid=@resid and sta <>'X'
					and stime < @begin and @begin <= etime
			end
	
			  if @use is null
				  select @use = 0
			  if @ooo is null
				  select @ooo = 0
			  if @total is null
				  select @total = 0
	
				if @ooo > 0
				  select @descript = ltrim(rtrim(convert(char(10),@use)))  + '/' +rtrim(convert(char(10),@total - @use - @ooo)) -- + '▲' + rtrim(convert(char(10),@ooo))
				else
				  select @descript = ltrim(rtrim(convert(char(10),@use)))+'/'+rtrim(ltrim(convert(char(10),@total - @use)))
			if @langid = 0 
			begin
				if @mode = 'A01' or @mode = 'A02'
				 select @title = substring(convert(char(10),@date,111),6,5) +'  '+ @des 
				if @mode = 'A03'
				 select @title = @des 
	
				 insert into #querytmp
						values(convert(char(2),@row_id), rtrim(@resid)+'-'+@name,@total,@descript, @title,'')
			end 
			else
			begin
				if @mode = 'A01' or @mode = 'A02'
				 select @title = substring(convert(char(10),@date,111),6,5) +'  '+ @des1
				if @mode = 'A03'
				 select @title = @des1
	
				 insert into #querytmp
						values(convert(char(2),@row_id), rtrim(@resid)+'-'+@name1,@total,@descript, @title,'')
			end 

	
			fetch c_resid into @resid,@name,@name1
		end
	
		close c_resid
		fetch c_mode into @des,@des1,@from,@to
		select @row_id = @row_id + 1
	end
	
	close c_mode
	select @date = dateadd(dd,1,@date)
	select @i = @i + 1
end
	
	
	deallocate cursor c_resid
	deallocate cursor c_mode

select pcid,name,descript,total,title from #querytmp order by name,pcid,title
return 0
;
