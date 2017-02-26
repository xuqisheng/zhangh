--=============================================================
-- 根据参数，计算佣金
--
-- 这个过程很不严谨，不应该采用 simon 2006.5.7 
--=============================================================

if exists(select 1 from sysobjects where name = 'p_wz_cmscode_amount_calculate')
	drop proc p_wz_cmscode_amount_calculate ;
//create proc p_wz_cmscode_amount_calculate
//		@cmscode		 char(10) ,
//		@roomno		 char(4),
//		@rmrate		 money,
//		@cmsamt		 money    out
//
//as
//--=============================================================
//-- 根据参数，计算佣金
//--
//-- 这个过程很不严谨，不应该采用 simon 2006.5.7 
//--=============================================================
//declare
//		@ret			integer,
//	   @type			char(4),
//		@no			char(10),
//		@cmstype		char(1),		--0：比例   1:金额
//		@amount		money
//
//
//select @ret = 0
//--halt 对于停用的佣金码,处理
//if exists(select 1 from cmscode where code = @cmscode and halt = 'T')
//	select @ret = 1,@cmsamt = 0
//
//if @ret = 0
//begin
//	select @type = type from rmsta where roomno = @roomno  
//	-- if @@rowcount = 0 ? 
//	if exists(select 1 from cms_defitem a,cmscode_link b where b.code = @cmscode and b.cmscode = a.no and charindex(@type,a.rmtype)>0)
//	begin
//		select @cmstype = a.type,@amount = a.amount from cms_defitem a,cmscode_link b where b.code = @cmscode and b.cmscode = a.no and charindex(@type,a.rmtype)>0		
//		-- 如果有多行符合条件呢 ？
//		if @cmstype = '0'
//			select @cmsamt = round(@rmrate*@amount,2)
//		else
//			select @cmsamt = @amount
//	end
//	else
//		select @cmsamt = 0
//end 
//
//
//
////select @cmsamt
//
//return @ret
//;
//
//
//
//