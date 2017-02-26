
//================================================================================
// 	运行外部程序接口
//================================================================================

if exists(select * from sysobjects where name = "extraprg")
	drop table extraprg;
create table extraprg
(
	code				char(30)							not null,
   descript   		varchar(40)    				not null,
   descript1  		varchar(60) default ''   	not null,
   command  		varchar(100) default ''   	not null,
	bmp				varchar(100) default ''   	not null,
	sequence			int			default 0		not null
)
exec sp_primarykey extraprg, code
create unique index index1 on extraprg(code)
;

insert extraprg select 'word', 'Word', 'Word', 'C:\Program Files\Microsoft Office\Office10\winword.exe', 'c:\syhis\bmp\cap1.bmp', 10;
insert extraprg select 'excel', 'Excel', 'Excel', 'C:\Program Files\Microsoft Office\Office10\Excel.exe', 'c:\syhis\bmp\cap1.bmp', 20;
insert extraprg select 'notepad', '便纸薄', 'Notepad', 'Notepad.exe', 'c:\syhis\bmp\cap1.bmp', 30;
insert extraprg select 'mspaint', '画板', 'mspaint', 'mspaint.exe', 'c:\syhis\bmp\cap1.bmp', 40;
insert extraprg select 'calc', '计算器', 'calc', 'calc.exe', 'c:\syhis\bmp\cap1.bmp', 50;