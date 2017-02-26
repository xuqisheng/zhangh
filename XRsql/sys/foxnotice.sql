-------------------------------------------------------------------------------------------
-- foxnoticepart
-------------------------------------------------------------------------------------------
if exists(select * from sysobjects where name = 'foxnoticepart' and type ='U')
	drop table foxnoticepart
;
create table foxnoticepart (
	noticeid			varchar(16)						not null, -- ��Ϣ����ID
	descript    	varchar(64)		default ''	not null, -- ����
	descript1   	varchar(64)		default ''	not null, -- ����1
	syntax      	text				default ''	not null, -- ��ʾdw�﷨������ר���﷨
	handler			varchar(128)	default ''	not null, -- ��ʾdw˫���������
	apps				varchar(254)	default ''	not null  -- ����Ӧ��ʹ�õ�Ӧ��appid.code���Զ��
)
;

exec sp_primarykey foxnoticepart,noticeid
create unique index index1 on foxnoticepart(noticeid)
;

-------------------------------------------------------------------------------------------
-- foxnoticelayout
-------------------------------------------------------------------------------------------
if exists(select * from sysobjects where name = 'foxnoticelayout' and type ='U')
	drop table foxnoticelayout
;
create table foxnoticelayout (
	opapp				char(1)			default '1'				not null, -- ���ֹ���Ӧ��appid.code
	optype			char(3)			default 'EMP'			not null, -- ���ֹ�����HIS-ϵͳ GRP-�� EMP-��
	opid		    	varchar(16)		default ''				not null, -- ����HIS-->HOTEL GRP-->basecode.code  cat = 'dept' EMP-->sys_empno.empno
	noticeid			varchar(16)		default ''				not null, -- ��Ϣ����ID
	layoutpx      	int				default 0				not null,  
	layoutpy      	int				default 0				not null,  
	layoutpw      	int				default 0				not null,  
	layoutph      	int				default 0				not null,  
	layoutep      	int				default 0				not null  -- 0--������չ�� 1-����չ��
)
;
exec sp_primarykey foxnoticelayout,opapp,optype,opid,noticeid
create unique index index1 on foxnoticelayout(opapp,optype,opid,noticeid)
;
-------------------------------------------------------------------------------------------
-- data 
-------------------------------------------------------------------------------------------
DELETE FROM syscode_maint where code in('1A','1A1','1A2')
;
INSERT INTO syscode_maint ( code,descript,descript1,wtype,auth,show,source,parm ) 
VALUES ( '1A', '�ۺ�����', '�ۺ�����', '', '', '', '', '' )
;
INSERT INTO syscode_maint ( code,descript,descript1,wtype,auth,show,source,parm ) 
VALUES ( '1A1', '�ۺ����Ѳ���', '�ۺ����Ѳ���', 'response', 'ZHJ', 'd_foxnoticepartlist', 'w_foxnoticepart', '' )
;
INSERT INTO syscode_maint ( code,descript,descript1,wtype,auth,show,source,parm ) 
VALUES ( '1A2', '�ۺ����Ѳ���', '�ۺ����Ѳ���', 'sheet', 'ZHJ', 'select distinct opapp,optype,opid from foxnoticelayout |||opapp:Ӧ��;optype:���;opid:����', 'w_foxnoticelayout', '' )
;


INSERT INTO foxnoticepart VALUES (
	'FOXHIS',
	'FOXHIS',
	'FOXHIS',
	'class=n_noticeowner_afterlogin',
	'n_noticehandler_foxhis',
	'1,2,3,4,5,6,7,8,9');
INSERT INTO foxnoticepart VALUES (
	'TRACE',
	'TRACE',
	'TRACE',
	'_com_d_TRACE;(select inure,abate,content from message_trace where ( recvaddr like ''%<''+''#empno#''+''>%'' or recvaddr like ''%<D:''+rtrim(ltrim((select deptno from sys_empno where empno = ''#empno#''))) +''>%'' or recvaddr like ''%<D:''+substring(rtrim(ltrim((select deptno from sys_empno where empno = ''#empno#''))),1,1) +''>%'' or recvaddr like ''%<hotel>%'') and ( sort = ''AFF'' ) and ( tag = ''1'' ));inure:��Ч=12=mm/dd hh|mm;abate:ʧЧ=12=mm/dd hh|mm;content:����=32',
	'n_noticehandler_foxhis',
	'1,2,3,4,5,6,7,8,9');
INSERT INTO foxnoticepart VALUES (
	'TODAYARR',
	'���ս���',
	'���ս���1',
	'_com_d_���ս������˱���;(select char05  =  c.roomno,c.arr,c.dep,b.haccnt,rslt10  =  a.accnt from rsvsrc c,master a,master_des b where c.accnt=a.accnt and a.accnt=b.accnt and  a.sta=''R'' and  datediff(dd,  c.arr,  getdate())=0  order by c.arr);char05:����=4=[general]=alignment="2";b.haccnt:����=14;c.arr:����=9=mm/dd hh|mm=alignment="2";c.dep:����=4=mm/dd=alignment="2"headerds=[autoappe=0]',
	'n_noticehandler_front',
	'1,2,3,4,5,6,7,8,9');
INSERT INTO foxnoticepart VALUES (
	'TODAYDEP',
	'�������',
	'�������1',
	'_com_d_������걨��(����);(select a.roomno,a.arr,a.dep,b.name,rslt10  =  a.accnt from master a,guest b where a.class=''F''  and a.haccnt=b.no and a.sta =''O'' and datediff(dd,  a.dep,  getdate())=0 order by a.roomno,a.accnt);a.roomno:����;b.name:����=12;a.arr:����=6=mm/dd=alignment="2";a.dep:����=6=mm/dd=alignment="2"headerds=[autoappe=0] ',
	'n_noticehandler_front',
	'1,2,3,4,5,6,7,8,9');
INSERT INTO foxnoticepart VALUES (
	'VIP',
	'VIP',
	'VIP',
	'_com_d_VIP ������ס��Ԥ����;(select a.roomno,a.arr,a.dep,b.name,rslt10  =  a.accnt from master a,guest b where a.class=''F'' and a.haccnt=b.no and a.sta in (''I'',  ''R'') and b.vip>''0'' order by b.vip,a.roomno,a.accnt);a.roomno:����;b.name:����=12;a.arr:����=9=mm/dd mm|dd =alignment="2";a.dep:����=6=mm/dd=alignment="2";headerds=[autoappe=''0''] ',
	'n_noticehandler_front',
	'1,2,3,4,5,6,7,8,9');
INSERT INTO foxnoticepart VALUES (
	'EMAIL',
	'����',
	'����1',
	'_com_d_����;(select sender,subject from message_mail a where a.status =''1'' and a.id in ( select id from message_mailrecv b  where b.receiver = ''#empno#''  and b.tag = ''0''));sender:������;subject:����=32',
	'n_noticehandler_foxhis',
	'1,2,3,4,5,6,7,8,9');


INSERT INTO foxnoticelayout VALUES ('1',	'HIS',	'HOTEL',	'EMAIL',	27,	24,	1893,	748,	0);
INSERT INTO foxnoticelayout VALUES ('1',	'HIS',	'HOTEL',	'TODAYARR',	27,	824,	1893,	748,	0);
INSERT INTO foxnoticelayout VALUES ('1',	'HIS',	'HOTEL',	'TODAYDEP',	1984,	824,	1893,	748,	0);
INSERT INTO foxnoticelayout VALUES ('1',	'HIS',	'HOTEL',	'TRACE',	1984,	24,	1893,	748,	0);
INSERT INTO foxnoticelayout VALUES ('1',	'HIS',	'HOTEL',	'VIP',	27,	1616,	1893,	748,	0);
INSERT INTO foxnoticelayout VALUES ('1',	'HIS',	'HOTEL',	'FOXHIS',	1984,	1616,	1893,	748,	0);
