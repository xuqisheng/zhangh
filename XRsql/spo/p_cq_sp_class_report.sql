drop  proc p_cq_sp_class_report;
create proc p_cq_sp_class_report
	@type		char(1)
as

declare
	@sort			char(4),
	@si			char(2),
	@num0			int,
	@num			int,
	@ii			int,
	@jj			int,
	@color		int,
	@columns		int,
	@value		char(255)

create table #report
(
	descript			char(20),
	guests			money,
	total				money,
	perc				money
)

select @value = value from sysoption where catalog = 'spo' and item = 'vipcard_type'

if @type = '1'
insert #report
	select c.descript,count(a.no),(select count(no) from vipcard where sta = 'I' and charindex(rtrim(type),@value) > 0),0.00 from vipcard a,guest b,basecode c where a.hno=b.no
	and c.cat='cuscls1' and c.code like '[1234567Q]%' and b.class1 = c.code and a.sta='I' and charindex(rtrim(a.type),@value) > 0 group by c.descript
if @type = '2'
insert #report
select c.descript,count(a.no),(select count(no) from vipcard where sta = 'I' and charindex(rtrim(type),@value) > 0),0.00 from vipcard a,guest b,basecode c where a.hno=b.no
	and c.cat='cuscls4' and c.code like '7%' and b.class4 = c.code and a.sta='I' and charindex(rtrim(a.type),@value) > 0 group by c.descript
if @type = '3'
insert #report
select c.descript,count(a.no),(select count(no) from vipcard where sta = 'I' and charindex(rtrim(type),@value) > 0),0.00 from vipcard a,guest b,basecode c where a.hno=b.no
	and c.cat='cuscls2' and c.code like 'S%' and b.class2 = c.code and a.sta='I' and charindex(rtrim(a.type),@value) > 0 group by c.descript
if @type = '4'
insert #report
select c.descript,count(a.no),(select count(no) from vipcard where sta = 'I' and charindex(rtrim(type),@value) > 0),0.00 from vipcard a,guest b,basecode c where a.hno=b.no
	and c.cat='sex'  and b.sex = c.code and a.sta='I' and charindex(rtrim(a.type),@value) > 0 group by c.descript

update #report set perc = (guests/total)*100

select descript,guests,perc from #report
//select * from #report

 ;
