
------------------------------------------------------------------------------------
-- �°�200805 �Կ�
-- ��˼�¼��������ͷ�����¼�Ĺ��ܡ� ȥ�� number, made �ȱ�ʾ�������ֶ� 
------------------------------------------------------------------------------------
if object_id('doorcard_req') is not null
	drop table doorcard_req ;
CREATE TABLE doorcard_req 
(
	 id		  numeric		identity,						--��ˮ��
	 sta		  char(1)		not null,						--�ſ�״̬ R=����, F=�ƿ�ʧ��, I=�ƿ��ɹ�, X=����, N=���ڿ�, L=��ʧ
    accnt     char(10)    NOT NULL,							--�ʺ�
    roomno    char(5)     DEFAULT ''	 NOT NULL,		--����
    name      varchar(50) DEFAULT ''	 NOT NULL,		--��������	
    arr       datetime    NOT NULL,							--��
    dep       datetime    NOT NULL,							--��	
    card_type char(10)    NOT NULL,							--����
    card_t    char(10)    NULL,								--���ȼ�
	 encoder		char(10)   null,								--�ƿ���
    pc_id     char(4)     NOT NULL,							--pc_id
	 cardno1	  varchar(20)	default ''	not null,      --�ſ���
	 cardno2	  varchar(20)	default ''	not null,      --�����������Ԥ�� 
	 flag1	  varchar(20)	default ''	not null,      --Ԥ���ֶ� 
	 flag2	  varchar(20)	default ''	not null,      --
	 flag3	  varchar(20)	default ''	not null,      --
	 flag4	  varchar(20)	default ''	not null,      --
	 remark    varchar(100) null,								-- ��ע���ƿ�ʧ����Ϣ�� 
    date      datetime    NOT NULL,							--Ӫҵ����
	 cby			char(10)		not null,						--������
	 cbydate		datetime		not null,						--����ʱ��
	 mby			char(10)		 null,							--�޸���
	 mbydate		datetime		 null								--�޸�ʱ��
);
EXEC sp_primarykey 'doorcard_req', id;
CREATE UNIQUE INDEX index1 ON doorcard_req(id);
CREATE INDEX index2 ON doorcard_req(accnt);
CREATE INDEX index3 ON doorcard_req(date);


------------------------------------------------------------------------------------
-- �ϰ棺��Ҫ�����¼�ƿ����� ���ܹ��������õĿ� 
------------------------------------------------------------------------------------
--if object_id('doorcard_req') is not null
--	drop table doorcard_req;
--create table doorcard_req (
--	accnt				char(10)							not null,
--	roomno			char(5)			default ''	not null,
--	name				varchar(50)		default ''	not null,
--	arr				datetime							not null,
--	dep				datetime							not null,
--	card_type		char(10)							not null,
--	number			int				default 1	not null,
--	made				int				default 0	not null,
--	done				char(1)			default 'F'	not null,
--	empno				char(10)							not null,
--	date				datetime							not null,
--	pc_id				char(4)							not null
--)
--exec sp_primarykey  doorcard_req, accnt;
--create unique index index1 on doorcard_req(accnt);

