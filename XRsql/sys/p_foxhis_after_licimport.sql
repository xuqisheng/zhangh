if exists (select 1 from sysobjects where name = 'p_foxhis_after_licimport' and type = 'P')
   drop procedure p_foxhis_after_licimport
; 
--------------------------------------------------------------------------------
-- do something after license imoport
--------------------------------------------------------------------------------
create procedure p_foxhis_after_licimport
as	
begin 
	declare @version varchar(32)

	-- 在这里加入证书导入后的处理
	
	select @version = rtrim(ltrim(value)) from sysoption where catalog='hotel' and item='lic_version'

	-----------------------------------------------
	-- 1.系统颜色修改
	-----------------------------------------------
	-- X5.版本
	if charindex('X5.',@version) = 1 
	begin 
		update sysoption set value ='31907036' where catalog = "hotel" and item = "color_datawindow_color" 

		update sysoption set value ='15780518' where catalog = "hotel" and item = "color_header_background" 
		update sysoption set value ='8388608' where catalog = "hotel" and item = "color_header_color" 

		update sysoption set value ='33222896' where catalog = "hotel" and item = "color_detail_background" 
		update sysoption set value ='0' where catalog = "hotel" and item = "color_detail_color" 

		update sysoption set value ='33222896' where catalog = "hotel" and item = "color_summary_background" 
		update sysoption set value ='0' where catalog = "hotel" and item = "color_summary_color" 

		update sysoption set value ='33222896' where catalog = "hotel" and item = "color_footer_background" 
		update sysoption set value ='0' where catalog = "hotel" and item = "color_footer_color" 
	end
	-- X3.版本
	if charindex('X3.',@version) = 1 
	begin 
		update sysoption set value ='13683936' where catalog = "hotel" and item = "color_datawindow_color" 

		update sysoption set value ='6304856' where catalog = "hotel" and item = "color_header_background" 
		update sysoption set value ='16771327' where catalog = "hotel" and item = "color_header_color" 

		update sysoption set value ='16771327' where catalog = "hotel" and item = "color_detail_background" 
		update sysoption set value ='0' where catalog = "hotel" and item = "color_detail_color" 

		update sysoption set value ='16771327' where catalog = "hotel" and item = "color_summary_background" 
		update sysoption set value ='0' where catalog = "hotel" and item = "color_summary_color" 

		update sysoption set value ='16771327' where catalog = "hotel" and item = "color_footer_background" 
		update sysoption set value ='0' where catalog = "hotel" and item = "color_footer_color" 
	end
	
	-----------------------------------------------
	-- 2. 关于启用何种 ar 的影响
	-----------------------------------------------
	declare	@lic1 varchar(255), @lic2 varchar(255)
	select @lic1 = isnull((select value from sysoption where catalog='hotel' and item='lic_buy.1'), '')
	select @lic2 = isnull((select value from sysoption where catalog='hotel' and item='lic_buy.2'), '')
	if charindex(',oar,', @lic1)>0 or charindex(',oar,', @lic2)>0 
		begin
		update pccode set deptno3='', deptno6='' where argcode>='9' and charindex('TOR',deptno2)>0
		update auditprg set callform = 'p_gl_audit_jiedai @ret out,@msg out' where prgname = 'jiedai'
		update adtrep set callform = 'd_gl_audit_put_jiedai1' where callform like 'd_gl_audit_put_jiedai%'
		end
	else
		begin
		update pccode set deptno3='', deptno6='99' where argcode>='9' and charindex('TOR',deptno2)>0
		update auditprg set callform = 'p_gl_audit_jiedai_nar @ret out,@msg out' where prgname = 'jiedai'
		update adtrep set callform = 'd_gl_audit_put_jiedai_nar1' where callform like 'd_gl_audit_put_jiedai%'
		end
end
;

