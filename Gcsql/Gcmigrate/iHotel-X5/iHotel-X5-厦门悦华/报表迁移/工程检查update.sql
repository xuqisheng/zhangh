SELECT master_id,NAME,biz_date_begin,biz_date_end,sta,rmno,last_charge,last_pay,(last_charge - last_pay),last_balance,charge_ttl,pay_ttl,till_charge,till_pay,till_charge - till_pay,till_balance,master_type
FROM master_snapshot
WHERE hotel_group_id = 1
AND hotel_id = 1
AND sta IN ('I','S','O','X','R')
AND (last_balance<>0 OR till_balance<>0 OR charge_ttl<>0 OR pay_ttl<>0)
AND biz_date_begin < '2014.12.07'
AND biz_date_end >= '2014.12.07'
AND ((last_charge - last_pay) <> last_balance OR (till_charge - till_pay) <> till_balance)
ORDER BY master_type DESC,sta,rmno,master_id 

UPDATE master_snapshot SET 
last_charge = last_pay + last_balance,till_charge = till_pay + till_balance
WHERE hotel_group_id = 1
AND hotel_id = 1
AND sta IN ('I','S','O','X','R')
AND (last_balance<>0 OR till_balance<>0 OR charge_ttl<>0 OR pay_ttl<>0)
AND biz_date_begin < '2014.12.07'
AND biz_date_end >= '2014.12.07'
AND ((last_charge - last_pay) <> last_balance OR (till_charge - till_pay) <> till_balance)
AND (last_balance > 0 OR till_balance > 0)
ORDER BY master_type DESC,sta,rmno,master_id 

UPDATE master_snapshot SET 
last_pay = last_charge - last_balance,till_pay = till_charge - till_balance
WHERE hotel_group_id = 1
AND hotel_id = 1
AND sta IN ('I','S','O','X','R')
AND (last_balance<>0 OR till_balance<>0 OR charge_ttl<>0 OR pay_ttl<>0)
AND biz_date_begin < '2014.12.07'
AND biz_date_end >= '2014.12.07'
AND ((last_charge - last_pay) <> last_balance OR (till_charge - till_pay) <> till_balance)
AND (last_balance < 0 OR till_balance < 0)
ORDER BY master_type DESC,sta,rmno,master_id 