package com.aua.util;

import java.lang.reflect.InvocationTargetException;
import org.apache.commons.beanutils.BeanUtilsBean;

public class BeanUtils
{
  public static void copyProperties(Object dest, Object orig)
    throws IllegalAccessException, InvocationTargetException
  {
    BeanUtilsBean.getInstance().copyProperties(dest, orig);
  }
}