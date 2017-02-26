
if  exists(select * from sysobjects where name = "p_gds_master_link_list")
	 drop proc p_gds_master_link_list;
create proc p_gds_master_link_list
   @accnt		char(10)
as
-----------------------------------------------------------------------------------------------
--	p_gds_master_link_list: 宾客主单关联显示，同时显示所有客房资源
--应该包含非有效状态
--兼顾当前、历史
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
	flag			int			default 0	not null,		-- 关系标记 0 - 6
	sele			char(1)		default 'F'	not null,
	bal			money			default 0	not null,		-- 余额
	remark		varchar(100)	default '' 	null,
	packages		varchar(50)	default '' 	null,
	resno			char(10)		default '' 	null,
	gstno			int			default 0 	null,
	accredit		money			default 0	not null			-- 信用
)

declare		@class		char(1),
				@saccnt 		char(10),
				@master		char(10),
				@pcrec		char(10),
				@groupno		char(10),
				@resno		char(10),
				@grpsta		char(1),
				@his			char(1)


select @class=class, @saccnt=saccnt, @master=master, @groupno=groupno, @pcrec=pcrec, @resno=resno 
	from master where accnt=@accnt
if @@rowcount=0 
begin
	select @class=class, @saccnt=saccnt, @master=master, @groupno=groupno, @pcrec=pcrec, @resno=resno 
		from hmaster where accnt=@accnt
	if @@rowcount=0
	begin
		select *,0,0,0,0,0 from #goutput 
		return 0
	end
	select @his='T'
end
else
	select @his='F'

--if @class not in ('F', 'G', 'M')
--begin
--	select *,0,0,0,0,0 from #goutput 
--	return 0
--end

----------------------------------------
--	Current
----------------------------------------
if @his='F'
begin
	if @class='F' or @class='C' 
	begin
		-- himself (flag = 0)
		insert #goutput 
			select b.accnt,0,b.master,b.saccnt,b.pcrec,b.groupno,b.class,b.haccnt,b.sta,
				c.name,b.type,b.rmnum,b.roomno,b.setrate,b.arr,b.dep,0,'T',b.charge-b.credit,b.ref,b.packages,b.resno,b.gstno,b.accredit
			 from master b, guest c
				where b.haccnt=c.no and b.accnt=@accnt
	
		-- master (flag = 1)
		if @master<>''
		insert #goutput 
			select b.accnt,0,b.master,b.saccnt,b.pcrec,b.groupno,b.class,b.haccnt,b.sta,
				c.name,b.type,b.rmnum,b.roomno,b.setrate,b.arr,b.dep,1,'F',b.charge-b.credit,b.ref,b.packages,b.resno,b.gstno,b.accredit
			 from master b, guest c
				where b.haccnt=c.no and b.master=@master
					and b.accnt not in (select accnt from #goutput)
	
		-- saccnt (flag = 2)
		if @saccnt <> ''
		insert #goutput 
			select b.accnt,0,b.master,b.saccnt,b.pcrec,b.groupno,b.class,b.haccnt,b.sta,
				c.name,b.type,b.rmnum,b.roomno,b.setrate,b.arr,b.dep,2,'F',b.charge-b.credit,b.ref,b.packages,b.resno,b.gstno,b.accredit
			 from master b, guest c
				where b.haccnt=c.no and b.saccnt=@saccnt
					and b.accnt not in (select accnt from #goutput)
	
		-- pcrec (flag = 3)
		if @pcrec <> ''
		insert #goutput 
			select b.accnt,0,b.master,b.saccnt,b.pcrec,b.groupno,b.class,b.haccnt,b.sta,
				c.name,b.type,b.rmnum,b.roomno,b.setrate,b.arr,b.dep,3,'F',b.charge-b.credit,b.ref,b.packages,b.resno,b.gstno,b.accredit
			 from master b, guest c
				where b.haccnt=c.no and b.pcrec=@pcrec
					and b.accnt not in (select accnt from #goutput)
	
		-- resno (flag = 4)
--		if @resno <> ''
--		insert #goutput 
--			select b.accnt,0,b.master,b.saccnt,b.pcrec,b.groupno,b.class,b.haccnt,b.sta,
--				c.name,b.type,b.rmnum,b.roomno,b.setrate,b.arr,b.dep,4,'F',b.charge-b.credit,b.ref,b.packages,b.resno,b.gstno,b.accredit
--			 from master b, guest c
--				where b.haccnt=c.no and b.resno=@resno
--					and b.accnt not in (select accnt from #goutput)
		
		if @groupno<>''
		begin
			select @grpsta = sta from master where accnt = @groupno
	
			insert #goutput  -- other member of the group (flag = 5)
				select b.accnt,0,b.master,b.saccnt,b.pcrec,b.groupno,b.class,b.haccnt,b.sta,
					c.name,b.type,b.rmnum,b.roomno,b.setrate,b.arr,b.dep,5,'F',b.charge-b.credit,b.ref,b.packages,b.resno,b.gstno,b.accredit
				 from master b, guest c
					where b.haccnt=c.no and b.groupno=@groupno
						and b.accnt not in (select accnt from #goutput)
	
			-- group master (flag = 6)
			if charindex(@grpsta, 'RICG')>0 and exists(select 1 from rsvsrc where accnt=@groupno and blkmark<>'T' and type<>'PM')
				insert #goutput 
					select a.accnt,a.id,b.master,a.saccnt,b.pcrec,b.groupno,b.class,b.haccnt,'R',
						c.name,a.type,a.quantity,a.roomno,a.rate,a.arr,a.dep,6,'F',b.charge-b.credit,a.remark,a.packages,b.resno,a.gstno,b.accredit -- yjw 取rsvsrc的package
					 from rsvsrc a, master b, guest c
						where a.accnt=b.accnt and b.haccnt=c.no and a.blkmark<>'T' and a.type<>'PM' 
							and b.accnt=@groupno and a.accnt not in (select accnt from #goutput)
			else
				insert #goutput
					select b.accnt,0,b.master,b.saccnt,b.pcrec,b.groupno,b.class,b.haccnt,b.sta,
						c.name,b.type,b.rmnum,b.roomno,b.setrate,b.arr,b.dep,6,'F',b.charge-b.credit,b.ref,b.packages,b.resno,b.gstno,b.accredit
					 from master b, guest c
						where b.haccnt=c.no and b.accnt=@groupno
							and b.accnt not in (select accnt from #goutput)
		end
	end
	else			-- 团体会议
	begin
		select @grpsta = sta from master where accnt = @accnt
		-- himself (flag = 0)
--		if charindex(@grpsta, 'RICG')>0 and exists(select 1 from rsvsrc where accnt=@accnt and blkmark<>'T')
			insert #goutput 
				select a.accnt,a.id,b.master,a.saccnt,b.pcrec,b.groupno,b.class,b.haccnt,'R',
					c.name,a.type,a.quantity,a.roomno,a.rate,a.arr,a.dep,0,'T',0,a.remark,a.packages,b.resno,a.gstno,0 -- yjw 取rsvsrc的package
				 from rsvsrc a, master b, guest c
					where a.accnt=b.accnt and b.haccnt=c.no and b.accnt=@accnt and a.blkmark<>'T' and a.type<>'PM'
--		else
			insert #goutput
				select b.accnt,0,b.master,b.saccnt,b.pcrec,b.groupno,b.class,b.haccnt,b.sta,
					c.name,b.type,b.rmnum,b.roomno,b.setrate,b.arr,b.dep,0,'T',b.charge-b.credit,b.ref,b.packages,b.resno,b.gstno,b.accredit
				 from master b, guest c
					where b.haccnt=c.no and b.accnt=@accnt
	
		-- pcrec (flag = 3 : 排除自己的成员)
		if @pcrec <> ''
		insert #goutput 
			select b.accnt,0,b.master,b.saccnt,b.pcrec,b.groupno,b.class,b.haccnt,b.sta,
				c.name,b.type,b.rmnum,b.roomno,b.setrate,b.arr,b.dep,3,'F',b.charge-b.credit,b.ref,b.packages,b.resno,b.gstno,b.accredit
			 from master b, guest c
				where b.haccnt=c.no and b.pcrec=@pcrec and b.groupno<>@accnt
					and b.accnt not in (select accnt from #goutput)
	
		-- member  (flag = 5)
		insert #goutput 
			select b.accnt,0,b.master,b.saccnt,b.pcrec,b.groupno,b.class,b.haccnt,b.sta,
				c.name,b.type,b.rmnum,b.roomno,b.setrate,b.arr,b.dep,5,'F',b.charge-b.credit,b.ref,b.packages,b.resno,b.gstno,b.accredit
			 from master b, guest c
				where b.haccnt=c.no and b.groupno=@accnt
	end
end
else
----------------------------------------
--	History
----------------------------------------
	if @class='F' or @class='C' 
	begin
		-- himself (flag = 0)
		insert #goutput 
			select b.accnt,0,b.master,b.saccnt,b.pcrec,b.groupno,b.class,b.haccnt,b.sta,
				c.name,b.type,b.rmnum,b.roomno,b.setrate,b.arr,b.dep,0,'T',b.charge-b.credit,b.ref,b.packages,b.resno,b.gstno,b.accredit
			 from hmaster b, guest c
				where b.haccnt=c.no and b.accnt=@accnt
	
		-- master (flag = 1)
		if @master<>''
		insert #goutput 
			select b.accnt,0,b.master,b.saccnt,b.pcrec,b.groupno,b.class,b.haccnt,b.sta,
				c.name,b.type,b.rmnum,b.roomno,b.setrate,b.arr,b.dep,1,'F',b.charge-b.credit,b.ref,b.packages,b.resno,b.gstno,b.accredit
			 from hmaster b, guest c
				where b.haccnt=c.no and b.master=@master
					and b.accnt not in (select accnt from #goutput)
	
		-- saccnt (flag = 2)  -- 历史记录的 saccnt 已经没有什么意义了
--		if @saccnt <> ''
--		insert #goutput 
--			select b.accnt,0,b.master,b.saccnt,b.pcrec,b.groupno,b.class,b.haccnt,b.sta,
--				c.name,b.type,b.rmnum,b.roomno,b.setrate,b.arr,b.dep,2,'F',b.charge-b.credit,b.ref,b.packages,b.resno,b.gstno,b.accredit
--			 from hmaster b, guest c
--				where b.haccnt=c.no and b.saccnt=@saccnt
--					and b.accnt not in (select accnt from #goutput)
	
		-- pcrec (flag = 3)
		if @pcrec <> ''
		insert #goutput 
			select b.accnt,0,b.master,b.saccnt,b.pcrec,b.groupno,b.class,b.haccnt,b.sta,
				c.name,b.type,b.rmnum,b.roomno,b.setrate,b.arr,b.dep,3,'F',b.charge-b.credit,b.ref,b.packages,b.resno,b.gstno,b.accredit
			 from hmaster b, guest c
				where b.haccnt=c.no and b.pcrec=@pcrec
					and b.accnt not in (select accnt from #goutput)
	
		-- resno (flag = 4)
--		if @resno <> ''
--		insert #goutput 
--			select b.accnt,0,b.master,b.saccnt,b.pcrec,b.groupno,b.class,b.haccnt,b.sta,
--				c.name,b.type,b.rmnum,b.roomno,b.setrate,b.arr,b.dep,4,'F',b.charge-b.credit,b.ref,b.packages,b.resno,b.gstno,b.accredit
--			 from hmaster b, guest c
--				where b.haccnt=c.no and b.resno=@resno
--					and b.accnt not in (select accnt from #goutput)
		
		if @groupno<>''
		begin
			select @grpsta = sta from hmaster where accnt = @groupno
	
			insert #goutput  -- other member of the group (flag = 5)
				select b.accnt,0,b.master,b.saccnt,b.pcrec,b.groupno,b.class,b.haccnt,b.sta,
					c.name,b.type,b.rmnum,b.roomno,b.setrate,b.arr,b.dep,5,'F',b.charge-b.credit,b.ref,b.packages,b.resno,b.gstno,b.accredit
				 from hmaster b, guest c
					where b.haccnt=c.no and b.groupno=@groupno
						and b.accnt not in (select accnt from #goutput)
	
			-- group master (flag = 6)
--			if charindex(@grpsta, 'RICG')>0 and exists(select 1 from rsvsrc where accnt=@groupno and blkmark<>'T')
--				insert #goutput 
--					select a.accnt,a.id,b.master,a.saccnt,b.pcrec,b.groupno,b.class,b.haccnt,'R',
--						c.name,a.type,a.quantity,a.roomno,a.rate,a.arr,a.dep,6,'F',b.charge-b.credit,a.remark,b.packages,b.resno,a.gstno,b.accredit
--					 from rsvsrc a, master b, guest c
--						where a.accnt=b.accnt and b.haccnt=c.no and a.blkmark<>'T' and a.type<>'PM'
--							and b.accnt=@groupno and a.accnt not in (select accnt from #goutput)
--			else
				insert #goutput
					select b.accnt,0,b.master,b.saccnt,b.pcrec,b.groupno,b.class,b.haccnt,b.sta,
						c.name,b.type,b.rmnum,b.roomno,b.setrate,b.arr,b.dep,6,'F',b.charge-b.credit,b.ref,b.packages,b.resno,b.gstno,b.accredit
					 from hmaster b, guest c
						where b.haccnt=c.no and b.accnt=@groupno
							and b.accnt not in (select accnt from #goutput)
		end
	end
	else			-- 团体会议
	begin
		select @grpsta = sta from hmaster where accnt = @accnt
		-- himself (flag = 0)
/*
--		if charindex(@grpsta, 'RICG')>0 and exists(select 1 from rsvsrc where accnt=@accnt and blkmark<>'T')
--			insert #goutput 
--				select a.accnt,a.id,b.master,a.saccnt,b.pcrec,b.groupno,b.class,b.haccnt,'R',
--					c.name,a.type,a.quantity,a.roomno,a.rate,a.arr,a.dep,0,'T',b.charge-b.credit,a.remark,b.packages,b.resno,a.gstno,b.accredit
--				 from rsvsrc a, master b, guest c
--					where a.accnt=b.accnt and b.haccnt=c.no and b.accnt=@accnt and a.blkmark<>'T and a.type<>'PM'
--		else
*/
			insert #goutput
				select b.accnt,0,b.master,b.saccnt,b.pcrec,b.groupno,b.class,b.haccnt,b.sta,
					c.name,b.type,b.rmnum,b.roomno,b.setrate,b.arr,b.dep,0,'T',b.charge-b.credit,b.ref,b.packages,b.resno,b.gstno,b.accredit
				 from hmaster b, guest c
					where b.haccnt=c.no and b.accnt=@accnt
	
		-- pcrec (flag = 3)
		if @pcrec <> ''
		insert #goutput 
			select b.accnt,0,b.master,b.saccnt,b.pcrec,b.groupno,b.class,b.haccnt,b.sta,
				c.name,b.type,b.rmnum,b.roomno,b.setrate,b.arr,b.dep,3,'F',b.charge-b.credit,b.ref,b.packages,b.resno,b.gstno,b.accredit
			 from hmaster b, guest c
				where b.haccnt=c.no and b.pcrec=@pcrec
					and b.accnt not in (select accnt from #goutput)
	
		-- member  (flag = 5)
		insert #goutput 
			select b.accnt,0,b.master,b.saccnt,b.pcrec,b.groupno,b.class,b.haccnt,b.sta,
				c.name,b.type,b.rmnum,b.roomno,b.setrate,b.arr,b.dep,5,'F',b.charge-b.credit,b.ref,b.packages,b.resno,b.gstno,b.accredit
			 from hmaster b, guest c
				where b.haccnt=c.no and b.groupno=@accnt
	end

-- filter
-- delete #goutput where sta in ('X', 'N', 'W')

-- Modify flag
update #goutput set flag=6 where class<>'F' 
update #goutput set flag=5 where class='F' and groupno<>''

-- adjust --> grp amount columns
update #goutput set bal=0, accredit=0 
	where #goutput.accnt like '[GM]%' 
		and exists (select 1 from #goutput a where #goutput.accnt=a.accnt and a.type<#goutput.type)

-- 统计 
declare 
		@ttl_rm		int,
		@ttl_gst		int,
		@ttl_rate	money,
		@ttl_bal		money,
		@ttl_acc		money
select @ttl_rm = isnull((select sum(rmnum) from #goutput where charindex(sta,'SRIOD')>0 and roomno='' and type<>'PM' and type<>''), 0) 
select @ttl_rm = @ttl_rm + isnull((select count(distinct roomno) from #goutput where charindex(sta,'SRIOD')>0 and roomno<>'' and type<>'PM' and type<>''), 0) 
select @ttl_gst = isnull((select sum(rmnum*gstno) from #goutput where charindex(sta,'SRIOD')>0 and type<>'PM' and type<>''), 0) 
select @ttl_rate = isnull((select sum(rate) from #goutput where charindex(sta,'SRIOD')>0 and type<>'PM' and type<>''), 0) 
select @ttl_bal = isnull((select sum(bal) from #goutput), 0) 
select @ttl_acc = isnull((select sum(accredit) from #goutput), 0) 

-- output 
-- select *, @ttl_rm, @ttl_gst, @ttl_rate, @ttl_bal, @ttl_acc from #goutput  -- 保持排序不变 
select a.*, @ttl_rm, @ttl_gst, @ttl_rate, @ttl_bal, @ttl_acc 						-- 每次当前账号不同，次序改变 
	from #goutput a, basecode b 
	where a.sta=b.code and b.cat='mststa'  order by a.sele desc, a.id, a.arr, a.roomno
--	order by a.flag, b.sequence, a.arr, a.roomno 

return 0
;
