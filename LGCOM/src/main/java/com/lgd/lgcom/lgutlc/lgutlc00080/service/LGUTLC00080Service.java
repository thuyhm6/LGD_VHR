/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGUTLC00080Service.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 8.  3.    csseo    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgutlc.lgutlc00080.service;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.lgutlc.lgutlc00080.service.LGUTLC00080Service.java
 * </PRE>
 *
 * @Author    csseo
 * @Date      2016. 8. 3. 오전 9:00:58
 * @Version
 */
public interface LGUTLC00080Service {
	/**
	 * Desc : Dynamic Query 목록을 조회한다.
	 * @Method Name : retrieveDynamicQueryPopList
	 * @param  param
	 * @return List<?>
	 */
	public List<LGCOMData> retrieveDynamicQueryPopList(LGCOMData param);

	/**
	 * Desc : Dynamic Query 컬럼 목록을 조회한다.
	 * @Method Name : retrieveDynamicQueryDetail
	 * @param  param
	 * @return List<?>
	 */
	public List<LGCOMData> retrieveDynamicQueryColumnList(LGCOMData param);

	/**
	 * Desc : 새 배치에서 호출 할 부분
	 * @Method Name : retrieveDynamicQueryResultList
	 * @param  param
	 * @result LGCOMData
	 */
	public LGCOMData saveDynamicQueryResultList(LGCOMData param);

	//예전 실제 로직
	public LGCOMData saveDynamicQueryResultListNewBatch(LGCOMData param);
	
	/**
	 * Desc : Dynamic Query 결과 목록을 조회한다.
	 * @Method Name : retrieveDynamicQueryResultList2
	 * @param  param
	 * @result LGCOMData
	 */
	public LGCOMData saveDynamicQueryResultList2(LGCOMData param);

	/**
	 * Desc : Dynamic Query 결과 목록을 조회한다.
	 * @Method Name : retrieveDynamicQueryResultList
	 * @param  param
	 * @return LGCOMData
	 */
	public List<LGCOMData> retrieveDynamicQueryResultList(LGCOMData param);

	/**
	 * Desc : Dynamic Query 실행 이력을 조회한다.
	 * @Method Name : retrieveDynamicQueryTodayList
	 * @param  param
	 * @return List<?>
	 * @throws IOException
	 * @throws SQLException
	 */
	public List<LGCOMData> retrieveDynamicQueryTodayList(LGCOMData param) throws SQLException, IOException;

	/**
	 * Desc : Excel 파일을 다운로드 한다.
	 * @Method Name : exportDynamicQueryExcel
	 * @param  param
	 * @return void
	 */
	public LGCOMData exportDynamicQueryExcel(LGCOMData param) throws Exception;
}
