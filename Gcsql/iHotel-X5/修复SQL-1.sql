ar ���ñ��û����ʾ  accredit -- extraflag
Ԥ�����绰����
��Ҫ���ͷ�����-- ���ձ�

up_map_accnt.accnt_old, accnt_new -- accnt_type in (masster_si,_r, consume )
master.srqs, amenti.., feature 
master_base 

�������Ӧ - ��ȫһ�£�����û�н��ж���ת�� -- �Ǹ��ʻ������⣿- �˲�û����  
�г����Ӧ - ��ȫһ�£�����û�н��ж���ת�� -- ���µĶ��ձ�
��Դ���Ӧ - ��ȫһ�£�����û�н��ж���ת��

���� - Ԥ������ 
Ԥ��������û������2 


Ԥ���Ҳ���Ԥ���� 

Ԥ��״̬������

ҵ��
��Ա 

��ʷ����Ŀǰ��Ҫ��֤����������Щҵ���õĿͻ���Ϣû�е��룬����  ��Ф�� ��ϵͳ��5�������ǽ�������9290250���� 
�ͻ����룺��Щ��ַ ʡ�ݳ���û�е���� 
Ǳ��״̬û�е��� 
Э�鹫˾������Ϣ�ģ���ϵ�ˡ�ְ������ϲ�ã�������������ϵ��
��ϲ�ѯȱ�����1�Ĳ�ѯ��Ŀ 
Э�鹫˾�༭��ȱ��class2-4�ı༭ 
�״���ס�������ס 

����Աֻ�ܲ鿴�Լ���
Э�鹫˾�б����ӱ�ǩ - �Ŷӻ��� -- ��Ҫ���뵵��������
ҵ������Ҫ���ˢ�¡�1-12�·��÷�����������

�������Ӳ������������ظ����� 
��ar���������渶������á�C�����ģ��ʺſ���û����д���߲��淶��ȡ����ʱ��ᱨ����


�ͷ�״̬�ؽ�proc - ����ʤ
���͵���- ֤��һ����������һ������ʧ�� 
guest -> company 

�ͷ�����ҳ��- ������˫����ϸ���ԣ�������Ϣ����ȷ-�°벿�� 

ˮ����-�������� �ʻ���- 
�绰�ӿ�- �ƷѲ�׼�� ©���� 
����¥������� -- ���д��ȡ������sql 

SELECT  * FROM rsv_src AS a WHERE hotel_group_id = 2 AND hotel_id = 9 AND occ_flag IN ('RF','RG') AND DATE(rsv_arr_date) <> arr_date;

SELECT  * FROM rsv_src AS a WHERE hotel_group_id = 2 AND hotel_id = 9 AND occ_flag IN ('RF','RG') AND DATE(rsv_dep_date) <> dep_date;

update rsv_src set rsv_arr_date = CONCAT(DATE_FORMAT(rsv_arr_date,'%Y:%m:%d'),' ','18:00:00') FROM rsv_src WHERE DATE_FORMAT(rsv_arr_date,'%H:%i:%s') = '00:00:00';
update rsv_src set rsv_dep_date = CONCAT(DATE_FORMAT(rsv_dep_date,'%Y:%m:%d'),' ','12:00:00') FROM rsv_src WHERE DATE_FORMAT(rsv_dep_date,'%H:%i:%s') = '00:00:00';



-- ����ԱЭ�鹫˾��ʾ���� 
SELECT a.* FROM company_base a, company_type b 
WHERE a.id=b.company_id
	AND b.hotel_group_id=2 AND b.hotel_id=9
	AND b.saleman=IFNULL((SELECT MIN(x.code) FROM sales_man X, sales_man_business Y 
							WHERE x.hotel_group_id=2 AND x.hotel_id=0
								AND y.hotel_group_id=2 AND y.hotel_id=9
								AND x.code=y.sales_man AND y.login_user='SM02'), '')
; 

DESC company_type; 
SELECT id, saleman FROM company_type WHERE hotel_id=9 AND saleman<>'';
SELECT * FROM USER WHERE NAME='������';
SELECT  * FROM sales_man_business WHERE login_user='SM02'
SELECT  * FROM sales_man WHERE CODE='SM02'

-- ar�������� 
SELECT a.id, a.arno, b.name, a.credit, 
	IFNULL((SELECT SUM(c.amount) FROM accredit c 
				WHERE c.hotel_group_id=2 AND c.hotel_id=9
					AND c.accnt_type='A' AND c.accnt=a.id),0) AS mmm
	FROM ar_master a, ar_master_guest b
	WHERE a.hotel_group_id=2 AND a.hotel_id=9 
		AND b.hotel_group_id=2 AND b.hotel_id=9
		AND a.id=b.id;


UPDATE ar_master a, 
	(SELECT accnt, SUM(amount) AS credit FROM accredit 
		WHERE hotel_group_id=2 AND hotel_id=9 AND accnt_type='A'
			GROUP BY accnt
	) b SET a.credit=IFNULL(b.credit,0)
	WHERE a.hotel_group_id=2 AND a.hotel_id=9 
		AND a.id=b.accnt;

SELECT a.id, a.credit, b.amount
FROM ar_master a, 
	(SELECT accnt, SUM(amount) AS amount FROM accredit 
		WHERE hotel_group_id=2 AND hotel_id=9 AND accnt_type='A'
			GROUP BY accnt
	) b 
	WHERE a.hotel_group_id=2 AND a.hotel_id=9 
		AND a.id=b.accnt;

DESC ar_master; 

SELECT * FROM accredit; 

-- ������Ϣ���� 
UPDATE master_base SET link_id=id 
	WHERE hotel_group_id=2 AND hotel_id=9 ;  

UPDATE master_base a, up_map_accnt b, migrate_db.master c, up_map_accnt d
SET a.link_id=d.accnt_new 
	WHERE a.hotel_group_id=2 AND a.hotel_id=9 
	AND b.hotel_group_id=2 AND b.hotel_id=9 
	AND d.hotel_group_id=2 AND d.hotel_id=9 
	AND a.id=b.accnt_new AND b.accnt_type IN ('master_si', 'master_r', 'consume') 
	AND c.pcrec=d.accnt_old AND d.accnt_type IN ('master_si', 'master_r', 'consume') 
	AND b.accnt_old=c.accnt AND c.pcrec<>''; 	
	
UPDATE master_base SET pkg_link_id=link_id 
	WHERE hotel_group_id=2 AND hotel_id=9; 

-- ���֤���룬���������������ȡ�������� 
SELECT * FROM master_guest WHERE id_no='440106196410060392'; NAME='���';
DESC master_guest; 

SELECT * FROM guest WHERE id_no='440106196410060392';
SELECT * FROM guest_base WHERE id=1566717;

����Ա��ʾЭ�鹫˾��Χ
SELECT a.id,b.sta,a.name,a.name2,b.code1,b.code2,b.code3,a.nation,a.nation AS nationDescript,b.valid_begin,b.valid_end,a.phone,a.fax,a.linkman1,b.saleman,c.name saleman_name,
CASE WHEN d.times_in > 120 THEN '��Ҫ' WHEN  d.times_in <= 120 AND  d.times_in > 60 THEN '��' ELSE '��' END AS imp_level
FROM company_base a,company_type b 
LEFT JOIN sales_man c ON c.hotel_group_id = 2 AND c.hotel_id = 0 AND b.saleman = c.code 
LEFT JOIN company_production d ON d.hotel_group_id = b.hotel_group_id AND d.hotel_id = b.hotel_id AND b.company_id = d.company_id 
WHERE (1=1) AND a.id = b.company_id AND a.hotel_group_id = 2  AND b.hotel_group_id = 2 AND b.hotel_id = 9  
AND (b.saleman = 'SM02' OR
	NOT EXISTS (SELECT 1 FROM sales_man X,sales_man_business Y
		WHERE x.hotel_group_id = 2 AND x.hotel_id = 0
		   AND y.hotel_group_id = 2 
                   AND y.hotel_id = 9 
                   AND x.code = y.sales_man
                   AND y.login_user = 'SM02'))
 ORDER BY b.sta DESC,b.modify_datetime DESC

-- C��ar�ʻ�������ȥ������ 
SELECT a.id,b.name,a.arno, b.coding, c.card_no 
FROM ar_master a, ar_master_guest b, accredit c 
WHERE a.hotel_group_id=2 AND a.hotel_id=9 
	AND b.hotel_group_id=2 AND b.hotel_id=9 
	AND c.hotel_group_id=2 AND c.hotel_id=9 
	AND a.id=b.id AND a.id=c.accnt AND c.accnt_type='A'
	AND c.ta_code='9930'; 

UPDATE ar_master a, ar_master_guest b, accredit c 
SET c.card_no = ''
WHERE a.hotel_group_id=2 AND a.hotel_id=9 
	AND b.hotel_group_id=2 AND b.hotel_id=9 
	AND c.hotel_group_id=2 AND c.hotel_id=9 
	AND a.id=b.id AND a.id=c.accnt AND c.accnt_type='A'
	AND c.ta_code='9930'; 


-- ���� Э�鹫˾��ַ��ʡ�� state 
INSERT up_map_code 
	SELECT 2, 9, 'prvcode', CODE, descript, '', descript 
	FROM migrate_db.prvcode
	WHERE country='CN'; 
	
SELECT a.code_old, a.code_new, b.code 
	FROM up_map_code a, code_province b
	WHERE a.hotel_group_id=2 AND a.hotel_id=9 
		AND a.code_old_des=b.descript AND a.cat='prvcode';

UPDATE up_map_code a, code_province b
	SET a.code_new=b.code 
	WHERE a.hotel_group_id=2 AND a.hotel_id=9 
		AND a.code_old_des=b.descript AND a.cat='prvcode';
	
SELECT * FROM up_map_code WHERE hotel_id=9 AND cat='prvcode' AND code_new=''; 
SELECT * FROM migrate_db.prvcode ; 

SELECT id, NAME, state, country, city, division, street FROM company_base WHERE hotel_group_id=2 AND hotel_id=0; 

UPDATE company_base a, up_map_code b 
SET a.state=b.code_new
WHERE a.hotel_group_id=2 AND a.hotel_id=0 
	AND b.hotel_group_id=2 AND b.hotel_id=9
	AND a.state=b.code_old AND b.cat='prvcode'; 
	
	
-- �޲�ar������ϵ��
UPDATE ar_master_guest a, up_map_accnt b, migrate_db.ar_master c, migrate_db.guest d
SET a.linkman=d.liason 
WHERE a.hotel_group_id=2 AND a.hotel_id=9 
	AND b.hotel_group_id=2 AND b.hotel_id=9 
	AND a.id=b.accnt_new AND b.accnt_old=c.accnt AND c.haccnt=d.no 
	AND b.accnt_type ='armst'
	AND a.linkman='' AND d.liason<>'';
	
-- �޸������绰
UPDATE master_guest a, up_map_accnt b, migrate_db.master c SET a.phone=c.phone 
WHERE a.hotel_group_id=2 AND a.hotel_id=9 
	AND b.hotel_group_id=2 AND b.hotel_id=9 
	AND a.id=b.accnt_new AND b.accnt_old=c.accnt 
	AND b.accnt_type IN ('master_si', 'master_r', 'comsume')
	AND a.phone='' AND c.phone <>'';
	
SELECT * FROM MASTER WHERE bdate='2013.12.31' 

SELECT a.id, c.accnt, a.rmno, a.ratecode new1, c.ratecode old1 , d.code_new oldnew1
FROM master_base a, up_map_accnt b, migrate_db.master c, up_map_code d  
WHERE a.hotel_group_id=2 AND a.hotel_id=9 
	AND b.hotel_group_id=2 AND b.hotel_id=9 
	AND d.hotel_group_id=2 AND d.hotel_id=9 
	AND a.id=b.accnt_new AND b.accnt_old=c.accnt 
	AND b.accnt_type IN ('master_si', 'master_r')
	AND d.cat='ratecode' AND c.ratecode=d.code_old
	AND a.ratecode<>d.code_new; 
	


-- SELECT a.id, c.accnt, a.rmno, a.specials, c.srqs
-- SELECT a.id, c.accnt, a.rmno, a.amenities, c.amenities
-- SELECT a.id, c.accnt, a.rmno, a.src, c.src
SELECT a.id, c.accnt, a.rmno, a.market new1, c.market old1 , d.code_new oldnew1
FROM master_base a, up_map_accnt b, migrate_db.master c, up_map_code d  
WHERE a.hotel_group_id=2 AND a.hotel_id=9 
	AND b.hotel_group_id=2 AND b.hotel_id=9 
	AND d.hotel_group_id=2 AND d.hotel_id=9 
	AND a.id=b.accnt_new AND b.accnt_old=c.accnt 
	AND b.accnt_type IN ('master_si', 'master_r', 'consume')
	AND d.cat='mktcode' AND c.market=d.code_old
	AND a.market<>d.code_new; 

-- SELECT a.id, c.accnt, a.rmno, a.market new1, c.market old1 , d.code_new oldnew1
UPDATE master_base a, up_map_accnt b, migrate_db.master c, up_map_code d 
SET a.market=d.code_new  
WHERE a.hotel_group_id=2 AND a.hotel_id=9 
	AND b.hotel_group_id=2 AND b.hotel_id=9 
	AND d.hotel_group_id=2 AND d.hotel_id=9 
	AND a.id=b.accnt_new AND b.accnt_old=c.accnt 
	AND b.accnt_type IN ('master_si', 'master_r', 'consume')
	AND d.cat='mktcode' AND c.market=d.code_old
	AND a.market<>d.code_new; 	

UPDATE rsv_src a, up_map_accnt b, migrate_db.master c, up_map_code d 
SET a.market=d.code_new  
WHERE a.hotel_group_id=2 AND a.hotel_id=9 
	AND b.hotel_group_id=2 AND b.hotel_id=9 
	AND d.hotel_group_id=2 AND d.hotel_id=9 
	AND a.accnt=b.accnt_new AND b.accnt_old=c.accnt 
	AND b.accnt_type IN ('master_si', 'master_r')
	AND d.cat='mktcode' AND c.market=d.code_old
	AND a.market<>d.code_new; 	

UPDATE company_type a, up_map_accnt b, migrate_db.guest c, up_map_code d 
SET a.market=d.code_new  
WHERE a.hotel_group_id=2 AND a.hotel_id=0 
	AND b.hotel_group_id=2 AND b.hotel_id=9 
	AND d.hotel_group_id=2 AND d.hotel_id=9 
	AND a.company_id=b.accnt_new AND b.accnt_old=c.no 
	AND b.accnt_type IN ('company')
	AND d.cat='mktcode' AND c.market=d.code_old
	AND a.market<>d.code_new; 	

UPDATE guest_type a, up_map_accnt b, migrate_db.guest c, up_map_code d 
SET a.market=d.code_new  
WHERE a.hotel_group_id=2 AND a.hotel_id=9 
	AND b.hotel_group_id=2 AND b.hotel_id=9 
	AND d.hotel_group_id=2 AND d.hotel_id=9 
	AND a.guest_id=b.accnt_new AND b.accnt_old=c.no 
	AND b.accnt_type IN ('guest')
	AND d.cat='mktcode' AND c.market=d.code_old
	AND a.market<>d.code_new; 	

UPDATE master_base a, up_map_accnt b, migrate_db.master c 
SET a.amenities = c.amenities
WHERE a.hotel_group_id=2 AND a.hotel_id=9 
	AND b.hotel_group_id=2 AND b.hotel_id=9 
	AND a.id=b.accnt_new AND b.accnt_old=c.accnt 
	AND b.accnt_type IN ('master_si', 'master_r')
	AND a.amenities<>c.amenities; 


-- �޲�����ǩ֤���뾳�ڰ��� 
UPDATE master_guest a, up_map_accnt b, migrate_db.master c, migrate_db.guest d 
SET a.visa_type=d.visaid, a.visa_end=d.visaend, a.enter_port=d.rjplace, a.enter_date_end=d.rjdate
WHERE a.hotel_group_id=2 AND a.hotel_id=9 
	AND b.hotel_group_id=2 AND b.hotel_id=9 
	AND a.id=b.accnt_new AND b.accnt_old=c.accnt 
	AND c.haccnt=d.no
	AND b.accnt_type IN ('master_si', 'master_r', 'comsume')
	AND d.rjplace <>'';
	
	
UPDATE master_guest a, up_map_accnt b, migrate_yw.master c, migrate_yw.guest d 
SET a.enter_date_end=d.visaend
WHERE a.hotel_group_id=2 AND a.hotel_id=14 
	AND b.hotel_group_id=2 AND b.hotel_id=14 
	AND a.id=b.accnt_new AND b.accnt_old=c.accnt 
	AND c.haccnt=d.no
	AND b.accnt_type IN ('master_si', 'master_r', 'comsume')
	AND d.rjplace <>'';

-- �޲������ͷ����� 
UPDATE master_guest a, up_map_accnt b, migrate_db.master c, migrate_db.guest d SET a.feature=d.feature 
WHERE a.hotel_group_id=2 AND a.hotel_id=9 
	AND b.hotel_group_id=2 AND b.hotel_id=9 
	AND a.id=b.accnt_new AND b.accnt_old=c.accnt 
	AND c.haccnt=d.no
	AND b.accnt_type IN ('master_si', 'master_r', 'comsume')
	AND a.feature='' AND d.feature <>'';

-- �޲�ar������ϵ��
UPDATE ar_master_guest a, up_map_accnt b, migrate_db.ar_master c, migrate_db.guest d
SET a.linkman=d.liason 
WHERE a.hotel_group_id=2 AND a.hotel_id=9 
	AND b.hotel_group_id=2 AND b.hotel_id=9 
	AND a.id=b.accnt_new AND b.accnt_old=c.accnt AND c.haccnt=d.no 
	AND b.accnt_type ='armst'
	AND a.linkman='' AND d.liason<>'';	



	
	
SELECT DISTINCT cat FROM up_map_code ; 
-- mktcode, srccode,ratecode,channel, idcode, paymth, pccode, 
--  rmtype, restype, salesman, package, compcode1 

SELECT DISTINCT accnt_type FROM up_map_accnt ; 


    UPDATE master_base a, up_map_accnt b, migrate_db.master c,up_map_accnt d 
    SET a.link_id=d.accnt_new 
		WHERE a.hotel_group_id=2 AND a.hotel_id=9 
		AND b.hotel_group_id=2 AND b.hotel_id=9 
		AND d.hotel_group_id=2 AND d.hotel_id = 9 
		AND c.pcrec = d.accnt_old 
		AND a.id=b.accnt_new 
		AND b.accnt_type ='master_si' AND a.sta IN ('I','S','O') 
		AND d.accnt_type='master_si' AND b.accnt_old=c.accnt AND c.pcrec<>''; 	
		
	UPDATE master_base SET link_id=id WHERE hotel_group_id=2 AND hotel_id=9 AND sta IN ('I','S','O') AND (link_id=0 OR link_id IS NULL);  
	UPDATE master_base SET pkg_link_id=link_id WHERE hotel_group_id=2 AND hotel_id=9 AND sta IN ('I','S','O'); 

UPDATE master_base SET link_id=id 
	WHERE hotel_group_id=2 AND hotel_id=9 ;  

UPDATE master_base a, up_map_accnt b, migrate_db.master c, up_map_accnt d
SET a.link_id=d.accnt_new 
	WHERE a.hotel_group_id=2 AND a.hotel_id=9 
	AND b.hotel_group_id=2 AND b.hotel_id=9 
	AND d.hotel_group_id=2 AND d.hotel_id=9 
	AND a.id=b.accnt_new AND b.accnt_type IN ('master_si', 'master_r', 'consume') 
	AND c.pcrec=d.accnt_old AND d.accnt_type IN ('master_si', 'master_r', 'consume') 
	AND b.accnt_old=c.accnt AND c.pcrec<>''; 	
	
UPDATE master_base SET pkg_link_id=link_id 
	WHERE hotel_group_id=2 AND hotel_id=9; 

SELECT a.id, c.accnt, c.pcrec 	
FROM master_base a, up_map_accnt b, migrate_db.master c
	WHERE a.hotel_group_id=2 AND a.hotel_id=9 
	AND b.hotel_group_id=2 AND b.hotel_id=9 
	AND a.id=b.accnt_new AND b.accnt_type IN ('master_si', 'master_r', 'consume') 
	AND b.accnt_old=c.accnt AND c.pcrec='F312300134'; 	

SELECT id, link_id FROM master_base WHERE id IN (19298, 19299);

SELECT * FROM up_map_code WHERE cat='ratecode' ORDER BY code_old; 
SELECT * FROM migrate_db.master WHERE ratecode='FIT';


SELECT * FROM sys_error WHERE hotel_group_id =2 AND hotel_id = 9 ORDER BY id DESC LIMIT 20


UPDATE master_base a ,up_map_code b SET a.rmtype = b.code_new WHERE a.hotel_group_id=2 AND a.hotel_id=9 AND b.hotel_group_id=2 AND b.hotel_id = 9 AND b.cat = 'rmtype' AND a.rmtype = b.code_old;
UPDATE rsv_src a ,	  up_map_code b SET a.rmtype = b.code_new 
WHERE a.hotel_group_id=2 AND a.hotel_id=9 AND b.hotel_group_id=2 
AND b.hotel_id = 9 AND b.cat = 'rmtype' AND a.rmtype = b.code_old;



SELECT * FROM rsv_src AS a WHERE hotel_group_id = 2 AND hotel_id = 9 
AND LEFT(rmno,1) <> '#' AND rmno <> ''
AND  EXISTS (SELECT 1 FROM room_no WHERE hotel_group_id = 2 AND hotel_id=  9
AND CODE = a.rmno AND rmtype <> a.rmtype)

SELECT a.rmno, a.rmtype srv_rmtype, b.rmtype no_rmtype, c.code_old code_old 
FROM rsv_src a, room_no b, up_map_code c  
WHERE a.hotel_group_id = 2 AND a.hotel_id = 9 
	AND b.hotel_group_id = 2 AND b.hotel_id = 9 
	AND c.hotel_group_id = 2 AND c.hotel_id=9 
	AND a.rmno=b.code AND a.rmtype<>b.rmtype 
	AND a.rmtype=c.code_new AND c.cat='rmtype'; 

SELECT * FROM room_type WHERE hotel_id=9 AND is_halt='F'; 
SELECT * FROM room_no WHERE CODE='802' AND hotel_id=9;
SELECT * FROM up_map_code WHERE hotel_id=9 AND code_old='hsd';

SELECT * FROM rsv_src WHERE rmno='802';

SELECT code_old, COUNT(1) FROM up_map_code 
	WHERE hotel_id=9 AND cat='rmtype' GROUP BY code_old ; 
SELECT code_new, COUNT(1) FROM up_map_code 
	WHERE hotel_id=9 AND cat='rmtype' GROUP BY code_new; 



SELECT a.id, b.name, b.coding, a.arno, a.building FROM ar_master a, ar_master_guest b 
WHERE a.hotel_group_id=2 AND a.hotel_id=9 
	AND b.hotel_group_id=2 AND b.hotel_id=9 
	AND a.id=b.id AND a.id=26886; 
	
DESC ar_master;
 
SELECT id, arno, building FROM ar_master WHERE hotel_group_id=2 AND hotel_id=9;
UPDATE ar_master SET building=arno WHERE hotel_group_id=2 AND hotel_id=9;

UPDATE ar_master a, ar_master_guest b 
SET a.arno=b.coding
WHERE a.hotel_group_id=2 AND a.hotel_id=9 
	AND b.hotel_group_id=2 AND b.hotel_id=9 
	AND a.id=b.id; 

UPDATE ar_master a, ar_master_guest b 
SET b.coding=a.building
WHERE a.hotel_group_id=2 AND a.hotel_id=9 
	AND b.hotel_group_id=2 AND b.hotel_id=9 
	AND a.id=b.id; 


SELECT * FROM room_no WHERE hotel_id = 9 AND CODE IN ('1205','1203')


UPDATE ar_account a,up_map_accnt b,migrate_db.ar_detail c SET a.create_datetime=c.log_date
	WHERE a.hotel_group_id=2 AND a.hotel_id=9 AND b.hotel_group_id=2 AND b.hotel_id=9
	AND a.accnt=b.accnt_new AND b.accnt_old=c.accnt AND a.number=c.number AND b.accnt_type='armst'
	
SELECT a.create_datetime,c.log_date 
FROM ar_account a,up_map_accnt b,migrate_db.ar_detail c
	WHERE a.hotel_group_id=2 AND a.hotel_id=9 
		AND b.hotel_group_id=2 AND b.hotel_id=9
		AND a.accnt=b.accnt_new AND b.accnt_old=c.accnt 
		AND a.number=c.number AND b.accnt_type='armst' AND a.accnt='26651'

SELECT * FROM ar_account WHERE hotel_group_id=2 AND hotel_id=9 
	AND accnt=26651 AND number=121;
SELECT * FROM ar_detail WHERE hotel_group_id=2 AND hotel_id=9 
	AND ar_accnt=26651 AND ar_inumber=121; 
	
SELECT * FROM ar_account WHERE hotel_group_id=2 AND hotel_id=9 
	AND accnt=26651 AND number=121;
	
SELECT a.accnt, a.number, a.act_tag, a.create_datetime, b.modify_datetime 
FROM ar_account a, ar_detail b 
	WHERE a.hotel_group_id=2 AND a.hotel_id=9 
		AND b.hotel_group_id=2 AND b.hotel_id=9 
		AND a.accnt=26651 
		AND a.accnt=b.ar_accnt AND a.number=b.ar_inumber 
		AND b.ar_subtotal='T' AND b.ar_pnumber=0;



	
