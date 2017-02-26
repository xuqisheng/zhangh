//exec sp_rename sys_column_show, a_sys_column_show; 

if exists(select 1 from sysobjects where name = "sys_column_show" and type="U")
	drop table sys_column_show;
CREATE TABLE sys_column_show 
(
    window      varchar(50)     default '' not NULL,
    column      varchar(40)     default '' not NULL,
    descript    varchar(50)     default '' not NULL,
    descript1   varchar(50)     default '' not NULL,
    syntax      text         default '' not NULL,
    sequence    int        default 0 not NULL,
    ctype       char(4)      default '' not NULL,
    exp         varchar(100) default '' not NULL,
    defselected char(1)      default 'F' not NULL
)
EXEC sp_primarykey 'sys_column_show', window,column
CREATE UNIQUE NONCLUSTERED INDEX index1
    ON sys_column_show(window ASC,column);

//update a_sys_column_show set descript1='' where descript1 is null; 
//update a_sys_column_show set exp='' where exp is null; 
//
//insert sys_column_show select * from a_sys_column_show; 
//select * from sys_column_show ; 
//

