
INSERT INTO workselect VALUES (
	'00',
	'w_cq_sp_guest_list',
	'客户档案',
	'客户（宾客）档案_eng',
	'select a.no,a.sno,a.sta,a.name,a.name2,a.unit,a.code1,a.code2,a.araccnt1,a.nation,a.phone,a.fax,a.liason,b.descript,a.i_times,a.i_days,a.tl,a.rm,a.fb,a.en,a.ot,a.birth,char21  =  a.ident from guest a, saleid b where a.class not in (''R'',  ''H'') and a.saleid*=b.code and (1=1)',
	'a.no:档案号;a.sno:编号=6;a.sta:状态;a.name:姓名=20;a.name2:姓名2=12;a.unit:单位=16;a.code1:房价码=10=[general]=alignment=''2'';a.code2:POS模式=5=[general]=alignment=''2'';a.araccnt1:AR=7;a.nation:国籍;a.phone:电话=10;a.fax:传真=10;a.liason:联系人=12;b.descript:销售员=12;a.tl:总收入=10=0.00;a.i_times:人次=4=0=alignment="2";a.i_days:人天=4=0=alignment="2";a.rm:客房=10=0.00;a.fb:餐饮=10=0.00;a.en:娱乐=10=0.00;a.ot:其它=10=0.00;a.birth:生日=9=yyyy/mm/dd;char21:证件=16headerds=[footer=1 autoappe=0]computes=c_num:count( a.no ):footer:1::a.name:a.name::alignment="2"!texttext=t_rec:记录数:footer:1::a.no:a.no::alignment="2"!',
	'a.sta',
	'a_no1',
	'_com_p_客户档案列表;(select a.no,a.sno,a.sta,a.name,a.code1,a.code2,a.araccnt1,a.nation,a.phone,a.fax,a.liason,b.descript,a.i_times,a.i_days,a.tl,a.street from guest a, saleid b where a.class not in (''R'',  ''H'') and a.saleid*=b.code and (1=1)  order by a.name);a.no:档案号;a.sno:编号=6;a.sta:状态;a.name:姓名=26;a.code1:房价码=10=[general]=alignment=''2'';a.code2:POS模式=5=[general]=alignment=''2'';a.araccnt1:AR=7;a.nation:国籍;a.phone:电话=10;a.fax:传真=10;a.liason:联系人=12;b.descript:销售员=12;a.tl:总收入=10=0.00;a.i_times:人次=4=0=alignment="2";a.i_days:人天=4=0=alignment="2";a.street:地址=20headerds=[header=4 summary=1 autoappe=0] computes=c_yshu:''页次(''+string(page(),''0'')+''/''+string(pagecount(),''0'')+'')'':header:3::a.street:a.street::border="0" alignment="2"!computes=c_count:''总  ''+string(count( a.no ))+''  行'':summary:1::a.no:b.descript::alignment="2" font.italic="0"!computes=c_i:sum( a.i_times ):summary:1::a.i_times:a.i_times::alignment="2" format="0" !computes=c_d:sum( a.i_days ):summary:1::a.i_days:a.i_days::alignment="2" format="0" !computes=c_tl:sum( a.tl ):summary:1::a.tl:a.tl::alignment="2" format="0.00" !texttext=c_title:客户档案列表:header:2::a.no:a.street::border="0" alignment="2" font.height="-12" font.italic="0"!texttext=t_hotel:#hotel#:header:1::a.no:a.street::border="0" alignment="2" font.height="-12" font.italic="0"!texttext=t_date:打印时间#pdate#:header:3::a.no:a.tl::border="0" alignment="0"!',
	'F',
	'F');


INSERT INTO workbutton_name VALUES (
	'w_cq_sp_guest_list',
	'ue_new',
	'新建',
	'New',
	'T',
	'',
	100);
INSERT INTO workbutton_name VALUES (
	'w_cq_sp_guest_list',
	'ue_open',
	'打开',
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
	'更换销售员',
	'Chg. SaleID',
	'T',
	'',
	200);
INSERT INTO workbutton_name VALUES (
	'w_cq_sp_guest_list',
	'ue_chgdep',
	'更换终止日期',
	'Chg. Dep.',
	'T',
	'',
	210);
INSERT INTO workbutton_name VALUES (
	'w_cq_sp_guest_list',
	'ue_chgarr',
	'更换起始日期',
	'Chg. Arr.',
	'T',
	'',
	209);


INSERT INTO worksta_name VALUES (
	'w_cq_sp_guest_list',
	'''I''',
	'有效',
	'Valid',
	'T',
	10);
INSERT INTO worksta_name VALUES (
	'w_cq_sp_guest_list',
	'''O''',
	'停用',
	'Stoped',
	'F',
	20);
INSERT INTO worksta_name VALUES (
	'w_cq_sp_guest_list',
	'',
	'所有',
	'All',
	'F',
	100);


INSERT INTO worksheet VALUES (
	'00',
	'w_cq_sp_guest_list',
	2,
	'所有',
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
	'旅行社',
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
	'客人档案',
	'Guests',
	'a.class=''F''',
	50,
	'',
	'',
	'',
	'',
	'_com_p_客户档案列表;(select a.no,a.sno,a.sta,a.name,a.code1,a.code2,a.araccnt1,a.nation,a.phone,a.fax,a.liason,b.descript,a.i_times,a.i_days,a.tl,a.birth,char21  =  a.ident,a.address from guest a, saleid b where a.class not in (''R'',  ''H'') and a.saleid*=b.code and (1=1)  order by a.name);a.no:档案号;a.sno:编号=6;a.sta:状态;a.name:姓名=26;a.code1:房价码=10=[general]=alignment=''2'';a.code2:POS模式=5=[general]=alignment=''2'';a.araccnt1:AR=7;a.nation:国籍;a.phone:电话=10;a.fax:传真=10;a.liason:联系人=12;b.descript:销售员=12;a.tl:总收入=10=0.00;a.i_times:人次=4=0=alignment="2";a.i_days:人天=4=0=alignment="2";a.birth:生日=9=yyyy/mm/dd;char21:证件=16;a.address:地址=20headerds=[header=4 summary=1 autoappe=0] computes=c_yshu:''页次(''+string(page(),''0'')+''/''+string(pagecount(),''0'')+'')'':header:3::a.address:a.address::border="0" alignment="2"!computes=c_count:''总  ''+string(count( a.no ))+''  行'':summary:1::a.no:b.descript::alignment="2" font.italic="0"!computes=c_i:sum( a.i_times ):summary:1::a.i_times:a.i_times::alignment="2" format="0" !computes=c_d:sum( a.i_days ):summary:1::a.i_days:a.i_days::alignment="2" format="0" !computes=c_tl:sum( a.tl ):summary:1::a.tl:a.tl::alignment="2" format="0.00" !texttext=c_title:客户档案列表:header:2::a.no:a.address::border="0" alignment="2" font.height="-12" font.italic="0"!texttext=t_hotel:#hotel#:header:1::a.no:a.address::border="0" alignment="2" font.height="-12" font.italic="0"!texttext=t_date:打印时间#pdate#:header:3::a.no:a.tl::border="0" alignment="0"!',
	'F');
INSERT INTO worksheet VALUES (
	'00',
	'w_cq_sp_guest_list',
	5,
	'订房中心',
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
	'团体会议',
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
	'黑名单',
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
	'联系人',
	'Contact',
	'exists(Select 1 From argst b where a.no=b.no)',
	48,
	'',
	'',
	'',
	'',
	'_com_p_客户档案列表;(select a.no,a.sno,a.sta,a.name,a.code1,a.code2,a.araccnt1,a.nation,a.phone,a.fax,a.liason,b.descript,a.i_times,a.i_days,a.tl,a.birth,char21  =  a.ident,a.address from guest a, saleid b where a.class not in (''R'',  ''H'') and a.saleid*=b.code and (1=1) order by a.name);a.no:档案号;a.sno:编号=6;a.sta:状态;a.name:姓名=26;a.code1:房价码=10=[general]=alignment=''2'';a.code2:POS模式=5=[general]=alignment=''2'';a.araccnt1:AR=7;a.nation:国籍;a.phone:电话=10;a.fax:传真=10;a.liason:联系人=12;b.descript:销售员=12;a.tl:总收入=10=0.00;a.i_times:人次=4=0=alignment="2";a.i_days:人天=4=0=alignment="2";a.birth:生日=9=yyyy/mm/dd;char21:证件=16;a.address:地址=20headerds=[header=4 summary=1 autoappe=0] computes=c_yshu:''页次(''+string(page(),''0'')+''/''+string(pagecount(),''0'')+'')'':header:3::a.address:a.address::border="0" alignment="2"!computes=c_count:''总  ''+string(count( a.no ))+''  行'':summary:1::a.no:b.descript::alignment="2" font.italic="0"!computes=c_i:sum( a.i_times ):summary:1::a.i_times:a.i_times::alignment="2" format="0" !computes=c_d:sum( a.i_days ):summary:1::a.i_days:a.i_days::alignment="2" format="0" !computes=c_tl:sum( a.tl ):summary:1::a.tl:a.tl::alignment="2" format="0.00" !texttext=c_title:客户档案列表:header:2::a.no:a.address::border="0" alignment="2" font.height="-12" font.italic="0"!texttext=t_hotel:#hotel#:header:1::a.no:a.address::border="0" alignment="2" font.height="-12" font.italic="0"!texttext=t_date:打印时间#pdate#:header:3::a.no:a.tl::border="0" alignment="0"!',
	'F');
INSERT INTO worksheet VALUES (
	'00',
	'w_cq_sp_guest_list',
	9,
	'公司',
	'Company',
	'a.class=''C''',
	11,
	'',
	'',
	'',
	'',
	'',
	'F');



