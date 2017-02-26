drop  proc p_gds_int_postcharge;
create proc p_gds_int_postcharge
   @modu_id	    	char(2) ,
   @pc_id	    	char(4) ,
   @shift	    	char(1) ,
   @empno	    	char(10),
	@p_user			varchar(16),
   @p_min      	int,
	@p_charge		money,
   @p_time    		datetime,
   @returnmode  	char(1)      	-- ���ط�ʽ
as
--------------------------------------------------------------------------------------
--		int �Ʒѵ���  exec p_gds_int_postcharge '05','.247','2','8002',60,36,'2009-7-7 16:00','S'
--		
--		2009.8.24 ���Ʊ�ע���ݵ���ʾ 
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
	@ref1				varchar(10),
	@ref2				varchar(50) 

select @ret=0,@msg="",@mprompt = '?'                
select @selemark='aInternet����',@bdate = bdate1 from sysdata

if @p_min%60 = 0 
	select @ref2 = convert(char(10), @p_time, 111)+' '+ convert(char(8), @p_time, 8) +'--'+ convert(char(5),@p_min/60)
else
	select @ref2 = convert(char(10), @p_time, 111)+' '+ convert(char(8), @p_time, 8) +'--'+ convert(char(5),@p_min/60 + 1)

select @sta = ocsta, @accnt = substring(accntset, 1, 10) from rmsta where roomno = @p_user
if exists(select 1 from master where charindex('INT',srqs)>0 and accnt=@accnt )
 	select @ret=1, @msg='��ѿ��!', @mprompt = 'INT FREE'
--if not exists(select 1 from inttoact where int_user = @p_user)
--	select @ret=1, @msg='���û��ʺŲ�û����ǰ̨�ʺ�ע��:'+@p_user, @mprompt = 'NO REG'
--if not exists(select 1 from master where accnt = (select accnt from inttoact where int_user = @p_user))
--	select @ret=1, @msg='���û��ʺŶ�Ӧ��ǰ̨�ʺŲ�������:'+@p_user, @mprompt = 'NO ACT'
--else
--	begin
	select @pccode = value from sysoption where catalog = 'internet' and item = 'pccode'
	if rtrim(@pccode) is null
		select @ret=1, @msg='ϵͳû��ָ��internet���ô���!!', @mprompt = 'NO PCCD'
	else
		if not exists(select * from pccode where pccode = rtrim(@pccode))
			select @ret=1, @msg='ϵͳָ����internet���ô��벻����!!!', @mprompt = 'NO PCCD'

	if @ret = 0
		begin
      select  @selemark = 'a'+'INTERNET FEE'  -- 2003.3
     -- select @pccode = substring(@pccode,1,2) + "A",@package = ' '+substring(@pccode,1,2)
		--exec p_gds_int_calc_fee @p_user, @p_time, @p_min, @p_charge output
     	if @p_charge<>0
		begin
			exec @ret = p_gl_accnt_posting @selemark, @modu_id, @pc_id,0,@shift, @empno, @accnt,0, @pccode, '',1, @p_charge,@p_charge,0,0,0,0,'',@ref2, @bdate, '','', 'IRYY', 0, '', @msg out
		   if @ret <> 0
			   select @mprompt = 'NO POST'
			else
			   select @sucmark = 'T',@mprompt = @accnt
		end
		else
			 select @mprompt = 'FREE'
		end
--	end
              
select @id = isnull((select max(inumber)from intfolio),0) + 1
insert intfolio(inumber, log_date,  int_user, date,    minute, amount,   refer, empno, shift)
	      values(@id,     getdate(), @p_user,  @p_time, @p_min, @p_charge, @mprompt, @empno, @shift)

if @returnmode = 'S'
   select @ret,@msg,@mprompt,@id, @p_charge

return @ret
/* ### DEFNCOPY: END OF DEFINITION */
;