if exists(select * from sysobjects where name = "p_gds_reserve_welcome_card")
   drop proc p_gds_reserve_welcome_card
;
create proc p_gds_reserve_welcome_card
	@accnt			char(10)
as

------------------------------------------------------------
--		��ӡ���˻�ӭ��
------------------------------------------------------------

create table #gout (
	name				varchar(60)			null,
	arr				datetime				null,
	dep				datetime				null,
	roomno			char(5)				null,
	ratecode			char(10)				null,
	rate				money					null,
	srqs				varchar(30)			null,
	remark			varchar(255)		null
)

insert #gout 
	select b.haccnt,a.arr,a.dep,isnull(rtrim(a.roomno),a.type),a.ratecode,a.setrate,a.srqs,'' 
		from master a, master_des b 
			where a.accnt=b.accnt and a.accnt=@accnt
if @@rowcount = 0
	insert #gout(name) values('No Guest')
else
begin
	-- ���۱���
	if exists(select 1 from #gout where srqs is not null and charindex('P5', srqs)>0 )
		update #gout set rate = null 

	-- ��ע
	declare	@bf		varchar(255)		-- һ���¼��͵ص�
	select @bf = isnull((select rtrim(value) from sysoption where catalog='reserve' and item='rmcard_ref'), '')
	update #gout set remark = @bf
end

-- output
select * from #gout
return 0
;