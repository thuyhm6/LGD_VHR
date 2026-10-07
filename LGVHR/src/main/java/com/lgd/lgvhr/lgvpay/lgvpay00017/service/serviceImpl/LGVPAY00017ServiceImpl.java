/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAY00017ServiceImpl.java
 * @Desc    : User Defined Table/Column
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
package com.lgd.lgvhr.lgvpay.lgvpay00017.service.serviceImpl;

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
import com.lgd.lgvhr.lgvpay.lgvpaycomm.service.LGVPAYCOMMService;

import devonframe.util.NullUtil;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpay00017.service.serviceImpl.LGVPAY00017ServiceImpl.java
 * </PRE>
 *
 * @Author    limsujin
 * @Date      2018. 01. 29. 
 * @Version
 */
@Service("LGVPAY00017Service")
public class LGVPAY00017ServiceImpl implements LGVPAY00017Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVPAY00017ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;
	
    @Resource(name="messageSourceAccessor")
    protected MessageSourceAccessor messageSourceAccessor;
    
    @Resource(name="LGVPAYCOMMService")
    private LGVPAYCOMMService lgvpaycomm;


    /** 
     * User Define Table 목록을 조회한다.
     * @param param
     * @return
     */
    public List<LGCOMData> retrieveUserDefineTableList(LGCOMData param) {
        return this.commonDao.selectList("LGVPAY00017.retrieveUserDefineTableList", param);
    }
    
    /**
     * Desc : User Define Table 정보를 조회한다. 
     * @Method Name : retrieveUserDefineTableData
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
    public LGCOMData retrieveUserDefineTableData(LGCOMData param) {
    	param.set( "srchTableSeqNo", NullUtil.nvl(param.getString("srchTableSeqNo"), param.getString("tableSeqNo")) );
    	return commonDao.select("LGVPAY00017.retrieveUserDefineTableList", param);
    }

    /**
     * Desc : User Define Table 저장 전 체크 
     * - 급여 시스템담당자 권한이 있는지 체크
     * - 입력값 체크
     *   - 필수입력 체크
     *   - Match Type=R(Range)인 경우 Data Type은 N(Number)인지 체크
     *   - 수정 건 중 UDT Row 데이터 있는 경우 Match Type, Data Type, Validate Flag 수정 불가 체크
     *   - dataTypeCode : User Defined Table Match Type='R' 인 경우 빈값 또는 N(Number) 값인지 체크
     * - 유효성 체크
     *   - User Define Table Name 중복 체크
     * 
     * @Method Name : validateSaveUserDefineTable
     * @param param
     * @return boolean
     * @throws Exception
     */
	public boolean validateSaveUserDefineTable(LGCOMData param) {
    	boolean validateFlag = false;
    	
    	validateFlag = lgvpaycomm.retrievePaySystemMasterAuthFlag(param); 
    	if ( !validateFlag ) {//급여담당자 권한이 없는 경우
    		throw new LGCOMException(messageSourceAccessor.getMessage("note.NoPermission"));
    		
    	} else {
            
            LGCOMData validateData = commonDao.select("LGVPAY00017.retireveValidateUserDefineTableData", param);
            if ( !NullUtil.isNull(validateData) ) {
	            //필수체크 컬럼
	            String[] requireFieldNames  = new String[] {"tableName", "dataManagementWayCode", "dataTypeCode", "dataValidationFlag"};//필수 컬럼명
	            String[] unChangeableFieldNames = new String[] {"dataManagementWayCode", "dataTypeCode", "dataValidationFlag"};//수정불가 컬럼명
	            String[] requireFieldTitles = new String[] { messageSourceAccessor.getMessage("label.pay.tableName")
	                                                       , messageSourceAccessor.getMessage("label.pay.matchType")
	            		                                   , messageSourceAccessor.getMessage("DataType")
	            		                                   , messageSourceAccessor.getMessage("ValidateFlag") };//필수 컬럼명 화면 label

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
	        		
		        	//Table Match Type=R (Rage)인 경우 Data Type은 숫자 또는 공백만 가능하도록 체크함.
		        	if ( "R".equals(item.getString("dataManagementWayCode")) 
	        			&& !NullUtil.isNone(item.getString("dataTypeCode")) && !"N".equals(item.getString("dataTypeCode")) ) {
		        		throw new LGCOMException(messageSourceAccessor.getMessage("note.pay.udtRangeDataType"));
		        	}

		        	//저장된 데이터 조회
		        	item.set( LGCOMConstants.HTTP_SESSION_KEY, param.getData(LGCOMConstants.HTTP_SESSION_KEY) );
		        	item.set( "LGVHR_PROJECT_SESSION", param.getData("LGVHR_PROJECT_SESSION") );
		        	LGCOMData tableData = this.retrieveUserDefineTableData(item);

	        		// UDT Row 데이터 있는 경우 Match Type, Data Type, Validate Flag 수정 불가 체크
		        	if ( !NullUtil.isNull(tableData) ) {
		        		for ( int j=0; j<unChangeableFieldNames.length; j++ ) {
				        	if ( "Y".equals(tableData.getString("rowExistsFlag")) && !item.getString(unChangeableFieldNames[j]).equals(tableData.getString(unChangeableFieldNames[j])) ) {
		        				throw new LGCOMException(messageSourceAccessor.getMessage("note.pay.unChangeableUDTData"));
		        			}
		        		}
		        	}
		        }//end-for ( LGCOMData item : LGCOMUtils.emptyIfNull(culist) )

            	StringBuffer errorMsg = new StringBuffer();
                //User Defined Table Name 중복 체크
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
	 * Desc : User Define Table을 저장한다.
	 * - 값 유효성 체크
	 * - 삭제건 처리(데이터 삭제 후 같은 명칭으로 재등록할 수 있으므로 가장 먼저 삭제 처리함)
	 *   - User Define Table 삭제
	 *   - User Define Table 에 등록된 Column 전체 삭제
	 *   - User Define Table 에 등록된 Row 전체 삭제
	 *   - User Define Table 에 등록된 Value 전체 삭제
	 * - 수정건 처리(데이터 수정 시 같은 명칭으로 변경할 수 있으므로 등록이전 수정 처리함)
	 * - 등록건 처리
	 * 
	 * @Method Name : saveUserDefineTableList
	 * @param  param
	 * @throws Exception
	 */
	@SuppressWarnings("unchecked")
	@Transactional(propagation=Propagation.REQUIRED)
    public LGCOMData saveUserDefineTableList(LGCOMData param){
		if ( validateSaveUserDefineTable(param) ) {//값 체크 정상인 경우 처리
			
	        LGCOMData userSession = param.getData(LGCOMConstants.HTTP_SESSION_KEY);
	        LGCOMData projectSession = param.getData("LGVHR_PROJECT_SESSION");
	        
	        /* 삭제건 처리 */
	        List<LGCOMData> dList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_DELETE);
	        for( LGCOMData item : LGCOMUtils.emptyIfNull(dList) ) {
	        	item.set( LGCOMConstants.HTTP_SESSION_KEY, userSession );
	        	item.set( "LGVHR_PROJECT_SESSION", projectSession );

	            this.commonDao.delete("LGVPAY00017.deleteUserDefineValueAll",item);
	            this.commonDao.delete("LGVPAY00017.deleteUserDefineRowAll",item);
	            this.commonDao.delete("LGVPAY00017.deleteUserDefineColumnAll",item);
	            this.commonDao.delete("LGVPAY00017.deleteUserDefineTable",item);
	        }
	        
	        /* 수정건 저장 */
	        List<LGCOMData> uList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_UPDATE);
	        for( LGCOMData item : LGCOMUtils.emptyIfNull(uList) ) {
	        	item.set( LGCOMConstants.HTTP_SESSION_KEY, userSession );
	        	item.set( "LGVHR_PROJECT_SESSION", projectSession );
	            this.commonDao.update("LGVPAY00017.updateUserDefineTable",item);
	        }
	
	        /* 등록건 저장 */
	        List<LGCOMData> cList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_INSERT);
	        for( LGCOMData item : LGCOMUtils.emptyIfNull(cList) ) {
	        	item.set( LGCOMConstants.HTTP_SESSION_KEY, userSession );
	        	item.set( "LGVHR_PROJECT_SESSION", projectSession );

	            this.commonDao.insert("LGVPAY00017.insertUserDefineTable",item);
	        }
		}
		return param;
    }
    
    /** 
     * User Define Column 목록을 조회한다.
     * @Method Name : retrieveUserDefineColumnList
     * @param param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrieveUserDefineColumnList(LGCOMData param) {
        return this.commonDao.selectList("LGVPAY00017.retrieveUserDefineColumnList", param);
    }

    /**
     * Desc : User Define Column 저장 전 체크 
     * - 급여 시스템담당자 권한이 있는지 체크
     * - 필수컬럼 값 유무 체크
     * - User Define Column Name 중복 체크
     * 
     * @Method Name : validateSaveUserDefineColumn
     * @param param
     * @return boolean
     * @throws Exception
     */
    @SuppressWarnings("unchecked")
	public boolean validateSaveUserDefineColumn(LGCOMData param) {
    	boolean validateFlag = false;
    	
    	validateFlag = lgvpaycomm.retrievePaySystemMasterAuthFlag(param); 
    	if ( !validateFlag ) {//급여담당자 권한이 없는 경우
    		throw new LGCOMException(messageSourceAccessor.getMessage("note.NoPermission"));
    		
    	} else {
            
            //필수체크 컬럼
            String[] requireFieldNames  = new String[] {"userColumnName"};//필수 컬럼명
            String[] requireFieldTitles = new String[] { messageSourceAccessor.getMessage("label.pay.columnKey")
            		                                    };//필수 컬럼명 화면 label
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
	        	}
	        }
            
	        //입력값 체크
            LGCOMData validateData = commonDao.select("LGVPAY00017.retireveValidateUserDefineColumnData", param);
            if ( !NullUtil.isNull(validateData) ) {
            	StringBuffer errorMsg = new StringBuffer();
                //User Define Column Name 중복 체크
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
	 * Desc : User Define Column 을 저장한다.
	 * - 값 유효성 체크
	 * - 삭제건 처리(데이터 삭제 후 같은 명칭으로 재등록할 수 있으므로 가장 먼저 삭제 처리함)
	 *   - User Define Table Column 삭제
	 *   - User Define Table Column Value 전체 삭제
	 * - 수정건 처리(데이터 수정 시 같은 명칭으로 변경할 수 있으므로 등록이전 수정 처리함)
	 * - 등록건 처리
	 * 
	 * @Method Name : saveUserDefineColumnList
	 * @param  param
	 * @throws Exception
	 */
	@SuppressWarnings("unchecked")
	@Transactional(propagation=Propagation.REQUIRED)
    public void saveUserDefineColumnList(LGCOMData param){
		if ( validateSaveUserDefineColumn(param) ) {//값 체크 정상인 경우 처리
			
	        LGCOMData userSession = param.getData(LGCOMConstants.HTTP_SESSION_KEY);
	        LGCOMData projectSession = param.getData("LGVHR_PROJECT_SESSION");
	        LGCOMData paramData = param.getData("parameter");
	
	        /* 삭제건 저장 */
	        List<LGCOMData> dList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_DELETE);
	        for( LGCOMData item : LGCOMUtils.emptyIfNull(dList) ) {
	        	item.set( LGCOMConstants.HTTP_SESSION_KEY, userSession );
	        	item.set( "LGVHR_PROJECT_SESSION", projectSession );
	        	item.set( "tableSeqNo", paramData.get("tableSeqNo"));
	        	
	            this.commonDao.delete("LGVPAY00017.deleteUserDefineColumnValueAll", item);
	            this.commonDao.delete("LGVPAY00017.deleteUserDefineColumn", item);
	        }
	        
	        /* 수정건 저장 */
	        List<LGCOMData> uList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_UPDATE);
	        for( LGCOMData item : LGCOMUtils.emptyIfNull(uList) ) {
	        	item.set( LGCOMConstants.HTTP_SESSION_KEY, userSession );
	        	item.set( "LGVHR_PROJECT_SESSION", projectSession );
	        	item.set( "tableSeqNo", paramData.get("tableSeqNo"));
	        	
	            this.commonDao.update("LGVPAY00017.updateUserDefineColumn",item);
	        }
	
	        /* 등록건 저장 */
	        List<LGCOMData> cList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_INSERT);
	        for( LGCOMData item : LGCOMUtils.emptyIfNull(cList) ) {
	        	item.set( LGCOMConstants.HTTP_SESSION_KEY, userSession );
	        	item.set( "LGVHR_PROJECT_SESSION", projectSession );
	        	item.set( "tableSeqNo", paramData.get("tableSeqNo"));
	                            
	            this.commonDao.insert("LGVPAY00017.insertUserDefineColumn",item);
	        }
		}
    }
}
