
if exists(select * from sysobjects where name = "p_gl_reserve_registration")
	drop proc p_gl_reserve_registration;

create proc p_gl_reserve_registration
	@accnt				char(10)
as
-- 帐务客人主单(同行客人) 

declare
	@sex					char(10), 
	@idcls				char(40), 
	@idend				datetime, 
	@visaid				char(40), 
	@stay					datetime, 
	@wherefrom			char(40),
	@whereto				char(40),
	@purpose				char(40),
	@paycode				char(3), 
	@deposit				money,
	@setrate				money,
	@cusno				char(50),
	@agent				char(50),
	@groupno				char(10),
	@extra				char(30)


select @setrate = a.setrate, @sex = b.sex, @idcls = b.idcls, @idend = Null, @visaid = visaid, @stay = Null, 
	@wherefrom = a.wherefrom, @whereto = a.whereto, @purpose = a.purpose,
	@paycode = a.paycode, @deposit = 0, @cusno = a.cusno, @agent = isnull(rtrim(a.agent), a.source),
	@groupno = a.groupno, @extra = a.extra
	from master a, guest b where a.accnt = @accnt and a.haccnt = b.no
-- 成员、房价保密
if @groupno <> '' or substring(@extra, 5, 1) <> '0'
	select @setrate = 0
--
select @sex = descript from basecode where cat = 'sex' and code = @sex
select @idcls = descript from basecode where cat = 'idcode' and code = @idcls
select @visaid = descript from basecode where cat = 'visaid' and code = @visaid
select @wherefrom = descript from cntcode where code = @wherefrom
select @whereto = descript from cntcode where code = @whereto
select @purpose = descript from basecode where cat = 'visaid' and code = @purpose
select @paycode = Null
select @cusno = name from guest where no = @cusno
select @agent = name from guest where no = @agent
--
select b.lname, b.fname, b.name, a.type, @setrate, a.roomno, isnull(a.citime, a.arr), a.dep, b.i_times, b.nation, @sex, 
	b.birth, @idcls, b.ident, @idend, @visaid, b.visaend, b.rjdate, @stay, @wherefrom, @whereto, b.email, @purpose, b.street, 
	@paycode, @deposit, @cusno, @agent, a.srqs, isnull(a.ciby, a.resby), b.name, a.roomno, a.dep, @setrate, 
	char1 = space(60), char2 = space(60), char3 = space(60), char4 = space(60), money1 = 0, money2 = 0, datetime1 = Null, datetime2 = Null
	from master a, guest b where a.accnt = @accnt and a.haccnt = b.no
--
return 0;
