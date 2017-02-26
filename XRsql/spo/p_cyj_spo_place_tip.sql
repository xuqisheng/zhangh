/*-------------------------------------------------------------------*/
//	康乐场地占用图
/*-------------------------------------------------------------------*/
if exists(select 1 from sysobjects where name = 'p_cyj_spo_place_tip')
	drop proc p_cyj_spo_place_tip;
create procedure p_cyj_spo_place_tip
	@entry			char(10)
as

create table #show
(
	show		varchar(100)	,
	len		int
)
insert into #show
select '单位:  ' + isnull(unit, ''), 100 from sp_reserve where resno = @entry
insert into #show
select '联系人:'+isnull(name, ''), 100 from sp_reserve where resno = @entry
insert into #show
select '电话： '+isnull(phone, ''), 100 from sp_reserve where resno = @entry
insert into #show
select '单号：  '+ isnull(menu,''),100 from sp_menu where menu = @entry
insert into #show
select '单号：  '+ isnull(menu,''),100 from sp_plaooo where menu = @entry
//insert into #show
//select '备注： '+isnull(remark, ''), 100 from pos_reserve where resno = @entry
//
select * from #show
;



