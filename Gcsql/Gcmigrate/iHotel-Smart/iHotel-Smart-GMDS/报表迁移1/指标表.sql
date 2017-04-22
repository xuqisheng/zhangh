ALTER TABLE audit_impdata ADD audit_index VARCHAR(30) NOT NULL DEFAULT '' AFTER class;

SELECT * FROM migrate_xsw.audit_impdata  WHERE halt = 'F' ORDER BY sequence;

SELECT * FROM rep_audit_index_history a,migrate_xsw.audit_impdata b 
WHERE a.hotel_id = 13 AND a.biz_date ='2014.04.20' AND b.date = '2014.04.20' AND 
a.audit_index = b.audit_index;

UPDATE  rep_audit_index_history a,migrate_xsw.audit_impdata b 
SET a.amount = b.amount,a.amount_m = b.amount_m,a.amount_y = b.amount_y
WHERE a.hotel_id = 13 AND a.biz_date ='2014.04.20' AND b.date = '2014.04.20' AND 
a.audit_index = b.audit_index;

SELECT * FROM migrate_xsw.audit_impdata WHERE audit_index <> '' AND audit_index NOT IN(SELECT audit_index FROM portal.rep_audit_index_history
WHERE hotel_id = 13 AND biz_date = '2014.04.20')

-- 历史
ALTER TABLE migrate_xsw.yaudit_impdata ADD audit_index VARCHAR(30) NOT NULL DEFAULT '' AFTER class;

SELECT * FROM migrate_xsw.audit_impdata  WHERE halt = 'F' ORDER BY sequence;
SELECT * FROM migrate_xsw.yaudit_impdata  WHERE halt = 'F' ORDER BY sequence;

UPDATE migrate_xsw.yaudit_impdata a,migrate_xsw.audit_impdata b
SET a.audit_index = b.audit_index WHERE a.class = b.class AND a.halt = 'F' AND b.halt = 'F';

SELECT * FROM migrate_xsw.yaudit_impdata  WHERE halt = 'F' AND DATE = '2014.04.01';




