drop  proc p_cyj_pos_shift_tran;
create proc p_cyj_pos_shift_tran
	@empno			char(10),
	@bdate			datetime,
	@shift			char(1),
	@pccodes			char(255)
as
declare
	@sysdate			datetime


create table #menu
(
	menu			char(10),
	paycode		char(5),
	accnt			char(10),
	roomno		char(10),
	ref			char(40),
	amount		money
)

create table #bill
(
	paycode		char(5),
	descript		char(10),
	menu			char(10),
	accnt			char(10),
	roomno		char(10),
	name			char(40),
	amount		money
)


select @sysdate = bdate from sysdata
if @bdate = @sysdate
	begin
	insert into #menu select a.menu,c.deptno2,a.accnt,a.roomno,a.ref,a.amount from pos_pay a, pos_menu b, pccode c
		where a.menu = b.menu and (charindex(b.pccode, @pccodes)>0 or @pccodes = '') and a.bdate = @bdate and (a.empno  = @empno or @empno = '') and(a.shift = @shift or @shift = '') and a.crradjt <> 'C ' and a.crradjt <> 'CO'
		and a.paycode = c.pccode and c.deptno2 like 'TO%'
	end
else
	begin
	insert into #menu select a.menu,c.deptno2,a.accnt,a.roomno,a.ref,a.amount from pos_hpay a, pos_hmenu b, pccode c
		where a.menu = b.menu and (charindex(b.pccode, @pccodes)>0 or @pccodes = '') and a.bdate = @bdate and (a.empno  = @empno or @empno = '') and (a.shift = @shift or @shift = '') and a.crradjt <> 'C ' and a.crradjt <> 'CO'
		and a.paycode = c.pccode and c.deptno2 like 'TO%'
	end

insert into #bill select a.paycode, '转客房', a.menu, a.accnt, a.roomno, a.ref, a.amount from #menu a 
	where  a.paycode = 'TOA'
insert into #bill select a.paycode, '转AR', a.menu, a.accnt, a.roomno, a.ref, a.amount from #menu a
	where  a.paycode = 'TOR'



select paycode,descript,menu,accnt,roomno,name,amount from #bill order by paycode,menu
;