// -----------------------------------------------------------------------
// guest_search   ���� - ����
// -----------------------------------------------------------------------
if exists(select * from sysobjects where type ="U" and name = "guest_search")
   drop table guest_search;
create table guest_search
(
	pc_id			char(4)							not null,
	no				char(7)			default ''	not null,	-- ��������
	flag			char(1)			default ''  not null,	-- ��� 1=ɾ������ 2=׷��ɾ������
	empno			char(10)							not null,
	log_date		datetime							not null
);
exec sp_primarykey guest_search, pc_id, no, flag
create unique index index1 on guest_search(pc_id, no, flag)
;

// ----------------------------------------------------------------------------------
//		����������Ҫɾ���ĵ��� 
// ---------------------------------------------------------------------------------- 
if object_id('p_gds_guest_del_search') is not null
	drop proc p_gds_guest_del_search;
create proc p_gds_guest_del_search
	@pc_id		char(4),
	@mode			char1),		-- 0=���� or 1=׷��
	@no1			char(1),		-- ������Χ begin
	@no2			char(1),		-- ������Χ end 
	@...							-- �������� 
	@empno		char(10)
as
declare
	@accnt		char(10),

/* ���������� 
������������� 60 ����Զ�ɾ��  
vip
��Ա
name
fname
lname
birth
ident
street
sta=cancel, noshow = 14�� 
keep
grade
latency
i_times
i_days
tl
lastvisit 
*/

// �û�ȷ����Ϣ 
select name,fname,lname,name2, sta, vip, ident, cardno, birth,tl,rm,fb,i_times,i_days,lv_date  from guest; 

return @ret
;
