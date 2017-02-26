if exists (select 1 from sysobjects where name = 'p_foxhis_db_hide' and type='P')
	drop proc p_foxhis_db_hide
;
create proc  p_foxhis_db_hide 
	@appid		char(1),
	@modu_id		char(2),
	@code			varchar(30),
	@langid		int = 0
as
-------------------------------------------------------------------------------
--  Êý¾Ý¿â¼õ·Ê 
-------------------------------------------------------------------------------
select @appid 		= isnull(rtrim(@appid), '')
select @modu_id 	= isnull(rtrim(@modu_id), '')

select * into #gout from toolbar where 1=2
insert #gout select *,'--' from toolbar 
	where appid='-' and (cat='' or @appid+@modu_id like cat+'%')
		and @code = code

declare	@row	int
select @row = count(1) from #gout 
while @row < 6 
begin
	insert #gout (appid,cat,code,descript,descript1,wtype,auth,source,parm,multi,lic,sequence,hotkey) 
		values('-', '', '', '', '', '', '', '', '', '', '', 99999,'--')
	select @row = @row + 1
end

if @langid = 0
begin
	update #gout set hotkey=isnull(substring(descript,charindex('&',descript),2), '') where charindex('&',descript) > 0
	select descript,wtype,auth,source,parm,multi,lic,hotkey from #gout order by sequence 
end
else
begin
	update #gout set hotkey=isnull(substring(descript1,charindex('&',descript1),2), '') where charindex('&',descript1) > 0
	select descript1,wtype,auth,source,parm,multi,lic,hotkey from #gout order by sequence 
end

return 0
;
