if exists(select 1 from sysobjects where name ='p_cyj_pos_adj_menudata' and type ='P')
	drop  proc p_cyj_pos_adj_menudata ;

create proc p_cyj_pos_adj_menudata 
	@menus		char(255)
--
--		对一个餐单重新计算服务、税、折扣等对应数据
--
as
declare	
	@menu 		char(10)

if ltrim(rtrim(@menus)) is null         
	begin        -- 处理所有餐单
	update pos_dish set amount = (select sum(c.tax) from pos_dish c where c.menu = b.menu and rtrim(ltrim(c.code))<='X' and charindex(c.sta,'03579A')>0 ) 
		from pos_dish b where rtrim(ltrim(b.code)) = 'Y'
	update pos_dish set amount = (select sum(c.srv) from pos_dish c where c.menu = b.menu and rtrim(ltrim(c.code))<='X' and charindex(c.sta,'03579A')>0 ) 
		from pos_dish b where rtrim(ltrim(b.code)) = 'Z'
	update pos_menu set tax = (select sum(c.tax) from pos_dish c where c.menu = b.menu and rtrim(ltrim(c.code))<='X' and charindex(c.sta,'03579A')>0 ) 
		from pos_menu b 
	update pos_menu set srv = (select sum(c.srv) from pos_dish c where c.menu = b.menu and rtrim(ltrim(c.code))<='X' and charindex(c.sta,'03579A')>0 ) 
		from pos_menu b 
	update pos_menu set dsc = (select sum(c.dsc) from pos_dish c where c.menu = b.menu and rtrim(ltrim(c.code))<='X' and charindex(c.sta,'03579A')>0 ) 
		from pos_menu b 
	end
else
	begin        -- 针对一个餐单
	if not exists(select 1 from pos_menu where charindex(menu, @menus)=0)
		return
	update pos_dish set amount = (select sum(tax) from pos_dish where menu = b.menu and rtrim(ltrim(code))<='X' and charindex(sta,'03579A')>0 ) 
		from pos_dish b where charindex(b.menu, @menus)>0 and rtrim(ltrim(b.code)) = 'Y'
	update pos_dish set amount = (select sum(srv) from pos_dish where menu = b.menu and rtrim(ltrim(code))<='X' and charindex(sta,'03579A')>0 ) 
		from pos_dish b where charindex(b.menu, @menus)>0 and rtrim(ltrim(b.code)) = 'Z'
	update pos_menu set tax = (select sum(tax) from pos_dish where menu = b.menu and rtrim(ltrim(code))<='X' and charindex(sta,'03579A')>0 ) 
		from pos_menu b where charindex(b.menu, @menus)>0
	update pos_menu set srv = (select sum(srv) from pos_dish where menu = b.menu and rtrim(ltrim(code))<='X' and charindex(sta,'03579A')>0 ) 
		from pos_menu b where charindex(b.menu, @menus)>0
	update pos_menu set dsc = (select sum(dsc) from pos_dish where menu = b.menu and rtrim(ltrim(code))<='X' and charindex(sta,'03579A')>0 ) 
		from pos_menu b where charindex(b.menu, @menus)>0
	end	
;