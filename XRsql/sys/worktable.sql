//========================================================================================
// 	ϵͳ������
//
//			��ϵͳû��ģ����룬�����modu_id��Ҫ�ǰ���ϵͳ���㹤�������л��ֵġ�
//
//========================================================================================

//exec sp_rename workselect, a_workselect;
//exec sp_rename worksheet, a_worksheet;
//exec sp_rename workbutton, a_workbutton;
//


//----------------------------------------------------------------------------------------
//	ϵͳ����������Դ���塣select or datawindow
//	  modu_id = 00 ��Ϊϵͳȱʡ��ȡֵ�ط�
//----------------------------------------------------------------------------------------
if object_id('workselect') is not null
	drop table workselect
;
create table workselect (
	modu_id				char(2)						not null,
	window				varchar(30)					not null,	// ��������
	descript				varchar(30)	default ''	not null,
	descript1			varchar(40)	default ''	not null,
	colsele				text							not null,	// SQL��� or datawindow
	coldes				text			default ''	not null,	// ��������
	colsta				varchar(20)	default ''	not null,	// ״̬�����Ӧ���ֶ�
	colkey				varchar(20)	default ''	not null,	// �����ؼ��ֶΣ� sheet ->getitem
	genput				text			default ''	not null,	// ��ӡ
	usedef				char(1) 		default 'T' not null,	// �� dw ����Դʱ���Ƿ�ʹ��his_dyn3 �е�dw
	openflash			char(1) 		default 'T' not null		// ��ʱˢ��
)
exec sp_primarykey workselect, modu_id, window
create unique index index1 on workselect(modu_id, window)
;

//----------------------------------------------------------------------------------------
//	ϵͳ���������ݵ�״̬ѡ�񡣿��Զ�ѡ
//		worksta_name	�����ĳ���ڵ�ͳһ���壬�Լ�ȱʡ��ѡ��״̬
//		worksta			���������ĳһ����ģ���ѡ��״̬
//----------------------------------------------------------------------------------------
if object_id('worksta_name') is not null
	drop table worksta_name
;
create table worksta_name (
	window				varchar(30)					not null,	
	sta					varchar(20)	default ''	not null,	// ״̬�ű�����������ʾȫ����or ('R','I')
	descript				varchar(30)	default ''	not null,
	descript1			varchar(40)	default ''	not null,
	show					char(1)		default 'F'	not null,	// ȱʡѡ��״̬
	sequence				int 			default 0 	not null
)
exec sp_primarykey worksta_name, window, sta
create unique index index1 on worksta_name(window, sta)
;
if object_id('worksta') is not null
	drop table worksta
;
create table worksta (
	window				varchar(30)					not null,	
	modu_id				char(2)						not null,
	sta					varchar(20)	default ''	not null
)
exec sp_primarykey worksta, modu_id, window, sta
create unique index index1 on worksta(modu_id, window, sta)
;

//----------------------------------------------------------------------------------------
//	ϵͳ�������ǩҳ�Ķ��塣���Բ���workselect �����ݣ�Ҳ�������ж��塣
//----------------------------------------------------------------------------------------
if object_id('worksheet') is not null
	drop table worksheet
;
create table worksheet (
	modu_id				char(2)						not null,
	window				varchar(30)					not null,   	// ��������
	tab_no				int			default 0	not null,		// tab ���
	descript				varchar(30)	default ''	not null,		// tab ����
	descript1			varchar(40)	default ''	not null,		// tab ����
	tab_tag				varchar(255)	default ''	not null,	// where
	sequence				int			default 0	not null,		// ����

//	���ÿһ�� tabpage, ���Ա仯��
	colsele				text			default ''	not null,	// SQL��� or datawindow
	coldes				text			default ''	not null,	// ��������
	colsta				varchar(20)	default ''	not null,	// ״̬�����Ӧ���ֶ�
	colkey				varchar(20)	default ''	not null,	// �����ؼ��ֶΣ� sheet ->getitem
	genput				text			default ''	not null,	// ��ӡ
	usedef				char(1) 		default 'T' not null		// �� dw ����Դʱ���Ƿ�ʹ��his_dyn3 �е�dw

)
exec sp_primarykey worksheet, modu_id, window, tab_no
create unique index index1 on worksheet(modu_id, window, tab_no)
;

//----------------------------------------------------------------------------------------
//	ϵͳ������Ĺ��ܰ�ťѡ�񡣶�ѡ
//		workbutton_name	�����ĳ���ڵ�ͳһ���壬�Լ�ȱʡ��ѡ��״̬
//		workbutton			���������ĳһ����ģ���ѡ��״̬
//----------------------------------------------------------------------------------------
// ϵͳ������Ľ��涨�� - buttons
//		���ĳ�����ڣ���ť������һ��ͳһ�ĵط�
if object_id('workbutton_name') is not null
	drop table workbutton_name
;
create table workbutton_name (
	window				varchar(30)						not null,   // ��������
	event					varchar(20)	default '' 		not null,	// �û��Զ����¼����� eg. ue_open
	descript				varchar(20)	default '' 		not null,
	descript1			varchar(20)	default '' 		not null,
	show					char(1)		default 'T'		not null,	// �Ƿ����
	lic					varchar(20)	default '' 		not null,
	sequence				int								not null
)
exec sp_primarykey workbutton_name, window, event
create unique index index1 on workbutton_name(window, event)
create unique index index2 on workbutton_name(window, sequence, event)
;
if object_id('workbutton') is not null
	drop table workbutton
;
create table workbutton (
	window				varchar(30)					not null,   	// ��������
	modu_id				char(2)						not null,
	tab_no				int							not null,		// tab ���
	event					varchar(20)					not null			// �û��Զ����¼�����
)
exec sp_primarykey workbutton, window, modu_id, tab_no, event
create unique index index1 on workbutton(window, modu_id, tab_no, event)
;

//----------------------------------------------------------------------------------------
//	ϵͳ������� ��ϲ�ѯ����
//----------------------------------------------------------------------------------------
if object_id('workcond') is not null
	drop table workcond
;
create table workcond (
	gkey					varchar(50)			not null,	// �ؼ��֣�һ�� = ��������
	tabdes				varchar(50)			null,			// ��ϵ���ı������
	name					varchar(50)			not null,	// ��������
	content				text					not null,	// ��������
)
exec sp_primarykey workcond, gkey, name
create unique index index1 on workcond(gkey, name)
;

insert workcond select 'w_gds_pubmkt_cusdef_list', 'cusdef a, rmratecode b, pos_mode_name c', '������', '1=1';
insert workcond select 'w_gds_pubmkt_cuslist', 'cusinf a,cusdef b,cuscls d', '������', '1=1';
insert workcond select 'w_gds_reserve_arlist', 'armst a', '������', '1=1';
insert workcond select 'w_gds_reserve_blklst', 'blklst a, blkmstclass b, sexcode c', '������', '1=1';
insert workcond select 'w_gds_reserve_grplist', 'grpmst a, jscode b', '������', '1=1';
insert workcond select 'w_gds_reserve_harlist', 'harmst a', '������', '1=1';
insert workcond select 'w_gds_reserve_hgrplist', 'hgrpmst a,hmaster_income b', '������', '1=1';
insert workcond select 'w_gds_reserve_hgstinf_list', 'hgstinf a', '������', '1=1';
insert workcond select 'w_gds_reserve_hgstlist', 'hmaster a,hguest b,hguest_income c', '������', '1=1';
insert workcond select 'w_gds_reserve_mstlist', 'master a, guest b, jscode c', '������', '1=1';
insert workcond select 'w_gds_vip_crdlist', 'crdsta a', '������', '1=1';
//insert workcond select '', '', '������', '1=1';



if exists (select * from sysobjects where name = 't_gds_worksta_name_delete' and type = 'TR')
   drop trigger t_gds_worksta_name_delete;
create trigger t_gds_worksta_name_delete
   on worksta_name
   for delete as
begin
delete worksta from deleted a 
	where worksta.window=a.window and worksta.sta=a.sta
end
;


if exists (select * from sysobjects where name = 't_gds_workbutton_name_delete' and type = 'TR')
   drop trigger t_gds_workbutton_name_delete;
create trigger t_gds_workbutton_name_delete
   on workbutton_name
   for delete as
begin
delete workbutton from deleted a 
	where workbutton.window=a.window and workbutton.event=a.event
end
;


/*
//delete workselect ;
//insert workselect
//  SELECT modu_id,   
//         window,   
//         descript,   
//         rtrim(descript)+'_eng',   
//         colsele,   
//         coldes,   
//         colsta,   
//         colkey,   
//         genput,   
//         usedef,   
//         openflash  
//    FROM a_workselect;
//select * from workselect;
//
//delete worksheet;
//insert worksheet
//  SELECT modu_id,   
//         window,   
//         tab_no,   
//         tab_name,   
//         rtrim(tab_name)+'_eng',   
//         tab_tag,0,
//         '','','','','','T'
//    FROM a_worksheet  ;
//select * from worksheet;


delete  from worksta_name where window='w_gds_reserve_mstlist';
delete  from worksta where window='w_gds_reserve_mstlist';
delete  from workbutton_name where window='w_gds_reserve_mstlist';
delete  from workbutton where window='w_gds_reserve_mstlist';
--- CUSINF
delete  from worksta_name where window='w_gds_pubmkt_cuslist';
delete  from worksta where window='w_gds_pubmkt_cuslist';
delete  from workbutton_name where window='w_gds_pubmkt_cuslist';
delete  from workbutton where window='w_gds_pubmkt_cuslist';

*/



