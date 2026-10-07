/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAY00014ServiceImpl.java
 * @Desc    : Formula Management
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2018. 01. 11.    limsujin    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvpay.lgvpay00014.service.serviceImpl;

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
import com.lgd.lgvhr.lgvpay.lgvpay00014.service.LGVPAY00014Service;
import com.lgd.lgvhr.lgvpay.lgvpaycomm.service.LGVPAYCOMMService;

import devonframe.util.NullUtil;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpay00014.service.serviceImpl.LGVPAY00014ServiceImpl.java
 * </PRE>
 *
 * @Author    limsujin
 * @Date      2018. 01. 11. 
 * @Version
 */
@Service("LGVPAY00014Service")
public class LGVPAY00014ServiceImpl implements LGVPAY00014Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVPAY00014ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;
	
    @Resource(name="messageSourceAccessor")
    protected MessageSourceAccessor messageSourceAccessor;
    
    @Resource(name="LGVPAYCOMMService")
    private LGVPAYCOMMService lgvpaycomm;


    /** 
     * Formula 목록을 조회한다.
     * @param param
     * @return
     */
    public List<LGCOMData> retrieveFormulaList(LGCOMData param) {
        return this.commonDao.selectList("LGVPAY00014.retrieveFormulaList", param);
    }
    
    /**
     * Desc : Formula 정보를 조회한다. 
     * @Method Name : retrieveFormulaData
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
    public LGCOMData retrieveFormulaData(LGCOMData param) {
    	param.set( "srchPayrollCalculationFormulaId", NullUtil.nvl(param.getString("srchPayrollCalculationFormulaId"), param.getString("payrollCalculationFormulaId")) );
    	return commonDao.select("LGVPAY00014.retrieveFormulaList", param);
    }
    
    /**
     * Desc : Formula 삭제 가능여부를 조회한다. 
     * @Method Name : retrieveFormulaDeleteFlag
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
    public boolean retrieveFormulaDeleteFlag(LGCOMData param) {
    	param.set( "srchPayrollCalculationFormulaId", NullUtil.nvl(param.getString("srchPayrollCalculationFormulaId"), param.getString("payrollCalculationFormulaId")) );
    	LGCOMData formulaData = commonDao.select("LGVPAY00014.retrieveFormulaList", param);
    	
    	if ( !NullUtil.isNull(formulaData) && "Y".equals(formulaData.getString("deleteEnableFlag")) ) {
    		return true;
    	}
    	return false;
    }

    /**
     * Desc : Formula 저장 전 체크 
     * - 급여 시스템담당자 권한이 있는지 체크
     * - 삭제인 경우 급여항목에 이미 등록된 Formula인지 체크
     * - Formula Program명 유무 체크
     * - Formula Program명 중복 체크
     * 
     * @Method Name : validateSaveFormula
     * @param param
     * @return boolean
     * @throws Exception
     */
    @SuppressWarnings("unchecked")
	public boolean validateSaveFormula(LGCOMData param) {
    	boolean validateFlag = false;
    	
    	validateFlag = lgvpaycomm.retrievePaySystemMasterAuthFlag(param); 
    	if ( !validateFlag ) {//급여담당자 권한이 없는 경우
    		throw new LGCOMException(messageSourceAccessor.getMessage("note.NoPermission"));
    		
    	} else {

    		//삭제 건
            for ( LGCOMData item : LGCOMUtils.emptyIfNull((List<LGCOMData>)param.get(LGCOMConstants.STATUS_DELETE)) ) {
            	if ( !retrieveFormulaDeleteFlag(item) ) {
            		//급여항목에 이미 등록된 Formula는 삭제 불가
        			throw new LGCOMException(messageSourceAccessor.getMessage("note.pay.deleteAlreadyExistsPayrollItem"));
            	}
            }
            
            LGCOMData validateData = commonDao.select("LGVPAY00014.retireveValidateFormulaData", param);
            if ( !NullUtil.isNull(validateData) ) {
            	StringBuffer errorMsg = new StringBuffer();
            	//Formula 명 유무 체크
            	if ( "Y".equals(validateData.getString("nameEmptyFlag")) ) {
            		throw new LGCOMException(messageSourceAccessor.getMessage("error.required", new Object[]{messageSourceAccessor.getMessage("label.pay.formulaProgram")}));
            	}
            	
                //formula program명 중복 체크
            	if ( NullUtil.notNone(validateData.getString("dupNames")) ) {
            		errorMsg.append(messageSourceAccessor.getMessage("error.duplicateValue"))
            		        .append(validateData.getString("dupNamesTitle"))
            		        .append(validateData.getString("dupNames"));
    	    		throw new LGCOMException(errorMsg.toString());
            	}
            }
    		validateFlag = true;
    	}
    	
    	return validateFlag;
    }

	/**
	 * Desc : Formula를 저장한다.
	 * - 값 유효성 체크
	 * - 삭제건 처리(데이터 삭제 후 같은 명칭으로 재등록할 수 있으므로 가장 먼저 삭제 처리함)
	 *   - Formula 삭제
	 *   - Formula 에 등록된 Detail 전체 삭제
	 * - 수정건 처리(데이터 수정 시 같은 명칭으로 변경할 수 있으므로 등록이전 수정 처리함)
	 * - 등록건 처리
	 * 
	 * @Method Name : saveFormulaList
	 * @param  param
	 * @throws Exception
	 */
	@SuppressWarnings("unchecked")
	@Transactional(propagation=Propagation.REQUIRED)
    public LGCOMData saveFormulaList(LGCOMData param){
		if ( validateSaveFormula(param) ) {//값 체크 정상인 경우 처리
			
	        LGCOMData userSession = param.getData(LGCOMConstants.HTTP_SESSION_KEY);
	        LGCOMData projectSession = param.getData("LGVHR_PROJECT_SESSION");
	        
	        /* 삭제건 처리 */
	        List<LGCOMData> dList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_DELETE);
	        for( LGCOMData item : LGCOMUtils.emptyIfNull(dList) ) {
	        	item.set( LGCOMConstants.HTTP_SESSION_KEY, userSession );
	        	item.set( "LGVHR_PROJECT_SESSION", projectSession );

	            this.commonDao.delete("LGVPAY00014.deleteFormulaDetailAll",item);
	            this.commonDao.delete("LGVPAY00014.deleteFormula",item);
	        }
	        
	        /* 수정건 저장 */
	        List<LGCOMData> uList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_UPDATE);
	        for( LGCOMData item : LGCOMUtils.emptyIfNull(uList) ) {
	        	item.set( LGCOMConstants.HTTP_SESSION_KEY, userSession );
	        	item.set( "LGVHR_PROJECT_SESSION", projectSession );
	            this.commonDao.update("LGVPAY00014.updateFormula",item);
	        }
	
	        /* 등록건 저장 */
	        List<LGCOMData> cList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_INSERT);
	        for( LGCOMData item : LGCOMUtils.emptyIfNull(cList) ) {
	        	item.set( LGCOMConstants.HTTP_SESSION_KEY, userSession );
	        	item.set( "LGVHR_PROJECT_SESSION", projectSession );

	            this.commonDao.insert("LGVPAY00014.insertFormula",item);
	        }
		}
		return param;
    }
    
    /** 
     * Formula Detail 목록을 조회한다.
     * @param param
     * @return
     */
    public List<LGCOMData> retrieveFormulaDetailList(LGCOMData param) {
        return this.commonDao.selectList("LGVPAY00014.retrieveFormulaDetailList", param);
    }

    /**
     * Desc : Formula Detail 저장 전 체크 
     * - 급여 시스템담당자 권한이 있는지 체크
     * - 정렬순서 중복 체크
     * - 파라메터명 중복 체크
     * - 필수컬럼 값 유무 체크
     * - OUT 파라메터인 경우 PayrollItemName, PayrollItemDetailName 필수 체크
     * 
     * @Method Name : validateSaveFormulaDetail
     * @param param
     * @return boolean
     * @throws Exception
     */
    @SuppressWarnings("unchecked")
	public boolean validateSaveFormulaDetail(LGCOMData param) {
    	boolean validateFlag = false;
    	
    	validateFlag = lgvpaycomm.retrievePaySystemMasterAuthFlag(param); 
    	if ( !validateFlag ) {//급여담당자 권한이 없는 경우
    		throw new LGCOMException(messageSourceAccessor.getMessage("note.NoPermission"));
    		
    	} else {
            
            LGCOMData validateData = commonDao.select("LGVPAY00014.retireveValidateFormulaDetailData", param);
            if ( !NullUtil.isNull(validateData) ) {
            	StringBuffer errorMsg = new StringBuffer();
                //정렬순서번호 중복 체크
            	if ( NullUtil.notNone(validateData.getString("dupSortOrders")) ) {
            		errorMsg.append(messageSourceAccessor.getMessage("error.duplicateValue"))
            		        .append(validateData.getString("dupSortOrdersTitle"))
            		        .append(validateData.getString("dupSortOrders"));
    	    		throw new LGCOMException(errorMsg.toString());
    	    		
   	    		//파라메터명 중복 체크
            	} else if ( NullUtil.notNone(validateData.getString("dupNames")) ) {
            		errorMsg.append(messageSourceAccessor.getMessage("error.duplicateValue"))
            		        .append(validateData.getString("dupNamesTitle"))
            		        .append(validateData.getString("dupNames"));
    	    		throw new LGCOMException(errorMsg.toString());
            	}
            }
            
            //OUT파라메터인 경우 Payroll Item Name, Payroll Item Detail Name 필수 체크
            //필수체크 컬럼
            String[] requireFieldNames  = new String[] {"sortOrderNo", "parameterIoTypeCode", "parameterValue", "dataTypeCode"};//필수 컬럼명
            String[] requireFieldTitles = new String[] { messageSourceAccessor.getMessage("SortOrder")
            		                                   , messageSourceAccessor.getMessage("label.pay.parameterType")
            		                                   , messageSourceAccessor.getMessage("ParameterName")
            		                                   , messageSourceAccessor.getMessage("DataType") };//필수 컬럼명 화면 label
            //신규건 체크
	        for ( LGCOMData item : LGCOMUtils.emptyIfNull((List<LGCOMData>)param.get(LGCOMConstants.STATUS_INSERT)) ) {
	        	//필수값 체크
	        	if ( requireFieldNames.length > 0 ) {
	        		for ( int i=0; i<requireFieldNames.length; i++ ) {
	        			if ( NullUtil.isNone(item.getString(requireFieldNames[i])) ) {
	        				throw new LGCOMException(messageSourceAccessor.getMessage("error.required", new Object[]{requireFieldTitles[i]}));
	        			}
	        		}
	        	//OUT 변수인 경우 필수값 체크
	        	} else if ( "OUT".equals(item.getString("parameterIoTypeCode")) 
	        			&& ( NullUtil.isNone(item.getString("payrollItemId")) || NullUtil.isNone(item.getString("payrollItemDetailDetailId")) ) ) {
	        		throw new LGCOMException(messageSourceAccessor.getMessage("note.pay.emptyPayrollItemOrPayrollItemDetail"));
	        	}
	        }
	        
	        //수정건 체크
	        for ( LGCOMData item : LGCOMUtils.emptyIfNull((List<LGCOMData>)param.get(LGCOMConstants.STATUS_UPDATE)) ) {
	        	//필수값 체크
	        	if ( requireFieldNames.length > 0 ) {
	        		for ( int i=0; i<requireFieldNames.length; i++ ) {
	        			if ( NullUtil.isNone(item.getString(requireFieldNames[i])) ) {
	        				throw new LGCOMException(messageSourceAccessor.getMessage("error.required", new Object[]{requireFieldTitles[i]}));
	        			}
	        		}
	        	//OUT 변수인 경우 필수값 체크
	        	} else if ( "OUT".equals(item.getString("parameterIoTypeCode")) 
	        			&& ( NullUtil.isNone(item.getString("payrollItemId")) || NullUtil.isNone(item.getString("payrollItemDetailDetailId")) ) ) {
	        		throw new LGCOMException(messageSourceAccessor.getMessage("note.pay.emptyPayrollItemOrPayrollItemDetail"));
	        	}
	        }
    		
    		validateFlag = true;
    	}
    	
    	return validateFlag;
    }

	/**
	 * Desc : Formula Detail 를 저장한다.
	 * - 값 유효성 체크
	 * - 삭제건 처리(데이터 삭제 후 같은 명칭으로 재등록할 수 있으므로 가장 먼저 삭제 처리함)
	 * - 수정건 처리(데이터 수정 시 같은 명칭으로 변경할 수 있으므로 등록이전 수정 처리함)
	 * - 등록건 처리
	 * 
	 * @Method Name : saveFormulaDetailList
	 * @param  param
	 * @throws Exception
	 */
	@SuppressWarnings("unchecked")
	@Transactional(propagation=Propagation.REQUIRED)
    public void saveFormulaDetailList(LGCOMData param){
		if ( validateSaveFormulaDetail(param) ) {//값 체크 정상인 경우 처리
			
	        LGCOMData userSession = param.getData(LGCOMConstants.HTTP_SESSION_KEY);
	        LGCOMData projectSession = param.getData("LGVHR_PROJECT_SESSION");
	        LGCOMData paramData = param.getData("parameter");
	
	        /* 삭제건 저장 */
	        List<LGCOMData> dList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_DELETE);
	        for( LGCOMData item : LGCOMUtils.emptyIfNull(dList) ) {
	        	item.set( LGCOMConstants.HTTP_SESSION_KEY, userSession );
	        	item.set( "LGVHR_PROJECT_SESSION", projectSession );
	        	item.set( "payrollCalculationFormulaId", paramData.get("payrollCalculationFormulaId"));
	        	
	            this.commonDao.delete("LGVPAY00014.deleteFormulaDetail", item);
	        }
	        
	        /* 수정건 저장 */
	        List<LGCOMData> uList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_UPDATE);
	        for( LGCOMData item : LGCOMUtils.emptyIfNull(uList) ) {
	        	item.set( LGCOMConstants.HTTP_SESSION_KEY, userSession );
	        	item.set( "LGVHR_PROJECT_SESSION", projectSession );
	        	item.set( "payrollCalculationFormulaId", paramData.get("payrollCalculationFormulaId"));
	        	
	            this.commonDao.update("LGVPAY00014.updateFormulaDetail",item);
	        }
	
	        /* 등록건 저장 */
	        List<LGCOMData> cList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_INSERT);
	        for( LGCOMData item : LGCOMUtils.emptyIfNull(cList) ) {
	        	item.set( LGCOMConstants.HTTP_SESSION_KEY, userSession );
	        	item.set( "LGVHR_PROJECT_SESSION", projectSession );
	        	item.set( "payrollCalculationFormulaId", paramData.get("payrollCalculationFormulaId"));
	                            
	            this.commonDao.insert("LGVPAY00014.insertFormulaDetail",item);
	        }
		}
    }
}
