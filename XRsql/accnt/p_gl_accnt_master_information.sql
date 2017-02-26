
if exists(select * from sysobjects where name = "p_gl_accnt_master_information")
	drop proc p_gl_accnt_master_information;

create proc p_gl_accnt_master_information
	@operation		char(10),
	@accnt			char(10),
	@langid			integer = 0
as

-- ָ�����˵���Ҫ��Ϣ�����Ը����û����������޸� 

declare
	@arr				datetime, 
	@dep				datetime, 
	@ratecode		char(10), 
	@packages		varchar(50), 
	@srqs				varchar(30), 
	@charge			money, 
	@credit			money, 
	@accredit		money, 
	@vip				char(1)


create table #master
(
	item					char(20)			null,								-- ��Ŀ 
	descript0			char(30)			null,								-- ����� 
	descript1			char(30)			null,								-- �Ҷ��� 
	descript2			char(30)			null,								-- ���� 
	alignment			integer			default 0 null,				-- ���뷽ʽ 
	sequence				integer			null,								-- ���� 
)
select @arr = arr, @dep = dep, @ratecode = ratecode, @packages = packages, @srqs = srqs,
	@charge = charge, @credit = credit, @accredit = accredit from master where accnt = @accnt
if @langid = 0
	begin
	insert #master select '����:', convert(char(10), @arr, 011) + '  ' + substring(convert(char(10), @arr, 108), 1, 5), '', '', 0, 10
	insert #master select '�뿪:', convert(char(10), @dep, 011) + '  ' + substring(convert(char(10), @dep, 108), 1, 5), '', '', 0, 20
	insert #master select 'Rate Code:', @ratecode, '', '', 0, 30
	insert #master select 'Packages:', @packages, '', '', 0, 40
	insert #master select '����Ҫ��:', @srqs, '', '', 0, 50
	insert #master select 'Balance:', convert(char(15), @charge - @credit), '', '', 1, 60
	insert #master select '����:', convert(char(15), @accredit), '', '', 1, 70
	end
else
	begin
	insert #master select 'Arrival:', convert(char(10), @arr, 011) + '  ' + substring(convert(char(10), @arr, 108), 1, 5), '', '', 0, 10
	insert #master select 'Departure:', convert(char(10), @dep, 011) + '  ' + substring(convert(char(10), @dep, 108), 1, 5), '', '', 0, 20
	insert #master select 'Rate Code:', @ratecode, '', '', 0, 30
	insert #master select 'Packages:', @packages, '', '', 0, 40
	insert #master select 'Special:', @srqs, '', '', 0, 50
	insert #master select 'Balance:', convert(char(15), @charge - @credit), '', '', 1, 60
	insert #master select 'Credit Limit:', convert(char(15), @accredit), '', '', 1, 70
	end
update #master set descript1 = descript0, descript2 = descript0
select item, descript0, descript1, descript2, alignment from #master order by sequence
;
