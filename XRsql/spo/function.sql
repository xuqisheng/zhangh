
//INSERT INTO sys_function VALUES ('0311','03','����ϵͳ','����ϵͳ_e','appid!S');
//
//INSERT INTO basecode VALUES ('function_class','40','����ϵͳ','����ϵͳ_eng','F','F',0,' ','F');

delete sys_function where code like '40%';
INSERT INTO sys_function VALUES ( '4001','40', '���ֿ���','���ֿ���_e','sp!newmenu');
INSERT INTO sys_function VALUES ( '4002','40', '����Ԥ��','����Ԥ��_e','sp!newreserve');
INSERT INTO sys_function VALUES ( '4003','40', '��������Ԥ��','��������Ԥ��_e','sp!mulreserve');
INSERT INTO sys_function VALUES ( '4004','40', '���ֳ���ά��','����ά��_e','sp!modiplace');
INSERT INTO sys_function VALUES ( '4005','40', '���ֳ��ؼ�¼','���ؼ�¼_e','sp!vipuseplace');
INSERT INTO sys_function VALUES ( '4006','40', '���ֽ���','���ֽ���_e','sp!checkout');
INSERT INTO sys_function VALUES ( '4007','40', '����Ԥ��ת�Ǽ�','����Ԥ��ת�Ǽ�_e','sp!res!reg');
INSERT INTO sys_function VALUES ( '4008','40', '���ֽ�������','���ֽ�������_e','sp!place!over');
INSERT INTO sys_function VALUES ( '4009','40', '����ά�޽���','����ά�޽���_e','sp!place!modiover');

INSERT INTO sys_function VALUES ( '4010','40', '����ɾ���û�����','����ɾ���û�����_e','sp!place!use!del');
INSERT INTO sys_function VALUES ( '4011','40', '��������','��������_e','sp!menu!union');
INSERT INTO sys_function VALUES ( '4012','40', '���ֳ��ؽ���','���ֳ��ؽ���_e','sp!place!cho');
INSERT INTO sys_function VALUES ( '4013','40', '�����޸��û�����','�����޸��û�����_e','sp!place!use!modi');
INSERT INTO sys_function VALUES ( '4014','40', '���������û�����','���������û�����_e','sp!place!use!add');
INSERT INTO sys_function VALUES ( '4015','40', '���ַ�������','���ַ�������_e','sp!inputdish');

INSERT INTO sys_function VALUES ( '4016','40', '�����ؽ�','�����ؽ�_e','sp!menu!recheck');
INSERT INTO sys_function VALUES ( '4017','40', '��������','��������_e','sp!menu!cancel');
INSERT INTO sys_function VALUES ( '4018','40', '���ֳ�������','���ֳ�������_e','sp!union!cancel');
INSERT INTO sys_function VALUES ( '4019','40', '����Ԥ��ȷ��','����Ԥ��ȷ��_e','sp!reserve!ok');
INSERT INTO sys_function VALUES ( '4020','40', '����ȡ��Ԥ��','����ȡ��Ԥ��_e','sp!res!cancel');

INSERT INTO sys_function VALUES ( '4021','40', '����Ԥ������','����Ԥ������_e','sp!res!account');
INSERT INTO sys_function VALUES ( '4022','40', '�����˻ض���','�����˻ض���_e','sp!res!reaccount');

INSERT INTO sys_function VALUES ( '4023','40', '����Ԥ���ӳ���','����Ԥ���ӳ���_e','sp!res!addplace');

INSERT INTO sys_function VALUES ( '4024','40', '����Ԥ��������','����Ԥ��������_e','sp!res!unplace');


INSERT INTO sys_function VALUES ( '4025','40', '���ִ���༭','���ִ���༭_e','sp!code!edit');
INSERT INTO sys_function VALUES ( '4026','40', '�����½��ƻ�','�����½��ƻ�_e','sp!plan!new');

INSERT INTO sys_function VALUES ( '4027','40', '���ּƻ��޸�','���ּƻ��޸�_e','sp!plan!modi');

INSERT INTO sys_function VALUES ( '4028','40', '�����½�Ͷ��','�����½�Ͷ��_e','sp!mind!new');

INSERT INTO sys_function VALUES ( '4029','40', '����Ͷ���޸�','����Ͷ���޸�_e','sp!mind!modi');
INSERT INTO sys_function VALUES ( '4030','40', '���ּĴ������ý���','���ּĴ������ý���_e','sp!rent!new');
INSERT INTO sys_function VALUES ( '4031','40', '����Ԥ���޸�','����Ԥ���޸�_e','sp!modireserve');

INSERT INTO sys_function VALUES ( '4032','40', '���ֳ������','���ֳ������_e','sp!cancel!dish');
