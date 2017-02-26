drop  proc p_cyj_pos_pcrec_adj;
create proc p_cyj_pos_pcrec_adj
as
-- 调整联单号，以防止联单号错误
declare
	@bdate		datetime,
	@menu			char(10),
	@pcrec		char(10)

	select @bdate = bdate from sysdata

-- 调整pos_tmenu
declare c_cur cursor for select a.pcrec  from pos_tmenu a , pos_tmenu b where a.pcrec>' ' and  a.pcrec = b.menu and b.pcrec<>b.menu
open c_cur
fetch c_cur into @pcrec
while @@sqlstatus = 0 
	begin
	select @menu = min(menu) from pos_tmenu where pcrec = @pcrec
	update pos_tmenu set pcrec = @menu  where pcrec = @pcrec
	fetch c_cur into @pcrec
	end
close c_cur
deallocate cursor c_cur

-- 调整pos_hmenu
declare c_cur_hmenu cursor for select a.pcrec  from pos_hmenu a , pos_hmenu b where a.pcrec>' ' and  a.pcrec = b.menu and b.pcrec<>b.menu and a.bdate=@bdate and b.bdate=@bdate
open c_cur_hmenu
fetch c_cur_hmenu into @pcrec
while @@sqlstatus = 0 
	begin
	select @menu = min(menu) from pos_hmenu where pcrec = @pcrec
	update pos_hmenu set pcrec = @menu  where pcrec = @pcrec
	fetch c_cur_hmenu into @pcrec
	end
close c_cur_hmenu
deallocate cursor c_cur_hmenu

;

