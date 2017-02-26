if exists(select * from sysobjects where name = "p_gds_reserve_envelop")
   drop proc p_gds_reserve_envelop
;
create proc p_gds_reserve_envelop
	@accnt			char(10)
as

------------------------------------------------------------
--		打印客人预订信息的信封
------------------------------------------------------------

create table #gout (
	name				varchar(60)			null,
	roomnos			varchar(255)		null
)

/*

string 	ls_nat,ls_guestid,ls_rn, ls_resno, ls_name
int 		li_cnt

ls_guestid=message.stringparm
ls_nat = mid(ls_guestid,2,3)
ls_rn = ''

if integer(ls_nat) < 400 then
	select rtrim(name) into :ls_name from guest where guestid = :ls_guestid;	
	select rtrim(resno) into :ls_resno from master a, guest b where a.accnt=b.accnt and b.guestid=:ls_guestid;
	if ls_resno='' or isnull(ls_resno)  then
		select roomno into :ls_rn from guest where guestid = :ls_guestid;
	else
		declare c_rooms cursor for select distinct roomno from master where charindex(sta,'RICG')>0 and resno=:ls_resno order by roomno;
		open c_rooms;
		fetch c_rooms into :ls_nat;
		do while sqlca.sqlcode=0
			ls_rn = ls_rn + ls_nat + ' '
			fetch c_rooms into :ls_nat;
		loop
		close c_rooms;
	end if
	
else
	select rtrim(name) into :ls_name from grpmst where accnt = :ls_guestid;	
	declare c1 cursor for select distinct roomno from guest where groupno=:ls_guestid;
	open c1;
	fetch c1 into :ls_nat;
	do while sqlca.sqlcode=0
		ls_rn +=ls_nat
		ls_rn +=' '
		fetch c1 into :ls_nat;		
	loop
	close c1;
end if

dw_1.settransobject(sqlca)
dw_1.insertrow(0)

dw_1.object.name[1] = ls_name
dw_1.object.rooms[1] = ls_rn

cb_print.setfocus()
cb_print.triggerevent(clicked!)
close(this)
return

*/

-- 模拟数据
if not exists(select 1 from #gout)
begin
	insert #gout select '杭州西软科技 WestSoft', '1001 1002 1003 1004 1005 1006 '
	insert #gout select '', '2001 2002 2003 2004 2005 2006 '
	insert #gout select '', '3001 3002 3003 3004 3005 3006 '
	insert #gout select '', ''
	insert #gout select '   --- 注意', '此处数据均为模拟数据!'
end

-- output
select * from #gout
return 0
;