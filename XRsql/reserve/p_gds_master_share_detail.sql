if exists(select * from sysobjects where name = "p_gds_master_share_detail")
   drop proc p_gds_master_share_detail
;
create  proc p_gds_master_share_detail
   @accnt 				char(10)
as
------------------------------------
--	Share Window : Detail  
-- 包含非有效状态 (暂不考虑已经转入历史的客人)
------------------------------------
declare	@saccnt		char(10),
			@master		char(10)

create table #goutput(
	accnt				char(10)		default ''		null,
	master			char(10)		default ''		null,
	name				varchar(60)	default ''		null,
	sta				varchar(20)	default ''		null,		-- 状态描述
	arr				datetime							null,
	dep				datetime							null,
	gstno				int			default 0		null,
	ratecode			char(10)		default ''		null,
	rate				money			default 0		null,
	roomno			char(5)		default ''		null,
	sta0				char(1)		default ''		null,		 -- 状态代码
	packages			varchar(50)	default ''  	null
)

select @saccnt = saccnt, @master = master from master where accnt=@accnt
if @@rowcount > 0
begin
	insert #goutput
		select a.accnt,a.master,b.haccnt,b.sta,a.arr,a.dep,a.gstno,a.ratecode,a.setrate,a.roomno,a.sta,a.packages
			from master a, master_des b
				where a.accnt=b.accnt 
					and ( a.saccnt= @saccnt or a.master= @master )
end

select a.* from #goutput a, basecode b 
	where a.sta0*=b.code and b.cat='mststa' 
		order by b.sequence,master, accnt
;
