if object_id('p_gds_reserve_chktprm_son') is not null
drop proc p_gds_reserve_chktprm_son
;
create proc p_gds_reserve_chktprm_son
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
--��  p_gds_reserve_chktprm ����
--		ע��������ⷿ�ŵĴ���:  roomno>='0' ��ʾ�ַ���, �����ʾû�зַ�.
-- ------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------
-- 	�ַ�,�˷�,����,Ԥ��ת��ס,Ԥ��ȡ��,Ԥ���ָ�,���������˷���״̬ת������ǰ,���ڵ����ڸ��ĵ�
-- 	�������̸����˿�����Ϣʱ,���ر�־�����Ӧ������ȷ��¼������־
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
	@eetime     datetime,       -- ��������� ����
	@otype      char(5) ,       -- ԭ����   
	@oroomno    char(5) ,       -- ԭ����   
	@oarr       datetime,       -- ԭ����   
	@odep       datetime,       -- ԭ����   
	@pblkno     int,            -- ���÷����� 
	@prmtk      int,            -- �������ʺ��� 
	@number     smallint,       -- �ʵ���Ŀ 
	@rmsta        char(1),        -- �ͷ�״̬ 
	@skip_block int,            -- �Ƿ��������Ԥ�����ж�
	@groupno    char(10),        -- �ź� 
	@grpsta     char(1),        -- ����״̬ 
	@grparr     datetime,       -- ���嵽�� 
	@grpdep     datetime,       -- �������� 
	@grpclass   char(1),        -- ������� 
	@nullwith2  varchar(60),   
	@needtotran varchar(3),  		    -- �Ƿ�Ҫ������Ϣ master -> guest : arr, dep, roomno
	@bdate      datetime,
	@discount   money,
	@discount1  money,
	@percent    money,
	@rtreason   char(3),
	@qtrate     money,
	@setrate    money,
	@rmrate    money,
   @ocsta      char(1),
   @accntset   varchar(70),
	@extra		char(30),
	@saccnt		char(10),
	@master		char(10),
	@blkcode		char(10),
	@oblkcode	char(10),
	@rsvchk		varchar(20),
	@saccnt_1	char(10),
	@master_1	char(10),
	@tmp_accnt1	char(10),
	@tmp_accnt2	char(10)

--FHB added
declare	@number1		int,
			@num			int,
			@quantity	money

-- �Ƿ�Ҫ������Դ����У�� 
select @rsvchk=''  -- yes 
if @nullwithreturn is not null 
begin 
	if charindex('rsvchk=0;', @nullwithreturn) > 0 
		select @rsvchk = 'rsvchk=0;'  -- no һ����ͬ�������ʱ��ֻ�����һ������У�� 
end 

-- 
declare 	@ratecode	varchar(10),	-- ������
			@cusno		char(7),			-- ��λ����
			@rmnum		int,
			@ormnum		int,
			@tmpsta 		char(1),
			@class 		char(1),
			@marr			datetime,   	-- ��¼����ʱ����Ϣ��ԭʼ����
			@mdep			datetime

declare   -- New for rsvsrc
			@src			char(3),
			@market		char(3),
			@packages	varchar(50),
			@srqs		   varchar(30),
			@amenities  varchar(30)

declare
	@allow_dirty_register_in        char(1),-- �Ƿ������෿��ס��'Y' ���� ��'N' ��ֹ 
	@allow_exceed_use_room_type     char(1),-- �Ƿ�������ʹ�÷���, ���� @min_useable < 1 ʱҲ����Ԥ����־ ��'Y' ���� �� 'N' ��ֹ
	@allow_check_roomno_first       char(1),-- �Ƿ������Է��ż���Ϊ׼, �������Ƿ������Ľ����־ ��'Y' ���� 'N' ��ֹ 
	@cntlblock                      char(1) -- �Ƿ�����鷿��Ԥ����� ��'t','T' ���� �� ��������             

declare	@host_id	varchar(30)
select @host_id = host_id()

-- init the data 
select @ret = 0,@msg = "",@nullwith2=@nullwithreturn, @tmpsta=''
select @bdate = bdate1 from sysdata
select @skip_block = 0

-- sysoption values
select @allow_dirty_register_in=value from sysoption where catalog="reserve" and item="allow_dirty_register_in"
if @@rowcount = 0
	select @allow_dirty_register_in="N"

select @allow_check_roomno_first=value from sysoption where catalog="distribute" and item="allow_check_roomno_first"
if @@rowcount = 0
	select  @allow_check_roomno_first  = "N"

select @allow_exceed_use_room_type=value from sysoption where catalog="distribute" and item="allow_exceed_use_room_type"
if @@rowcount = 0
   select  @allow_exceed_use_room_type  = "N"

select  @cntlblock = value from sysoption  where   catalog = "reserve" and item = "cntlblock"
if @@rowcount = 0
   select  @cntlblock = "T"

-- ����ʼ
begin tran 
save  tran p_gds_reserve_chktprm_son_s1

-- ���������ź� ?
update chktprm set code = 'A'  

-- ��ס�������� 
select @groupno = groupno from master where accnt = @accnt
if @@rowcount = 1 and @groupno <> ''
   begin
   select @grparr=convert(datetime,convert(char(8),arr,1)), @grpdep=convert(datetime,convert(char(8),dep,1)),
          @grpsta=sta, @grpclass=class 
		from master where accnt = @groupno  -- convert date-> yyyy/mm/dd 00:00:00
	-- �����������<��̬��-1>
--	update master set exp_sta=(select b.exp_sta from master b where b.accnt=@groupno) where accnt=@accnt
   end

-- ��master����ȡ����  �жϷ��� 
select @mststa = sta,@discount=discount,@discount1=discount1,@rtreason=isnull(rtreason,''),@rmrate=rmrate,
	    	@qtrate = qtrate,@setrate = setrate,@ratecode=rtrim(ratecode), @cusno=rtrim(cusno),@class=class,
		@extra=extra, @saccnt=saccnt, @master=master,
			@src=src, @market=market, @packages=packages, @srqs=srqs, @amenities=amenities
	from master where accnt = @accnt
-- �ٷ����ܲ���֮��,�������ȡ����... 
--if @class<>'F' 
--begin
--	select @ret = 0, @msg='�Ǳ������������账��'
--	goto RET_P
--end

---- �������Żݣ�ע���ų������������÷���
--if @groupno = '' and @rmrate<>@setrate and substring(@extra,1,1)<>'1' and substring(@extra,2,1)<>'1'
--begin
--   select @percent = p01 from reason where code = @rtreason and p01 > 0
--   if @@rowcount = 0
--   begin
--		select @ret = 1, @msg='�����Ż�����δ��'
--		goto RET_P
--	end
--   if @discount <> 0 and @discount>@qtrate*@percent
--	begin
--		select @ret = 1,@msg='�����Żݳ����Ż��޶� - 1'
--		goto RET_P
--	end
--   if @discount1>@percent
--	begin
--		select @ret = 1,@msg='�����Żݳ����Ż��޶� - 2'
--		goto RET_P
--	end
--end                                          
                                                                                                       
 
select @mststa = sta ,@omststa = osta ,@gstno  = gstno,@rm_type = type,@rm_no = roomno,
	    @s_time = arr ,@e_time  = dep  ,@otype  = otype,@oroomno =oroomno,
	    @oarr   = oarr,@odep    =odep  ,@rmnum=rmnum, @ormnum=ormnum, @blkcode=blkcode, @oblkcode=oblkcode  
	from master where accnt = @accnt
if @rm_no=null  select @rm_no=''
if @omststa='' select @omststa = ''

if @mststa='I' and @rm_no<'0'
begin
	select @ret = 1,@msg = "���ȷ��䷿��"
	goto         RET_P
end

-- �������⴦��
if @class='G' or @class='M'
	select @rmnum=1, @ormnum=1, @gstno=0  

-- ���ŵ���Ч���ж�
if charindex(@mststa, 'RIW')>0
begin
	if @rm_no<'0' and @rm_no<>''
	begin
		if substring(@rm_no,1,1)<>'#' 
		begin
			select @ret = 1,@msg = "���Ŵ�������!"
			goto         RET_P
		end
	end
	else if @rm_no >= '0'
	begin
		if not exists(select 1 from rmsta where roomno=@rm_no)
		begin
			select @ret = 1,@msg = "���Ŵ�������!"
			goto         RET_P
		end
	end
end

if @omststa<>'I' and @mststa='I' 
	and exists(select 1 from master where sta='I' and roomno=@rm_no and master<>@master and saccnt<>@saccnt and share<>'T')		-- modi by zk share='F'->share<>'T'
--	and exists(select 1 from master where sta='I' and roomno=@rm_no and master<>@master and saccnt<>@saccnt and share='F')
begin
	select @ret = 1,@msg = "�ÿͷ��Ѿ�������ס"
	goto RET_P
end

-- ����ס���жϺ͸���ʱ��
if charindex(@omststa,'ISO')=0 and @mststa='I' and @nick <> 'I'  -- nick ��ʾͬ��������ʱ��ԭ����״̬
begin
	-- 
	if @mststa='I' and @omststa='S' and not exists(select 1 from master where bdate=@bdate)
	begin
		select @ret = 1,@msg = "�����ʻ�ҹ�����ʹ�øù���"
		goto RET_P
	end

	-- ���õ���ʱ��  -- Ԥ�����ˣ���Ԥ�����ڵĴ������ϵ���
--	if charindex(@omststa, 'RCG')>0 and @mststa='I' -- Ԥ��ת�Ǽ�
--			and datepart(hour,getdate())<6 					-- С�� 6 ��
--			and datediff(dd,@s_time,getdate()) > 0			-- ���� < ��ǰ����
--		select @s_time = convert(datetime, convert(char(10), dateadd(dd,-1,getdate()), 111)+' 23:59:59')
--	else
		select @s_time = getdate()

	update master set arr=@s_time, bdate=@bdate, ciby=@empno, citime=getdate() where accnt=@accnt  -- ����ci info 

	if datediff(dd, @e_time, getdate())>0 
	begin
		select @ret = 1,@msg = "�뿪���ڲ���С�ڵ�ǰʵ������"
		goto RET_P
	end

	if datediff(dd, @s_time, @e_time)<0 
	begin
		select @ret = 1,@msg = "�뿪���ڲ���С�ڵ�������"
		goto RET_P
	end
end



-- ���ڷ�����һ����У�� 
if @rmnum <= 0 
begin
	select @ret = 1,@msg = "����ֻ�� >= 1"
	goto RET_P
end
if @mststa='I' and @rmnum <> 1 
begin
	select @ret = 1,@msg = "�Ǽ������ķ���ֻ�� = 1"
	goto RET_P
end
if @rm_no>'0' and  @rmnum <> 1 
begin
	select @ret = 1,@msg = "�ַ�����ֻ��ռ��һ������ !"
	goto	RET_P
end


if @s_time <> @oarr or @oarr is null
   select @needtotran = 'A'  					-- ��Ҫ�������� master����guest
if @e_time <> @odep or @odep is null
   select @needtotran = @needtotran+'D'

-- ȥ������ʱ���е�ʱ�䲿�� 
select @marr = @s_time, @mdep = @e_time
select @s_time = convert(datetime,convert(char(8),@s_time,1))
select @e_time = convert(datetime,convert(char(8),@e_time,1))
if @e_time < @s_time 
   select @eetime = @s_time -- ��������� ���� -- ԭ�� hry �汾�����ձ���ȵ��մ���ȵ�ʱ����Զ�+1
else
   select @eetime = @e_time
select @oarr   = convert(datetime,convert(char(8),@oarr  ,1)) 
select @odep   = convert(datetime,convert(char(8),@odep  ,1))


----------------------------------------------------------------------------
--	�����Ա������ж�
----------------------------------------------------------------------------
if @groupno <> ''
begin
	if @rmnum > 1 
	begin
		select @ret = 1,@msg = "�����Ա�ķ���ֻ�� = 1"
      goto RET_P
	end

	if charindex(@grpsta,'RCGI') = 0
	begin
		if charindex(@mststa,'RCG') > 0
		begin
			select @ret = 1,@msg = "������������ЧԤ����Ǽ�״̬"
			goto         RET_P
		end
		else if charindex(@mststa,'I') > 0
		begin
			select @ret = 1,@msg = "���������ǵǼ�״̬"
			goto         RET_P
		end
	end
   else if charindex(@grpsta,'RCG') > 0
	begin
		if charindex(@mststa,'I') > 0
		begin
			select @ret = 1,@msg = "���������ǵǼ�״̬,�����������Ǽ�"
         goto         RET_P
		end
	end

--	-- ����
--   if exists (select 1 from grprate where accnt = @groupno and type =@rm_type)
--	begin
--      if @rm_type <> @otype  -- �϶�����
--		begin
--         select @qtrate = rate from grprate where accnt = @groupno and type = @rm_type
--         select @setrate = @qtrate 
--         update master set qtrate = @setrate,rmrate=@setrate, setrate=@setrate  where accnt = @accnt 
--		end 
--	end 
--   else
--	begin
--	   select @ret = 1,@msg ="��δ�������� "+@groupno+" �ķ��෿��:"+@rm_type
--      goto   RET_P
--	end

   if not (@s_time >=@grparr and @s_time <= @grpdep and @e_time >=@grparr and @e_time <= @grpdep) 
		and charindex(@mststa,'RCG')>0  -- Ԥ��״̬���������ն�Ҫ�ж� !
	begin
		select @ret = 1,@msg ="proc : �����Ա�������ڲ��ܳ�������������������"
      goto   RET_P
	end
   if not (@e_time >=@grparr and @e_time <= @grpdep)  -- �Ѿ���ס�ˣ�ֻ�ж�����
		and charindex(@mststa,'I')>0
	begin
		select @ret = 1,@msg ="proc : �����Ա�������ڲ��ܳ�������������������"
      goto   RET_P
	end
end

----------------------------------------------------------------------------
--	ȡ������ 070918 simon 
----------------------------------------------------------------------------
declare @pc_id char(4), @shift char(1), @count int 
select @count = count(1) from auth_runsta where host_id=@host_id and status='R' and empno=@empno 
if @count=1 
begin
	select @pc_id=pc_id, @shift=shift from auth_runsta where host_id=@host_id and status='R' and empno=@empno 
	if rtrim(@shift) is null or charindex(@shift, '12345')=0 select @shift='3' 
end
else
	select @pc_id='pcid', @shift='1'

if charindex(@mststa,'OXND')>0 and charindex(@omststa,'RI')>0
begin
	update accredit set tag='5', empno2=@empno, bdate2=@bdate, shift2=@shift, log_date2=getdate() 
		where accnt=@accnt and tag='0' 
	update master set accredit=0, limit=0 where accnt=@accnt 
end

----------------------------------------------------------------------------
--	�Ƿ��������Ԥ�����ж� 
----------------------------------------------------------------------------
if @mststa = @omststa and @s_time = @oarr and @e_time = @odep and @rm_no = @oroomno and @rm_no>='0' and @rmnum=@ormnum and @blkcode=@oblkcode 
   select @skip_block = 1
if @mststa <> @omststa or @rm_no <> @oroomno or (@rm_type <> @otype and @rm_no<'0' and @oroomno<'0')
   select @needtotran = @needtotran+'R'


----------------------------------------------------------------------------
-- ��� rmsta���жϣ� @rm_no �Ƿ���ڡ� rmsta accntset
--	ע���ų����ⷿ��
----------------------------------------------------------------------------
if @rm_no>'0'
begin
   select @ocsta=ocsta, @rmsta=sta, @number=number,@rm_type=type,@tmpsta=tmpsta from rmsta where roomno = @rm_no
   if @@rowcount = 0
	begin
		select @ret = 1,@msg = "ϵͳ�л�δ��˷��� - %1^" + @rm_no
      goto         RET_P
	end
	-- �ж�[@s_time, @e_time)�ڼ�÷��Ƿ����� ----by yjw   ��ǰ��rmsta��ȡ,���ڴ�rm_ooo��ȡ
	if exists(select 1 from rm_ooo where roomno = @rm_no and status = 'I' --and sta = 'O'
		and (dend is null or datediff(dd,dend, @s_time)<0) and datediff(dd,dbegin,@eetime)>0)
	begin
		select @ret = 1,@msg = "�÷��ڵ����ڼ佫ά��, ���뷿��������ϵ"
      goto         RET_P
	end

	-- �෿��ס���ж�
	if @mststa='I' and @omststa <> @mststa and @ocsta='V' and @rmsta = 'D' 
		and @allow_dirty_register_in = 'N'   --- and charindex(@idcheck,'T')=0
	begin
		select @ret = 1,@msg ="�÷�δ���,������ס"
		goto        RET_P
	end
	-- ����Ԥ������ʱ̬��
	if @mststa in ('R','C','G') and (@rm_no <> @oroomno or @mststa<>@omststa)
		and @tmpsta<>'' and datediff(dd,@s_time,getdate())=0
		and exists(select 1 from rmstalist1 where code=@tmpsta and rlock='T')
	begin
		select @ret = 1,@msg ="�÷����ڴ�����ʱ����״̬, ���� !"
		goto        RET_P
	end
	
	-- ������ס����ʱ̬��
	if @mststa='I' and (@oroomno <> @rm_no or @mststa<>@omststa) and @tmpsta<>''
		and exists(select 1 from rmstalist1 where code=@tmpsta and ilock='T')
	begin
		select @ret = 1,@msg ="�÷����ڴ�����ʱ����״̬, ���� !"
		goto        RET_P
	end

   if @oroomno <> @rm_no
	begin
      if @oroomno>'0' and charindex(@omststa,'RCGI') > 0  -- ����
		begin
			update rmsta set logmark=logmark+1,empno=@empno,changed=getdate() where roomno = @oroomno
			if charindex(@mststa,'RCGI') > 0  -- ��� if...else...�ĺ��治�ǰ�����ǰ���� ?
				update rmsta set logmark=logmark+1,empno=@empno,changed=getdate() where roomno = @rm_no 
			else
				update rmsta set sta = sta where roomno = @rm_no and @mststa = 'I' 
		end
      else		-- �ַ�
		begin
         if charindex(@mststa,'RCGI') > 0
            update rmsta set sta = sta,logmark=logmark+1,empno=@empno,changed=getdate() where roomno = @rm_no 
         else
            update rmsta set sta = sta where roomno = @rm_no and @mststa = 'I' 
		end 
	end 
   else if @mststa <> @omststa or charindex('A',@needtotran) > 0 or charindex('D',@needtotran) > 0 
      update rmsta set sta = sta,logmark=logmark+1,empno=@empno,changed=getdate() where roomno = @rm_no 

   if @skip_block <> 0
      goto RET_S		-- ���� Ԥ�����ж�
end 
else if @oroomno>'0' and charindex(@omststa,'RCGI') > 0  -- ȡ���ַ�
	update rmsta set logmark=logmark+1,empno=@empno,changed=getdate() where roomno = @oroomno

-- 
select @msg = @msg + @rsvchk 

---------------------------------------
-- Ԥ��������------�ȸ������ж�
---------------------------------------
-- 1. ȡ���ͷ���Դ
---------------------------------------
if charindex(@mststa,'RCGI') = 0    -- ------> not reserve sta 
begin
	-- ����Ԥ����
   if charindex(@omststa,'RCGI') <> 0  -- Cancel a reservation etc...... 
	begin
		-- �����ж����¼
		declare	@id		int
		while exists(select 1 from rsvsrc where accnt=@accnt)
		begin
			select @id=max(id) from rsvsrc where accnt=@accnt
			exec p_gds_reserve_rsv_del @accnt,@id,'R',@empno,@ret output, @msg output
		end
	   if charindex(@omststa,'I') <> 0  -- checkout etc ...... 
		   exec p_gds_reserve_flrmsta @oroomno,@accnt,'DELE',@empno
	end
   goto RET_S 
end
---------------------------------------
-- 2. ȡ��,���߸��� �ͷ���Դ
---------------------------------------
else     -----> reserve sta 
begin
	-- �жϳ�ͻ
	if @rm_no >= '0' 
	begin
		declare	@conflict	int
		select @conflict = isnull((select count(1) from master a
												where a.sta in ('R', 'I') and a.roomno=@rm_no 
													and a.share<>'T'
													and a.accnt<>@accnt 																			-- �ų��Լ�
													and a.master<>@master 																		-- �ų�ͬס
													and a.accnt not in (select accnt from host_accnt where host_id=@host_id) 	-- �ų�ͬ������
													and datediff(dd, @s_time, a.dep)>0 and datediff(dd, @e_time, a.arr)<0
													--and not (@groupno<>'' and a.groupno=@groupno) --�Ŷ�Ϊ���ų�����ȥ��(��Ϊ������������û������)
										), 0)
		if @conflict > 0 
		begin
		select @saccnt = isnull((select max(a.accnt) from master a
												where a.sta in ('R', 'I') and a.roomno=@rm_no 
													and a.share<>'T'
													and a.accnt<>@accnt 																			-- �ų��Լ�
													and a.master<>@master 																		-- �ų�ͬס
													and a.accnt not in (select accnt from host_accnt where host_id=@host_id) 	-- �ų�ͬ������
													and datediff(dd, @s_time, a.dep)>0 and datediff(dd, @e_time, a.arr)<0
													--and not (@groupno<>'' and a.groupno=@groupno)
										), '')
			select @ret = 1,@msg = "�ͷ� %1 �Ѿ���ռ��^" + @rm_no + "("+ @saccnt +")"
			goto RET_P
		end
	end

	-- ��Դ����
	if charindex(@omststa,'RCGI') <> 0 and @omststa<>''	-- ��Դ�仯 
	begin
		exec p_gds_reserve_rsv_mod @accnt,0,@rm_type,@rm_no,'',@marr,@mdep,@rmnum,@gstno,@setrate,'',
			@rmrate,@rtreason,@ratecode,@src,@market,@packages,@srqs,@amenities,@empno,'R',@ret output, @msg output
		if @ret<>0 
		begin
			select @msg = @msg + '---' + @omststa
			goto RET_P
		end
      if charindex(@omststa,'I') <> 0  
		begin
			if @oroomno<>@rm_no or @mststa<>'I'
				exec p_gds_reserve_flrmsta @oroomno,@accnt,'DELE',@empno
			else --if @nick = 'I' and @mststa='I' and @oroomno=@rm_no
				exec p_gds_reserve_flrmsta @oroomno,@accnt,'DELE!',@empno
--			else
--				exec p_gds_reserve_flrmsta @oroomno,@accnt,'DELE',@empno
		end
	end
	else																	-- ������Դ 
	begin
		if @oroomno<>'' and @rm_no=''
			exec p_gds_reserve_rsv_add @accnt,@rm_type,@rm_no,'Grid-Rood',@marr,@mdep,@rmnum,@gstno,@setrate,'',
				@rmrate,@rtreason,@ratecode,@src,@market,@packages,@srqs,@amenities,@empno,'R',@ret output, @msg output
		else
			exec p_gds_reserve_rsv_add @accnt,@rm_type,@rm_no,'',@marr,@mdep,@rmnum,@gstno,@setrate,'',
				@rmrate,@rtreason,@ratecode,@src,@market,@packages,@srqs,@amenities,@empno,'R',@ret output, @msg output
		-- �����  flrmsta ��������� !
	end
end 

----------------------------------------------------------------------------
-- ����סʱ����ʱrmsta���sccntset��û�и��¡�����ÿ�䷿���� �� fill rmsta
----------------------------------------------------------------------------
if @mststa = 'I'
begin
   select @accntset=accntset,@number = number from rmsta where @rm_no = roomno and charindex(@accnt,accntset) = 0
	if @@rowcount > 0
	begin 
		if @number>=6
		begin
			select @ret = 1,@msg = "�÷����������ʵ�, �����ټ�"
			goto        RET_P
		end
		exec p_gds_reserve_flrmsta @rm_no,@accnt,'ADD',@empno
	end
end 


---------------------------------------------------------
-- ��ʱ����Դ�����Ѿ���ɣ������ж���Դ�ɷ�ռ�� 
---------------------------------------------------------
-- ɢ�͵�������ѷַ� �� ��ҪԤ������  (�����Ա���������Ҫ���� ?)
---------------------------------------------------------
select @pblkno = 0, @prmtk = 0
if @groupno<>'' and ( @rm_no>='0' or charindex(@cntlblock,'tT') > 0 )
begin		-- ������ɢ�Ͷ���䷿��������δ��� ? gds
   exec p_getavail @accnt,@omststa,@rm_type,@rm_no,@s_time,@e_time,@otype,@oroomno,@oarr,@odep,@pblkno output,@prmtk output
   if @pblkno < 0 and charindex(@cntlblock,'tT') > 0 and ( @rm_no<'0' or @allow_check_roomno_first <> 'Y')
	begin
      select @ret = 1,@msg = "û���㹻�ķ�����Դ,�뻻��������й���Ա����Ԥ�����Ʋ���"
      goto         RET_P
	end
end

--------------------------------------
-- ����˳�����,������½�� 
--------------------------------------
RET_S:
if @ret=0
begin
	-- �賿�������� 2007.5 
	if @class='F' and (@omststa='' or @omststa='R' or @omststa='C' or @omststa='G') and @mststa='I' 
	begin
		if exists(select 1 from sysoption where catalog='ratemode' and item='new_morning_post' and (value='T' or value='t'))
			begin
			exec @ret = p_gl_audit_rmpost_added '02', @pc_id, 0, @shift, @empno, @accnt, 'RN'
			if @ret<>0 
				select @msg='�賿�������˴���'
//			else
//				begin
//				--ҹ��󵽵�Ŀ��ˣ��賿���շ��ѵ�ʱ������а��ۣ�����۵�ʹ��ʱ��Ҫ����
//				update package_detail set starting_date = bdate,closing_date = dateadd(dd,1,bdate) where accnt = @accnt
//				--FHB Added At 20091104 For package_detail To pos_package_detail
//				declare c_package cursor for select number,quantity from package_detail where accnt = @accnt
//				open c_package
//				fetch c_package into @number1,@quantity
//				while @@sqlstatus = 0
//				begin
//					while @quantity>0
//					begin
//						select @num = isnull(max(number),0) + 1 from pos_package_detail where accnt = @accnt
//						insert pos_package_detail  (accnt,number,roomno,name1,fname,name2,name4,username,arr,dep,groupno,groupname,pcrec,code,descript,
//										descript1,price,pccode,pos_pccode,pos_shift,pos_menu,pos_number,bdate,pos_sta,pda_date,sta,pc_id,empno,shift,bdate1,remark,quantity )
//						select a.accnt,@num,a.roomno,b.name,isnull(rtrim(b.fname),'')+isnull(rtrim(b.lname),''),b.name2,b.name4,b.name,c.arr,
//								 c.dep,c.groupno,e.name,c.pcrec,a.code,a.descript,a.descript1,f.amount,f.pccode,f.pos_pccode,f.type,'',1,a.starting_date,
//									'N',null,'N','','','',null,'',1
//						from package_detail a,guest b,master c,guest e,package f
//								where a.accnt = @accnt and a.number = @number1 and a.accnt = c.accnt and c.haccnt = b.no and c.haccnt *= e.no and  a.code = f.code
//						select @quantity = @quantity - 1
//					end
//					fetch c_package into @number1,@quantity
//				end
//	
//				close c_package
//				deallocate cursor c_package
//				end
				
			end 
	end

	if @ret=0 and charindex(@class, 'GM')>0 
		exec @ret = p_gds_update_group @accnt, @empno, @grpmstlogmark,@msg output
	if @ret=0
	begin
		if @mststa=@omststa or @mststa=@nick  --sta �����仯��ʱ��bdate �仯
			update master set osta = sta ,otype = @rm_type,type = @rm_type,oroomno = roomno,
				oarr = arr, odep = dep, ormnum=rmnum, oblkcode=blkcode  where accnt = @accnt
		else
		begin
			if exists(select 1 from gate where audit = 'T') and @mststa='N'  -- ���ڻ���, No-Show
				select @bdate = dateadd(dd, -1, @bdate)
			update master set osta = sta ,otype = @rm_type,type = @rm_type,oroomno = roomno,
				oarr = arr, odep = dep, ormnum=rmnum, bdate=@bdate, oblkcode=blkcode  where accnt = @accnt
		end
		 
		--modi by zk 2009-5-21 ������Դ�����master�ֶεı䶯
		select @master = master from master where accnt = @accnt
		if @master = '' 
			update master set master = accnt where accnt = @accnt
  
		if @groupno <> ''  -- and @ndmaingrpmst = 1 
			exec @ret = p_gds_maintain_group @groupno,@empno,@grpmstlogmark,@msg output
	end 
end
if @ret <> 0
   rollback tran p_gds_reserve_chktprm_son_s1
else
begin
	if datalength(@needtotran) > 0 and @nullwithreturn is not null
   	select @msg = 'guestmodified'
	if @mststa<>@omststa and (@mststa='I' or @omststa='I') 
	begin
		if @rm_no>='0' 
			exec p_gds_lgfl_rmsta @rm_no 
		if @rm_no<>@oroomno and @oroomno>='0' 
			exec p_gds_lgfl_rmsta @oroomno 
	end 
	exec p_yjw_rsvsrc_detail_accnt @accnt
end 
commit tran

if @nullwithreturn is null
   select @ret,@msg
else
   select @nullwithreturn = @msg
return @ret


--------------------------------------
-- ���������ع��˳�
--------------------------------------
RET_P:
rollback tran p_gds_reserve_chktprm_son_s1
commit   tran 

if @nullwithreturn is null
   select @ret,@msg 
else
   select @nullwithreturn = @msg
return @ret
;