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
package com.lgd.lgcom.lgsysc.lgsysc00070.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgcom.lgsysc.lgsysc00070.service.LGSYSC00070Service;

/**
 * <PRE>
 * com.lgd.lgcom.lgsysc.lgsysc00210.controller.LGSYS00070Controller.java
 * </PRE>
 *
 * @Author    csseo
 * @Date      2016. 5. 18. 오전 9:00:58
 * @Version
 */
@Service(value="LGSYSC00070Service")
public class LGSYSC00070ServiceImpl implements LGSYSC00070Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGSYSC00070ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

	/**
	 * Desc : 즐겨찾기 목록을 조회한다.
	 * @Method Name : retrieveFavorateList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveFavoriteList(LGCOMData param)  {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGSYSC00070.retrieveFavoriteList",param);
	}

	/**
	 * Desc : 즐겨찾기 항목을 삭제한다.
	 * @Method Name : retrieveFavorateList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public void deleteFavoriteItem(LGCOMData param) {
		LOGGER.debug("param = " + param);
		this.commonDao.selectList("LGSYSC00070.deleteFavoriteItem",param);
	}


	/**
	 * Desc : 즐겨찾기 항목을 추가한다.
	 * @Method Name : retrieveFavorateList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public void insertFavoriteItem(LGCOMData param) {
		LOGGER.debug("param = " + param);
		this.commonDao.selectList("LGSYSC00070.insertFavoriteItem",param);
	}

	/**
	 * Desc : 즐겨찾기 화면 표시순서를 갱신한다.
	 * @Method Name : updateFavoriteSortOrder
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	@SuppressWarnings({ "unchecked" })
	public void updateFavoriteSortOrder(LGCOMData param) {
		LOGGER.debug("param = " + param);
		List<LGCOMData> sortOrder = (List<LGCOMData>)param.get("sortOrder");
		
		for( LGCOMData item : LGCOMUtils.emptyIfNull( sortOrder ) ) {
			item.set( "USER_SESSION" , param.get( "USER_SESSION" ) );
			this.commonDao.update("LGSYSC00070.updateFavoriteSortOrder",item);
		}
	}

	public List<LGCOMData> retrieveTop10ListForMain(LGCOMData param) {
		param.set("USER_SESSION",param.get("USER_SESSION"));
		return this.commonDao.selectList("LGSYSC00070.retrieveTop10ListForMain",param);
	}
}
