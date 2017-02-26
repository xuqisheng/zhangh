
if exists(select 1 from sysobjects where name = "p_gds_update_room_status" and type = 'P')
   drop proc p_gds_update_room_status;
create proc p_gds_update_room_status
   @rm_no   char(5),     	-- ���� 
   @lockop  char(1),     	-- �������:'L',Ϊ����������,'l',Ϊ����������,
									--	 ����Ϊһ�����
                         
   @sta     char(1),     -- ��״̬ 
   @s_time  datetime,    -- ������ʼ����,��δ������������ 
   @e_time  datetime,    -- ������������ 
   @empno   char(10),     -- ����Ա���� 
   @retmode char(1),     -- ���ط�ʽ   
   @msg     varchar(60)  output 

as

-- ---------------------------------------------------------------------------
--		�޸ķ�̬
--
--			״̬���࣭1: R, D, I, T  -- û��ʱ���ԣ������޸ģ���ͷ��Ƿ�ռ�á�Ԥ���޹ء�
--											���У�I, T �����ַ�̬�е��û����ܲ���Ҫ
--
--			״̬���࣭2: O, S        -- ��ʱ���ԣ���һ�������޸�
--											Ŀǰ��ϵͳ���ĳ�ͷ�����Чά�޼�¼ֻ��Ϊ 1 ����
--											��Ϊ��״̬��ʱ����Ҫ���� rmsta ����
-- ---------------------------------------------------------------------------

declare
   @t_time   	datetime,
   @ret      	int,
   @cgetdate 	datetime,
   @ocsta    	char(1),
   @osta     	char(1),
	@rmtype		char(5),
	@over			int,
	@locked char(1), @futbegin datetime, @futend datetime

select @ret=0,@msg='',@cgetdate = convert(datetime,convert(char(10),getdate(),111))
select @rmtype = type from rmsta where roomno = @rm_no
if @@rowcount = 0
begin
	select @ret=1,@msg= '%1 - ���Ų�����^'+@rm_no 
	if @retmode ='S'
		select @ret,@msg
	return @ret
end

begin tran
save  tran p_gds_update_room_status_s1

update rmsta set sta = sta where roomno = @rm_no
select @ocsta = ocsta,@osta = sta from rmsta where roomno = @rm_no

-- ά�� ��ά��������
if charindex(@lockop,'lL') > 0
	begin
   if @lockop ='l'  -- ����
	   begin
	   if exists(select 1 from rmstalist where sta = @osta and maintnmark='T')
		   begin
		   if exists(select 1 from rmstalist where sta = @sta and charindex(maintnmark,'T') = 0)
			   update rmsta set logmark=logmark+1,sta = @sta,empno = @empno,changed = getdate(),locked = 'N',futbegin = null,futend = null,fempno = @empno,fcdate = getdate(),osno='' where roomno = @rm_no
         else
			   select @ret = 1,@msg = '�����ǰά����״̬��,���跿̬��Ч'
         end 
	   else
		   update rmsta set logmark=logmark+1,locked = 'N',futbegin = null,futend = null,fempno = @empno,fcdate = getdate() where roomno = @rm_no
	   end
   else				-- ����
	   begin
	   select @s_time = convert(datetime,convert(char(10),@s_time,111))
	   select @e_time = convert(datetime,convert(char(10),@e_time,111))
	   if @s_time is not null and @e_time is not null
		   begin
		   if @s_time > @e_time
            begin
			   select @t_time = @s_time
			   select @s_time = @e_time
			   select @e_time = @t_time  
			   end
		   if @s_time = @e_time
		      select @e_time = dateadd(day,1,@s_time) 
		   end
	   else if @s_time is null
		   select @ret=1,@msg='��ָ��������ʼ����'
	   if @ret = 0 and @s_time <  @cgetdate
		   select @ret=1,@msg='������ʼ���ڲ���С�ڽ���'

	   if @ret = 0 and @sta<>'S'  -- ���������ò��ж� 
         begin
			-- �Ƿ���Ҫ�ж���Դ�أ� - ���ֻ���޸�ά�޼�¼�����Բ��ж���
			select @locked=locked, @futbegin=futbegin, @futend=futend from rmsta where roomno=@rm_no 
			if not (@locked='L' and datediff(dd, @futbegin, @s_time)>=0 and datediff(dd, @futend, @e_time)<=0 )
			begin
				-- ��Դ�ж�
				exec @ret = p_gds_reserve_type_avail @rmtype,@s_time,@e_time,'1','R',@over output
				if @ret<>0 or @over<0
					select @ret=1, @msg='�ͷ���Ԥ��'
				else
					begin
					exec p_gds_reserve_ctrltype_check @rmtype, @s_time, @e_time, 'R', @over output
					if @over > 0
						select @ret=1, @msg='��ͷ���Ԥ��'
					else
						begin 
						exec p_gds_reserve_ctrlblock_check @s_time, @e_time, 'R', @over output
						if @over > 0
							select @ret=1, @msg='�ͷ��������Ƴ���'
						else
							begin
							if exists (select roomno from rsvroom where roomno = @rm_no and quantity > 0
											 and ((@e_time is null and @s_time < end_) or (@e_time > begin_ and end_ > @s_time)))
								select @ret=1,@msg='ָ������������÷�����Ԥ��,����'
							end
						end 
					end
				end 
         end 
		else if @ret = 0 and @sta='S'
			begin
			select @locked=locked, @futbegin=futbegin, @futend=futend from rmsta where roomno=@rm_no 
			if not (@locked='L' and datediff(dd, @futbegin, @s_time)>=0 and datediff(dd, @futend, @e_time)<=0 )
				begin
				if exists (select roomno from rsvroom where roomno = @rm_no and quantity > 0
						 and ((@e_time is null and @s_time < end_) or (@e_time > begin_ and end_ > @s_time)))
				select @ret=1,@msg='ָ������������÷�����Ԥ��,����'
				end
			end

	  if @ret = 0
		  begin
		  if exists(select 1 from rmstalist where sta = @sta and maintnmark='T')
			  begin
  		     update rmsta set  logmark=logmark+1,locked='L',futsta=@sta,futbegin = @s_time,futend = @e_time,
	                          fempno = @empno,fcdate = getdate()
						      where roomno = @rm_no
		     if @@rowcount > 0 and @s_time = @cgetdate
				  update rmsta set sta = @sta,empno = @empno,changed = getdate()
                     where roomno = @rm_no -- and ocsta = 'V'
			  end
		  else
			  select @ret=1,@msg='ά��������ʱ,��ָ�������ά��״̬'
		  end
	  end
	end

-- һ�㴦��
else
   begin
   if exists(select 1 from rmstalist where sta = @sta and charindex(maintnmark,'T') > 0 )
	   select @ret=1,@msg='Ҫ�ĳ�ά����,��ʹ��ά������������'
   else if not exists(select 1 from rmstalist where sta = @sta and charindex(maintnmark,'T') = 0 )
	   select @ret=1,@msg='��ʹ��ϵͳ�趨�ķ�̬'
   else if exists(select 1 from rmstalist where sta = @osta and charindex(maintnmark,'T') > 0 )
	   select @ret=1,@msg='Ҫ���ά����,��ʹ��ά������������'
   else if @sta = @osta 
  	   select @ret=1,@msg='�÷�״̬�Ѿ�������Ҫ���õ�״̬, �������Ϊ'
   else 
	   update rmsta set logmark=logmark+1,sta = @sta,empno = @empno,changed = getdate() where roomno = @rm_no
   end

if @ret <> 0
   rollback tran p_gds_update_room_status_s1
commit tran

if @retmode ='S'
   select @ret,@msg
return @ret
;

