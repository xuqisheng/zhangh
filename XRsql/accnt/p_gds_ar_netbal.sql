IF OBJECT_ID('p_gds_ar_netbal') IS NOT NULL
    DROP PROCEDURE p_gds_ar_netbal
;
create proc p_gds_ar_netbal
   @accnt		char(10),
	@langid		int = 0
as
---------------------------------------------------------
--	显示净额
---------------------------------------------------------
declare	@amount1		money,
			@amount2		money,
			@amount3		money

create table #goutput (
	item			char(12)							null,
	descript		varchar(50)						null,
	descript1	varchar(50)						null,
	amount		money								null,
	mout			varchar(20)						null
)

-- 当前余额
insert #goutput select 'curbal', '当前余额', 'Current Balance', 
	charge-credit,'' from armst where accnt=@accnt 

-- 信用
insert #goutput select 'credit', '信用:'+b.descript, 'Credit:'+b.descript1, 
	a.amount,'' from accredit a, pccode b where a.accnt=@accnt and a.pccode=b.pccode and a.tag='0'
if @@rowcount = 0 
	insert #goutput select 'credit', '信用', 'Credit', 0,''

-- 授权
insert #goutput select 'arget',  '授权:'+c.roomno+'-'+d.name+'-'+c.accnt, 'Credited:'+c.roomno+'-'+d.name+'-'+c.accnt, 
	a.amount,'' from accredit a,  pccode b, master c, guest d WHERE a.cardno=@accnt and a.accnt=c.accnt and c.haccnt=d.no and a.tag='0' and a.pccode=b.pccode and b.deptno2='TOR'
if @@rowcount = 0 
	insert #goutput select 'arget',  '授权', 'Credited', 0 ,''

-- 净额
select @amount1 = isnull((select sum(amount) from #goutput where item='curbal'), 0)
select @amount2 = isnull((select sum(amount) from #goutput where item='credit'), 0)
select @amount3 = isnull((select sum(amount) from #goutput where item='arget'), 0)
select @amount1 = @amount1 + @amount3 - @amount2 
insert #goutput select 'netbal',  '净额', 'Net Bal.', @amount1 ,''

-- money -> char 
update #goutput set mout = rtrim(convert(char(20), amount))

-- 显示 - 允许记账
insert #goutput select '-',  '-', '-', null,null
if @langid = 0 
	insert #goutput select 'lock',  '允许记账', 'Auth. Posting', null, b.descript from armst a, basecode b
		where a.accnt=@accnt and b.cat='artag2' and a.artag2=b.code 
else
	insert #goutput select 'lock',  '允许记账', 'Auth. Posting', null, b.descript1 from armst a, basecode b
		where a.accnt=@accnt and b.cat='artag2' and a.artag2=b.code 

-- Output 
if @langid = 0
	select descript, mout from #goutput 
else
	select descript1, mout from #goutput 

return 
;