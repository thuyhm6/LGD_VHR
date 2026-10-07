/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAY00021ServiceImpl.java
 * @Desc    : 급여대상자 관리
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2017. 12. 05.    Sonsuyang    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvpay.lgvpay00021.service.serviceImpl;

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
import com.lgd.lgvhr.lgvpay.lgvpay00021.service.LGVPAY00021Service;
import com.lgd.lgvhr.lgvpay.lgvpaycomm.service.LGVPAYCOMMService;

import devonframe.util.NullUtil;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpay00021.controller.lgvpay00021Controller.java
 * </PRE>
 *
 * @Author    Sonsuyang
 * @Date      2017. 11. 17. 오전 9:00:58
 * @Version
 */
@Service(value="LGVPAY00021Service")
public class LGVPAY00021ServiceImpl implements LGVPAY00021Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVPAY00021ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;
	
	@Resource(name="messageSourceAccessor")
    protected MessageSourceAccessor messageSourceAccessor;
    
    @Resource(name="LGVPAYCOMMService")
    private LGVPAYCOMMService lgvpaycomm;

	/**
	 * Desc : Calculation Set를 조회한다.
	 * @Method Name : retrieveCalcSetList
	 * @param  param
	 * @return List<LGCOMData>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveCalcSetList(LGCOMData param) {
		return this.commonDao.selectList("LGVPAY00021.retrieveCalcSetList",param);
	}

	/**
	 * Desc : Calculation Set 한 건을 조회한다.
	 * @Method Name : retrieveCalcSetData
	 * @param  param
	 * @return LGCOMData
	 * @throws Exception
	 */
	public LGCOMData retrieveCalcSetData(LGCOMData param) {
		param.set( "srchPayrollCalculationSetId", NullUtil.nvl(param.getString("srchPayrollCalculationSetId"), param.getString("payrollCalculationSetId")));
		return this.commonDao.select("LGVPAY00021.retrieveCalcSetList",param);
	}
	
	/**
     * Desc : Calculation Set 저장 전 값 체크
     * - 급여 담당자 권한이 있는지 체크
     * - 입력값 체크
     *   - 필수입력 체크
     * - 유효성 체크
     *   - Calculation Set Name 중복 체크
     *   
     * @Method Name : validateSaveCalcSet
     * @param  param
     * @throws Exception
     */
    public boolean validateSaveCalcSet(LGCOMData param) {
    	boolean validateFlag = false;
    	
    	validateFlag = lgvpaycomm.retrievePayMasterAuthFlag(param); 
    	if ( !validateFlag ) {//급여담당자 권한이 없는 경우
    		throw new LGCOMException(messageSourceAccessor.getMessage("note.NoPermission"));
    		
    	} else {
    		//에러메세지
        	StringBuffer errorMsg = new StringBuffer();
            //필수체크 컬럼
            String[] requireFieldNames  = new String[] {"payrollCalculationSetName", "resignationFlag", "payrollTypeCode", "autoCreationFlag"};//필수 컬럼명
            String[] requireFieldTitles = new String[] { messageSourceAccessor.getMessage("label.pay.calculationSet")
                                                       , messageSourceAccessor.getMessage("label.pay.resignationFlag")
                                                       , messageSourceAccessor.getMessage("label.pay.payType")
                                                       , messageSourceAccessor.getMessage("label.pay.autoCreationFlag") };//필수 컬럼명 화면 label

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
	        	
	        	//수정건인 경우 급여실행결과 있으면 payrollTypeCode 수정 불가 체크
	        	if ( NullUtil.notNone(item.getString("payrollCalculationSetId")) ) {
		        	
		        	item.set( LGCOMConstants.HTTP_SESSION_KEY, param.getData(LGCOMConstants.HTTP_SESSION_KEY) );
		        	item.set( "LGVHR_PROJECT_SESSION", param.getData("LGVHR_PROJECT_SESSION") );
		        	LGCOMData setData = this.retrieveCalcSetData(item);
		        	//에러메세지 초기화
		        	errorMsg.delete(0, errorMsg.length());
		        	
		        	if ( !NullUtil.isNull(setData) ) {
		        		//급여실행결과 있는 경우 payrollTypeCode 수정불가 체크
		        		if ( "Y".equals(setData.getString("execFlag")) && !item.getString("payrollTypeCode").equals(setData.getString("payrollTypeCode")) ) {
		        			//이미 실행된 결과가 있으므로 저장 불가능합니다.
		            		errorMsg.append(messageSourceAccessor.getMessage("note.pay.saveAlreadyRunResult"))
	        		        		.append("<br/>")
			        		        .append(messageSourceAccessor.getMessage("label.pay.calculationSet"))
			        		        .append("=")
			        		        .append(item.getString("payrollCalculationSetName"));
		            		throw new LGCOMException(errorMsg.toString());
		        		}
		        	}
	        	}
	        }//end-for
    		
    		//삭제건 체크
	        for ( LGCOMData item : LGCOMUtils.emptyIfNull(param.getList(LGCOMConstants.STATUS_DELETE)) ) {
	        	
	        	item.set( LGCOMConstants.HTTP_SESSION_KEY, param.getData(LGCOMConstants.HTTP_SESSION_KEY) );
	        	item.set( "LGVHR_PROJECT_SESSION", param.getData("LGVHR_PROJECT_SESSION") );
	        	LGCOMData setData = this.retrieveCalcSetData(item);
	        	//에러메세지 초기화
	        	errorMsg.delete(0, errorMsg.length());
	        	
	        	if ( !NullUtil.isNull(setData) ) {
	        		//급여실행결과 있는 경우 삭제불가 체크
	        		if ( "Y".equals(setData.getString("execFlag")) ) {
	        			//이미 실행된 결과가 있으므로 삭제 불가능합니다.
	            		errorMsg.append(messageSourceAccessor.getMessage("note.pay.deleteAlreadyRunResult"))
		        				.append("<br/>")
		        		        .append(messageSourceAccessor.getMessage("label.pay.calculationSet"))
		        		        .append("=")
		        		        .append(item.getString("payrollCalculationSetName"));
	            		throw new LGCOMException(errorMsg.toString());
	        		}
	        	}
	        	
	        }//end-for
            
            LGCOMData validateData = commonDao.select("LGVPAY00021.retireveValidateCalcSetData", param);
            if ( !NullUtil.isNull(validateData) ) {
	        	//에러메세지 초기화
	        	errorMsg.delete(0, errorMsg.length());
	        	
            	//Calculation Set Name 중복 체크
            	if ( NullUtil.notNone(validateData.getString("dupCalcSetNames")) ) {		            		
            		errorMsg.append(messageSourceAccessor.getMessage("error.duplicateValue"))
            		        .append(validateData.getString("dupCalcSetNamesTitle"))
            		        .append(validateData.getString("dupCalcSetNames"));
    	    		throw new LGCOMException(errorMsg.toString());
	            }
            }//end-if ( !NullUtil.isNull(validateData) ) 
    		validateFlag = true;
    	}
    	
    	return validateFlag;
    }
	
	/**
     * Desc : Calculation Set을 저장한다.
     * @Method Name : saveCalcSet
     * @param  param
     * @throws Exception
     */
    @SuppressWarnings("unchecked")
	@Transactional(propagation=Propagation.REQUIRED)
	public void saveCalcSet(LGCOMData param) {
		if ( validateSaveCalcSet(param) ) {//값 체크 정상인 경우 처리
			
	        LGCOMData userSession = param.getData(LGCOMConstants.HTTP_SESSION_KEY);
	        LGCOMData projectSession = param.getData("LGVHR_PROJECT_SESSION");
			
			//삭제처리
			for( LGCOMData item : LGCOMUtils.emptyIfNull((List<LGCOMData>)param.get(LGCOMConstants.STATUS_DELETE)) ) {
	        	item.set( LGCOMConstants.HTTP_SESSION_KEY, userSession );
	        	item.set( "LGVHR_PROJECT_SESSION", projectSession );

	        	//Calculation Set 대상자 전체삭제
				this.commonDao.delete("LGVPAY00021.deleteCalcSetTargetPerAll", item);
				this.commonDao.delete("LGVPAY00021.deleteCalcSet", item);
			}
			
			//수정처리
			for( LGCOMData item : LGCOMUtils.emptyIfNull((List<LGCOMData>)param.get(LGCOMConstants.STATUS_UPDATE)) ) {
	        	item.set( LGCOMConstants.HTTP_SESSION_KEY, userSession );
	        	item.set( "LGVHR_PROJECT_SESSION", projectSession );

				this.commonDao.delete("LGVPAY00021.updateCalcSet", item);
			}
			
			//등록처리
			for( LGCOMData item : LGCOMUtils.emptyIfNull((List<LGCOMData>)param.get(LGCOMConstants.STATUS_INSERT)) ) {
	        	item.set( LGCOMConstants.HTTP_SESSION_KEY, userSession );
	        	item.set( "LGVHR_PROJECT_SESSION", projectSession );
	        	
				this.commonDao.update("LGVPAY00021.insertCalcSet", item);
			}
		}
	}
}
