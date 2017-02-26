
IF OBJECT_ID('p_cq_cmscode_get_none') IS NOT NULL
    DROP PROCEDURE p_cq_cmscode_get_none
;
create proc p_cq_cmscode_get_none
		@accnt				char(10),	-- �˺�
		@cmscode				char(10),	-- Ӷ����
		@cms_code			char(10),	-- Ӷ����ϸ��
		@bdate				datetime		-- Ӫҵ����
as
----------------------------------------------------------------------
--	Ӷ����㲢�Ҹ��� cms_rec - ��ԣ��޽��ݽ���
--
-- ������ʱ���ж�Ӷ���Ƿ���ڷ���
----------------------------------------------------------------------
declare
		@pri				integer,
		@cmscode_detail char(10),
		@unit				 char(1),
		@type				 char(1),
		@rmtype			 varchar(255),
		@amount			 money,
		@dayuse			 char(2),
		@uproom1			 money,	@upamount1      money,
		@uproom2			 money,	@upamount2      money,
		@uproom3			 money,	@upamount3      money,
		@uproom4			 money,	@upamount4      money,
		@uproom5			 money,	@upamount5      money,
		@uproom6			 money,	@upamount6      money,
		@uproom7			 money,	@upamount7      money,
		@upamount       money,
		@week           varchar(30),
		@weeknow    	 char(1),
		@rmmode         char(8),
		@nights		    integer,
		@datecond		 varchar(80),
		@ret        	integer,
		@extra 			char(10),
		@d_line			money,
		@packrate		int,
		@srvrate			int

select @unit = unit,@type=type,@rmtype=rmtype,@amount=amount,@dayuse=dayuse,
	@uproom1=uproom1,@upamount1=upamount1,@uproom2=uproom2,@upamount2=upamount2,
	@uproom3=uproom3,@upamount3=upamount3,@uproom4=uproom4,@upamount4=upamount4,
	@uproom5=uproom5,@upamount5=upamount5,@uproom6=uproom6,@upamount6=upamount6,
	@uproom7=uproom7,@datecond = datecond ,@extra=extra,@d_line=d_line
from cms_defitem where no=@cms_code

select @packrate = convert(integer,substring(@extra,1,1)),@srvrate = convert(integer,substring(@extra,2,1))


--�����Ƿ�Ӷ
select @rmmode = 'JjBb'
if substring(@dayuse,1,1) = 'T'		-- ����ȫ��
	select @rmmode = rtrim(@rmmode) + 'N'
if substring(@dayuse,2,1) = 'T'		-- ���հ���
	select @rmmode = rtrim(@rmmode) + 'P'

--type = 1 ����� 0 ������ 2 - �׼�
--unit = 1 ����   0 ������


if @unit = '0'	-- 0 ������
begin
	if @type='0'
		begin
		update cms_rec set cms0 = ((rmrate+rmsur)*abs(1 -@packrate)*abs(1 -@srvrate)+netrate*@packrate*@srvrate+(packrate+netrate)*@packrate*(1 -@srvrate)+(rmsur+netrate)*@srvrate*(1 -@packrate))*@amount,
				cmsunit=@unit,cmstype=@type,cmsdetail=@cms_code
				where bdate = @bdate and belong=@accnt and cmscode=@cmscode and rtrim(cmsdetail)=null and
				(charindex(rtrim(type)+',',@rmtype+',')>0 or rtrim(@rmtype) is null) and sta = 'I'  and rtrim(cmsdetail) is null
					 and charindex(substring(mode,1,1),@rmmode)>0 and ((rmrate*abs(1 -@packrate)*abs(1 -@srvrate)+netrate*@packrate*@srvrate+(packrate+netrate)*@packrate*(1 -@srvrate)+(rmsur+netrate)*@srvrate*(1 -@packrate))>@d_line or @d_line=0)
		end
	else if @type='1'
		begin
		update cms_rec set cms0 = @amount,cmsunit=@unit,cmstype=@type,cmsdetail=@cms_code
				where bdate = @bdate and belong=@accnt and cmscode=@cmscode and rtrim(cmsdetail)=null and
				(charindex(rtrim(type)+',',@rmtype+',')>0 or rtrim(@rmtype) is null) and sta = 'I'  and rtrim(cmsdetail) is null
					 and charindex(substring(mode,1,1),@rmmode)>0 
						and ((rmrate*abs(1 -@packrate)*abs(1 -@srvrate)+netrate*@packrate*@srvrate+(packrate+netrate)*@packrate*(1 -@srvrate)+(rmsur+netrate)*@srvrate*(1 -@packrate))>@d_line or @d_line=0)
		end
	else if @type='2'
		update cms_rec set cms0 = (rmrate-@amount),cmsunit=@unit,cmstype=@type,cmsdetail=@cms_code
			where bdate = @bdate and belong=@accnt and cmscode=@cmscode and rtrim(cmsdetail)=null and
				(charindex(rtrim(type)+',',@rmtype+',')>0 or rtrim(@rmtype) is null) and sta = 'I'  and rtrim(cmsdetail) is null
					 and charindex(substring(mode,1,1),@rmmode)>0
end
else if 	@unit = '1'	-- 1 ����
begin
	if @type='0'
		begin
		update cms_rec set cms0 = ((rmrate+rmsur)*abs(1 -@packrate)*abs(1 -@srvrate)+netrate*@packrate*@srvrate+(packrate+netrate)*@packrate*(1 -@srvrate)+(rmsur+netrate)*@srvrate*(1 -@packrate))*@amount,cmsunit=@unit,cmstype=@type,cmsdetail=@cms_code
				where bdate = @bdate and datediff(day,arr,bdate) = 0 and belong=@accnt and cmscode=@cmscode and rtrim(cmsdetail)=null
				 and (charindex(rtrim(type)+',',@rmtype+',')>0 or rtrim(@rmtype) is null) and sta = 'I' and rtrim(cmsdetail) is null
					 and charindex(substring(mode,1,1),@rmmode)>0 and (((rmrate+rmsur)*abs(1 -@packrate)*abs(1 -@srvrate)+netrate*@packrate*@srvrate+(packrate+netrate)*@packrate*(1 -@srvrate)+(rmsur+netrate)*@srvrate*(1 -@packrate))>@d_line or @d_line=0)
		end
	else if @type='1'
		update cms_rec set cms0 = @amount,cmsunit=@unit,cmstype=@type,cmsdetail=@cms_code
			where bdate = @bdate and datediff(day,arr,bdate) = 0 and belong=@accnt and cmscode=@cmscode and  rtrim(cmsdetail)=null
			 and (charindex(rtrim(type)+',',@rmtype+',')>0 or rtrim(@rmtype) is null) and sta = 'I' and rtrim(cmsdetail) is null
				 and charindex(substring(mode,1,1),@rmmode)>0 and (((rmrate+rmsur)*abs(1 -@packrate)*abs(1 -@srvrate)+netrate*@packrate*@srvrate+(packrate+netrate)*@packrate*(1 -@srvrate)+(rmsur+netrate)*@srvrate*(1 -@packrate))>@d_line or @d_line=0)
	else if @type='2'
		update cms_rec set cms0 = (rmrate-@amount),cmsunit=@unit,cmstype=@type,cmsdetail=@cms_code
			where bdate = @bdate and datediff(day,arr,bdate) = 0 and belong=@accnt and cmscode=@cmscode and  rtrim(cmsdetail)=null
				 and (charindex(rtrim(type)+',',@rmtype+',')>0 or rtrim(@rmtype) is null) and sta = 'I' and rtrim(cmsdetail) is null
					and charindex(substring(mode,1,1),@rmmode)>0
end


return;

