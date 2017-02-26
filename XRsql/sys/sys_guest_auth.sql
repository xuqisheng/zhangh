if exists(select 1 from sysobjects where name='sys_guest_auth' and type='U')
drop table sys_guest_auth
;
create table sys_guest_auth
(
  name varchar(30) not null,     -----guest��������� ������tabpage������
  descript varchar(20) null,
  descript1 varchar(20) null,
  type     varchar(3) not null,  -----��'col'�����'tab'
  fvisible  char(1) default 'T'  not null,---�����еĿɼ���
  fedit     char(1) default 'T'  not null,---�����еı༭��
  gvisible  char(1) default 'T'  not null,---�Ŷ��еĿɼ���
  gedit     char(1) default 'T'  not null,---�Ŷ��еı༭��
  cvisible  char(1) default 'T'  not null,---Э�鵥λ�еĿɼ���
  cedit     char(1) default 'T'  not null,---Э�鵥λ�����еı༭��
  rvisible  char(1) default 'T'  not null,---AR�еĿɼ���
  redit     char(1) default 'T'  not null,---AR�еı༭��
  sequence integer default 0   not null
)
exec sp_primarykey 'sys_guest_auth', name

create unique  nonclustered index index1
    on sys_guest_auth(name)
;
  
