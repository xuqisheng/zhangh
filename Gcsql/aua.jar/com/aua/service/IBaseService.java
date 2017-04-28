package com.aua.service;

import com.aua.entity.BaseEntity;
import java.io.Serializable;
import org.hibernate.LockMode;
import org.springframework.dao.DataAccessException;

public abstract interface IBaseService
{
  public abstract <T extends BaseEntity> Serializable save(T paramT)
    throws DataAccessException;

  public abstract <T extends BaseEntity> void saveOrUpdate(T paramT)
    throws DataAccessException;

  public abstract <T extends BaseEntity> void update(T paramT)
    throws DataAccessException;

  public abstract <T extends BaseEntity> void delete(T paramT)
    throws DataAccessException;

  public abstract <T extends BaseEntity> T merge(T paramT)
    throws DataAccessException;

  public abstract <T extends BaseEntity> void refresh(T paramT)
    throws DataAccessException;

  public abstract <T extends BaseEntity> void refresh(T paramT, LockMode paramLockMode)
    throws DataAccessException;

  public abstract <T extends BaseEntity> boolean contains(T paramT)
    throws DataAccessException;

  public abstract void evict(Object paramObject)
    throws DataAccessException;

  public abstract void initialize(Object paramObject)
    throws DataAccessException;
}