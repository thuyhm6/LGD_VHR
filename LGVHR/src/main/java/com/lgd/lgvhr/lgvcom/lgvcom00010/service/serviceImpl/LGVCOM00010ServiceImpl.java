/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVCOM00010ServiceImpl.java
 * @Desc    :
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER      DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *   1.0   2017.11.13.      LHJ      최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvcom.lgvcom00010.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvcom.lgvcom00010.service.LGVCOM00010Service;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvcom.lgvcom00010.service.serviceImpl.LGVCOM00010ServiceImpl.java
 * </PRE>
 *
 * @Author    LHJ
 * @Date      2017. 11. 13. 오전 9:32:46
 * @Version
 */
@Service("LGVCOM00010Service")
public class LGVCOM00010ServiceImpl implements LGVCOM00010Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVCOM00010ServiceImpl.class);

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
		String listName = "LGVCOM00010.retrieveRequestRList";

		if( (pReqType != null && !"".equals(pReqType)) && (pStatus != null && !"".equals(pStatus)) ){
			if("REQUEST".equals(pReqType)) {
				if("R".equals(pStatus)) {
					listName = "LGVCOM00010.retrieveRequestRList";
				} else {
					listName = "LGVCOM00010.retrieveRequestCList";
				}
			} else if("REFERENCE".equals(pReqType)) {
				if("R".equals(pStatus)) {
					listName = "LGVCOM00010.retrieveReferenceRList";
				} else {
					listName = "LGVCOM00010.retrieveReferenceCList";
				}
			} else if("INSPECTION".equals(pReqType)) {
				if("R".equals(pStatus)) {
					listName = "LGVCOM00010.retrieveInspectionRList";
				} else {
					listName = "LGVCOM00010.retrieveInspectionCList";
				}
			} else if("PREVIEW".equals(pReqType)) {
				if("R".equals(pStatus)) {
					listName = "LGVCOM00010.retrievePreviewRList";
				} else {
					listName = "LGVCOM00010.retrievePreviewCList";
				}
			} else {
				listName = "LGVCOM00010.retrieveRequestRList";
			}
		} else {
			listName = "LGVCOM00010.retrieveRequestRList";
		}
		return this.commonDao.selectList(listName, param);
	}
}
