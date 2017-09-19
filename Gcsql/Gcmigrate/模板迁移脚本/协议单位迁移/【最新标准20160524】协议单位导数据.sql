
*注意：切记导入之前协议单位加一个唯一标识如：company_base.create_hotel='30' , company_type.create_user='999'; 
这样做的好处就是为了防止出错时，可以通过此标识找出来刚插入的数据，以便删除重新导。
之前导入后，只要做修改就会报错，原因是company_base表中集团ID与本地库Id号不一致导致，导完后，需把PMS库id与group库id做成一样的。

*********************************************************************************************************************************************
1、集团库company_base数据插入
INSERT INTO company_base   (`hotel_group_id`, `hotel_id`, `name`,`name2`,`name_combine`, `is_save`, `language`,`nation`,`phone`,`linkman1`,`country`,`street`,
`remark`,`create_hotel`,`create_user`, `create_datetime`, `modify_hotel`, `modify_user`, `modify_datetime`)
 SELECT '2','0',单位名称,单位名称,单位名称,'F','C','CN',办公电话,联系人,'CN',地址,备注,'28','9999','2016-05-24 10:01:31','9','9999','2016-05-24 10:01:31'  FROM sheet1$

/*   
插入后查询是否插入成功；核对下数量，如果不对再执行下面的删除语句；
SELECT * FROM company_base WHERE create_hotel='28'

DELETE FROM company_base WHERE create_hotel='28'
*/   

--portal_group（先在集团库执行） 
--portal_pms（后在酒店库执行）


 
2、 集团库company_type数据插入
INSERT INTO company_type   (`hotel_group_id`, `hotel_id`, `company_id`,`sta`,`manual_no`, `sys_cat`, `over_rsvsrc`, `belong_app_code`, `valid_begin`, `valid_end`,`code1`,`saleman`, `create_user`, 
`create_datetime`,  `modify_user`, `modify_datetime`)
 SELECT '2','0',a.id,'I',b.合约号,'C','F',1,b.有效期由,b.有效期至,b.房价代码,b.业务员,9999,'2016-05-24 10:01:31',9999,'2016-05-24 10:01:31'
 FROM company_base  a , sheet1$  b  WHERE   a.name=b.单位名称     AND          a.create_user='9999'
 
 /*
 插入后查询是否插入成功；核对下数量，如果不对再执行下面的删除语句；
SELECT * FROM company_type WHERE  create_user='9999' AND hotel_group_id=2
 
DELETE FROM company_type WHERE  create_user='9999' AND hotel_group_id=2 
*/
--portal_group（先在集团库执行） 
--portal_pms（后在酒店库执行）


3、酒店库company_type数据插入
INSERT INTO company_type   (`hotel_group_id`, `hotel_id`, `company_id`,`sta`,`manual_no`, `sys_cat`, `over_rsvsrc`, `belong_app_code`, `valid_begin`, `valid_end`,`code1`,`saleman`, `create_user`, 
`create_datetime`,  `modify_user`, `modify_datetime`)
 SELECT '2','28',a.id,'I',b.合约号,'C','F',1,b.有效期由,b.有效期至,b.房价代码,b.业务员,9999,'2016-05-24 10:01:31',9999,'2016-05-24 10:01:31'
 FROM company_base  a , sheet1$  b  WHERE   a.name=b.单位名称     AND          a.create_user='9999'
 
/*
SELECT * FROM company_type WHERE create_user='9999' LIMIT 100000;
*/
--portal_group（先在集团库执行） 
--portal_pms（后在酒店库执行）


4、执行此过程
  CALL up_fill_company_profile_extra('2','28')
--portal_group（先在集团库执行） 
--portal_pms（后在酒店库执行）



*************************************************************
5、如不能模糊查询、导完后批量更新name字段
update company_base set name2=name,name3=name,name_combine=name where hotel_group_id=1 and saleman='XX';
-------------------------------
6、导完之后指修改销售员

UPDATE company_type SET saleman='DM419' WHERE hotel_group_id=1 AND saleman='关航';


