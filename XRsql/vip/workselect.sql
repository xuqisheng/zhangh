// ----------------------------------------------------------------------------
// vipcard ϵͳ������
// ----------------------------------------------------------------------------

// workselect 
delete workselect where window='w_gl_vip_card_list';
INSERT INTO workselect VALUES (
	'00',
	'w_gl_vip_card_list',
	'�����һ����',
	'�����һ����_eng',
	'select a.no,a.sno,a.sta,a.araccnt1,d.haccnt,c.name,b.name,a.code1,a.code2,a.ref,a.resby,a.reserved,a.cby,a.changed,numb12  =  (a.credit - a.charge) from vipcard a,guest b,guest c,master_des d where a.hno=b.no and a.cno*=c.no and a.araccnt1*=d.accnt and (1=1)',
	'a.no:����=15;a.sno:�Ͽ���=16;a.sta:״̬;b.name:����=16;c.name:��λ=22;numb12:����=10=[general]=alignment="1";a.araccnt1:AR�˺�=9=[general]=alignment="2";d.haccnt:AR�˻�����=16;a.code1:������=7;a.code2:POSģʽ=5;a.ref:��ע=30;a.resby:����;a.reserved:ʱ��=9=yyyy/mm/dd=alignment="2";a.cby:�޸�;a.changed:ʱ��=9=yyyy/mm/dd=alignment="2"headerds=[footer=1]computes=s_count:count( rslt07_1 ):footer:1::a.name:a.name::alignment="2"!',
	'a.sta',
	'a_no1',
	'_com_p_�����һ����;(select a.no,a.sno,a.sta,a.araccnt1,d.haccnt,a.name,c.name,b.name,a.code1,a.code2,a.ref from vipcard a,guest b,guest c,master_des d where a.cno*=b.no and a.hno*=c.no and a.araccnt1*=d.accnt and (1=1));a.no:���;a.sno:����=15=[general]=alignment="2";a.sta:״̬;a.name:����=16;a.araccnt1:AR�˺�=9=[general]=alignment="2";d.haccnt:AR�˻�����=16;c.name:�ͻ�(����)=8;b.name:�ͻ�(��λ)=22;a.code1:������=7;a.code2:POSģʽ=5;a.ref:��ע=30headerds=[header=4 player=3 summary=1] computes=p_yshu:''ҳ��(''+string(page(),''0'')+''/''+string(pagecount(),''0'')+'')'':header:3::a.ref:a.ref::alignment="2" border="0" !computes=heji:count( a.no ):summary:1::a.araccnt1:a.araccnt1::alignment="2" format="0"!texttext=p_title:#hotel#:header:1::a.no:a.ref::border="0" alignment="2" font.height="-14" font.italic="1"!texttext=p_title1:��ǰ�����һ����:header:2::a.no:a.ref::border="0" alignment="2" font.height="-14" font.italic="1"!texttext=p_date:��ӡʱ�� #pdate#:header:3::a.no:a.name::alignment="0" border="0" !texttext=htext:�ϼ�:summary:1::a.no:a.sta::alignment="2" !',
	'F',
	'F');


// worksheet
delete worksheet where window='w_gl_vip_card_list';
INSERT INTO worksheet VALUES ('00','w_gl_vip_card_list',1,'����','All','1=1',10,'','','','','','F');
INSERT INTO worksheet VALUES ('00','w_gl_vip_card_list',2,'���ֿ�','Points Card','a.class=''1''',20,'','','','','','F');
INSERT INTO worksheet VALUES ('00','w_gl_vip_card_list',3,'���˴�ֵ��','Personal AR Card','a.class=''2''',30,'','','','','','F');
INSERT INTO worksheet VALUES ('00','w_gl_vip_card_list',4,'��λ��ֵ��','Company AR Card','a.class=''3''',40,'','','','','','F');
INSERT INTO worksheet VALUES ('00','w_gl_vip_card_list',5,'��������ֵ��','NoName AR Card','a.class=''4''',50,'','','','','','F');
INSERT INTO worksheet VALUES ('00','w_gl_vip_card_list',6,'��δ����','','a.crc=''''',100,'','','','','','F');

// worksta_name
delete worksta_name where window='w_gl_vip_card_list';
INSERT INTO worksta_name VALUES ('w_gl_vip_card_list','','����','All','T',10);
INSERT INTO worksta_name VALUES ('w_gl_vip_card_list','''R''','��ʼ','Init','F',20);
INSERT INTO worksta_name VALUES ('w_gl_vip_card_list','''I''','��Ч','Valid','F',30);
INSERT INTO worksta_name VALUES ('w_gl_vip_card_list','''L''','��ʧ','Suspend','F',40);
INSERT INTO worksta_name VALUES ('w_gl_vip_card_list','''S''','����','Sleep','F',50);
INSERT INTO worksta_name VALUES ('w_gl_vip_card_list','''O''','ͣ��','Stoped','F',60);
INSERT INTO worksta_name VALUES ('w_gl_vip_card_list','''X''','����','Cancellation','F',70);
INSERT INTO worksta_name VALUES ('w_gl_vip_card_list','''D''','ɾ��','Delete','F',80);


// workbutton_name
delete workbutton_name where window='w_gl_vip_card_list';
INSERT INTO workbutton_name VALUES ('w_gl_vip_card_list','ue_new','�½�','Create','T',10);
INSERT INTO workbutton_name VALUES ('w_gl_vip_card_list','ue_open',' ��','Open','T',20);
INSERT INTO workbutton_name VALUES ('w_gl_vip_card_list','ue_sep1','','','T',25);
INSERT INTO workbutton_name VALUES ('w_gl_vip_card_list','ue_no','����','No','T',30);
INSERT INTO workbutton_name VALUES ('w_gl_vip_card_list','ue_sno','ԭ����','Sno','T',40);
INSERT INTO workbutton_name VALUES ('w_gl_vip_card_list','ue_name','����','Name','T',50);
INSERT INTO workbutton_name VALUES ('w_gl_vip_card_list','ue_unit','��λ��','Comp. Name','T',70);
INSERT INTO workbutton_name VALUES ('w_gl_vip_card_list','ue_ar','AR�˻�','AR','T',80);
--INSERT INTO workbutton_name VALUES ('w_gl_vip_card_list','ue_emp1','����','Create','T',100);
--INSERT INTO workbutton_name VALUES ('w_gl_vip_card_list','ue_emp2','�޸�','Modify','T',110);
INSERT INTO workbutton_name VALUES ('w_gl_vip_card_list','ue_sep2','','','T',120);
INSERT INTO workbutton_name VALUES ('w_gl_vip_card_list','ue_hname','�ֿ���','Guest','T',150);
INSERT INTO workbutton_name VALUES ('w_gl_vip_card_list','ue_cname','��λ','Company','T',160);
INSERT INTO workbutton_name VALUES ('w_gl_vip_card_list','ue_ar1','AR��','Account','T',170);
INSERT INTO workbutton_name VALUES ('w_gl_vip_card_list','ue_pool','������','Iss. Pool','T',200);
INSERT INTO workbutton_name VALUES ('w_gl_vip_card_list','ue_issue','����','Issue','T',210);
INSERT INTO workbutton_name VALUES ('w_gl_vip_card_list','ue_post','��������','Point Post','T',250);
