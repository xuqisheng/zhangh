DELETE   a  FROM guest_base a,up_map_accnt b WHERE  
a.hotel_group_id = 1 AND a.hotel_id = 0 AND b.hotel_group_id = 1 AND b.hotel_id = 3
AND b.accnt_type = 'GUEST' AND   a.id =  b.accnt_new;

DELETE   a  FROM guest_link_base a,up_map_accnt b WHERE  
a.hotel_group_id = 1 AND a.hotel_id = 0 AND b.hotel_group_id = 1 AND b.hotel_id = 3
AND b.accnt_type = 'GUEST' AND   a.id =  b.accnt_new;	
	
DELETE   a  FROM guest_link_addr a,up_map_accnt b WHERE  
a.hotel_group_id = 1 AND a.hotel_id = 0 AND b.hotel_group_id = 1 AND b.hotel_id = 3
AND b.accnt_type = 'GUEST' AND   a.guest_id =  b.accnt_new;	

DELETE   a  FROM guest_type a,up_map_accnt b WHERE  
a.hotel_group_id = 1 AND a.hotel_id = 0 AND b.hotel_group_id = 1 AND b.hotel_id = 3
AND b.accnt_type = 'GUEST' AND   a.guest_id =  b.accnt_new;	

DELETE   a  FROM guest_type a,up_map_accnt b WHERE  
a.hotel_group_id = 1 AND a.hotel_id = 3 AND b.hotel_group_id = 1 AND b.hotel_id = 3
AND b.accnt_type = 'GUEST' AND   a.guest_id =  b.accnt_new;	

DELETE   a  FROM guest_prefer a,up_map_accnt b WHERE  
a.hotel_group_id = 1 AND a.hotel_id = 3 AND b.hotel_group_id = 1 AND b.hotel_id = 3
AND b.accnt_type = 'GUEST' AND   a.guest_id =  b.accnt_new;	


DELETE   a  FROM guest_production a,up_map_accnt b WHERE  
a.hotel_group_id = 1 AND a.hotel_id = 0 AND b.hotel_group_id = 1 AND b.hotel_id = 3
AND b.accnt_type = 'GUEST' AND   a.guest_id =  b.accnt_new;	

DELETE   a  FROM guest_production a,up_map_accnt b WHERE  
a.hotel_group_id = 1 AND a.hotel_id = 3 AND b.hotel_group_id = 1 AND b.hotel_id = 3
AND b.accnt_type = 'GUEST' AND   a.guest_id =  b.accnt_new;	

DELETE   a  FROM guest_base a,up_map_accnt b WHERE  
a.hotel_group_id = 1 AND a.hotel_id = 0 AND b.hotel_group_id = 1 AND b.hotel_id = 3
AND b.accnt_type = 'GUEST_GRP' AND   a.id =  b.accnt_new;

DELETE   a  FROM guest_link_base a,up_map_accnt b WHERE  
a.hotel_group_id = 1 AND a.hotel_id = 0 AND b.hotel_group_id = 1 AND b.hotel_id = 3
AND b.accnt_type = 'GUEST_GRP' AND   a.id =  b.accnt_new;	
	
DELETE   a  FROM guest_link_addr a,up_map_accnt b WHERE  
a.hotel_group_id = 1 AND a.hotel_id = 0 AND b.hotel_group_id = 1 AND b.hotel_id = 3
AND b.accnt_type = 'GUEST_GRP' AND   a.guest_id =  b.accnt_new;	

DELETE   a  FROM guest_type a,up_map_accnt b WHERE  
a.hotel_group_id = 1 AND a.hotel_id = 0 AND b.hotel_group_id = 1 AND b.hotel_id = 3
AND b.accnt_type = 'GUEST_GRP' AND   a.guest_id =  b.accnt_new;	

DELETE   a  FROM guest_type a,up_map_accnt b WHERE  
a.hotel_group_id = 1 AND a.hotel_id = 3 AND b.hotel_group_id = 1 AND b.hotel_id = 3
AND b.accnt_type = 'GUEST_GRP' AND   a.guest_id =  b.accnt_new;	

DELETE   a  FROM guest_prefer a,up_map_accnt b WHERE  
a.hotel_group_id = 1 AND a.hotel_id = 3 AND b.hotel_group_id = 1 AND b.hotel_id = 3
AND b.accnt_type = 'GUEST_GRP' AND   a.guest_id =  b.accnt_new;	


DELETE   a  FROM guest_production a,up_map_accnt b WHERE  
a.hotel_group_id = 1 AND a.hotel_id = 0 AND b.hotel_group_id = 1 AND b.hotel_id = 3
AND b.accnt_type = 'GUEST_GRP' AND   a.guest_id =  b.accnt_new;	

DELETE   a  FROM guest_production a,up_map_accnt b WHERE  
a.hotel_group_id = 1 AND a.hotel_id = 3 AND b.hotel_group_id = 1 AND b.hotel_id = 3
AND b.accnt_type = 'GUEST_GRP' AND   a.guest_id =  b.accnt_new;	


SELECT * FROM company_base a,up_map_accnt b WHERE  
a.hotel_group_id = 1 AND a.hotel_id = 0 AND b.hotel_group_id = 1 AND b.hotel_id = 3
AND b.accnt_type = 'COMPANY' AND   a.id =  b.accnt_new;


DELETE   a  FROM company_base a,up_map_accnt b WHERE  
a.hotel_group_id = 1 AND a.hotel_id = 0 AND b.hotel_group_id = 1 AND b.hotel_id = 3
AND b.accnt_type = 'COMPANY' AND   a.id =  b.accnt_new;

DELETE   a  FROM company_type a,up_map_accnt b WHERE  
a.hotel_group_id = 1 AND a.hotel_id = 0 AND b.hotel_group_id = 1 AND b.hotel_id = 3
AND b.accnt_type = 'COMPANY' AND   a.company_id =  b.accnt_new;

DELETE   a  FROM company_type a,up_map_accnt b WHERE  
a.hotel_group_id = 1 AND a.hotel_id = 3 AND b.hotel_group_id = 1 AND b.hotel_id = 3
AND b.accnt_type = 'COMPANY' AND   a.company_id =  b.accnt_new;

DELETE   a  FROM company_prefer a,up_map_accnt b WHERE  
a.hotel_group_id = 1 AND a.hotel_id = 0 AND b.hotel_group_id = 1 AND b.hotel_id = 3
AND b.accnt_type = 'COMPANY' AND   a.company_id =  b.accnt_new;

DELETE   a  FROM company_production a,up_map_accnt b WHERE  
a.hotel_group_id = 1 AND a.hotel_id = 0 AND b.hotel_group_id = 1 AND b.hotel_id = 3
AND b.accnt_type = 'COMPANY' AND   a.company_id =  b.accnt_new;

SELECT * FROM up_map_accnt WHERE hotel_group_id = 1 AND hotel_id = 3;

DELETE FROM up_map_accnt WHERE hotel_group_id = 1 AND hotel_id = 3 AND accnt_type = 'COMPANY';
DELETE FROM profile_extra WHERE hotel_group_id = 1 AND hotel_id = 3  AND extra_item = 'RATECODE' AND master_type = 'COMPANY'
SELECT * FROM profile_extra WHERE hotel_group_id = 1 AND hotel_id = 3  

SELECT * FROM company_type WHERE hotel_id = 3 AND valid_begin < '2014.07.07'
 
SELECT company_id,code1,valid_begin,valid_end FROM company_type WHERE hotel_group_id = 1 AND hotel_id = 3 AND code1 <> '' 

  	UPDATE company_type a,up_map_code b SET a.saleman = b.code_new WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.hotel_group_id=2 AND b.hotel_id = 3
  	 AND b.code_old = a.saleman AND b.cat = 'salesman';
 