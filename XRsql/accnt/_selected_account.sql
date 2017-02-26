/* ��¼��Ҫһ������˺Ż�����(��ʱ) */

if exists(select * from sysobjects where type ="U" and name = "selected_account")
   drop table selected_account;

create table selected_account
(
	type			char(1)		not null,	/* ����	1.��ϸ��Ŀ��ѯר��
																2.��Ҫһ������˺�(����,���ֽ��˵�)
																3.post_chargeר��
																4.rmpostר��
																5.��Ҫһ���ӡ�˵����˺�
																6.��Ҫһ��������ÿ�����(���ֽ���) 
																s.����
																d.�ſ�����
																g.ǰ̨״̬����fit-mem 
																m.�����Ա�������� 
																s.ͬס����
																c.Ӷ����
*/
	pc_id			char(4)		not null,	/* IP��ַ */
	mdi_id		integer		not null,	/* �������ڵ�ID�� */
	accnt			char(10)		not null,	/* �˺� */
	number		integer		not null		/* �˴� */
)
exec   sp_primarykey selected_account, type, pc_id, mdi_id, accnt, number
create unique index index1 on selected_account(type, pc_id, mdi_id, accnt, number)
;
