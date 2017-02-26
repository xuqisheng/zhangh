-- 清除老数据
if exists (select 1
          from sysobjects
          where name = 'p_av_meetroomlist_h'
          and type = 'P')
   drop procedure p_av_meetroomlist_h
;

if exists (select 1
          from sysobjects
          where name = 'p_av_meetroomlist'
          and type = 'P')
   drop procedure p_av_meetroomlist
;
/*------------------------------------------------------------------------------
Description: 会议室显示
Reference  : Table --> res_av 
             View  --> <none>
             Proc  --> <none>
Parameter  : 
	     @infolio  varchar(10) 会议预订号
Author     : ZHJ
Date       : 2002.02
------------------------------------------------------------------------------*/
create procedure p_av_meetroomlist
	@instime  datetime, 
	@inetime  datetime, 
	@insort 	 varchar(10), 
	@inaccnt  varchar(10) = '#' 
as	
begin
  SELECT a.sta,   
         (select d.name from res_plu d where a.resid = d.resid ) name ,   
         a.stime,   
         a.sfield,   
         a.amount,   
         a.folio,   
         a.accnt,   
         (select c.name from guest c where c.no = (select b.haccnt from master b where a.accnt = b.accnt)) gstname,   
         a.summary,  
         a.sfieldtime,
			a.resid     
    FROM res_av a    
   WHERE ( resid in (select resid from res_plu where ('#'+sortid = @insort or resid = @insort or @insort = '###') and chkmode = 'mtr' ) ) and 
			( datediff(day,@instime,stime) >= 0 and datediff(day,@inetime,stime) <= 0)  and 
			( accnt = @inaccnt or '#' = @inaccnt ) and ( accnt in(select accnt from master))
  UNION  -- res_av_h
  SELECT a.sta,   
         (select d.name from res_plu d where a.resid = d.resid ) name ,   
         a.stime,   
         a.sfield,   
         a.amount,   
         a.folio,   
         a.accnt,   
         (select c.name from guest c where c.no = (select b.haccnt from hmaster b where a.accnt = b.accnt)) gstname,   
         a.summary,  
         a.sfieldtime,
			a.resid     
    FROM res_av_h a    
   WHERE ( resid in (select resid from res_plu where ('#'+sortid = @insort or resid = @insort or @insort = '###') and chkmode = 'mtr' ) ) and 
			( datediff(day,@instime,stime) >= 0 and datediff(day,@inetime,stime) <= 0)  and 
			( accnt = @inaccnt or '#' = @inaccnt ) and ( accnt in(select accnt from hmaster))
	ORDER BY a.stime ASC,   
				a.sta ASC   
end
;
