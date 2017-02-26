----------------------------------------------------------------------------------------------------
--	系统工作表 w_gds_sc_master_list_fo : blocks 列表（前台）
--
--	由于有的行太长，为了编辑方便，可以在其他文本编辑工具处理，
--
--
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- 删除所有相关 
----------------------------------------------------------------------------------------------------
delete  workselect 		where window='w_gds_sc_master_list_fo';
delete  worksheet 		where window='w_gds_sc_master_list_fo';
delete  workbutton_name where window='w_gds_sc_master_list_fo' ;
delete  workbutton 		where window='w_gds_sc_master_list_fo';
delete  worksta_name 	where window='w_gds_sc_master_list_fo';
delete  worksta 		where window='w_gds_sc_master_list_fo';

----------------------------------------------------------------------------------------------------
-- workselect (modu_id,window,descript,descript1,colsele,coldes,colsta,colkey,genput,usedef,openflash  )
----------------------------------------------------------------------------------------------------
INSERT INTO workselect VALUES (
	'01',
	'w_gds_sc_master_list_fo',
	'Block 预订列表',
	'Blocks List',
	'select a.foact,a.resno,a.rmnum,a.roomno,a.gstno,a.name,a.name2,a.sta,a.status,a.c_status, char012  =  substring(a.extra,  4,  1),char013  =  substring(a.extra,  5,  1), umb081  =  (Select count(1) From message_leaveword Where sort = ''LWD'' And accnt=a.accnt And tag<''2''),numb082  =  (Select count(1) From message_leaveword Where sort = ''LOC'' And accnt=a.accnt And tag=''1'' and datediff(second,  abate,  getdate())<0),char01  =  substring(a.extra,  10,  1), a.arr,a.dep,a.ref,char991  =  convert(char(99),  c.cusno+''/''+c.unit+''/''+  c.agent+''/''+c.source),mone100  =  a.charge-a.credit,a.setrate,a.resno,a.market,a.packages,char15  =  a.pcrec,rslt10  =  a.accnt, a.accnt from sc_master a, master_des c  where a.accnt*=c.accnt and a.foact like ''_F%'' and (1=1) order by a.arr',
	'a.accnt:帐号=10;a.resno:预订号=10;char01_1=='''':-;a.rmnum:房=4=0=alignment="2";a.gstno:人=3=0=alignment="2";a.name:姓名=20;a.sta:状态=3;a.status:STA1=3;a.c_status:STA2=3;a.market:Market=3;a.arr:到达=9=yy/mm/dd =alignment=''2'';a.dep:离开=9=yy/mm/dd =alignment=''2'';a.setrate:房价=6=0.00=color="0~tif(nodispchar013=''1'',255,0)";char991:单位/旅行社/订房中心=26;a.ref:备注=30;mone100:余额=8=0.00=color="0~tif(mone100>0,255,0)";a.foact:FOACTheaderds=[footer=1 autoappe=0]computes=c_jshu:( count( a_foact1 ) ):footer:1::a.accnt:a.accnt::alignment="2"!texttext=r_flag:●:detail:1::char01_1:char01_1::alignment="2" border="0" font.italic="0" font.face="ms serif" font.charset="0" font.height="-10" color="255" visible="1~tif(trim(a_foact1)<>'''',1,0)"!',
	'a.status',
	'rslt10',
	'_com_p_Blocks 列表;(select a.foact,a.rmnum,a.roomno,a.gstno,a.name,a.name2,a.sta,a.status,a.c_status,char012  =  substring(a.extra,  4,  1),char013  =  substring(a.extra,  5,  1), numb081  =  (Select count(1) From message_leaveword Where sort = ''LWD'' And accnt=a.accnt And tag<''2''),numb082  =  (Select count(1) From message_leaveword Where sort = ''LOC'' And accnt=a.accnt And tag=''1'' and datediff(second,  abate,  getdate())<0),char01  =  substring(a.extra,  10,  1), a.arr,a.dep,a.ref,char991  =  convert(char(99),  c.cusno+''/''+c.unit+''/''+  c.agent+''/''+c.source),mone100  =  a.charge-a.credit,a.setrate,a.resno,a.market,a.packages,char15  =  a.pcrec,rslt10  =  a.accnt, a.accnt from sc_master a, master_des c  where a.class in (''F'',  ''G'',  ''M'') and a.accnt*=c.accnt and (1=1) order by a.arr);a.accnt:帐号=10;char01_1=='''':-;a.rmnum:房=4=0=alignment="2";a.gstno:人=3=0=alignment="2";a.name:姓名=20;a.sta:状态=3;a.status:STA1=3;a.c_status:STA2=3;a.market:Market=3;a.arr:到达=9=yy/mm/dd =alignment=''2'';a.dep:离开=9=yy/mm/dd =alignment=''2'';a.setrate:房价=6=0.00=color="0~tif(nodispchar013=''1'',255,0)";char991:单位/旅行社/订房中心=26;a.ref:备注=30;mone100:余额=8=0.00=color="0~tif(mone100>0,255,0)";a.foact:FOACTheaderds=[footer=1 autoappe=0]computes=c_jshu:( count( a_foact1 ) ):footer:1::a.accnt:a.accnt::alignment="2"!texttext=r_flag:●:detail:1::char01_1:char01_1::alignment="2" border="0" font.italic="0" font.face="ms serif" font.charset="0" font.height="-10" color="255" visible="1~tif(trim(a_foact1)<>'''',1,0)"!texttext=t_hotel:#hotel#:header:1::a.accnt:a.ref::alignment="2" font.height="-12" border="0"!texttext=t_title:宾客信息列表:header:2::a.accnt:a.ref::alignment="2" font.height="-12" border="0"!texttext=t_print:打印时间 #pdate#:header:3::a.accnt:a.type::alignment="0"!',
	'F',
	'T');

----------------------------------------------------------------------------------------------------
-- worksheet (modu_id,window,tab_no,descript,descript1,tab_tag,sequence,colsele,coldes,colsta,colkey,genput,usedef ) 
----------------------------------------------------------------------------------------------------
INSERT INTO worksheet VALUES (
	'01',
	'w_gds_sc_master_list_fo',
	6,
	'所有',
	'All',
	'1=1',
	10,
	'',
	'',
	'',
	'',
	'_com_p_当前所有在店客人报表;(select a.roomno,a.arr,a.dep,b.name,b.sex,b.ident,b.address,b.nation,b.vip,mone30  =  (a.credit - a.charge)   from master a,guest b where a.haccnt=b.no and a.sta =''I'' and a.roomno<>'''' order by a.roomno,a.accnt);a.roomno:房号;a.arr:到日=12=yy/mm/dd hh|mm;a.dep:离日=8=yy/mm/dd;b.name:姓名=12;b.sex:性别;b.ident:证件号;b.address:地址=20;b.nation:国籍;b.vip:VIP;mone30:余额headerds=[header=4 player=3 summary=1 ] computes=p_yshu:''页次(''+string(page(),''0'')+''/''+string(pagecount(),''0)''):header:3::mone30:mone30::alignment="2" !computes=fshu:count( a.roomno for all DISTINCT ):summary:1::a.dep:a.dep::alignment="0" format="0"!computes=rrrr:count( a.roomno ):summary:1::b.sex:b.sex::alignment="0" format="0"!texttext=p_title:#hotel#:header:1::a.roomno:mone30::border="0" alignment="2" font.height="-12" font.italic="1"!texttext=p_title1:当前所有在店客人报表:header:2::a.accnt:mone30::border="0" alignment="2" font.height="-12" font.italic="1"!texttext=p_date:打印时间 #pdate#:header:3::a.roomno:a.dep::alignment="0"!texttext=t_fshu:房数:summary:1::a.roomno:a.arr::alignment="2"!texttext=t_rshu:人数:summary:1::b.name:b.name::alignment="2"!',
	'F');


----------------------------------------------------------------------------------------------------
-- workbutton_name  (window,event,descript,descript1,show,lic,sequence)
----------------------------------------------------------------------------------------------------
insert workbutton_name VALUES ('w_gds_sc_master_list_fo','ue_master','主单','Reservation','T','',10);
insert workbutton_name VALUES ('w_gds_sc_master_list_fo','ue_profile','档案','Profile','T','',12);
insert workbutton_name VALUES ('w_gds_sc_master_list_fo','ue_foact','关联主单','FO Resrv.','T','',15);
insert workbutton_name VALUES ('w_gds_sc_master_list_fo','ue_sep1','','','T','',25);
insert workbutton_name VALUES ('w_gds_sc_master_list_fo','ue_new','新建','New Group','T','',30);
insert workbutton_name VALUES ('w_gds_sc_master_list_fo','ue_sep2','','','T','',45);
insert workbutton_name VALUES ('w_gds_sc_master_list_fo','ue_rmgrid','客房占用','Room Grid','T','',50);
insert workbutton_name VALUES ('w_gds_sc_master_list_fo','ue_activity','活动','Activities','T','',70);
insert workbutton_name VALUES ('w_gds_sc_master_list_fo','ue_bill_res','打印单据','Print Folio','T','',80);
insert workbutton_name VALUES ('w_gds_sc_master_list_fo','ue_note','备注','Notes','T','',90);
insert workbutton_name VALUES ('w_gds_sc_master_list_fo','ue_sep3','','','T','',95);
insert workbutton_name VALUES ('w_gds_sc_master_list_fo','ue_account','账务处理','Billing','F','---',100);
insert workbutton_name VALUES ('w_gds_sc_master_list_fo','ue_fixchg','固定支出','Fixed charges','F','---',110);
insert workbutton_name VALUES ('w_gds_sc_master_list_fo','ue_locksta','允许记账','Auth. Post','F','---',120);
insert workbutton_name VALUES ('w_gds_sc_master_list_fo','ue_posting','入帐','Posting','F','---',130);
insert workbutton_name VALUES ('w_gds_sc_master_list_fo','ue_routing','定义账户','Routing','F','---',140);
insert workbutton_name VALUES ('w_gds_sc_master_list_fo','ue_bill_accnt','打印账单','Info Copy','F','---',150);

----------------------------------------------------------------------------------------------------
-- workbutton (window,modu_id,tab_no,event )
----------------------------------------------------------------------------------------------------
-- null 

----------------------------------------------------------------------------------------------------
-- worksta_name (window,sta,descript,descript1,show,sequence)
----------------------------------------------------------------------------------------------------
INSERT INTO worksta_name VALUES (
	'w_gds_sc_master_list_fo',
	'',
	'所有',
	'All',
	'F',
	0);
INSERT INTO worksta_name VALUES (
	'w_gds_sc_master_list_fo',
	'''INQ''',
	'问讯候补',
	'Inquiry',
	'F',
	10);
INSERT INTO worksta_name VALUES (
	'w_gds_sc_master_list_fo',
	'''TEN''',
	'非确认预订',
	'TEN-Resrv.',
	'F',
	20);
INSERT INTO worksta_name VALUES (
	'w_gds_sc_master_list_fo',
	'''TEN'',''DEF'',''ACT''',
	'预订',
	'Resrv.',
	'T',
	30);
INSERT INTO worksta_name VALUES (
	'w_gds_sc_master_list_fo',
	'''CAN''',
	'取消',
	'Cancellation',
	'F',
	40);
INSERT INTO worksta_name VALUES (
	'w_gds_sc_master_list_fo',
	'''NS''',
	'NO-SHOW',
	'No-show',
	'F',
	50);
INSERT INTO worksta_name VALUES (
	'w_gds_sc_master_list_fo',
	'''LOS''',
	'丢失',
	'Lost',
	'F',
	60);


----------------------------------------------------------------------------------------------------
-- worksta (window,modu_id,sta )
----------------------------------------------------------------------------------------------------
-- null 


-- (over)   ;
