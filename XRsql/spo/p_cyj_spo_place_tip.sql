/*-------------------------------------------------------------------*/
//	���ֳ���ռ��ͼ
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
select '��λ:  ' + isnull(unit, ''), 100 from sp_reserve where resno = @entry
insert into #show
select '��ϵ��:'+isnull(name, ''), 100 from sp_reserve where resno = @entry
insert into #show
select '�绰�� '+isnull(phone, ''), 100 from sp_reserve where resno = @entry
insert into #show
select '���ţ�  '+ isnull(menu,''),100 from sp_menu where menu = @entry
insert into #show
select '���ţ�  '+ isnull(menu,''),100 from sp_plaooo where menu = @entry
//insert into #show
//select '��ע�� '+isnull(remark, ''), 100 from pos_reserve where resno = @entry
//
select * from #show
;



