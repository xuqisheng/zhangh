//========================================================================================
// 	系统工作表
//
//			新系统没有模块号码，这里的modu_id主要是按照系统顶层工具条进行划分的。
//
//========================================================================================

//exec sp_rename workselect, a_workselect;
//exec sp_rename worksheet, a_worksheet;
//exec sp_rename workbutton, a_workbutton;
//


//----------------------------------------------------------------------------------------
//	系统工作表数据源定义。select or datawindow
//	  modu_id = 00 作为系统缺省的取值地方
//----------------------------------------------------------------------------------------
if object_id('workselect') is not null
	drop table workselect
;
create table workselect (
	modu_id				char(2)						not null,
	window				varchar(30)					not null,	// 窗口名称
	descript				varchar(30)	default ''	not null,
	descript1			varchar(40)	default ''	not null,
	colsele				text							not null,	// SQL语句 or datawindow
	coldes				text			default ''	not null,	// 列名描述
	colsta				varchar(20)	default ''	not null,	// 状态变更对应的字段
	colkey				varchar(20)	default ''	not null,	// 检索关键字段， sheet ->getitem
	genput				text			default ''	not null,	// 打印
	usedef				char(1) 		default 'T' not null,	// 非 dw 数据源时，是否使用his_dyn3 中的dw
	openflash			char(1) 		default 'T' not null		// 及时刷新
)
exec sp_primarykey workselect, modu_id, window
create unique index index1 on workselect(modu_id, window)
;

//----------------------------------------------------------------------------------------
//	系统工作表数据的状态选择。可以多选
//		worksta_name	：针对某窗口的统一定义，以及缺省的选中状态
//		worksta			：定义针对某一个子模块的选中状态
//----------------------------------------------------------------------------------------
if object_id('worksta_name') is not null
	drop table worksta_name
;
create table worksta_name (
	window				varchar(30)					not null,	
	sta					varchar(20)	default ''	not null,	// 状态脚本。‘’－表示全部；or ('R','I')
	descript				varchar(30)	default ''	not null,
	descript1			varchar(40)	default ''	not null,
	show					char(1)		default 'F'	not null,	// 缺省选中状态
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
//	系统工作表标签页的定义。可以采用workselect 的数据，也可以自行定义。
//----------------------------------------------------------------------------------------
if object_id('worksheet') is not null
	drop table worksheet
;
create table worksheet (
	modu_id				char(2)						not null,
	window				varchar(30)					not null,   	// 窗口名称
	tab_no				int			default 0	not null,		// tab 序号
	descript				varchar(30)	default ''	not null,		// tab 名称
	descript1			varchar(40)	default ''	not null,		// tab 名称
	tab_tag				varchar(255)	default ''	not null,	// where
	sequence				int			default 0	not null,		// 排序

//	针对每一个 tabpage, 可以变化；
	colsele				text			default ''	not null,	// SQL语句 or datawindow
	coldes				text			default ''	not null,	// 列名描述
	colsta				varchar(20)	default ''	not null,	// 状态变更对应的字段
	colkey				varchar(20)	default ''	not null,	// 检索关键字段， sheet ->getitem
	genput				text			default ''	not null,	// 打印
	usedef				char(1) 		default 'T' not null		// 非 dw 数据源时，是否使用his_dyn3 中的dw

)
exec sp_primarykey worksheet, modu_id, window, tab_no
create unique index index1 on worksheet(modu_id, window, tab_no)
;

//----------------------------------------------------------------------------------------
//	系统工作表的功能按钮选择。多选
//		workbutton_name	：针对某窗口的统一定义，以及缺省的选中状态
//		workbutton			：定义针对某一个子模块的选中状态
//----------------------------------------------------------------------------------------
// 系统工作表的界面定义 - buttons
//		针对某个窗口，按钮定义有一个统一的地方
if object_id('workbutton_name') is not null
	drop table workbutton_name
;
create table workbutton_name (
	window				varchar(30)						not null,   // 窗口名称
	event					varchar(20)	default '' 		not null,	// 用户自定义事件名称 eg. ue_open
	descript				varchar(20)	default '' 		not null,
	descript1			varchar(20)	default '' 		not null,
	show					char(1)		default 'T'		not null,	// 是否采用
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
	window				varchar(30)					not null,   	// 窗口名称
	modu_id				char(2)						not null,
	tab_no				int							not null,		// tab 序号
	event					varchar(20)					not null			// 用户自定义事件名称
)
exec sp_primarykey workbutton, window, modu_id, tab_no, event
create unique index index1 on workbutton(window, modu_id, tab_no, event)
;

//----------------------------------------------------------------------------------------
//	系统工作表的 组合查询条件
//----------------------------------------------------------------------------------------
if object_id('workcond') is not null
	drop table workcond
;
create table workcond (
	gkey					varchar(50)			not null,	// 关键字，一般 = 窗口名称
	tabdes				varchar(50)			null,			// 关系到的表及其别名
	name					varchar(50)			not null,	// 条件描述
	content				text					not null,	// 条件内容
)
exec sp_primarykey workcond, gkey, name
create unique index index1 on workcond(gkey, name)
;

insert workcond select 'w_gds_pubmkt_cusdef_list', 'cusdef a, rmratecode b, pos_mode_name c', '无条件', '1=1';
insert workcond select 'w_gds_pubmkt_cuslist', 'cusinf a,cusdef b,cuscls d', '无条件', '1=1';
insert workcond select 'w_gds_reserve_arlist', 'armst a', '无条件', '1=1';
insert workcond select 'w_gds_reserve_blklst', 'blklst a, blkmstclass b, sexcode c', '无条件', '1=1';
insert workcond select 'w_gds_reserve_grplist', 'grpmst a, jscode b', '无条件', '1=1';
insert workcond select 'w_gds_reserve_harlist', 'harmst a', '无条件', '1=1';
insert workcond select 'w_gds_reserve_hgrplist', 'hgrpmst a,hmaster_income b', '无条件', '1=1';
insert workcond select 'w_gds_reserve_hgstinf_list', 'hgstinf a', '无条件', '1=1';
insert workcond select 'w_gds_reserve_hgstlist', 'hmaster a,hguest b,hguest_income c', '无条件', '1=1';
insert workcond select 'w_gds_reserve_mstlist', 'master a, guest b, jscode c', '无条件', '1=1';
insert workcond select 'w_gds_vip_crdlist', 'crdsta a', '无条件', '1=1';
//insert workcond select '', '', '无条件', '1=1';



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



