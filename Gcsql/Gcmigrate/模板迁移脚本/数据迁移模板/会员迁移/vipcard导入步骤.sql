SELECT * FROM portal_member.hotel;

SELECT * FROM portal_member.code_transaction WHERE hotel_group_id = 118 ORDER BY CODE;

CALL up_ihotel_up_member(@ret);

SELECT SUM(charge),SUM(pay) FROM migrate_db.membercard;

SELECT * FROM migrate_db.membercard a,portal_member.card_base b WHERE b.hotel_group_id = 118
AND b.card_no = a.card_no AND a.hotel_group_id = 118;

SELECT * FROM card_base WHERE hotel_group_id = 118;

CALL up_ihotel_up_member_import(@ret);

SELECT * FROM card_base WHERE hotel_group_id = 118 AND hotel_id = 10135;

UPDATE card_base SET card_level='VIP003' WHERE hotel_group_id = 118 AND hotel_id = 10135;

UPDATE card_base SET hotel_id = 12 WHERE hotel_group_id = 118 AND hotel_id = 10135;

SELECT * FROM card_account WHERE hotel_group_id = 118 AND hotel_id =12;

UPDATE card_account SET hotel_id = 12 WHERE hotel_group_id = 118 AND hotel_id = 10135;


SELECT * FROM card_base WHERE hotel_group_id = 118 AND hotel_id=12 AND charge - pay <> 0;

SELECT * FROM card_base WHERE hotel_group_id = 118 AND hotel_id=10;


UPDATE card_base SET iss_hotel = 'XCHQYJD' WHERE hotel_group_id = 118 AND iss_hotel = 'FHQYJD';