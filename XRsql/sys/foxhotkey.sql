-------------------------------------------------------------------------------------------
-- foxhotkey
-------------------------------------------------------------------------------------------
if exists(select * from sysobjects where name = 'foxhotkey' and type ='U')
	drop table foxhotkey
;
create table foxhotkey (
	appid				char(1)							not null, -- 0 -- FOXHIS or refer to TABLE:appid 
	hotkey			char(3)							not null, -- [A-Z]|[0-9]|[F1-F12]
	hotkeyflags		char(1)			default '0'	not null, -- 0-NONE 1-SHIFT  2-CTRL 3-SHIFT+CTRL
	hotobj			varchar(64)		default ''	not null, -- '' or user define name int object tag
                                                       -- format: hotkey=<your define name>;
	descript    	varchar(30)		default ''	not null,
	descript1   	varchar(30)		default ''	not null,
  	popup				varchar(64)		default ''	not null,-- popup window classnane
	response			varchar(64)		default ''	not null -- response window classname
)
;
exec sp_primarykey foxhotkey,appid,hotkey,hotkeyflags
create unique index index1 on foxhotkey(appid,hotkey,hotkeyflags)
;

-------------------------------------------------------------------------------------------
-- data
-------------------------------------------------------------------------------------------
-- foxhis system
insert into foxhotkey(appid,hotkey,hotkeyflags,hotobj,descript,descript1,popup,response) 
	select '0','Z','2','','计算器','Calculator',
	'','w_gds_calculator' 

insert into foxhotkey(appid,hotkey,hotkeyflags,hotobj,descript,descript1,popup,response) 
	select '0','P','3','','酒店地图','Hotel Map',
	'','w_clg_information_hotel_map' 
;

-- foxhis front application 
insert into foxhotkey(appid,hotkey,hotkeyflags,hotobj,descript,descript1,popup,response) 
	select '1','D','2','','客房可用与占用','Rooms Available and Occupation',
	'w_gds_type_detail_avail','w_gds_type_detail_avail_response'  
	
insert into foxhotkey(appid,hotkey,hotkeyflags,hotobj,descript,descript1,popup,response) 
	select '1','H','2','','实时房情','House Status',
	'w_gds_house_status','w_gds_house_status_response' 
	
insert into foxhotkey(appid,hotkey,hotkeyflags,hotobj,descript,descript1,popup,response) 
	select '1','P','2','','Control Pannel','Control Pannel',
	'w_gl_public_control_panel','w_gl_public_control_panel_response'  
	
insert into foxhotkey(appid,hotkey,hotkeyflags,hotobj,descript,descript1,popup,response) 
	select '1','R','2','','房价查询','Rate Query',
	'w_gds_rate_query_cond','w_gds_rate_query_cond_response' 
	
insert into foxhotkey(appid,hotkey,hotkeyflags,hotobj,descript,descript1,popup,response) 
	select '1','F8','0','','币种计算器','Currency Calculator',
	'w_gl_currency_calculator','w_gl_currency_calculator_response' 
;

//insert into foxhotkey(appid,hotkey,hotkeyflags,hotobj,descript,descript1,popup,response) 
//	select '1','F3','2','m_ratequery','房价查询','Rate Query',
//	'w_gds_rate_query_cond','w_gds_rate_query_cond_response' 
//;
//	
-------------------------------------------------------------------------------------------
-- maint
-------------------------------------------------------------------------------------------
INSERT INTO syscode_maint ( code,descript,descript1,wtype,auth,show,source,parm ) 
VALUES ( 'SX','Foxhis快捷键设置','Foxhis Hotkey Set','response','','d_fox_hotkey','w_fox_hotkey_maint','' ) 
;

	
	