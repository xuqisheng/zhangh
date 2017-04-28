package com.aua.util;

import java.text.DecimalFormat;
import java.text.NumberFormat;

public final class NumberHelper
{
  public static String format(Number number)
  {
    if (number == null) return null;
    NumberFormat nf = new DecimalFormat("###0.00");
    return nf.format(number);
  }

  public static String parseNumber(Number obj)
  {
    if (obj == null)
      return "";

    return obj.toString();
  }
}