

//delete sysdefault where datawindow = 'd_gds_sc_master11'; 

exec p_foxhis_sysdefault 'd_gds_sc_master11',	'roomno',	'',	'A';
exec p_foxhis_sysdefault 'd_gds_sc_master11',	'c_saleid',	'#empno#',	'A';
exec p_foxhis_sysdefault 'd_gds_sc_master11',	'cby',	'#empno#',	'A';
exec p_foxhis_sysdefault 'd_gds_sc_master11',	'resby',	'#empno#',	'A';
exec p_foxhis_sysdefault 'd_gds_sc_master11',	'saleid2',	'#empno#',	'A';
exec p_foxhis_sysdefault 'd_gds_sc_master11',	'arr',	'#sysdate#',	'A';
exec p_foxhis_sysdefault 'd_gds_sc_master11',	'changed',	'#sysdate#',	'A';
exec p_foxhis_sysdefault 'd_gds_sc_master11',	'restime',	'#sysdate#',	'A';
exec p_foxhis_sysdefault 'd_gds_sc_master11',	'extra',	'0A0001000100000',	'A';
exec p_foxhis_sysdefault 'd_gds_sc_master11',	'packages',	'2BFG',	'A';
exec p_foxhis_sysdefault 'd_gds_sc_master11',	'channel',	'3',	'A';
exec p_foxhis_sysdefault 'd_gds_sc_master11',	'restype',	'4',	'A';
exec p_foxhis_sysdefault 'd_gds_sc_master11',	'src',	'HDR',	'A';
exec p_foxhis_sysdefault 'd_gds_sc_master11',	'market',	'MET',	'A';
exec p_foxhis_sysdefault 'd_gds_sc_master11',	'ratecode',	'MET',	'A';
exec p_foxhis_sysdefault 'd_gds_sc_master11',	'c_status',	'TEN',	'A';
exec p_foxhis_sysdefault 'd_gds_sc_master11',	'status',	'INQ',	'A';

select * from sysdefault where datawindow = 'd_gds_sc_master11' order by columnname; 
