IF OBJECT_ID('dbo.p_gds_master_flag') IS NOT NULL
DROP PROCEDURE dbo.p_gds_master_flag
;
create proc p_gds_master_flag
   @accnt		char(10),
	@langid		int = 0,
	@master		varchar(60)=''   -- master, guest, saleid ...
as
-----------------------------------------------------------------------------------------------
--	p_gds_master_flag: 宾客主单标志显示
-----------------------------------------------------------------------------------------------
create table #goutput (
	item			char(12)							not null,
	flag			int			default 0		not null,
	cmd			char(10)							not null,
	sequence		int			default 0		not null
)
--
if rtrim(@accnt) is null
begin
	insert #goutput(item, cmd, sequence) values( '', '', 999)
	goto gout
end

declare	@class		char(1),
			@count		int,
			@extra		char(30),
			@tmp			char(1),
			@lic_buy_1	varchar(255),
			@lic_buy_2	varchar(255),
			@shortkey	char(36),
			@keypos		int,
			@item			varchar(12)

declare	@l_locksta	varchar(12),
			@l_routing	varchar(12),
			@l_fixchg	varchar(12),
			@l_grpfee	varchar(12),
			@l_trace		varchar(12),
			@l_meet		varchar(12),
			@l_pos		varchar(12),
			@l_mail		varchar(12),
			@l_loc		varchar(12),
			@l_phone		varchar(12),
			@l_vod		varchar(12),
			@l_int		varchar(12),
			@l_rent		varchar(12),
			@l_ref		varchar(12),
			@l_gsource	varchar(12),   --团队资源
			@l_arbal		varchar(12),	--AR净额
			@l_authar	varchar(12),	--AR授权
			@l_file  	varchar(12),	--主单附件
			@l_invoice  varchar(12),   --发票
			@pms			varchar(20),
			@his			char(1),
			@authar		char(1),			--前台宾客ar记账是否必须授权
			@l_alerts	varchar(12),		--Alerts
			@l_sw			varchar(12),		--失物
			@l_allot		varchar(12)

-- 对应快捷键
select @shortkey = '1234567890abcdefghijklmnopqrstuvwxyz', @keypos = 0

select @master = isnull(rtrim(@master), 'master')
if @master = 'sc_master'
begin
	-- 接口定义
	if @langid = 0
		select @l_file     = ".附件" 
	else
		select @l_file     = ".File" 

	-- 附件
	select @keypos = @keypos + 1
	select @item = substring(@shortkey, @keypos, 1) + @l_file
	if exists(select 1 from file_detail where prvdept = 'B='+@accnt )
		insert #goutput(item, cmd, flag, sequence) values(@item,'file',1,160)
	else
		insert #goutput(item, cmd, flag, sequence) values(@item,'file',0,160)
end
if @master = 'guest'
begin
	-- 接口定义
	if @langid = 0
		select @l_file     = ".附件" , @l_sw = ".失物",@l_alerts	='.Alerts',@l_allot = '.配额使用'
	else
		select @l_file     = ".File" , @l_sw = ".Lost property",@l_alerts	='.Alerts',@l_allot = '.Allot Use'

	-- 附件
	select @keypos = @keypos + 1
	select @item = substring(@shortkey, @keypos, 1) + @l_file
	if exists(select 1 from file_detail where prvdept = 'G='+@accnt )
		insert #goutput(item, cmd, flag, sequence) values(@item,'file',1,160)
	else
		insert #goutput(item, cmd, flag, sequence) values(@item,'file',0,160)

	-- Alerts
	select @keypos = @keypos + 1
	select @item = substring(@shortkey, @keypos, 1) + @l_alerts
	if exists(select 1 from alerts where id = @accnt and rtrim(type)='G' and sta='I')
		insert #goutput(item, cmd, flag, sequence) values(@item,'Galerts',1,165)
	else
		insert #goutput(item, cmd, flag, sequence) values(@item,'Galerts',0,165)

	--失物
	select @keypos = @keypos + 1
	select @item = substring(@shortkey, @keypos, 1) + @l_sw
	if exists(select 1 from swreg where host_hno = @accnt ) or exists(select 1 from swrep where lose_hno = @accnt )
			or exists(select 1 from hswrep where lose_hno = @accnt ) or exists(select 1 from hswreg where host_hno = @accnt )
		insert #goutput(item, cmd, flag, sequence) values(@item,'sw',1,170)
	else
		insert #goutput(item, cmd, flag, sequence) values(@item,'sw',0,170)

	--配额使用情况
	if exists(select 1 from guest where no = @accnt and class not in ('F','G'))
		begin
		select @keypos = @keypos + 1
		select @item = substring(@shortkey, @keypos, 1) + @l_allot
		if exists(select 1 from gzhs_rsv_plan where no = @accnt ) 
			insert #goutput(item, cmd, flag, sequence) values(@item,'allot',1,180)
		else
			insert #goutput(item, cmd, flag, sequence) values(@item,'allot',0,180)
		end
end
else if @master = 'saleid'
begin
	-- 接口定义
	if @langid = 0
		select @l_file     = ".附件"
	else
		select @l_file     = ".File"

	-- 附件
	select @keypos = @keypos + 1
	select @item = substring(@shortkey, @keypos, 1) + @l_file
	if exists(select 1 from file_detail where prvdept = 'S='+@accnt )
		insert #goutput(item, cmd, flag, sequence) values(@item,'file',1,160)
	else
		insert #goutput(item, cmd, flag, sequence) values(@item,'file',0,160)

end
else if @master = 'master'
begin
	-- 普通接口
	select @pms = isnull((select rtrim(value)  from sysoption where catalog='reserve' and item='front_pms'), 'P')

	-- 前台宾客ar记账是否必须授权
	select @authar = isnull((select rtrim(value)  from sysoption where catalog='ar' and item='auth_req_fo'), 'F')

	-- 接口定义
	if @langid = 0
		select @l_locksta	='.允许记账',			@l_routing	='.定义帐户',			@l_fixchg	='.固定支出',
				@l_grpfee	='.团体付费',			@l_trace		='.事务',				@l_meet		='.会议室',
				@l_pos		='.订餐',				@l_mail		='.留言',				@l_loc		='.去向',
				@l_phone		='.电话',				@l_rent		='.租赁',				@l_ref		='.大备注',
				@l_gsource  ='.资源清单',			@l_arbal		='.净额',				@l_vod		='.VOD',
				@l_int		='.Internet',			@l_authar	='.授权AR',				@l_file     = ".附件",
				@l_alerts	='.Alerts'  ,			@l_invoice	='.发票'
	else
		select @l_locksta	='.Auth. Post',		@l_routing	='.Routing',			@l_fixchg	='.Fixed Chg',
				@l_grpfee	='.Grp Post',			@l_trace		='.Trace',				@l_meet		='.Meeting Rm',
				@l_pos		='.F&B',					@l_mail		='.Message',			@l_loc		='.Location',
				@l_phone		='.Phone',				@l_rent		='.Rental',				@l_ref		='.BigRef',
				@l_gsource  ='.RoomBlk',			@l_arbal		='.NetBal',				@l_vod		='.VOD',
				@l_int		='.Internet',			@l_authar	='.AuthAR',				@l_file     = ".File",
				@l_alerts	='.Alerts'  ,			@l_invoice	='.Invoice'
	--
	select @lic_buy_1 = isnull((select value from sysoption where catalog='hotel' and item='lic_buy.1'), '')
	select @lic_buy_2 = isnull((select value from sysoption where catalog='hotel' and item='lic_buy.2'), '')
	if @accnt like 'A%' and (charindex(',nar,', @lic_buy_1) > 0 or charindex(',nar,', @lic_buy_2) > 0)
	begin
		select @class=class, @extra=extra from ar_master where accnt=@accnt
		if @@rowcount = 0
		begin
			select @class=class, @extra=extra from har_master where accnt=@accnt
			if @@rowcount = 0
				goto gout
			else
				select @his = 'T'
		end
		else
			select @his = 'F'
	end
	else
	begin
		select @class=class, @extra=extra from master where accnt=@accnt
		if @@rowcount = 0
		begin
			select @class=class, @extra=extra from hmaster where accnt=@accnt
			if @@rowcount = 0
				goto gout
			else
				select @his = 'T'
		end
		else
			select @his = 'F'
	end


	-- locksta
	select @keypos = @keypos + 1
	select @item = substring(@shortkey, @keypos, 1) + @l_locksta
	insert #goutput(item, cmd, flag, sequence) values(@item, 'locksta', convert(integer, substring(@extra, 10, 1)),	10)

	-- routing
	select @keypos = @keypos + 1
	select @item = substring(@shortkey, @keypos, 1) + @l_routing
	if @his='F'
		select @count = count(1) from subaccnt where accnt=@accnt and type='5' and tag='2'  --  and pccodes<>'' and pccodes<>'.'
	else
		select @count = count(1) from hsubaccnt where accnt=@accnt and type='5' and tag='2'  --  and pccodes<>'' and pccodes<>'.'
	if @count > 0
		insert #goutput(item, cmd, flag, sequence) values(@item, 		'routing', 1, 20)
	else
		insert #goutput(item, cmd, flag, sequence) values(@item, 		'routing', 0, 20)

	-- fixchg
	select @keypos = @keypos + 1
	select @item = substring(@shortkey, @keypos, 1) + @l_fixchg
	if exists(select 1 from fixed_charge where accnt=@accnt)
		insert #goutput(item, cmd, flag, sequence) values(@item, 'fixchg', 1,	30)
	else
		insert #goutput(item, cmd, flag, sequence) values(@item, 'fixchg', 0,	30)

	-- grpfee
	if @class='G' or @class='M'
	begin
		select @keypos = @keypos + 1
		select @item = substring(@shortkey, @keypos, 1) + @l_grpfee
		if @his='F'
			select @count = count(1) from subaccnt where accnt=@accnt and type='2' and (pccodes='' or pccodes='.')
		else
			select @count = count(1) from hsubaccnt where accnt=@accnt and type='2' and (pccodes='' or pccodes='.')
		if @count > 0
			insert #goutput(item, cmd, flag, sequence) values(@item, 'grpfee', 0,	35)
		else
			insert #goutput(item, cmd, flag, sequence) values(@item, 'grpfee', 1,	35)
	end


	-- trace
	select @keypos = @keypos + 1
	select @item = substring(@shortkey, @keypos, 1) + @l_trace
	if @his='F'  -- 事务状态 0-无须处理 1-未处理 2-已处理 3-已删除 4-已失效
		select @count = count(1) from message_trace where  accnt=@accnt  and tag = '1'
	else
		select @count = count(1) from message_trace_h where  accnt=@accnt  and tag = '1'
	if @count > 0
		insert #goutput(item, flag, cmd, sequence) values(@item, 1, 'trace', 40)
	else
		insert #goutput(item, flag, cmd, sequence) values(@item, 0, 'trace', 40)

	-- meet
	select @keypos = @keypos + 1
	select @item = substring(@shortkey, @keypos, 1) + @l_meet
	if @his='F'
		select @count = count(1) from res_av where accnt=@accnt and sta in ('R','I','O') and resid in (select resid from res_plu where chkmode = 'mtr')
	else
		select @count = count(1) from res_av_h where accnt=@accnt and sta in ('R','I','O') and resid in (select resid from res_plu where chkmode = 'mtr')
	if @count > 0
		insert #goutput(item, flag, cmd, sequence) values(@item, 1, 'meet', 50)
	else
		insert #goutput(item, flag, cmd, sequence) values(@item, 0, 'meet', 50)

	-- fb - ?
	select @keypos = @keypos + 1
	select @item = substring(@shortkey, @keypos, 1) + @l_pos
	if @his='F'
		select @count = count(1) from pos_reserve where accnt=@accnt and sta<>'0'
	else
		select @count = count(1) from pos_hreserve where accnt=@accnt and sta<>'0'
	if @count > 0
		insert #goutput(item, cmd, flag, sequence) values(@item, 		'fb', 		1, 60)
	else
		insert #goutput(item, cmd, flag, sequence) values(@item, 		'fb', 		0, 60)

	-- msg
	select @keypos = @keypos + 1
	select @item = substring(@shortkey, @keypos, 1) + @l_mail
	if @his='F'
		select @count = count(1) from message_leaveword where sort = 'LWD' and accnt=@accnt and tag='1'
	else
		select @count = count(1) from message_leaveword_h where sort = 'LWD' and accnt=@accnt and tag='1'
	if @count > 0
		insert #goutput(item, flag, cmd, sequence) values(@item, 1, 'msg', 70)
	else
		insert #goutput(item, flag, cmd, sequence) values(@item, 0, 'msg', 70)

	-- loc
	select @keypos = @keypos + 1
	select @item = substring(@shortkey, @keypos, 1) + @l_loc
	if @his='F'
		select @count = count(1) from message_leaveword where sort = 'LOC' and accnt=@accnt and tag='1' and datediff(second,message_leaveword.abate,getdate())<0
	else
		select @count = count(1) from message_leaveword_h where sort = 'LOC' and accnt=@accnt and tag='1' and datediff(second,message_leaveword_h.abate,getdate())<0
	if @count > 0
		insert #goutput(item, flag, cmd, sequence) values(@item, 1, 'loc', 80)
	else
		insert #goutput(item, flag, cmd, sequence) values(@item, 0, 'loc', 80)

	-- phone
	if @class = 'F' and charindex('P', @pms) > 0
	begin
		select @keypos = @keypos + 1
		select @item = substring(@shortkey, @keypos, 1) + @l_phone
		insert #goutput(item, cmd, sequence) values(@item, 		'phone', 	90)
		select @tmp = substring(@extra, 6, 1)
		if @tmp > '0'
			update #goutput set flag=1 where cmd = 'phone'
	end

	-- vod


	-- int


	-- Alerts
	if charindex(@class,'GFCM')>0
	begin
		select @keypos = @keypos + 1
		select @item = substring(@shortkey, @keypos, 1) + @l_alerts
		insert #goutput(item, cmd, sequence) values(@item, 'alerts', 		110)
		select @count = count(1) from alerts where id = @accnt and rtrim(type)='M' and sta='I'
		if @count > 0
			update #goutput set flag=1 where cmd = 'alerts'
	end

	-- ret
	select @keypos = @keypos + 1
	select @item = substring(@shortkey, @keypos, 1) + @l_rent
	if @his='F'
		select @count = count(1) from res_av where accnt=@accnt and sta in ('R','I') and resid in (select resid from res_plu where chkmode <> 'mtr')
	else
		select @count = count(1) from res_av_h where accnt=@accnt and sta in ('R','I') and resid in (select resid from res_plu where chkmode <> 'mtr')
	if @count > 0
		insert #goutput(item, cmd, flag, sequence) values(@item,'rent',1,120)
	else
		insert #goutput(item, cmd, flag, sequence) values(@item,'rent',0,120)

	-- Q-room		-- 目前只针对当前账户，历史不管了
	if @his='F' and @class = 'F'
	begin
		select @keypos = @keypos + 1
		select @item = substring(@shortkey, @keypos, 1) + '.Q-Room'
		if exists(select 1 from qroom where accnt=@accnt and cby='')
			insert #goutput(item, flag, cmd, sequence) values(@item, 1, 'qroom', 130)
		else
			insert #goutput(item, flag, cmd, sequence) values(@item, 0, 'qroom', 130)
	end

	-- big remark
	select @keypos = @keypos + 1
	select @item = substring(@shortkey, @keypos, 1) + @l_ref
	if exists(select 1 from master_remark where accnt=@accnt)
		insert #goutput(item, cmd, flag, sequence) values(@item,'bigref',1,140)
	else
		insert #goutput(item, cmd, flag, sequence) values(@item,'bigref',0,140)


	-- 以下功能存在不足，暂时关闭 - gds 2008.4.24  丁广平请求开放 2008.6.23
	-- Room Source List add by wz for gz_baiyun   -- 目前只针对当前账户，历史不管了
	if @his='F' and exists(select 1 from master where accnt=@accnt and class in ('G','M'))
	begin
		select @keypos = @keypos + 1
		select @item = substring(@shortkey, @keypos, 1) + @l_gsource
		insert #goutput(item, cmd, flag, sequence) values(@item,'rmsource',1,150)
	end

	-- Net. Bal
	if @class = 'A'
	begin
		select @keypos = @keypos + 1
		select @item = substring(@shortkey, @keypos, 1) + @l_arbal
		insert #goutput(item, flag, cmd, sequence) values(@item, 1, 'arnet', 130)
		if (charindex(',nar,', @lic_buy_1) > 0 or charindex(',nar,', @lic_buy_2) > 0)
		begin
			select @keypos = @keypos + 1
			if substring(@extra, 3, 1) = '2'
				select @item = substring(@shortkey, @keypos, 1) + '.Blacklist', @tmp = '1'
			else if substring(@extra, 3, 1) = '1'
				select @item = substring(@shortkey, @keypos, 1) + '.Cashlist', @tmp = '2'
			else
				select @item = substring(@shortkey, @keypos, 1) + '.Credit OK', @tmp = '0'
			insert #goutput(item, flag, cmd, sequence) values(@item, convert(integer, @tmp), 'arstatus', 130)
		end
	end

	-- Auth AR
	if @authar='T' and @class <> 'A' and @his='F'
	begin
		select @keypos = @keypos + 1
		select @item = substring(@shortkey, @keypos, 1) + @l_authar
		if substring(@extra,13,1)='1'
			insert #goutput(item, cmd, flag, sequence) values(@item, 'authar', 1,	30)
		else
			insert #goutput(item, cmd, flag, sequence) values(@item, 'authar', 0,	30)
	end

	-- 附件
	if exists(select 1 from file_detail where prvdept = 'M='+@accnt )
	begin
		select @keypos = @keypos + 1
		select @item = substring(@shortkey, @keypos, 1) + @l_file
		insert #goutput(item, cmd, flag, sequence) values(@item,'file',1,160)
	end
	else
	begin
		select @keypos = @keypos + 1
		select @item = substring(@shortkey, @keypos, 1) + @l_file
		insert #goutput(item, cmd, flag, sequence) values(@item,'file',0,160)
	end

	-- 发票
	if (charindex(',sinv,', @lic_buy_1) > 0 or charindex(',sinv,', @lic_buy_2) > 0)
	begin
		select @count = count(1) from invoice_op where accnt= @accnt
		select @count = @count + count(1) from invoice_op a,account b where a.billno = b.billno and b.accnt = @accnt and a.billno <>''
		select @count = @count + count(1) from invoice_op a,haccount b where a.billno = b.billno and b.accnt = @accnt and a.billno <>''
		select @keypos = @keypos + 1
		select @item = substring(@shortkey, @keypos, 1) + @l_invoice
		if @count > 0
			insert #goutput(item, cmd, flag, sequence) values(@item,'invoice',1,170)
		else
			insert #goutput(item, cmd, flag, sequence) values(@item,'invoice',0,170)
	end
end

-- End ...
gout:
-- 补  --- 不需要了，客户端自动调整 flag 宽度
--select @count = count(1) from #goutput
--while @count < 12
--begin
--	insert #goutput(item, cmd, sequence) values( '-', '-', 999)
--	select @count = @count + 1
--end

-- output
select item, flag, cmd from #goutput
return 0
;
