
if exists (select * from sysobjects where name = 'p_gds_int_init')
   drop proc p_gds_int_init;

create proc p_gds_int_init
as
--------------------------------------------------------------------------------------
--		 int �Ʒѳ�ʼ�� 
--------------------------------------------------------------------------------------

truncate table int_src
truncate table int_err

truncate table intfolio
truncate table inthfolio

truncate table inttoact
truncate table inttoact_log

return 0
;

if exists (select * from sysobjects where name = 'p_gds_int_calc_fee') 
   drop proc p_gds_int_calc_fee;

create proc p_gds_int_calc_fee
	@int_user			varchar(16),
	@date					datetime,
	@min					int,
   @amount  			money  output
as
--------------------------------------------------------------------------------------
--   Internet ���õļ���
--------------------------------------------------------------------------------------
declare 	@price		money
select @price = convert(money, rtrim(value)) from sysoption where catalog='internet' and item='min_price'
if @@error <> 0
	select @price = 0.2
else
begin
	if @price > 1
		select @price = 0.2
end

select @amount = @price * @min

return 0
;

if exists (select * from sysobjects where name = 'p_gds_int_postcharge') 
   drop proc p_gds_int_postcharge;

create proc p_gds_int_postcharge
   @modu_id	    	char(2) ,
   @pc_id	    	char(4) ,
   @shift	    	char(1) ,
   @empno	    	char(10) ,
	@p_user			varchar(16),	-- �û�
   @p_min      	int,   			-- ����
   @p_time    		datetime,   	-- �㲥ʱ��  
   @returnmode  	char(1)      	-- ���ط�ʽ  
as
--------------------------------------------------------------------------------------
--			 int �Ʒѵ��� 
--------------------------------------------------------------------------------------
declare
   @ret         int,
   @accnt       char(10),
   @sta         char(1),
   @selemark    char(13),
   @lastnumb    int,
   @inbalance   money,
   @bdate       datetime,
   @sucmark     char(1),
	@id			 int,
   @pccode      varchar(5),     	--Ӫҵ��    
	@package			varchar(5),
   @mprompt     	char(10),
   @msg         	varchar(60),
   @p_charge		money

select @ret=0,@msg="",@mprompt = '?', @p_charge=0
select @selemark='aInternet����', @bdate = bdate1 from sysdata

if not exists(select 1 from inttoact where int_user = @p_user)
	select @ret=1, @msg='���û��ʺŲ�û����ǰ̨�ʺ�ע��:'+@p_user, @mprompt = 'NO REG'
else if not exists(select 1 from master where accnt = (select accnt from inttoact where int_user = @p_user))
	select @ret=1, @msg='���û��ʺŶ�Ӧ��ǰ̨�ʺŲ�������:'+@p_user, @mprompt = 'NO ACT'
else
	begin
	select @pccode = value from sysoption where catalog = 'internet' and item = 'pccode'
	if rtrim(@pccode) is null 
		select @ret=1, @msg='ϵͳû��ָ��internet���ô���!!', @mprompt = 'NO PCCD'
	else
		if not exists(select * from pccode where pccode = @pccode)
			select @ret=1, @msg='ϵͳָ����internet���ô��벻����!!!', @mprompt = 'NO PCCD'

	if @ret = 0
		begin
      select  @selemark = 'a'+'INTERNET FEE'  -- 2003.3
      select @pccode = substring(@pccode,1,2) + "A",@package = ' '+substring(@pccode,1,2)
		exec p_gds_int_calc_fee @p_user, @p_time, @p_min, @p_charge output
     	if @p_charge<>0
		begin
			exec @ret = p_gl_accnt_posting @selemark, @modu_id, @pc_id,0,@shift, @empno, @accnt,0, @pccode, '',1, @p_charge,@p_charge,0,0,0,0,'','', @bdate, '', '', 'IRYY', 0, '', @msg out
		   if @ret <> 0
			   select @mprompt = 'NO POST'
			else
			   select @sucmark = 'T',@mprompt = @accnt
		end
		else
			 select @mprompt = 'FREE'
		end
	end

select @id = isnull((select max(inumber) from intfolio),0) + 1
insert intfolio(inumber, log_date,  int_user, date,    minute, amount,   refer, empno, shift)
	      values(@id,     getdate(), @p_user,  @p_time, @p_min, @p_charge, @mprompt, @empno, @shift)

if @returnmode = 'S'
   select @ret,@msg,@mprompt,@id, @p_charge

return @ret
;


if exists (select * from sysobjects where name = 'p_gds_int_actlnk') 
   drop proc p_gds_int_actlnk
;
create proc p_gds_int_actlnk
	@int_user			varchar(16),
	@accnt				char(10),
	@mode					char(1),
	@empno				char(10),
   @returnmode  		char(1)='R'      	-- ���ط�ʽ  
as
--------------------------------------------------------------------------------------
--   int �ʺ�����
--------------------------------------------------------------------------------------
declare 	@ret int,@msg varchar(60)

select @ret = 0, @msg = '?'

if @ret=0 and charindex(@mode, 'Aa') > 0 
begin
	if not exists(select 1 from master where charindex(sta, 'R,I,S,G,C') > 0 and accnt = @accnt)
		select @ret = 1, @msg = '�����ʺ����� ! -- ' + @accnt
	else if exists(select 1 from inttoact where int_user = @int_user and accnt <> @accnt and charindex(occ,'Tt')>0)
		select @ret = 1, @msg = '�������ʺ��Ѿ���ʹ�� ! -- ' + @accnt
	else if exists(select 1 from inttoact where int_user = @int_user and accnt = @accnt and charindex(occ,'Tt')>0)
		select @ret = 1, @msg = '��Թ�ϵ�Ѿ��趨 !'
	else if exists(select 1 from inttoact where int_user=@int_user)
	begin
		update inttoact set accnt=@accnt, occ='T', date=getdate(), empno=@empno, logmark=logmark+1 where int_user=@int_user
		select @ret = @@error, @msg = '���ݲ������'
	end
	else
	begin
		insert inttoact(int_user,accnt,occ,date,empno) select @int_user, @accnt, 'T', getdate(), @empno
		select @ret = @@error, @msg = '���ݲ������'
		if @@error = 0 
			update inttoact set logmark=logmark + 1 
	end
end
begin
	if exists(select 1 from inttoact where int_user=@int_user)
	begin
		update inttoact set accnt='', occ='F', date=getdate(), empno=@empno, logmark=logmark+1 where int_user=@int_user
		select @ret = @@error, @msg = '���ݲ������'
	end
end
	
if @returnmode = 'S'
	select @ret, @msg

return @ret
;


if object_id('p_gds_internet_pms_set') is not null
	drop proc p_gds_internet_pms_set
;
create proc p_gds_internet_pms_set 
	@username		varchar(16),
	@tag				char(1),
	@empno			char(10)
as
--------------------------------------------------------------------------------------
--   int �ʺ� PMS SET
--------------------------------------------------------------------------------------

if exists(select 1 from internet_pms where username = @username)
	update internet_pms set tag=@tag, changed = 'F', empno=@empno, date=getdate() where username=@username
else
	insert internet_pms(username,tag,changed,empno,date,settime,accnt) 
		select @username, @tag, 'F', @empno, getdate(), getdate(), ''

return 0
;


if exists(select  * from sysobjects where name = 'p_gds_int_deal_data')
	drop proc p_gds_int_deal_data;
create proc p_gds_int_deal_data
as
--------------------------------------------------------------------------------------
-- 	��������: ���� auditprg �У�����ɾ������
--------------------------------------------------------------------------------------

declare 		@delay		int,
				@sdelay		varchar(255),
				@bdate		datetime

select @bdate = bdate1 from sysdata
select @sdelay = ltrim(rtrim(value)) from sysoption where catalog = 'internet' and item = 'src_delay'
if @@error <> 0 or @@rowcount <> 1 or datalength(@sdelay) > 4 
	select @sdelay = '10'
select @delay = convert(int, @sdelay)
if @delay < 0 
	select @delay = 10

delete int_src where datediff(dd, log_date, @bdate) > @delay
delete int_err where datediff(dd, log_date, @bdate) > @delay

return 0;
