if exists(select * from sysobjects where name='p_gds_maint_hisbase' and type ='P')
   drop proc p_gds_maint_hisbase;
create proc p_gds_maint_hisbase
	@mode		char(1) = '' -- �ǿվͲ��ж�init����6000000�ַ� 
as
-- ------------------------------------------------------------------------
-- ϵͳά������: 	���� sysdata.hisbase 
-- 
-- ��Ա�Ƶ굵������� 6000000 ��ʼ�Ǵ� X502.. 2006.10.10 ���Ժ�汾��ʼ 
-- ------------------------------------------------------------------------
declare	@maxno		int,
			@hisbase		int,
			@ver			varchar(255),
			@hotelid		varchar(30) 

select @hotelid = value from sysoption where catalog='hotel' and item='hotelid'
select @ver = value from sysoption where catalog='hotel' and item='lic_version'
if @@rowcount = 0
begin 
	select '��ǰ�汾���ܲ���X���Ĳ�Ʒ������Ҫ������'
	return 
end
if substring(@ver, 1, 5) <> 'X5.02'
begin 
	select '�� X5.02 ��Ʒ������Ҫ������'
	return 
end
if @mode = ''
begin 
	if not exists(select 1 from syscomments a, sysobjects b where a.id=b.id and b.name='p_foxhis_sysdata_init' and charindex('6000000',a.text)>0 )
	begin 
		select 'p_foxhis_sysdata_init û�а��� 6000000 �ַ������� '
		return 
	end
end 

select @maxno = isnull(convert(int,(select max(no) from guest where no like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9]')), 6000000) 
if @maxno < 6000000 and @hotelid<>'crs'
begin 
	select 'ʵ����󵵰�����С�� 6000000������'
	return 
end

select @hisbase = hisbase from sysdata 
if @hisbase < @maxno + 1
	update sysdata set hisbase = @maxno + 1
;

select hisbase from sysdata ; 
exec p_gds_maint_hisbase;
select hisbase from sysdata ; 


