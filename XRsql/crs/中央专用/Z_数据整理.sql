-- ϵͳά��
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

INSERT INTO auto_dept(code,descript,descript1) VALUES ('A','����Ԥ������','CRS Report')
INSERT INTO auto_dept(code,descript,descript1) VALUES ('Z1','�ҵĲ���','My Test')
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

//INSERT INTO syscode_maint ( code,descript,descript1,wtype,auth,show,source,parm ) VALUES ( 'S9','ͬ����������','Hotel Sync Setup','response','','d_maint_hotelsync','w_maint_hotelsync','' ) 
INSERT INTO syscode_maint ( code,descript,descript1,wtype,auth,show,source,parm ) VALUES ( 'SA','��Ա�Ƶ�����','Hotel Info','response','','d_hotelinfo_list','w_hotelinfo_maint','' ) 
INSERT INTO syscode_maint ( code,descript,descript1,wtype,auth,show,source,parm ) VALUES ( 'SZ','ϵͳ����Ƥ��','Foxhis Theme','response','','d_sys_foxtheme_list','w_sys_foxtheme','' ) 
;
-- ����
delete from basecode where cat = 'dept'
;
INSERT INTO basecode ( cat,code,descript,descript1,sys,halt,sequence,grp,center ) VALUES ( 'dept','0','supervisor','supervisor','T','F',0,'','F' ) 
INSERT INTO basecode ( cat,code,descript,descript1,sys,halt,sequence,grp,center ) VALUES ( 'dept','B','Ԥ������','Reserve Center','F','T',0,'','F' ) 
INSERT INTO basecode ( cat,code,descript,descript1,sys,halt,sequence,grp,center ) VALUES ( 'dept','B00','Ԥ�����ľ���','Reserve Center Manager','F','T',0,'','F' ) 
INSERT INTO basecode ( cat,code,descript,descript1,sys,halt,sequence,grp,center ) VALUES ( 'dept','B01','Ԥ����Ա','Reserve Center Operator','F','T',0,'','F' ) 
INSERT INTO basecode ( cat,code,descript,descript1,sys,halt,sequence,grp,center ) VALUES ( 'dept','O','��������','Other','F','F',0,'','F' ) 
INSERT INTO basecode ( cat,code,descript,descript1,sys,halt,sequence,grp,center ) VALUES ( 'dept','O99','��ѵ','Train','F','F',0,'','F' ) 
INSERT INTO basecode ( cat,code,descript,descript1,sys,halt,sequence,grp,center ) VALUES ( 'dept','X','������','WeskLake','F','F',0,'','F' ) 
INSERT INTO basecode ( cat,code,descript,descript1,sys,halt,sequence,grp,center ) VALUES ( 'dept','Z','���Է�','EDP','F','T',0,'','F' ) 
;

-- Ա��
delete from sys_empno where deptno not in(select code from basecode where cat = 'dept') 
;
-- ϵͳ������

delete from basecode where cat = 'moduno' and code = 'ZZ'
;
INSERT INTO basecode ( cat,code,descript,descript1,sys,halt,sequence,grp,center ) VALUES ( 'moduno','ZZ','Ԥ������','Center Reservation','F','F',0,'','F' ) 
;
