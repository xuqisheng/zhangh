// -----------------------------------------------------------------
//	构建 info 基本的系统与界面元素 
//	 appid, moduno, toolbar ......
// -----------------------------------------------------------------

//
//// appid
//delete appid where code='M';
//insert appid (code,moduno,descript,descript1,ref,exename)
//	VALUES ('M','','经理查询系统','Manager Infomation','','info');
//
//// moduno 
//delete basecode where cat='moduno' and code = '10';
//INSERT INTO basecode (cat,code,descript,descript1,sys,halt,sequence,grp,center)
//VALUES ('moduno','10','经理查询','info','T','F',0,'','F');
//
// toobar_cat
//delete toolbar_cat where appid='M' order by sequence;
//
// --- import the following text
//code	descript	descript1	appid	moduno	pic	show	sequence
//info	经营分析	Analysis	M	10	sale	T	100
//reserve	预订前台	Resrv & Front	M	10	res	T	200
//pos	餐饮娱乐	F&B	M	10	3dishout	T	300
//other	其他	Other	M	10	2inv	T	400
//query	查询	Query	M	10	check	T	500
//exit	退出	Exit	M		exit	T	600
//select * from toolbar_cat where appid='M' order by sequence;


// toolbar
//delete from toolbar where appid='M' order by cat, sequence;
//
// --- import the following text
//appid	cat	code	descript	descript1	wtype	auth	source	parm	multi	sequence
//M	info	jourrep	营业总表	Manager Rep.	sheet		w_info_total_new		F	10
//M	info	info	经营分析	Total Analysis	sheet		w_gl_info_msgraph		F	15
//M	info	Adtrep	稽核报表	Audit Report	sheet		w_gds_audit_report		F	20
//M	info	autorep	报表专家	Report Center	sheet		w_gds_auto_report		F	30
//M	other	cus	消费帐	House Account	sheet		w_gds_master_list_cus		F	10
//M	other	ar	应收帐	AR Account	sheet		w_gds_master_list_ar		F	20
//M	other	age	帐龄分析	Aging Rep.	response		w_gl_audit_arrepo		F	30
//M	other	rmsta	房态管理	Room Status	response		w_gds_house_rmsta_change		F	40
//M	pos	TableMap	餐位图	TableMap	sheet		w_cyj_pos_table_map		F	10
//M	pos	posres	餐饮预定	posres	sheet		w_cyj_pos_inventory		F	20
//M	pos	postag	餐饮消费统计	postag	sheet		w_cq_pos_pccode_tag		F	30
//M	query	profiles	客户档案	Profiles	sheet		w_gds_guest_list		F	10
//M	query	reshis	历史住客	Room History	sheet		w_gds_hmaster_list		F	20
//M	query	housesta	实时房情	housesta	response		w_gds_house_status		F	30
//M	query	vacocc	可用与占用	Avl. & Occ.	response		w_gds_type_detail_avail		F	40
//M	query	plan	趋势预测	Control Plan	response		w_gl_public_control_panel		F	50
//M	query	events	活动事务	Events	response		w_gds_events_list		F	60
//M	query	pubinf	公共信息	Public Informatins	sheet		w_gl_information		F	70
//M	reserve	asklist	销售问询	Sales Inquiry	response		w_gds_turnaway_list		F	10
//M	reserve	guestlist1	预订宾客	Resrvs. List	sheet		w_gds_master_list_res		F	20
//M	reserve	guestlist2	本日将到	Today Arr. List	sheet		w_gds_master_list_arr		F	30
//M	reserve	guestlist3	在住宾客	Guests List	sheet		w_gds_master_list_inhouse		F	40
//M	reserve	hsmap2	实时房态	Rooms Map	sheet		w_gds_house_map_new	10	F	50
//M	reserve	queryaccnt	账务查询	Account Query	sheet		w_gl_accnt_account_query		F	60
//
//select * from toolbar where appid='M' order by cat, sequence;
//