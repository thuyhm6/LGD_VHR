/**
 * -----------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source : LGSETC00090Service.java
 * @Desc : Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 * -----------------------------------------------------------------------------
 * ------- 변 경 사 항
 * -----------------------------------------------------------------------------
 * ------- VER DATE AUTHOR DESCRIPTION
 * -----------------------------------------------------------------------------
 * ------ 1. 0 2016. 8. 3. csseo 최초 프로그램 작성
 * -----------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgutlc.lgutlc00090.service;

import java.util.List;
import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.lgsetc.lgsetc00090.service.LGSETC00090Service.java
 * </PRE>
 *
 * @Author    csseo
 * @Date      2016. 8. 3. 오전 9:00:58
 * @Version
 */
public interface LGUTLC00090Service {
	/**
	 * Desc : Dynamic Query 목록을 조회한다.
	 * @Method Name : retrieveDynamicQueryList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveDynamicQueryList(LGCOMData param);

	/**
	 * Desc : Dynamic Query 상세내역을 조회한다.
	 * @Method Name : retrieveDynamicQueryDetail
	 * @param  param
	 * @return LGCOMData
	 */
	public LGCOMData retrieveDynamicQueryDetail(LGCOMData param);

	/**
	 * Desc : Dynamic Query 컬럼 목록을 조회한다.
	 * @Method Name : retrieveDynamicQueryDetail
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveDynamicQueryColumnList(LGCOMData param);

	/**
	 * Desc : Dynamic Query 내용을 저장한다.
	 * @Method Name : saveDynamicQueryInfo
	 * @param  param
	 * @return LGCOMData
	 */
	public LGCOMData saveDynamicQueryInfo(LGCOMData param);

	/**
	 * Desc : Dynamic Query Parameter 목록을 조회한다.
	 * @Method Name : retrieveDynamicQueryParamList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveDynamicQueryParamList(LGCOMData param);

	/**
	 * Desc : Dynamic Query Parameter 목록을 저장한다.
	 * @Method Name : saveDynamicQueryParamData
	 * @param  param
	 */
	public void saveDynamicQueryParamData(LGCOMData param);

	/**
	 * Desc : Dynamic Query Parameter 기본값 목록을 조회한다.
	 * @Method Name : retrieveDynamicQueryParamValueList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveDynamicQueryParamValueList(LGCOMData param);

	/**
	 * Desc : Dynamic Query Parameter Value 목록을 저장한다.
	 * @Method Name : saveDynamicQueryParamValueData
	 * @param  param
	 */
	public void saveDynamicQueryParamValueData(LGCOMData param);

	/**
	 * Desc : Dynamic Query Parameter 출력용 목록을 조회한다.
	 * @Method Name : retrieveParamValueListForInput
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveParamValueListForInput(LGCOMData param);

	/**
	 * Desc : Dynamic Query Parameter 검색 Popup 목록을 조회한다.
	 * @Method Name : retrieveParamSearchListForInput
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveParamSearchListForInput(LGCOMData param);

	/**
	 * Desc : Dynamic Query SQL을 생성한다.
	 * @Method Name : retrieveDynamicQueryPreview
	 * @param  param
	 * @return LGCOMData
	 */
	public LGCOMData retrieveDynamicQueryPreview(LGCOMData param);

	/**
	 * Desc : Dynamic Query SQL을 Test한다.
	 * @Method Name : retrieveDynamicQueryTest
	 * @param  param
	 * @return LGCOMData
	 */
	public LGCOMData retrieveDynamicQueryTest(LGCOMData param);

	/**
	 * Desc : 쿼리 ID를 받아 Data를 조합해서 Query를 생성한다.
	 * @Method Name : retrieveDynamicQueryBody
	 * @param  queryId
	 * @return String
	 */
	public String retrieveDynamicQueryBody(LGCOMData param);
}
