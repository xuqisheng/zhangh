// -----------------------------------------------------------------
//	���� info ������ϵͳ�����Ԫ�� 
//	 appid, moduno, toolbar ......
// -----------------------------------------------------------------

//
//// appid
//delete appid where code='M';
//insert appid (code,moduno,descript,descript1,ref,exename)
//	VALUES ('M','','�����ѯϵͳ','Manager Infomation','','info');
//
//// moduno 
//delete basecode where cat='moduno' and code = '10';
//INSERT INTO basecode (cat,code,descript,descript1,sys,halt,sequence,grp,center)
//VALUES ('moduno','10','�����ѯ','info','T','F',0,'','F');
//
// toobar_cat
//delete toolbar_cat where appid='M' order by sequence;
//
// --- import the following text
//code	descript	descript1	appid	moduno	pic	show	sequence
//info	��Ӫ����	Analysis	M	10	sale	T	100
//reserve	Ԥ��ǰ̨	Resrv & Front	M	10	res	T	200
//pos	��������	F&B	M	10	3dishout	T	300
//other	����	Other	M	10	2inv	T	400
//query	��ѯ	Query	M	10	check	T	500
//exit	�˳�	Exit	M		exit	T	600
//select * from toolbar_cat where appid='M' order by sequence;


// toolbar
//delete from toolbar where appid='M' order by cat, sequence;
//
// --- import the following text
//appid	cat	code	descript	descript1	wtype	auth	source	parm	multi	sequence
//M	info	jourrep	Ӫҵ�ܱ�	Manager Rep.	sheet		w_info_total_new		F	10
//M	info	info	��Ӫ����	Total Analysis	sheet		w_gl_info_msgraph		F	15
//M	info	Adtrep	���˱���	Audit Report	sheet		w_gds_audit_report		F	20
//M	info	autorep	����ר��	Report Center	sheet		w_gds_auto_report		F	30
//M	other	cus	������	House Account	sheet		w_gds_master_list_cus		F	10
//M	other	ar	Ӧ����	AR Account	sheet		w_gds_master_list_ar		F	20
//M	other	age	�������	Aging Rep.	response		w_gl_audit_arrepo		F	30
//M	other	rmsta	��̬����	Room Status	response		w_gds_house_rmsta_change		F	40
//M	pos	TableMap	��λͼ	TableMap	sheet		w_cyj_pos_table_map		F	10
//M	pos	posres	����Ԥ��	posres	sheet		w_cyj_pos_inventory		F	20
//M	pos	postag	��������ͳ��	postag	sheet		w_cq_pos_pccode_tag		F	30
//M	query	profiles	�ͻ�����	Profiles	sheet		w_gds_guest_list		F	10
//M	query	reshis	��ʷס��	Room History	sheet		w_gds_hmaster_list		F	20
//M	query	housesta	ʵʱ����	housesta	response		w_gds_house_status		F	30
//M	query	vacocc	������ռ��	Avl. & Occ.	response		w_gds_type_detail_avail		F	40
//M	query	plan	����Ԥ��	Control Plan	response		w_gl_public_control_panel		F	50
//M	query	events	�����	Events	response		w_gds_events_list		F	60
//M	query	pubinf	������Ϣ	Public Informatins	sheet		w_gl_information		F	70
//M	reserve	asklist	������ѯ	Sales Inquiry	response		w_gds_turnaway_list		F	10
//M	reserve	guestlist1	Ԥ������	Resrvs. List	sheet		w_gds_master_list_res		F	20
//M	reserve	guestlist2	���ս���	Today Arr. List	sheet		w_gds_master_list_arr		F	30
//M	reserve	guestlist3	��ס����	Guests List	sheet		w_gds_master_list_inhouse		F	40
//M	reserve	hsmap2	ʵʱ��̬	Rooms Map	sheet		w_gds_house_map_new	10	F	50
//M	reserve	queryaccnt	�����ѯ	Account Query	sheet		w_gl_accnt_account_query		F	60
//
//select * from toolbar where appid='M' order by cat, sequence;
//