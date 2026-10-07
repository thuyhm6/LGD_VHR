/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAY00013ServiceImpl.java
 * @Desc    : Payment Master All Employee
 *
 * Copyright ⓒ 2018 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2018. 01. 03.  	limsujin  	최초 프로그램 작성                                     
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvpay.lgvpay00013.service.serviceImpl;

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
import com.lgd.lgvhr.lgvpay.util.LGVPAYUtil;

import devonframe.util.DateUtil;
import devonframe.util.NullUtil;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpay00013.service.serviceImpl.LGVPAY00013ServiceImpl.java
 * </PRE>
 *
 * @Author    limsujin
 * @Date      2018. 01. 03.
 * @Version
 */
@Service("LGVPAY00013Service")
public class LGVPAY00013ServiceImpl implements LGVPAY00013Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVPAY00013ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;
	
    @Resource(name="messageSourceAccessor")
    protected MessageSourceAccessor messageSourceAccessor;
    
    @Resource(name="LGVPAYCOMMService")
    private LGVPAYCOMMService lgvpaycomm;

	/**
	 * Desc : 급여 항목을 조회한다.
	 * @Method Name : retrievePayrollItemList
	 * @param  param
	 * @return List<LGCOMData>
	 * @throws Exception
	 */
	public List<LGCOMData> retrievePayrollItemList(LGCOMData param) {
		return commonDao.selectList("LGVPAY00013.retrievePayrollItemList", param);
    }
    
    /**
     * Desc : 급여항목 아이디에 대한 급여항목 정보를 조회한다.
     * @Method Name : retrievePayrollItemData
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
    public LGCOMData retrievePayrollItemData(LGCOMData param) {
    	param.set( "srchPayrollItemId", param.get( "payrollItemId" ));
    	return commonDao.select("LGVPAY00013.retrievePayrollItemList", param);
    }
    
    /**
     * Desc : 급여항목 수정 또는 삭제 가능한지 여부를 조회한다.
     * @Method Name : retrievePayrollItemModifyEnableFlag
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
    public boolean retrievePayrollItemModifyEnableFlag(LGCOMData param) {
		LGCOMData payrollItemData = this.retrievePayrollItemData(param);

		//급여항목 삭제가능 여부가 'Y'인 경우만 처리
		if ( !NullUtil.isNull(payrollItemData) && "Y".equals(payrollItemData.getString("delUptPossibleFlag")) ) {
			return true;
		}
		return false;
    }
    
    /**
     * Desc : PAY_VALUE 기본 등록하는 classCode인지 조회한다.
     * @Method Name : retrievePayValueInsertFlag
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
    public boolean retrievePayValueInsertFlag(LGCOMData param) {
    	param.set( "valueSetId", "LGVPAY_PAY_ITEM_CLASSIFICATION_CODE_LIST" );
    	param.set( "languageCode", param.getData(LGCOMConstants.HTTP_SESSION_KEY).get("languageCode"));
    	param.set( "payItemClassificationCode", param.getString("payItemClassificationCode") );
    	
    	List<LGCOMData> classData = this.commonDao.executeValueSetQuery(param);
    	
    	if ( classData.size() > 0 && "Y".equals(((LGCOMData)classData.get(0)).getString("payValueFlag")) ) {
    		return true;
    	}
    	return false;
    }
    
    /**
     * Desc : Payroll Item Class 정보를 조회한다.
     * @Method Name : retrievePayrollItemClassData
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
    public LGCOMData retrievePayrollItemClassData(LGCOMData param) {
    	return commonDao.select("LGVPAY00013.retrievePayrollItemClassData", param);
    }

    /**
     * Desc : Payroll Item 저장 전 체크 
     * - 급여 시스템담당자 권한이 있는지 체크
     * - 입력값 체크
     *   - 필수입력 체크
     *   - StartDate
     *     - 날짜포맷(dd/mm/yyyy) 체크
     *   - EndDate 
     *     - 날짜포맷(dd/mm/yyyy) 체크
     *     - 종료일이 시작일 이후인지 체크
     *   - 수정인 경우 수정가능 행에서 수정 불가 컬럼 변경여부 체크
     * - 삭제 가능여부 체크
     *   - 삭제 가능여부가 Y가 아닌 경우 삭제 불가 체크
     * - 유효성 체크
     *   - Payroll Item Name 중복 체크
     * 
     * @Method Name : validateSavePayrollItem
     * @param param
     * @return boolean
     * @throws Exception
     */
    public boolean validateSavePayrollItem(LGCOMData param) {
    	boolean validateFlag = false;
    	
    	validateFlag = lgvpaycomm.retrievePaySystemMasterAuthFlag(param); 
    	if ( !validateFlag ) {//급여담당자 권한이 없는 경우
    		throw new LGCOMException(messageSourceAccessor.getMessage("note.NoPermission"));
    		
    	} else {
    		
    		//에러메세지
        	StringBuffer errorMsg = new StringBuffer();
            //필수체크 컬럼
            String[] requireFieldNames  = new String[] {"payrollItemName", "inquiryName", "detailDesc", "payItemClassificationCode", "priority", "startDate", "endDate"};//필수 컬럼명
            String[] requireFieldTitles = new String[] { messageSourceAccessor.getMessage("label.pay.payrollItemName")
                                                       , messageSourceAccessor.getMessage("label.pay.inquiryName")
                                                       , messageSourceAccessor.getMessage("Description")
                                                       , messageSourceAccessor.getMessage("label.pay.classification")
                                                       , messageSourceAccessor.getMessage("label.pay.priority")
                                                       , messageSourceAccessor.getMessage("StartDate")
                                                       , messageSourceAccessor.getMessage("EndDate") };//컬럼 화면 label
            //수정불가체크 컬럼
            String[] unChangeFieldNames  = new String[] {"payrollItemName", "payItemClassificationCode", "priority", "payrollCalcFormulaValue", "startDate"};//필수 컬럼명
            String[] unChangeFieldTitles = new String[] { messageSourceAccessor.getMessage("label.pay.payrollItemName")
                                                        , messageSourceAccessor.getMessage("label.pay.classification")
                                                        , messageSourceAccessor.getMessage("label.pay.priority")
                                                        , messageSourceAccessor.getMessage("label.pay.formula")
                                                        , messageSourceAccessor.getMessage("StartDate") };//컬럼 화면 label

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
        		if ( !LGVPAYUtil.validateDateFormat(item.getString("startDate")) ) {
        			throw new LGCOMException(messageSourceAccessor.getMessage("error.incorrectFormat")+"("+ messageSourceAccessor.getMessage("StartDate") +")");
        		}
        		
        		//종료일 포맷 체크
        		if ( !LGVPAYUtil.validateDateFormat(item.getString("endDate")) ) {
        			throw new LGCOMException(messageSourceAccessor.getMessage("error.incorrectFormat")+"("+ messageSourceAccessor.getMessage("EndDate") +")");
        		}
        		
        		//시작일이 종료일 이후인지 체크
        		if ( DateUtil.isAfter(LGVPAYUtil.getFormattedDate(item.getString("startDate")), LGVPAYUtil.getFormattedDate(item.getString("endDate"))) ) {
        			throw new LGCOMException(messageSourceAccessor.getMessage("error.DataRangePickerFromDate"));
        		}
	        	
	        	//수정건인 경우 급여실행결과 있으면 payrollTypeCode 수정 불가 체크
	        	if ( NullUtil.notNone(item.getString("payrollItemId")) ) {
		        	
		        	item.set( LGCOMConstants.HTTP_SESSION_KEY, param.getData(LGCOMConstants.HTTP_SESSION_KEY) );
		        	item.set( "LGVHR_PROJECT_SESSION", param.getData("LGVHR_PROJECT_SESSION") );
		        	//Payroll Item 데이터 조회
		        	LGCOMData payrollItemData = this.retrievePayrollItemData(item);
		        	//에러메세지 초기화
		        	errorMsg.delete(0, errorMsg.length());
		        	
		        	if ( !NullUtil.isNull(payrollItemData) ) {
		        		//급여실행결과 있는 경우 수정불가 컬럼값 변경여부 체크
		        		if ( !"Y".equals(payrollItemData.getString("delUptPossibleFlag")) ) {
		        			
		    	        	//수정불가 컬럼 체크
		    	        	if ( unChangeFieldNames.length > 0 ) {
		    	        		for ( int k=0; k<unChangeFieldNames.length; k++ ) {
		    			        	errorMsg.delete(0, errorMsg.length());
		    	        			if ( !NullUtil.nvl(item.getString(unChangeFieldNames[k]), "").equals(NullUtil.nvl(payrollItemData.getString(unChangeFieldNames[k]), "")) ) {
		    		        			//이미 실행된 결과가 있으므로 저장 불가능합니다.
		    		            		errorMsg.append(messageSourceAccessor.getMessage("note.pay.saveAlreadyRunResult"))
		    	        		        		.append("<br/>")
		    			        		        .append(unChangeFieldTitles[k])
		    			        		        .append("=")
		    			        		        .append(NullUtil.nvl(item.getString(unChangeFieldNames[k]), ""));
		    		            		throw new LGCOMException(errorMsg.toString());
		    	        			}
		    	        		}
		    	        	}//if ( requireFieldNames.length > 0 )
		    	        	
		        		}//if ( !"Y".equals(payrollItemData.getString("delUptPossibleFlag")) ) {
		        	}
	        	}
	        }//end-for
    		
    		//삭제건 체크
	        for ( LGCOMData item : LGCOMUtils.emptyIfNull(param.getList(LGCOMConstants.STATUS_DELETE)) ) {
	        	
	        	item.set( LGCOMConstants.HTTP_SESSION_KEY, param.getData(LGCOMConstants.HTTP_SESSION_KEY) );
	        	item.set( "LGVHR_PROJECT_SESSION", param.getData("LGVHR_PROJECT_SESSION") );
	        	//에러메세지 초기화
	        	errorMsg.delete(0, errorMsg.length());

	    		//급여항목 삭제가능 여부가 'Y'인 경우만 처리
        		if ( !retrievePayrollItemModifyEnableFlag(item) ) {
        			//이미 실행된 결과가 있으므로 삭제 불가능합니다.
            		errorMsg.append(messageSourceAccessor.getMessage("note.pay.deleteAlreadyRunResult"))
	        				.append("<br/>")
	        		        .append(messageSourceAccessor.getMessage("label.pay.payrollItemName"))
	        		        .append("=")
	        		        .append(item.getString("payrollItemName"));
            		throw new LGCOMException(errorMsg.toString());
        		}
	        	
	        }//end-for
            
            LGCOMData validateData = commonDao.select("LGVPAY00013.retireveValidatePayrollItemData", param);
            if ( !NullUtil.isNull(validateData) ) {
	        	//에러메세지 초기화
	        	errorMsg.delete(0, errorMsg.length());
	        	
            	//Payroll Item Name 중복 체크
            	if ( NullUtil.notNone(validateData.getString("dupNames")) ) {		            		
            		errorMsg.append(messageSourceAccessor.getMessage("error.duplicateValue"))
            		        .append(validateData.getString("dupNamesTitle"))
            		        .append(validateData.getString("dupNames"));
    	    		throw new LGCOMException(errorMsg.toString());
	            }
            }//end-if ( !NullUtil.isNull(validateData) ) 
    		validateFlag = true;
    	}
    	
    	return validateFlag;
    }
    
    /**
     * Desc : 급여 항목을 등록/수정/삭제한다.
     * - 급여 시스템 담당자 권한 보유여부 체크
     * - 급여항목 삭제건 처리.(급여항목 중복 체크 시 화면에서 삭제한 건은 제외하고 체크하기 위해 가장 먼저 수행함)
     * - 급여항목 등록건 처리
     *   - 급여항목명 중복 체크
     *   - 급여항목 시퀀스 조회
     *   - 급여항목 신규등록
     *   - 급여항목 Detail 등록. PAY_VALUE 있는 class_code인 경우 PAY_VALUE 기본값 등록
     *   - 급여항목 Property 등록. 일괄 N으로 등록하고 사용자가 수정하도록 함.
     * - 급여항목 수정건 처리
     *   - 급여항목 수정
     *   - 급여항목 Detail에 PAY_VALUE 등록 및 삭제
     *     - PAY_VALUE 있는 class_code인 경우 Detail 에 없으면 등록, 있는 경우 변경하지 않음.
     *     - PAY_VALUE 없는 class_code인 경우 Detail 에 있으면 삭제, 없는 경우 추가하지 않음.
     * 
     * @Method Name : savePayrollItem
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
	@SuppressWarnings("unchecked")
	@Transactional(propagation=Propagation.REQUIRED)
    public LGCOMData savePayrollItem(LGCOMData param) {
		
    	if ( validateSavePayrollItem(param) ) {//값 체크 정상인 경우 처리

	        LGCOMData userSession = param.getData(LGCOMConstants.HTTP_SESSION_KEY);
	        LGCOMData projectSession = param.getData("LGVHR_PROJECT_SESSION");
    		
    		/* 삭제건 처리 */
            List<LGCOMData> dList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_DELETE);
            for( LGCOMData item : LGCOMUtils.emptyIfNull(dList) ) {

            	item.set( LGCOMConstants.HTTP_SESSION_KEY, userSession );
            	item.set( "LGVHR_PROJECT_SESSION", projectSession );

    			//급여항목 Use 전체 삭제
    			commonDao.delete("LGVPAY00013.deletePayrollItemUseAll", item);
    			//급여항목 Property 전체 삭제
    			commonDao.delete("LGVPAY00013.deletePayrollItemCalcPropertyAll", item);
    			//급여항목 Detail 전체 삭제
    			commonDao.delete("LGVPAY00013.deletePayrollItemDetailAll", item);
    			//급여항목 삭제
    			commonDao.delete("LGVPAY00013.deletePayrollItem", item);
            }
    		
            /* 수정건 저장 */
            List<LGCOMData> uList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_UPDATE);
            for( LGCOMData item : LGCOMUtils.emptyIfNull(uList) ) {
            	item.set( LGCOMConstants.HTTP_SESSION_KEY, userSession );
            	item.set( "LGVHR_PROJECT_SESSION", projectSession );

            	//PAY_VALUE 없는 class_code인 경우 등록된 PAY_VALUE 삭제
            	if ( !retrievePayValueInsertFlag(item) ) {
            		//Detail에 등록된 PAY_VALUE 삭제
            		commonDao.delete("LGVPAY00013.deletePayrollItemDetail", item);
            	} else {
            		//Detail에 PAY_VALUE 등록
            		commonDao.insert("LGVPAY00013.insertPayrollItemDetail", item);
            	}
            	//급여항목 수정
            	commonDao.update("LGVPAY00013.updatePayrollItem", item);
            }
    		
            /* 등록건 저장 */
            List<LGCOMData> cList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_INSERT);
            for( LGCOMData item : LGCOMUtils.emptyIfNull(cList) ) {
            	item.set( LGCOMConstants.HTTP_SESSION_KEY, userSession );
            	item.set( "LGVHR_PROJECT_SESSION", projectSession );
            	
            	//급여항목 아이디 조회
            	LGCOMData idData = commonDao.select("LGVPAY00013.retrievePayrollItemId");
            	
            	if ( !NullUtil.isNull(idData) ) {
            		item.set( "payrollItemId", idData.getString("payrollItemId") );
            		
            		//급여항목등록
            		commonDao.insert("LGVPAY00013.insertPayrollItem", item);
            		//Detail에 PAY_VALUE 등록
            		commonDao.insert("LGVPAY00013.insertPayrollItemDetail", item);
            		//Property 등록
            		commonDao.insert("LGVPAY00013.insertPayrollItemCalcProperty", item);
            	}
            }
    	}
    	return param;
    }
	
	/**
	 * Desc : 소급집게 리스트 조회한다.
	 * @Method Name : retrieveAggrItemList
	 * @param  LGCOMData param
	 * @return List<LGCOMData>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveAggrItemList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVPAY00013.retrieveAggrItemList", param);
	}

	// checkDownload 10/11/2025 Vanaa
	public LGCOMData checkDownload(LGCOMData param) {
		return this.commonDao.select("LGVPAY00012.checkDownload", param);
	}
}
