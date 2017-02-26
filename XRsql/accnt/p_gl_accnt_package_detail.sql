
if exists(select * from sysobjects where name = "p_gl_accnt_package_detail")
	drop proc p_gl_accnt_package_detail;

create proc p_gl_accnt_package_detail
	@accnt			char(10)
as
-- 某帐号Package Detail查询
declare 
	@pcrec_pkg		char(10)

create table #detail
(
	accnt					char(10)			not null,								-- 账号 
	number				integer			not null,								-- 关键字 
	roomno				char(5)			default '' not null,					-- 房号 
	code					char(8)			default '' not null,					-- 代码 
	descript				char(30)			not null,								-- 描述 
	descript1			char(30)			default '' not null,					-- 英文描述 
	bdate					datetime			not null,								--  
	starting_date		datetime			default '2000/1/1' not null,		-- 有效起始日期 
	closing_date		datetime			default '2038/12/31' not null,	-- 有效截止日期 
	starting_time		char(8)			default '00:00:00' not null,		-- 每天的有效挂账起始时间 
	closing_time		char(8)			default '23:59:59' not null,		-- 每天的有效挂账截止时间 
	pccodes				varchar(255)	default '' not null,					-- 可以关联的营业点费用码 
	pos_pccode			char(5)			default '' not null,					-- 超出限额后，记入Account的营业点费用码 
	quantity				money				default 0 not null,					-- 数量 
	charge				money				default 0 not null,					-- 已转账的金额 
	credit				money				default 0 not null,					-- 允许转账的金额 
	posted_accnt		char(10)			default '' not null,					-- 实际转账的账号 
	posted_roomno		char(5)			default '' not null,					-- 实际转账的房号 
	posted_number		integer			default 0 not null,					-- 对应关键字(实际使用的是那一行Package) 
	tag					char(1)			default '0' not null,				-- 标志：0.自动过入的Package(未用)
																							--			1.自动过入的Package(已用了一部分)
																							--			2.自动过入的Package(已用光)
																							--			5.自动过入的Package(已冲销)
																							--			9.实际使用Package的明细 
	account_accnt		char(10)			default '' not null,					-- 账号(对应Account.Accnt) 
	account_number		integer			default 0 not null,					-- 账次(对应Account.Number) 
	account_date		datetime			default getdate() not null,		-- 账号(对应Account.log_date) 
	flag					char(1)			null 
)

select @pcrec_pkg = pcrec_pkg from master where accnt = @accnt 
if rtrim(@pcrec_pkg) is null 
	select @pcrec_pkg = @accnt 

insert #detail select a.* from package_detail a, master b 
	where (b.accnt=@pcrec_pkg or b.pcrec_pkg=@pcrec_pkg) and a.accnt = b.accnt

update #detail set starting_date = a.starting_date from package_detail a
	where #detail.tag = '9' and #detail.accnt = a.accnt and #detail.posted_number = a.number
select accnt, number, roomno, code, descript, starting_date, closing_date, starting_time, closing_time, pccodes, pos_pccode,   
	charge, credit, posted_accnt, posted_roomno, posted_number, tag, account_accnt, account_number, account_date
	from #detail order by starting_date, code, account_date
;

