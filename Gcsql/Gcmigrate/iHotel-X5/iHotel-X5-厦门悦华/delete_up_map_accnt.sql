DELETE   a  FROM guest_base a,up_map_accnt b WHERE  
a.hotel_group_id = 1 AND a.hotel_id = 0 AND b.hotel_group_id = 1 AND b.hotel_id = 1
AND b.accnt_type = 'GUEST_FIT' AND   a.id =  b.accnt_new;

DELETE   a  FROM guest_link_base a,up_map_accnt b WHERE  
a.hotel_group_id = 1 AND a.hotel_id = 0 AND b.hotel_group_id = 1 AND b.hotel_id = 1
AND b.accnt_type = 'GUEST_FIT' AND   a.id =  b.accnt_new;	
	
DELETE   a  FROM guest_link_addr a,up_map_accnt b WHERE  
a.hotel_group_id = 1 AND a.hotel_id = 0 AND b.hotel_group_id = 1 AND b.hotel_id = 1
AND b.accnt_type = 'GUEST_FIT' AND   a.guest_id =  b.accnt_new;	

DELETE   a  FROM guest_type a,up_map_accnt b WHERE  
a.hotel_group_id = 1 AND a.hotel_id = 0 AND b.hotel_group_id = 1 AND b.hotel_id = 1
AND b.accnt_type = 'GUEST_FIT' AND   a.guest_id =  b.accnt_new;	

DELETE   a  FROM guest_type a,up_map_accnt b WHERE  
a.hotel_group_id = 1 AND a.hotel_id = 1 AND b.hotel_group_id = 1 AND b.hotel_id = 1
AND b.accnt_type = 'GUEST_FIT' AND   a.guest_id =  b.accnt_new;	

DELETE   a  FROM guest_prefer a,up_map_accnt b WHERE  
a.hotel_group_id = 1 AND a.hotel_id = 1 AND b.hotel_group_id = 1 AND b.hotel_id = 1
AND b.accnt_type = 'GUEST_FIT' AND   a.guest_id =  b.accnt_new;	


DELETE   a  FROM guest_production a,up_map_accnt b WHERE  
a.hotel_group_id = 1 AND a.hotel_id = 0 AND b.hotel_group_id = 1 AND b.hotel_id = 1
AND b.accnt_type = 'GUEST_FIT' AND   a.guest_id =  b.accnt_new;	

DELETE   a  FROM guest_production a,up_map_accnt b WHERE  
a.hotel_group_id = 1 AND a.hotel_id = 1 AND b.hotel_group_id = 1 AND b.hotel_id = 1
AND b.accnt_type = 'GUEST_FIT' AND   a.guest_id =  b.accnt_new;	

-- 团队
DELETE   a  FROM guest_base a,up_map_accnt b WHERE  
a.hotel_group_id = 1 AND a.hotel_id = 0 AND b.hotel_group_id = 1 AND b.hotel_id = 1
AND b.accnt_type = 'GUEST_GRP' AND   a.id =  b.accnt_new;

DELETE   a  FROM guest_link_base a,up_map_accnt b WHERE  
a.hotel_group_id = 1 AND a.hotel_id = 0 AND b.hotel_group_id = 1 AND b.hotel_id = 1
AND b.accnt_type = 'GUEST_GRP' AND   a.id =  b.accnt_new;	
	
DELETE   a  FROM guest_link_addr a,up_map_accnt b WHERE  
a.hotel_group_id = 1 AND a.hotel_id = 0 AND b.hotel_group_id = 1 AND b.hotel_id = 1
AND b.accnt_type = 'GUEST_GRP' AND   a.guest_id =  b.accnt_new;	

DELETE   a  FROM guest_type a,up_map_accnt b WHERE  
a.hotel_group_id = 1 AND a.hotel_id = 0 AND b.hotel_group_id = 1 AND b.hotel_id = 1
AND b.accnt_type = 'GUEST_GRP' AND   a.guest_id =  b.accnt_new;	

DELETE   a  FROM guest_type a,up_map_accnt b WHERE  
a.hotel_group_id = 1 AND a.hotel_id = 1 AND b.hotel_group_id = 1 AND b.hotel_id = 1
AND b.accnt_type = 'GUEST_GRP' AND   a.guest_id =  b.accnt_new;	

DELETE   a  FROM guest_prefer a,up_map_accnt b WHERE  
a.hotel_group_id = 1 AND a.hotel_id = 1 AND b.hotel_group_id = 1 AND b.hotel_id = 1
AND b.accnt_type = 'GUEST_GRP' AND   a.guest_id =  b.accnt_new;	


DELETE   a  FROM guest_production a,up_map_accnt b WHERE  
a.hotel_group_id = 1 AND a.hotel_id = 0 AND b.hotel_group_id = 1 AND b.hotel_id = 1
AND b.accnt_type = 'GUEST_GRP' AND   a.guest_id =  b.accnt_new;	

DELETE   a  FROM guest_production a,up_map_accnt b WHERE  
a.hotel_group_id = 1 AND a.hotel_id = 1 AND b.hotel_group_id = 1 AND b.hotel_id = 1
AND b.accnt_type = 'GUEST_GRP' AND   a.guest_id =  b.accnt_new;	

DELETE   a  FROM company_base a,up_map_accnt b WHERE  
a.hotel_group_id = 1 AND a.hotel_id = 0 AND b.hotel_group_id = 1 AND b.hotel_id = 1
AND b.accnt_type = 'COMPANY' AND   a.id =  b.accnt_new;

DELETE   a  FROM company_type a,up_map_accnt b WHERE  
a.hotel_group_id = 1 AND a.hotel_id = 0 AND b.hotel_group_id = 1 AND b.hotel_id = 1
AND b.accnt_type = 'COMPANY' AND   a.company_id =  b.accnt_new;

DELETE   a  FROM company_type a,up_map_accnt b WHERE  
a.hotel_group_id = 1 AND a.hotel_id = 1 AND b.hotel_group_id = 1 AND b.hotel_id = 1
AND b.accnt_type = 'COMPANY' AND   a.company_id =  b.accnt_new;

DELETE   a  FROM company_prefer a,up_map_accnt b WHERE  
a.hotel_group_id = 1 AND a.hotel_id = 0 AND b.hotel_group_id = 1 AND b.hotel_id = 1
AND b.accnt_type = 'COMPANY' AND   a.company_id =  b.accnt_new;

DELETE   a  FROM company_production a,up_map_accnt b WHERE  
a.hotel_group_id = 1 AND a.hotel_id = 0 AND b.hotel_group_id = 1 AND b.hotel_id = 1
AND b.accnt_type = 'COMPANY' AND   a.company_id =  b.accnt_new;

SELECT * FROM up_map_accnt WHERE hotel_group_id = 1 AND hotel_id = 1;

DELETE FROM up_map_accnt WHERE hotel_group_id = 1 AND hotel_id = 1;
 
-- 删除全部客史
DELETE FROM guest_base;
DELETE FROM guest_link_base;
DELETE FROM guest_link_addr;
DELETE FROM guest_type;
DELETE FROM guest_prefer;
DELETE FROM guest_production; 
-- 删除全部协议单位
DELETE FROM company_base;
DELETE FROM company_type;
DELETE FROM company_prefer;
DELETE FROM company_production;

SELECT COUNT(1) FROM up_map_accnt WHERE accnt_type = 'GUEST_FIT';
SELECT COUNT(1) FROM up_map_accnt WHERE accnt_type = 'GUEST_GRP';

SELECT * FROM master_base;


SELECT * FROM master_base WHERE hotel_group_id = 1 AND hotel_id = 1 AND rsv_class = 'H';