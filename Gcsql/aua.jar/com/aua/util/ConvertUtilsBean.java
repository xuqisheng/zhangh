package com.aua.util;

import org.apache.commons.beanutils.ConvertUtilsBean;
import org.apache.commons.beanutils.converters.BooleanConverter;
import org.apache.commons.beanutils.converters.ByteConverter;
import org.apache.commons.beanutils.converters.CharacterConverter;
import org.apache.commons.beanutils.converters.DoubleConverter;
import org.apache.commons.beanutils.converters.FloatConverter;
import org.apache.commons.beanutils.converters.IntegerConverter;
import org.apache.commons.beanutils.converters.LongConverter;
import org.apache.commons.beanutils.converters.ShortConverter;

public class ConvertUtilsBean extends org.apache.commons.beanutils.ConvertUtilsBean
{
  public void deregister()
  {
    super.deregister();
    register(new BooleanConverter(null), Boolean.class);
    register(new ByteConverter(null), Byte.class);
    register(new CharacterConverter(null), Character.class);
    register(new DoubleConverter(null), Double.class);
    register(new FloatConverter(null), Float.class);
    register(new IntegerConverter(null), Integer.class);
    register(new LongConverter(null), Long.class);
    register(new ShortConverter(null), Short.class);
  }
}