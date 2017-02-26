/* ��¼��Ҫһ������˺Ż�����(��ʱ) */

if exists(select * from sysobjects where type ="U" and name = "selected_account")
   drop table selected_account;

create table selected_account
(
	type			char(1)		not null,							/* ����	1.��ϸ��Ŀ��ѯר��
																						2.��Ҫһ������˺�(����,���ֽ��˵�)
																						3.post_chargeר��
																						4.rmpostר��
																						5.��Ҫһ���ӡ�˵����˺�
																						6.��Ҫһ��������ÿ�����(���ֽ���) */
	pc_id			char(4)		not null,							/* IP��ַ */
	mdi_id		integer		not null,							/* �������ڵ�ID�� */
	accnt			char(10)		not null,							/* �˺� */
	number		integer		not null								/* �˴� */
)
exec   sp_primarykey selected_account, type, pc_id, mdi_id, accnt, number
create unique index index1 on selected_account(type, pc_id, mdi_id, accnt, number)
;

if exists(select * from sysobjects where name = "accnt_set")
   drop table accnt_set;

create table accnt_set
(
	pc_id				char(4)			not null,					/* IP��ַ */
	mdi_id			integer			not null,					/* ��� */
	roomno			char(5)			not null,					/* ���� */
	accnt				char(10)			not null,					/* �˺� */
	subaccnt			integer			not null,					/* ���˺� */
	haccnt			char(7)			not null,					/* ��ʷ������ */
	name				char(50)			not null,					/* ���� */
	sta				char(3)			not null,					/* �˻�״̬ */
	charge			money				not null,					/* ���� */
	credit			money				not null,					/* Ԥ�� */
	tree_level		integer			default 0 not null,		/* ״̬ */
	tree_children	char(1)			not null,					/* */
	tree_picture	char(1)			not null,					/* ͼ����� */
	tag				char(1)			not null,					/* ��ʾ״̬ */
	csta				integer			default 0 not null		/* ��ʱʹ�� */
)
exec   sp_primarykey accnt_set, pc_id, mdi_id, roomno, accnt, subaccnt
create unique index index1 on accnt_set(pc_id, mdi_id, roomno, accnt, subaccnt)
;

// ��ʱ�˼��е���ϸ����
if exists(select * from sysobjects where name = "account_folder")
   drop table account_folder;

create table account_folder
(
	pc_id				char(4)			not null,					/*IP��ַ*/
	mdi_id			integer			not null,					/*���*/
	folder			integer			not null,					/*��ʱ�˼еı��*/
	accnt				char(10)			not null,					/*�˺�*/
	number			integer			not null						/*�˴�*/
)
exec   sp_primarykey account_folder, pc_id, mdi_id, folder, accnt, number
create unique index index1 on account_folder(pc_id, mdi_id, folder, accnt, number)
;

// ��ʱ�м��������ŵ�ǰ�˼��е���ϸ������p_gl_accnt_list_account���ɣ�p_gl_accnt_subtotal����ʹ��
if exists(select * from sysobjects where name = "account_temp")
   drop table account_temp;

create table account_temp
(
	pc_id				char(4)			not null,					/*IP��ַ*/
	mdi_id			integer			not null,					/*���*/
	accnt				char(10)			not null,					/*�˺�*/
	number			integer			not null,					/*�˴�*/
	mode1				char(10)			default '' not null,		/*ת�ʵ���*/
	billno			char(10)			default '' not null,		/*���˵���*/
	selected			integer			default 0 not null,		/*ѡ���־*/
	charge			money				default 0 not null,		/**/
	credit			money				default 0 not null		/**/
)
exec   sp_primarykey account_temp, pc_id, mdi_id, accnt, number
create unique index index1 on account_temp(pc_id, mdi_id, accnt, number)
create index index2 on account_temp(pc_id, mdi_id, selected)
;

// ��ʱ�м���������ת�ʸ�ʽ����ϸ������p_gl_accnt_list_account_ar���ɣ�p_gl_accnt_subtotal_ar����ʹ��
if exists(select * from sysobjects where name = "account_ar")
   drop table account_ar;

create table account_ar
(
	pc_id				char(4)			not null,					/*IP��ַ*/
	mdi_id			integer			not null,					/*���*/
	sta				char(1)			null,
	accnt				char(10)			default ''	null,			/*�˺�*/
	number			integer			default 0	null,			/*�˴�*/
	fmaccnt			char(10)			default ''	null,			/*ת�ʵ��˺�*/
	fmroomno			char(5)			default ''	null,			/*ת�ʵķ���*/
	modu_id			char(2)			default ''	null,
	pccode			char(5)			default ''	null,
	charge			money				default 0	null,
	credit			money				default 0	null,
	amount			money				default 0	null,
	amount1			money				default 0	null,
	ref				char(24)			null,
	ref1				char(10)			null,							/*ת�ʵ�billno*/
	ref2				char(50)			null,
	bdate				datetime			default getdate() null,
	log_date			datetime			default getdate() null,
	shift				char(1)			default ''	null,
	empno				char(10)			default ''	null,
	billno			char(10)			null
)
create index index1 on account_ar(pc_id, mdi_id, accnt, number)
create index index2 on account_ar(pc_id, mdi_id, fmaccnt)
;
