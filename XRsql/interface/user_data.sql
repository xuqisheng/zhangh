
drop table user_data;
create table user_data
(
	data			char(20) default ''	not null,
	remark		    char(60) default ''  null
)
exec sp_primarykey user_data,data
create unique index  user_data on user_data(data)
;

INSERT INTO user_data VALUES ('RemotePort','�������˿�');
INSERT INTO user_data VALUES ('LocalPort','�����˿�');
INSERT INTO user_data VALUES ('LocalDotAddr','������ַ');
INSERT INTO user_data VALUES ('Debug','');
INSERT INTO user_data VALUES ('ShowIcon','');
INSERT INTO user_data VALUES ('CommPort','����');
INSERT INTO user_data VALUES ('baud_rate','������');
INSERT INTO user_data VALUES ('bit','����λ');
INSERT INTO user_data VALUES ('parity','��żУ��');
INSERT INTO user_data VALUES ('stop','ֹͣλ');
INSERT INTO user_data VALUES ('handshaking','����Э��');
INSERT INTO user_data VALUES ('rthreshold','R��ֵ');
INSERT INTO user_data VALUES ('RemoteHost','��������ַ');
INSERT INTO user_data VALUES ('server_ip','�������нӿڵķ�������ַ');
INSERT INTO user_data VALUES ('empty_select','©����ѡ�� 1,ת��������,<>1������ʾ�;���');
INSERT INTO user_data VALUES ('autologin','�Զ���½�Ĳ���,T���Զ�,<> T �ֶ�');
INSERT INTO user_data VALUES ('phcode','�����������,��ʽ��:110,120,122,119');
INSERT INTO user_data VALUES ('times','��ʱ�䲻����������,��ʽ:����(ʱ���)#����(ʱ���)��:60(0600-');
INSERT INTO user_data VALUES ('sthreshold','S��ֵ');
INSERT INTO user_data VALUES ('dtrenable','');
INSERT INTO user_data VALUES ('rtsenable','');
INSERT INTO user_data VALUES ('nulldiscard','�Ƿ񶪵���ֵ');
INSERT INTO user_data VALUES ('inputlen','�����ַ����ĳ���');
INSERT INTO user_data VALUES ('outbuffersize','���ڷ��ͻ����С');
INSERT INTO user_data VALUES ('inbuffersize','���ڽ��ջ����С');
