// -----------------------------------------------------------------------
// guest_search   档案 - 查找
// -----------------------------------------------------------------------
if exists(select * from sysobjects where type ="U" and name = "guest_search")
   drop table guest_search;
create table guest_search
(
	pc_id			char(4)							not null,
	no				char(7)			default ''	not null,	-- 档案号码
	flag			char(1)			default ''  not null,	-- 标记 1=删除档案 2=追加删除档案
	empno			char(10)							not null,
	log_date		datetime							not null
);
exec sp_primarykey guest_search, pc_id, no, flag
create unique index index1 on guest_search(pc_id, no, flag)
;

// ----------------------------------------------------------------------------------
//		检索可能需要删除的档案 
// ---------------------------------------------------------------------------------- 
if object_id('p_gds_guest_del_search') is not null
	drop proc p_gds_guest_del_search;
create proc p_gds_guest_del_search
	@pc_id		char(4),
	@mode			char1),		-- 0=覆盖 or 1=追加
	@no1			char(1),		-- 检索范围 begin
	@no2			char(1),		-- 检索范围 end 
	@...							-- 检索条件 
	@empno		char(10)
as
declare
	@accnt		char(10),

/* 检索的条件 
金陵符合条件的 60 天后自动删除  
vip
会员
name
fname
lname
birth
ident
street
sta=cancel, noshow = 14天 
keep
grade
latency
i_times
i_days
tl
lastvisit 
*/

// 用户确认信息 
select name,fname,lname,name2, sta, vip, ident, cardno, birth,tl,rm,fb,i_times,i_days,lv_date  from guest; 

return @ret
;
