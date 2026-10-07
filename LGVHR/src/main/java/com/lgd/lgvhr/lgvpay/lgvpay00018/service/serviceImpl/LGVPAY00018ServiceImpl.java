/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAY00018ServiceImpl.java
 * @Desc    : User Defined Table Row
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2018. 01. 29.    limsujin    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvpay.lgvpay00018.service.serviceImpl;

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
import com.lgd.lgvhr.lgvpay.lgvpay00017.service.LGVPAY00017Service;
import com.lgd.lgvhr.lgvpay.lgvpay00018.service.LGVPAY00018Service;
import com.lgd.lgvhr.lgvpay.lgvpaycomm.service.LGVPAYCOMMService;
import com.lgd.lgvhr.lgvpay.util.LGVPAYUtil;

import devonframe.util.DateUtil;
import devonframe.util.NullUtil;
import devonframe.util.ValidationUtil;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpay00017.service.serviceImpl.LGVPAY00018ServiceImpl.java
 * </PRE>
 *
 * @Author    limsujin
 * @Date      2018. 01. 29. 
 * @Version
 */
@Service("LGVPAY00018Service")
public class LGVPAY00018ServiceImpl implements LGVPAY00018Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVPAY00018ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;
	
    @Resource(name="messageSourceAccessor")
    protected MessageSourceAccessor messageSourceAccessor;
    
    @Resource(name="LGVPAYCOMMService")
    private LGVPAYCOMMService lgvpaycomm;
    
    @Resource(name="LGVPAY00017Service")
    private LGVPAY00017Service lgvpay00017;


    /** 
     * User Define Table Row 목록을 조회한다.
     * @param param
     * @return
     */
    public List<LGCOMData> retrieveUserDefineTableRowList(LGCOMData param) {
        return this.commonDao.selectList("LGVPAY00018.retrieveUserDefineTableRowList", param);
    }

    /**
     * Desc : User Define Table Row 저장 전 체크 
     * - 급여 시스템담당자 권한이 있는지 체크
     * - 입력값 체크
     *   - 필수값 체크
     *     - sortOrderNo, effectiveStartYyyymmdd, effectiveEndYyyymmdd : 항상 필수 체크
     *     - lowerLimitCriticalValue : User Defined Table Match Type='M' or 'R' 메세지 분리하기 위해 별도 체크
     *     - upperLimitCriticalValue : User Defined Table Match Type='R' 인 경우만 필수 체크
     *   - lowerLimitCriticalValue
     *     - Data Type=N(Number)인 경우 숫자값인지 체크
     *   - upperLimitCriticalValue
     *     - Data Type=N(Number)인 경우 숫자값인지 체크
     *   - effectiveStartYyyymmdd 
     *     - 날짜포맷(dd/mm/yyyy) 체크
     *   - effectiveEndYyyymmdd 
     *     - 날짜포맷(dd/mm/yyyy) 체크
     *     - 종료일이 시작일 이후인지 체크
     * - 유효성 체크
     *   - Lower Bound 중복 체크
     *     - Match Type='M'인 경우 체크
     *     - Match Type='R' && 검증여부=Y인 경우 체크
     *   - Upper Bound 중복 체크
     *     - Match Type='R' && 검증여부=Y인 경우 체크
     *   - Row Seq 중복 체크 : 항상 체크
     *   - Lower Bound, Upper Bound Range 중복 체크.
     *     - Match Type='R' && 검증여부=Y인 경우 체크
     *   - Upper Bound 가 Lower Bound 보다 작은지 체크
     *     - Match Type='R' && 검증여부=Y인 경우 체크
     * 
     * @Method Name : validateSaveUserDefineTableRow
     * @param param
     * @return boolean
     * @throws Exception
     */
	public boolean validateSaveUserDefineTableRow(LGCOMData param) {
    	boolean validateFlag = false;
    	
    	validateFlag = lgvpaycomm.retrievePaySystemMasterAuthFlag(param); 
    	if ( !validateFlag ) {//급여담당자 권한이 없는 경우
    		throw new LGCOMException(messageSourceAccessor.getMessage("note.NoPermission"));
    		
    	} else {
    		//테이블 정보 조회
            LGCOMData tempData = new LGCOMData();
            tempData.set( "tableSeqNo", param.getData("parameter").get("tableSeqNo") );
            tempData.set( LGCOMConstants.HTTP_SESSION_KEY, param.getData(LGCOMConstants.HTTP_SESSION_KEY) );
            tempData.set( "LGVHR_PROJECT_SESSION", param.getData("LGVHR_PROJECT_SESSION") );
    		LGCOMData tableData = lgvpay00017.retrieveUserDefineTableData(tempData);

    		if ( !NullUtil.isNull(tableData) ) {
	            //필수체크 컬럼
	            String[] requireFieldNames  = new String[] {"sortOrderNo", "effectiveStartYyyymmdd", "effectiveEndYyyymmdd"};//필수 컬럼명
	            String[] requireFieldTitles = new String[] { messageSourceAccessor.getMessage("label.pay.rowSeq")
	                                                       , messageSourceAccessor.getMessage("EffectiveStartDate")
	            		                                   , messageSourceAccessor.getMessage("EffectEndDate") };//필수 컬럼명 화면 label
	
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
		        	}

		        	////Table Match Type=M (Match)인 경우 lowerBound 만 체크함.
		        	if ( "M".equals(tableData.getString("dataManagementWayCode"))
		        			&& NullUtil.isNone(item.getString("lowerLimitCriticalValue")) ) {
		        		throw new LGCOMException(messageSourceAccessor.getMessage("error.required", new Object[]{messageSourceAccessor.getMessage("label.pay.exact")}));
		        		
		        	//Table Match Type=M (Match) && Data Type=N (Number) 경우 lowerBound 숫자인지 체크
		        	} else if ( "M".equals(tableData.getString("dataManagementWayCode")) 
		        			&& "N".equals(tableData.getString("dataTypeCode"))
		        			&& !ValidationUtil.checkFloat(item.getString("lowerLimitCriticalValue")) && !ValidationUtil.checkInteger(item.getString("lowerLimitCriticalValue")) ) {
		        		throw new LGCOMException(messageSourceAccessor.getMessage("note.pay.onlyNumber", new Object[]{messageSourceAccessor.getMessage("label.pay.exact")}));
			        		
		        	//Table Match Type=R (Range)인 경우 lowerBound, upperBound 모두 체크함.
		        	} else if ( "R".equals(tableData.getString("dataManagementWayCode")) 
		        			&& NullUtil.isNone(item.getString("lowerLimitCriticalValue")) ) {
		        		throw new LGCOMException(messageSourceAccessor.getMessage("error.required", new Object[]{messageSourceAccessor.getMessage("label.pay.lowerBound")}));
		        		
		        	//Table Match Type=R (Range) && Data Type=N (Number) 경우 lowerBound 숫자인지 체크
		        	} else if ( "R".equals(tableData.getString("dataManagementWayCode")) 
		        			&& "N".equals(tableData.getString("dataTypeCode"))
		        			&& !ValidationUtil.checkFloat(item.getString("lowerLimitCriticalValue")) && !ValidationUtil.checkInteger(item.getString("lowerLimitCriticalValue")) ) {
		        		throw new LGCOMException(messageSourceAccessor.getMessage("note.pay.onlyNumber", new Object[]{messageSourceAccessor.getMessage("label.pay.lowerBound")}));
		        		
		        	//Table Match Type=R (Range)인 경우 lowerBound, upperBound 모두 체크함.
		        	} else if ( "R".equals(tableData.getString("dataManagementWayCode")) 
		        			&& NullUtil.isNone(item.getString("upperLimitCriticalValue")) ) {
		        		throw new LGCOMException(messageSourceAccessor.getMessage("error.required", new Object[]{messageSourceAccessor.getMessage("label.pay.upperBound")}));
		        		
		        	//Table Match Type=R (Range) && Data Type=N (Number) 경우 upperBound 숫자인지 체크
		        	} else if ( "R".equals(tableData.getString("dataManagementWayCode")) 
		        			&& "N".equals(tableData.getString("dataTypeCode"))
		        			&& !ValidationUtil.checkFloat(item.getString("upperLimitCriticalValue")) && !ValidationUtil.checkInteger(item.getString("upperLimitCriticalValue")) ) {
		        		throw new LGCOMException(messageSourceAccessor.getMessage("note.pay.onlyNumber", new Object[]{messageSourceAccessor.getMessage("label.pay.upperBound")}));
		        	
		        	} else {
		        		//시작일 포맷 체크
		        		if ( !LGVPAYUtil.validateDateFormat(item.getString("effectiveStartYyyymmdd")) ) {
		        			throw new LGCOMException(messageSourceAccessor.getMessage("error.incorrectFormat")+"("+ messageSourceAccessor.getMessage("EffectiveStartDate") +")");
		        		}
		        		
		        		//종료일 포맷 체크
		        		if ( !LGVPAYUtil.validateDateFormat(item.getString("effectiveEndYyyymmdd")) ) {
		        			throw new LGCOMException(messageSourceAccessor.getMessage("error.incorrectFormat")+"("+ messageSourceAccessor.getMessage("EffectEndDate") +")");
		        		}
		        		
		        		//시작일이 종료일 이후인지 체크
		        		if ( DateUtil.isAfter(LGVPAYUtil.getFormattedDate(item.getString("effectiveStartYyyymmdd")), LGVPAYUtil.getFormattedDate(item.getString("effectiveEndYyyymmdd"))) ) {
		        			throw new LGCOMException(messageSourceAccessor.getMessage("error.DataRangePickerFromDate"));
		        		}
		        	}
		        }
	            
	            LGCOMData validateData = commonDao.select("LGVPAY00018.retireveValidateUserDefineTableRowData", param);
	            if ( !NullUtil.isNull(validateData) ) {
	            	StringBuffer errorMsg = new StringBuffer();
	            	boolean dupValueValidationFlag = false;//중복체크여부
	            	boolean dupRangeValidationFlag = false;//Range 중복 체크 여부
	            	
	            	/*
	            	 * Validation Rule
	            	 * - Match Type
	            	 *   - Match
	            	 *     - dataValidationFlag 와 관계 없이 value 중복 체크
	            	 *   - Range 
	            	 *     - dataType=Number && dataValidationFlag=Y : Value 중복체크, Range 중복 체크
	            	 *     - dataType=Number && dataValidationFlag=N : Value 중복체크 안함, Range 중복체크 안함.
	            	 */
	            	if ( "M".equals(tableData.getString("dataManagementWayCode")) ) {
	            		dupValueValidationFlag = true;
	            		dupRangeValidationFlag = false;
	            		
	            	} else if ( "R".equals(tableData.getString("dataManagementWayCode"))
	            			&& "N".equals(tableData.getString("dataTypeCode"))
	            			&& "Y".equals(tableData.getString("dataValidationFlag")) ) {
	            		dupValueValidationFlag = true;
	            		dupRangeValidationFlag = true;
	            	}
	            	
	                //User Defined Table Lower Bound 중복 체크
	            	if ( NullUtil.notNone(validateData.getString("dupLowerNames")) && dupValueValidationFlag ) {
	            		String dupLowerNamesTitle = ("M".equals(tableData.getString("dataManagementWayCode")))?validateData.getString("dupExactNamesTitle"):validateData.getString("dupLowerNamesTitle");
	            		
	            		errorMsg.append(messageSourceAccessor.getMessage("error.duplicateValue"))
	            		        .append(dupLowerNamesTitle)
	            		        .append(validateData.getString("dupLowerNames"));
	    	    		throw new LGCOMException(errorMsg.toString());
	    	    		
		            //User Defined Table Upper Bound 중복 체크. MatchType=Range이고 DataType=NUMBER이고, 검증여부가 Y 경우만 체크함.
	            	} else if ( NullUtil.notNone(validateData.getString("dupUpperNames")) && dupValueValidationFlag ) {		            		
	            		errorMsg.append(messageSourceAccessor.getMessage("error.duplicateValue"))
	            		        .append(validateData.getString("dupUpperNamesTitle"))
	            		        .append(validateData.getString("dupUpperNames"));
	    	    		throw new LGCOMException(errorMsg.toString());
	    	    		
		            //User Defined Table Sort Order No 중복 체크
	            	} else if ( NullUtil.notNone(validateData.getString("dupSortOrder")) ) {		            		
	            		errorMsg.append(messageSourceAccessor.getMessage("error.duplicateValue"))
	            		        .append(validateData.getString("dupSortOrderTitle"))
	            		        .append(validateData.getString("dupSortOrder"));
	    	    		throw new LGCOMException(errorMsg.toString());
	    	    		
		            //User Defined Table Lower, Upper Bound Range 중복 체크. MatchType=Range이고 DataType=NUMBER이고, 검증여부가 Y 경우만 체크함.
	            	} else if ( "Y".equals(validateData.getString("dupRangeFlag")) && dupRangeValidationFlag ) {
	    	    		throw new LGCOMException(messageSourceAccessor.getMessage("note.pay.duplicateRange"));
	    	    		
		            //User Defined Table Upper Bound 가 Lower Bound 보다 큰지 체크. MatchType=Range이고 DataType=NUMBER이고, 검증여부가 Y 경우만 체크함.
	            	} else if ( NullUtil.notNone(validateData.getString("lessUpper")) && dupRangeValidationFlag ) {
	            		errorMsg.append(messageSourceAccessor.getMessage("note.pay.upperBoundGreaterThanLowerBound"))
	            		        .append(validateData.getString("dupUpperNamesTitle"))
	            		        .append(validateData.getString("lessUpper"));
	    	    		throw new LGCOMException(errorMsg.toString());
		            }
	            }
    		}
    		validateFlag = true;
    	}
    	
    	return validateFlag;
    }

	/**
	 * Desc : User Define Table Row 를 저장한다.
	 * - 값 유효성 체크
	 * - 삭제건 처리(데이터 삭제 후 같은 명칭으로 재등록할 수 있으므로 가장 먼저 삭제 처리함)
	 * - 수정건 처리(데이터 수정 시 같은 명칭으로 변경할 수 있으므로 등록이전 수정 처리함)
	 * - 등록건 처리
	 * 
	 * @Method Name : saveUserDefineTableRowList
	 * @param  param
	 * @throws Exception
	 */
	@SuppressWarnings("unchecked")
	@Transactional(propagation=Propagation.REQUIRED)
    public LGCOMData saveUserDefineTableRowList(LGCOMData param){
		if ( validateSaveUserDefineTableRow(param) ) {//값 체크 정상인 경우 처리
			
	        LGCOMData userSession = param.getData(LGCOMConstants.HTTP_SESSION_KEY);
	        LGCOMData projectSession = param.getData("LGVHR_PROJECT_SESSION");
	        
	        /* 삭제건 처리 */
	        List<LGCOMData> dList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_DELETE);
	        for( LGCOMData item : LGCOMUtils.emptyIfNull(dList) ) {
	        	item.set( LGCOMConstants.HTTP_SESSION_KEY, userSession );
	        	item.set( "LGVHR_PROJECT_SESSION", projectSession );
	        	item.set( "tableSeqNo", param.getData("parameter").get("tableSeqNo") );

	            this.commonDao.delete("LGVPAY00018.deleteUserDefineTableRow",item);
	        }
	        
	        /* 수정건 저장 */
	        List<LGCOMData> uList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_UPDATE);
	        for( LGCOMData item : LGCOMUtils.emptyIfNull(uList) ) {
	        	item.set( LGCOMConstants.HTTP_SESSION_KEY, userSession );
	        	item.set( "LGVHR_PROJECT_SESSION", projectSession );
	        	item.set( "tableSeqNo", param.getData("parameter").get("tableSeqNo") );
	        	
	            this.commonDao.update("LGVPAY00018.updateUserDefineTableRow",item);
	        }
	
	        /* 등록건 저장 */
	        List<LGCOMData> cList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_INSERT);
	        for( LGCOMData item : LGCOMUtils.emptyIfNull(cList) ) {
	        	item.set( LGCOMConstants.HTTP_SESSION_KEY, userSession );
	        	item.set( "LGVHR_PROJECT_SESSION", projectSession );
	        	item.set( "tableSeqNo", param.getData("parameter").get("tableSeqNo") );

	            this.commonDao.insert("LGVPAY00018.insertUserDefineTableRow",item);
	        }
		}
		return param;
    }
}
