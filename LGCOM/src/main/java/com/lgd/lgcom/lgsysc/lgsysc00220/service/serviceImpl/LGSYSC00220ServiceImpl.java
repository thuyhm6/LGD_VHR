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
package com.lgd.lgcom.lgsysc.lgsysc00220.service.serviceImpl;

import java.sql.SQLException;
import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgcom.lgsysc.lgsysc00220.service.LGSYSC00220Service;

/**
 * <PRE>
 * com.lgd.lgcom.lgsysc.lgsysc00180.service.serviceImpl.LGSYSC00180ServiceImpl.java
 * </PRE>
 *
 * @Author    csseo
 * @Date      2016. 5. 18. 오전 9:00:58
 * @Version
 */
@Service(value="LGSYSC00220Service")
public class LGSYSC00220ServiceImpl implements LGSYSC00220Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGSYSC00220ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

	/**
	 * Desc : 사용자의 Role에 기반한 사용가능한 모든 메뉴 목록을 조회한다.
	 * @Method Name : retrieveUsetListByRole
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveMenuListByRole(LGCOMData param)  {
		LOGGER.debug("param = " + param);
		//this.commonDao.supportExcelExport("LGSYSC00220.retrieveMenuListByRole",param);
		/*
		Set keys = new HashSet<String>();
		Iterator<String> it = param.keySet().iterator();
		while( it.hasNext() ) {
			String key = it.next();
			LOGGER.debug("key= " + key );
			keys.add( key );
		}
		*/
		return this.commonDao.selectList("LGSYSC00220.retrieveMenuListByRole",param);
	}

	/**
	 * Desc : 사용자 메뉴 목록을 인출한다.
	 * @Method Name : retrieveUserMenuList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveUserMenuList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGSYSC00220.retrieveUserMenuList",param);
	}

	/**
	 * Desc : 사용자 메뉴 목록 저장한다.
	 * @Method Name : insertUserMenuList
	 * @param  param
	 * @return void
	 */
	@SuppressWarnings("unchecked")
	public void insertUserMenuList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		/*
		//나에게 저장한 모든 메뉴 항목을 지운다.
		this.commonDao.delete( "LGSYSC00220.deleteUserMenu" , param);
		//화면으로부터 모든 항목을 받아서, 이것을 일괄 저장한다.
		List<Map<String, Object>> list = (List<Map<String, Object>>)param.get("created");
		for( Map<String,Object> item : LGCOMUtils.emptyIfNull( list ) ) {
			item.put("USER_SESSION",  param.get("USER_SESSION") );
			this.commonDao.delete( "LGSYSC00220.insertUserMenu" , item);
		}
		*/
		// 화면으로부터 모든 항목을 받아서, 이것을 일괄 저장한다.
		List<LGCOMData> list = (List<LGCOMData>)param.get("created");
		for( LGCOMData item : LGCOMUtils.emptyIfNull( list ) ) {
			item.put("USER_SESSION",  param.get("USER_SESSION") );
			this.commonDao.delete( "LGSYSC00220.insertUserMenu" , item);
		}
	}

	/**
	 * Desc : 사용자 메뉴의 Top 메뉴의 순서를 재정렬한다.
	 * @Method Name : updateUserTopMenuOrder
	 * @param  param
	 * @return void
	 */
	@SuppressWarnings("unchecked")
	public void updateUserTopMenuOrder(LGCOMData param) {
		// 화면으로부터 모든 항목을 받아서, 이것을 일괄 저장한다.
		List<LGCOMData> list = (List<LGCOMData>)param.get("created");
		for( LGCOMData item : LGCOMUtils.emptyIfNull( list ) ) {
			item.put("USER_SESSION",  param.get("USER_SESSION") );
			this.commonDao.delete( "LGSYSC00220.updateUserTopMenuOrder" , item);
		}
	}

	@SuppressWarnings("unchecked")
	public void deleteUserMenuList(LGCOMData param) {
		// 화면으로부터 모든 항목을 받아서, 이것을 일괄 저장한다.
		List<LGCOMData> list = (List<LGCOMData>)param.get("created");
		for( LGCOMData item : LGCOMUtils.emptyIfNull( list ) ) {
			item.put("USER_SESSION",  param.get("USER_SESSION") );
			this.commonDao.delete( "LGSYSC00220.deleteUserMenu" , item);
		}
	}

	/**
	 * Desc : Export Excel Sample
	 * @Method Name : exportExcel
	 * @param param
	 * @return
	 * @throws SQLException
	 */
	public LGCOMData exportExcel(LGCOMData param) throws SQLException  {
		LOGGER.debug("export Excel start >>> ");
		return this.commonDao.requestExcelExport("Common.retrieveMessageList",param);
	}

	/**
	 * Desc : My Menu에서 사용하는 Role 기반 시스템 및 메뉴 목록 조회
	 * @Method Name : retrieveMyMenuListByRole
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveMyMenuListByRole(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGSYSC00220.retrieveMyMenuListByRole",param);
	}

	/**
	 * Desc : My Menu 사용자 메뉴 목록을 인출한다.
	 * @Method Name : retrieveMyMenuUserMenuList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveMyMenuUserMenuList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGSYSC00220.retrieveMyMenuUserMenuList",param);
	}
}
