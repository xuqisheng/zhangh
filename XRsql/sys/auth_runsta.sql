// ------------------------------------------------------------------------
//		ϵͳվ������״̬��
// ------------------------------------------------------------------------ 
if exists(select * from sysobjects where name = "auth_runsta")
	drop table auth_runsta;
create table auth_runsta
(
	pc_id		char(4)					not null,	// PC�������ַ
	act_date	datetime	   			null,		   // ��¼ʱ��
	run_date	datetime	   			null,
	status	char(1)					not null,	// "R","H","S",����,����,ͣ��
	empno		char(10)	default ''	not null,	// ��½����
	name		char(20)					null,       // ����
	appid		char(5)	default ''	not null,   // Ӧ�ñ�� ��ʽ��appid ��appid+interface_group+interface_id
	funcid	char(30)					null,       // ʹ�ù���
	errtag	char(1) default "F"	not null,
	host_id	varchar(10)				null,
	host_name	varchar(30)			null, 
	spid			integer				null, 
	srvid		varchar(20)				null,
	shift		char(1) 					null
)
exec sp_primarykey auth_runsta,pc_id,appid
create unique index index1 on auth_runsta(pc_id,appid)
;

// ------------------------------------------------------------------------
//	pcid_des  ϵͳվ��������
// ------------------------------------------------------------------------ 
if exists(select * from sysobjects where name = 'pcid_des' and type ='U')
	drop table pcid_des
;
create table pcid_des (
	pc_id				char(4)								not null, 
	descript    	varchar(30)		default ''	    null,
	descript1   	varchar(30)		default ''	    null,
	chair				varchar(10)		default ''	    null, -- ������
	phone				varchar(8)		default ''	    null,-- �绰
	modus				varchar(100)	default ''	    null,-- ׼��ģ��
	users				varchar(100)	default ''	    null, -- ׼���û�
	mustrun	   	varchar(32)		default ''	    null, -- �����������е�ģ�飬һ���ǽӿڵ�
	notifywho   	varchar(128)	default ''	    null, -- �����������е�ģ��ֹͣʱ����Ҫ֪ͨ����
	mac				char(12)			default ''	    null, -- �����������ַ
	computer   		varchar(254)	default ''	    null  -- ��¼mac��Ӧ�ļ�������ƺ�ip
)
;
exec sp_primarykey pcid_des,pc_id 
create unique index index1 on pcid_des(pc_id)
;


// ------------------------------------------------------------------------
//		��ѯϵͳվ������״̬
// ------------------------------------------------------------------------ 
if exists (select 1 from sysobjects where name = 'p_sys_auth_runsta'  and type = 'P')
	drop procedure p_sys_auth_runsta;

create  procedure p_sys_auth_runsta 
   @status	char(1) = '%',
	@langid	integer = 0 
as
begin 
	create table #qrylst
	(
		pc_id			char(4)			  not null,	 
		descript		varchar(60)				null,
		chair			varchar(10)				null,			 
		phone			varchar(8)				null,			 
		act_date		datetime	   			null,	 
		run_date		datetime	   			null,
		status		char(1)					null,	 
		empno			char(10)					null,		
		name			char(20)					null,   	
		appid			char(5)					null,   	
		appdes		varchar(30)				null,
		host_name	varchar(30)				null, 
		spid			integer					null, 
		must			integer					null,  
		itf			integer					null 
	) 

	create table #applst
	(
		appid			char(5)					null,   	
		descript		varchar(60)				null,
		descript1	varchar(60)				null,
		itf			integer					null 
	) 
	-- application
	insert into #applst 
		select code,descript,descript1,0 from appid where moduno = ''
	-- interface 
	insert into #applst 
		select 'D' + groupid + id,descript,descript1,1 from interface 

	-- get data
	if @langid = 0 
	begin 
		insert into #qrylst 
		select a.pc_id,b.descript,b.chair,b.phone,a.act_date,
				a.run_date,a.status,a.empno,a.name,a.appid, 
				c.descript,a.host_name,a.spid, 0 ,0 
		from  auth_runsta a,
				pcid_des b, 
				#applst c 
		where ( c.appid  = a.appid ) and 
				( a.status like rtrim(@status)+'%'  ) and 
				( a.pc_id *= b.pc_id ) 
		-- must run but not running
		if ( @status = '%' or @status = 'S' )
		begin 
			insert into #qrylst 
			select b.pc_id,b.descript,b.chair,b.phone,null,
					null,'S','','',c.appid, 
					c.descript,'',null, 1 ,0  
			from  pcid_des b, 
					#applst c 
			where ( charindex('<'+c.appid+'>', b.mustrun) > 0  ) and 
					( (b.pc_id +'@'+ c.appid) not in(select pc_id+'@'+appid from auth_runsta ) )
		end 
	end
	else
	begin
		insert into #qrylst 
		select a.pc_id,b.descript1,b.chair,b.phone,a.act_date,
				a.run_date,a.status,a.empno,a.name,a.appid, 
				c.descript1,a.host_name,a.spid, 0 ,0 
		from  auth_runsta a,
				pcid_des b, 
				#applst c 
		where ( c.appid  = a.appid ) and 
				( a.status like rtrim(@status)+'%'  ) and 
				( a.pc_id *= b.pc_id ) 
		-- must run but not running
		if ( @status = '%' or @status = 'S' )
		begin 
			insert into #qrylst 
			select b.pc_id,b.descript1,b.chair,b.phone,null,
					null,'S','','',c.appid, 
					c.descript1,'',null, 1 ,0  
			from  pcid_des b, 
					#applst c 
			where ( charindex('<'+c.appid+'>', b.mustrun) > 0  ) and 
					( (b.pc_id +'@'+ c.appid) not in(select pc_id+'@'+appid from auth_runsta ) )
		end 
	end 

	update #qrylst set must = 1 
		from  #qrylst a,
				pcid_des b 
		where a.pc_id = b.pc_id and 
				charindex('<'+a.appid+'>',b.mustrun) > 0 

	-- return 
	select * from #qrylst order by pc_id,appid  
end
;

// ------------------------------------------------------------------------
//		��ѯϵͳ�������е�վ��
// ------------------------------------------------------------------------ 
if exists (select 1 from sysobjects where name = 'p_sys_auth_mustrun'  and type = 'P')
	drop procedure p_sys_auth_mustrun;

create  procedure p_sys_auth_mustrun  
as
begin 

	create table #qrylst
	(
		pc_id			char(4)			  not null,	 
		appid			char(5)					null,   	
		descript		varchar(60)				null,
		descript1	varchar(60)				null,
		appdes		varchar(60)				null,
		appdes1		varchar(60)				null,
		status		char(1)					null,	 
		notifywho	varchar(128)			null 		
	) 

	create table #applst
	(
		appid			char(5)					null,   	
		descript		varchar(60)				null,
		descript1	varchar(60)				null,
		itf			integer					null 
	) 
	-- application
	insert into #applst 
		select code,descript,descript1,0 
		from appid 
		where moduno = ''  
	-- interface 
	insert into #applst 
		select 'D' + groupid + id,descript,descript1,1 
		from interface 

	-- get data
	insert into #qrylst 
	select b.pc_id,c.appid,b.descript,b.descript1,c.descript,c.descript1,'S',b.notifywho 
	from  pcid_des b, 
			#applst c  
	where charindex('<'+c.appid+'>', b.mustrun) > 0 and  charindex('<', b.notifywho) > 0

	-- update auth_runsta.status 
	update #qrylst set status = b.status
		from  #qrylst a,
				auth_runsta b 
		where a.pc_id = b.pc_id and a.appid = b.appid 

	-- romove 
	delete from #qrylst 
		where status = 'R'

	-- return 
	select * 
		from #qrylst 
		order by appid,pc_id
end
;
