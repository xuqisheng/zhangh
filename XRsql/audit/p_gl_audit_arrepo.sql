IF OBJECT_ID('p_gl_audit_arrepo') IS NOT NULL
    DROP PROCEDURE p_gl_audit_arrepo
;
create proc p_gl_audit_arrepo
	@pc_id			char(4), 
	@dates			varchar(255),
	@option			char(10),
	@deptno			char(4) = 'ALL',
	@artag			varchar(20) = 'ALL',
	@deposit			char(1) = 'T'   -- �Ƿ��������
as
------------------------------------------------------------------
--	���������֧�ֽ�ֹ���ڡ����ܷ�����������Ŀ��
------------------------------------------------------------------
declare
	@count			integer, 
	@lastdate		datetime, 
	@date				datetime, 
	@empname			char(10),
	@bno				varchar(10),
	@bno1				varchar(10),
	@bno2				varchar(10),
	@pccode			char(5),
	@mode				char(1)				-- d=detail  s=sumamry

delete arrepo where pc_id = @pc_id

-- Mode
if @option = 'summary'
	select @mode = 's', @option = 'A'
else
	select @mode = 'd'

-- Deposit
if rtrim(@deposit) is null 
	select @deposit = 'T'
if @deposit <> 'F' 
	select @deposit = 'T'
-- �Ƿ��������ͨ�� pccode �Ĵ�С���ж�
if @deposit = 'T'
	select @pccode = 'ZZZZZ'  -- ��������
else
	select @pccode = '9'			-- ����������

-- Record
if charindex('S', @option) > 0
	begin
	insert arrepo (pc_id, catalog, accnt, descript, name)
		select @pc_id, 'T/G', a.accnt, '', b.name
		from master a, guest b where a.sta = 'S' and a.class != 'A' and a.haccnt = b.no
                                                                                                                 
	end

if charindex('A', @option) > 0
	insert arrepo (pc_id, catalog, accnt, descript, name)
		select @pc_id, 'AR', a.accnt, '', b.name
		from master a, guest b where a.class = 'A' and a.haccnt = b.no
			and (@artag='ALL' or charindex(a.artag1, @artag) > 0)

-- ��ֹ���� = @dates �ĵ�һ������
select @count = 0
select @lastdate = convert(datetime,substring(@dates, 1, 10))

-- 	ȥ����һ�����ڣ�=��ֹ���ڣ���
--		�������һ��������Զ�����ڣ��������㡮��Զ��
select @dates = ltrim(stuff(@dates, 1, 10, '')) + '2000/01/01'

-- ���� billno ������, ��Ҫ��������
select @bno = convert(char(10), @lastdate, 111)
select @bno = substring(@bno,4,1)+substring(@bno,6,2)+substring(@bno,9,2)
select @bno1 = 'B'+@bno, @bno2 = 'T'+@bno

create table #account (
	accnt		char(10)		null,
	charge	money			null,
	credit	money			null,
	billno	char(10)		null,
	pccode	char(5)		null,
	bdate		datetime		null
)
insert #account 
	select a.accnt,a.charge,a.credit,a.billno,a.pccode,a.bdate from account a, arrepo b
		where b.pc_id = @pc_id and a.accnt = b.accnt 
			and a.bdate<@lastdate and a.billno = '' 
insert #account 
	select a.accnt,a.charge,a.credit,a.billno,a.pccode,a.bdate from account a, arrepo b
		where b.pc_id = @pc_id and a.accnt = b.accnt 
			and a.bdate<@lastdate and ((a.billno like 'B%' and a.billno > @bno1) or (a.billno like 'T%' and a.billno > @bno2))
insert #account 
	select a.accnt,a.charge,a.credit,a.billno,a.pccode,a.bdate from haccount a, arrepo b
		where b.pc_id = @pc_id and a.accnt = b.accnt 
			and a.bdate<@lastdate and ((a.billno like 'B%' and a.billno > @bno1) or (a.billno like 'T%' and a.billno > @bno2))

create index index1 on #account(accnt,billno,pccode,bdate)

-- begin 
while char_length(@dates) > 0
	begin
	select @count = @count + 1, @date = convert(datetime, substring(@dates, 1, 10)), @dates = substring(@dates, 11, 255)
	if @count = 1
		update arrepo set amount1 = isnull((select sum(a.charge - a.credit) from #account a, transfer b, pccode c
			where arrepo.pc_id = @pc_id and a.accnt = arrepo.accnt
			and rtrim(b.accnt) = @pc_id and b.type='6' and a.pccode = c.pccode and c.deptno + c.pccode like rtrim(b.pccode)
			and a.bdate >= @date and a.bdate < @lastdate and a.pccode<@pccode), 0)
	else if @count = 2
		update arrepo set amount2 = isnull((select sum(a.charge - a.credit) from #account a, transfer b, pccode c
			where arrepo.pc_id = @pc_id  and a.accnt = arrepo.accnt
			and rtrim(b.accnt) = @pc_id and b.type='6' and a.pccode = c.pccode and c.deptno + c.pccode like rtrim(b.pccode)
			and a.bdate >= @date and a.bdate < @lastdate and a.pccode<@pccode), 0)
	else if @count = 3
		update arrepo set amount3 = isnull((select sum(a.charge - a.credit) from #account a, transfer b, pccode c
			where arrepo.pc_id = @pc_id  and a.accnt = arrepo.accnt 
			and rtrim(b.accnt) = @pc_id and b.type='6' and a.pccode = c.pccode and c.deptno + c.pccode like rtrim(b.pccode)
			and a.bdate >= @date and a.bdate < @lastdate and a.pccode<@pccode), 0)
	else if @count = 4
		update arrepo set amount4 = isnull((select sum(a.charge - a.credit) from #account a, transfer b, pccode c
			where arrepo.pc_id = @pc_id and a.accnt = arrepo.accnt 
			and rtrim(b.accnt) = @pc_id and b.type='6' and a.pccode = c.pccode and c.deptno + c.pccode like rtrim(b.pccode)
			and a.bdate >= @date and a.bdate < @lastdate and a.pccode<@pccode), 0)
	else if @count = 5
		update arrepo set amount5 = isnull((select sum(a.charge - a.credit) from #account a, transfer b, pccode c
			where arrepo.pc_id = @pc_id and  a.accnt = arrepo.accnt
			and rtrim(b.accnt) = @pc_id and b.type='6' and a.pccode = c.pccode and c.deptno + c.pccode like rtrim(b.pccode)
			and a.bdate >= @date and a.bdate < @lastdate and a.pccode<@pccode), 0)
	else if @count = 6
		update arrepo set amount6 = isnull((select sum(a.charge - a.credit) from #account a, transfer b, pccode c
			where arrepo.pc_id = @pc_id and  a.accnt = arrepo.accnt 
			and rtrim(b.accnt) = @pc_id and b.type='6' and a.pccode = c.pccode and c.deptno + c.pccode like rtrim(b.pccode)
			and a.bdate >= @date and a.bdate < @lastdate and a.pccode<@pccode), 0)
	else if @count = 7
		update arrepo set amount7 = isnull((select sum(a.charge - a.credit) from #account a, transfer b, pccode c
			where arrepo.pc_id = @pc_id and a.accnt = arrepo.accnt 
			and rtrim(b.accnt) = @pc_id and b.type='6' and a.pccode = c.pccode and c.deptno + c.pccode like rtrim(b.pccode)
			and a.bdate >= @date and a.bdate < @lastdate and a.pccode<@pccode), 0)
	else if @count = 8
		update arrepo set amount8 = isnull((select sum(a.charge - a.credit) from #account a, transfer b, pccode c
			where arrepo.pc_id = @pc_id and a.accnt = arrepo.accnt 
			and rtrim(b.accnt) = @pc_id and b.type='6' and a.pccode = c.pccode and c.deptno + c.pccode like rtrim(b.pccode)
			and a.bdate >= @date and a.bdate < @lastdate and a.pccode<@pccode), 0)
	else if @count = 9
		update arrepo set amount9 = isnull((select sum(a.charge - a.credit) from #account a, transfer b, pccode c
			where arrepo.pc_id = @pc_id and a.accnt = arrepo.accnt  
			and rtrim(b.accnt) = @pc_id and b.type='6' and a.pccode = c.pccode and c.deptno + c.pccode like rtrim(b.pccode)
			and a.bdate >= @date and a.bdate < @lastdate and a.pccode<@pccode), 0)
	else
		update arrepo set amount10 = isnull((select sum(a.charge - a.credit) from #account a, transfer b, pccode c
			where arrepo.pc_id = @pc_id and a.accnt = arrepo.accnt 
			and rtrim(b.accnt) = @pc_id and b.type='6' and a.pccode = c.pccode and c.deptno + c.pccode like rtrim(b.pccode)
			and a.bdate >= @date and a.bdate < @lastdate and a.pccode<@pccode), 0)

	select @lastdate = @date
	end
   
delete arrepo where amount1 = 0 and amount2 =0 and amount3 = 0 and amount4 = 0 and amount5 =0 and amount6 = 0 and
	amount7 = 0 and amount8 = 0 and amount9 = 0 and amount10 = 0 and pc_id = @pc_id
update arrepo set amount = amount1 + amount2 + amount3 + amount4 + amount5 + amount6 + amount7 + amount8 + amount9 + amount10
	where pc_id = @pc_id

-- �������ܼ�¼
if @mode = 's'
	begin 
	select * into #arrepo from arrepo where 1=2
	insert #arrepo select * from arrepo where pc_id = @pc_id
	delete arrepo where pc_id = @pc_id
	insert arrepo (pc_id, catalog, accnt, descript, name, amount1, amount2, amount3, amount4, amount5, amount6, amount7, amount8, amount9, amount10, amount)
		select @pc_id,'AR',a.code,'', a.descript,sum(c.amount1),sum(c.amount2),sum(c.amount3),sum(c.amount4),sum(c.amount5),
		sum(c.amount6),sum(c.amount7),sum(c.amount8),sum(c.amount9),sum(c.amount10),sum(c.amount)	
		from basecode a,master b ,#arrepo c
		where a.code = b.artag1 and b.accnt = c.accnt and a.cat = 'artag1' and c.pc_id = @pc_id
		group by a.code ,a.descript
		order by a.code ,a.descript 
	end

return 0
;
