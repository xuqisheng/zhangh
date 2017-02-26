drop procedure p_cq_sp_get_menu;
create procedure p_cq_sp_get_menu
			@place		char(11),
			@menu			char(10)
			
as
declare
			@places		char(255),
			@menus		char(255),
			@ls_place	char(11),
			@ls_menu		char(10),
			@menu1		char(10),
			@sta			char(1),
			@count1		int,
			@count2		int
	
update sp_plaav set sp_menu = '' where sp_menu is null
if @place <> '' and @place is not null 
	begin
	select @menu = sp_menu,@menu1 = menu1  from sp_plaav where menu+rtrim(convert(char,inumber)) = @place
	if @menu  <> '' and @menu is not null
		select @sta  = sta from sp_menu where menu = @menu
	if @sta is null
		select @sta = ''
	if @menu is null
		select @menu = ''
	if charindex(@sta,'37') = 0		--非结帐状态,取所有有联单的情况
		begin
		declare c_place cursor for 
			select menu + rtrim(convert(char,inumber)),sp_menu from sp_plaav where menu1 = @menu1 and sta <> 'X' and 
				(sp_menu = '' or sp_menu is null)
			union
			select menu + rtrim(convert(char,inumber)),sp_menu from sp_plaav where menu1 = @menu1 and sta <> 'X' and 
				sp_menu <> '' and  sp_menu is not null and sp_menu in (select menu from sp_menu where charindex(sta,'37') = 0)
			
		end
	else		--结帐状态下只取与该单关联的单子
		begin

		declare c_place cursor for 
			select menu + rtrim(convert(char,inumber)),sp_menu from sp_plaav where  sta <> 'X' 
				and (sp_menu = @menu or sp_menu = (select pcrec from sp_menu where menu = @menu and pcrec <> '' and pcrec is not null))
		end

	open c_place
	fetch c_place into @ls_place,@ls_menu
	while @@sqlstatus = 0
		begin
		if @ls_place <> '' and @ls_place is not null and charindex(@ls_place,@places) = 0 
			select @places = @places + @ls_place + '#'
		if @ls_menu <> '' and @ls_menu is not null and charindex(@ls_menu,@menus) = 0 
			select @menus = @menus + @ls_menu + '#'
		fetch c_place into @ls_place,@ls_menu
		end
	close c_place
	deallocate cursor c_place	
	end
if @menu <> '' and @menu is not null
	begin
	select @sta = sta from sp_menu where menu = @menu
	if  charindex(@sta,'37') = 0
		declare c_place2 cursor for 
			select menu + rtrim(convert(char,inumber)),sp_menu from sp_plaav where  sta <> 'X' 
					and menu1 in (select menu1 from sp_plaav where sp_menu = @menu)
					and (sp_menu = '' or sp_menu is  null or sp_menu in (select menu from sp_menu where charindex(sta,'37') = 0))
	else
		declare c_place2 cursor for 
			select menu + rtrim(convert(char,inumber)),sp_menu from sp_plaav where  sta <> 'X' 
					and (sp_menu = @menu or sp_menu = (select pcrec from sp_menu where menu = @menu and pcrec <> '' and pcrec is not null))
	open c_place2
	fetch c_place2 into @ls_place,@ls_menu
	while @@sqlstatus = 0 
		begin
		if @ls_place <> '' and @ls_place is not null and charindex(@ls_place,@places) = 0 
			select @places = @places + @ls_place + '#'
		if @ls_menu <> '' and @ls_menu is not null and charindex(@ls_menu,@menus) = 0 
			select @menus = @menus + @ls_menu + '#'
		fetch c_place2 into @ls_place,@ls_menu
		end
	close c_place2
	deallocate cursor c_place2	
	end 

select @count1 = count(1) from sp_menu where charindex(menu,@menus) > 0 and sta = '3'
select @count2 = count(1) from sp_menu where charindex(menu,@menus) > 0 and charindex(sta,'37') = 0

if (select count(distinct menu1) from sp_plaav where charindex(menu+rtrim(convert(char,inumber)),@places) > 0) > 1
	update sp_plaav set menu1 = substring(@places,1,10) where charindex(menu+rtrim(convert(char,inumber)),@places) > 0

select @places,@menus
;
