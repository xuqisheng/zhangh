--**********************************************************************************
--		foxhis autoupdate application
--**********************************************************************************

------------------------------------------------------------------------------------
--		update path
------------------------------------------------------------------------------------
if exists(select 1 from sysobjects where name = "foxautoupdate" and type="U")
	drop table foxautoupdate;

create table foxautoupdate
(
	id					smallint		            not null, 
	serverpath 		varchar(254)	         not null,		-- ��������Ŀ¼ e.g. /usr/foxupd/fox2003/
	clientpath 		varchar(254)	         not null,		-- �ͻ���Ŀ¼   e.g. c:\fox2003\
	lieover			smallint		 default 1	not null       -- �Ƿ���ʱ����, ��0--ʹ����
)
exec sp_primarykey foxautoupdate,id 
;

-- ������ʽ:(��ά��ϵͳ������)
-- <SRV>IP=IP��ַ;USR=�û�;PWD=����;CMP=ST;</SRV>
if not exists(select 1 from sysoption where catalog = 'hotel' and item = 'updateftpserver') 
	insert into sysoption(catalog,item,value) values('hotel','updateftpserver','')
;

-- ά������  
DELETE FROM syscode_maint WHERE code = '17')
INSERT INTO syscode_maint VALUES ('17','�Զ����²���ά��','','response','foxhis','d_foxhis_update1','w_foxhis_update_config','');


