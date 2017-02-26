
// -------------------------------------------------------------------------------------
//	��ʷ���� -- ɾ����� 
// -------------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "guest_del_flag")
	drop table guest_del_flag;
create table  guest_del_flag
(
	no    		char(7)		 						not null,		// ������:�����Զ����� 
	lastdate		datetime								not null,		// �����޸�ʱ��
   crtby       char(10)								not null,		// ���� 
	crttime     datetime 		default getdate()	not null,
	bdate			datetime								not null 
)
exec sp_primarykey guest_del_flag,no
create unique index index1 on guest_del_flag(no)
create index index2 on guest_del_flag(crttime)
;
