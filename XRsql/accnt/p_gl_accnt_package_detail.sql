
if exists(select * from sysobjects where name = "p_gl_accnt_package_detail")
	drop proc p_gl_accnt_package_detail;

create proc p_gl_accnt_package_detail
	@accnt			char(10)
as
-- ĳ�ʺ�Package Detail��ѯ
declare 
	@pcrec_pkg		char(10)

create table #detail
(
	accnt					char(10)			not null,								-- �˺� 
	number				integer			not null,								-- �ؼ��� 
	roomno				char(5)			default '' not null,					-- ���� 
	code					char(8)			default '' not null,					-- ���� 
	descript				char(30)			not null,								-- ���� 
	descript1			char(30)			default '' not null,					-- Ӣ������ 
	bdate					datetime			not null,								--  
	starting_date		datetime			default '2000/1/1' not null,		-- ��Ч��ʼ���� 
	closing_date		datetime			default '2038/12/31' not null,	-- ��Ч��ֹ���� 
	starting_time		char(8)			default '00:00:00' not null,		-- ÿ�����Ч������ʼʱ�� 
	closing_time		char(8)			default '23:59:59' not null,		-- ÿ�����Ч���˽�ֹʱ�� 
	pccodes				varchar(255)	default '' not null,					-- ���Թ�����Ӫҵ������� 
	pos_pccode			char(5)			default '' not null,					-- �����޶�󣬼���Account��Ӫҵ������� 
	quantity				money				default 0 not null,					-- ���� 
	charge				money				default 0 not null,					-- ��ת�˵Ľ�� 
	credit				money				default 0 not null,					-- ����ת�˵Ľ�� 
	posted_accnt		char(10)			default '' not null,					-- ʵ��ת�˵��˺� 
	posted_roomno		char(5)			default '' not null,					-- ʵ��ת�˵ķ��� 
	posted_number		integer			default 0 not null,					-- ��Ӧ�ؼ���(ʵ��ʹ�õ�����һ��Package) 
	tag					char(1)			default '0' not null,				-- ��־��0.�Զ������Package(δ��)
																							--			1.�Զ������Package(������һ����)
																							--			2.�Զ������Package(���ù�)
																							--			5.�Զ������Package(�ѳ���)
																							--			9.ʵ��ʹ��Package����ϸ 
	account_accnt		char(10)			default '' not null,					-- �˺�(��ӦAccount.Accnt) 
	account_number		integer			default 0 not null,					-- �˴�(��ӦAccount.Number) 
	account_date		datetime			default getdate() not null,		-- �˺�(��ӦAccount.log_date) 
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

