--------------------------------------------------------------------------------
--  TABLE:��Ϣ������message_notify_type
--------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "message_notify_type")
	drop table message_notify_type
;
create table message_notify_type 
(
	msgsort			char(32)     default ''        not null,  -- ���
   descript   		varchar(60)  default ''			 not null,  -- ����
   descript1  		varchar(60)  default ''   		 not null,  -- ����1
	msgmode			char(1)      default '0'       not null,  -- ����ʽ 0--֪ͨ 1--ҵ�� 
   msgwin  		   varchar(60)  default ''   		 not null,  -- ��Ϣ�����ڣ����ܲ���msgid
	usefullife     char(5)      default '0'       not null,  -- ��Чʱ�� 0-������ 1--���� M..---���� H..--Сʱ D..--�� 
	msgfirst			char(1)      default '0' 	    not null,  -- �Ƿ�������ʾ 0-�� 1-��
	msgroll			char(1)      default '0' 	    not null,  -- �Ƿ���� 0-�� 1-��
	msgicon			char(1)      default '0' 	    not null,  -- �Ƿ���ʾͼ�� 0-�� 1-��
	msgrec			char(1)      default '0' 	    not null   -- �Ƿ��¼ 0-�� 1-��
)
exec sp_primarykey message_notify_type,msgsort
create unique index index1 on message_notify_type(msgsort)
;
--------------------------------------------------------------------------------
--  DATA
--------------------------------------------------------------------------------
insert into message_notify_type(msgsort,descript,descript1,msgmode,msgwin,usefullife,msgfirst,msgroll,msgicon,msgrec) 
	select 'SYS_RUNINTERFACE','Foxhis ������','Foxhis Sercice','0','','M10','0','1','1','1'  
insert into message_notify_type(msgsort,descript,descript1,msgmode,msgwin,usefullife,msgfirst,msgroll,msgicon,msgrec) 
	select 'FOXNOTIFY','Foxhis ֪ͨ��Ϣ','Foxhis Notify','0','','M30','0','1','1','1'  
insert into message_notify_type(msgsort,descript,descript1,msgmode,msgwin,usefullife,msgfirst,msgroll,msgicon,msgrec) 
	select 'FOXMAIL','Foxhis �ʾ�','Foxhis Mail','0','','0','0','1','1','1'  
insert into message_notify_type(msgsort,descript,descript1,msgmode,msgwin,usefullife,msgfirst,msgroll,msgicon,msgrec) 
	select 'FOXTRACE','Foxhis Trace ','Foxhis Trace ','1','w_trace_affair_qa','0','0','1','1','1'  
insert into message_notify_type(msgsort,descript,descript1,msgmode,msgwin,usefullife,msgfirst,msgroll,msgicon,msgrec) 
	select 'FOXRMCHKIN','��������','Room Check In','1','','0','0','1','1','1'  
insert into message_notify_type(msgsort,descript,descript1,msgmode,msgwin,usefullife,msgfirst,msgroll,msgicon,msgrec) 
	select 'FOXRMCHKINOK','�����鷿���','Room Check In Ok','1','','0','0','1','1','1'  
insert into message_notify_type(msgsort,descript,descript1,msgmode,msgwin,usefullife,msgfirst,msgroll,msgicon,msgrec) 
	select 'FOXRMCHKOUT','�鷿����','Room Check Out','1','','0','0','1','1','1'  
insert into message_notify_type(msgsort,descript,descript1,msgmode,msgwin,usefullife,msgfirst,msgroll,msgicon,msgrec) 
	select 'FOXRMCHKOUTOK','�鷿���','Room Check Out Ok','1','','0','0','1','1','1' 
insert into message_notify_type(msgsort,descript,descript1,msgmode,msgwin,usefullife,msgfirst,msgroll,msgicon,msgrec) 
	select 'Q-ROOM','Q-Room','Q-Room','1','','0','0','1','1','1'  
insert into message_notify_type(msgsort,descript,descript1,msgmode,msgwin,usefullife,msgfirst,msgroll,msgicon,msgrec) 
	select 'DISC-ROOM','ì�ܷ�','Discrepart Room','1','','0','0','1','1','1'  
insert into message_notify_type(msgsort,descript,descript1,msgmode,msgwin,usefullife,msgfirst,msgroll,msgicon,msgrec) 
	select 'ACNT_PHONE','�绰�Ƿ���©','Losing Account for Phone','0','','M30','0','1','1','1'  
insert into message_notify_type(msgsort,descript,descript1,msgmode,msgwin,usefullife,msgfirst,msgroll,msgicon,msgrec) 
	select 'CRS_NOTIFY','CRS ֪ͨ��Ϣ','CRS Notify','0','','M04','0','1','1','1'  
; 



--------------------------------------------------------------------------------
--  TABLE:��Ϣ������message_notify 
--------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "message_notify")
	drop table message_notify
;
create table message_notify 
(
	msgid				char(32) 						    not null,
	msgsort  		char(32)     default ''        not null,  -- ��� 
	msgdate			datetime     default getdate() not null,  -- ʱ�� 
	msgfrom			varchar(10)  default '' 	    not null,  -- ���� (empno)
	msgfrom1  		varchar(32)  default '' 	    not null,  -- ���� (pc_id@appid)
	msgto          varchar(254) default ''        not null,  -- ���� (empno or dept addr) e.g. FOX or <D:0>
	msgto1         varchar(254) default ''        not null,  -- ���� (pc_id list) e.g. ,2.22,0.22,
	msgtext			varchar(254) default ''        not null,  -- ����
	msgdata			varchar(254) default ''        not null,  -- ��Ϣ����
	status			char(1)      default '0'       not null,  -- ״̬ 0-δ���� 1-�Ѵ���
	reader			text                               null   -- ����(date time,empno,op,pc_id@appid\r\n)*
)
exec sp_primarykey message_notify,msgid
create unique index index1 on message_notify(msgid)
;
