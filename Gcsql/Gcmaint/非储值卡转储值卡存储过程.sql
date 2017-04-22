DROP PROCEDURE IF EXISTS add_card_account_master_transfer;
DELIMITER $$
CREATE DEFINER=`root`@`%`PROCEDURE  add_card_account_master_transfer(
	IN  arg_hotel_group_id BIGINT(16), -- 集团代码
	IN  arg_card_type VARCHAR(30), -- 会员计划
	OUT arg_ret INT,	 -- 返回执行状态 1=成功 0=失败 
	OUT arg_msg VARCHAR(255) -- 返回信息
	)
SQL SECURITY INVOKER -- 调用者模式
BEGIN
-- -----------------------------------------
-- 非储值卡转储值卡，调用的存储过程
-- ------------------------------------------------------------------------------------------------
-- 2016.03.22 陈剑培 存储过程初次编写
-- ------------------------------------------------------------------------------------------------
DECLARE var_name VARCHAR(60);
DECLARE var_tag VARCHAR(10);
DECLARE var_create_user VARCHAR(20);
DECLARE var_modify_user VARCHAR(20);
DECLARE var_create_datetime DATETIME;
DECLARE var_modify_dateTime DATETIME;
DECLARE var_is_account CHAR(2);

SET var_name ='主账户';
SET var_tag = 'BASE';
SET var_modify_user = 'ADMIN';
SET var_modify_dateTime = NOW();
SET arg_ret = 1, arg_msg = 'OK';
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
SET var_is_account = (SELECT is_account FROM card_type WHERE hotel_group_id = arg_hotel_group_id AND CODE =arg_card_type);

IF var_is_account = 'F' THEN 
	UPDATE card_type SET is_account='T' WHERE CODE=arg_card_type AND hotel_group_id =arg_hotel_group_id;
END IF;

INSERT INTO card_account_master(hotel_group_id,hotel_id,card_Id,member_id,NAME,tag,create_user,create_datetime,modify_user,modify_datetime)
SELECT cb.hotel_group_id,0,cb.inner_card_no,cb.member_id,var_name,var_tag,cb.create_user,cb.create_datetime,var_modify_user,var_modify_dateTime 
	FROM card_base cb LEFT JOIN card_account_master cam 
	ON cb.`inner_card_no` = cam.`card_id` AND cb.`hotel_group_id` = cam.hotel_group_id 
	WHERE cb.card_type = arg_card_type AND cb.`hotel_group_id` = arg_hotel_group_id AND cam.`id` IS NULL ORDER BY cb.id;


END$$

CALL add_card_account_master_transfer(6,'HYK',@A,@B);