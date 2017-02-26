/* �����������(ָ������) */

if exists(select * from sysobjects where name = "p_gl_haccnt_master_header3")
	drop proc p_gl_haccnt_master_header3;

create proc p_gl_haccnt_master_header3
	@pc_id				char(4),
	@mdi_id				integer,
	@roomno				char(5),
	@accnt				char(10),
	@subaccnt			integer
as

declare
	@name1				varchar(50), 
	@name2				varchar(50), 
	@name3				varchar(50), 
	@vip1					char(3), 
	@vip2					char(3), 
	@vip3					char(3), 
	@his1					char(1), 
	@his2					char(1), 
	@his3					char(1), 
	@ref					varchar(250), 
	@groupno				char(10), 
	@agent				char(7), 
	@cusno				char(7), 
	@to_accnt			char(10), 
	@rtdescript			char(50), 
	@rmrate				money, 
	@qtrate				money, 
	@setrate				money, 
	@discount			money, 
	@discount1			money, 
	@nation				char(3), 
	@vip					char(3), 
	@haccnt				char(7), 
	@cnt					integer, 
	@rmcode				char(3), 
	@rmcodedes			varchar(30),
	@i_times				integer


select @ref = '', @cnt = 0, @name1 = '', @vip1 = 'F', @his1 = 'F', @name2 = '', @vip2 = 'F', @his2 = 'F', @name3 = '', @vip3 = 'F', @his3 = 'F'
//            
select @rmrate = rmrate, @qtrate = qtrate, @setrate = setrate, @discount = discount, @discount1 = discount1, 
	@haccnt = haccnt, @groupno = groupno, @cusno = cusno, @agent = agent
	from hmaster where accnt = @accnt
if @rmrate != @setrate
	begin
	select @rtdescript = '���м�:' + ltrim(convert(char(10), @rmrate)) + 'Ԫ;'
	if @rmrate != @qtrate
		select @rtdescript = @rtdescript + 'Э���:' + ltrim(convert(char(10), @qtrate)) + 'Ԫ;'
	if @qtrate != @setrate
		select @rtdescript = @rtdescript + '�Ż�:' + ltrim(convert(char(10), @qtrate - @setrate)) + 'Ԫ'
	end
//
declare c_transfer cursor for select distinct to_accnt from subaccnt where accnt = @accnt and type = '5' and pccodes != '-;' order by to_accnt
open c_transfer
fetch c_transfer into @to_accnt
while @@sqlstatus = 0
	begin
	if @to_accnt != ''
		select @ref = @ref + ',' + @to_accnt
	fetch c_transfer into @to_accnt
	end 
close c_transfer
deallocate cursor c_transfer
if @ref != ''
	select @ref = '�Զ�ת�ʵ�' + rtrim(substring(@ref, 2, 250)) + ';'
//
select @name1 = b.name from hmaster a, guest b where a.accnt = @groupno and a.haccnt *= b.no
select @name2 = name from guest where no = @cusno
select @name3 = name from guest where no = @agent
select @i_times = b.i_times from hmaster a, guest b where a.accnt = @accnt and a.haccnt = b.no
//��ʾ���ʽ���Ƿ�
//select a.accnt, b.name, a.sta, a.roomno, a.arr, a.dep, a.groupno, @name1, a.cusno, @name2, a.agent, @name3, 
//	b.vip, isnull(@i_times, 0), mail = @cnt, a.packages, a.applicant, substring(isnull(@ref, '') + isnull(a.comsg, '') + '  ' + isnull(a.ref, ''), 1, 250), a.srqs, c.deptno2, 
//	a.setrate, addbed_rate, a.rtreason, a.ratecode, locksta='', a.pcrec, @rtdescript, balance = charge - credit, a.limit, ref1 = ''
//	from hmaster a, guest b, pccode c where a.accnt = @accnt and a.haccnt = b.no and a.paycode *= c.pccode
select a.accnt, b.name, a.sta, a.roomno, a.arr, a.dep, a.groupno, @name1, a.cusno, @name2, a.agent, @name3, 
	b.vip, isnull(@i_times, 0), mail = @cnt, a.packages, a.applicant, isnull(a.ref, '') + '  ' + substring(isnull(@ref, '') + isnull(a.comsg, ''), 1, 250), a.srqs, a.paycode, 
	a.setrate, addbed_rate, a.rtreason, a.ratecode, locksta='', a.pcrec, @rtdescript, balance = charge - credit, a.limit, ref1 = ''
	from hmaster a, guest b where a.accnt = @accnt and a.haccnt = b.no
return 0;
