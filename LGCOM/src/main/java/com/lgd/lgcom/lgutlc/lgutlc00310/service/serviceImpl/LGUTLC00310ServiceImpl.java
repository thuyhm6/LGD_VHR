/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGUTLC00203ServiceImpl.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER      DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *   1.0   2016.08.22.      CYJ      최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgutlc.lgutlc00310.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgcom.lgutlc.lgutlc00310.service.LGUTLC00310Service;

/**
 * <PRE>
 * com.lgd.lgcom.lgutlc.lgutlc00310.service.serviceImpl.LGUTLC00310ServiceImpl.java
 * </PRE>
 *
 * @Author    CYJ
 * @Date      2016. 8. 22. 오전 9:50:46
 * @Version
 */
@Service("LGUTLC00310Service")
public class LGUTLC00310ServiceImpl implements LGUTLC00310Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGUTLC00310ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

	/**
	 * Desc : 나의 결재요청 목록을 조회한다.
	 * @Method Name : retrieveRequestList
	 * @param  param
	 * @return List<LGCOMData>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveRequestList(LGCOMData param){
		String pStatus = param.getString("status");
		String pReqType = param.getString("reqType");
		String listName = "LGUTLC00310.retrieveRequestRList";

		if( (pReqType != null && !"".equals(pReqType)) && (pStatus != null && !"".equals(pStatus)) ){
			if("REQUEST".equals(pReqType)) {
				if("R".equals(pStatus)) {
					listName = "LGUTLC00310.retrieveRequestRList";
				} else {
					listName = "LGUTLC00310.retrieveRequestCList";
				}
			} else if("REFERENCE".equals(pReqType)) {
				if("R".equals(pStatus)) {
					listName = "LGUTLC00310.retrieveReferenceRList";
				} else {
					listName = "LGUTLC00310.retrieveReferenceCList";
				}
			} else if("INSPECTION".equals(pReqType)) {
				if("R".equals(pStatus)) {
					listName = "LGUTLC00310.retrieveInspectionRList";
				} else {
					listName = "LGUTLC00310.retrieveInspectionCList";
				}
			} else if("PREVIEW".equals(pReqType)) {
				if("R".equals(pStatus)) {
					listName = "LGUTLC00310.retrievePreviewRList";
				} else {
					listName = "LGUTLC00310.retrievePreviewCList";
				}
			} else {
				listName = "LGUTLC00310.retrieveRequestRList";
			}
		} else {
			listName = "LGUTLC00310.retrieveRequestRList";
		}
		return this.commonDao.selectList(listName, param);
	}
}
