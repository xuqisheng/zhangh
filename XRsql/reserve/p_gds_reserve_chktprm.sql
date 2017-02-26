
-- ���������� 
//if exists(select * from sysobjects where name = "host_accnt" and type='U')
//	drop table host_accnt;
//create table host_accnt
//(
//	host_id		varchar(30)		default '' 	not null,
//   accnt     	char(10) 				not null
//)
//exec sp_primarykey host_accnt,host_id,accnt;
//create unique index index1 on host_accnt(host_id,accnt);


if exists(select * from sysobjects where name = "p_gds_reserve_chktprm")
	drop proc p_gds_reserve_chktprm
;
create proc p_gds_reserve_chktprm
	@accnt           char(10),        -- �ʺ� 
	@request         char(20),        -- �����ǳ���Ҫ�Ĳ�������������
	@idcheck         char(1),        -- �ж��෿��ס 
	@empno           char(10),        -- ����Ա
	@nick           char(5),        -- �����������
	@ndmaingrpmst    int,				-- �Ƿ�Ҫά���������� 
	@grpmstlogmark   int,  				-- �Ƿ�Ҫ��¼��־ 
	@nullwithreturn  varchar(60) = null output
as
-- ------------------------------------------------------------------------------------
--
--	p_gds_reserve_chktprm
--		in SC, using - p_gds_sc_chktprm 
--		
--		ȫ�µ��ŷ�����
--		ע��������ⷿ�ŵĴ���:  roomno>='0' ��ʾ�ַ���, �����ʾû�зַ�.
-- ------------------------------------------------------------------------------------

-- ------------------------------------------------------------------------------------
-- 	�ַ�,�˷�,����,Ԥ��ת��ס,Ԥ��ȡ��,Ԥ���ָ�,���������˷���״̬ת������ǰ,���ڵ����ڸ��ĵ�
-- 	�������̸����˿�����Ϣʱ,���ر�־�����Ӧ������ȷ��¼������־
-- ------------------------------------------------------------------------------------
declare
	@ret        int,
   @msg        varchar(60),
	@class 		char(1),
	@bdate      datetime,
	@accnt0		char(10),		-- ԭʼ�� accnt 
	@saccnt		char(10),
	@master		char(10),
	@host_id		varchar(30),
	@mststa     char(1),				@omststa    char(1),
	@type    	char(5),				@otype      char(5),
	@roomno		char(5),				@oroomno    char(5),
	@s_time     datetime,			@oarr       datetime,
	@e_time     datetime,			@odep       datetime,
	@rmnum		int,					@ormnum		int,
	@blkcode		char(10),			@oblkcode	char(10),
	@count		int,
	@oldsta		char(1),	-- �ʺ�ԭ����״̬
	@staup		char(1),	-- ״̬ͬ������
	@gstno		int

declare
	@blkup		char(1),			-- ͬ���Ƿ���� BLOCK 
	@blkno		char(10),		
	@blknos		varchar(100),	-- һ��ͬס��������ж�� BLKCODE 
	@blktype		char(5),
	@blkarr		datetime,
	@blkdep		datetime

declare @tran_save_point varchar(32) 
select @tran_save_point = 'p_gds_reserve_chktprm_s' + ltrim(convert(char(10), @@trancount)) 

select @ret=0, @msg='', @accnt0=@accnt

-- ���ͬס/��������˺�
select @host_id = host_id()
delete host_accnt where host_id=@host_id

-- ����ʼ
begin tran 
save  tran @tran_save_point

-- ���������ź�
update chktprm set code = 'A'  

-- �� master ����ȡ����
select @mststa=sta, @omststa=osta, @type=type, @otype=otype, @roomno=roomno, @oroomno=oroomno,
		@s_time=arr, @e_time=dep, @oarr=oarr, @odep=odep, @rmnum=rmnum, @ormnum=ormnum,
		@class=class, @saccnt=saccnt, @master=master, @blkcode=blkcode,  @oblkcode=oblkcode 
	from master where accnt = @accnt
if @@rowcount = 0
begin
	select @ret = 1, @msg='��¼������'
	goto RET_P
end

-- �������ķ������⴦�� 
if @class in ('G','M','C') 
begin
	if @type<>'' and not exists(select 1 from typim where type=@type and tag='P')
	begin
		select @ret = 1, @msg='%1��ƥ��^����'
		goto RET_P
	end
	select @rmnum=1, @ormnum=1, @gstno=0 
end

--
if @class in ('G','M')
begin 
	if @blkcode<>'' and exists(select 1 from rsvsrc where accnt=@accnt and type<>'PM')
	begin
		select @ret = 1, @msg='Ӧ��BLOCK��ʱ�򣬲�������Ԥ����Դ'
		goto RET_P
	end
end 

-- û�����üٷ���ʱ��ֱ���˳�
if @class in ('G','M','C')  and (@type='' and @otype='')
begin
	if @class<>'C' 
		exec @ret = p_gds_update_group @accnt, @empno, @grpmstlogmark,@msg output
	goto RET_P
end 

if @class='F' and rtrim(@type) is null 
begin
	select @ret = 1, @msg='�������'
	goto RET_P
end

if @roomno=null  select @roomno=''
if @roomno='' and @oroomno like '#%' 
	select @roomno=@oroomno 
if @omststa='' select @omststa = ''

--
if (charindex(@mststa,'RICG')=0 and charindex(@omststa,'RICG')=0)
	or ( @mststa=@omststa and @type=@otype and @roomno=@oroomno and @rmnum=@ormnum and @blkcode=@oblkcode 
			and datediff(dd,@s_time,@oarr)=0 and datediff(dd,@e_time,@odep)=0 )
begin
	-- ������ʱ�����
	update rsvsrc set arr=a.arr from master a 
		where a.accnt=@accnt and rsvsrc.accnt=a.accnt and datediff(dd,rsvsrc.arr,a.arr)=0 and rsvsrc.arr<>a.arr and rsvsrc.id=0
	update rsvsrc set dep=a.dep from master a 
		where a.accnt=@accnt and rsvsrc.accnt=a.accnt and datediff(dd,rsvsrc.dep,a.dep)=0 and rsvsrc.dep<>a.dep and rsvsrc.id=0

	select @ret = 0, @msg='���漰�ͷ���Դ�仯'
	--���ÿ�շ��ۼ�¼�����뵽rsvsrc_detail   yjw 2008-5-29
	exec p_yjw_rsvsrc_detail_accnt @accnt
	--
	goto RET_P
end

-- ȱʡ�Զ�ͬ��
if @nick is null or @nick<>'p'
	select @nick = 'U'

----------------------------------------------------------------------------------------------------------------------
-- ״̬ͬ����������ס.   �������У����磺Ԥ��ȡ������סȡ�������˵ȣ��е���Ҫ���ɣ��еĵ�ȷ��Ҫ�������
----------------------------------------------------------------------------------------------------------------------
if @mststa<>@omststa
begin
	if @mststa='I' and @omststa not in ('O', 'S')
		select @staup = 'T'
	else
		select @staup = 'F'
end
else
	select @staup = '-'

-----------------------------------------------------------
-- ����ͬס����������ɾ��ԭ����Ԥ����ȫ�������µ�Ԥ������
-----------------------------------------------------------
-- ��¼���
insert host_accnt select @host_id, accnt from rsvsrc where saccnt=@saccnt
-- select @count = count(1) from rsvsrc a, rsvsrc b where a.accnt=@accnt and a.saccnt=b.saccnt
select @count = count(1) from host_accnt where host_id=@host_id 

if @count > 1 and  @nick = 'U' and @staup <> 'F' 
begin
	-- ɾ��Ԥ����¼�������BLOCK��Դ����Ҫ�����ͷ� 
	if exists(select 1 from rsvsrc where saccnt=@saccnt and blkcode<>'') 
		select @blkup='T' 
	else 
		select @blkup='F' 
	if @blkup='T' 
	begin 
		delete rsvsrc_blk where host_id=@host_id
		select @blktype=type, @blkarr=begin_, @blkdep=end_ from rsvsaccnt where saccnt=@saccnt 
		select @blkno = '', @blknos = ''
		select @blkno = isnull((select min(blkcode) from rsvsrc where saccnt=@saccnt and blkcode>@blkno), '') 
		while @blkno <> ''
		begin 
			select @blknos = @blknos + @blkno  -- ��ͬס���漰�� blkcode �������� 
			exec p_gds_reserve_rsv_blkdiff @host_id, @blkno, @blktype, @blkarr, @blkdep, 'before+'
			select @blkno = isnull((select min(blkcode) from rsvsrc where saccnt=@saccnt and blkcode>@blkno), '') 
		end 
	end 

	exec p_gds_reserve_rsv_del_saccnt @saccnt
	delete rsvsrc where saccnt=@saccnt

	if @blkup='T' 
	begin 
		select @blknos = ltrim(@blknos)
		while rtrim(@blknos) is not null
		begin 
			select @blkno = substring(@blknos, 1, 10) 
			select @blknos = ltrim(stuff(@blknos, 1, 10, ''))

			exec p_gds_reserve_rsv_blkdiff @host_id, @blkno, @blktype, @blkarr, @blkdep, 'after+'
		end 
		exec @ret = p_gds_reserve_rsv_blkuse @host_id, '', @blktype, @empno 
		delete rsvsrc_blk where host_id=@host_id
		if @ret<>0
		begin 
			select @msg='chktprm blkup error' 
			goto RET_P
		end 
	end 
	
	-- ͬ���������ⷿ�ſ��Բ��� 
	if @roomno < '0'
	begin
		if @oroomno >= '0' -- ȥ�����ŵģ���Ҫ�������ⷿ�ţ�ԭ���з��ŵģ������ǲ�������ģ������ֲ��� 
		begin
			exec p_GetAccnt1 'SRM', @roomno output
			select @roomno = '#' + rtrim(@roomno)
		end
	end
	
	-- work one by one 
	declare	@gsta 		char(1), 
				@gtype 		char(5), 
				@groomno 	char(5), 
				@garr 		datetime, 
				@gdep 		datetime 

	select @accnt = isnull((select min(accnt) from host_accnt where host_id=@host_id and accnt>''), '')
	while @accnt <> ''
	begin
		select @gsta=osta, @gtype=otype, @groomno=oroomno, @garr=oarr, @gdep=odep from master where accnt=@accnt
		select @oldsta = @gsta

		-- ԭ����ס�Ŀͷ�����Ҫ���� rmsta 
		if @gsta = 'I' and @groomno>='0' and (@groomno <> @roomno or (@groomno = @roomno and @mststa <> 'I'))
	   	exec p_gds_reserve_flrmsta @groomno,@accnt,'DELE',@empno

		----------------------------------------------------------------------
		-- ͬ�����������µ���ס��Ϣ���磺arr, ����ϵ���Ϣ���磺oarr 
		----------------------------------------------------------------------
		if @accnt <> @accnt0 
		begin
			--		����ͬ��������saccnt ��ͬ
			select @gtype=@type, @groomno=@roomno
			-- ״̬ 
			if @staup='T' and @oldsta=@omststa
				select @gsta = @mststa 
			-- 	����ͬ����������Ӧ�ֶε�������ͬ����arr��ͬ������dep��ͬ
			if datediff(dd,@oarr,@garr)=0 and datediff(dd,@oarr,@s_time)<>0
				select @garr = @s_time
			if datediff(dd,@odep,@gdep)=0 and datediff(dd,@odep,@e_time)<>0
				select @gdep = @e_time
	
			-- �Ѿ���ס�Ĳ����޸ĵ��� modi by zk 2008-10-20
			if @class='G' or @class='M' -- �Ŷӻ��鲻���� ormnum  -- �ƺ�ͬ�����治������Ŷ�Ŷ 
				begin
				update master set otype='', type=@gtype, oroomno='', roomno=@groomno, -- ormnum=0, 
									osta='', sta=@gsta, arr=@garr, oarr=null, dep=@gdep, odep=null, oblkcode='' 
					where accnt = @accnt and sta <> 'I' 
				update master set otype='', type=@gtype, oroomno='', roomno=@groomno, -- ormnum=0, 
									osta='', sta=@gsta, oarr=null, dep=@gdep, odep=null, oblkcode='' 
					where accnt = @accnt and sta = 'I'
				end
			else 
				begin
				update master set otype='', type=@gtype, oroomno='', roomno=@groomno, ormnum=0, 
									osta='', sta=@gsta, arr=@garr, oarr=null, dep=@gdep, odep=null, oblkcode='' 
					where accnt = @accnt and sta <> 'I'
				update master set otype='', type=@gtype, oroomno='', roomno=@groomno, ormnum=0, 
									osta='', sta=@gsta, oarr=null, dep=@gdep, odep=null, oblkcode='' 
					where accnt = @accnt and sta = 'I'
				end
		end 
		else
		begin
			if @class='G' or @class='M' -- ������ ormnum 
				update master set otype='', roomno=@roomno, oroomno='',           osta='', oarr=null, odep=null, oblkcode='' where accnt = @accnt
			else
				update master set otype='', roomno=@roomno, oroomno='', ormnum=0, osta='', oarr=null, odep=null, oblkcode='' where accnt = @accnt
		end

		if exists(select 1 from host_accnt where host_id=@host_id and accnt>@accnt)
			select @msg = 'rsvchk=0;'  -- ͬ����ǰ���ʻ�������Դ��� 
		else 
			select @msg = ''
		exec @ret = p_gds_reserve_chktprm_son @accnt,@request,@idcheck,@empno,@oldsta,@ndmaingrpmst,@grpmstlogmark,@msg output  -- nick->share 
		if @ret<>0
			goto RET_P
		else if @accnt<>@accnt0 -- ��¼��־��@accnt0 �ڿͻ����Ѿ���¼�� 
			update master set cby=@empno, changed=getdate(), logmark=logmark+1 where accnt=@accnt 
		select @accnt = isnull((select min(accnt) from host_accnt where host_id=@host_id and accnt>@accnt), '')
	end
end
else
begin		-- û��ͬס��¼��ֱ�Ӵ���
	exec @ret = p_gds_reserve_chktprm_son @accnt,@request,@idcheck,@empno,@nick,@ndmaingrpmst,@grpmstlogmark,@msg output
	-- ��ͬס��ϵ�����ǲ�ͬ�����������ʱ����Ҫ���µ��� master  
	if @ret=0 and @count>1 and @mststa=@omststa and @type+@roomno<>@otype+@oroomno 
	begin
		if @accnt = @master 
		begin
			select @master=min(accnt) from host_accnt where host_id=@host_id and accnt<>@accnt 
			update master set master=@master from host_accnt a where a.host_id=@host_id and master.accnt=a.accnt and a.accnt<>@accnt 
		end
		else
			update master set master=accnt where accnt=@accnt 
	end
end

--���ÿ�շ��ۼ�¼�����뵽rsvsrc_detail   yjw 2008-5-29
-- exec p_yjw_rsvsrc_detail_accnt @accnt

-- Proc exit
RET_P:
if @ret <> 0 
	rollback tran @tran_save_point
commit   tran 
delete host_accnt where host_id = @host_id 
if @nullwithreturn is null
   select @ret,@msg 
else
   select @nullwithreturn = @msg
return @ret
;
