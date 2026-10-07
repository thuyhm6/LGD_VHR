/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAYP0006Service.java
 * @Desc    : Payroll Item Detail List
 *
 * Copyright ⓒ 2018 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2018. 01. 05.  	limsujin  	최초 프로그램 작성                                     
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvpay.lgvpayp0006.service.serviceImpl;

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
import com.lgd.lgvhr.lgvpay.lgvpayp0006.service.LGVPAYP0006Service;

import devonframe.util.NullUtil;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpayp0006.service.serviceImpl.LGVPAYP0006ServiceImpl.java
 * </PRE>
 *
 * @Author    limsujin
 * @Date      2018. 01. 05.
 * @Version
 */
@Service("LGVPAYP0006Service")
public class LGVPAYP0006ServiceImpl implements LGVPAYP0006Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVPAYP0006ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;
	
    @Resource(name="messageSourceAccessor")
    protected MessageSourceAccessor messageSourceAccessor;
    
    @Resource(name="LGVPAYCOMMService")
    private LGVPAYCOMMService lgvpaycomm;
    
    @Resource(name="LGVPAY00013Service")
    private LGVPAY00013Service lgvpay00013;

    /**
     * Desc : Payroll Item Detail List 를 조회한다.
     * @Method Name : retrievePayrollItemDetailList
     * @param param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrievePayrollItemDetailList(LGCOMData param) {
    	return this.commonDao.selectList("LGVPAYP0006.retrievePayrollItemDetailList", param);
    }

    /**
     * Desc : Payroll Item Detail 저장 전 체크 
     * - 급여 시스템담당자 권한이 있는지 체크
     * - 급여항목ID 있는지 체크
     * - 급여항목 수정/삭제 가능여부가 'Y'인지 체크. Y인 경우만 등록, 수정, 삭제 가능함.
     * - 저장할 Detail 항목이 PAY_VALUE인지 체크. PAY_VALUE는 등록, 수정, 삭제 불가능함.
     * - 항목명 중복 체크
     * - 정렬순서번호 중복 체크
     * - 10건 초과인지 체크
     * 
     * @Method Name : validateSaveDetail
     * @param param
     * @return boolean
     * @throws Exception
     */
    @SuppressWarnings("unchecked")
	public boolean validateSaveDetail(LGCOMData param) {
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
    		
    		// 저장할 Detail 항목이 PAY_VALUE인지 체크. PAY_VALUE는 등록, 수정, 삭제 불가능함.
    		String detailItemName = "PAY_VALUE";
    		//등록 건
            for ( LGCOMData item : LGCOMUtils.emptyIfNull((List<LGCOMData>)param.get(LGCOMConstants.STATUS_INSERT)) ) {
            	if ( detailItemName.equals(item.getString("detailName")) ) {
        			throw new LGCOMException(messageSourceAccessor.getMessage("note.pay.payValueCannotRegister"));
            	}
            }
    		//수정 건
            for ( LGCOMData item : LGCOMUtils.emptyIfNull((List<LGCOMData>)param.get(LGCOMConstants.STATUS_UPDATE)) ) {
            	if ( detailItemName.equals(item.getString("detailName")) ) {
        			throw new LGCOMException(messageSourceAccessor.getMessage("note.pay.payValueCannotModify"));
            	}
            }
    		//삭제 건
            for ( LGCOMData item : LGCOMUtils.emptyIfNull((List<LGCOMData>)param.get(LGCOMConstants.STATUS_DELETE)) ) {
            	if ( detailItemName.equals(item.getString("detailName")) ) {
        			throw new LGCOMException(messageSourceAccessor.getMessage("note.pay.payValueCannotDelete"));
            	}
            }
            
            LGCOMData validateData = commonDao.select("LGVPAYP0006.retireveValidateData", param);
            if ( !NullUtil.isNull(validateData) ) {
            	StringBuffer errorMsg = new StringBuffer();
                //항목명 중복 체크
            	if ( NullUtil.notNone(validateData.getString("dupNames")) ) {
            		errorMsg.append(messageSourceAccessor.getMessage("error.duplicateValue"))
            		        .append(validateData.getString("dupNamesTitle"))
            		        .append(validateData.getString("dupNames"));
    	    		throw new LGCOMException(errorMsg.toString());
    	    		
    	    	// 정렬순서번호 중복 체크
            	} else if ( NullUtil.notNone(validateData.getString("dupSortNames")) ) {
            		errorMsg.append(messageSourceAccessor.getMessage("error.duplicateValue"))
    		                .append(validateData.getString("dupSortNamesTitle"))
		    		        .append(validateData.getString("dupSortNames"));
		            		throw new LGCOMException(errorMsg.toString());
		            		
		        // 10건 초과인지 체크
            	} else if ( "Y".equals(validateData.getString("limitRowOverFlag")) ) {
    	    		throw new LGCOMException(messageSourceAccessor.getMessage("error.tenrows", new Object[]{validateData.getString("limitRow")}));
            	}
            }
    	}
    	validateFlag = true;
    	
    	return validateFlag;
    }
    
    /**
     * Desc : 급여 항목 Detail 등록/수정/삭제한다.
     * - 저장 전 체크
     * - 삭제 건 처리
     *   - Detail 항목 삭제
     * - 등록 건 처리
     *   - Detail 항목 등록
     * - 수정 건 처리
     *   - Detail 항목 수정
     * 
     * @Method Name : saveDetail
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
	@SuppressWarnings("unchecked")
	@Transactional(propagation=Propagation.REQUIRED)
    public LGCOMData saveDetail(LGCOMData param) {
        LGCOMData userSession = param.getData(LGCOMConstants.HTTP_SESSION_KEY);
        LGCOMData projectSession = param.getData("LGVHR_PROJECT_SESSION");
        LGCOMData paramData = param.getData("parameter");
        
		//저장 전 체크
		if ( validateSaveDetail(param) ) {
			
			LOGGER.debug("저장 처리 시작 ");
		
			//삭제건 처리
            List<LGCOMData> dList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_DELETE);

            for ( LGCOMData item : LGCOMUtils.emptyIfNull(dList) ) {
            	item.set( LGCOMConstants.HTTP_SESSION_KEY, userSession );
            	item.set( "LGVHR_PROJECT_SESSION", projectSession );
            	item.set( "payrollItemId", paramData.get("payrollItemId"));
            	
            	//Detail 삭제
            	commonDao.delete("LGVPAYP0006.deletePayrollItemDetail", item);
            }
		
			//등록건 처리
            List<LGCOMData> cList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_INSERT);
            for ( LGCOMData item : LGCOMUtils.emptyIfNull(cList) ) {
            	item.set( LGCOMConstants.HTTP_SESSION_KEY, userSession );
            	item.set( "LGVHR_PROJECT_SESSION", projectSession );
            	item.set( "payrollItemId", paramData.get("payrollItemId"));
            	
            	//Detail 등록
            	commonDao.insert("LGVPAYP0006.insertPayrollItemDetail", item);
            }
		
			//수정건 처리
            List<LGCOMData> uList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_UPDATE);
            for ( LGCOMData item : LGCOMUtils.emptyIfNull(uList) ) {
            	item.set( LGCOMConstants.HTTP_SESSION_KEY, userSession );
            	item.set( "LGVHR_PROJECT_SESSION", projectSession );
            	item.set( "payrollItemId", paramData.get("payrollItemId"));
            	
            	//Detail 수정
            	commonDao.update("LGVPAYP0006.updatePayrollItemDetail", item);
            }
		}
		return param;
	}
}
