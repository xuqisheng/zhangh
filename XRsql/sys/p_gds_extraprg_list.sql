//------------------------------------------------------------------------------
//  Õ‚≤ø≥Ã–Ú
//------------------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'p_gds_extraprg_list' and type='P')
	drop proc p_gds_extraprg_list
;
create proc  p_gds_extraprg_list 
	@langid		int = 0
as

if @langid = 0
	select code,descript,command,sequence,bmp from extraprg  order by sequence, code
else
	select code,descript1,command,sequence,bmp from extraprg  order by sequence, code

return 0
;
