DELETE   a  FROM member_base a, migrate_xx.membercard b WHERE  
a.hotel_group_id = 2 AND a.hotel_id = 0 AND
a.id =  b.member_id;

DELETE   a  FROM member_link_base a, migrate_xx.membercard b WHERE  
a.hotel_group_id = 2 AND a.hotel_id = 0 AND
a.id =  b.member_id;	
	
DELETE   a  FROM member_link_addr a, migrate_xx.membercard b WHERE  
a.hotel_group_id = 2 AND a.hotel_id = 0 AND
a.member_id =  b.member_id;	

DELETE   a  FROM member_type a, migrate_xx.membercard b WHERE  
a.hotel_group_id = 2 AND a.hotel_id = 0 AND
a.member_id =  b.member_id;	

DELETE   a  FROM member_prefer a, migrate_xx.membercard b WHERE  
a.hotel_group_id = 2 AND a.hotel_id = 0 AND
a.member_id =  b.member_id;	


DELETE   a  FROM member_web a, migrate_xx.membercard b WHERE  
a.hotel_group_id = 2 AND a.hotel_id = 0 AND
a.member_id =  b.member_id;	
 
DELETE   a  FROM card_base a, migrate_xx.membercard b WHERE  
a.hotel_group_id = 2 AND a.hotel_id = 9 AND
a.member_id =  b.member_id;	

DELETE   a  FROM card_point a, migrate_xx.membercard b WHERE  
a.hotel_group_id = 2 AND a.hotel_id = 9 AND
a.card_no =  b.card_id;	
 
DELETE   a  FROM card_account_master a, migrate_xx.membercard b WHERE  
a.hotel_group_id = 2 AND a.hotel_id = 0 AND
a.card_id =  b.card_id AND a.member_id = b.member_id;	
 
DELETE   a  FROM card_account a, migrate_xx.membercard b WHERE  
a.hotel_group_id = 2 AND a.hotel_id = 9 AND 
a.card_id =  b.card_id;	