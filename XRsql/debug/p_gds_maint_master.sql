// ------------------------------------------------------------------------
// ϵͳά������֮��: 	ά�� master, grprate
//
//				���� rmsta, etc...
// ------------------------------------------------------------------------
if exists(select * from sysobjects where name='p_gds_maint_master' and type ='P')
   drop proc p_gds_maint_master;
create proc p_gds_maint_master
as
create table #goutput (msg			varchar(100)		null)

---------------------------------------
--	��������
---------------------------------------
-- �˺�=Null
if exists(select 1 from master where rtrim(accnt) is null)
begin
	select * from master where rtrim(accnt) is null
	select 'ά�������ִ�����ֹ - �˺�=Null'
	return
end
-- ���Ų�����
if exists(select 1 from master where class='F' and roomno<>'' and roomno not in (select roomno from rmsta))
begin
	select 'master accnt'=accnt, sta, '���Ų�����'=roomno from master where class='F' and roomno<>'' and roomno not in (select roomno from rmsta)
	select 'ά�������ִ�����ֹ - ���Ų�����'
	return
end
//-- ���಻����
//if exists(select 1 from master where type<>'' and type not in (select type from typim) and sta in ('R', 'I'))
//begin
//	select 'ά�������ִ�����ֹ - ���಻����'
//	return
//end

//-- �����˺Ų�����
//if exists(select 1 from master where class='F' and groupno<>'' and groupno not in (select accnt from master where class in ('G', 'M')))
//begin
//	select 'master accnt'=accnt, '�����˺Ų�����'=groupno from master where class='F' and groupno<>'' and groupno not in (select accnt from master where class in ('G', 'M'))
//	select 'ά�������ִ�����ֹ - �����˺Ų�����'
//	return
//end
	
---------------------------------------
-- ���� rmsta ά�� master �ͷ���Ϣ
---------------------------------------
update master set type=a.type, otype=a.type, qtrate=a.rate from rmsta a where master.roomno=a.roomno
update master_till set type=a.type, otype=a.type, qtrate=a.rate from rmsta a where master_till.roomno=a.roomno
update master_last set type=a.type, otype=a.type, qtrate=a.rate from rmsta a where master_last.roomno=a.roomno

---------------------------------------
-- grprate
---------------------------------------
declare @grpaccnt char(10), @type char(5), @rate money
truncate table grprate
declare	c_grprate cursor for select distinct groupno, type from master 
	where sta in ('R', 'I') and class='F' and groupno<>''
open c_grprate 
fetch c_grprate into @grpaccnt, @type
while @@sqlstatus = 0
begin
	select @rate = max(setrate) from master where groupno=@grpaccnt and type=@type and class='F'
	insert grprate(accnt,type,rate,oldrate,cby,changed)
		values(@grpaccnt,@type,@rate,@rate,'FOX',getdate())

	fetch c_grprate into @grpaccnt, @type
end
close c_grprate
deallocate cursor c_grprate

---------------------------------------
-- �ؽ�Ԥ������Ϣ
---------------------------------------
exec p_gds_reserve_rsvsrc_reb

-- Output
if exists(select 1 from #goutput)
	select * from #goutput
return 0
;


// exec p_gds_maint_master;



