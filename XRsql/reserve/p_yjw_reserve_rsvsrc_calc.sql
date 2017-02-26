IF OBJECT_ID('dbo.p_yjw_reserve_rsvsrc_calc') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.p_yjw_reserve_rsvsrc_calc
    IF OBJECT_ID('dbo.p_yjw_reserve_rsvsrc_calc') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.p_yjw_reserve_rsvsrc_calc >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.p_yjw_reserve_rsvsrc_calc >>>'
END
;

--针对未计算包价明细的 rsvsrc_detail记录进行计算
--如果@accnt<>'' and @accnt<>null，计算具体某一个帐号
--else计算所有的未计算记录
create procedure p_yjw_reserve_rsvsrc_calc
                   @accnt  char(10),
                   @pc_id char(4),
                   @mdi_id integer 

as
declare
   @date_      datetime,
   @rate     money,
   @ratecode   char(10),
   @packages    varchar(50),
   @type     char(5),
   @gstno    int,
   @children    int,
   @tag       char(1),
   @p_lau     money,
   @p_bf      money,
   @p_srv     money,
   @p_ot      money,
   @qrate     money,
   @rmrate    money,
 	@bdate     datetime,
   @quantity  money


select @bdate=bdate from sysdata 
--删除rsvsrc表中已经没有的记录
--delete rsvsrc_detail where accnt not in(select accnt from rsvsrc) 

if @accnt<>'' and @accnt is not null
	begin
		declare c_get_accnt1 cursor for select  accnt,date_,quantity,gstno,child,type,ratecode,rate,packages  from rsvsrc_detail where calc='F' and accnt=@accnt
		open c_get_accnt1
		fetch c_get_accnt1 into @accnt,@date_,@quantity,@gstno,@children,@type,@ratecode,@rate,@packages
		while @@sqlstatus=0
			begin
			  exec p_yjw_daily_rate_change 'FN',@pc_id,@mdi_id,@date_,@ratecode,@type,@packages,@rate,@gstno,@children
			  select @p_srv=isnull(sum(a.amount),0) from rmratecode_check a,package b,basecode c where a.pc_id=@pc_id and a.code=b.code and b.type=c.code and c.grp='SVC' and c.cat='package_type'
			  select @p_bf=isnull(sum(a.amount),0) from rmratecode_check a,package b,basecode c where a.pc_id=@pc_id and a.code=b.code and b.type=c.code and c.grp='BF'  and c.cat='package_type'
			  select @p_lau=isnull(sum(a.amount),0)  from rmratecode_check a,package b,basecode c where a.pc_id=@pc_id and a.code=b.code and b.type=c.code and c.grp='LAU'  and c.cat='package_type'
			  select @p_ot=isnull(sum(a.amount),0) from rmratecode_check a,package b,basecode c where a.pc_id=@pc_id and a.code=b.code and b.type=c.code and c.grp not in('SVC','BF','LAU')  and c.cat='package_type' and a.code<>'QRAT' and a.code <>'RMRA'
			  select @qrate=isnull(amount,0) from rmratecode_check where pc_id=@pc_id and code='QRAT'
			  select @rmrate=isnull(amount,0) from rmratecode_check where pc_id=@pc_id and code='RMRA'
				 
			  update rsvsrc_detail set p_srv=@p_srv,p_bf=@p_bf,p_lau=@p_lau,p_ot=@p_ot,qrate=@qrate,trate=@rmrate,calc='T' where accnt=@accnt and date_=@date_
			  fetch c_get_accnt1 into @accnt,@date_,@quantity,@gstno,@children,@type,@ratecode,@rate,@packages 
			end  
		close  c_get_accnt1            
		deallocate cursor c_get_accnt1
	end
else
   begin
		declare c_get_accnt cursor for select  accnt,date_,quantity,gstno,child,type,ratecode,rate,packages  from rsvsrc_detail where calc='F'
		open c_get_accnt
		fetch c_get_accnt into @accnt,@date_,@quantity,@gstno,@children,@type,@ratecode,@rate,@packages
		while @@sqlstatus=0
			begin
			  exec p_yjw_daily_rate_change 'FN',@pc_id,@mdi_id,@date_,@ratecode,@type,@packages,@rate,@gstno,@children
			  select @p_srv=isnull(sum(a.amount),0) from rmratecode_check a,package b,basecode c where a.pc_id=@pc_id and a.code=b.code and b.type=c.code and c.grp='SVC' and c.cat='package_type'
			  select @p_bf=isnull(sum(a.amount),0) from rmratecode_check a,package b,basecode c where a.pc_id=@pc_id and a.code=b.code and b.type=c.code and c.grp='BF'  and c.cat='package_type'
			  select @p_lau=isnull(sum(a.amount),0)  from rmratecode_check a,package b,basecode c where a.pc_id=@pc_id and a.code=b.code and b.type=c.code and c.grp='LAU'  and c.cat='package_type'
			  select @p_ot=isnull(sum(a.amount),0) from rmratecode_check a,package b,basecode c where a.pc_id=@pc_id and a.code=b.code and b.type=c.code and c.grp not in('SVC','BF','LAU')  and c.cat='package_type' and a.code<>'QRAT' and a.code <>'RMRA'
			  select @qrate=isnull(amount,0) from rmratecode_check where pc_id=@pc_id and code='QRAT'
			  select @rmrate=isnull(amount,0) from rmratecode_check where pc_id=@pc_id and code='RMRA'
				 
			  update rsvsrc_detail set p_srv=@p_srv,p_bf=@p_bf,p_lau=@p_lau,p_ot=@p_ot,qrate=@qrate,trate=@rmrate,calc='T' where accnt=@accnt and date_=@date_
			  fetch c_get_accnt into @accnt,@date_,@quantity,@gstno,@children,@type,@ratecode,@rate,@packages 
			end  
		close  c_get_accnt             
		deallocate cursor c_get_accnt
   end

                                                                                                                                                                                       




;
EXEC sp_procxmode 'dbo.p_yjw_reserve_rsvsrc_calc','unchained'
;
IF OBJECT_ID('dbo.p_yjw_reserve_rsvsrc_calc') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.p_yjw_reserve_rsvsrc_calc >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.p_yjw_reserve_rsvsrc_calc >>>'
;
