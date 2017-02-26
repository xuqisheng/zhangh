--档案合并界面窗口
drop table cmb_alter;
IF OBJECT_ID('dbo.cmb_alter') IS  NULL
  begin
	create table cmb_alter
	(
	pc_id char(4) not null,
	item varchar(60) not null,
	descript varchar(60) null,
	descript1 varchar(60) null,
	value_a varchar(255) null,
	value_b varchar(255) null,
	alternative char(2) null,
	value_f	varchar(255) null,
	sequence	int null,
 	value_data_a varchar(60) null,
	value_data_b varchar(60) null,
	value_data_f varchar(60) null,
	helpable char(1) default 'F' null,
	help varchar(255) null,
	descript_sql varchar(255) null,
	sm char(1) default '' null,
	constraint pk_cmb_alter primary key (pc_id,item)
	)
  end;
;


