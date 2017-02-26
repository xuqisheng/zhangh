if exists(select 1 from sysobjects where name='sys_guest_auth' and type='U')
drop table sys_guest_auth
;
create table sys_guest_auth
(
  name varchar(30) not null,     -----guest对象的名称 列名或tabpage的名称
  descript varchar(20) null,
  descript1 varchar(20) null,
  type     varchar(3) not null,  -----列'col'或分类'tab'
  fvisible  char(1) default 'T'  not null,---客人列的可见性
  fedit     char(1) default 'T'  not null,---客人列的编辑性
  gvisible  char(1) default 'T'  not null,---团队列的可见性
  gedit     char(1) default 'T'  not null,---团队列的编辑性
  cvisible  char(1) default 'T'  not null,---协议单位列的可见性
  cedit     char(1) default 'T'  not null,---协议单位客人列的编辑性
  rvisible  char(1) default 'T'  not null,---AR列的可见性
  redit     char(1) default 'T'  not null,---AR列的编辑性
  sequence integer default 0   not null
)
exec sp_primarykey 'sys_guest_auth', name

create unique  nonclustered index index1
    on sys_guest_auth(name)
;
  
