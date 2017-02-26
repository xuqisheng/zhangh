/* �˵���ˮ��¼�������ѯ�ã� */
if  exists(select * from sysobjects where name = "billno_temp" and type ="U")
	drop table billno_temp
;
create table billno_temp
(
	pc_id					char(4)			not null,
	mdi_id				integer			not null,
	billno				char(10)			not null,
	charge				money				default 0 not null,
	credit				money				default 0 not null,
	tor					money				default 0 not null,				/*����δ��*/
	accntof				char(10)			default '' not null,
	empno					char(10)			default '' not null,
	log_date				datetime			default getdate() not null,
	selected				integer			default '0' not null,
)
;
exec sp_primarykey billno_temp, pc_id, mdi_id, billno
create unique index index1 on billno_temp(pc_id, mdi_id, billno)
;

if exists(select * from sysobjects where name = "p_gl_accnt_haccount_list1")
	drop proc p_gl_accnt_haccount_list1;

create proc p_gl_accnt_haccount_list1
	@pc_id			char(4),						// IP��ַ
	@mdi_id			integer,						// Ψһ�����񴰿�ID
	@roomno			char(5),						// ����
	@accnt			char(10),					// �˺�
	@subaccnt		integer						// ���˺�(���@roomno = '99999', @subaccnt������ʱ�˼еı��)
as
declare
	@charge			money,
	@credit			money,
	@count			integer

create table #account
(
	accnt			char(10)		not null,							/*�ʺ�*/
	number		integer		not null,							/*�������к�,ÿ���ʺŷֱ��1��ʼ*/
	inumber		integer		not null,							/*�������к�(����,ת��ʱ����)*/
	log_date		datetime		default getdate() not null,	/*��������*/
	pccode		char(5)		not null,							/*Ӫҵ����*/
	charge		money			default 0 not null,				/*�跽��,��¼��������*/
	credit		money			default 0 not null,				/*������,��¼���˶��𼰽����*/
	tofrom		char(2)		default '' not null,				/*ת�ʷ���,"TO"��"FM"*/
	accntof		char(10)		default '' not null,				/*ת����Դ��Ŀ��*/
	billno		char(10)		default '' not null				/*���ʵ���*/
)
create table #billno
(
	billno		char(10)		not null,							/*���ʵ���*/
	accntof		char(10)		default '' not null,				/*ת���ʺ�*/
	charge		money			default 0 not null,				/*�跽��,��¼��������*/
	credit		money			default 0 not null,				/*������,��¼���˶��𼰽����*/
	tor			money			default 0 not null,				/*����δ��*/
	empno			char(10)		default '' not null,
	log_date		datetime		null									/*����*/
)
delete billno_temp where pc_id = @pc_id and mdi_id = @mdi_id
// ����
if @roomno = '' and @accnt = ''
	begin
	insert #account select b.accnt, b.number, b.inumber, b.log_date, b.pccode, b.charge, b.credit, b.tofrom, isnull(b.accntof, ''), b.billno from accnt_set a, account b
		where a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.subaccnt = 0 and a.accnt = b.accnt and b.billno <> ''
	union select b.accnt, b.number, b.inumber, b.log_date, b.pccode, b.charge, b.credit, b.tofrom, isnull(b.accntof, ''), b.billno from accnt_set a, haccount b
		where a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.subaccnt = 0 and a.accnt = b.accnt and b.billno <> ''
	end
// ָ������
else if @accnt = ''
	begin
	insert #account select b.accnt, b.number, b.inumber, b.log_date, b.pccode, b.charge, b.credit, b.tofrom, isnull(b.accntof, ''), b.billno from accnt_set a, account b
		where a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.roomno = @roomno and a.subaccnt = 0 and a.accnt = b.accnt and b.billno <> ''
	union select b.accnt, b.number, b.inumber, b.log_date, b.pccode, b.charge, b.credit, b.tofrom, isnull(b.accntof, ''), b.billno from accnt_set a, haccount b
		where a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.roomno = @roomno and a.subaccnt = 0 and a.accnt = b.accnt and b.billno <> ''
	end
// ָ��������˺�
else
	begin
	insert #account select b.accnt, b.number, b.inumber, b.log_date, b.pccode, b.charge, b.credit, b.tofrom, isnull(b.accntof, ''), b.billno from account b
		where b.accnt = @accnt and b.billno <> ''
	union select b.accnt, b.number, b.inumber, b.log_date, b.pccode, b.charge, b.credit, b.tofrom, isnull(b.accntof, ''), b.billno from haccount b
		where b.accnt = @accnt and b.billno <> ''
	end
//
insert #billno (billno, charge, credit, log_date) select a.billno, sum(a.charge), sum(a.credit), max(a.log_date)
	from #account a where not a.billno like 'T%' group by a.billno
insert #billno (billno, accntof, charge, credit, log_date)
	select billno, accntof, -1 * sum(charge), -1 * sum(credit), max(log_date)
	from #account where billno like 'T%' and tofrom = 'TO' group by billno, accntof
update #billno set tor = isnull((select sum(b.charge - b.credit - b.archarge + b.arcredit)
	from #account a, transfer_log b where a.billno = #billno.billno and a.tofrom = 'TO' and a.accnt = b.accnt and a.inumber = b.number), 0)
update #billno set empno = a.empno1, log_date = a.date1 from billno a where #billno.billno = a.billno
insert billno_temp select @pc_id, @mdi_id, billno, charge, credit, tor, accntof, empno, log_date, 0 from #billno
// 3.����'����δ����'��'����ѡ����'
select @charge = sum(a.charge), @credit = sum(a.credit), @count = count(1)
	from account a, account_temp b where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.accnt = a.accnt and b.number = a.number and a.billno = ''
if @count > 0
	insert billno_temp values (@pc_id, @mdi_id, '����δ����', @charge, @credit, 0, '', '', getdate(), 0)
select 0, ''
return
;
