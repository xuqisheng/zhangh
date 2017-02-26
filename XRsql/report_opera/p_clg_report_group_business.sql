--E66�Ĺ���,��ǰ��ס������Ϣ�����������飬�����г��롣
drop proc p_clg_report_group_business;
create proc p_clg_report_group_business
as
declare
	@accnt	char(10),
	@actmem	char(10),
	@market	char(3),
	@rmnum	int,
	@adults	int,
	@children	int,
	@rmrev	money,
	@exrev	money,
	@ttlrev	money
--���������г�������ʾ
create table #goutput(
	accnt		char(10)		null,	
	blkcode	char(10)		null,
	market	char(3)		null,		
	name		varchar(50)	null,
	rmnum		int			null,
	adults	int			null,
	children	int			null,
	rmrev		money			null,
	exrev		money			null,
	tax		money			null,
	total		money			null)
create table #temp(accnt	char(10)		null)
--�����ʺţ���ס��
insert into #temp select a.accnt from master a where a.class='G' and a.sta='I'
declare c_1 cursor for select accnt from #temp
--��ʹ�õ��г���
declare c_2 cursor for select distinct market from master where class='F' and sta='I' and groupno=@accnt
--��Ա���ʺţ������г���
declare c_3	cursor for select accnt from master where class='F' and sta='I' and groupno=@accnt and market=@market
open c_1
fetch c_1 into @accnt
while @@sqlstatus=0
begin
	open c_2
	fetch c_2 into @market
	while @@sqlstatus=0
	begin
		--ÿһ����ķ���������
		select @rmnum=count(distinct roomno),@adults=sum(gstno),@children=sum(children) from master where class='F' and sta='I' and groupno=@accnt and market=@market
		--�����ķ���
		select @rmrev=isnull(sum(a.charge),0) from account a,pccode b where a.accnt=@accnt and a.pccode=b.pccode and b.deptno7='rm'
		select @exrev=isnull(sum(a.charge),0) from account a,pccode b where a.accnt=@accnt and a.pccode=b.pccode and b.deptno7<>'rm'
		select @ttlrev=isnull(sum(a.charge),0) from account a where a.accnt=@accnt
		open c_3
		fetch c_3 into @actmem
		while @@sqlstatus=0
		begin
			--��Ա�ķ��ã��ۼӡ���ͳ�����˷����˵ķ��á�
			select @rmrev=@rmrev+isnull(sum(a.charge),0) from account a,pccode b where a.accnt=@actmem and a.pccode=b.pccode and b.deptno7='rm'
			select @exrev=@exrev+isnull(sum(a.charge),0) from account a,pccode b where a.accnt=@actmem and a.pccode=b.pccode and b.deptno7<>'rm'
			select @ttlrev=@ttlrev+isnull(sum(a.charge),0) from account a where a.accnt=@actmem
			fetch c_3 into @actmem
		end
		close c_3
		--˰���ƺ���Ϊ0?
		insert into #goutput select @accnt,a.blkcode,@market,b.haccnt,@rmnum,@adults,@children,@rmrev,@exrev,0,@ttlrev from master a,master_des b where a.accnt=b.accnt and a.accnt=@accnt
		fetch c_2 into @market
	end
	close c_2
	fetch c_1 into @accnt
end
close c_1

deallocate cursor c_1
deallocate cursor c_2
deallocate cursor c_3

select * from #goutput
;