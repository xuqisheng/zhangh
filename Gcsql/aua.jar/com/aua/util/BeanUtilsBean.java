package com.aua.util;

import org.apache.commons.beanutils.BeanUtilsBean;
import org.apache.commons.beanutils.ContextClassLoaderLocal;
import org.apache.commons.beanutils.PropertyUtilsBean;

public class BeanUtilsBean extends org.apache.commons.beanutils.BeanUtilsBean
{
  private static final ContextClassLoaderLocal beansByClassLoader = new ContextClassLoaderLocal() {
    protected Object initialValue() {
      return new BeanUtilsBean();
    }
  };

  public static synchronized org.apache.commons.beanutils.BeanUtilsBean getInstance() {
    return ((BeanUtilsBean)beansByClassLoader.get());
  }

  public BeanUtilsBean() {
    super(new ConvertUtilsBean(), new PropertyUtilsBean());
  }
}