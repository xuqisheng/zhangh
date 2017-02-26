-- �Զ���Ϣ���
insert basecode_cat(cat,descript,descript1,len) select 'automsg_type', '��Ϣ���', '��Ϣ���', 10;

insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) 
	select 'automsg_type', 'foxnotify','FOXHIS������ʾ��Ϣ', 'FOXHIS Notify', 'T','T',0,'1';
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) 
	select 'automsg_type', 'sms','����', 'SMS', 'T','T',0,'1';
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) 
	select 'automsg_type', 'email','����', 'eMail', 'T','T',0,'1';

-- ��ϵ���
insert basecode_cat(cat,descript,descript1,len) select 'contact', '��ϵ���', '��ϵ���', 10;
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) 
	select 'contact', 'email','����', 'eMail', 'T','T',0,'email';
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) 
	select 'contact', 'mobile','�ֻ�', 'Mobile', 'T','T',0,'sms';
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) 
	select 'contact', 'tel','�绰', 'Tel', 'T','T',0,'sms';
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) 
	select 'contact', 'fax','����', 'Fax', 'T','T',0,'';
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) 
	select 'contact', 'qq','QQ', 'QQ', 'T','T',0,'1','';
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) 
	select 'contact', 'msn','MSN', 'MSN', 'T','T',0,'';
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) 
	select 'contact', 'icq','ICQ', 'ICQ', 'T','T',0,'';

--ְԱ��ϵ��Ϣ��
if exists(select * from sysobjects where name = "sys_empno_contact")
	drop table sys_empno_contact;
create table sys_empno_contact
(
	empno				varchar(10)						not null, 
   type	   		varchar(10)    				not null, -- ��ϵ��ʽ
   content   		varchar(60) default ''   	not null  -- ��������
)
create index index1 on sys_empno_contact(empno,type)
;


--ϵͳ�Զ���Ϣ�¼�
if exists(select * from sysobjects where name = "automsg_event")
	drop table automsg_event;
create table automsg_event
(
	eventid			varchar(64)						not null, 
   descript   		varchar(60) default ''		not null,
   descript1  		varchar(60) default ''   	not null,
	tdcheck			char(3)							not null, 
	tdtrigger		char(3)							not null, 
	lastcheck		datetime							 null,
	lasttrigger		datetime							 null 
)
exec sp_primarykey automsg_event,eventid
create unique index index1 on automsg_event(eventid)
;
--ϵͳ�Զ���Ϣ�¼�֪ͨ��Ϣ
if exists(select * from sysobjects where name = "automsg_event_notify")
	drop table automsg_event_notify;
create table automsg_event_notify
(
	recid				varchar(10)						not null, 
	eventid			varchar(64)						not null, 
  	type	   		varchar(10) 					not null,  -- basecode==automsg_type
   notify   		varchar(254) default ''   	not null,  -- ֪ͨ��Ա 
   content   		varchar(254) default ''   	not null,  -- ��������,�궨�壬�磺0^%1��GM����%2^
	tmhold			char(3)							not null   -- ��Ϣ�������ʱ�䣬
)
exec sp_primarykey automsg_event_notify,eventid,type
create unique index index1 on automsg_event_notify(eventid,type)
;

--ϵͳ�Զ���Ϣ�����
if exists(select * from sysobjects where name = "automsg")
	drop table automsg;
create table automsg
(
	recid				varchar(10)						not null, 
	eventid			varchar(64)						not null, 
  	type	   		varchar(10) 					not null,  
   notify   		varchar(254) default ''   	not null,  
   content   		varchar(254) default ''   	not null,
	tmhold			char(3)							not null,   -- ��Ϣ�������ʱ�䣬
	tmtrigger		datetime							not null,
	tmprocess		datetime								 null,
	tag				char(1)		 default 'N'	not null  -- N:�¼�¼ S:�ɹ� F:ʧ�� X:ȡ��
)
exec sp_primarykey automsg,recid
create unique index index1 on automsg(recid)
;

insert into sys_extraid(cat,descript,id) select 'AMN','�Զ���Ϣ�¼�֪ͨ��',0 
insert into sys_extraid(cat,descript,id) select 'AME','�Զ���Ϣ�����',0 
;

-------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- ����: �ж�һ�������Ƿ���Ҫ�������� 
--------------------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'p_am_chkrunning' and type = 'P') 
   drop procedure p_am_chkrunning 
;  
create procedure p_am_chkrunning  
	@enventid	varchar(64), 
	@retmode		char(1) = 'S',
	@retcode		int = 0	output 
as	 
begin  
	declare @tdcheck			char(3)
	declare @tdtrigger		char(3)
	declare @lastcheck		datetime 
	declare @lasttrigger		datetime 
	declare @lastpost			datetime 
	declare @n int, @d int
	-----------------------------------------------------------------------------
	-- ����Ƿ���ϴ���������
	select @tdcheck = isnull(tdcheck,'D99')+'000', @lastcheck = lastcheck 
		from automsg_event 
		where eventid = @enventid
	if ( @lastcheck is not null) 
	begin
		select @d = convert(int,substring(@tdcheck,2,2)) 
	
		if lower(substring(@tdcheck,1,1)) = 'd'
			select @n = datediff(dd,@lastcheck,getdate())
		if lower(substring(@tdcheck,1,1)) = 'h'
			select @n = datediff(hh,@lastcheck,getdate())
		if lower(substring(@tdcheck,1,1)) = 'm'
			select @n = datediff(mi,@lastcheck,getdate())

		if @n < @d 
		begin	
			-- ���ǻ�û�е����ʱ�䣬ֱ�ӷ���
			select @retcode = 1 
			if @retmode='S'
				select @retcode 
			return @retcode 
		end
	end
	-- ��Ҫ��飬���¼��ʱ�� 
	update automsg_event set lastcheck = getdate() where eventid = @enventid

	-- ����Ƿ��Ѿ��д�����Ϣ����ǰ����ڣ�
	select @tdtrigger = isnull(tdtrigger,'D99')+'000', @lasttrigger = lasttrigger 
		from automsg_event 
		where eventid = @enventid
	if ( @lasttrigger is not null) 
	begin
		select @d = convert(int,substring(@tdtrigger,2,2)),@lastpost = @lasttrigger
		if lower(substring(@tdtrigger,1,1)) = 'd'
			select @lastpost = dateadd(dd,@d,@lasttrigger)
		if lower(substring(@tdtrigger,1,1)) = 'h'
			select @lastpost = dateadd(hh,@d,@lasttrigger)
		if lower(substring(@tdtrigger,1,1)) = 'm'
			select @lastpost = dateadd(mi,@d,@lasttrigger)
		if exists (select 1 from automsg where eventid = @enventid and @lasttrigger <= tmtrigger and tmtrigger < @lastpost and @lastpost > getdate()) 
		begin	
			-- �Ѿ��������ˣ�ֱ�ӷ���
			select @retcode = 2 
			if @retmode='S'
				select @retcode 
			return @retcode 
		end
	end
	-- ��Ҫ���д������� 
	select @retcode = 0
	if @retmode='S'
		select @retcode 
	return @retcode 
end
;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- ��������
--------------------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'p_am_lettingrate' and type = 'P') 
   drop procedure p_am_lettingrate 
;  
create procedure p_am_lettingrate   
as	 
begin  
	declare @ret int, @msg	varchar(254) 
	declare @retchk			int 
	declare @lasttrigger		datetime 
	declare @procname		 	varchar(64)
	declare @type				varchar(10)
	declare @notify			varchar(254)
	declare @content			varchar(254)
	declare @tmhold			char(3)
	declare @recid				char(10)
	-----------------------------------------------------------------------------
	declare @tm	 datetime 
	declare @occ money 
	-----------------------------------------------------------------------------
	-- 1. ��ʼ��
	-----------------------------------------------------------------------------
	select @procname = 'p_am_lettingrate'
	select @ret = 0,@msg = ''

	-- ����Ƿ���Ҫ���д���
	exec p_am_chkrunning @procname, 'R', @retchk output

	if @retchk > 0
	begin
		select @ret = @retchk,@msg = ''
		select @ret,@msg 
		return @ret
	end
	-- ���津��ʱ�� 
	select @lasttrigger = getdate()
	-----------------------------------------------------------------------------
	-- 2. ���崦��,�Ѵ����¼����automsg
	-----------------------------------------------------------------------------
	-- ���������
	select @tm = getdate()
	exec p_gds_reserve_rsv_index @tm, '%', 'Occupancy %', 'R', @occ output
	select @occ
	
	if @occ > 0.00
	begin
		-- �Ѵ����¼����automsg
		declare c_1 cursor for 
			select type,notify,content,tmhold  
			from automsg_event_notify 
			where eventid = @procname
		open c_1
		fetch c_1 into @type,@notify,@content,@tmhold 
		while @@sqlstatus = 0 
		begin
			-- ��ȡ��¼��
			exec p_GetAccnt1 @type = 'AME', @accnt = @recid out
			-- ����������Ϣ��
			-- @content�ڶ������ǲ����������ģ�������׷���Ͼ������������ʹ��ϵͳ��
			-- ����������ݸ���֪ͨ��Ϣ���崦�� 
			select @content = @content + '^����'
			insert into automsg(recid,eventid,type,notify,content,tmhold,tmtrigger,tmprocess,tag)
				select @recid,@procname,@type,@notify,@content,@tmhold,getdate(),null,'N' 

			fetch c_1 into @type,@notify,@content,@tmhold 
		end 
		close c_1
		deallocate cursor c_1 
	end
	-----------------------------------------------------------------------------
	-- 3. �������,���´���ʱ��
	-----------------------------------------------------------------------------
	if @ret = 0 
	begin
		update automsg_event set lasttrigger = @lasttrigger where eventid = @procname
	end
	-----------------------------------------------------------------------------
	-- 4.	����
	-- ������һ������ �� @ret >= 0  @msg = '' 
	-- �����г��ִ��� �� @ret < 0  @msg = ������ʾ��Ϣ
	-----------------------------------------------------------------------------
	select @ret,@msg 
end 
;  
