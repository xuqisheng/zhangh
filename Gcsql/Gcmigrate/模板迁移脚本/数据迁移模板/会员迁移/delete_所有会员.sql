DELETE   a  FROM member_base a WHERE  a.hotel_group_id = 2;
DELETE   a  FROM member_link_base a WHERE  a.hotel_group_id = 2;	
DELETE   a  FROM member_link_addr a WHERE  a.hotel_group_id = 2;
DELETE   a  FROM member_type a WHERE  a.hotel_group_id = 2;
DELETE   a  FROM member_prefer a WHERE a.hotel_group_id = 2;
DELETE   a  FROM member_web a WHERE a.hotel_group_id = 2;
DELETE   a  FROM card_base a WHERE a.hotel_group_id = 2;
DELETE   a  FROM card_point a WHERE  a.hotel_group_id = 2; 
DELETE   a  FROM card_account_master a WHERE  a.hotel_group_id = 2;
DELETE   a  FROM card_account a WHERE  a.hotel_group_id = 2;