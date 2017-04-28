package com.aua.hibernate.dialect;

import org.hibernate.Hibernate;
import org.hibernate.dialect.MySQL5InnoDBDialect;
import org.hibernate.type.NullableType;

public class MySQL5InnoDBDialect extends org.hibernate.dialect.MySQL5InnoDBDialect
{
  public MySQL5InnoDBDialect()
  {
    registerHibernateType(1, Hibernate.STRING.getName());
  }
}