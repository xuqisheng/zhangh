
delete basecode where cat='action' ;
insert basecode(cat,code,descript,descript1) values('action','Reserv','w_gds_master','w_gds_master') ;
insert basecode(cat,code,descript,descript1) values('action','Profile','w_gds_guest','w_gds_guest') ;
insert basecode(cat,code,descript,descript1) values('action','Profile.1','w_gds_guest_front','w_gds_guest_front') ;
insert basecode(cat,code,descript,descript1) values('action','Bill','w_gl_accnt_billing','w_gl_accnt_billing') ;
insert basecode(cat,code,descript,descript1) values('action','Block','w_gds_sc_master','w_gds_sc_master') ;
insert basecode(cat,code,descript,descript1) values('action','Vipcard','w_gds_vipcard','w_gds_vipcard') ;

--insert basecode(cat,code,descript,descript1) values('action','sp','w_gds_master','w_gds_master') ;
--insert basecode(cat,code,descript,descript1) values('action','Activity','w_gds_sc_master','w_gds_sc_master') ;
--insert basecode(cat,code,descript,descript1) values('action','Event','w_gds_sc_master','w_gds_sc_master') ;


select * from basecode where cat='action';
