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
	select 'message','msg0','全部客人','All Guest',
	'当前宾客一览表;(select rslt10_1  =  a.accnt,a.roomno,a.sta,a.arr,a.dep,b.name,c.name,mone10  =  a.charge-a.credit,char01  =  substring(a.extra,  10,  1),a.groupno,a.paycode from master a,guest b,guest c,basecode d where a.class=''F'' and a.haccnt=b.no and a.cusno*=c.no and d.cat=''mststa'' and a.sta=d.code and (1=1) order by a.roomno,d.sequence);a.roomno:房号;a.sta:状态;a.arr:到达=7=yy/mm/dd=alignment="2";a.dep:离开=5=mm/dd=alignment="2";b.name:姓名=16;mone10:余额=9;char01_6=='''':-;a.groupno:团体号=8;c.name:单位=16;a.paycode:结算headerds=[header=1 autoappe=0]texttext=r_lock:●:detail:1::char01_6:char01_6::alignment="2" border="0" font.italic="0" font.face="ms serif" font.charset="0" font.height="-7" color="65280~tif(nodispchar01=''1'',65280,if(nodispchar01=''2'',32768,0))" visible="1~tif(nodispchar01=''0'',0,1)"!',
	'',
	'',0

insert into message_mgr(mgrclass,mgritem,descript,descript1,dwlst,dwprn,dwmac,sequence)
	select 'message','msg1','今日到达客人','Guest Arriving Today',
	'当前宾客一览表;(select rslt10_1  =  a.accnt,a.roomno,a.sta,a.arr,a.dep,b.name,c.name,mone10  =  a.charge-a.credit,char01  =  substring(a.extra,  10,  1),a.groupno,a.paycode from master a,guest b,guest c,basecode d where a.class=''F'' and a.haccnt=b.no and a.cusno*=c.no and d.cat=''mststa'' and a.sta=d.code and datediff(day,a.arr,getdate()) = 0 and (1=1) order by a.roomno,d.sequence);a.roomno:房号;a.sta:状态;a.arr:到达=7=yy/mm/dd=alignment="2";a.dep:离开=5=mm/dd=alignment="2";b.name:姓名=16;mone10:余额=9;char01_6=='''':-;a.groupno:团体号=8;c.name:单位=16;a.paycode:结算headerds=[header=1 autoappe=0]texttext=r_lock:●:detail:1::char01_6:char01_6::alignment="2" border="0" font.italic="0" font.face="ms serif" font.charset="0" font.height="-7" color="65280~tif(nodispchar01=''1'',65280,if(nodispchar01=''2'',32768,0))" visible="1~tif(nodispchar01=''0'',0,1)"!',
	'',
	'',1

insert into message_mgr(mgrclass,mgritem,descript,descript1,dwlst,dwprn,dwmac,sequence)
	select 'message','msg2','明日到达客人','Guest Arriving Tomorrow',
	'当前宾客一览表;(select rslt10_1  =  a.accnt,a.roomno,a.sta,a.arr,a.dep,b.name,c.name,mone10  =  a.charge-a.credit,char01  =  substring(a.extra,  10,  1),a.groupno,a.paycode from master a,guest b,guest c,basecode d where a.class=''F'' and a.haccnt=b.no and a.cusno*=c.no and d.cat=''mststa'' and a.sta=d.code and datediff(day,a.arr,getdate()) = -1 and (1=1) order by a.roomno,d.sequence);a.roomno:房号;a.sta:状态;a.arr:到达=7=yy/mm/dd=alignment="2";a.dep:离开=5=mm/dd=alignment="2";b.name:姓名=16;mone10:余额=9;char01_6=='''':-;a.groupno:团体号=8;c.name:单位=16;a.paycode:结算headerds=[header=1 autoappe=0]texttext=r_lock:●:detail:1::char01_6:char01_6::alignment="2" border="0" font.italic="0" font.face="ms serif" font.charset="0" font.height="-7" color="65280~tif(nodispchar01=''1'',65280,if(nodispchar01=''2'',32768,0))" visible="1~tif(nodispchar01=''0'',0,1)"!',
	'',
	'',2

insert into message_mgr(mgrclass,mgritem,descript,descript1,dwlst,dwprn,dwmac,sequence)
	select 'message','msg3','今日离开客人','Guest Departing Today',
	'当前宾客一览表;(select rslt10_1  =  a.accnt,a.roomno,a.sta,a.arr,a.dep,b.name,c.name,mone10  =  a.charge-a.credit,char01  =  substring(a.extra,  10,  1),a.groupno,a.paycode from master a,guest b,guest c,basecode d where a.class=''F'' and a.haccnt=b.no and a.cusno*=c.no and d.cat=''mststa'' and a.sta=d.code and datediff(day,a.dep,getdate()) = 0 and (1=1) order by a.roomno,d.sequence);a.roomno:房号;a.sta:状态;a.arr:到达=7=yy/mm/dd=alignment="2";a.dep:离开=5=mm/dd=alignment="2";b.name:姓名=16;mone10:余额=9;char01_6=='''':-;a.groupno:团体号=8;c.name:单位=16;a.paycode:结算headerds=[header=1 autoappe=0]texttext=r_lock:●:detail:1::char01_6:char01_6::alignment="2" border="0" font.italic="0" font.face="ms serif" font.charset="0" font.height="-7" color="65280~tif(nodispchar01=''1'',65280,if(nodispchar01=''2'',32768,0))" visible="1~tif(nodispchar01=''0'',0,1)"!',
	'',
	'',3

insert into message_mgr(mgrclass,mgritem,descript,descript1,dwlst,dwprn,dwmac,sequence)
	select 'message','msg4','明日离开客人','Guest Departing Tomorrow',
	'当前宾客一览表;(select rslt10_1  =  a.accnt,a.roomno,a.sta,a.arr,a.dep,b.name,c.name,mone10  =  a.charge-a.credit,char01  =  substring(a.extra,  10,  1),a.groupno,a.paycode from master a,guest b,guest c,basecode d where a.class=''F'' and a.haccnt=b.no and a.cusno*=c.no and d.cat=''mststa'' and a.sta=d.code and datediff(day,a.dep,getdate()) = -1 and (1=1) order by a.roomno,d.sequence);a.roomno:房号;a.sta:状态;a.arr:到达=7=yy/mm/dd=alignment="2";a.dep:离开=5=mm/dd=alignment="2";b.name:姓名=16;mone10:余额=9;char01_6=='''':-;a.groupno:团体号=8;c.name:单位=16;a.paycode:结算headerds=[header=1 autoappe=0]texttext=r_lock:●:detail:1::char01_6:char01_6::alignment="2" border="0" font.italic="0" font.face="ms serif" font.charset="0" font.height="-7" color="65280~tif(nodispchar01=''1'',65280,if(nodispchar01=''2'',32768,0))" visible="1~tif(nodispchar01=''0'',0,1)"!',
	'',
	'',4 

insert into message_mgr(mgrclass,mgritem,descript,descript1,dwlst,dwprn,dwmac,sequence)
	select 'message','msg5','在住客人','Guest in House ',
	'当前宾客一览表;(select rslt10_1  =  a.accnt,a.roomno,a.sta,a.arr,a.dep,b.name,c.name,mone10  =  a.charge-a.credit,char01  =  substring(a.extra,  10,  1),a.groupno,a.paycode from master a,guest b,guest c,basecode d where a.class=''F'' and a.haccnt=b.no and a.cusno*=c.no and d.cat=''mststa'' and a.sta=d.code and a.sta=''I'' and (1=1) order by a.roomno,d.sequence);a.roomno:房号;a.sta:状态;a.arr:到达=7=yy/mm/dd=alignment="2";a.dep:离开=5=mm/dd=alignment="2";b.name:姓名=16;mone10:余额=9;char01_6=='''':-;a.groupno:团体号=8;c.name:单位=16;a.paycode:结算headerds=[header=1 autoappe=0]texttext=r_lock:●:detail:1::char01_6:char01_6::alignment="2" border="0" font.italic="0" font.face="ms serif" font.charset="0" font.height="-7" color="65280~tif(nodispchar01=''1'',65280,if(nodispchar01=''2'',32768,0))" visible="1~tif(nodispchar01=''0'',0,1)"!',
	'',
	'',5 

insert into message_mgr(mgrclass,mgritem,descript,descript1,dwlst,dwprn,dwmac,sequence)
	select 'message','msg6','明日在住客人','Guest in House Tomorrow',
	'当前宾客一览表;(select rslt10_1  =  a.accnt,a.roomno,a.sta,a.arr,a.dep,b.name,c.name,mone10  =  a.charge-a.credit,char01  =  substring(a.extra,  10,  1),a.groupno,a.paycode from master a,guest b,guest c,basecode d where a.class=''F'' and a.haccnt=b.no and a.cusno*=c.no and d.cat=''mststa'' and a.sta=d.code and ( (a.sta=''I'' and datediff(day,a.dep,getdate()) <> -1 ) or (a.sta=''R'' and datediff(day,a.arr,getdate()) = -1) ) and (1=1) order by a.roomno,d.sequence);a.roomno:房号;a.sta:状态;a.arr:到达=7=yy/mm/dd=alignment="2";a.dep:离开=5=mm/dd=alignment="2";b.name:姓名=16;mone10:余额=9;char01_6=='''':-;a.groupno:团体号=8;c.name:单位=16;a.paycode:结算headerds=[header=1 autoappe=0]texttext=r_lock:●:detail:1::char01_6:char01_6::alignment="2" border="0" font.italic="0" font.face="ms serif" font.charset="0" font.height="-7" color="65280~tif(nodispchar01=''1'',65280,if(nodispchar01=''2'',32768,0))" visible="1~tif(nodispchar01=''0'',0,1)"!',
	'',
	'',6 

insert into message_mgr(mgrclass,mgritem,descript,descript1,dwlst,dwprn,dwmac,sequence)
	select 'message','msg7','团队客人','Group Guest',
	'当前宾客一览表;(select rslt10_1  =  a.accnt,a.roomno,a.sta,a.arr,a.dep,b.name,c.name,mone10  =  a.charge-a.credit,char01  =  substring(a.extra,  10,  1),a.groupno,a.paycode from master a,guest b,guest c,basecode d where a.class=''F'' and a.haccnt=b.no and a.cusno*=c.no and d.cat=''mststa'' and a.sta=d.code and a.groupno <> '''' and (1=1) order by a.roomno,d.sequence);a.roomno:房号;a.sta:状态;a.arr:到达=7=yy/mm/dd=alignment="2";a.dep:离开=5=mm/dd=alignment="2";b.name:姓名=16;mone10:余额=9;char01_6=='''':-;a.groupno:团体号=8;c.name:单位=16;a.paycode:结算headerds=[header=1 autoappe=0]texttext=r_lock:●:detail:1::char01_6:char01_6::alignment="2" border="0" font.italic="0" font.face="ms serif" font.charset="0" font.height="-7" color="65280~tif(nodispchar01=''1'',65280,if(nodispchar01=''2'',32768,0))" visible="1~tif(nodispchar01=''0'',0,1)"!',
	'',
	'',7 

;


