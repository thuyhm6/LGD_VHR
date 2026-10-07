/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : lgvpay00005ServiceImpl.java
 * @Desc    : 명세서 오픈일 관리
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2017. 12. 21.    bakderia    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvpay.lgvpay00011.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.util.LGCOMConstants;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvpay.lgvpay00011.service.LGVPAY00011Service;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpay00011.controller.LGVPAY00011Controller.java
 * </PRE>
 *
 * @Author    bakderia
 * @Date      2017. 12. 21. 오후 18:26:35
 * @Version
 */
@Service(value="LGVPAY00011Service")
public class LGVPAY00011ServiceImpl implements LGVPAY00011Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVPAY00011ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;
	
	@Resource(name="messageSourceAccessor")
    protected MessageSourceAccessor messageSourceAccessor;

	/**
	 * Desc : 명세서 오픈일을 조회한다.
	 * @Method Name : retrievePaySlipOpenDateMngList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrievePaySlipOpenDateMngList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVPAY00011.retrievePaySlipOpenDateMngList",param);
	}
	
	/**
     * Desc : 명세서 오픈일을 수정한다.
     * @Method Name : savePaySlipOpenDateMng
     * @param  param
     * @throws Exception
     */
    @SuppressWarnings("unchecked")
	public void savePaySlipOpenDateMng(LGCOMData param) {
		LOGGER.debug("param = " + param);
		
		List<LGCOMData> updateList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_UPDATE);
		String[] paySlipOpenDateSplit = null;
		String soeOpenDate = "";
		//수정처리
		for( LGCOMData uItem : LGCOMUtils.emptyIfNull(updateList) ) {
			if(uItem.getString("paySlipOpenDate").length() > 0 && uItem.getString("paySlipOpenDate") != null) {
				paySlipOpenDateSplit = uItem.getString("paySlipOpenDate").split("/");
				soeOpenDate = paySlipOpenDateSplit[2]+paySlipOpenDateSplit[1]+paySlipOpenDateSplit[0]+uItem.getString("hour")+uItem.getString("minutes");  
			}
			uItem.set("soeOpenDate", soeOpenDate);
			uItem.set("payrollCalculationExecId", uItem.getString("payrollCalculationExecId"));
			
			this.commonDao.update("LGVPAY00011.updatePaySlipOpenDateMng",uItem);
		}
	}
}
