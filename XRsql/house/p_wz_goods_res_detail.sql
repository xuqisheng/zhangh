if exists (select 1 from sysobjects where name = 'p_wz_goods_res_detail')
	drop proc p_wz_goods_res_detail;

create proc p_wz_goods_res_detail
		@sortid			char(10),
		@day				datetime,
		@day_num			char(2)
	






  SELECT res_av.resid,   
         res_plu.name,   
         res_av.stime,   
         res_av.etime,   
         res_av.qty,   
         res_av.folio,   
         res_av.resby,   
         res_av.resbyname,   
         res_av.reserved,   
         res_av.accnt,   
         res_av.sta  
    FROM res_av,   
         res_plu  
   WHERE ( res_av.resid = res_plu.resid ) and  
         ( ( res_plu.sortid = :as_sortid ) )    