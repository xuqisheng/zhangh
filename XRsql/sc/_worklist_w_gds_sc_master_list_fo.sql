----------------------------------------------------------------------------------------------------
--	ϵͳ������ w_gds_sc_master_list_fo : blocks �б�ǰ̨��
--
--	�����е���̫����Ϊ�˱༭���㣬�����������ı��༭���ߴ���
--
--
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- ɾ��������� 
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
	'Block Ԥ���б�',
	'Blocks List',
	'select a.foact,a.resno,a.rmnum,a.roomno,a.gstno,a.name,a.name2,a.sta,a.status,a.c_status, char012  =  substring(a.extra,  4,  1),char013  =  substring(a.extra,  5,  1), umb081  =  (Select count(1) From message_leaveword Where sort = ''LWD'' And accnt=a.accnt And tag<''2''),numb082  =  (Select count(1) From message_leaveword Where sort = ''LOC'' And accnt=a.accnt And tag=''1'' and datediff(second,  abate,  getdate())<0),char01  =  substring(a.extra,  10,  1), a.arr,a.dep,a.ref,char991  =  convert(char(99),  c.cusno+''/''+c.unit+''/''+  c.agent+''/''+c.source),mone100  =  a.charge-a.credit,a.setrate,a.resno,a.market,a.packages,char15  =  a.pcrec,rslt10  =  a.accnt, a.accnt from sc_master a, master_des c  where a.accnt*=c.accnt and a.foact like ''_F%'' and (1=1) order by a.arr',
	'a.accnt:�ʺ�=10;a.resno:Ԥ����=10;char01_1=='''':-;a.rmnum:��=4=0=alignment="2";a.gstno:��=3=0=alignment="2";a.name:����=20;a.sta:״̬=3;a.status:STA1=3;a.c_status:STA2=3;a.market:Market=3;a.arr:����=9=yy/mm/dd =alignment=''2'';a.dep:�뿪=9=yy/mm/dd =alignment=''2'';a.setrate:����=6=0.00=color="0~tif(nodispchar013=''1'',255,0)";char991:��λ/������/��������=26;a.ref:��ע=30;mone100:���=8=0.00=color="0~tif(mone100>0,255,0)";a.foact:FOACTheaderds=[footer=1 autoappe=0]computes=c_jshu:( count( a_foact1 ) ):footer:1::a.accnt:a.accnt::alignment="2"!texttext=r_flag:��:detail:1::char01_1:char01_1::alignment="2" border="0" font.italic="0" font.face="ms serif" font.charset="0" font.height="-10" color="255" visible="1~tif(trim(a_foact1)<>'''',1,0)"!',
	'a.status',
	'rslt10',
	'_com_p_Blocks �б�;(select a.foact,a.rmnum,a.roomno,a.gstno,a.name,a.name2,a.sta,a.status,a.c_status,char012  =  substring(a.extra,  4,  1),char013  =  substring(a.extra,  5,  1), numb081  =  (Select count(1) From message_leaveword Where sort = ''LWD'' And accnt=a.accnt And tag<''2''),numb082  =  (Select count(1) From message_leaveword Where sort = ''LOC'' And accnt=a.accnt And tag=''1'' and datediff(second,  abate,  getdate())<0),char01  =  substring(a.extra,  10,  1), a.arr,a.dep,a.ref,char991  =  convert(char(99),  c.cusno+''/''+c.unit+''/''+  c.agent+''/''+c.source),mone100  =  a.charge-a.credit,a.setrate,a.resno,a.market,a.packages,char15  =  a.pcrec,rslt10  =  a.accnt, a.accnt from sc_master a, master_des c  where a.class in (''F'',  ''G'',  ''M'') and a.accnt*=c.accnt and (1=1) order by a.arr);a.accnt:�ʺ�=10;char01_1=='''':-;a.rmnum:��=4=0=alignment="2";a.gstno:��=3=0=alignment="2";a.name:����=20;a.sta:״̬=3;a.status:STA1=3;a.c_status:STA2=3;a.market:Market=3;a.arr:����=9=yy/mm/dd =alignment=''2'';a.dep:�뿪=9=yy/mm/dd =alignment=''2'';a.setrate:����=6=0.00=color="0~tif(nodispchar013=''1'',255,0)";char991:��λ/������/��������=26;a.ref:��ע=30;mone100:���=8=0.00=color="0~tif(mone100>0,255,0)";a.foact:FOACTheaderds=[footer=1 autoappe=0]computes=c_jshu:( count( a_foact1 ) ):footer:1::a.accnt:a.accnt::alignment="2"!texttext=r_flag:��:detail:1::char01_1:char01_1::alignment="2" border="0" font.italic="0" font.face="ms serif" font.charset="0" font.height="-10" color="255" visible="1~tif(trim(a_foact1)<>'''',1,0)"!texttext=t_hotel:#hotel#:header:1::a.accnt:a.ref::alignment="2" font.height="-12" border="0"!texttext=t_title:������Ϣ�б�:header:2::a.accnt:a.ref::alignment="2" font.height="-12" border="0"!texttext=t_print:��ӡʱ�� #pdate#:header:3::a.accnt:a.type::alignment="0"!',
	'F',
	'T');

----------------------------------------------------------------------------------------------------
-- worksheet (modu_id,window,tab_no,descript,descript1,tab_tag,sequence,colsele,coldes,colsta,colkey,genput,usedef ) 
----------------------------------------------------------------------------------------------------
INSERT INTO worksheet VALUES (
	'01',
	'w_gds_sc_master_list_fo',
	6,
	'����',
	'All',
	'1=1',
	10,
	'',
	'',
	'',
	'',
	'_com_p_��ǰ�����ڵ���˱���;(select a.roomno,a.arr,a.dep,b.name,b.sex,b.ident,b.address,b.nation,b.vip,mone30  =  (a.credit - a.charge)   from master a,guest b where a.haccnt=b.no and a.sta =''I'' and a.roomno<>'''' order by a.roomno,a.accnt);a.roomno:����;a.arr:����=12=yy/mm/dd hh|mm;a.dep:����=8=yy/mm/dd;b.name:����=12;b.sex:�Ա�;b.ident:֤����;b.address:��ַ=20;b.nation:����;b.vip:VIP;mone30:���headerds=[header=4 player=3 summary=1 ] computes=p_yshu:''ҳ��(''+string(page(),''0'')+''/''+string(pagecount(),''0)''):header:3::mone30:mone30::alignment="2" !computes=fshu:count( a.roomno for all DISTINCT ):summary:1::a.dep:a.dep::alignment="0" format="0"!computes=rrrr:count( a.roomno ):summary:1::b.sex:b.sex::alignment="0" format="0"!texttext=p_title:#hotel#:header:1::a.roomno:mone30::border="0" alignment="2" font.height="-12" font.italic="1"!texttext=p_title1:��ǰ�����ڵ���˱���:header:2::a.accnt:mone30::border="0" alignment="2" font.height="-12" font.italic="1"!texttext=p_date:��ӡʱ�� #pdate#:header:3::a.roomno:a.dep::alignment="0"!texttext=t_fshu:����:summary:1::a.roomno:a.arr::alignment="2"!texttext=t_rshu:����:summary:1::b.name:b.name::alignment="2"!',
	'F');


----------------------------------------------------------------------------------------------------
-- workbutton_name  (window,event,descript,descript1,show,lic,sequence)
----------------------------------------------------------------------------------------------------
insert workbutton_name VALUES ('w_gds_sc_master_list_fo','ue_master','����','Reservation','T','',10);
insert workbutton_name VALUES ('w_gds_sc_master_list_fo','ue_profile','����','Profile','T','',12);
insert workbutton_name VALUES ('w_gds_sc_master_list_fo','ue_foact','��������','FO Resrv.','T','',15);
insert workbutton_name VALUES ('w_gds_sc_master_list_fo','ue_sep1','','','T','',25);
insert workbutton_name VALUES ('w_gds_sc_master_list_fo','ue_new','�½�','New Group','T','',30);
insert workbutton_name VALUES ('w_gds_sc_master_list_fo','ue_sep2','','','T','',45);
insert workbutton_name VALUES ('w_gds_sc_master_list_fo','ue_rmgrid','�ͷ�ռ��','Room Grid','T','',50);
insert workbutton_name VALUES ('w_gds_sc_master_list_fo','ue_activity','�','Activities','T','',70);
insert workbutton_name VALUES ('w_gds_sc_master_list_fo','ue_bill_res','��ӡ����','Print Folio','T','',80);
insert workbutton_name VALUES ('w_gds_sc_master_list_fo','ue_note','��ע','Notes','T','',90);
insert workbutton_name VALUES ('w_gds_sc_master_list_fo','ue_sep3','','','T','',95);
insert workbutton_name VALUES ('w_gds_sc_master_list_fo','ue_account','������','Billing','F','---',100);
insert workbutton_name VALUES ('w_gds_sc_master_list_fo','ue_fixchg','�̶�֧��','Fixed charges','F','---',110);
insert workbutton_name VALUES ('w_gds_sc_master_list_fo','ue_locksta','�������','Auth. Post','F','---',120);
insert workbutton_name VALUES ('w_gds_sc_master_list_fo','ue_posting','����','Posting','F','---',130);
insert workbutton_name VALUES ('w_gds_sc_master_list_fo','ue_routing','�����˻�','Routing','F','---',140);
insert workbutton_name VALUES ('w_gds_sc_master_list_fo','ue_bill_accnt','��ӡ�˵�','Info Copy','F','---',150);

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
	'����',
	'All',
	'F',
	0);
INSERT INTO worksta_name VALUES (
	'w_gds_sc_master_list_fo',
	'''INQ''',
	'��Ѷ��',
	'Inquiry',
	'F',
	10);
INSERT INTO worksta_name VALUES (
	'w_gds_sc_master_list_fo',
	'''TEN''',
	'��ȷ��Ԥ��',
	'TEN-Resrv.',
	'F',
	20);
INSERT INTO worksta_name VALUES (
	'w_gds_sc_master_list_fo',
	'''TEN'',''DEF'',''ACT''',
	'Ԥ��',
	'Resrv.',
	'T',
	30);
INSERT INTO worksta_name VALUES (
	'w_gds_sc_master_list_fo',
	'''CAN''',
	'ȡ��',
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
	'��ʧ',
	'Lost',
	'F',
	60);


----------------------------------------------------------------------------------------------------
-- worksta (window,modu_id,sta )
----------------------------------------------------------------------------------------------------
-- null 


-- (over)   ;
