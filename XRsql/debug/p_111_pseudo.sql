
// ´´½¨ PM / PY ·¿ºÅ 
drop proc p_111_pseudo;
create proc p_111_pseudo
	@type			char(5),
	@begin		int,
	@end			int,
	@hall			char(1)='',
	@flr			char(3)='',
	@rmreg		char(3)=''
as
declare	@pos		int,
			@roomno	char(5),
			@date		datetime,
			@tag		char(1)	

update sysoption set value='T' where catalog='hotel' and item='proom_inst' 

if rtrim(@hall) is null
	select @hall=min(code) from basecode where cat='hall'
if rtrim(@flr) is null
	select @flr=min(code) from flrcode
if rtrim(@rmreg) is null
	select @rmreg=min(code) from basecode where cat='hsregion'
select @tag=tag from typim where type=@type 

-- 
select @pos = @begin, @date=getdate()
while @pos <= @end
begin
	select @roomno = rtrim(ltrim(convert(char(5), @pos)))
	INSERT INTO rmsta VALUES (
		@roomno,
		@roomno,
		@hall,		-- hall
		@flr,			-- flr
		@rmreg,		-- rm reg 
		@type,		-- type 
		@tag,		-- tag 
		'V',		-- ocsta
		'R',		-- old sta 
		'R',		-- sta 
		'',		
		2,
		2,
		'F',
		'',
		0,
		'',
		'N',
		'',
		NULL,
		NULL,
		NULL,
		NULL,
		0,
		0,
		'',
		'F',
		NULL,
		0,
		0,
		0,
		0,
		0,
		'',
		'',
		'',
		'',
		0,
		0,
		0,
		0,
		'',
		0,
		'FOX',
		@date,
			1)

	select @pos = @pos + 1
end

return 
;

//delete rmsta where  type='PM' or type='PY'; 
//exec p_111_pseudo  'PM', 9001, 9300;
//exec p_111_pseudo  'PY', 8001, 8100;
//select * from rmsta where type='PM' or type='PY' order by roomno ;


