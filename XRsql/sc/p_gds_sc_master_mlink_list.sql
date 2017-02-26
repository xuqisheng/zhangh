if exists(select 1 from sysobjects where name = "p_gds_sc_master_mlink_list")
	drop proc p_gds_sc_master_mlink_list;
create proc p_gds_sc_master_mlink_list
	@accnt		char(10)		-- block # 
as
----------------------------------------------------------------------------------------------
--		产生针对某个 block 关联的主单列表  
--			
--			包括上层、本层、下层   
--			应该包含非有效状态 ? 
--			兼顾当前、历史
----------------------------------------------------------------------------------------------- 

create table #goutput (
	accnt			char(10)						not null,
	id				int			default 0	not null,
	master		char(10)						not null,
	saccnt		char(10)						not null,
	pcrec			char(10)						not null,
	groupno		char(10)						not null,
	class			char(1)						not null,
	haccnt		char(7)						not null,
	sta			char(1)						not null,
	name			varchar(60)	default '' 	not null,
	type			char(5)						not null,
	rmnum			int			default 0	not null,
	roomno		char(5)		default ''	not null,
	rate			money			default 0	not null,
	arr			datetime						null,
	dep			datetime						null,
	flag			int			default 0	not null,		-- 关系标记 1=pri level, 2=equal level, 3=next level 
	sele			char(1)		default 'F'	not null,		-- ? 
	bal			money			default 0	not null,		-- 余额
	remark		varchar(100)	default '' 	null,
	packages		varchar(50)	default '' 	null,
	resno			char(10)		default '' 	null,
	gstno			int			default 0 	null,
	accredit		money			default 0	not null			-- 信用
)

declare	@parentblock			char(10),		-- 父亲 block # 
			@his						char(1)			-- 进入历史 ？ 

select @parentblock = blkcode from sc_master where accnt=@accnt
if @@rowcount=0 
begin
	select @parentblock = blkcode from sc_hmaster where accnt=@accnt   -- block 主单总是最后进入历史 ？
	if @@rowcount=0 
		goto gout
	else
		select @his='T' 
end
else
	select @his='F' 

-- 父母 : level = 1 
if rtrim(@parentblock) is not null
begin
	if @his='F'  -- 当前主单
	begin
		insert #goutput 
			select b.accnt,0,b.master,b.saccnt,b.pcrec,b.groupno,b.class,b.haccnt,b.sta,
				c.name,b.type,b.rmnum,b.roomno,b.setrate,b.arr,b.dep,1,'F',b.charge-b.credit,b.ref,b.packages,b.resno,b.gstno,b.accredit
			 from master b, guest c
				where b.haccnt=c.no and b.accnt=@parentblock
		insert #goutput 
			select b.accnt,0,b.master,b.saccnt,b.pcrec,'',b.class,b.haccnt,b.sta,
				c.name,b.type,b.rmnum,b.roomno,b.setrate,b.arr,b.dep,1,'F',b.charge-b.credit,b.ref,b.packages,b.resno,b.gstno,b.accredit
			 from sc_master b, guest c
				where b.haccnt=c.no and b.accnt=@parentblock
	end 

	-- 历史主单 
	insert #goutput 
		select b.accnt,0,b.master,b.saccnt,b.pcrec,b.groupno,b.class,b.haccnt,b.sta,
			c.name,b.type,b.rmnum,b.roomno,b.setrate,b.arr,b.dep,1,'F',b.charge-b.credit,b.ref,b.packages,b.resno,b.gstno,b.accredit
		 from hmaster b, guest c
			where b.haccnt=c.no and b.accnt=@parentblock
	insert #goutput 
		select b.accnt,0,b.master,b.saccnt,b.pcrec,'',b.class,b.haccnt,b.sta,
			c.name,b.type,b.rmnum,b.roomno,b.setrate,b.arr,b.dep,1,'F',b.charge-b.credit,b.ref,b.packages,b.resno,b.gstno,b.accredit
		 from sc_hmaster b, guest c
			where b.haccnt=c.no and b.accnt=@parentblock
end

-- 兄弟姐妹 : level = 2 
if rtrim(@parentblock) is not null
begin
	if @his='F'  -- 当前主单
	begin
		insert #goutput 
			select b.accnt,0,b.master,b.saccnt,b.pcrec,b.groupno,b.class,b.haccnt,b.sta,
				c.name,b.type,b.rmnum,b.roomno,b.setrate,b.arr,b.dep,2,'F',b.charge-b.credit,b.ref,b.packages,b.resno,b.gstno,b.accredit
			 from master b, guest c
				where b.haccnt=c.no and b.blkcode=@parentblock
		insert #goutput 
			select b.accnt,0,b.master,b.saccnt,b.pcrec,'',b.class,b.haccnt,b.sta,
				c.name,b.type,b.rmnum,b.roomno,b.setrate,b.arr,b.dep,2,'F',b.charge-b.credit,b.ref,b.packages,b.resno,b.gstno,b.accredit
			 from sc_master b, guest c
				where b.haccnt=c.no and b.blkcode=@parentblock
	end

	-- 历史主单 
	insert #goutput 
		select b.accnt,0,b.master,b.saccnt,b.pcrec,b.groupno,b.class,b.haccnt,b.sta,
			c.name,b.type,b.rmnum,b.roomno,b.setrate,b.arr,b.dep,2,'F',b.charge-b.credit,b.ref,b.packages,b.resno,b.gstno,b.accredit
		 from hmaster b, guest c
			where b.haccnt=c.no and b.blkcode=@parentblock
	insert #goutput 
		select b.accnt,0,b.master,b.saccnt,b.pcrec,'',b.class,b.haccnt,b.sta,
			c.name,b.type,b.rmnum,b.roomno,b.setrate,b.arr,b.dep,2,'F',b.charge-b.credit,b.ref,b.packages,b.resno,b.gstno,b.accredit
		 from sc_hmaster b, guest c
			where b.haccnt=c.no and b.blkcode=@parentblock
end


-- 子女 : level = 3 
if @his='F'  -- 当前主单
begin
	insert #goutput 
		select b.accnt,0,b.master,b.saccnt,b.pcrec,b.groupno,b.class,b.haccnt,b.sta,
			c.name,b.type,b.rmnum,b.roomno,b.setrate,b.arr,b.dep,4,'F',b.charge-b.credit,b.ref,b.packages,b.resno,b.gstno,b.accredit
		 from master b, guest c
			where b.haccnt=c.no and b.blkcode=@accnt
	insert #goutput 
		select b.accnt,0,b.master,b.saccnt,b.pcrec,'',b.class,b.haccnt,b.sta,
			c.name,b.type,b.rmnum,b.roomno,b.setrate,b.arr,b.dep,4,'F',b.charge-b.credit,b.ref,b.packages,b.resno,b.gstno,b.accredit
		 from sc_master b, guest c
			where b.haccnt=c.no and b.blkcode=@accnt
end 
-- 历史主单 
insert #goutput 
	select b.accnt,0,b.master,b.saccnt,b.pcrec,b.groupno,b.class,b.haccnt,b.sta,
		c.name,b.type,b.rmnum,b.roomno,b.setrate,b.arr,b.dep,4,'F',b.charge-b.credit,b.ref,b.packages,b.resno,b.gstno,b.accredit
	 from hmaster b, guest c
		where b.haccnt=c.no and b.blkcode=@accnt
insert #goutput 
	select b.accnt,0,b.master,b.saccnt,b.pcrec,'',b.class,b.haccnt,b.sta,
		c.name,b.type,b.rmnum,b.roomno,b.setrate,b.arr,b.dep,4,'F',b.charge-b.credit,b.ref,b.packages,b.resno,b.gstno,b.accredit
	 from sc_hmaster b, guest c
		where b.haccnt=c.no and b.blkcode=@accnt

gout: 
-- filter
-- delete #goutput where sta in ('X', 'N', 'W')

--
update #goutput set flag=3, sele='T' where accnt=@accnt  -- 选中自己 

-- adjust --> grp amount columns
update #goutput set bal=0, accredit=0 
	where #goutput.accnt like '[GM]%' 
		and exists (select 1 from #goutput a where #goutput.accnt=a.accnt and a.type<#goutput.type)

select * from #goutput 
-- select a.* from #goutput a, basecode b where a.sta=b.code and b.cat='mststa' order by a.flag, b.sequence

return 0
;

