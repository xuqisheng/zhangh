
/* -----------------------------------------------------------------------------------------------
	In waitlist window, we will show guest's info 
----------------------------------------------------------------------------------------------- */
if  exists(select * from sysobjects where name = "p_gds_master_info_for_waitlist")
	 drop proc p_gds_master_info_for_waitlist;
create proc p_gds_master_info_for_waitlist
   @accnt		char(10)			-- 肯定是宾客 class='F'
as
create table #goutput (
	accnt			char(10)			default ''	not null,
	haccnt		char(10)			default ''	not null,

	cusno			char(7)			default ''	not null,
	cusno_name	varchar(60)						null,
	agent			char(7)			default ''	not null,
	agent_name	varchar(60)						null,
	source		char(7)			default ''	not null,
	source_name	varchar(60)						null,

	vip			char(1)			default ''		not null,
	phone			varchar(20)		default ''		not null,		// 电话 -- 优先 master_hung
	fax			varchar(20)		default ''		not null,		// 传真 
	nation		varchar(40)		default ''		not null,	  	// 国籍 
	ref			varchar(100)	default ''		null,

   priority	char(1)		default ''			not null,	   -- 优先级
	reason	char(3)								null,
	remark	varchar(100) default ''			not null,
	crtby		char(10)		default ''			not null,      -- 创建
   crttime	datetime		default getdate() not null			-- 创建日期       
)


-- insert from master
insert #goutput (accnt,haccnt,cusno,agent,source,ref) 
	select accnt, haccnt, cusno, agent, source, ref from master where accnt=@accnt

-- update from guest
update #goutput set vip=a.vip, fax=a.fax, nation=a.nation from guest a where #goutput.haccnt=a.no
update #goutput set cusno_name=a.name from guest a where #goutput.cusno=a.no
update #goutput set agent_name=a.name from guest a where #goutput.agent=a.no
update #goutput set source_name=a.name from guest a where #goutput.source=a.no

-- update from master_hung
update #goutput set priority=a.priority, reason=a.reason, remark=a.remark,crtby=a.crtby, crttime=a.crttime 
	from master_hung a where a.status='I' and #goutput.accnt=a.accnt

-- phone 
declare	@phone		varchar(20)
select @phone = rtrim(phone) from master_hung where status='I' and accnt=@accnt 
if @phone is not null
	update #goutput set phone = @phone

-- output
select cusno_name,agent_name,source_name,vip,phone,fax,nation,ref,
	   priority,reason,remark,crtby, crttime
	from #goutput

return 0
;
