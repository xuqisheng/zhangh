

// ��Щ����ʹ�ñ��͵���  -- ע�ⲻ�ǵ�λ��˾ 
select "insert aaa select " + a.name + " from  " + b.name + " where " + a.name+"<"+">" + "'"+"' "  + ';'
	from syscolumns a, sysobjects b  where a.id=b.id and (a.name='haccnt' or a.name='hno'); 

// ��¼��Щ����������ɾ����  -- ����Ҫ��ɾ�� ���� ��ʷ��log �� 
insert aaa select haccnt from master_middle where haccnt<>'' ;
insert aaa select haccnt from sc_master where haccnt<>'' ;
insert aaa select haccnt from pos_menu where haccnt<>'' ;
insert aaa select hno from sp_plaav where hno<>'' ;
insert aaa select haccnt from turnaway where haccnt<>'' ;
insert aaa select haccnt from pos_reserve where haccnt<>'' ;
insert aaa select haccnt from ar_master where haccnt<>'' ;
insert aaa select haccnt from accnt_set where haccnt<>'' ;
insert aaa select haccnt from subaccnt where haccnt<>'' ;
insert aaa select haccnt from rmrate_tchg where haccnt<>'' ;
insert aaa select haccnt from master_des_till where haccnt<>'' ;
insert aaa select haccnt from sc_master_till where haccnt<>'' ;
insert aaa select haccnt from sp_menu where haccnt<>'' ;
insert aaa select haccnt from master where haccnt<>'' ;
insert aaa select haccnt from pos_tmenu where haccnt<>'' ;
insert aaa select haccnt from master_quick where haccnt<>'' ;
insert aaa select hno from vipcard where hno<>'' ;
insert aaa select haccnt from qroom where haccnt<>'' ;
insert aaa select haccnt from master_des where haccnt<>'' ;
insert aaa select haccnt from sp_reserve where haccnt<>'' ;
insert aaa select haccnt from master_last where haccnt<>'' ;
insert aaa select haccnt from master_till where haccnt<>'' ;
insert aaa select haccnt from ar_master_till where haccnt<>'' ;
insert aaa select haccnt from sc_pos_reserve where haccnt<>'' ;
insert aaa select haccnt from sp_tmenu where haccnt<>'' ;
insert aaa select haccnt from armst where haccnt<>'' ;
