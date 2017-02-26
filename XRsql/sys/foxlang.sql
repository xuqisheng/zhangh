--**********************************************************************************
--		foxhis������
--**********************************************************************************

------------------------------------------------------------------------------------
--		foxlangid  �����ִ���
------------------------------------------------------------------------------------
if exists(select 1 from sysobjects where name = "foxlangid" and type="U")
	drop table foxlangid;

create table foxlangid
(
	langid 		smallint		               not null,	-- ����
	descript 	varchar(60)		            not null,	-- ����
	client 		varchar(250)	default ''	not null		-- �ͻ����ļ�
)
exec sp_primarykey foxlangid, langid
create unique index index1 on foxlangid(langid)
;
INSERT INTO foxlangid (langid,descript,client) VALUES (0,'��������Chinese (Simplified)','foxhis_chs.fhl')
INSERT INTO foxlangid (langid,descript,client) VALUES (1,'��������Chinese (Traditional)','foxhis_cht.fhl')
INSERT INTO foxlangid (langid,descript,client) VALUES (2,'Ӣ��English','foxhis_en.fhl')
INSERT INTO foxlangid (langid,descript,client) VALUES (3,'����Japanese','foxhis_jp.fhl')
INSERT INTO foxlangid (langid,descript,client) VALUES (4,'������Korean','foxhis_kor.fhl')
INSERT INTO foxlangid (langid,descript,client) VALUES (5,'����German','foxhis_ger.fhl')
INSERT INTO foxlangid (langid,descript,client) VALUES (6,'����French','foxhis_fr.fhl')
INSERT INTO foxlangid (langid,descript,client) VALUES (7,'����Russian','foxhis_rus.fhl')
;

------------------------------------------------------------------------------------
--		foxlangmsg   ��̬�ı���Ϣ : �����ͻ��˺ͷ��������еĶ�̬����
--------------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "foxlangmsg" and type="U")
	drop table foxlangmsg;

create table foxlangmsg
(
	msg			int							not null,						
	obj 			varchar(50)					not null,		-- ��Ϣ���ڶ��󣬿�Ϊͨ��
	descript 	varchar(250)	         not null,		-- ����
	langid 		int		     default 0 not null			-- ����
)
exec sp_primarykey foxlangmsg, msg, langid
create index index1 on foxlangmsg(msg, obj, langid)
create index index2 on foxlangmsg(descript, langid)
;


--------------------------------------------------------------------------------------
--		foxlangobj - ���Ӷ����¼
--------------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "foxlangobj" and type="U")
	drop table foxlangobj;

create table foxlangobj
(
	obj 			varchar(250)				not null,		-- ����
	descript 	varchar(250)	         not null,		-- ����
	langid 		int		     default 0 not null			-- ����
)
exec sp_primarykey foxlangobj, obj, langid
create unique index index1 on foxlangobj(obj, langid)
create index index2 on foxlangobj(descript, langid)
;

--------------------------------------------------------------------------------
-- foxlang insert message
--------------------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'p_foxlang_insertmsg' and type = 'P') 
   drop procedure p_foxlang_insertmsg 
;  
create procedure p_foxlang_insertmsg  
	@descript varchar(250)  
as	 
begin  
	if not exists (select 1 from foxlangmsg where descript = @descript and langid = 0) 
	begin 
		insert into foxlangmsg (msg,obj,descript,langid) 
		select (select max(isnull(msg,0)) +1 from foxlangmsg where langid = 0),'',@descript,0  
	end 
end 
;  

--------------------------------------------------------------------------------
-- foxlang insert object
--------------------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'p_foxlang_insertobj' and type = 'P') 
   drop procedure p_foxlang_insertobj 
;  
create procedure p_foxlang_insertobj  
	@obj varchar(250),   
	@txt varchar(250)  
as	 
begin  
	if not exists (select 1 from foxlangobj where obj = @obj and langid = 0) 
	begin 
		insert into foxlangobj (obj,descript,langid) 
		select @obj,@txt,0  
	end 
end 
;  


--------------------------------------------------------------------------------
-- foxlang maint
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'p_foxlang_maint' and type = 'P') 
   drop procedure p_foxlang_maint 
;  
create procedure p_foxlang_maint
	@inlangid  int,       -- langid
	@intype    char(1)    -- O:obj M:msg A:all
as
begin
	if @inlangid > 0 
	begin
		if(@intype='O' or @intype='A')
		begin
			delete from foxlangobj
				where langid = @inlangid  and obj not in(select obj from foxlangobj where langid = 0)
			insert into foxlangobj (obj,descript,langid)
				select obj,descript,@inlangid
				from foxlangobj
				where langid = 0  and obj not in(select obj from foxlangobj where langid = @inlangid)
		end			
		if(@intype='M' or @intype='A')
		begin
			delete from foxlangmsg
				where langid = @inlangid  and msg not in(select msg from foxlangmsg where langid = 0)
			insert into foxlangmsg (msg,obj,descript,langid)
				select msg,obj,descript,@inlangid
				from foxlangmsg
				where langid = 0  and msg not in(select msg from foxlangmsg where langid = @inlangid)
		end			
	end 
end
;
