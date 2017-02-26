if  exists(select * from sysobjects where name = "p_gds_get_accnt_rmrate")
	drop proc p_gds_get_accnt_rmrate;
create proc p_gds_get_accnt_rmrate
	@accnt			char(10),
	@rmrate			money			output,		-- ��ֵ
	@msg				varchar(60)	output,
	@expdate			datetime	= null			-- ָ������
as
-- ----------------------------------------------------------------------------------
--	�����ʺ�ȡ�÷���   (master)
--	@msg = 'fut' -- ��ʾ��ȡδ���۸� - ��Ҫ�Աȵ�
--      ���򣬱�ʾֱ�ӻ�ȡЭ��۸�
-- ----------------------------------------------------------------------------------
declare 
	@ret				int,
	@arr				datetime,
	@dep				datetime,
	@long				int,
	@type				char(5),
	@roomno			char(5),
	@rmnums			int,
	@gstno			int,
	@ratecode		char(10),
	@groupno			char(10),
	@bdate			datetime,
	@bfdate			datetime,
	@fut				char(1),
	@mkt				char(3),
	@setrate			money,
	@sta				char(1),
	@saccnt			char(10),
	@keydate			datetime, 	-- �۸�������� 
	@keyrmrate		money,
	@keyrate			money,
	@mode				char(1),
   @count         int 

if rtrim(@msg) is null select @msg=''
if @msg='fut' 
	select @fut='1'
else
	select @fut='0'

select @ret=0, @rmrate=0, @msg=''
select @bdate = bdate1 from sysdata
select @bfdate=dateadd(dd,-1,@bdate)

//�ж��Ƿ���ÿ�շ���,���ʹ����ÿ�շ���,����Ӧ�İ��ۺͷ�����Ҫ��rsvsrc_detail��ȡ
select @count=count(1) from rsvsrc_detail where accnt=@accnt and datediff(day,date_,@expdate)=0 and mode='M'
     if @count>0 
			begin
           select @arr=arr, @dep=dep, @type=type, @roomno=roomno, @groupno=groupno, @ratecode=ratecode, 
					@rmnums=rmnum, @gstno=gstno, @mkt=market, @setrate=setrate,@sta=sta, @saccnt=saccnt
				from master where accnt=@accnt
           select @setrate=rate from rsvsrc_detail where accnt=@accnt and date_=@expdate
         end  

else
		select @arr=arr, @dep=dep, @type=type, @roomno=roomno, @groupno=groupno, @ratecode=ratecode, 
					@rmnums=rmnum, @gstno=gstno, @mkt=market, @setrate=setrate,@sta=sta, @saccnt=saccnt
				from master where accnt=@accnt


if @@rowcount = 0
	select @ret=1, @msg='�ʺŲ����� !', @rmrate=@setrate
else if @sta<>'R' and @sta<>'I'
	select @ret=1, @msg='����Ч�˻�״̬', @rmrate=@setrate
else
begin
	-- ��ȡ����ģʽ - 0=ά�������۸� 1=�ϸ���Э��۸� 2=��� 3=���� 
	select @mode = isnull((select substring(value,1,1) from sysoption where catalog = 'reserve' and item = 'rmrate_autochg_mode'), '0')
	if charindex(@mode, '0123') = 0 
		select @mode = '0'

	-- ��������
	select @arr = convert(datetime,convert(char(8),@arr,1))
	select @dep = convert(datetime,convert(char(8),@dep,1))
	select @long = datediff(dd, @arr, @dep)
	if @long <= 0	
		select @long = 1
	if @expdate is null
		select @expdate = @bdate

--	if @fut='1'  -- �Ա�ȡ��, �Զ���۵�ʱ����Ҫ... ��ǰ��������Ҫ, ��������Ҫ
--	begin
--		if @expdate<@arr 
--			select @expdate = @arr
--		if @expdate>@dep
--			select @expdate = @dep
		select @expdate = convert(datetime,convert(char(8),@expdate,1))

		if @expdate <= @bdate or @mode='0' 
		begin
			select @rmrate=@setrate 
		end 
		else if exists(select 1 from mktcode where code=@mkt and flag='LON')	
			and exists(select 1 from ls_master where accnt=@accnt)
		begin -- �������ļ۸������ÿ�ն����ʱ���Զ���ȡÿ�ռ۸� 
			select @rmrate=isnull((select rate from ls_detail where accnt=@accnt and date=@expdate), 0)
		end
		else
		begin
			-- ��Щ������ô���
			select @long=isnull((select count(1) from rsvsrc where saccnt=@saccnt and rate<>0), 0)
			if @long>1  -- ͬס���ۣ�����������м۸����� 
			begin
				select @rmrate=@setrate 
			end
			else
			begin
				-- �Ȼ�ȡ������Ϣ 
				if @arr > @bdate
					select @keydate=@arr
				else
					select @keydate=@bdate 
				select @keyrate=@setrate
				exec @ret = p_gds_get_rmrate @keydate, @long, @type, @roomno, @rmnums, @gstno, @ratecode, @groupno, 'R', @keyrmrate output, @msg output
				if @ret = 0 
				begin
					if @expdate <= @keydate 
						select @rmrate = @setrate 
					else
					begin
						exec @ret = p_gds_get_rmrate @expdate, @long, @type, @roomno, @rmnums, @gstno, @ratecode, @groupno, 'R', @rmrate output, @msg output
						if @ret=0 
						begin
							if @keyrmrate=@rmrate 
								select @rmrate = @keyrate 
							else
							begin
								if @mode='1' 	-- 1=�ϸ���Э��۸�
								begin	
									if @keyrate<>@keyrmrate 
										select @rmrate=@keyrate 
								end
								else if @mode = '2'	-- 2=���
								begin	
									select @rmrate=@keyrate - @keyrmrate + @rmrate 
								end
								else if @mode = '3'	-- 3=���� 
								begin	
									select @rmrate=round(@keyrate * @rmrate / @keyrmrate, 2) 
								end
							end 
						end
						else
							select @rmrate = @setrate -- ����δ�����ڵ�Э��۸��޷���ȡ����ֱ����ԭ���ļ۸� 
					end 
				end
				else
					select @rmrate = @setrate -- ����ԭ����Э��۸��޷���ȡ����ֱ����ԭ���ļ۸� 
			end
		end 
--	end
--	else		-- ����������ȡ'Э���'
--	begin
--		select @expdate = convert(datetime,convert(char(8),@expdate,1))
--		-- ɢ�͵����,�Ƿ�Ҫ������ͬԤ���� ���� ���� ����-----> ����������?
--		select @expdate = convert(datetime,convert(char(8),@expdate,1))
--		if @expdate <= @bdate 
--			select @rmrate = @setrate 
--		else
--			exec @ret = p_gds_get_rmrate @expdate, @long, @type, @roomno, @rmnums, @gstno, @ratecode, @groupno, 'R', @rmrate output, @msg output
--	end
end

return @ret
;

-- 
-- select accnt,setrate,arr,dep from master where class='F' and groupno='' and sta='I';
--
--      -------------->  ���ԵĽű�
-- declare 
-- @ret           int,
-- @rmrate			money,
-- @msg		 varchar(60)
-- select @msg='fut'
-- delete gdsmsg
-- exec @ret = p_gds_get_accnt_rmrate 'F501160003',@rmrate output,@msg output,'2005/4/5'
-- if @ret=0
-- 	insert gdsmsg select convert(char(10), @rmrate)
-- else
-- 	insert gdsmsg select isnull(@msg, '')
-- ;
-- select * from gdsmsg;