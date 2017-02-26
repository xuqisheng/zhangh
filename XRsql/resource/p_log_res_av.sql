/*--------------------------------------------------
  Log Procedure 
  Table    :res_av
  Generator:sp_create_logproc
             (ZHJ Nov,2002)
--------------------------------------------------*/
                                                
if exists (select 1
          from sysobjects
          where name = 'p_log_res_av'
          and type = 'P')
   drop procedure p_log_res_av
;
                                                                                                           
create procedure p_log_res_av
  @accnt char(10)
as
begin

	update res_av_log set logmark = (select count(*) from res_av_log b where b.folio = a.folio and b.logmark < a.logmark )
	from res_av_log a 
	where a.folio = @accnt 
                                                                                                                                                                                                   
    select 'folio', 'folio', a.folio, b.folio,b.cby,b.cbytime                                                                                                                                                                                                   
    from res_av_log a, res_av_log b 
    where a.logmark = b.logmark - 1 and a.folio = @accnt and b.folio =  @accnt and a.folio <> b.folio                                                                                                                     
  union                                                                                                                                                                                                                                                         
    select 'accnt', '资源帐号', a.accnt, b.accnt,b.cby,b.cbytime                                                                                                                                                                                                
    from res_av_log a, res_av_log b 
    where a.logmark = b.logmark - 1 and a.folio = @accnt and b.folio =  @accnt and a.accnt <> b.accnt                                                                                                                     
  union                                                                                                                                                                                                                                                         
    select 'sta', '单据状态', a.sta, b.sta,b.cby,b.cbytime                                                                                                                                                                                                      
    from res_av_log a, res_av_log b 
    where a.logmark = b.logmark - 1 and a.folio = @accnt and b.folio =  @accnt and a.sta <> b.sta                                                                                                                         
  union                                                                                                                                                                                                                                                         
    select 'resid', '资源编码', a.resid, b.resid,b.cby,b.cbytime                                                                                                                                                                                                
    from res_av_log a, res_av_log b 
    where a.logmark = b.logmark - 1 and a.folio = @accnt and b.folio =  @accnt and a.resid <> b.resid                                                                                                                     
  union                                                                                                                                                                                                                                                         
    select 'qty', '预订数量', convert(varchar(60),a.qty),convert(varchar(60),b.qty),b.cby,b.cbytime                                                                                                                                                                   
    from res_av_log a, res_av_log b 
    where a.logmark = b.logmark - 1 and a.folio = @accnt and b.folio =  @accnt and a.qty <> b.qty                                                                                                                         
  union                                                                                                                                                                                                                                                         
    select 'bdate', '营业时间', convert(char(10), a.bdate, 111) + ' ' + convert(char(10), a.bdate, 108), convert(char(10), b.bdate, 111) + ' ' + convert(char(10), b.bdate, 108),b.cby,b.cbytime                                                                
    from res_av_log a, res_av_log b 
    where a.logmark = b.logmark - 1 and a.folio = @accnt and b.folio =  @accnt and a.bdate <> b.bdate                                                                                                                     
  union                                                                                                                                                                                                                                                         
    select 'stime', '开始时间', convert(char(10), a.stime, 111) + ' ' + convert(char(10), a.stime, 108), convert(char(10), b.stime, 111) + ' ' + convert(char(10), b.stime, 108),b.cby,b.cbytime                                                                
    from res_av_log a, res_av_log b 
    where a.logmark = b.logmark - 1 and a.folio = @accnt and b.folio =  @accnt and a.stime <> b.stime                                                                                                                     
  union                                                                                                                                                                                                                                                         
    select 'etime', '结束时间', convert(char(10), a.etime, 111) + ' ' + convert(char(10), a.etime, 108), convert(char(10), b.etime, 111) + ' ' + convert(char(10), b.etime, 108),b.cby,b.cbytime                                                                
    from res_av_log a, res_av_log b 
    where a.logmark = b.logmark - 1 and a.folio = @accnt and b.folio =  @accnt and a.etime <> b.etime                                                                                                                     
  union                                                                                                                                                                                                                                                         
    select 'sfield', '开始场次', convert(varchar(60),a.sfield),convert(varchar(60),b.sfield),b.cby,b.cbytime                                                                                                                                                          
    from res_av_log a, res_av_log b 
    where a.logmark = b.logmark - 1 and a.folio = @accnt and b.folio =  @accnt and a.sfield <> b.sfield                                                                                                                   
  union                                                                                                                                                                                                                                                         
    select 'efield', '结束场次', convert(varchar(60),a.efield),convert(varchar(60),b.efield),b.cby,b.cbytime                                                                                                                                                          
    from res_av_log a, res_av_log b 
    where a.logmark = b.logmark - 1 and a.folio = @accnt and b.folio =  @accnt and a.efield <> b.efield                                                                                                                   
  union                                                                                                                                                                                                                                                         
    select 'sfieldtime', '开始场次时间', a.sfieldtime, b.sfieldtime,b.cby,b.cbytime                                                                                                                                                                             
    from res_av_log a, res_av_log b 
    where a.logmark = b.logmark - 1 and a.folio = @accnt and b.folio =  @accnt and a.sfieldtime <> b.sfieldtime                                                                                                           
  union                                                                                                                                                                                                                                                         
    select 'efieldtime', '结束场次时间', a.efieldtime, b.efieldtime,b.cby,b.cbytime                                                                                                                                                                             
    from res_av_log a, res_av_log b 
    where a.logmark = b.logmark - 1 and a.folio = @accnt and b.folio =  @accnt and a.efieldtime <> b.efieldtime                                                                                                           
  union                                                                                                                                                                                                                                                         
    select 'summary', '单据摘要', substring(a.summary,1,60), substring(b.summary,1,60),b.cby,b.cbytime                                                                                                                                                                                          
    from res_av_log a, res_av_log b 
    where a.logmark = b.logmark - 1 and a.folio = @accnt and b.folio =  @accnt and a.summary <> b.summary                                                                                                                 
  union                                                                                                                                                                                                                                                         
    select 'worker', '负责人', a.worker, b.worker,b.cby,b.cbytime                                                                                                                                                                                               
    from res_av_log a, res_av_log b 
    where a.logmark = b.logmark - 1 and a.folio = @accnt and b.folio =  @accnt and a.worker <> b.worker                                                                                                                   
  union                                                                                                                                                                                                                                                         
    select 'amount', '金额', convert(varchar(60),a.amount),convert(varchar(60),b.amount),b.cby,b.cbytime                                                                                                                                                              
    from res_av_log a, res_av_log b 
    where a.logmark = b.logmark - 1 and a.folio = @accnt and b.folio =  @accnt and a.amount <> b.amount                                                                                                                   
  union                                                                                                                                                                                                                                                         
    select 'amount0', '原来金额', convert(varchar(60),a.amount0),convert(varchar(60),b.amount0),b.cby,b.cbytime                                                                                                                                                       
    from res_av_log a, res_av_log b 
    where a.logmark = b.logmark - 1 and a.folio = @accnt and b.folio =  @accnt and a.amount0 <> b.amount0                                                                                                                 
  union                                                                                                                                                                                                                                                         
    select 'reason', '优惠理由', a.reason, b.reason,b.cby,b.cbytime                                                                                                                                                                                             
    from res_av_log a, res_av_log b 
    where a.logmark = b.logmark - 1 and a.folio = @accnt and b.folio =  @accnt and a.reason <> b.reason                                                                                                                   
  union                                                                                                                                                                                                                                                         
    select 'flag', '入帐标志', a.flag, b.flag,b.cby,b.cbytime                                                                                                                                                                                                   
    from res_av_log a, res_av_log b 
    where a.logmark = b.logmark - 1 and a.folio = @accnt and b.folio =  @accnt and a.flag <> b.flag                                                                                                                       
                                                                                                                                                                                                                                                                
end
;
