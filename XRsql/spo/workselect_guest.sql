
INSERT INTO workselect VALUES (
	'00',
	'w_cq_sp_guest_list',
	'�ͻ�����',
	'�ͻ������ͣ�����_eng',
	'select a.no,a.sno,a.sta,a.name,a.name2,a.unit,a.code1,a.code2,a.araccnt1,a.nation,a.phone,a.fax,a.liason,b.descript,a.i_times,a.i_days,a.tl,a.rm,a.fb,a.en,a.ot,a.birth,char21  =  a.ident from guest a, saleid b where a.class not in (''R'',  ''H'') and a.saleid*=b.code and (1=1)',
	'a.no:������;a.sno:���=6;a.sta:״̬;a.name:����=20;a.name2:����2=12;a.unit:��λ=16;a.code1:������=10=[general]=alignment=''2'';a.code2:POSģʽ=5=[general]=alignment=''2'';a.araccnt1:AR=7;a.nation:����;a.phone:�绰=10;a.fax:����=10;a.liason:��ϵ��=12;b.descript:����Ա=12;a.tl:������=10=0.00;a.i_times:�˴�=4=0=alignment="2";a.i_days:����=4=0=alignment="2";a.rm:�ͷ�=10=0.00;a.fb:����=10=0.00;a.en:����=10=0.00;a.ot:����=10=0.00;a.birth:����=9=yyyy/mm/dd;char21:֤��=16headerds=[footer=1 autoappe=0]computes=c_num:count( a.no ):footer:1::a.name:a.name::alignment="2"!texttext=t_rec:��¼��:footer:1::a.no:a.no::alignment="2"!',
	'a.sta',
	'a_no1',
	'_com_p_�ͻ������б�;(select a.no,a.sno,a.sta,a.name,a.code1,a.code2,a.araccnt1,a.nation,a.phone,a.fax,a.liason,b.descript,a.i_times,a.i_days,a.tl,a.street from guest a, saleid b where a.class not in (''R'',  ''H'') and a.saleid*=b.code and (1=1)  order by a.name);a.no:������;a.sno:���=6;a.sta:״̬;a.name:����=26;a.code1:������=10=[general]=alignment=''2'';a.code2:POSģʽ=5=[general]=alignment=''2'';a.araccnt1:AR=7;a.nation:����;a.phone:�绰=10;a.fax:����=10;a.liason:��ϵ��=12;b.descript:����Ա=12;a.tl:������=10=0.00;a.i_times:�˴�=4=0=alignment="2";a.i_days:����=4=0=alignment="2";a.street:��ַ=20headerds=[header=4 summary=1 autoappe=0] computes=c_yshu:''ҳ��(''+string(page(),''0'')+''/''+string(pagecount(),''0'')+'')'':header:3::a.street:a.street::border="0" alignment="2"!computes=c_count:''��  ''+string(count( a.no ))+''  ��'':summary:1::a.no:b.descript::alignment="2" font.italic="0"!computes=c_i:sum( a.i_times ):summary:1::a.i_times:a.i_times::alignment="2" format="0" !computes=c_d:sum( a.i_days ):summary:1::a.i_days:a.i_days::alignment="2" format="0" !computes=c_tl:sum( a.tl ):summary:1::a.tl:a.tl::alignment="2" format="0.00" !texttext=c_title:�ͻ������б�:header:2::a.no:a.street::border="0" alignment="2" font.height="-12" font.italic="0"!texttext=t_hotel:#hotel#:header:1::a.no:a.street::border="0" alignment="2" font.height="-12" font.italic="0"!texttext=t_date:��ӡʱ��#pdate#:header:3::a.no:a.tl::border="0" alignment="0"!',
	'F',
	'F');


INSERT INTO workbutton_name VALUES (
	'w_cq_sp_guest_list',
	'ue_new',
	'�½�',
	'New',
	'T',
	'',
	100);
INSERT INTO workbutton_name VALUES (
	'w_cq_sp_guest_list',
	'ue_open',
	'��',
	'Open',
	'T',
	'',
	110);
INSERT INTO workbutton_name VALUES (
	'w_cq_sp_guest_list',
	'ue_sep1',
	'-',
	'-',
	'T',
	'',
	199);
INSERT INTO workbutton_name VALUES (
	'w_cq_sp_guest_list',
	'ue_chgsaleid',
	'��������Ա',
	'Chg. SaleID',
	'T',
	'',
	200);
INSERT INTO workbutton_name VALUES (
	'w_cq_sp_guest_list',
	'ue_chgdep',
	'������ֹ����',
	'Chg. Dep.',
	'T',
	'',
	210);
INSERT INTO workbutton_name VALUES (
	'w_cq_sp_guest_list',
	'ue_chgarr',
	'������ʼ����',
	'Chg. Arr.',
	'T',
	'',
	209);


INSERT INTO worksta_name VALUES (
	'w_cq_sp_guest_list',
	'''I''',
	'��Ч',
	'Valid',
	'T',
	10);
INSERT INTO worksta_name VALUES (
	'w_cq_sp_guest_list',
	'''O''',
	'ͣ��',
	'Stoped',
	'F',
	20);
INSERT INTO worksta_name VALUES (
	'w_cq_sp_guest_list',
	'',
	'����',
	'All',
	'F',
	100);


INSERT INTO worksheet VALUES (
	'00',
	'w_cq_sp_guest_list',
	2,
	'����',
	'All',
	'1=1',
	10,
	'',
	'',
	'',
	'',
	'',
	'F');
INSERT INTO worksheet VALUES (
	'00',
	'w_cq_sp_guest_list',
	3,
	'������',
	'Agent',
	'a.class=''A''',
	20,
	'',
	'',
	'',
	'',
	'',
	'F');
INSERT INTO worksheet VALUES (
	'00',
	'w_cq_sp_guest_list',
	1,
	'���˵���',
	'Guests',
	'a.class=''F''',
	50,
	'',
	'',
	'',
	'',
	'_com_p_�ͻ������б�;(select a.no,a.sno,a.sta,a.name,a.code1,a.code2,a.araccnt1,a.nation,a.phone,a.fax,a.liason,b.descript,a.i_times,a.i_days,a.tl,a.birth,char21  =  a.ident,a.address from guest a, saleid b where a.class not in (''R'',  ''H'') and a.saleid*=b.code and (1=1)  order by a.name);a.no:������;a.sno:���=6;a.sta:״̬;a.name:����=26;a.code1:������=10=[general]=alignment=''2'';a.code2:POSģʽ=5=[general]=alignment=''2'';a.araccnt1:AR=7;a.nation:����;a.phone:�绰=10;a.fax:����=10;a.liason:��ϵ��=12;b.descript:����Ա=12;a.tl:������=10=0.00;a.i_times:�˴�=4=0=alignment="2";a.i_days:����=4=0=alignment="2";a.birth:����=9=yyyy/mm/dd;char21:֤��=16;a.address:��ַ=20headerds=[header=4 summary=1 autoappe=0] computes=c_yshu:''ҳ��(''+string(page(),''0'')+''/''+string(pagecount(),''0'')+'')'':header:3::a.address:a.address::border="0" alignment="2"!computes=c_count:''��  ''+string(count( a.no ))+''  ��'':summary:1::a.no:b.descript::alignment="2" font.italic="0"!computes=c_i:sum( a.i_times ):summary:1::a.i_times:a.i_times::alignment="2" format="0" !computes=c_d:sum( a.i_days ):summary:1::a.i_days:a.i_days::alignment="2" format="0" !computes=c_tl:sum( a.tl ):summary:1::a.tl:a.tl::alignment="2" format="0.00" !texttext=c_title:�ͻ������б�:header:2::a.no:a.address::border="0" alignment="2" font.height="-12" font.italic="0"!texttext=t_hotel:#hotel#:header:1::a.no:a.address::border="0" alignment="2" font.height="-12" font.italic="0"!texttext=t_date:��ӡʱ��#pdate#:header:3::a.no:a.tl::border="0" alignment="0"!',
	'F');
INSERT INTO worksheet VALUES (
	'00',
	'w_cq_sp_guest_list',
	5,
	'��������',
	'Booking Center',
	'a.class=''S''',
	30,
	'',
	'',
	'',
	'',
	'',
	'F');
INSERT INTO worksheet VALUES (
	'00',
	'w_cq_sp_guest_list',
	6,
	'�������',
	'Group Master',
	'a.class=''G''',
	40,
	'',
	'',
	'',
	'',
	'',
	'F');
INSERT INTO worksheet VALUES (
	'00',
	'w_cq_sp_guest_list',
	7,
	'������',
	'Blacklist',
	'a.class=''T'' and a.type=''B''',
	60,
	'',
	'',
	'',
	'',
	'',
	'F');
INSERT INTO worksheet VALUES (
	'00',
	'w_cq_sp_guest_list',
	8,
	'��ϵ��',
	'Contact',
	'exists(Select 1 From argst b where a.no=b.no)',
	48,
	'',
	'',
	'',
	'',
	'_com_p_�ͻ������б�;(select a.no,a.sno,a.sta,a.name,a.code1,a.code2,a.araccnt1,a.nation,a.phone,a.fax,a.liason,b.descript,a.i_times,a.i_days,a.tl,a.birth,char21  =  a.ident,a.address from guest a, saleid b where a.class not in (''R'',  ''H'') and a.saleid*=b.code and (1=1) order by a.name);a.no:������;a.sno:���=6;a.sta:״̬;a.name:����=26;a.code1:������=10=[general]=alignment=''2'';a.code2:POSģʽ=5=[general]=alignment=''2'';a.araccnt1:AR=7;a.nation:����;a.phone:�绰=10;a.fax:����=10;a.liason:��ϵ��=12;b.descript:����Ա=12;a.tl:������=10=0.00;a.i_times:�˴�=4=0=alignment="2";a.i_days:����=4=0=alignment="2";a.birth:����=9=yyyy/mm/dd;char21:֤��=16;a.address:��ַ=20headerds=[header=4 summary=1 autoappe=0] computes=c_yshu:''ҳ��(''+string(page(),''0'')+''/''+string(pagecount(),''0'')+'')'':header:3::a.address:a.address::border="0" alignment="2"!computes=c_count:''��  ''+string(count( a.no ))+''  ��'':summary:1::a.no:b.descript::alignment="2" font.italic="0"!computes=c_i:sum( a.i_times ):summary:1::a.i_times:a.i_times::alignment="2" format="0" !computes=c_d:sum( a.i_days ):summary:1::a.i_days:a.i_days::alignment="2" format="0" !computes=c_tl:sum( a.tl ):summary:1::a.tl:a.tl::alignment="2" format="0.00" !texttext=c_title:�ͻ������б�:header:2::a.no:a.address::border="0" alignment="2" font.height="-12" font.italic="0"!texttext=t_hotel:#hotel#:header:1::a.no:a.address::border="0" alignment="2" font.height="-12" font.italic="0"!texttext=t_date:��ӡʱ��#pdate#:header:3::a.no:a.tl::border="0" alignment="0"!',
	'F');
INSERT INTO worksheet VALUES (
	'00',
	'w_cq_sp_guest_list',
	9,
	'��˾',
	'Company',
	'a.class=''C''',
	11,
	'',
	'',
	'',
	'',
	'',
	'F');



