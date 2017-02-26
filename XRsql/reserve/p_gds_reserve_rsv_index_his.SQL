IF OBJECT_ID('p_gds_reserve_rsv_index_his') IS NOT NULL
    DROP PROCEDURE p_gds_reserve_rsv_index_his
;
create proc p_gds_reserve_rsv_index_his
	@repdate		datetime,
	@date			datetime,
	@rn			money		output,	-- rm nigth
	@rr			money		output,	-- rm revenue 
	@rn_ten		money		output,
	@rr_ten		money		output
as
-----------------------------------------------
-- 历史处理，配合 p_gds_reserve_rms_pickup2 应用 
-- 收益管理使用 hz sofitel 
--
-- 由于历史数据保存的原因，这里的数据是不准的。比如没有团体取消的预留房情况等  
-- 
--	@repdate 计算基准日期 - 
--	@date    计算客房占用日期 - 
--		客房占用日期 @date in (master.arr -> master.dep)
--		报表日期		 @repdate in (master.restime -> master.bdate) 
-----------------------------------------------

create table #rsv (
   accnt     	char(10) 				not null,
	sta			char(1)					not null,
	type			char(5)					not null,
	roomno		char(5)					not null,
	groupno		char(10)					not null,
	restype		char(3)					not null,
	rmnum			int						not null,
	rate			money						not null,
	restime    	datetime  				not null,
	arr      	datetime  				not null,
	dep      	datetime  				not null,
	bdate      	datetime  				not null,
	ten			char(1)					not null
)

insert #rsv select accnt, sta, type, roomno, groupno, restype, rmnum, setrate, 
		isnull(isnull(restime,citime),arr), arr, dep, bdate,'F'  
	from hmaster where datediff(dd, @date, arr)<=0 and datediff(dd, @date, dep)>0 and accnt like 'F%'
update #rsv set restime = a.restime from hmaster a where #rsv.groupno=a.accnt
delete #rsv where not (datediff(dd, @repdate, restime)<=0 and datediff(dd, @repdate, bdate)>0 )
update #rsv set ten='T' from restype a where #rsv.restype=a.code and a.definite='F' 

select @rn=isnull(sum(rmnum),0) from #rsv where roomno='' 
select @rn=@rn + count(distinct roomno) from #rsv where roomno<>'' 
select @rr=isnull(sum(rmnum*rate),0) from #rsv

select @rn_ten=isnull(sum(rmnum),0) from #rsv where ten='T' and roomno='' 
select @rn_ten=@rn_ten + count(distinct roomno) from #rsv where ten='T' and roomno<>'' 
select @rr_ten=isnull(sum(rmnum*rate),0) from #rsv where ten='T' 

-- select * from #rsv 
-- select @rn, @rr, @rn_ten, @rr_ten 

return 0
;
