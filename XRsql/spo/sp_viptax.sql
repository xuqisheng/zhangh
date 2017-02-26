/* ��ѽ��ɼ�¼�� */

if  exists(select * from sysobjects where name = "sp_viptax" and type ="U")
	  drop table sp_viptax;

create table sp_viptax
(
	no				char(20)		default ''			not null,			/*��Ա����*/
	packcode		char(10)		default ''			not null,			/*������*/
	inumber		integer		default 0 			not null,			/**/
	accnt			char(10)		default '' 			not null,			/*��ѵ������ʺ�*/
	pccode		char(5)		default ''			not null,			/*���˷�����*/
	
	class			char(1)		default '0' 		not null,			/*���0 -- ÿ�շ�̯��1 -- ��������̯��2 -- ����̯,ֱ��������*/
	arr			datetime		default getdate() not null, 			/*��Ч�ڵĿ�ʼʱ��*/
	dep			datetime		default getdate() not null, 			/*��Ч�ڵĽ���ʱ��*/
	bdate			datetime		default getdate() not null, 			/*��̯���ڼ�¼*/
	amount		money			default 0			not null,			/*�����ܽ��*/
	rate			money			default 0			not null,			/*ÿ�շ�̯���*/
	rate0			money			default 0			not null,
	posted		money			default 0			not null,			/*�Ѿ���̯���*/
	paycode		char(5)		default ''			not null,			/*���۸�����*/
	
	halt			char(1)		default 'F'			not null,			/*�������*/
	logdate		datetime		default getdate()	not null,   		/*����ʱ��*/
	empno			char(3)		default	''			not null,			/*����Ա*/
	accnt1		char(10)		default '' 			null


)
exec sp_primarykey sp_viptax,no,packcode,inumber
create unique index index1 on sp_viptax(no,packcode,inumber)
;

/* ��ѽ��ɼ�¼�� */

if  exists(select * from sysobjects where name = "sp_hviptax" and type ="U")
	  drop table sp_hviptax;

create table sp_hviptax
(
	no				char(20)		default ''			not null,			/*��Ա����*/
	packcode		char(10)		default ''			not null,			/*������*/
	inumber		integer		default 0 			not null,			/**/
	accnt			char(10)		default '' 			not null,			/*��ѵ������ʺ�*/
	pccode		char(5)		default ''			not null,			/*���˷�����*/
	
	class			char(1)		default '0' 		not null,			/*���0 -- ÿ�շ�̯��1 -- ��������̯��2 -- ����̯,ֱ��������*/
	arr			datetime		default getdate() not null, 			/*��Ч�ڵĿ�ʼʱ��*/
	dep			datetime		default getdate() not null, 			/*��Ч�ڵĽ���ʱ��*/
	bdate			datetime		default getdate() not null, 			/*��̯���ڼ�¼*/
	amount		money			default 0			not null,			/*�����ܽ��*/
	rate			money			default 0			not null,			/*ÿ�շ�̯���*/
	rate0			money			default 0			not null,
	posted		money			default 0			not null,			/*�Ѿ���̯���*/
	paycode		char(5)		default ''			not null,			/*���۸�����*/
	
	halt			char(1)		default 'F'			not null,			/*�������*/
	logdate		datetime		default getdate()	not null,   		/*����ʱ��*/
	empno			char(3)		default	''			not null,			/*����Ա*/
	accnt1		char(10)		default '' 			null

)
exec sp_primarykey sp_hviptax,no,packcode,inumber,bdate
create unique index index1 on sp_hviptax(no,packcode,inumber,bdate)
;

if  exists(select * from sysobjects where name = "sp_tax" and type ="U")
	  drop table sp_tax;

create table sp_tax
(
	no				char(20)		default ''			not null,			/*��Ա����*/
	packcode		char(10)		default ''			not null,			/*������*/
	inumber		integer		default 0 			not null,			/**/
	accnt			char(10)		default '' 			not null,			/*��ѵ������ʺ�*/
	pccode		char(5)		default ''			not null,			/*���˷�����*/
	
	audit			char(1)		default 'F'			not null,			/*�������*/
	logdate		datetime		default getdate()	not null,   		/*����ʱ��*/
	empno			char(3)		default	''			not null,			/*����Ա*/


)
exec sp_primarykey sp_tax,no,packcode,inumber
create unique index index1 on sp_tax(no,packcode,inumber)
;