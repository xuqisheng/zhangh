//================================================================================
// 	相关人信息
//================================================================================
if  exists(select * from sysobjects where name = "p_gds_accnt_argst_list")
	drop proc p_gds_accnt_argst_list;
create proc p_gds_accnt_argst_list
	@no				char(7)
as
create table #list
(
	no			char(7),
	name1		varchar(60),
	accnt		char(10),
	name2		varchar(60),
	tag1		char(1),
	tag2		char(1),
	tag3		char(1),
	tag4		char(1),
	tag5		char(1)
)

declare
	@class		char(1),
	@araccnt1	char(7),
	@araccnt2	char(7),
	@lic_buy_1	varchar(255),
	@lic_buy_2	varchar(255)

------------------
-- @no = AR 帐
------------------
select @lic_buy_1 = isnull((select value from sysoption where catalog='hotel' and item='lic_buy.1'), '')
select @lic_buy_2 = isnull((select value from sysoption where catalog='hotel' and item='lic_buy.2'), '')
if substring(@no,1,1)='A' and (charindex(',nar,', @lic_buy_1) > 0 or charindex(',nar,', @lic_buy_2) > 0)
	insert #list select b.no, b.name, c.accnt, d.name, a.tag1, a.tag2, a.tag3, a.tag4, a.tag5 
		from argst a, guest b, ar_master c, guest d
		where a.no=b.no and a.accnt=c.accnt and c.haccnt=d.no and a.accnt=@no
else if substring(@no,1,1)='A'  
	insert #list select b.no, b.name, c.accnt, d.name, a.tag1, a.tag2, a.tag3, a.tag4, a.tag5 
		from argst a, guest b, master c, guest d
		where a.no=b.no and a.accnt=c.accnt and c.haccnt=d.no and a.accnt=@no
else 
	begin
	select @class=class, @araccnt1=araccnt1, @araccnt2=araccnt2 from guest where no=@no
	if @@rowcount = 0 
		goto gout

	if @class <> 'F'
		begin
		------------------
		-- @no = 单位
		------------------
		insert #list select b.no, b.name, c.no, c.name, a.tag1, a.tag2, a.tag3, a.tag4, a.tag5 
			from argst a, guest b, guest c
			where a.no=b.no and a.accnt=c.no and a.accnt=@no
		if rtrim(@araccnt1) is not null
			insert #list select b.no, b.name, c.accnt, d.name, a.tag1, a.tag2, a.tag3, a.tag4, a.tag5 
				from argst a, guest b, master c, guest d
				where a.no=b.no and a.accnt=c.accnt and c.haccnt=d.no and a.accnt=@araccnt1
		if rtrim(@araccnt2) is not null
			insert #list select b.no, b.name, c.accnt, d.name, a.tag1, a.tag2, a.tag3, a.tag4, a.tag5 
				from argst a, guest b, master c, guest d
				where a.no=b.no and a.accnt=c.accnt and c.haccnt=d.no and a.accnt=@araccnt2
		end
	else					
		begin
		------------------
		-- @no = 宾客
		------------------
		-- ar
		insert #list select b.no, b.name, c.accnt, d.name, a.tag1, a.tag2, a.tag3, a.tag4, a.tag5 
			from argst a, guest b, master c, guest d
			where a.no=@no and a.no=b.no and a.accnt=c.accnt and c.haccnt=d.no
		-- cusno
		insert #list select b.no, b.name, c.no, c.name, a.tag1, a.tag2, a.tag3, a.tag4, a.tag5 
			from argst a, guest b, guest c
			where a.no=@no and a.no=b.no and a.accnt=c.no
		end
end

gout:
select no,name1,accnt,name2,tag1,tag2,tag3,tag4,tag5 from #list order by no

return 0
;
