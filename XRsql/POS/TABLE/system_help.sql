if exists(select * from sysobjects where name = "system_help" and type ="U")
	drop table system_help;

create table system_help
(
	cat			char(10)		default '' not null, 	/* ĞòÂë*/
	descript		char(30)		default '' not null,		/* ´úÂë*/
	descript1	char(50)		default '' not null,		/* ÃèÊö*/				
	userhelp		text			default '' not null,		/* ÃèÊö*/
	userhelp1	text			default '' not null,		/* ÃèÊö*/
	help			text			default '' not null,		/* ÃèÊö*/
	help1			text			default '' not null		/* ÃèÊö*/
			
)
;
exec sp_primarykey system_help,cat
create unique index index1 on system_help(cat)
;
