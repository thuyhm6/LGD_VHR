/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAY00015ServiceImpl.java
 * @Desc    : Aggregate Management
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2018. 01. 18.    limsujin    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvpay.lgvpay00015.service.serviceImpl;

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
import com.lgd.lgvhr.lgvpay.lgvpay00015.service.LGVPAY00015Service;
import com.lgd.lgvhr.lgvpay.lgvpaycomm.service.LGVPAYCOMMService;
import com.lgd.lgvhr.lgvpay.util.LGVPAYUtil;

import devonframe.util.DateUtil;
import devonframe.util.NullUtil;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpay00015.service.serviceImpl.LGVPAY00015ServiceImpl.java
 * </PRE>
 *
 * @Author    limsujin
 * @Date      2018. 01. 18. 
 * @Version
 */
@Service("LGVPAY00015Service")
public class LGVPAY00015ServiceImpl implements LGVPAY00015Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVPAY00015ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;
	
    @Resource(name="messageSourceAccessor")
    protected MessageSourceAccessor messageSourceAccessor;
    
    @Resource(name="LGVPAYCOMMService")
    private LGVPAYCOMMService lgvpaycomm;

    /** 
     * Aggregate 목록을 조회한다.
     * @param param
     * @return
     */
    public List<LGCOMData> retrieveAggregateList(LGCOMData param) {
        return this.commonDao.selectList("LGVPAY00015.retrieveAggregateList", param);
    }
    
    /**
     * Desc : Aggregate 정보를 조회한다. 
     * @Method Name : retrieveAggregateData
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
    public LGCOMData retrieveAggregateData(LGCOMData param) {
    	param.set( "srchPayrollItemAggregateId", NullUtil.nvl(param.getString("srchPayrollItemAggregateId"), param.getString("payrollItemAggregateId")) );
    	return commonDao.select("LGVPAY00015.retrieveAggregateList", param);
    }
    
    /**
     * Desc : Aggregate 삭제 가능여부를 조회한다. 
     * @Method Name : retrieveAggregateDeleteFlag
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
    public boolean retrieveAggregateDeleteFlag(LGCOMData param) {
    	param.set( "srchPayrollItemAggregateId", NullUtil.nvl(param.getString("srchPayrollItemAggregateId"), param.getString("payrollItemAggregateId")) );
    	LGCOMData aggregateData = commonDao.select("LGVPAY00015.retrieveAggregateList", param);
    	
    	if ( !NullUtil.isNull(aggregateData) && "Y".equals(aggregateData.getString("usedFlag")) ) {//급여실행결과가 있는 경우 삭제 불가
    		return false;
    	}
    	return true;
    }

    /**
     * Desc : Aggregate 저장 전 체크 
     * - 급여 시스템담당자 권한이 있는지 체크
     * - 삭제건 체크
     *   - 급여 실행결과 있는 경우 삭제 불가
     * - 수정건 체크
     *   - 급여 실행결과 있는 경우 수정 불가
     *   - 필수컬럼 값 유무 체크
     * - 입력건
     *   - 필수컬럼 값 유무 체크
     * - Aggregate 중복 체크
     * 
     * @Method Name : validateSaveAggregate
     * @param param
     * @return boolean
     * @throws Exception
     */
    @SuppressWarnings("unchecked")
	public boolean validateSaveAggregate(LGCOMData param) {
    	boolean validateFlag = false;
    	
    	validateFlag = lgvpaycomm.retrievePaySystemMasterAuthFlag(param); 
    	if ( !validateFlag ) {//급여담당자 권한이 없는 경우
    		throw new LGCOMException(messageSourceAccessor.getMessage("note.NoPermission"));
    		
    	} else {
            
            //필수체크 컬럼
            String[] requireFieldNames  = new String[] {"payrollItemAggregateName", "payrollAggregateTypeCode", "runFlag", "monthFlag", "yearFlag"};//필수 컬럼명
            String[] requireFieldTitles = new String[] { messageSourceAccessor.getMessage("label.pay.aggregateName")
            		                                   , messageSourceAccessor.getMessage("label.pay.aggregateType")
            		                                   , messageSourceAccessor.getMessage("label.pay.run")
            		                                   , messageSourceAccessor.getMessage("month")
            		                                   , messageSourceAccessor.getMessage("Year") };//필수 컬럼명 화면 label

    		//삭제 건
            for ( LGCOMData item : LGCOMUtils.emptyIfNull((List<LGCOMData>)param.get(LGCOMConstants.STATUS_DELETE)) ) {
            	if ( !retrieveAggregateDeleteFlag(item) ) {
            		//급여 실행결과가 있는 경우 삭제 불가
        			throw new LGCOMException(messageSourceAccessor.getMessage("note.pay.deleteAlreadyRunResult"));//이미 실행된 결과가 있으므로 삭제 불가능합니다.
            	}
            }

            //수정건 체크
	        for ( LGCOMData item : LGCOMUtils.emptyIfNull((List<LGCOMData>)param.get(LGCOMConstants.STATUS_UPDATE)) ) {
            	if ( !retrieveAggregateDeleteFlag(item) ) {
            		//급여 실행결과가 있는 경우 수정 불가
        			throw new LGCOMException(messageSourceAccessor.getMessage("note.pay.saveAlreadyRunResult"));//이미 실행된 결과가 있으므로 저장 불가능합니다.
            	}
            	
	        	//필수값 체크
	        	if ( requireFieldNames.length > 0 ) {
	        		for ( int i=0; i<requireFieldNames.length; i++ ) {
	        			if ( NullUtil.isNone(item.getString(requireFieldNames[i])) ) {
	        				throw new LGCOMException(messageSourceAccessor.getMessage("error.required", new Object[]{requireFieldTitles[i]}));
	        			}
	        		}
	        	}
	        	
	        	//usage(runFlag, monthFlag, yearFlag) 중 하나는 Y여야 함.
	        	if ( !"Y".equals(NullUtil.nvl(item.getString("runFlag"), "")) &&  !"Y".equals(NullUtil.nvl(item.getString("monthFlag"), "")) &&  !"Y".equals(NullUtil.nvl(item.getString("yearFlag"), "")) ) {
	        		throw new LGCOMException(messageSourceAccessor.getMessage("note.pay.selectUsageValue"));
	        	}
	        }

            //신규건 체크
	        for ( LGCOMData item : LGCOMUtils.emptyIfNull((List<LGCOMData>)param.get(LGCOMConstants.STATUS_INSERT)) ) {
	        	//필수값 체크
	        	if ( requireFieldNames.length > 0 ) {
	        		for ( int i=0; i<requireFieldNames.length; i++ ) {
	        			if ( NullUtil.isNone(item.getString(requireFieldNames[i])) ) {
	        				throw new LGCOMException(messageSourceAccessor.getMessage("error.required", new Object[]{requireFieldTitles[i]}));
	        			}
	        		}
	        	}
	        	
	        	//usage(runFlag, monthFlag, yearFlag) 중 하나는 Y여야 함.
	        	if ( !"Y".equals(NullUtil.nvl(item.getString("runFlag"), "")) &&  !"Y".equals(NullUtil.nvl(item.getString("monthFlag"), "")) &&  !"Y".equals(NullUtil.nvl(item.getString("yearFlag"), "")) ) {
	        		throw new LGCOMException(messageSourceAccessor.getMessage("note.pay.selectUsageValue"));
	        	}
	        }
            
	        //중복체크
            LGCOMData validateData = commonDao.select("LGVPAY00015.retireveValidateAggregateData", param);
            if ( !NullUtil.isNull(validateData) ) {
            	StringBuffer errorMsg = new StringBuffer();            	
                //aggregate name 중복 체크
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
	 * Desc : Aggregate를 저장한다.
	 * - 값 유효성 체크
	 * - 삭제건 처리(데이터 삭제 후 같은 명칭으로 재등록할 수 있으므로 가장 먼저 삭제 처리함)
	 *   - Aggregate 에 등록된 Detail 전체 삭제
	 *   - Aggregate Cycle 데이터 전체 삭제
	 *   - Aggregate 삭제
	 * - 수정건 처리(데이터 수정 시 같은 명칭으로 변경할 수 있으므로 등록이전 수정 처리함)
	 *   - flag = Y인 경우 Aggregate Cycle 데이터 등록
	 *   - flag = N인 경우 Aggregate Cycle 데이터 삭제
	 *   - Aggregate 수정
	 * - 등록건 처리
	 *   - flag = Y인 경우 Aggregate Cycle 데이터 등록
	 *   - flag = N인 경우 Aggregate Cycle 데이터 삭제
	 *   - Aggregate 수정
	 * 
	 * @Method Name : saveAggregateList
	 * @param  param
	 * @throws Exception
	 */
	@SuppressWarnings("unchecked")
	@Transactional(propagation=Propagation.REQUIRED)
    public LGCOMData saveAggregateList(LGCOMData param){
		if ( validateSaveAggregate(param) ) {//값 체크 정상인 경우 처리
			
	        LGCOMData userSession = param.getData(LGCOMConstants.HTTP_SESSION_KEY);
	        LGCOMData projectSession = param.getData("LGVHR_PROJECT_SESSION");
	        
	        /* 삭제건 처리 */
	        List<LGCOMData> dList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_DELETE);
	        for( LGCOMData item : LGCOMUtils.emptyIfNull(dList) ) {
	        	item.set( LGCOMConstants.HTTP_SESSION_KEY, userSession );
	        	item.set( "LGVHR_PROJECT_SESSION", projectSession );

	            this.commonDao.delete("LGVPAY00015.deleteAggregateDetailAll",item);
	            this.commonDao.delete("LGVPAY00015.deleteAggregateCycleAll", item);
	            this.commonDao.delete("LGVPAY00015.deleteAggregate",item);
	        }
	        
	        /* 수정건 저장 */
	        List<LGCOMData> uList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_UPDATE);
	        for( LGCOMData item : LGCOMUtils.emptyIfNull(uList) ) {
	        	item.set( LGCOMConstants.HTTP_SESSION_KEY, userSession );
	        	item.set( "LGVHR_PROJECT_SESSION", projectSession );
	        	
	        	this.commonDao.delete("LGVPAY00015.deleteAggregateCycle", item);
	        	this.commonDao.insert("LGVPAY00015.insertAggregateCycle", item);
	            this.commonDao.update("LGVPAY00015.updateAggregate",item);
	        }
	
	        /* 등록건 저장 */
	        List<LGCOMData> cList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_INSERT);
	        for( LGCOMData item : LGCOMUtils.emptyIfNull(cList) ) {
	        	item.set( LGCOMConstants.HTTP_SESSION_KEY, userSession );
	        	item.set( "LGVHR_PROJECT_SESSION", projectSession );
	        	
	        	LGCOMData idData = commonDao.select("LGVPAY00015.retrieveAggregateId");

	        	if ( !NullUtil.isNull(idData) && NullUtil.notNone(idData.getString("payrollItemAggregateId")) ) {
	        		item.set( "payrollItemAggregateId", idData.get("payrollItemAggregateId") );
	        		
		        	this.commonDao.delete("LGVPAY00015.deleteAggregateCycle", item);
		        	this.commonDao.insert("LGVPAY00015.insertAggregateCycle", item);
		            this.commonDao.insert("LGVPAY00015.insertAggregate",item);
	        	}
	        }
		}
		return param;
    }
    
    /** 
     * Aggregate Detail 목록을 조회한다.
     * @param param
     * @return
     */
    public List<LGCOMData> retrieveAggregateDetailList(LGCOMData param) {
        return this.commonDao.selectList("LGVPAY00015.retrieveAggregateDetailList", param);
    }

    /**
     * Desc : Aggregate Detail 저장 전 체크 
     * - 급여 시스템담당자 권한이 있는지 체크
     * - 정렬순서 중복 체크
     * - 파라메터명 중복 체크
     * - 필수컬럼 값 유무 체크
     * - OUT 파라메터인 경우 PayrollItemName, PayrollItemDetailName 필수 체크
     * 
     * @Method Name : validateSaveAggregateDetail
     * @param param
     * @return boolean
     * @throws Exception
     */
	public boolean validateSaveAggregateDetail(LGCOMData param) {
    	boolean validateFlag = false;
    	
    	validateFlag = lgvpaycomm.retrievePaySystemMasterAuthFlag(param); 
    	if ( !validateFlag ) {//급여담당자 권한이 없는 경우
    		throw new LGCOMException(messageSourceAccessor.getMessage("note.NoPermission"));
    		
    	} else {
            //마스터 데이터 조회
            LGCOMData tempData = new LGCOMData();
            tempData.set( "payrollItemAggregateId", param.getData("parameter").get("payrollItemAggregateId") );
            tempData.set( LGCOMConstants.HTTP_SESSION_KEY, param.getData(LGCOMConstants.HTTP_SESSION_KEY) );
            tempData.set( "LGVHR_PROJECT_SESSION", param.getData("LGVHR_PROJECT_SESSION") );
            LGCOMData masterData = this.retrieveAggregateData(tempData);
            
            if ( !NullUtil.isNull(masterData) ) {
	            //필수체크 컬럼
	            String[] requireFieldNames  = new String[] {"effectiveStartYyyymmdd", "effectiveEndYyyymmdd"};//필수 컬럼명
	            String[] requireFieldTitles = new String[] { messageSourceAccessor.getMessage("EffectiveStartDate")
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
		        	
		        	//Master 그리드의 payrollAggregateTypeCode 값이 CLASS 또는 METHOD 인 경우 Aggregate Detail Name 필수값 체크
		        	if ( ("CLASS".equals(masterData.getString("payrollAggregateTypeCode")) || "METHOD".equals(masterData.getString("payrollAggregateTypeCode")))
		        			&& NullUtil.isNone(item.getString("payItemClassificationCode")) ) {
		        		throw new LGCOMException(messageSourceAccessor.getMessage("error.required", new Object[]{messageSourceAccessor.getMessage("label.pay.aggregateDetailName")}));
			        		
		        	//Master 그리드의 payrollAggregateTypeCode 값이 ITEM 인 경우 Aggregate Detail Value 필수값 체크
		        	} else if ( "ITEM".equals(masterData.getString("payrollAggregateTypeCode")) 
		        			&& ( NullUtil.isNone(item.getString("payrollItemId")) || NullUtil.isNone(item.getString("payrollItemDetailDetailId")) ) ) {
		        		throw new LGCOMException(messageSourceAccessor.getMessage("error.required", new Object[]{messageSourceAccessor.getMessage("label.pay.aggregateDetailValue")}));
		        	
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

		        param.set( "payrollAggregateTypeCode", masterData.get("payrollAggregateTypeCode") );
	            LGCOMData validateData = commonDao.select("LGVPAY00015.retireveValidateAggregateDetailData", param);
	            if ( !NullUtil.isNull(validateData) ) {
	            	StringBuffer errorMsg = new StringBuffer();
	                //집계(누계) 상세항목 중복 체크
	            	if ( NullUtil.notNone(validateData.getString("dupAggrDetailNames")) ) {
	            		errorMsg.append(messageSourceAccessor.getMessage("error.duplicateValue"))
	            		        .append(validateData.getString("dupAggrDetailNamesTitle"))
	            		        .append(validateData.getString("dupAggrDetailNames"));
	    	    		throw new LGCOMException(errorMsg.toString());
	
	            	}
	            }
            }//if ( !NullUtil.isNull(masterData) )
    		
    		validateFlag = true;
    	}
    	
    	return validateFlag;
    }

	/**
	 * Desc : Aggregate Detail 를 저장한다.
	 * - 값 유효성 체크
	 * - 삭제건 처리(데이터 삭제 후 같은 명칭으로 재등록할 수 있으므로 가장 먼저 삭제 처리함)
	 * - 수정건 처리(데이터 수정 시 같은 명칭으로 변경할 수 있으므로 등록이전 수정 처리함)
	 * - 등록건 처리
	 * 
	 * @Method Name : saveAggregateDetailList
	 * @param  param
	 * @throws Exception
	 */
	@SuppressWarnings("unchecked")
	@Transactional(propagation=Propagation.REQUIRED)
    public void saveAggregateDetailList(LGCOMData param){
		if ( validateSaveAggregateDetail(param) ) {//값 체크 정상인 경우 처리
			
	        LGCOMData userSession = param.getData(LGCOMConstants.HTTP_SESSION_KEY);
	        LGCOMData projectSession = param.getData("LGVHR_PROJECT_SESSION");
	        LGCOMData paramData = param.getData("parameter");
	
	        /* 삭제건 저장 */
	        List<LGCOMData> dList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_DELETE);
	        for( LGCOMData item : LGCOMUtils.emptyIfNull(dList) ) {
	        	item.set( LGCOMConstants.HTTP_SESSION_KEY, userSession );
	        	item.set( "LGVHR_PROJECT_SESSION", projectSession );
	        	item.set( "payrollItemAggregateId", paramData.get("payrollItemAggregateId"));
	        	item.set( "payrollAggregateTypeCode", param.get("payrollAggregateTypeCode"));
	        	
	            this.commonDao.update("LGVPAY00015.deleteAggregateDetail", item);
	        }
	        
	        /* 수정건 저장 */
	        List<LGCOMData> uList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_UPDATE);
	        for( LGCOMData item : LGCOMUtils.emptyIfNull(uList) ) {
	        	item.set( LGCOMConstants.HTTP_SESSION_KEY, userSession );
	        	item.set( "LGVHR_PROJECT_SESSION", projectSession );
	        	item.set( "payrollItemAggregateId", paramData.get("payrollItemAggregateId"));
	        	item.set( "payrollAggregateTypeCode", param.get("payrollAggregateTypeCode"));
	        	
	            this.commonDao.update("LGVPAY00015.updateAggregateDetail",item);
	        }
	
	        /* 등록건 저장 */
	        List<LGCOMData> cList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_INSERT);
	        for( LGCOMData item : LGCOMUtils.emptyIfNull(cList) ) {
	        	item.set( LGCOMConstants.HTTP_SESSION_KEY, userSession );
	        	item.set( "LGVHR_PROJECT_SESSION", projectSession );
	        	item.set( "payrollItemAggregateId", paramData.get("payrollItemAggregateId"));
	        	item.set( "payrollAggregateTypeCode", param.get("payrollAggregateTypeCode"));
	                            
	            this.commonDao.insert("LGVPAY00015.insertAggregateDetail",item);
	        }
		}
    }
}
