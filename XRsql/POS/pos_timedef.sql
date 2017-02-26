CREATE TABLE pos_timedef (
	id char(2),
	thisid char(2),
	timedesc char(30),
	datecond char(60),
	start_t char(8),
	end_t char(8),
	factor float);
INSERT INTO pos_timedef VALUES (
	'01',
	'01',
	'周一至周天0时至7时',
	'w:1234567',
	'00:00:00',
	'06:59:59',
	1);
INSERT INTO pos_timedef VALUES (
	'01',
	'02',
	'周一至周日7时至24时',
	'w:1234567',
	'07:00:00',
	'23:59:59',
	1);
INSERT INTO pos_timedef VALUES (
	'02',
	'01',
	'周一至周日0时至7时',
	'w:1234567',
	'00:00:00',
	'06:59:59',
	0.6);
INSERT INTO pos_timedef VALUES (
	'02',
	'02',
	'周一至周日7时至22时',
	'w:1234567',
	'07:00:00',
	'21:59:59',
	1);
INSERT INTO pos_timedef VALUES (
	'02',
	'03',
	'周一至周日22时至0点',
	'w:1234567',
	'22:00:00',
	'23:59:59',
	0.6);
INSERT INTO pos_timedef VALUES (
	'03',
	'01',
	'每日',
	'w:1234567',
	'00:00:00',
	'23:59:59',
	1);
