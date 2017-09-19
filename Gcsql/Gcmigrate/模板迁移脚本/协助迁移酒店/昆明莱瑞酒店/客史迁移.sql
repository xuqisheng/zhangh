SELECT * FROM hotel;

SELECT * FROM guest;

ALTER TABLE guest ADD COLUMN sex CHAR(1) AFTER  name_combine;

SELECT * FROM up_map_accnt WHERE hotel_group_id = 97 AND hotel_id = 10107;

SELECT * FROM code_base WHERE hotel_group_id = 97 AND hotel_id = 10107 AND parent_code = 'idcode';

CALL up_ihotel_up_guest(97,10107);

SELECT * FROM guest_base WHERE hotel_group_id = 97 ;

SELECT * FROM guest_type WHERE hotel_group_id = 97 ;
UPDATE 
guest_type SET sys_cat = 'N' WHERE hotel_group_id = 97 ;