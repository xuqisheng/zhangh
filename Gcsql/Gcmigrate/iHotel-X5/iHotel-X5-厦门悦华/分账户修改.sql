SELECT * FROM account_sub WHERE hotel_id = 1 AND accnt = 13537;

SELECT * FROM account WHERE hotel_id = 1 AND accnt = 13537;

SELECT * FROM account a,account_sub b WHERE a.hotel_group_id = 1 AND a.hotel_id = 1  
AND a.accnt = b.accnt AND b.hotel_group_id = 1 AND b.hotel_id = 1 AND b.type = 'SUBACCNT'
AND b.tag = 'USER' AND b.accnt_type = 'MASTER' AND INSTR(b.ta_codes,a.ta_code) > 0;
 
 
SELECT * FROM account a,account_sub b WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 
AND a.accnt = b.accnt AND b.hotel_group_id = 1 AND b.hotel_id = 1 AND b.type = 'SUBACCNT'
AND b.tag = 'USER' AND b.accnt_type = 'MASTER' AND INSTR(b.ta_codes,a.ta_code) > 0; 
-- 更新分账户
UPDATE account a,account_sub b  SET a.subaccnt = b.id
WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 
AND a.accnt = b.accnt AND b.hotel_group_id = 1 AND b.hotel_id = 1 AND b.type = 'SUBACCNT'
AND b.tag = 'USER' AND b.accnt_type = 'MASTER' AND INSTR(b.ta_codes,a.ta_code) > 0; 
-- 更新分账户自己部分

SELECT * FROM account a,account_sub b WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 
AND a.accnt = b.accnt AND b.hotel_group_id = 1 AND b.hotel_id = 1 AND b.type = 'SUBACCNT'
AND b.tag = 'SYS_FIX' AND b.accnt_type = 'MASTER' AND INSTR(b.ta_codes,a.ta_code) = 0;

SELECT * FROM account a,account_sub b WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 AND a.accnt = 12702
AND a.accnt = b.accnt AND b.hotel_group_id = 1 AND b.hotel_id = 1 AND b.type = 'SUBACCNT'
AND b.tag = 'SYS_FIX' AND b.accnt_type = 'MASTER' AND INSTR(b.ta_codes,a.ta_code) = 0;


UPDATE account a,account_sub b  SET a.subaccnt = b.id
WHERE a.hotel_group_id = 1 AND a.hotel_id = 1 
AND a.accnt = b.accnt AND b.hotel_group_id = 1 AND b.hotel_id = 1 AND b.type = 'SUBACCNT'
AND b.tag = 'SYS_FIX' AND b.accnt_type = 'MASTER' AND INSTR(b.ta_codes,a.ta_code) = 0; 

