--=============================================================
-- ���ݲ���������Ӷ��
--
-- ������̺ܲ��Ͻ�����Ӧ�ò��� simon 2006.5.7 
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
//-- ���ݲ���������Ӷ��
//--
//-- ������̺ܲ��Ͻ�����Ӧ�ò��� simon 2006.5.7 
//--=============================================================
//declare
//		@ret			integer,
//	   @type			char(4),
//		@no			char(10),
//		@cmstype		char(1),		--0������   1:���
//		@amount		money
//
//
//select @ret = 0
//--halt ����ͣ�õ�Ӷ����,����
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
//		-- ����ж��з��������� ��
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