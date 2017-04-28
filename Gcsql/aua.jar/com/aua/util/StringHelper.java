package com.aua.util;

import java.io.Serializable;
import java.math.BigDecimal;

public final class StringHelper
  implements Serializable
{
  private static final long serialVersionUID = -1007994084L;
  public static String EMPTY = "";

  public static boolean isEmpty(String str)
  {
    return ((str == null) || (str.length() == 0));
  }

  public static boolean isNull(String str)
  {
    return ((str == null) || (str.trim().length() == 0));
  }

  public static boolean isNotNull(String str)
  {
    return ((str != null) && (str.trim().length() > 0));
  }

  public static boolean isNotEmpty(String str)
  {
    return ((str != null) && (str.length() > 0));
  }

  public static Long parseToLong(String str) {
    if (isNull(str))
      return null;

    return Long.valueOf(str);
  }

  public static Integer parseToInteger(String str) {
    if (isNull(str))
      return null;

    return Integer.valueOf(str); }

  public static BigDecimal parseToBigDecimal(String str) {
    if (isNull(str))
      return null;

    return new BigDecimal(str);
  }
}