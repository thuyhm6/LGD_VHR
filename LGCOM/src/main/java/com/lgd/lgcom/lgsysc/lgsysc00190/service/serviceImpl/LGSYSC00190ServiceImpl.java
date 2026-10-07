/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGSYSC00210ServiceImpl.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 5. 18.    jhlee    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgsysc.lgsysc00190.service.serviceImpl;

import java.util.Iterator;
import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgcom.lgsysc.lgsysc00190.service.LGSYSC00190Service;

/**
 * <PRE>
 * com.lgd.lgcom.lgsysc.lgsysc00190.service.serviceImpl.LGSYSC00190ServiceImpl.java
 * </PRE>
 *
 * @Author csseo
 * @Date 2016. 5. 18. 오전 9:00:58
 * @Version
 */
@Service(value = "LGSYSC00190Service")
public class LGSYSC00190ServiceImpl implements LGSYSC00190Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGSYSC00190ServiceImpl.class);

	@Resource(name = "commonDao")
	CommonDao commonDao;

	/**
	 * Desc : 전체 시스템 메뉴 목록을 조회한다.
	 * 
	 * @Method Name : retrieveUsetList
	 * @param param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveMenuList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGSYSC00190.retrieveMenuList", param);
	}

	/**
	 * Desc : 전체 시스템 메뉴 목록을 조회한다.
	 * 
	 * @Method Name : retrieveUsetList
	 * @param param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveProgramList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGSYSC00190.retrieveProgramList", param);
	}

	/**
	 * Desc : 프로그램 항목의 정보를 수정한다. ( update 와 insert 가 함께 수행되므로 주의 )
	 * 
	 * @Method Name : updateProgramList
	 * @param param
	 * @return List<?>
	 * @throws Exception
	 */
	@SuppressWarnings("unchecked")
	public void updateMenuList(LGCOMData param) {
		LOGGER.debug("param = " + param);

		List<LGCOMData> list = (List<LGCOMData>) param.get("updated");

		for (LGCOMData item : LGCOMUtils.emptyIfNull(list)) {
			item.put("USER_SESSION", param.get("USER_SESSION"));
			
			processMenuNames( item );
			this.commonDao.update("LGSYSC00190.updateMenu", item);
		}

		list = (List<LGCOMData>) param.get("created");

		for (LGCOMData item : LGCOMUtils.emptyIfNull(list)) {
			LGCOMData mewMenuItem = this.commonDao.select("LGSYSC00190.retrieveNewMenuId", item);

			if (mewMenuItem != null) {
				item.put("menuId", mewMenuItem.getString("menuId"));
			}

			item.put("USER_SESSION", param.get("USER_SESSION"));
			
			processMenuNames( item );
			this.commonDao.insert("LGSYSC00190.insertMenu", item);
		}

		list = (List<LGCOMData>) param.get("deleted");

		for (LGCOMData item : LGCOMUtils.emptyIfNull(list)) {
			this.commonDao.delete("LGSYSC00190.deleteMenuNames", item);
			this.commonDao.delete("LGSYSC00190.deleteMenu", item);
		}
	}
	
	private void processMenuNames( LGCOMData item ) {
		this.commonDao.delete("LGSYSC00190.deleteMenuNames", item);
		
		LGCOMData names = (LGCOMData)item.get("names"); 
		Iterator<String> it = names.keySet().iterator();
		LGCOMData name = null;
		
		while( it.hasNext() ){
			String key = it.next();
			name = new LGCOMData();
			name.put("menuId", item.get("menuId"));
			name.put("languageCode", key );
			name.put("menuName",  names.getString( key ) );
			name.put("USER_SESSION", item.get("USER_SESSION"));
			this.commonDao.delete("LGSYSC00190.insertMenuNames", name);
		}
	}
}
