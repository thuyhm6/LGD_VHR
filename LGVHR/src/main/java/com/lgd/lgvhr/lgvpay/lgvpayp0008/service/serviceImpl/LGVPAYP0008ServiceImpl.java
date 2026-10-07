/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAYP0008Service.java
 * @Desc    : Payroll Item Use List
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
package com.lgd.lgvhr.lgvpay.lgvpayp0008.service.serviceImpl;

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
import com.lgd.lgvhr.lgvpay.lgvpayp0008.service.LGVPAYP0008Service;
import com.lgd.lgvhr.lgvpay.util.LGVPAYUtil;

import devonframe.util.DateUtil;
import devonframe.util.NullUtil;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpayp0008.service.serviceImpl.LGVPAYP0008ServiceImpl.java
 * </PRE>
 *
 * @Author    limsujin
 * @Date      2018. 01. 05.
 * @Version
 */
@Service("LGVPAYP0008Service")
public class LGVPAYP0008ServiceImpl implements LGVPAYP0008Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVPAYP0008ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;
	
    @Resource(name="messageSourceAccessor")
    protected MessageSourceAccessor messageSourceAccessor;
    
    @Resource(name="LGVPAYCOMMService")
    private LGVPAYCOMMService lgvpaycomm;
    
    @Resource(name="LGVPAY00013Service")
    private LGVPAY00013Service lgvpay00013;

    /**
     * Desc : Payroll Item Use List 를 조회한다.
     * @Method Name : retrievePayrollItemUseList
     * @param param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrievePayrollItemUseList(LGCOMData param) {
    	return this.commonDao.selectList("LGVPAYP0008.retrievePayrollItemUseList", param);
    }

    /**
     * Desc : Payroll Item Use 저장 전 체크 
     * - 급여 시스템담당자 권한이 있는지 체크
     * - 급여항목ID 있는지 체크
     * - 입력값 체크.
     *   - 필수입력 체크
     *   - StartDate
     *     - 날짜포맷(dd/mm/yyyy) 체크
     *   - EndDate 
     *     - 날짜포맷(dd/mm/yyyy) 체크
     *     - 종료일이 시작일 이후인지 체크
     * - 유효성 체크(급여 계산에서 사용되었는지 여부와 관계없이 항상 등록/수정/삭제 가능함)
     *   - Use항목의 유효기간 중복 체크
     * 
     * @Method Name : validateSaveUse
     * @param param
     * @return boolean
     * @throws Exception
     */
	public boolean validateSaveUse(LGCOMData param) {
    	boolean validateFlag = false;
    	
    	// 급여 시스템담당자 권한이 있는지 체크
    	validateFlag = lgvpaycomm.retrievePaySystemMasterAuthFlag(param); 
    	if ( !validateFlag ) {//급여담당자 권한이 없는 경우
    		throw new LGCOMException(messageSourceAccessor.getMessage("note.NoPermission"));
    		
    	// 급여항목ID 있는지 체크
    	} else if ( NullUtil.isNone(param.getData("parameter").getString("payrollItemId")) ) {//급여항목ID 없는 경우
    		throw new LGCOMException(messageSourceAccessor.getMessage("note.pay.noSelectedPayrollItem"));
    		
    	} else {

    		//에러메세지
        	StringBuffer errorMsg = new StringBuffer();
            //필수체크 컬럼
            String[] requireFieldNames  = new String[] {"payrollTypeCode", "effectiveStartYyyymmdd", "effectiveEndYyyymmdd"};//필수 컬럼명
            String[] requireFieldTitles = new String[] { messageSourceAccessor.getMessage("label.pay.use")
                                                       , messageSourceAccessor.getMessage("StartDate")
                                                       , messageSourceAccessor.getMessage("EndDate") };//컬럼 화면 label
            
            List<LGCOMData> culist = LGCOMData.createList();//등록, 수정 List객체 담기 위한 빈 객체 선언. 등록 List객체 선언 후 수정 List 객체를 addAll하는 경우 등록 객체에 수정객체가 추가되는 문제가 있어서 빈 객체 선언하여 사용함.
            culist.addAll(param.getList(LGCOMConstants.STATUS_INSERT));
            culist.addAll(param.getList(LGCOMConstants.STATUS_UPDATE));
            
            //신규건 또는 수정건 체크
	        for ( LGCOMData item : LGCOMUtils.emptyIfNull(culist) ) {
	        	//필수값 체크
	        	if ( requireFieldNames.length > 0 ) {
	        		for ( int i=0; i<requireFieldNames.length; i++ ) {
	        			if ( NullUtil.isNone(item.getString(requireFieldNames[i])) ) {
	        				throw new LGCOMException(messageSourceAccessor.getMessage("error.required", new Object[]{requireFieldTitles[i]}));
	        			}
	        		}
	        	}//end-if ( requireFieldNames.length > 0 )
	        	
        		//시작일 포맷 체크
        		if ( !LGVPAYUtil.validateDateFormat(item.getString("effectiveStartYyyymmdd")) ) {
        			throw new LGCOMException(messageSourceAccessor.getMessage("error.incorrectFormat")+"("+ messageSourceAccessor.getMessage("StartDate") +")");
        		}
        		
        		//종료일 포맷 체크
        		if ( !LGVPAYUtil.validateDateFormat(item.getString("effectiveEndYyyymmdd")) ) {
        			throw new LGCOMException(messageSourceAccessor.getMessage("error.incorrectFormat")+"("+ messageSourceAccessor.getMessage("EndDate") +")");
        		}
        		
        		//시작일이 종료일 이후인지 체크
        		if ( DateUtil.isAfter(LGVPAYUtil.getFormattedDate(item.getString("effectiveStartYyyymmdd")), LGVPAYUtil.getFormattedDate(item.getString("effectiveEndYyyymmdd"))) ) {
        			throw new LGCOMException(messageSourceAccessor.getMessage("error.DataRangePickerFromDate"));
        		}
	        	
	        }//end-for
    		
    		// 항목의 유효기간 중복 체크
            LGCOMData validateData = commonDao.select("LGVPAYP0008.retireveValidateData", param);
            if ( !NullUtil.isNull(validateData) ) {
	        	//에러메세지 초기화
	        	errorMsg.delete(0, errorMsg.length());
                //항목명 중복 체크
            	if ( NullUtil.notNone(validateData.getString("dupPayrollTypeNames")) ) {
            		errorMsg.append(messageSourceAccessor.getMessage("error.duplicateValue"))
            		        .append(validateData.getString("dupPayrollTypeNamesTitle"))
            		        .append(validateData.getString("dupPayrollTypeNames"));
    	    		throw new LGCOMException(errorMsg.toString());
    	    		
            	}
            }
        	validateFlag = true;
    	}
    	return validateFlag;
    }

    /**
     * Desc : 급여 항목 Use 등록/수정/삭제한다.
     * - 저장 전 체크
     * - 삭제 건 처리
     *   - Use 항목 삭제
     * - 수정 건 처리
     * - 등록 건 처리
     *   - Use 항목 등록
     * 
     * @Method Name : saveUse
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
	@SuppressWarnings("unchecked")
	@Transactional(propagation=Propagation.REQUIRED)
    public LGCOMData saveUse(LGCOMData param) {
        LGCOMData userSession = param.getData(LGCOMConstants.HTTP_SESSION_KEY);
        LGCOMData projectSession = param.getData("LGVHR_PROJECT_SESSION");
        LGCOMData paramData = param.getData("parameter");
		
		//저장 전 체크
		if ( validateSaveUse(param) ) {
			//삭제건 처리
            List<LGCOMData> dList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_DELETE);

            for ( LGCOMData item : LGCOMUtils.emptyIfNull(dList) ) {
            	item.set( LGCOMConstants.HTTP_SESSION_KEY, userSession );
            	item.set( "LGVHR_PROJECT_SESSION", projectSession );
            	item.set( "payrollItemId", paramData.get("payrollItemId"));
            	
            	//Use 삭제
            	commonDao.delete("LGVPAYP0008.deletePayrollItemUse", item);
            }
		
			//수정건 처리
            List<LGCOMData> uList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_UPDATE);
            for ( LGCOMData item : LGCOMUtils.emptyIfNull(uList) ) {
            	item.set( LGCOMConstants.HTTP_SESSION_KEY, userSession );
            	item.set( "LGVHR_PROJECT_SESSION", projectSession );
            	item.set( "payrollItemId", paramData.get("payrollItemId"));
            	
            	//Use 수정
            	commonDao.update("LGVPAYP0008.updatePayrollItemUse", item);
            }
		
			//등록건 처리
            List<LGCOMData> cList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_INSERT);
            for ( LGCOMData item : LGCOMUtils.emptyIfNull(cList) ) {
            	item.set( LGCOMConstants.HTTP_SESSION_KEY, userSession );
            	item.set( "LGVHR_PROJECT_SESSION", projectSession );
            	item.set( "payrollItemId", paramData.get("payrollItemId"));
            	
            	//Use 등록
            	commonDao.insert("LGVPAYP0008.insertPayrollItemUse", item);
            }
		}
		return param;
	}
}
