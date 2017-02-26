/* ����ʺŵ��ʵ�����Ҫ�� */

if exists(select * from sysobjects where name = "p_gl_accnt_list_ar1" and type = "P")
	drop proc p_gl_accnt_list_ar1;

create proc p_gl_accnt_list_ar1
	@pc_id			char(4),
	@mdi_id			integer
as

// �����
create table #listar
(
	accnt			char(10)		null,									/*�ʺ�*/
	number		integer		default 0 not null,				/*�ʴ�*/
	roomno		char(5)		null,									/*����*/
	name			char(50)		null,									/*����*/
	groupno		char(10)		null,									/*�����*/
	grpname		char(50)		null,									/*������*/
	charge		money			default 0 not null,				/*�跽��,��¼��������*/
	credit		money			default 0 not null,				/*������,��¼���˶��𼰽����*/
	log_date		datetime		not null,							/*Ӫҵ����*/
	arr			datetime		null,									/*�뿪*/
	dep			datetime		null,									/*����*/
)
// ��ʱ��
create table #listar1
(
	accnt			char(10)		null,									/*�ʺ�*/
	number		integer		default 0 not null,				/*�ʴ�*/
	grpname		char(50)		null,									/*������*/
	charge		money			default 0 not null,				/*�跽��,��¼��������*/
	credit		money			default 0 not null,				/*������,��¼���˶��𼰽����*/
	log_date		datetime		not null,							/*Ӫҵ����*/
	tofrom		char(2)		null									/*ת�˱�־*/
)

// gds
select a.* into #account from account a, account_temp b where a.accnt = b.accnt and a.number = b.number
	and b.pc_id = @pc_id and b.mdi_id = @mdi_id
// ת����
insert #listar (accnt, groupno, roomno, charge, credit, log_date)
	select a.accntof, a.groupno, a.roomno, sum(a.charge), sum(a.credit), a.log_date
	from #account a group by a.accntof, a.groupno, a.roomno, a.log_date

delete #listar where rtrim(accnt) is null and rtrim(groupno) is null
update #listar set groupno = accnt, accnt = '' 
	where accnt like '[G,M]%'
// ������
insert #listar1 (accnt, number, grpname, charge, credit, log_date, tofrom)
	select accnt, number, ref + ref1 + ref2, charge, credit, log_date, tofrom 
	from #account
//		from #account where accnt = @accnt and billno = ''
insert #listar (accnt, number, grpname, charge, credit, log_date)
	select accnt, number, grpname, charge, credit, log_date from #listar1 
		where tofrom <> 'FM'
// ���ˡ���������
//update #listar set groupno = isnull(rtrim(#listar.groupno), a.groupno), name = b.name, arr = a.arr, dep = a.dep
//	from master a, guest b where a.accnt = #listar.accnt and a.haccnt = b.no
//update #listar set groupno = isnull(rtrim(#listar.groupno), a.groupno), name = b.name, arr = a.arr, dep = a.dep
//	from hmaster a, guest b where a.accnt = #listar.accnt and a.haccnt = b.no
update #listar set groupno = isnull(rtrim(a.groupno), #listar.groupno), name = b.name, arr = a.arr, dep = a.dep
	from master a, guest b where a.accnt = #listar.accnt and a.haccnt = b.no
update #listar set groupno = isnull(rtrim(a.groupno), #listar.groupno), name = b.name, arr = a.arr, dep = a.dep
	from hmaster a, guest b where a.accnt = #listar.accnt and a.haccnt = b.no
update #listar set grpname = b.name, arr = a.arr, dep = a.dep
	from master a, guest b where a.accnt = #listar.groupno and a.haccnt = b.no
update #listar set grpname = b.name, arr = a.arr, dep = a.dep
	from hmaster a, guest b where a.accnt = #listar.groupno and a.haccnt = b.no
//
select * from #listar where charge<>0 order by log_date, groupno, accnt
;



//if exists(select * from sysobjects where name = "p_gl_accnt_list_ar0" and type = "P")
//	drop proc p_gl_accnt_list_ar0;
//create proc p_gl_accnt_list_ar0
//	@accnt			char(10)
//as
//declare @pc_id			char(4)
//select @pc_id = '####'
//
//// �����
//create table #listar
//(
//	accnt			char(10)		null,									/*�ʺ�*/
//	number		integer		default 0 not null,				/*�ʴ�*/
//	roomno		char(4)		null,									/*����*/
//	name			char(50)		null,									/*����*/
//	groupno		char(10)		null,									/*�����*/
//	grpname		char(50)		null,									/*������*/
//	charge		money			default 0 not null,				/*�跽��,��¼��������*/
//	credit		money			default 0 not null,				/*������,��¼���˶��𼰽����*/
//	log_date			datetime		not null,							/*Ӫҵ����*/
//	arr			datetime		null,									/*�뿪*/
//	dep			datetime		null,									/*����*/
//)
//// ��ʱ��
//create table #listar1
//(
//	accnt			char(10)		null,									/*�ʺ�*/
//	number		integer		default 0 not null,				/*�ʴ�*/
//	grpname		char(50)		null,									/*������*/
//	charge		money			default 0 not null,				/*�跽��,��¼��������*/
//	credit		money			default 0 not null,				/*������,��¼���˶��𼰽����*/
//	log_date			datetime		not null,							/*Ӫҵ����*/
//	tofrom		char(2)		null									/*ת�˱�־*/
//)
//
//// gds
//select * into #account from account 
//	where accnt=@accnt and (@pc_id='####' or number not in (select d.number from selected_account d where d.type='g' and d.accnt=@accnt and d.pc_id=@pc_id))
//
//// ת����
//insert #listar (accnt, groupno, roomno, charge, credit, log_date)
//	select a.accntof, a.groupno, a.roomno, sum(a.charge), sum(a.credit), b.log_date
//	from #account a, #account b
//	where a.accnt = @accnt and a.billno = '' and b.accnt = @accnt and a.pnumber *= b.number
//	group by a.groupno, a.accntof, a.roomno, b.log_date
//
//delete #listar where rtrim(accnt) is null and rtrim(groupno) is null
//update #listar set groupno = accnt, accnt = '' 
//	where substring(accnt, 2, 2) >= '80' and substring(accnt, 2, 2) < '95'
//
//// ������
//insert #listar1 (accnt, number, grpname, charge, credit, log_date, tofrom)
//	select accnt, number, ref + ref1 + ref2, charge, credit, log_date, tofrom 
//		from #account where accnt = @accnt and billno = ''
//insert #listar (accnt, number, grpname, charge, credit, log_date)
//	select accnt, number, grpname, charge, credit, log_date from #listar1 
//		where tofrom <> 'FM'
//
//// ������
////update #listar set name = b.name, arr = a.arr, dep = a.dep
////	from guest b where b.accnt = #listar.accnt
////	and b.guestid = (select min(guestid) from guest c where c.accnt = #listar.accnt)
////update #listar set name = b.name, arr = a.arr, dep = a.dep
////	from hguest b where b.accnt = #listar.accnt
////	and b.guestid = (select min(guestid) from hguest c where c.accnt = #listar.accnt)
//update #listar set name = b.ref, arr = a.arr, dep = a.dep
//	from master b where b.accnt = #listar.accnt
//update #listar set name = b.ref, arr = a.arr, dep = a.dep
//	from hmaster b where b.accnt = #listar.accnt
//
//update #listar set grpname = a.name, arr = a.arr, dep = a.dep
//	from grpmst a where a.accnt = #listar.groupno
//update #listar set grpname = a.name, arr = a.arr, dep = a.dep
//	from hgrpmst a where a.accnt = #listar.groupno
//
//select * from #listar where charge<>0 order by log_date, groupno, accnt
//;
//