
*ע�⣺�мǵ���֮ǰЭ�鵥λ��һ��Ψһ��ʶ�磺company_base.create_hotel='30' , company_type.create_user='999'; 
�������ĺô�����Ϊ�˷�ֹ����ʱ������ͨ���˱�ʶ�ҳ����ղ�������ݣ��Ա�ɾ�����µ���
֮ǰ�����ֻҪ���޸ľͻᱨ��ԭ����company_base���м���ID�뱾�ؿ�Id�Ų�һ�µ��£���������PMS��id��group��id����һ���ġ�

*********************************************************************************************************************************************
1�����ſ�company_base���ݲ���
INSERT INTO company_base   (`hotel_group_id`, `hotel_id`, `name`,`name2`,`name_combine`, `is_save`, `language`,`nation`,`phone`,`linkman1`,`country`,`street`,
`remark`,`create_hotel`,`create_user`, `create_datetime`, `modify_hotel`, `modify_user`, `modify_datetime`)
 SELECT '2','0',��λ����,��λ����,��λ����,'F','C','CN',�칫�绰,��ϵ��,'CN',��ַ,��ע,'28','9999','2016-05-24 10:01:31','9','9999','2016-05-24 10:01:31'  FROM sheet1$

/*   
������ѯ�Ƿ����ɹ����˶������������������ִ�������ɾ����䣻
SELECT * FROM company_base WHERE create_hotel='28'

DELETE FROM company_base WHERE create_hotel='28'
*/   

--portal_group�����ڼ��ſ�ִ�У� 
--portal_pms�����ھƵ��ִ�У�


 
2�� ���ſ�company_type���ݲ���
INSERT INTO company_type   (`hotel_group_id`, `hotel_id`, `company_id`,`sta`,`manual_no`, `sys_cat`, `over_rsvsrc`, `belong_app_code`, `valid_begin`, `valid_end`,`code1`,`saleman`, `create_user`, 
`create_datetime`,  `modify_user`, `modify_datetime`)
 SELECT '2','0',a.id,'I',b.��Լ��,'C','F',1,b.��Ч����,b.��Ч����,b.���۴���,b.ҵ��Ա,9999,'2016-05-24 10:01:31',9999,'2016-05-24 10:01:31'
 FROM company_base  a , sheet1$  b  WHERE   a.name=b.��λ����     AND          a.create_user='9999'
 
 /*
 ������ѯ�Ƿ����ɹ����˶������������������ִ�������ɾ����䣻
SELECT * FROM company_type WHERE  create_user='9999' AND hotel_group_id=2
 
DELETE FROM company_type WHERE  create_user='9999' AND hotel_group_id=2 
*/
--portal_group�����ڼ��ſ�ִ�У� 
--portal_pms�����ھƵ��ִ�У�


3���Ƶ��company_type���ݲ���
INSERT INTO company_type   (`hotel_group_id`, `hotel_id`, `company_id`,`sta`,`manual_no`, `sys_cat`, `over_rsvsrc`, `belong_app_code`, `valid_begin`, `valid_end`,`code1`,`saleman`, `create_user`, 
`create_datetime`,  `modify_user`, `modify_datetime`)
 SELECT '2','28',a.id,'I',b.��Լ��,'C','F',1,b.��Ч����,b.��Ч����,b.���۴���,b.ҵ��Ա,9999,'2016-05-24 10:01:31',9999,'2016-05-24 10:01:31'
 FROM company_base  a , sheet1$  b  WHERE   a.name=b.��λ����     AND          a.create_user='9999'
 
/*
SELECT * FROM company_type WHERE create_user='9999' LIMIT 100000;
*/
--portal_group�����ڼ��ſ�ִ�У� 
--portal_pms�����ھƵ��ִ�У�


4��ִ�д˹���
  CALL up_fill_company_profile_extra('2','28')
--portal_group�����ڼ��ſ�ִ�У� 
--portal_pms�����ھƵ��ִ�У�



*************************************************************
5���粻��ģ����ѯ���������������name�ֶ�
update company_base set name2=name,name3=name,name_combine=name where hotel_group_id=1 and saleman='XX';
-------------------------------
6������֮��ָ�޸�����Ա

UPDATE company_type SET saleman='DM419' WHERE hotel_group_id=1 AND saleman='�غ�';


