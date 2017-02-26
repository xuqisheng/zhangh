//Ϊ�˱��ڱȽϣ������arr,dep����'yy/mm/dd 00:00:00'
if exists(select * from sysobjects where name = 'p_clg_grp_checkbill_datasrc')
	drop proc p_clg_grp_checkbill_datasrc;

create proc p_clg_grp_checkbill_datasrc
	@modu_id	char(2),
	@pc_id	char(4),
	@accnt	char(10),	-- �����ʺ�
	@arr	datetime,
	@dep	datetime
as
declare
	@thisday	datetime,
    @pccode     char(5)

delete from grp_checkbill where modu_id=@modu_id and pc_id=@pc_id
--׼�����ݣ��ѷ����İ�����������Ա���ѽ���ʷ������δ����������ǰ���ܷ����ķ���,��Ҫ���Զ����ѣ����ܻ��й̶����ã���Ŀǰδ����
--�ѷ�������
create table #accnt(accnt char(10) not null, master char(10) not null)
insert into #accnt select accnt,master from master where accnt=@accnt or groupno=@accnt
insert into #accnt select accnt,master from hmaster where accnt=@accnt or groupno=@accnt

insert into grp_checkbill select @modu_id,@pc_id,date,accnt,roomno,'',pccode,'',billno,1,charge,credit,'F'
 from account where accnt in (select accnt from #accnt)
insert into grp_checkbill select @modu_id,@pc_id,date,accnt,roomno,'',pccode,'',billno,1,charge,credit,'F'
 from haccount where accnt in (select accnt from #accnt)

--δ��������
select @thisday=bdate from sysdata
select @pccode=rtrim(value) from sysoption where catalog='audit' and item='room_charge_pccode'
if @thisday < @arr
	select @thisday = @arr
if @arr = @dep
	select @dep = dateadd(dd, 1, @dep)
while @thisday < @dep
	begin
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
	insert into grp_checkbill select @modu_id,@pc_id,@thisday,accnt,'',type,@pccode,'','',quantity,trate,0,'T'
	 from rsvsrc_detail where accnt=@accnt and datediff(dd,date_,@thisday)=0
	insert into grp_checkbill select @modu_id,@pc_id,@thisday,accnt,roomno,type,@pccode,'','',1,trate,0,'T'
	 from rsvsrc_detail where accnt in (SELECT accnt FROM master WHERE groupno=@accnt) and datediff(dd,date_,@thisday)=0

	select @thisday = dateadd(dd,1,@thisday)
	end
delete from grp_checkbill where modu_id=@modu_id and pc_id=@pc_id and accnt in (select accnt from #accnt where accnt<>master) and charge = 0 and credit = 0   --�ϵļ�¼��һ����ͬס��

update grp_checkbill set rmtype=a.type from rmsta a where a.roomno=grp_checkbill.roomno and grp_checkbill.modu_id=@modu_id and grp_checkbill.pc_id=@pc_id
;
//exec p_clg_grp_checkbill_datasrc @modu_id='02',@pc_id='0.45',@accnt='4800444',@arr='2004-5-19 00:00:00',@dep='2004-6-29 00:00:00'
//select * from grp_checkbill order by pccode
//delete from grp_checkbill
//;