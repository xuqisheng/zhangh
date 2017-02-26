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
	serverpath 		varchar(254)	         not null,		-- 服务器端目录 e.g. /usr/foxupd/fox2003/
	clientpath 		varchar(254)	         not null,		-- 客户端目录   e.g. c:\fox2003\
	lieover			smallint		 default 1	not null       -- 是否暂时搁置, 非0--使用中
)
exec sp_primarykey foxautoupdate,id 
;

-- 参数格式:(在维护系统中配置)
-- <SRV>IP=IP地址;USR=用户;PWD=密码;CMP=ST;</SRV>
if not exists(select 1 from sysoption where catalog = 'hotel' and item = 'updateftpserver') 
	insert into sysoption(catalog,item,value) values('hotel','updateftpserver','')
;

-- 维护代码  
DELETE FROM syscode_maint WHERE code = '17')
INSERT INTO syscode_maint VALUES ('17','自动更新参数维护','','response','foxhis','d_foxhis_update1','w_foxhis_update_config','');


