
// �ۺ�ɨ����ʱ��¼ 
if exists(select * from sysobjects where name = "foxhis_sign")
	drop table foxhis_sign;
CREATE TABLE foxhis_sign 
(
    signid     int          NOT NULL,		// ID ��ˮ 
    name1      varchar(100) NULL,			// ���� 
    ref1       varchar(60)  NULL,			// ��ע 
    sign       image        NULL,			// ͼ�� 
    linkno     char(10)     NULL,			// ������ 
    empno      char(5)      NOT NULL,		// ������
    addtime    datetime     NOT NULL,		// ����ʱ��
    addpcid    char(4)      NOT NULL,		// ����վ�� 
    scan_class char(1)      NOT NULL,		// N=��������ʹ�� 
    flag       char(1)      NOT NULL,
    linkempno  char(5)      NOT NULL,		// ������
    linktime   datetime     NULL,			// ����ʱ�� 
    type1      char(1)      NOT NULL		// ��������S=ǩ�� P=��Ƭ 
);

