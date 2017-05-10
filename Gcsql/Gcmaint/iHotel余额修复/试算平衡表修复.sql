SELECT classno,descript,last_bl,debit,credit,till_bl FROM rep_dai WHERE hotel_group_id = 1 AND hotel_id = 108
AND classno IN('02000','02000') ORDER BY classno;

SELECT SUM(charge - pay) FROM master_base_till WHERE hotel_group_id = 1 AND hotel_id = 108;
SELECT SUM(charge - pay) FROM ar_master_till WHERE hotel_group_id = 1 AND hotel_id = 108;

SELECT 1,22,'2016.01.21','02000',SUM(last_balance),SUM(charge_ttl),SUM(pay_ttl),SUM(till_balance) FROM master_snapshot WHERE hotel_group_id = 1 AND hotel_id = 108 AND
biz_date_begin < '2016.01.21' AND biz_date_end >=  '2016.01.21' AND master_type ='armaster';
SELECT 1,22,'2016.01.21','02000',SUM(last_balance),SUM(charge_ttl),SUM(pay_ttl),SUM(till_balance) FROM master_snapshot WHERE hotel_group_id = 1 AND hotel_id = 108 AND
biz_date_begin < '2016.01.21' AND biz_date_end >=  '2016.01.21' AND master_type <>'armaster';



-- 试算平衡表本日余额
SELECT b.biz_date,b.till_bl,c.amount,b.till_bl-c.amount AS balance FROM (SELECT biz_date,till_bl FROM rep_dai_history WHERE hotel_group_id = 1 AND hotel_id = 108 AND biz_date >='2016.01.20' AND biz_date <='2016.01.25' AND classno = '02000') b,
(SELECT biz_date,amount FROM rep_trial_balance_history WHERE hotel_group_id = 1 AND hotel_id = 108 AND biz_date >='2016.01.20' AND biz_date <='2016.01.25' AND item_type = '50' AND item_code = '20'
) c WHERE b.biz_date = c.biz_date AND b.till_bl <> c.amount; 

SELECT b.biz_date,b.till_bl,c.amount,b.till_bl-c.amount AS balance FROM (SELECT biz_date,till_bl FROM rep_dai_history WHERE hotel_group_id = 1 AND hotel_id = 108 AND biz_date >='2016.01.20' AND biz_date <='2016.01.25' AND classno = '02000') b,
(SELECT biz_date,amount FROM rep_trial_balance_history WHERE hotel_group_id = 1 AND hotel_id = 108 AND biz_date >='2016.01.20' AND biz_date <='2016.01.25' AND item_type = '50' AND item_code = '10'
) c WHERE b.biz_date = c.biz_date AND b.till_bl <> c.amount; 

SELECT * FROM rep_trial_balance_history WHERE hotel_group_id = 1 AND hotel_id = 108 AND biz_date = '2016.01.21'
ORDER BY item_type,item_code;

 

SELECT -214251.50+808607.75  594356.25
-- 01.21日本日余额不对修复
-- 更新当天
UPDATE rep_trial_balance_history SET amount = amount-2000,amount_m = amount_m-2000,amount_y = amount_y-2000
WHERE hotel_group_id = 1 AND hotel_id = 108 AND biz_date = '2016.01.21'
AND ((item_type = '40' AND item_code = '9001') OR (item_type = '40' AND item_code = '}}}}}'))
ORDER BY item_type,item_code;

UPDATE rep_trial_balance_history SET amount = amount-2000,amount_m = amount_m-2000,amount_y = amount_y-2000
WHERE hotel_group_id = 1 AND hotel_id = 108 AND biz_date = '2016.01.21'
AND item_type = '50' AND item_code IN('00','10','20');


UPDATE rep_trial_balance_history SET amount_m = amount_m-2000,amount_y = amount_y-2000
WHERE hotel_group_id = 1 AND hotel_id = 108 AND biz_date > '2016.01.21'
AND ((item_type = '40' AND item_code = '9001') OR (item_type = '40' AND item_code = '}}}}}'))
ORDER BY item_type,item_code;

UPDATE rep_trial_balance_history SET amount_m = amount_m-2000,amount_y = amount_y-2000
WHERE hotel_group_id = 1 AND hotel_id = 108 AND biz_date > '2016.01.21'
AND item_type = '50' AND item_code IN('00','10','20');

SELECT * FROM rep_trial_balance_history WHERE hotel_group_id = 1 AND hotel_id = 108 AND biz_date = '2016.01.22'
ORDER BY item_type,item_code; 

UPDATE rep_trial_balance_history SET amount = amount-2000,amount_m = amount_m-2000,amount_y = amount_y-2000
WHERE hotel_group_id = 1 AND hotel_id = 108 AND biz_date = '2016.01.22'
AND item_type = '10' AND item_code IN('*');


UPDATE rep_trial_balance_history SET amount = amount-2000,amount_m = amount_m-2000,amount_y = amount_y-2000
WHERE hotel_group_id = 1 AND hotel_id = 108 AND biz_date = '2016.01.22'
AND item_type = '50' AND item_code IN('10','}}}}}');

SELECT * FROM rep_trial_balance_history WHERE hotel_group_id = 1 AND hotel_id = 108 AND biz_date = '2016.01.23'
ORDER BY item_type,item_code; 
 