if object_id('p_gl_lgfl') is not null
drop proc p_gl_lgfl
;
create proc p_gl_lgfl
	@entry				char(30),
	@accnt				char(10),
	@number				integer = 0
as
declare
	@lic_buy_1			varchar(255),
	@lic_buy_2			varchar(255)

if rtrim(@accnt) is null
	return 0

if @entry='master'
	begin
	select @lic_buy_1 = isnull((select value from sysoption where catalog='hotel' and item='lic_buy.1'), '')
	select @lic_buy_2 = isnull((select value from sysoption where catalog='hotel' and item='lic_buy.2'), '')
	-- ÐÂÓ¦ÊÕÕË
	if @accnt is null
		begin
		exec p_gl_lgfl_master @accnt
		exec p_gl_lgfl_ar_master @accnt
		end
	else if substring(@accnt, 1, 1) = 'A' and (charindex(',nar,', @lic_buy_1) > 0 or charindex(',nar,', @lic_buy_2) > 0)
		exec p_gl_lgfl_ar_master @accnt
	else
		exec p_gl_lgfl_master @accnt
	end
else if @entry='guest'
	exec p_gl_lgfl_guest @accnt
else if @entry='vipcard'
	exec p_gds_lgfl_vipcard @accnt
--else if @entry='meet_rmav'
--	exec p_gl_lgfl_meet_rmav @accnt, @number
else if @entry='rmsta'
	exec p_gds_lgfl_rmsta @accnt
else if @entry='rm_ooo'
	exec p_yjw_lgfl_rmooo @accnt
else if @entry='fec_def'
	exec p_gds_lgfl_fec_def @accnt
else if @entry='fec_folio'
	exec p_gds_lgfl_fec_folio @accnt
else if @entry = 'pos_reserve'
	exec p_cq_reserve_lgfl_reserve @accnt
else if @entry = 'sp_reserve'
	exec p_cq_sp_reserve_lgfl @accnt
else if @entry = 'pos_menu'
	exec p_cq_newpos_menu_lgfl @accnt
else if @entry='sc_master'
	exec p_sc_lgfl_master @accnt
else if @entry='sc_eventreservation'
	exec p_sc_lgfl_evtres @accnt
else if @entry='saleid'
   exec p_zk_lgfl_saleid @accnt
else if @entry='gzhs_rsv_plan'
   exec p_gds_lgfl_gzhs_rsv_plan @accnt

return 0
;