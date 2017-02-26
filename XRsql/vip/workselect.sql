// ----------------------------------------------------------------------------
// vipcard 系统工作表
// ----------------------------------------------------------------------------

// workselect 
delete workselect where window='w_gl_vip_card_list';
INSERT INTO workselect VALUES (
	'00',
	'w_gl_vip_card_list',
	'贵宾卡一览表',
	'贵宾卡一览表_eng',
	'select a.no,a.sno,a.sta,a.araccnt1,d.haccnt,c.name,b.name,a.code1,a.code2,a.ref,a.resby,a.reserved,a.cby,a.changed,numb12  =  (a.credit - a.charge) from vipcard a,guest b,guest c,master_des d where a.hno=b.no and a.cno*=c.no and a.araccnt1*=d.accnt and (1=1)',
	'a.no:卡号=15;a.sno:老卡号=16;a.sta:状态;b.name:名称=16;c.name:单位=22;numb12:积分=10=[general]=alignment="1";a.araccnt1:AR账号=9=[general]=alignment="2";d.haccnt:AR账户名称=16;a.code1:房价码=7;a.code2:POS模式=5;a.ref:备注=30;a.resby:发行;a.reserved:时间=9=yyyy/mm/dd=alignment="2";a.cby:修改;a.changed:时间=9=yyyy/mm/dd=alignment="2"headerds=[footer=1]computes=s_count:count( rslt07_1 ):footer:1::a.name:a.name::alignment="2"!',
	'a.sta',
	'a_no1',
	'_com_p_贵宾卡一览表;(select a.no,a.sno,a.sta,a.araccnt1,d.haccnt,a.name,c.name,b.name,a.code1,a.code2,a.ref from vipcard a,guest b,guest c,master_des d where a.cno*=b.no and a.hno*=c.no and a.araccnt1*=d.accnt and (1=1));a.no:编号;a.sno:卡号=15=[general]=alignment="2";a.sta:状态;a.name:名称=16;a.araccnt1:AR账号=9=[general]=alignment="2";d.haccnt:AR账户名称=16;c.name:客户(宾客)=8;b.name:客户(单位)=22;a.code1:房价码=7;a.code2:POS模式=5;a.ref:备注=30headerds=[header=4 player=3 summary=1] computes=p_yshu:''页次(''+string(page(),''0'')+''/''+string(pagecount(),''0'')+'')'':header:3::a.ref:a.ref::alignment="2" border="0" !computes=heji:count( a.no ):summary:1::a.araccnt1:a.araccnt1::alignment="2" format="0"!texttext=p_title:#hotel#:header:1::a.no:a.ref::border="0" alignment="2" font.height="-14" font.italic="1"!texttext=p_title1:当前贵宾卡一览表:header:2::a.no:a.ref::border="0" alignment="2" font.height="-14" font.italic="1"!texttext=p_date:打印时间 #pdate#:header:3::a.no:a.name::alignment="0" border="0" !texttext=htext:合计:summary:1::a.no:a.sta::alignment="2" !',
	'F',
	'F');


// worksheet
delete worksheet where window='w_gl_vip_card_list';
INSERT INTO worksheet VALUES ('00','w_gl_vip_card_list',1,'所有','All','1=1',10,'','','','','','F');
INSERT INTO worksheet VALUES ('00','w_gl_vip_card_list',2,'积分卡','Points Card','a.class=''1''',20,'','','','','','F');
INSERT INTO worksheet VALUES ('00','w_gl_vip_card_list',3,'个人储值卡','Personal AR Card','a.class=''2''',30,'','','','','','F');
INSERT INTO worksheet VALUES ('00','w_gl_vip_card_list',4,'单位储值卡','Company AR Card','a.class=''3''',40,'','','','','','F');
INSERT INTO worksheet VALUES ('00','w_gl_vip_card_list',5,'不记名储值卡','NoName AR Card','a.class=''4''',50,'','','','','','F');
INSERT INTO worksheet VALUES ('00','w_gl_vip_card_list',6,'卡未发行','','a.crc=''''',100,'','','','','','F');

// worksta_name
delete worksta_name where window='w_gl_vip_card_list';
INSERT INTO worksta_name VALUES ('w_gl_vip_card_list','','所有','All','T',10);
INSERT INTO worksta_name VALUES ('w_gl_vip_card_list','''R''','初始','Init','F',20);
INSERT INTO worksta_name VALUES ('w_gl_vip_card_list','''I''','有效','Valid','F',30);
INSERT INTO worksta_name VALUES ('w_gl_vip_card_list','''L''','挂失','Suspend','F',40);
INSERT INTO worksta_name VALUES ('w_gl_vip_card_list','''S''','休眠','Sleep','F',50);
INSERT INTO worksta_name VALUES ('w_gl_vip_card_list','''O''','停用','Stoped','F',60);
INSERT INTO worksta_name VALUES ('w_gl_vip_card_list','''X''','销卡','Cancellation','F',70);
INSERT INTO worksta_name VALUES ('w_gl_vip_card_list','''D''','删除','Delete','F',80);


// workbutton_name
delete workbutton_name where window='w_gl_vip_card_list';
INSERT INTO workbutton_name VALUES ('w_gl_vip_card_list','ue_new','新建','Create','T',10);
INSERT INTO workbutton_name VALUES ('w_gl_vip_card_list','ue_open',' 打开','Open','T',20);
INSERT INTO workbutton_name VALUES ('w_gl_vip_card_list','ue_sep1','','','T',25);
INSERT INTO workbutton_name VALUES ('w_gl_vip_card_list','ue_no','卡号','No','T',30);
INSERT INTO workbutton_name VALUES ('w_gl_vip_card_list','ue_sno','原卡号','Sno','T',40);
INSERT INTO workbutton_name VALUES ('w_gl_vip_card_list','ue_name','名称','Name','T',50);
INSERT INTO workbutton_name VALUES ('w_gl_vip_card_list','ue_unit','单位名','Comp. Name','T',70);
INSERT INTO workbutton_name VALUES ('w_gl_vip_card_list','ue_ar','AR账户','AR','T',80);
--INSERT INTO workbutton_name VALUES ('w_gl_vip_card_list','ue_emp1','发行','Create','T',100);
--INSERT INTO workbutton_name VALUES ('w_gl_vip_card_list','ue_emp2','修改','Modify','T',110);
INSERT INTO workbutton_name VALUES ('w_gl_vip_card_list','ue_sep2','','','T',120);
INSERT INTO workbutton_name VALUES ('w_gl_vip_card_list','ue_hname','持卡人','Guest','T',150);
INSERT INTO workbutton_name VALUES ('w_gl_vip_card_list','ue_cname','单位','Company','T',160);
INSERT INTO workbutton_name VALUES ('w_gl_vip_card_list','ue_ar1','AR账','Account','T',170);
INSERT INTO workbutton_name VALUES ('w_gl_vip_card_list','ue_pool','发卡池','Iss. Pool','T',200);
INSERT INTO workbutton_name VALUES ('w_gl_vip_card_list','ue_issue','发卡','Issue','T',210);
INSERT INTO workbutton_name VALUES ('w_gl_vip_card_list','ue_post','积分入账','Point Post','T',250);
