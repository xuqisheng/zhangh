
drop table user_data;
create table user_data
(
	data			char(20) default ''	not null,
	remark		    char(60) default ''  null
)
exec sp_primarykey user_data,data
create unique index  user_data on user_data(data)
;

INSERT INTO user_data VALUES ('RemotePort','服务器端口');
INSERT INTO user_data VALUES ('LocalPort','本机端口');
INSERT INTO user_data VALUES ('LocalDotAddr','本机地址');
INSERT INTO user_data VALUES ('Debug','');
INSERT INTO user_data VALUES ('ShowIcon','');
INSERT INTO user_data VALUES ('CommPort','串口');
INSERT INTO user_data VALUES ('baud_rate','波特率');
INSERT INTO user_data VALUES ('bit','数据位');
INSERT INTO user_data VALUES ('parity','奇偶校验');
INSERT INTO user_data VALUES ('stop','停止位');
INSERT INTO user_data VALUES ('handshaking','握手协议');
INSERT INTO user_data VALUES ('rthreshold','R阀值');
INSERT INTO user_data VALUES ('RemoteHost','服务器地址');
INSERT INTO user_data VALUES ('server_ip','允许运行接口的服务器地址');
INSERT INTO user_data VALUES ('empty_select','漏单的选择 1,转入消费账,<>1则有提示和警报');
INSERT INTO user_data VALUES ('autologin','自动登陆的掺数,T是自动,<> T 手动');
INSERT INTO user_data VALUES ('phcode','特殊号码提醒,格式如:110,120,122,119');
INSERT INTO user_data VALUES ('times','长时间不动作的提醒,格式:分钟(时间段)#分钟(时间段)如:60(0600-');
INSERT INTO user_data VALUES ('sthreshold','S阀值');
INSERT INTO user_data VALUES ('dtrenable','');
INSERT INTO user_data VALUES ('rtsenable','');
INSERT INTO user_data VALUES ('nulldiscard','是否丢掉空值');
INSERT INTO user_data VALUES ('inputlen','接收字符串的长度');
INSERT INTO user_data VALUES ('outbuffersize','串口发送缓存大小');
INSERT INTO user_data VALUES ('inbuffersize','串口接收缓存大小');
