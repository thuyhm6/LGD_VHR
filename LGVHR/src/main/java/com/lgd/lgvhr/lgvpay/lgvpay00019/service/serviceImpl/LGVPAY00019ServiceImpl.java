/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAY00019ServiceImpl.java
 * @Desc    : User Defined Table Value
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2018. 02. 01.    limsujin    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvpay.lgvpay00019.service.serviceImpl;

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
import com.lgd.lgvhr.lgvpay.lgvpay00019.service.LGVPAY00019Service;
import com.lgd.lgvhr.lgvpay.lgvpaycomm.service.LGVPAYCOMMService;
import com.lgd.lgvhr.lgvpay.util.LGVPAYUtil;

import devonframe.util.DateUtil;
import devonframe.util.NullUtil;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpay00019.service.serviceImpl.LGVPAY00019ServiceImpl.java
 * </PRE>
 *
 * @Author    limsujin
 * @Date      2018. 02. 01. 
 * @Version
 */
@Service("LGVPAY00019Service")
public class LGVPAY00019ServiceImpl implements LGVPAY00019Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVPAY00019ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;
	
    @Resource(name="messageSourceAccessor")
    protected MessageSourceAccessor messageSourceAccessor;
    
    @Resource(name="LGVPAYCOMMService")
    private LGVPAYCOMMService lgvpaycomm;


    /** 
     * User Define Table Value 목록을 조회한다.
     * @param param
     * @return
     */
    public List<LGCOMData> retrieveUserDefineTableValueList(LGCOMData param) {
        return this.commonDao.selectList("LGVPAY00019.retrieveUserDefineTableValueList", param);
    }

    /**
     * Desc : User Define Table Value 저장 전 체크 
     * - 급여 시스템담당자 권한이 있는지 체크
     * - 입력값 체크
     *   - 필수입력 체크
     *   - effectiveStartYyyymmdd 
     *     - 날짜포맷(dd/mm/yyyy) 체크
     *   - effectiveEndYyyymmdd 
     *     - 날짜포맷(dd/mm/yyyy) 체크
     *     - 종료일이 시작일 이후인지 체크
     * - 유효성 체크
     *   - 유효기간 시작일 중복 체크
     *   - 유효기간 중복 체크
     * 
     * @Method Name : validateSaveUserDefineTableValue
     * @param param
     * @return boolean
     * @throws Exception
     */
	public boolean validateSaveUserDefineTableValue(LGCOMData param) {
    	boolean validateFlag = false;
    	
    	validateFlag = lgvpaycomm.retrievePaySystemMasterAuthFlag(param); 
    	if ( !validateFlag ) {//급여담당자 권한이 없는 경우
    		throw new LGCOMException(messageSourceAccessor.getMessage("note.NoPermission"));
    		
    	} else {
            //필수체크 컬럼
            String[] requireFieldNames  = new String[] {"tableCellValue", "effectiveStartYyyymmdd", "effectiveEndYyyymmdd"};//필수 컬럼명
            String[] requireFieldTitles = new String[] { messageSourceAccessor.getMessage("label.pay.value")
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
	        	}//end-if ( requireFieldNames.length > 0 )
	        	
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
	        }//end-for
            
            LGCOMData validateData = commonDao.select("LGVPAY00019.retireveValidateUserDefineTableValueData", param);
            if ( !NullUtil.isNull(validateData) ) {
            	StringBuffer errorMsg = new StringBuffer();
            	//시작일 중복 체크
            	if ( NullUtil.notNone(validateData.getString("dupStartDate")) ) {		            		
            		errorMsg.append(messageSourceAccessor.getMessage("error.duplicateValue"))
            		        .append(validateData.getString("dupStartDateTitle"))
            		        .append(validateData.getString("dupStartDate"));
    	    		throw new LGCOMException(errorMsg.toString());
    	    	//유효기간 중복 체크
            	} else if ( NullUtil.notNone(validateData.getString("dupPeriod")) ) {
        	    	throw new LGCOMException(messageSourceAccessor.getMessage("note.pay.duplicatePeriod"));
	            }
            }//end-if ( !NullUtil.isNull(validateData) ) 
    		validateFlag = true;
    	}
    	
    	return validateFlag;
    }

	/**
	 * Desc : User Define Table Value 를 저장한다.
	 * - 값 유효성 체크
	 * - 삭제건 처리(데이터 삭제 후 같은 명칭으로 재등록할 수 있으므로 가장 먼저 삭제 처리함)
	 * - 수정건 처리(데이터 수정 시 같은 명칭으로 변경할 수 있으므로 등록이전 수정 처리함)
	 * - 등록건 처리
	 * 
	 * @Method Name : saveUserDefineTableValueList
	 * @param  param
	 * @throws Exception
	 */
	@SuppressWarnings("unchecked")
	@Transactional(propagation=Propagation.REQUIRED)
    public LGCOMData saveUserDefineTableValueList(LGCOMData param){
		if ( validateSaveUserDefineTableValue(param) ) {//값 체크 정상인 경우 처리
			
	        LGCOMData userSession = param.getData(LGCOMConstants.HTTP_SESSION_KEY);
	        LGCOMData projectSession = param.getData("LGVHR_PROJECT_SESSION");
	        
	        /* 삭제건 처리 */
	        List<LGCOMData> dList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_DELETE);
	        for( LGCOMData item : LGCOMUtils.emptyIfNull(dList) ) {
	        	item.set( LGCOMConstants.HTTP_SESSION_KEY, userSession );
	        	item.set( "LGVHR_PROJECT_SESSION", projectSession );
	        	item.set( "tableSeqNo", param.getData("parameter").get("tableSeqNo") );
	        	item.set( "rowNo", param.getData("parameter").get("rowNo") );
	        	item.set( "columnSeqNo", param.getData("parameter").get("columnSeqNo") );

	            this.commonDao.delete("LGVPAY00019.deleteUserDefineTableValue",item);
	        }
	        
	        /* 수정건 저장 */
	        List<LGCOMData> uList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_UPDATE);
	        for( LGCOMData item : LGCOMUtils.emptyIfNull(uList) ) {
	        	item.set( LGCOMConstants.HTTP_SESSION_KEY, userSession );
	        	item.set( "LGVHR_PROJECT_SESSION", projectSession );
	        	item.set( "tableSeqNo", param.getData("parameter").get("tableSeqNo") );
	        	item.set( "rowNo", param.getData("parameter").get("rowNo") );
	        	item.set( "columnSeqNo", param.getData("parameter").get("columnSeqNo") );
	        	
	            this.commonDao.update("LGVPAY00019.updateUserDefineTableValue",item);
	        }
	
	        /* 등록건 저장 */
	        List<LGCOMData> cList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_INSERT);
	        for( LGCOMData item : LGCOMUtils.emptyIfNull(cList) ) {
	        	item.set( LGCOMConstants.HTTP_SESSION_KEY, userSession );
	        	item.set( "LGVHR_PROJECT_SESSION", projectSession );
	        	item.set( "tableSeqNo", param.getData("parameter").get("tableSeqNo") );
	        	item.set( "rowNo", param.getData("parameter").get("rowNo") );
	        	item.set( "columnSeqNo", param.getData("parameter").get("columnSeqNo") );

	            this.commonDao.insert("LGVPAY00019.insertUserDefineTableValue",item);
	        }
		}
		return param;
    }
}
