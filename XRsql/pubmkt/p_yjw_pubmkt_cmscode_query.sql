IF OBJECT_ID('p_yjw_pubmkt_cmscode_query') IS NOT NULL
    DROP PROCEDURE p_yjw_pubmkt_cmscode_query
;
create proc p_yjw_pubmkt_cmscode_query
	@begin	datetime,
	@end 		datetime,
	@no		char(7)
as 
--用来统计佣金在某一阶段内的汇总、返佣及剩余佣金的情况
declare
  @descript varchar(30),
  @cmsamtpaied money,
  @cmsamtleft  money,
  @cmsamt      money,
  @cusno       char(7),
  @agent       char(7),
  @source      char(7),
  @cus         char(7)

create table #woutput
(
	source		char(7)			default '',
	agent			char(7)			default '',
	cusno			char(7)			default '',
	descript		varchar(30)		default '',
	rmrate		money				default 0,
	cmsamt		money				default 0,
   w_or_h      money          default 0,
   cmsamtpaied money          default 0,
   cmsamtleft  money          default 0,
)

insert #woutput(source,agent,cusno,rmrate,cmsamt,w_or_h,cmsamtpaied,cmsamtleft)
	select source,agent,cusno,sum(rmrate),sum(cms0),sum(w_or_h),0,0
		from cms_rec
		where datediff(dd,bdate,@begin)<=0 and datediff(dd,bdate,@end)>=0
		and ( rtrim(source)+rtrim(agent)+rtrim(cusno) like @no +'%' or rtrim(@no) is null )
      and (rtrim(source)+rtrim(agent)+rtrim(cusno))<>''
      group by source,agent,cusno

update #woutput set descript = a.name from guest a where #woutput.agent = a.no
update #woutput set descript = a.name from guest a where #woutput.source = a.no
update #woutput set descript = a.name from guest a where #woutput.cusno = a.no

declare c_calculate cursor for select source,agent,cusno from #woutput
open c_calculate
fetch c_calculate into @source,@agent,@cusno
while @@sqlstatus=0
      begin
         select @cus=rtrim(@source)+rtrim(@agent)+rtrim(@cusno)
			select @cmsamtpaied =isnull(sum(cms0),0) from cms_rec where ( rtrim(source)+rtrim(agent)+rtrim(cusno))= @cus and ispaied is not null
			select @cmsamt=isnull(sum(cms0),0) from cms_rec where ( rtrim(source)+rtrim(agent)+rtrim(cusno)) = @cus
			select @cmsamtleft=isnull(@cmsamt - @cmsamtpaied,0)
			update #woutput set cmsamtpaied=@cmsamtpaied,cmsamtleft=@cmsamtleft where (rtrim(source)+rtrim(agent)+rtrim(cusno)) = @cus
         fetch c_calculate into @source,@agent,@cusno
      end
close c_calculate
deallocate cursor c_calculate
select descript,rmrate,w_or_h,cmsamt,cmsamtpaied,cmsamtleft from #woutput order by cmsamt desc,descript asc
return 0 ;

