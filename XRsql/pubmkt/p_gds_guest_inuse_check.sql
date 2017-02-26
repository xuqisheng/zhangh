if exists(select * from sysobjects where name = "p_gds_guest_inuse_check")
	drop proc p_gds_guest_inuse_check;
create proc p_gds_guest_inuse_check
	@no				char(7),	
	@retmode			char(1) = 'R', 
	@msg				varchar(60)='' output 
as
----------------------------------------------------------------------------------
--  �ͻ������Ƿ����ü�� 
----------------------------------------------------------------------------------
declare		@ret				int,
				@count			int,
				@class		 	char(1) 

select @ret=0, @msg='' 
select @class=class from guest where no=@no 
if @@rowcount=0 
	select @ret=1, @msg='%1������^����'
else if exists(select 1 from master where accnt like '[FGM]%' and (haccnt=@no or cusno=@no or agent=@no or source=@no)) 
	select @ret=1, @msg='��ǰ%1����ʹ�øõ���^����'
else if exists(select 1 from master where accnt like '[C]%' and (haccnt=@no or cusno=@no or agent=@no or source=@no)) 
	select @ret=1, @msg='��ǰ%1����ʹ�øõ���^�����ʻ�'
else if exists(select 1 from master where accnt like '[A]%' and (haccnt=@no or cusno=@no or agent=@no or source=@no)) 
	select @ret=1, @msg='��ǰ%1����ʹ�øõ���^AR�ʻ�'

else if exists(select 1 from ar_master where accnt like '[C]%' and (haccnt=@no )) 
	select @ret=1, @msg='��ǰ%1����ʹ�øõ���^AR�ʻ�'

else if exists(select 1 from sc_master where (haccnt=@no or cusno=@no or agent=@no or source=@no)) 
	select @ret=1, @msg='��ǰ%1����ʹ�øõ���^BLOCK'
else if exists(select 1 from vipcard where (hno=@no or cno=@no or kno=@no)) 
	select @ret=1, @msg='��ǰ%1����ʹ�øõ���^��Ա��'
else if exists(select 1 from pos_reserve where (haccnt=@no or cusno=@no)) 
	select @ret=1, @msg='��ǰ%1����ʹ�øõ���^����Ԥ��'
else if exists(select 1 from sp_reserve where (haccnt=@no or cusno=@no)) 
	select @ret=1, @msg='��ǰ%1����ʹ�øõ���^����Ԥ��'
else if exists(select 1 from pos_menu where (haccnt=@no or cusno=@no)) 
	select @ret=1, @msg='��ǰ%1����ʹ�øõ���^��������'
else if exists(select 1 from sp_menu where (haccnt=@no or cusno=@no)) 
	select @ret=1, @msg='��ǰ%1����ʹ�øõ���^���ֵ���'

-- output 
if @retmode = 'S' 
	select @ret, @msg 
return @ret 
;
