IF OBJECT_ID('p_pos_tou_mstlist') IS NOT NULL
    DROP PROCEDURE p_pos_tou_mstlist
;
create proc p_pos_tou_mstlist
	@class		varchar(10),
	@sta			varchar(10),
	@parm			varchar(30)
as
------------------------------------------------------------------------
--
--		触摸屏查询前台帐号显示, 从master,ar_master,vipcard 取数
--
------------------------------------------------------------------------

-- master.sta
select @sta = 'I'

--
create table #class(
	tag 		char(10),
	des 		char(5)
)
insert into #class select '5','A卡'
insert into #class select '6','C卡'
insert into #class select 'CD','信用'
insert into #class select '123789AZ','普通'

-- Output table
create table #mstlist(
	accnt 		char(10),
	roomno 		char(5),
	name 			char(50),
	name2 		char(50),
	sta 			char(1),
	haccnt 		char(7),
	class 		char(1),
	tag 			char(1)
)

-- Parms
select @parm = rtrim(@parm)
if @parm is not null
begin
	if exists(select 1 from rmsta where roomno like @parm+'%')  and datalength(@parm)<=5
	begin
		insert into #mstlist
			SELECT a.accnt, a.roomno, b.name, b.name2, a.sta, a.haccnt, a.class, a.artag1
				FROM master a, guest b where a.haccnt = b.no
					and charindex(a.sta, @sta)>0 and charindex(a.class,@class)>0
					and ( a.roomno like '%'+rtrim(@parm)+'%' )
	end
	else
	begin
		insert into #mstlist
			SELECT a.accnt, a.roomno, b.name, b.name2, a.sta, a.haccnt, a.class, a.artag1
				FROM master a, guest b where a.haccnt = b.no
					and charindex(a.sta, @sta)>0 and charindex(a.class,@class)>0
					and ( a.roomno like '%'+rtrim(@parm)+'%'
							or a.accnt like '%'+rtrim(@parm)+'%'
							or b.name like '%'+rtrim(@parm)+'%'
							or b.name2 like '%'+rtrim(@parm)+'%')
			union
			SELECT a.accnt, '', b.name, b.name2, a.sta, a.haccnt, 'A', a.artag1
				FROM ar_master a, guest b where a.haccnt = b.no
					and charindex(a.sta, @sta)>0 and charindex('A',@class)>0
					and ( b.name like '%'+rtrim(@parm)+'%'
							or a.accnt like '%'+rtrim(@parm)+'%'
							or b.name2 like '%'+rtrim(@parm)+'%'
							or (rtrim(@parm) like '%'+rtrim(ltrim(b.sno)) +'%' and b.sno >''))
			union
			SELECT a.accnt, '', b.name, b.name2, c.sta, c.sno, 'A', a.artag1
				FROM ar_master a, guest b, vipcard c where a.haccnt = b.no
					and charindex(a.sta, @sta)>0 and charindex('A',@class)>0 and a.accnt = c.araccnt1
					and (c.no like '%'+rtrim(@parm)+'%'
							or c.sno like '%'+rtrim(@parm)+'%')
			union
			SELECT a.accnt, '', b.name, b.name2, c.sta, c.sno, 'A', a.artag1
				FROM master a, guest b, vipcard c where a.haccnt = b.no
					and charindex(a.sta, @sta)>0 and charindex('A',@class)>0 and a.accnt = c.araccnt1
					and (c.no like '%'+rtrim(@parm)+'%'
							or c.sno like '%'+rtrim(@parm)+'%')
	end
end

update #mstlist set roomno = b.des from #mstlist a, #class b where charindex(a.tag, b.tag) >0

select a.accnt, a.roomno, a.name, a.name2, a.sta, a.haccnt, a.class from #mstlist a
;
