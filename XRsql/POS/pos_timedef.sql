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
	'��һ������0ʱ��7ʱ',
	'w:1234567',
	'00:00:00',
	'06:59:59',
	1);
INSERT INTO pos_timedef VALUES (
	'01',
	'02',
	'��һ������7ʱ��24ʱ',
	'w:1234567',
	'07:00:00',
	'23:59:59',
	1);
INSERT INTO pos_timedef VALUES (
	'02',
	'01',
	'��һ������0ʱ��7ʱ',
	'w:1234567',
	'00:00:00',
	'06:59:59',
	0.6);
INSERT INTO pos_timedef VALUES (
	'02',
	'02',
	'��һ������7ʱ��22ʱ',
	'w:1234567',
	'07:00:00',
	'21:59:59',
	1);
INSERT INTO pos_timedef VALUES (
	'02',
	'03',
	'��һ������22ʱ��0��',
	'w:1234567',
	'22:00:00',
	'23:59:59',
	0.6);
INSERT INTO pos_timedef VALUES (
	'03',
	'01',
	'ÿ��',
	'w:1234567',
	'00:00:00',
	'23:59:59',
	1);
