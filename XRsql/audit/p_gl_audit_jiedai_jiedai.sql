if exists (select * from sysobjects where name ='p_gl_audit_jiedai_jiedai' and type ='P')
	drop proc p_gl_audit_jiedai_jiedai;
create proc p_gl_audit_jiedai_jiedai
	@nar				char(1), 
	@accnt			char(10), 
	@charge			money,				-- 费用
	@credit			money,				-- 付款
	@apply			money					-- 结帐
as
declare
	@class			char(8), 
	@groupno			char(10), 
	@nt_netgst		char(8), 
	@nt_netar		char(8)
	
select @nt_netgst ='02000', @nt_netar = '03000'
-- 账号类别
if @accnt like 'A%'
	begin
	if @nar = 'T'
		select @class = b.grp from ar_master_till a, basecode b where a.accnt = @accnt and a.artag1 = b.code and b.cat = 'artag1'
	else
		select @class = b.grp from master_till a, basecode b where a.accnt = @accnt and a.artag1 = b.code and b.cat = 'artag1'
	if not exists (select 1 from jiedai where class = substring(@nt_netar, 1, 2) + @class)
		insert jiedai (class, descript, descript1, date) select substring(@nt_netar, 1, 2) + @class, descript, descript1, getdate()
			from basecode where cat = 'argrp1' and code = @class
	end
else
	begin
	select @class = class, @groupno = groupno from master_till where accnt = @accnt
	if not rtrim(@groupno) is null
		select @class = class from master_till where accnt = @groupno
	if not exists (select 1 from jiedai where class = substring(@nt_netgst, 1, 2) + @class)
		insert jiedai (class, descript, descript1, date) select substring(@nt_netgst, 1, 2) + @class, descript, descript1, getdate()
			from basecode where cat = 'mstcls' and code = @class
	end
-- 
if @accnt like 'A%' and @charge = 0
	begin
	update dairep set credit = credit + @credit, sumcre = sumcre - @credit where class = @nt_netar
	update jiedai set charge = charge + @charge, credit = credit + @credit, apply = apply + @apply where class = substring(@nt_netar, 1, 2) + @class
	update jiedai set charge = charge + @charge, credit = credit + @credit, apply = apply + @apply where class = @nt_netar
	end
else if @accnt like 'A%' and @charge != 0
	begin
	update dairep set debit = debit + @charge, sumcre = sumcre + @charge where class = @nt_netar
	update jiedai set charge = charge + @charge, credit = credit + @credit, apply = apply + @apply where class = substring(@nt_netar, 1, 2) + @class
	update jiedai set charge = charge + @charge, credit = credit + @credit, apply = apply + @apply where class = @nt_netar
	end
else if not @accnt like 'A%' and @charge = 0
	begin
	update dairep set credit = credit + @credit, sumcre = sumcre - @credit where class = @nt_netgst
	update jiedai set charge = charge + @charge, credit = credit + @credit, apply = apply + @apply where class = substring(@nt_netgst, 1, 2) + @class
	update jiedai set charge = charge + @charge, credit = credit + @credit, apply = apply + @apply where class = @nt_netgst
	end
else if not @accnt like 'A%' and @charge != 0
	begin
	update dairep set debit = debit + @charge, sumcre = sumcre + @charge where class = @nt_netgst
	update jiedai set charge = charge + @charge, credit = credit + @credit, apply = apply + @apply where class = substring(@nt_netgst, 1, 2) + @class
	update jiedai set charge = charge + @charge, credit = credit + @credit, apply = apply + @apply where class = @nt_netgst
	end
return 0
;
