/**
 *------------------------------------------------------------------------------
  * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAYP0007Service.java
 * @Desc    : Payroll Item Property List
 *
 * Copyright ⓒ 2018 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2018. 01. 11.  	limsujin  	최초 프로그램 작성                                     
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvpay.lgvpayp0007.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.util.LGCOMConstants;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.exception.LGCOMException;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvpay.lgvpay00013.service.LGVPAY00013Service;
import com.lgd.lgvhr.lgvpay.lgvpaycomm.service.LGVPAYCOMMService;
import com.lgd.lgvhr.lgvpay.lgvpayp0007.service.LGVPAYP0007Service;

import devonframe.util.NullUtil;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpayp0007.service.serviceImpl.LGVPAYP0007ServiceImpl.java
 * </PRE>
 *
 * @Author    limsujin
 * @Date      2018. 01. 11.
 * @Version
 */
@Service("LGVPAYP0007Service")
public class LGVPAYP0007ServiceImpl implements LGVPAYP0007Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVPAYP0007ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;
	
    @Resource(name="messageSourceAccessor")
    protected MessageSourceAccessor messageSourceAccessor;
    
    @Resource(name="LGVPAYCOMMService")
    private LGVPAYCOMMService lgvpaycomm;
    
    @Resource(name="LGVPAY00013Service")
    private LGVPAY00013Service lgvpay00013;

    /**
     * Desc : Payroll Item Proeprty List 를 조회한다.
     * @Method Name : retrievePayrollItemPropertyList
     * @param param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrievePayrollItemPropertyList(LGCOMData param) {
    	return this.commonDao.selectList("LGVPAYP0007.retrievePayrollItemPropertyList", param);
    }

    /**
     * Desc : 급여항목 Property 저장 전 체크 
     * - 급여 시스템담당자 권한이 있는지 체크
     * - 급여항목ID 있는지 체크
     * - 급여항목 수정/삭제 가능여부가 'Y'인지 체크. Y인 경우만 수정 가능함.
     * 
     * @Method Name : validateSaveProperty
     * @param param
     * @return boolean
     * @throws Exception
     */
	public boolean validateSaveProperty(LGCOMData param) {
    	boolean validateFlag = false;
    	
    	// 급여 시스템담당자 권한이 있는지 체크
    	validateFlag = lgvpaycomm.retrievePaySystemMasterAuthFlag(param); 
    	if ( !validateFlag ) {//급여담당자 권한이 없는 경우
    		throw new LGCOMException(messageSourceAccessor.getMessage("note.NoPermission"));
    		
    	// 급여항목ID 있는지 체크
    	} else if ( NullUtil.isNone(param.getData("parameter").getString("payrollItemId")) ) {//급여항목ID 없는 경우
    		throw new LGCOMException(messageSourceAccessor.getMessage("note.pay.noSelectedPayrollItem"));
    		
    	} else {
    		// 급여항목 수정/삭제 가능여부가 'Y'인지 체크. Y인 경우만 등록, 수정, 삭제 가능함.
    		LGCOMData tempData = new LGCOMData();
    		tempData.set( "payrollItemId", param.getData("parameter").get("payrollItemId") );
    		tempData.set( LGCOMConstants.HTTP_SESSION_KEY,  param.getData(LGCOMConstants.HTTP_SESSION_KEY) );
    		tempData.set( "LGVHR_PROJECT_SESSION",  param.getData("LGVHR_PROJECT_SESSION") );
    		
    		LGCOMData itemData = lgvpay00013.retrievePayrollItemData(tempData);
    		if ( NullUtil.isNull(itemData) && !"Y".equals(itemData.getString("delUptPossibleFlag")) ) {//수정, 삭제불가능한 경우
    			throw new LGCOMException(messageSourceAccessor.getMessage("note.pay.saveAlreadyRunResult"));
    		}
    	}
    	validateFlag = true;
    	
    	return validateFlag;
    }
    
    /**
     * Desc : 급여 항목 Property 수정한다.
     * - 저장 전 체크
     * - 수정 건 처리
     * 
     * @Method Name : saveProperty
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
	@SuppressWarnings("unchecked")
	@Transactional(propagation=Propagation.REQUIRED)
    public LGCOMData saveProperty(LGCOMData param) {
        LGCOMData userSession = param.getData(LGCOMConstants.HTTP_SESSION_KEY);
        LGCOMData projectSession = param.getData("LGVHR_PROJECT_SESSION");
        LGCOMData paramData = param.getData("parameter");
        
		//저장 전 체크
		if ( validateSaveProperty(param) ) {
		
			//수정건 처리
            List<LGCOMData> uList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_UPDATE);
            for ( LGCOMData item : LGCOMUtils.emptyIfNull(uList) ) {
            	item.set( LGCOMConstants.HTTP_SESSION_KEY, userSession );
            	item.set( "LGVHR_PROJECT_SESSION", projectSession );
            	item.set( "payrollItemId", paramData.get("payrollItemId"));
            	
            	//Detail 수정
            	commonDao.update("LGVPAYP0007.updatePayrollItemProperty", item);
            }
		}
		return param;
	}
}
