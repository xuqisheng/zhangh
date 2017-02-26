if exists(select * from sysobjects where name = "p_gl_audit_sjourrep_scjj_print" and type = "P")
	drop proc p_gl_audit_sjourrep_scjj_print;

create proc p_gl_audit_sjourrep_scjj_print
	@date				datetime
as

create table #sjourrep
(
	descript		char(16)	null, 
	amount1		money		default 0 not null,
	amount2		money		default 0 not null,
	amount3		money		default 0 not null,
	amount4		money		default 0 not null,
	amount5		money		default 0 not null,
	amount6		money		default 0 not null,
	amount7		money		default 0 not null,
	amount8		money		default 0 not null,
	amount9		money		default 0 not null,
	amount10		money		default 0 not null,
	amount11		money		default 0 not null,
	amount12		money		default 0 not null,
)
insert #sjourrep (descript) select '今日'
insert #sjourrep (descript) select '累计'
update #sjourrep set amount1 = isnull((select day from yjourrep where date = @date and 
	class = '010020'), 0) where descript = '今日'									            
update #sjourrep set amount2 = isnull((select day from yjourrep where date = @date and 
	class = '010030'), 0) where descript = '今日'									            
update #sjourrep set amount3 = isnull((select day/100 from yjourrep where date = @date and 
	class = '010080'), 0) where descript = '今日'									              
update #sjourrep set amount4 = isnull((select sum(day) from yjourrep where date = @date and 
	class in ('010055', '010058')), 0) where descript = '今日'					            
update #sjourrep set amount5 = isnull((select sum(day) from yjourrep where date = @date and 
	class in ('010043', '010045', '010048', '010060')), 0) where descript = '今日'									            
update #sjourrep set amount6 = isnull((select day from yjourrep where date = @date and 
	class = '010070'), 0) where descript = '今日'									            
update #sjourrep set amount7 = isnull((select day from yjourrep where date = @date and 
	class = '010078'), 0) where descript = '今日'									            
update #sjourrep set amount8 = isnull((select day from yjourrep where date = @date and 
	class = '010410'), 0) where descript = '今日'									            
update #sjourrep set amount9 = isnull((select day from yjourrep where date = @date and 
	class = '010430'), 0) where descript = '今日'									            
update #sjourrep set amount10 = isnull((select day from yjourrep where date = @date and 
	class = '070430'), 0) where descript = '今日'									            
update #sjourrep set amount11 = isnull((select day from yjourrep where date = @date and 
	class = '010045'), 0) where descript = '今日'									            
update #sjourrep set amount12 = isnull((select day from yjourrep where date = @date and 
	class = '010048'), 0) where descript = '今日'									            
   
update #sjourrep set amount1 = isnull((select month from yjourrep where date = @date and 
	class = '010020'), 0) where descript = '累计'									            
update #sjourrep set amount2 = isnull((select month from yjourrep where date = @date and 
	class = '010030'), 0) where descript = '累计'									            
update #sjourrep set amount3 = isnull((select month/100 from yjourrep where date = @date and 
	class = '010080'), 0) where descript = '累计'									              
update #sjourrep set amount4 = isnull((select sum(month) from yjourrep where date = @date and 
	class in ('010055', '010058')), 0) where descript = '累计'					            
update #sjourrep set amount5 = isnull((select sum(month) from yjourrep where date = @date and 
	class in ('010043', '010045', '010048', '010060')), 0) where descript = '累计'									            
update #sjourrep set amount6 = isnull((select month from yjourrep where date = @date and 
	class = '010070'), 0) where descript = '累计'									            
update #sjourrep set amount7 = isnull((select month from yjourrep where date = @date and 
	class = '010078'), 0) where descript = '累计'									            
update #sjourrep set amount8 = isnull((select month from yjourrep where date = @date and 
	class = '010410'), 0) where descript = '累计'									            
update #sjourrep set amount9 = isnull((select month from yjourrep where date = @date and 
	class = '010430'), 0) where descript = '累计'									            
update #sjourrep set amount10 = isnull((select month from yjourrep where date = @date and 
	class = '070430'), 0) where descript = '累计'									            
update #sjourrep set amount11 = isnull((select month from yjourrep where date = @date and 
	class = '010045'), 0) where descript = '累计'									            
update #sjourrep set amount12 = isnull((select month from yjourrep where date = @date and 
	class = '010048'), 0) where descript = '累计'									            
select * from #sjourrep order by descript
return 0;


if exists(select * from sysobjects where name = "p_gl_audit_sjourrep_scjj_dw4" and type = "P")
	drop proc p_gl_audit_sjourrep_scjj_dw4;

create proc p_gl_audit_sjourrep_scjj_dw4
	@date				datetime
as
declare
	@day				money,
	@month			money,
	@year				money,
	@day1				money,
	@month1			money,
	@year1			money,
	@day2				money,
	@month2			money,
	@year2			money,
	@day3				money,
	@month3			money,
	@year3			money,
	@day4				money,
	@month4			money,
	@year4			money,
	@day5				money,
	@month5			money,
	@year5			money,
	@day6				money,
	@month6			money,
	@year6			money

select @day = round(day, 2), @month = round(month, 2), @year = round(year, 2) from yjourrep where date = @date and class = '010180'
select @day1 = round(day, 2), @month1 = round(month, 2), @year1 = round(year, 2) from yjourrep where date = @date and class = '010190'
select @day4 = round(day, 2), @month4 = round(month, 2), @year4 = round(year, 2) from yjourrep where date = @date and class = '0101903'
select @day5 = round(day, 2), @month5 = round(month, 2), @year5 = round(year, 2) from yjourrep where date = @date and class = '0101905'
select @day6 = round(day, 2), @month6 = round(month, 2), @year6 = round(year, 2) from yjourrep where date = @date and class = '0101908'
select @day2 = round(day, 2), @month2 = round(month, 2), @year2 = round(year, 2) from yjourrep where date = @date and class = '010200'
select @day3 = round(day, 2), @month3 = round(month, 2), @year3 = round(year, 2) from yjourrep where date = @date and class = '010220'
select '今日房价:' + substring(ltrim(convert(char(20), @day)), 1, 7) + '     散客:' + substring(ltrim(convert(char(20), @day1)), 1, 7) + ' （散客:' + substring(ltrim(convert(char(20), @day4)), 1, 7) + ' 散客团:' + substring(ltrim(convert(char(20), @day5)), 1, 7) + ' 会议团:' + substring(ltrim(convert(char(20), @day6)), 1, 7) + '） 团体:' + substring(ltrim(convert(char(20), @day2)), 1, 7) + ' 长住:' + substring(ltrim(convert(char(20), @day3)), 1, 7),
	'本月房价:' + substring(ltrim(convert(char(20), @month)), 1, 7) + '     散客:' + substring(ltrim(convert(char(20), @month1)), 1, 7) + ' （散客:' + substring(ltrim(convert(char(20), @month4)), 1, 7) + ' 散客团:' + substring(ltrim(convert(char(20), @month5)), 1, 7) + ' 会议团:' + substring(ltrim(convert(char(20), @month6)), 1, 7) + '） 团体:' + substring(ltrim(convert(char(20), @month2)), 1, 7) + ' 长住:' + substring(ltrim(convert(char(20), @month3)), 1, 7),
	'本年房价:' + substring(ltrim(convert(char(20), @year)), 1, 7) + '     散客:' + substring(ltrim(convert(char(20), @year1)), 1, 7) + ' （散客:' + substring(ltrim(convert(char(20), @year4)), 1, 7) + ' 散客团:' + substring(ltrim(convert(char(20), @year5)), 1, 7) + ' 会议团:' + substring(ltrim(convert(char(20), @year6)), 1, 7) + '） 团体:' + substring(ltrim(convert(char(20), @year2)), 1, 7) + ' 长住:' + substring(ltrim(convert(char(20), @year3)), 1, 7)
return 0;
