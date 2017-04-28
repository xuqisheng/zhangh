package com.aua.util;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

public final class DateHelper
{
  public static final String SHORT_DATE_PATTERN = "yyyy-MM-dd";
  public static final String DATE_PATTERN = "yyyy-MM-dd HH24:mm";

  public static String formatDate(Date date)
  {
    if (date == null)
      return "";

    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
    return sdf.format(date);
  }

  public static Date shortDate(Date date)
  {
    Calendar c = Calendar.getInstance();
    c.setTime(date);
    c.set(11, 0);
    c.set(12, 0);
    c.set(13, 0);
    c.set(14, 0);
    return c.getTime();
  }

  public static Date parseString(String strDate, String pattern) {
    if (StringHelper.isNull(strDate))
      return null;

    String strPattern = pattern;
    if (StringHelper.isNull(strPattern))
      strPattern = "yyyy-MM-dd";

    SimpleDateFormat sdf = new SimpleDateFormat(strPattern);
    try {
      return sdf.parse(strDate);
    } catch (ParseException e) {
      throw new RuntimeException(e);
    }
  }
}