
if exists(select * from sysobjects where name = "p_gds_sc_chktprm")
	drop proc p_gds_sc_chktprm
;
create proc p_gds_sc_chktprm
	@accnt           char(10),        -- �ʺ� 
	@request         char(20),        -- �����ǳ���Ҫ�Ĳ�������������
	@idcheck         char(1),        -- �ж��෿��ס 
	@empno           char(10),        -- ����Ա
	@nick            char(5),        -- �����������
	@ndmaingrpmst    int,				-- �Ƿ�Ҫά���������� 
	@grpmstlogmark   int,  				-- �Ƿ�Ҫ��¼��־ 
	@nullwithreturn  varchar(60) = null output
as
-- ------------------------------------------------------------------------------------
--	block ���� ������� 
-- ------------------------------------------------------------------------------------
declare
	@ret        int,
   @msg        varchar(60),
	@mststa     char(1),        -- �ʺ�״̬   
	@omststa    char(1),        -- �ʺ�ԭ״̬ 
	@gstno      int    ,        -- ��������   
	@rm_type    char(5),        -- ���� 
	@rm_no      char(5),        -- ���� 
	@s_time     datetime,       -- ��ʼʱ�� 
	@e_time     datetime,       -- ��ֹʱ�� 
	@otype      char(5) ,       -- ԭ����   
	@oroomno    char(5) ,       -- ԭ����   
	@oarr       datetime,       -- ԭ����   
	@odep       datetime,       -- ԭ����   
	@bdate      datetime,
	@setrate    money,
   @ocsta      char(1),
   @accntset   varchar(70),
	@extra		char(30),
	@def			char(1),
	@starsv		char(1),
	@status		char(10) 

declare 	@ratecode	varchar(10),	-- ������
			@rmnum		int,
			@class 		char(1),
			@marr			datetime,   	-- ��¼����ʱ����Ϣ��ԭʼ����
			@mdep			datetime

declare   -- New for rsvsrc
			@src			char(3),
			@market		char(3),
			@packages	varchar(50),
			@srqs		   varchar(30),
			@amenities  varchar(30)

-- init the data 
select @ret = 0, @msg = ""
select @bdate = bdate1 from sysdata

-- ����ʼ
begin tran 
save  tran p_gds_sc_chktprm_s1

-- ���������ź� ?
update chktprm set code = 'A'  

-- ��master����ȡ����
select @mststa = sta,@setrate = setrate,@ratecode=ratecode, @class=class, @extra=extra, 
		@src=src, @market=market, @packages=packages, @srqs=srqs, @amenities=amenities,
		@mststa = sta ,@omststa = osta ,@gstno  = gstno,@rm_type = type,@rm_no = roomno,
		@s_time = arr ,@e_time  = dep  ,@otype  = otype,@oroomno =oroomno,
		@oarr   = oarr,@odep    =odep  ,@rmnum=rmnum, @status=status 
	from sc_master where accnt = @accnt

if @rm_no=null  select @rm_no=''
if @omststa='' select @omststa = ''

-- 
if @mststa <> @omststa 
begin 
	if @mststa in ('W', 'X', 'N') 
	begin 
		if exists(select 1 from rsvsrc where blkcode=@accnt) 
		begin 
			select @ret = 1,@msg = "��BLOCK�Ѿ���ʹ��, ���ܽ��е�ǰ����!"
			goto RET_P
		end 
		if exists(select 1 from master where blkcode=@accnt and sta in ('R', 'O', 'D')) 
		begin 
			select @ret = 1,@msg = "��BLOCK�Ѿ���ʹ��, ���ܽ��е�ǰ����!"
			goto RET_P
		end 
		if exists(select 1 from hmaster where blkcode=@accnt and sta in ('R', 'O', 'D')) 
		begin 
			select @ret = 1,@msg = "��BLOCK�Ѿ���ʹ��, ���ܽ��е�ǰ����!"
			goto RET_P
		end 
	end 
end 

-- ���ڷ�����һ����У�� 
if @rmnum <= 0 
begin
	select @ret = 1,@msg = "����ֻ�� >= 1"
	goto RET_P
end

--
if @rm_type<>'' or @otype<>''
begin
	select @ret = 1,@msg = "Block������ֹ��д�ͷ���Ϣ"
	goto RET_P
end

-- ȥ������ʱ���е�ʱ�䲿�� 
select @marr = @s_time, @mdep = @e_time  -- ԭʼʱ��
select @s_time = convert(datetime,convert(char(8),@s_time,1))
select @e_time = convert(datetime,convert(char(8),@e_time,1))
select @oarr   = convert(datetime,convert(char(8),@oarr  ,1)) 
select @odep   = convert(datetime,convert(char(8),@odep  ,1))

if exists(select 1 from rsvsrc where accnt=@accnt and (begin_<@s_time or end_>@e_time))
begin
	select @ret = 1,@msg = "����������ͷ�ռ��ì��,���ȵ����ͷ�ռ��!"
	goto RET_P
end
if exists(select 1 from rsvsrc where blkcode=@accnt and (begin_<@s_time or end_>@e_time))
begin
	select @ret = 1,@msg = "���������붩��ռ��ì��,���ܴ���!"
	goto RET_P
end

--
select @def=definite, @starsv=starsv from sc_ressta where code=@status 

--------------------------------------------------------
-- block ����Ԥ�����ı仯 -- ������� sc_chktprm ����
--		����sta, osta ����Ԥ��������Դ�仯 
exec @ret = p_gds_sc_block_change @accnt, @empno, @msg output 
if @ret<>0 
	goto RET_P
--------------------------------------------------------


-- block ��ֹʹ�ÿͷ���Ϣ���·��������ȡ��  simon 2006/9
-----------------------------------------
---- Ԥ��������------�ȸ������ж�
-----------------------------------------
---- 1. ȡ���ͷ���Դ
-----------------------------------------
--if charindex(@mststa,'RI') = 0       -- ------> not reserve sta 
--begin
--	-- ����Ԥ����
--   if charindex(@omststa,'RI') <> 0  -- Cancel a reservation etc...... 
--	begin
--		-- �����ж����¼
--		declare	@id		int
--		while exists(select 1 from rsvsrc where accnt=@accnt)
--		begin
--			select @id=max(id) from rsvsrc where accnt=@accnt
--			select @msg = 'sc!'
--			exec p_gds_reserve_rsv_del @accnt,@id,'R',@empno,@ret output, @msg output
--		end
--	end
--   goto RET_S 
--end
-----------------------------------------
---- 2. ȡ��,���߸��� �ͷ���Դ
-----------------------------------------
--else     -----> reserve sta 
--begin
--
--	-- ��Դ����
--	if charindex(@omststa,'RI') <> 0 and @omststa<>''
--	begin
--		select @msg = 'sc!'
--		exec p_gds_reserve_rsv_mod @accnt,0,@rm_type,@rm_no,'',@marr,@mdep,@rmnum,@gstno,@setrate,'',
--			@setrate,'',@ratecode,@src,@market,@packages,@srqs,@amenities,@empno,'R',@ret output, @msg output
--		if @ret<>0 
--		begin
--			select @msg = @msg + '---' + @omststa
--			goto RET_P
--		end
--	end
--	else
--	begin
--		select @msg='sc!grp'  -- ��ʾ�����������Լ�����Դ
--		exec p_gds_reserve_rsv_add @accnt,@rm_type,@rm_no,'',@marr,@mdep,@rmnum,@gstno,@setrate,'',
--			@setrate,'',@ratecode,@src,@market,@packages,@srqs,@amenities,@empno,'R',@ret output, @msg output
--	end 
--end 
--
--------------------------------------
-- ����˳�����,������½�� 
--------------------------------------
RET_S:
if @ret=0
begin
	exec @ret = p_gds_sc_update_group @accnt, @empno, @grpmstlogmark,@msg output
	if @ret = 0
	begin
		if @mststa = @omststa   -- sta �����仯��ʱ��bdate �仯
			update sc_master set osta = sta ,otype = @rm_type,type = @rm_type,oroomno = roomno,
				oarr = arr, odep = dep where accnt = @accnt
		else
		begin
			if exists(select 1 from gate where audit = 'T') and @mststa='N'  -- ���ڻ���, No-Show
				select @bdate = dateadd(dd, -1, @bdate)
			update sc_master set osta = sta ,otype = @rm_type,type = @rm_type,oroomno = roomno,
				oarr = arr, odep = dep, bdate=@bdate  where accnt = @accnt
		end

	end 
end

if @ret <> 0
   rollback tran p_gds_sc_chktprm_s1
commit tran

if @ret = 0
begin 
	-- ���´���ŵ�������� 
	-- �������޸ģ�����¼۸� 
	if exists(select 1 from rsvsrc where accnt=@accnt and ratecode<>@ratecode)
	begin 
		declare @date datetime, @type char(5), @rate money, @id int 
		declare c_rate cursor for select id, begin_, type, quantity from rsvsrc where accnt=@accnt and ratecode<>@ratecode  
		open c_rate 
		fetch c_rate into @id, @date, @type, @rmnum 
		while @@sqlstatus = 0
		begin
			exec p_gds_get_rmrate @date, 1, @type, '', @rmnum, 1, @ratecode, '', 'R', @rate output, @msg output -- ���ﲻ�ٻ�ȡ @ret, ����Ӱ����̷���ֵ  
			if @rate is null 
				select @rate = 0 
			update rsvsrc set ratecode=@ratecode, rate=@rate where accnt=@accnt and id=@id 
			fetch c_rate into @id, @date, @type, @rmnum 
		end
		close c_rate
		deallocate cursor c_rate 
	end 

	-- backup the rsv info 
	if (@def='T' and @starsv='R') or @starsv in ('I', 'X', 'N', 'O') 
		insert rsvsrc_blkinit 
			select a.* from rsvsrc a 
				where a.accnt=@accnt 
					and a.accnt+a.type+convert(char(10),a.begin_,111) 
						not in (select b.accnt+b.type+convert(char(10),b.begin_,111) from rsvsrc_blkinit b where a.accnt=b.accnt)
end

if @nullwithreturn is null
   select @ret,@msg
else
   select @nullwithreturn = @msg
return @ret


--------------------------------------
-- ���������ع��˳�
--------------------------------------
RET_P:
rollback tran p_gds_sc_chktprm_s1
commit   tran 

if @nullwithreturn is null
   select @ret,@msg 
else
   select @nullwithreturn = @msg
return @ret
;
