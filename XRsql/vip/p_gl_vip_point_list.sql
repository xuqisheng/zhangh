-- ---------------------------------------------------------
--		p_gl_vip_point_list
-- ---------------------------------------------------------
IF OBJECT_ID('p_gl_vip_point_list') IS NOT NULL
    DROP PROCEDURE p_gl_vip_point_list
;
create proc p_gl_vip_point_list
	@haccnt				char(7),
	@no					char(20)
as
-- ---------------------------------------------------------
--  ����������ϸ����ʱ���ɼ�¼���ƺ�Ӱ���ٶȣ���
--		��������1���ٶ� 2������ʱ���ͳ��
-- ---------------------------------------------------------
declare
	@rm_pccodes_nt	char(255)

create table #no
(
	no				char(20)						not null
)
create table #goutput
(
	number			integer						not null,
	accnt				char(10)						not null,
	resno				char(10)						null,
	sta				char(1)						null,
	arr				datetime						null,
	dep				datetime						null,
	type				char(3)						null,
	roomno			char(5)						null,
	setrate			money			default 0	null,
	haccnt			char(7)						null,
	name			   varchar(50)	default ''	null,	 	-- ����1
	name2				varchar(50)	default ''	null,	 	-- ����2
	gstno				integer		default 0	not null,
	rmnum				integer		default 0	not null,
	packages			varchar(50)	default ''	not null,	-- ����
	charge			money			default 0	null,
	ref				varchar(100)				null,
   point_charge	money			default 0	not null,   -- ��������
   point_credit	money			default 0	not null,   -- ʹ�û���
   i_days			integer		default 0	not null,   -- ס������ 
   rm					money			default 0	not null, 	-- ��������
   fb					money			default 0	not null, 	-- ��������
   en					money			default 0	not null, 	-- ��������
   mt					money			default 0	not null, 	-- ��������
   ot					money			default 0	not null, 	-- ��������
   tl					money			default 0	not null		-- ������  
)
if rtrim(@no) is null
	insert #no select no from vipcard where cno = @haccnt or hno = @haccnt
else
	insert #no select @no
-- Get Records
insert #goutput (number, accnt, point_charge, point_credit)
	select min(number), a.fo_accnt, sum(a.charge), sum(a.credit)
	from vippoint a, #no b where a.no = b.no group by a.fo_accnt
update #goutput set sta = a.sta, resno = a.resno, arr = a.arr, dep = a.dep, type = a.type, roomno = a.roomno, 
	setrate = a.setrate, haccnt = a.haccnt, gstno = a.gstno, rmnum = a.rmnum, packages = a.packages, ref =a.ref
	from master a where #goutput.accnt = a.accnt
update #goutput set sta = a.sta, resno = a.resno, arr = a.arr, dep = a.dep, type = a.type, roomno = a.roomno, 
	setrate = a.setrate, haccnt = a.haccnt, gstno = a.gstno, rmnum = a.rmnum, packages = a.packages, ref =a.ref
	from hmaster a where #goutput.accnt = a.accnt
update #goutput set name = a.name, name2 = a.name2 from guest a where #goutput.haccnt = a.no

-- Sum 
update #goutput set rm = isnull((select sum(a.amount1) from master_income a, pccode b where a.accnt = #goutput.accnt and a.pccode = b.pccode and b.deptno7 = 'rm'),0)
update #goutput set fb = isnull((select sum(a.amount1) from master_income a, pccode b where a.accnt = #goutput.accnt and a.pccode = b.pccode and b.deptno7 = 'fb'),0)
update #goutput set en = isnull((select sum(a.amount1) from master_income a, pccode b where a.accnt = #goutput.accnt and a.pccode = b.pccode and b.deptno7 = 'en'),0)
update #goutput set mt = isnull((select sum(a.amount1) from master_income a, pccode b where a.accnt = #goutput.accnt and a.pccode = b.pccode and b.deptno7 = 'mt'),0)
update #goutput set ot = isnull((select sum(a.amount1) from master_income a, pccode b where a.accnt = #goutput.accnt and a.pccode = b.pccode and b.deptno7 = 'ot'),0)
update #goutput set tl = rm + fb + en + mt + ot

-- ���㷿��ķ�����
select @rm_pccodes_nt = isnull((select value from sysoption where catalog = 'audit' and item = 'room_charge_pccodes_nt'), '')
update #goutput set i_days = isnull((select sum(a.amount2) from master_income a where a.accnt=#goutput.accnt and a.pccode <> '' and charindex(a.pccode, @rm_pccodes_nt)>0 ), 0)

-- output
select accnt, sta, resno, arr, dep, type, roomno, setrate, name, name2, gstno, rmnum, packages, charge, ref,
	point_charge, point_credit, i_days, rm, fb, en, mt, ot, tl from #goutput order by number

return 0
;
