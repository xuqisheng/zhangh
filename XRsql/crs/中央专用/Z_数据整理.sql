-- 系统维护
delete from adtrep;
;
delete from auto_dept where code like '0%'
delete from auto_dept where code like 'B%'
delete from auto_dept where code like 'C%'
delete from auto_dept where code like 'D%'
delete from auto_dept where code like 'E%'
delete from auto_dept where code like 'F%'
delete from auto_dept where code like 'G%'
delete from auto_dept where code like 'H%'
delete from auto_dept where code like 'I%'
delete from auto_dept where code like 'J%'
delete from auto_dept where code like 'K%'
delete from auto_dept where code like 'L%'
delete from auto_dept where code in('A','Z1','Z1','Z4','Z5')

delete from auto_report where dept not in(select code from auto_dept)
;

INSERT INTO auto_dept(code,descript,descript1) VALUES ('A','中央预订报表','CRS Report')
INSERT INTO auto_dept(code,descript,descript1) VALUES ('Z1','我的测试','My Test')
;


delete from syscode_maint where code in('152','153','154','155','2','21','23','24','241')
delete from syscode_maint where code like '21_'
delete from syscode_maint where code like '23_'
delete from syscode_maint where code in('356','357','358')
delete from syscode_maint where code like '4%'
delete from syscode_maint where code like '5%'
delete from syscode_maint where code like '6%'
delete from syscode_maint where code like '8%'
delete from syscode_maint where code like '9%'
delete from syscode_maint where code like 'C%'
delete from syscode_maint where code like 'D%'
delete from syscode_maint where code like 'P%'
delete from syscode_maint where code like 'R%'
delete from syscode_maint where code in('S1','S5','S6','S7','S9','SA','SZ')
;

//INSERT INTO syscode_maint ( code,descript,descript1,wtype,auth,show,source,parm ) VALUES ( 'S9','同步数据设置','Hotel Sync Setup','response','','d_maint_hotelsync','w_maint_hotelsync','' ) 
INSERT INTO syscode_maint ( code,descript,descript1,wtype,auth,show,source,parm ) VALUES ( 'SA','成员酒店设置','Hotel Info','response','','d_hotelinfo_list','w_hotelinfo_maint','' ) 
INSERT INTO syscode_maint ( code,descript,descript1,wtype,auth,show,source,parm ) VALUES ( 'SZ','系统界面皮肤','Foxhis Theme','response','','d_sys_foxtheme_list','w_sys_foxtheme','' ) 
;
-- 部门
delete from basecode where cat = 'dept'
;
INSERT INTO basecode ( cat,code,descript,descript1,sys,halt,sequence,grp,center ) VALUES ( 'dept','0','supervisor','supervisor','T','F',0,'','F' ) 
INSERT INTO basecode ( cat,code,descript,descript1,sys,halt,sequence,grp,center ) VALUES ( 'dept','B','预订中心','Reserve Center','F','T',0,'','F' ) 
INSERT INTO basecode ( cat,code,descript,descript1,sys,halt,sequence,grp,center ) VALUES ( 'dept','B00','预订中心经理','Reserve Center Manager','F','T',0,'','F' ) 
INSERT INTO basecode ( cat,code,descript,descript1,sys,halt,sequence,grp,center ) VALUES ( 'dept','B01','预订人员','Reserve Center Operator','F','T',0,'','F' ) 
INSERT INTO basecode ( cat,code,descript,descript1,sys,halt,sequence,grp,center ) VALUES ( 'dept','O','其他部门','Other','F','F',0,'','F' ) 
INSERT INTO basecode ( cat,code,descript,descript1,sys,halt,sequence,grp,center ) VALUES ( 'dept','O99','培训','Train','F','F',0,'','F' ) 
INSERT INTO basecode ( cat,code,descript,descript1,sys,halt,sequence,grp,center ) VALUES ( 'dept','X','西软用','WeskLake','F','F',0,'','F' ) 
INSERT INTO basecode ( cat,code,descript,descript1,sys,halt,sequence,grp,center ) VALUES ( 'dept','Z','电脑房','EDP','F','T',0,'','F' ) 
;

-- 员工
delete from sys_empno where deptno not in(select code from basecode where cat = 'dept') 
;
-- 系统工作表

delete from basecode where cat = 'moduno' and code = 'ZZ'
;
INSERT INTO basecode ( cat,code,descript,descript1,sys,halt,sequence,grp,center ) VALUES ( 'moduno','ZZ','预订中心','Center Reservation','F','F',0,'','F' ) 
;
