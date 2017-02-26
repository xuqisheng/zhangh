
if exists (select * from sysobjects where name ='p_gds_get_date_link' and type ='P')
	drop proc p_gds_get_date_link;
create proc p_gds_get_date_link
	@date			datetime,	-- ���� 
	@pmark		char(2),		-- 'D', ĳ��, 'W' ĳ�����ۼ�, 'M', ĳ�����ۼ� 
	@retmode		char(1)='S', 
	@date_link	datetime	output -- ��������  
as
-- -------------------------------------------------------
-- ��������ģʽ����ȡ�������
-- -------------------------------------------------------

declare
	@isfstday	char(1),
	@isyfstday	char(1)

select @date_link = @date, @isfstday = 'F'
if @retmode is null or @retmode<>'R' 
	select @retmode='S' 

-- ����ʱ���
if @pmark = 'D'
	select @date_link = @date
else
	begin
	if @pmark = 'W'
		begin
		while datepart(dw, @date_link) <> 2
			select @date_link=dateadd(dd, -1, @date_link)
		end
	else if @pmark = 'M'
		begin
		exec p_hry_audit_fstday @date_link, @isfstday out, @isyfstday out
		while @isfstday = 'F'
			begin
			select @date_link = dateadd(dd, -1, @date_link)
			exec p_hry_audit_fstday @date_link, @isfstday out, @isyfstday out
			end
		end
	else
		begin
		exec p_hry_audit_fstday @date_link, @isfstday out, @isyfstday out
		while @isyfstday = 'F'
			begin
			select @date_link = dateadd(dd, -1, @date_link)
			exec p_hry_audit_fstday @date_link, @isfstday out, @isyfstday out
			end
		end
	end

if @retmode = 'S'
	select @date_link 

return; 
