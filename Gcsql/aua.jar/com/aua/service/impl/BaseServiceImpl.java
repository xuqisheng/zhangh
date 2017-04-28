package com.aua.service.impl;

import com.aua.dao.IBaseDao;
import com.aua.entity.BaseEntity;
import com.aua.service.IBaseService;
import java.io.Serializable;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.LockMode;
import org.springframework.dao.DataAccessException;

public abstract class BaseServiceImpl
  implements IBaseService
{
  protected static Log log = LogFactory.getLog(BaseServiceImpl.class);

  protected abstract IBaseDao getDao();

  public <T extends BaseEntity> Serializable save(T entity)
    throws DataAccessException
  {
    return getDao().save(entity);
  }

  public <T extends BaseEntity> void saveOrUpdate(T entity) throws DataAccessException {
    getDao().saveOrUpdate(entity);
  }

  public <T extends BaseEntity> void update(T entity) throws DataAccessException {
    getDao().update(entity);
  }

  public <T extends BaseEntity> void delete(T entity) throws DataAccessException {
    getDao().delete(entity);
  }

  public <T extends BaseEntity> T merge(T entity) throws DataAccessException {
    return getDao().merge(entity);
  }

  public <T extends BaseEntity> void refresh(T entity) throws DataAccessException {
    getDao().refresh(entity);
  }

  public <T extends BaseEntity> void refresh(T entity, LockMode lockMode) throws DataAccessException {
    getDao().refresh(entity, lockMode);
  }

  public <T extends BaseEntity> boolean contains(T entity) throws DataAccessException {
    return getDao().contains(entity);
  }

  public void evict(Object object) throws DataAccessException {
    getDao().evict(object);
  }

  public void initialize(Object proxy) throws DataAccessException {
    getDao().initialize(proxy);
  }
}