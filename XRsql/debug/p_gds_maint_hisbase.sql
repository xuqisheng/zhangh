if exists(select * from sysobjects where name='p_gds_maint_hisbase' and type ='P')
   drop proc p_gds_maint_hisbase;
create proc p_gds_maint_hisbase
	@mode		char(1) = '' -- 非空就不判断init过程6000000字符 
as
-- ------------------------------------------------------------------------
-- 系统维护程序: 	修正 sysdata.hisbase 
-- 
-- 成员酒店档案号码从 6000000 开始是从 X502.. 2006.10.10 日以后版本开始 
-- ------------------------------------------------------------------------
declare	@maxno		int,
			@hisbase		int,
			@ver			varchar(255),
			@hotelid		varchar(30) 

select @hotelid = value from sysoption where catalog='hotel' and item='hotelid'
select @ver = value from sysoption where catalog='hotel' and item='lic_version'
if @@rowcount = 0
begin 
	select '当前版本可能不是X核心产品，不需要做处理'
	return 
end
if substring(@ver, 1, 5) <> 'X5.02'
begin 
	select '非 X5.02 产品，不需要做处理'
	return 
end
if @mode = ''
begin 
	if not exists(select 1 from syscomments a, sysobjects b where a.id=b.id and b.name='p_foxhis_sysdata_init' and charindex('6000000',a.text)>0 )
	begin 
		select 'p_foxhis_sysdata_init 没有包含 6000000 字符，请检查 '
		return 
	end
end 

select @maxno = isnull(convert(int,(select max(no) from guest where no like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9]')), 6000000) 
if @maxno < 6000000 and @hotelid<>'crs'
begin 
	select '实际最大档案号码小于 6000000，请检查'
	return 
end

select @hisbase = hisbase from sysdata 
if @hisbase < @maxno + 1
	update sysdata set hisbase = @maxno + 1
;

select hisbase from sysdata ; 
exec p_gds_maint_hisbase;
select hisbase from sysdata ; 


