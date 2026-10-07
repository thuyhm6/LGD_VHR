/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : SampleServiceImpl.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2016. 8. 25.  	jhpark23  	최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.common.service.serviceImpl;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;

import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.ehcache.EhCacheCacheManager;
import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.service.UICommonService;
import com.lgd.lgcom.common.util.CacheUtils;
import com.lgd.lgcom.common.util.LGCOMConstants;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.common.service.serviceImpl.ApprovalServiceImpl.java
 * </PRE>
 *
 * @Author jhpark23
 * @Date 2016. 8. 25. 오전 11:56:51
 * @Version
 */
@Service("uiCommonService")
public class UICommonServiceImpl implements UICommonService {

	private static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(UICommonServiceImpl.class);

	@Autowired
	private EhCacheCacheManager cacheManager;

	@Autowired
	private CommonDao commonDao;

	/* 그리드 설정 저장 및 사용 */
	public LGCOMData retrieveGridConfig(LGCOMData param) {
		LGCOMData config = this.commonDao.select("uicommon.retrieveGridConfig", param);

		if( config == null ) {
			return null;
		}

		Object obj = config.get("content");

		if ( obj != null && obj instanceof java.sql.Clob) {
			String text = "";
			try {
				text = LGCOMUtils.clobToString((java.sql.Clob) obj);
			} catch (Exception e) {
				LOGGER.debug( e.getMessage() );
			} finally {
				config.set("content", text);
			}
		}

		LOGGER.debug("config--------------");
		LOGGER.debug(config);
		return config;
	}

	public void saveGridConfig(LGCOMData param){
		LOGGER.debug( param );
		
		LGCOMData config = this.commonDao.select("uicommon.retrieveGridConfigCount",param);
		int count = config.getInt("configCount");

		if( count == 0 ) {
			commonDao.insert("uicommon.insertGridConfig", param);
		} else {
			commonDao.update("uicommon.updateGridConfig", param);
		}
	}

	public void deleteGridConfig(LGCOMData param){
		commonDao.delete("uicommon.deleteGridConfig", param);
	}

	/* 키워드 사용 관련 부분  */
	@Override
	public List<LGCOMData> retrieveKeywordList(LGCOMData param) {
		return commonDao.selectList("uicommon.retrieveKeywordList",param);
	}

	@SuppressWarnings("unchecked")
	@Override
	public void saveKeywordList( LGCOMData param ) {
		//0. 화면에서 입력한 항목들을 받는다.
		LGCOMData items = (LGCOMData)param.get("keywordItems");
		
		Iterator<Map.Entry<String,Object>> keywords = items.entrySet().iterator();
		while( keywords.hasNext() ) {
		    Map.Entry<String,Object> keyword = keywords.next();
		    //String keyword = keywords.next();
			//조회 조건에 keyword 를 추가하여, 각 keyword 별로 처리를 수행한다.
			param.set("keyword", keyword.getKey()  );

			//1. 해당 keyword 로 먼저 현행 목록을 전부 인출한다. ( 파라미터에 keyword 라는 항목이 있어야 한다. )
			List<LGCOMData> currentList = commonDao.selectList("uicommon.retrieveKeywordList",param);
			LinkedHashSet<String> set = new LinkedHashSet<String>();

			for( LGCOMData item : LGCOMUtils.emptyIfNull(currentList) ) {
				set.add( item.getString("content") );
			}

			//2. 현행 항목은 모두 삭제한다.
			commonDao.delete("uicommon.deleteKeywordList", param);

			//4. 화면에서 입력 받은 항목을 set 에 추가한다.
			List<LGCOMData> list = (List<LGCOMData>)keyword.getValue();
			for( LGCOMData item : LGCOMUtils.emptyIfNull(list) ) {
				set.add( item.get("content") + "" );
			}

			//5. set 에 모인 전체 항목을 다시 inset 한다.
			Iterator<String> it = set.iterator();
			int inx = 1;
			LGCOMData item  = null;
			while( it.hasNext() ){
				item = new LGCOMData();
				item.set( LGCOMConstants.HTTP_SESSION_KEY, param.get(LGCOMConstants.HTTP_SESSION_KEY) );
				item.set( "logSeqNo", inx++ );
				item.set( "keyword",  param.getString("keyword") );
				item.set( "content", it.next() );

				commonDao.insert("uicommon.insertKeywordList", item);
			}
		}
	}

	@Override
	public void deleteKeywordList(LGCOMData param) {
		commonDao.delete("uicommon.deleteKeywordList", param);
	}

	/******* 조회 조건 저장 프로세스 *********/
	/**
	 * Desc : 조회 조건 저장 내역을 조회한다.
	 * @Method Name : retrieveSearchCondition
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveSearchCondition(LGCOMData param)  {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("uicommon.retrieveSearchCondition",param);
	}

	/**
	 * Desc : 조회 조건 저장 내역을 저장한다.
	 * @Method Name : insertSearchCondition
	 * @param  param
	 * @return void
	 * @throws Exception
	 */
	@SuppressWarnings("unchecked")
	public void insertSearchCondition(LGCOMData param)  {
		LOGGER.debug("param = " + param);
		this.commonDao.delete("uicommon.deleteSearchCondition", param);

		List<LGCOMData> list = (List<LGCOMData>)param.get("elements");

		for( LGCOMData item : LGCOMUtils.emptyIfNull( list ) ) {
			item.set( LGCOMConstants.HTTP_SESSION_KEY, param.get( LGCOMConstants.HTTP_SESSION_KEY ) );
			this.commonDao.insert("uicommon.insertSearchCondition", item);
		}
	}

   /**
     * Desc : 조회 조건 저장 내역을 저장한다.
     * @Method Name : deleteSearchCondition
     * @param  param
     * @return void
     * @throws Exception
     */
    public void deleteSearchCondition(LGCOMData param)  {
        LOGGER.debug("param = " + param);
        this.commonDao.delete("uicommon.deleteSearchCondition", param);
    }

	@SuppressWarnings("unchecked")
    public List<LGCOMData> retriveMenuItemFromCache( LGCOMData param) {
	    List<String> menuIdList = ( List<String> )param.get("menuIdList");
		if( menuIdList == null ) {
		    menuIdList = new ArrayList<String>();
			menuIdList.add( param.getString("menuId") );
		}

		List<LGCOMData> list = LGCOMData.createList();
		LGCOMData singleParam = new LGCOMData();

		for( String menuId : LGCOMUtils.emptyIfNull( menuIdList ) ) {
			LGCOMData menuItem = CacheUtils.getCacheValue(cacheManager, LGCOMConstants.MENU_CACHE, menuId);

			if( menuItem == null ) {
				singleParam.set( "menuId", menuId );
				menuItem = this.commonDao.select("Common.retrieveMenuList", singleParam  );
				if( menuItem != null ) {
					CacheUtils.setCacheValue(cacheManager, LGCOMConstants.MENU_CACHE, menuItem.getString("menuId"), menuItem);
					list.add( menuItem );
				}
			} else {
				list.add( menuItem );
			}
		}
		return list;
	}

	/**
	 * Desc : 공지사항중 Popup 형태로 공지된 목록을 조회한다.
	 * @Method Name : retrievePopupBoardList
	 * @param  param
	 * @return List<?>
	 * @throws IOException
	 * @throws SQLException
	 */
	public List<LGCOMData> retrievePopupNoticeList(LGCOMData param) {
	    LOGGER.debug("param = " + param);
	    LGCOMData userSession = (LGCOMData)param.get("USER_SESSION");

	    List<LGCOMData> list = null;

	    if( "LGPRO".equalsIgnoreCase( userSession.getString("systemCode") ) ) {
	    	list = this.commonDao.selectList("uicommon.retrievePopupNoticeListForLGPRO",param);
	    } else {
	    	list = this.commonDao.selectList("uicommon.retrievePopupNoticeList",param);
	    }

		for( LGCOMData item : LGCOMUtils.emptyIfNull( list ) ) {
			/* 제목 XSS 적용 */
			String boardTitle = item.getString("bulletinBoardTitle");
			// Executable Img 처리
			boardTitle = LGCOMUtils.removeExecutableImgTag(boardTitle);
			// XSS 처리
			boardTitle = LGCOMUtils.xssFilter(boardTitle);
			item.set("bulletinBoardTitle",boardTitle);
			
			/* CLOB 변환 */
			Object obj = item.get("bbBodyContent");
			if(obj instanceof java.sql.Clob) {
				String content = "";
				try {
					content = LGCOMUtils.clobToString((java.sql.Clob)obj);
				}catch( Exception e ) {
					content = "";
				}
				// Executable Img 처리
				content = LGCOMUtils.removeExecutableImgTag(content);
				// XSS 처리
				content = LGCOMUtils.xssFilter(content);
	            // IMG src 속성 경로 치환
	            content = LGCOMUtils.getReplaceImageString(content);
				item.set("bbBodyContent",content);
			}
		}
		return list;
	}

	/**
	 * Desc : 요청서의 안내탭 내용을 조회한다.
	 * @Method Name : retrieveGridConfig
	 * @param  param
	 * @return LGCOMData
	 */
	public LGCOMData retrieveRequestFormInfomationFromManual(LGCOMData param) {
		LOGGER.debug("param = " + param);
		// 주어진 프로그램ID와 언어코드로 요청서 안내탭 내용을 조회한다.
		LGCOMData result = this.commonDao.select("uicommon.retrieveRequestFormInfomationFromManual",param);
		if(result != null) {
			/* CLOB 변환 */
			Object obj = result.get("manualContent");
			if(obj instanceof java.sql.Clob) {
				String content = "";
				try {
					content = LGCOMUtils.clobToString((java.sql.Clob)obj);
				} catch(Exception e) {
					content = "";
				}
				// Executable Img 처리
				content = LGCOMUtils.removeExecutableImgTag(content);
				// XSS 처리
				content = LGCOMUtils.xssFilter(content);
				// IMG src 속성 경로 치환
				content = LGCOMUtils.getReplaceImageString(content);
				result.set("manualContent",content);
			}
			/* 첨부파일이 있으면 첨부파일 목록을 조회한다. */
			if(!StringUtils.isEmpty(result.getString("attachFileId"))) {
				LGCOMData param1 = new LGCOMData();
				param1.set("reqNumber", result.getString("attachFileId"));
				param1.set("downloadURL", "");
				List<LGCOMData> fileList = this.commonDao.selectList("LGSYSC00210.selectAttachmentListByReqNumber",param1);
				result.set("attachFile",fileList);
			}
		}
		LOGGER.debug("result = " + result);
		return result;
	}
	
	
	public LGCOMData checkValidBiMatrixMenuId(LGCOMData param) {
		return this.commonDao.select("Common.retrieveMenuList", param );
	}
	
}
