-------------------------------------------------------------------------------------------
-- message_mgr
-------------------------------------------------------------------------------------------
if exists(select * from sysobjects where name = 'message_mgr' and type ='U')
	drop table message_mgr
;
create table message_mgr (
	mgrclass			varchar(16)						not null, 
	mgritem			varchar(16)						not null,
	descript    	varchar(30)		default ''	not null,
	descript1   	varchar(30)		default ''	not null,
  	dwlst				text				default ''	not null,
  	dwprn				text				default ''	not null,
	dwmac				varchar(254)	default ''	not null,
	sequence			int				default 0	not null  
)
;
exec sp_primarykey message_mgr,mgrclass,mgritem 
create unique index index1 on message_mgr(mgrclass,mgritem )
;

-------------------------------------------------------------------------------------------
-- message_mgr data
-------------------------------------------------------------------------------------------
insert into message_mgr(mgrclass,mgritem,descript,descript1,dwlst,dwprn,dwmac,sequence)
	select 'message','msg0','ȫ������','All Guest',
	'��ǰ����һ����;(select rslt10_1  =  a.accnt,a.roomno,a.sta,a.arr,a.dep,b.name,c.name,mone10  =  a.charge-a.credit,char01  =  substring(a.extra,  10,  1),a.groupno,a.paycode from master a,guest b,guest c,basecode d where a.class=''F'' and a.haccnt=b.no and a.cusno*=c.no and d.cat=''mststa'' and a.sta=d.code and (1=1) order by a.roomno,d.sequence);a.roomno:����;a.sta:״̬;a.arr:����=7=yy/mm/dd=alignment="2";a.dep:�뿪=5=mm/dd=alignment="2";b.name:����=16;mone10:���=9;char01_6=='''':-;a.groupno:�����=8;c.name:��λ=16;a.paycode:����headerds=[header=1 autoappe=0]texttext=r_lock:��:detail:1::char01_6:char01_6::alignment="2" border="0" font.italic="0" font.face="ms serif" font.charset="0" font.height="-7" color="65280~tif(nodispchar01=''1'',65280,if(nodispchar01=''2'',32768,0))" visible="1~tif(nodispchar01=''0'',0,1)"!',
	'',
	'',0

insert into message_mgr(mgrclass,mgritem,descript,descript1,dwlst,dwprn,dwmac,sequence)
	select 'message','msg1','���յ������','Guest Arriving Today',
	'��ǰ����һ����;(select rslt10_1  =  a.accnt,a.roomno,a.sta,a.arr,a.dep,b.name,c.name,mone10  =  a.charge-a.credit,char01  =  substring(a.extra,  10,  1),a.groupno,a.paycode from master a,guest b,guest c,basecode d where a.class=''F'' and a.haccnt=b.no and a.cusno*=c.no and d.cat=''mststa'' and a.sta=d.code and datediff(day,a.arr,getdate()) = 0 and (1=1) order by a.roomno,d.sequence);a.roomno:����;a.sta:״̬;a.arr:����=7=yy/mm/dd=alignment="2";a.dep:�뿪=5=mm/dd=alignment="2";b.name:����=16;mone10:���=9;char01_6=='''':-;a.groupno:�����=8;c.name:��λ=16;a.paycode:����headerds=[header=1 autoappe=0]texttext=r_lock:��:detail:1::char01_6:char01_6::alignment="2" border="0" font.italic="0" font.face="ms serif" font.charset="0" font.height="-7" color="65280~tif(nodispchar01=''1'',65280,if(nodispchar01=''2'',32768,0))" visible="1~tif(nodispchar01=''0'',0,1)"!',
	'',
	'',1

insert into message_mgr(mgrclass,mgritem,descript,descript1,dwlst,dwprn,dwmac,sequence)
	select 'message','msg2','���յ������','Guest Arriving Tomorrow',
	'��ǰ����һ����;(select rslt10_1  =  a.accnt,a.roomno,a.sta,a.arr,a.dep,b.name,c.name,mone10  =  a.charge-a.credit,char01  =  substring(a.extra,  10,  1),a.groupno,a.paycode from master a,guest b,guest c,basecode d where a.class=''F'' and a.haccnt=b.no and a.cusno*=c.no and d.cat=''mststa'' and a.sta=d.code and datediff(day,a.arr,getdate()) = -1 and (1=1) order by a.roomno,d.sequence);a.roomno:����;a.sta:״̬;a.arr:����=7=yy/mm/dd=alignment="2";a.dep:�뿪=5=mm/dd=alignment="2";b.name:����=16;mone10:���=9;char01_6=='''':-;a.groupno:�����=8;c.name:��λ=16;a.paycode:����headerds=[header=1 autoappe=0]texttext=r_lock:��:detail:1::char01_6:char01_6::alignment="2" border="0" font.italic="0" font.face="ms serif" font.charset="0" font.height="-7" color="65280~tif(nodispchar01=''1'',65280,if(nodispchar01=''2'',32768,0))" visible="1~tif(nodispchar01=''0'',0,1)"!',
	'',
	'',2

insert into message_mgr(mgrclass,mgritem,descript,descript1,dwlst,dwprn,dwmac,sequence)
	select 'message','msg3','�����뿪����','Guest Departing Today',
	'��ǰ����һ����;(select rslt10_1  =  a.accnt,a.roomno,a.sta,a.arr,a.dep,b.name,c.name,mone10  =  a.charge-a.credit,char01  =  substring(a.extra,  10,  1),a.groupno,a.paycode from master a,guest b,guest c,basecode d where a.class=''F'' and a.haccnt=b.no and a.cusno*=c.no and d.cat=''mststa'' and a.sta=d.code and datediff(day,a.dep,getdate()) = 0 and (1=1) order by a.roomno,d.sequence);a.roomno:����;a.sta:״̬;a.arr:����=7=yy/mm/dd=alignment="2";a.dep:�뿪=5=mm/dd=alignment="2";b.name:����=16;mone10:���=9;char01_6=='''':-;a.groupno:�����=8;c.name:��λ=16;a.paycode:����headerds=[header=1 autoappe=0]texttext=r_lock:��:detail:1::char01_6:char01_6::alignment="2" border="0" font.italic="0" font.face="ms serif" font.charset="0" font.height="-7" color="65280~tif(nodispchar01=''1'',65280,if(nodispchar01=''2'',32768,0))" visible="1~tif(nodispchar01=''0'',0,1)"!',
	'',
	'',3

insert into message_mgr(mgrclass,mgritem,descript,descript1,dwlst,dwprn,dwmac,sequence)
	select 'message','msg4','�����뿪����','Guest Departing Tomorrow',
	'��ǰ����һ����;(select rslt10_1  =  a.accnt,a.roomno,a.sta,a.arr,a.dep,b.name,c.name,mone10  =  a.charge-a.credit,char01  =  substring(a.extra,  10,  1),a.groupno,a.paycode from master a,guest b,guest c,basecode d where a.class=''F'' and a.haccnt=b.no and a.cusno*=c.no and d.cat=''mststa'' and a.sta=d.code and datediff(day,a.dep,getdate()) = -1 and (1=1) order by a.roomno,d.sequence);a.roomno:����;a.sta:״̬;a.arr:����=7=yy/mm/dd=alignment="2";a.dep:�뿪=5=mm/dd=alignment="2";b.name:����=16;mone10:���=9;char01_6=='''':-;a.groupno:�����=8;c.name:��λ=16;a.paycode:����headerds=[header=1 autoappe=0]texttext=r_lock:��:detail:1::char01_6:char01_6::alignment="2" border="0" font.italic="0" font.face="ms serif" font.charset="0" font.height="-7" color="65280~tif(nodispchar01=''1'',65280,if(nodispchar01=''2'',32768,0))" visible="1~tif(nodispchar01=''0'',0,1)"!',
	'',
	'',4 

insert into message_mgr(mgrclass,mgritem,descript,descript1,dwlst,dwprn,dwmac,sequence)
	select 'message','msg5','��ס����','Guest in House ',
	'��ǰ����һ����;(select rslt10_1  =  a.accnt,a.roomno,a.sta,a.arr,a.dep,b.name,c.name,mone10  =  a.charge-a.credit,char01  =  substring(a.extra,  10,  1),a.groupno,a.paycode from master a,guest b,guest c,basecode d where a.class=''F'' and a.haccnt=b.no and a.cusno*=c.no and d.cat=''mststa'' and a.sta=d.code and a.sta=''I'' and (1=1) order by a.roomno,d.sequence);a.roomno:����;a.sta:״̬;a.arr:����=7=yy/mm/dd=alignment="2";a.dep:�뿪=5=mm/dd=alignment="2";b.name:����=16;mone10:���=9;char01_6=='''':-;a.groupno:�����=8;c.name:��λ=16;a.paycode:����headerds=[header=1 autoappe=0]texttext=r_lock:��:detail:1::char01_6:char01_6::alignment="2" border="0" font.italic="0" font.face="ms serif" font.charset="0" font.height="-7" color="65280~tif(nodispchar01=''1'',65280,if(nodispchar01=''2'',32768,0))" visible="1~tif(nodispchar01=''0'',0,1)"!',
	'',
	'',5 

insert into message_mgr(mgrclass,mgritem,descript,descript1,dwlst,dwprn,dwmac,sequence)
	select 'message','msg6','������ס����','Guest in House Tomorrow',
	'��ǰ����һ����;(select rslt10_1  =  a.accnt,a.roomno,a.sta,a.arr,a.dep,b.name,c.name,mone10  =  a.charge-a.credit,char01  =  substring(a.extra,  10,  1),a.groupno,a.paycode from master a,guest b,guest c,basecode d where a.class=''F'' and a.haccnt=b.no and a.cusno*=c.no and d.cat=''mststa'' and a.sta=d.code and ( (a.sta=''I'' and datediff(day,a.dep,getdate()) <> -1 ) or (a.sta=''R'' and datediff(day,a.arr,getdate()) = -1) ) and (1=1) order by a.roomno,d.sequence);a.roomno:����;a.sta:״̬;a.arr:����=7=yy/mm/dd=alignment="2";a.dep:�뿪=5=mm/dd=alignment="2";b.name:����=16;mone10:���=9;char01_6=='''':-;a.groupno:�����=8;c.name:��λ=16;a.paycode:����headerds=[header=1 autoappe=0]texttext=r_lock:��:detail:1::char01_6:char01_6::alignment="2" border="0" font.italic="0" font.face="ms serif" font.charset="0" font.height="-7" color="65280~tif(nodispchar01=''1'',65280,if(nodispchar01=''2'',32768,0))" visible="1~tif(nodispchar01=''0'',0,1)"!',
	'',
	'',6 

insert into message_mgr(mgrclass,mgritem,descript,descript1,dwlst,dwprn,dwmac,sequence)
	select 'message','msg7','�Ŷӿ���','Group Guest',
	'��ǰ����һ����;(select rslt10_1  =  a.accnt,a.roomno,a.sta,a.arr,a.dep,b.name,c.name,mone10  =  a.charge-a.credit,char01  =  substring(a.extra,  10,  1),a.groupno,a.paycode from master a,guest b,guest c,basecode d where a.class=''F'' and a.haccnt=b.no and a.cusno*=c.no and d.cat=''mststa'' and a.sta=d.code and a.groupno <> '''' and (1=1) order by a.roomno,d.sequence);a.roomno:����;a.sta:״̬;a.arr:����=7=yy/mm/dd=alignment="2";a.dep:�뿪=5=mm/dd=alignment="2";b.name:����=16;mone10:���=9;char01_6=='''':-;a.groupno:�����=8;c.name:��λ=16;a.paycode:����headerds=[header=1 autoappe=0]texttext=r_lock:��:detail:1::char01_6:char01_6::alignment="2" border="0" font.italic="0" font.face="ms serif" font.charset="0" font.height="-7" color="65280~tif(nodispchar01=''1'',65280,if(nodispchar01=''2'',32768,0))" visible="1~tif(nodispchar01=''0'',0,1)"!',
	'',
	'',7 

;


