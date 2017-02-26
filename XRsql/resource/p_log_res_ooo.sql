/*--------------------------------------------------
  Log Procedure 
   Table    :res_ooo
   Generator:sp_create_logproc
             (ZHJ Nov,2002)
--------------------------------------------------*/
                                               
if exists (select 1
          from sysobjects
          where name = 'p_log_res_ooo'
          and type = 'P')
   drop procedure p_log_res_ooo
;
                                                                                                         
create procedure p_log_res_ooo
  @accnt char(10)
as
begin
                                                                                                                                                                                                  
	update res_av_log set logmark = (select count(*) from res_av_log b where b.folio = a.folio and b.logmark < a.logmark )
	from res_av_log a 
	where a.folio = @accnt 

    select 'folio', '��Դ����', a.folio, b.folio,b.cby,b.cbytime                                                                                                                                                                                                
    from res_ooo_log a, res_ooo_log b 
    where a.logmark = b.logmark - 1 and a.folio = @accnt and b.folio =  @accnt and a.folio <> b.folio                                                                                                                   
  union                                                                                                                                                                                                                                                         
    select 'sta', '����״̬', a.sta, b.sta,b.cby,b.cbytime                                                                                                                                                                                                      
    from res_ooo_log a, res_ooo_log b 
    where a.logmark = b.logmark - 1 and a.folio = @accnt and b.folio =  @accnt and a.sta <> b.sta                                                                                                                       
  union                                                                                                                                                                                                                                                         
    select 'resid', '��Դ����', a.resid, b.resid,b.cby,b.cbytime                                                                                                                                                                                                
    from res_ooo_log a, res_ooo_log b 
    where a.logmark = b.logmark - 1 and a.folio = @accnt and b.folio =  @accnt and a.resid <> b.resid                                                                                                                   
  union                                                                                                                                                                                                                                                         
    select 'qty', 'Ԥ������', convert(varchar(60),a.qty),convert(varchar(60),b.qty),b.cby,b.cbytime                                                                                                                                                                   
    from res_ooo_log a, res_ooo_log b 
    where a.logmark = b.logmark - 1 and a.folio = @accnt and b.folio =  @accnt and a.qty <> b.qty                                                                                                                       
  union                                                                                                                                                                                                                                                         
    select 'bdate', 'Ӫҵʱ��', convert(char(10), a.bdate, 111) + ' ' + convert(char(10), a.bdate, 108), convert(char(10), b.bdate, 111) + ' ' + convert(char(10), b.bdate, 108),b.cby,b.cbytime                                                                
    from res_ooo_log a, res_ooo_log b 
    where a.logmark = b.logmark - 1 and a.folio = @accnt and b.folio =  @accnt and a.bdate <> b.bdate                                                                                                                   
  union                                                                                                                                                                                                                                                         
    select 'stime', '��ʼʱ��', convert(char(10), a.stime, 111) + ' ' + convert(char(10), a.stime, 108), convert(char(10), b.stime, 111) + ' ' + convert(char(10), b.stime, 108),b.cby,b.cbytime                                                                
    from res_ooo_log a, res_ooo_log b 
    where a.logmark = b.logmark - 1 and a.folio = @accnt and b.folio =  @accnt and a.stime <> b.stime                                                                                                                   
  union                                                                                                                                                                                                                                                         
    select 'etime', '����ʱ��', convert(char(10), a.etime, 111) + ' ' + convert(char(10), a.etime, 108), convert(char(10), b.etime, 111) + ' ' + convert(char(10), b.etime, 108),b.cby,b.cbytime                                                                
    from res_ooo_log a, res_ooo_log b 
    where a.logmark = b.logmark - 1 and a.folio = @accnt and b.folio =  @accnt and a.etime <> b.etime                                                                                                                   
  union                                                                                                                                                                                                                                                         
    select 'sfield', '��ʼ����', convert(varchar(60),a.sfield),convert(varchar(60),b.sfield),b.cby,b.cbytime                                                                                                                                                          
    from res_ooo_log a, res_ooo_log b 
    where a.logmark = b.logmark - 1 and a.folio = @accnt and b.folio =  @accnt and a.sfield <> b.sfield                                                                                                                 
  union                                                                                                                                                                                                                                                         
    select 'efield', '��������', convert(varchar(60),a.efield),convert(varchar(60),b.efield),b.cby,b.cbytime                                                                                                                                                          
    from res_ooo_log a, res_ooo_log b 
    where a.logmark = b.logmark - 1 and a.folio = @accnt and b.folio =  @accnt and a.efield <> b.efield                                                                                                                 
  union                                                                                                                                                                                                                                                         
    select 'sfieldtime', '��ʼ����ʱ��', a.sfieldtime, b.sfieldtime,b.cby,b.cbytime                                                                                                                                                                             
    from res_ooo_log a, res_ooo_log b 
    where a.logmark = b.logmark - 1 and a.folio = @accnt and b.folio =  @accnt and a.sfieldtime <> b.sfieldtime                                                                                                         
  union                                                                                                                                                                                                                                                         
    select 'efieldtime', '��������ʱ��', a.efieldtime, b.efieldtime,b.cby,b.cbytime                                                                                                                                                                             
    from res_ooo_log a, res_ooo_log b 
    where a.logmark = b.logmark - 1 and a.folio = @accnt and b.folio =  @accnt and a.efieldtime <> b.efieldtime                                                                                                         
  union                                                                                                                                                                                                                                                         
    select 'summary', '����ժҪ', substring(a.summary,1,60), substring(b.summary,1,60),b.cby,b.cbytime                                                                                                                                                                                          
    from res_ooo_log a, res_ooo_log b 
    where a.logmark = b.logmark - 1 and a.folio = @accnt and b.folio =  @accnt and a.summary <> b.summary                                                                                                               
  union                                                                                                                                                                                                                                                         
    select 'worker', '������', a.worker, b.worker,b.cby,b.cbytime                                                                                                                                                                                               
    from res_ooo_log a, res_ooo_log b 
    where a.logmark = b.logmark - 1 and a.folio = @accnt and b.folio =  @accnt and a.worker <> b.worker                                                                                                                 
  union                                                                                                                                                                                                                                                         
    select 'modu_id', 'Ԥ��ģ��', a.modu_id, b.modu_id,b.cby,b.cbytime                                                                                                                                                                                          
    from res_ooo_log a, res_ooo_log b 
    where a.logmark = b.logmark - 1 and a.folio = @accnt and b.folio =  @accnt and a.modu_id <> b.modu_id                                                                                                               
                                                                                                                                                                                                                                                                
end
;
