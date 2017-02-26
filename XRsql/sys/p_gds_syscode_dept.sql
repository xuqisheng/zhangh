
if exists(select 1 from sysobjects where name = 'p_gds_syscode_dept' and type = 'P')
	drop proc p_gds_syscode_dept;
create proc p_gds_syscode_dept
	@entry		varchar(10),
	@appid		char(1) = '2',
	@empno		char(10) = 'FOX'
as
----------------------------------------------------------------------------------------------
--	代码树
--	
--	entry = FOX 表示树的最底部 
--	empno 暂时不起到作用 
----------------------------------------------------------------------------------------------
declare
	@lic_buy_1			varchar(255),
	@lic_buy_2			varchar(255)
select @lic_buy_1 = isnull((select value from sysoption where catalog='hotel' and item='lic_buy.1'), '')
select @lic_buy_2 = isnull((select value from sysoption where catalog='hotel' and item='lic_buy.2'), '')

select code, descript,descript1  from syscode_maint  
	where charindex(@appid, appid)>0 
			and (@empno='FOX' or rtrim(lic) is null  
					or (rtrim(lic) is not null and (charindex(','+rtrim(lic)+',',@lic_buy_1)>0 or charindex(','+rtrim(lic)+',',@lic_buy_2)>0 )) 
					)
			and ((datalength(rtrim(code))= 1 and @entry='FOX')
					or (code like @entry+'%' and datalength(rtrim(code))=datalength(@entry)+1)
					)
	order by code asc

return;
