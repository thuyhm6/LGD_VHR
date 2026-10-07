/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVATT20450Service.java
 * @Desc    :
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2017. 10. 18.    bakderia    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvatt.lgvatt20450.service.serviceImpl;

import java.io.IOException;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;
import java.security.InvalidAlgorithmParameterException;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.sql.Clob;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

import javax.annotation.Resource;
import javax.crypto.BadPaddingException;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.NoSuchPaddingException;
import javax.servlet.http.HttpServletResponse;

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
import com.lgd.lgvhr.lgvatt.lgvatt20450.service.LGVATT20450Service;
import com.lgd.lgvhr.lgvcom.lgcomaes256util.service.serviceImpl.LGCOMAES256UTILServiceImpl;

import devonframe.util.NullUtil;
import devonframe.util.StringUtil;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvatt.LGVATT20450.controller.LGVATT20450Controller.java
 * </PRE>
 *
 * @Author    bakderia
 * @Date      2017. 10. 18. 오전 9:00:58
 * @Version
 */
@Service(value="LGVATT20450Service")
public class LGVATT20450ServiceImpl extends LGCOMAES256UTILServiceImpl implements LGVATT20450Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVATT20450ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

	@Resource(name="messageSourceAccessor")
    protected MessageSourceAccessor messageSourceAccessor;

	
	/**
	 * Desc : Value Set 목록을 조회한다.
	 * @Method Name : retrieveCodeValSetList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveMutiplanList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVATT20450.retrieveMutiplanList",param);
	}
	
	/**
	 * Desc : Attendance Detail 목록을 조회한다.
	 * @Method Name : retrieveAttendanceList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveAttendanceList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVATT20450.retrieveAttendanceList",param);
	}
	
	/**
	 * Desc : Attendance Detail 목록을 조회한다.
	 * @Method Name : retrieveAttendanceList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveAttendanceDetailList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVATT20450.retrieveAttendanceDetailList",param);
	}
	
	/**
	 * Desc : Attendance Detail 메세지를 조회한다.
	 * @Method Name : retrieveAttendanceList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public LGCOMData retrieveAttendanceDetailMessage(LGCOMData param) {
		LOGGER.debug("param = " + param);
		LGCOMData resultData = new LGCOMData();
		resultData = (LGCOMData) this.commonDao.select("LGVATT20450.retrieveAttendanceDetailMessage",param);
		
		if(resultData.getString("message") == null) {
			resultData.set("messageYn", "N");
		}else{
			resultData.set("messageYn", "Y");
		}
		
		return resultData;
	}
	
	/**
	 * Desc : 기등록된 장기근태 현황여부를 조회한다.
	 * @Method Name : retrieveCodeValSetList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public LGCOMData retrievePlanChk(LGCOMData param) {
		LOGGER.debug("param = " + param);
		LGCOMData resultData = new LGCOMData();
		LGCOMData projectSession = (LGCOMData)param.get("LGVHR_PROJECT_SESSION");
		String employeeNo = "";
		//결재요청자 자신의 결제건이 아닌 결제담당자가 요청할 경우 신청하는 결제요청자의 정보로 셋팅함.
		if(NullUtil.isNone(param.getString("employeeNo"))) {
			employeeNo = (String) projectSession.get("employeeNo");
			param.set("employeeNo", employeeNo);
		}else{
			employeeNo = param.getString("employeeNo");
			param.set("employeeNo", employeeNo);
		}
		
		resultData = (LGCOMData) this.commonDao.select("LGVATT20450.retrievePlanChk",param);
		
		return resultData;
	}
	/**
	 * Desc : 계획시작일과 계획종료일 간의 워크데이 일수를 조회한다.
	 * @Method Name : retrieveWorkDay
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public LGCOMData retrieveWorkDay(LGCOMData param) {
		LOGGER.debug("param = " + param);
		LGCOMData resultData = new LGCOMData();
		resultData = (LGCOMData) this.commonDao.select("LGVATT20450.retrieveWorkDay",param);
		
		return resultData;
	}
	
	/**
	 * Desc : 계획시작일에 대한 계획종료일을 조회한다.
	 * @Method Name : retrieveTodate
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public LGCOMData retrieveTodate(LGCOMData param) {
		LOGGER.debug("param = " + param);
		LGCOMData projectSession = (LGCOMData)param.get("LGVHR_PROJECT_SESSION");
		LGCOMData resultData = new LGCOMData();
		
		String employeeNo = "";
		//결재요청자 자신의 결제건이 아닌 결제담당자가 요청할 경우 신청하는 결제요청자의 정보로 셋팅함.
		if(NullUtil.isNone(param.getString("employeeNo"))) {
			employeeNo = (String) projectSession.get("employeeNo");
			param.set("employeeNo", employeeNo);
		}else{
			employeeNo = param.getString("employeeNo");
			param.set("employeeNo", employeeNo);
		}
		resultData = (LGCOMData) this.commonDao.select("LGVATT20450.retrieveTodate",param);
		
		return resultData;
	}
	/**
	 * Desc : 부서 하위 직원 목록을 조회한다.
	 * @Method Name : retrieveLowerEmpolyeeList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveLowerEmpolyeeList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVATT20450.retrieveLowerEmpolyeeList",param);
	}
	
	/**
     * Desc : Multiple Plan(Long Term) 정보를 저장한다.
     * @Method Name : saveMutipleLongPlan
     * @param  param
     * @throws Exception
     */
	@SuppressWarnings("unchecked")
	@Transactional(propagation=Propagation.REQUIRED)
    public LGCOMData saveMutipleLongPlan(LGCOMData param) {
		LOGGER.debug("param = " + param);
		
		LGCOMData userSession = (LGCOMData)param.get("USER_SESSION");
		LGCOMData projectSession = (LGCOMData)param.get("LGVHR_PROJECT_SESSION");
		LGCOMData resultData = new LGCOMData();
		LGCOMData registrantInfo = new LGCOMData();
		
		String systemCode = LGCOMUtils.getValueFromProjectProperties("systemCodeU");
        String projectSessionName = systemCode+"_PROJECT_SESSION";//프로젝트 세션명
        String key = "abcdefghijklmnopqrstuvwxyz123456";
		String decodeText = "";
		
		LGCOMData mdata = (LGCOMData) param.get("master");
		
		mdata.set("applicationUserId", userSession.get("applicationUserId"));
		mdata.set("subsidiaryCode", projectSession.get("subsidiaryCode"));

		//LOGGER.debug("넘어온 employeeNo =============>>>>> " + mdata.getString("employeeNo"));
		//LOGGER.debug("세션 employeeNo =============>>>>> " + projectSession.get("employeeNo"));
        
		/*************************************************************************
		 ***************************** 결제관련 처리 *****************************
		 *************************************************************************/
		
		// 결재요청아이디 시퀀스 조회
        LGCOMData requestMasterIdData = this.commonDao.select("LGVATTCOMM.retrieveRequestMasterId");
        
        if ( NullUtil.isNull(requestMasterIdData) ) {//요청아이디 정보가 없는 경우
        	LOGGER.error("error occured retrieve reqeust_master_id Data !!!!");
        	throw new LGCOMException ( messageSourceAccessor.getMessage("note.nodata") );
        	
        } else if ( NullUtil.isNone(requestMasterIdData.getString("requestMasterId")) ) {//조회한 요청아이디가 없는 경우 오류 처리
        	LOGGER.error("error occured retrieve reqeust_master_id!!!!");
        	throw new LGCOMException ( messageSourceAccessor.getMessage("note.nodata") );
        	
        } else {
        	//신청자 정보 조회
        	registrantInfo = this.commonDao.select("LGVATTCOMM.retrieveEmployee", mdata);
            
            mdata.set("approvalRequestId",requestMasterIdData.get("requestMasterId"));
            
            //결재요청자 자신의 결제건이 아닌 결제담당자가 요청할 경우 신청하는 결제요청자의 정보로 셋팅함.
            if(!projectSession.get("employeeNo").equals(mdata.getString("employeeNo"))) {
            	requestMasterIdData.set("requestorId", registrantInfo.get("applicationUserId"));
            }else{
            	requestMasterIdData.set("requestorId", userSession.get("applicationUserId"));
            }
            
            requestMasterIdData.set( LGCOMConstants.HTTP_SESSION_KEY, userSession );//요청정보 조회하면서 세션정보 일부 셋팅함.
            requestMasterIdData.set( projectSessionName, projectSession );
            requestMasterIdData.set( "approvalMenuId", mdata.get("approvalMenuId") );
            requestMasterIdData.set( "systemCode", systemCode );
            
            /* 요청코드, 시스템코드, 모듈코드, 요청번호, 요청제목등 조회 */
            LGCOMData approvalMasterData = new LGCOMData();
            LGCOMData planningInfo = new LGCOMData();
            approvalMasterData = this.commonDao.select("LGVATTCOMM.retreiveRequestBasicInfo", requestMasterIdData);
            
            //데이터가 없는 경우 처리하지 않음
            if (approvalMasterData != null && !approvalMasterData.isEmpty()) {
            	/* 계획수립 아이디 시퀀스 조회 */
            	planningInfo = this.commonDao.select("LGVATT20450.retreivePlanningSeq");
            	String planningId = planningInfo.getString("planningId");
            	
            	approvalMasterData.set("planningId", planningId);
            	mdata.set("planningId",planningId);
            	mdata.set("reason",mdata.getString("reason").replaceAll("<(/)?([a-zA-Z]*)(\\s[a-zA-Z]*=[^>]*)?(\\s)*(/)?>", ""));
            	/**********************************************************************
    	         *************************  장기근태정보 등록 *************************
    	         **********************************************************************/
            	this.commonDao.insert("LGVATT20450.insertMutipleLongPlan", mdata);
            	
            	String subsidiaryCode = projectSession.getString("subsidiaryCode");
            	
            	//대리신청이 아니고 자신이 신청했을경우 
            	if(!projectSession.get("employeeNo").equals(mdata.getString("employeeNo"))) {
            		approvalMasterData.set("ouId", registrantInfo.get("defaultOrgId"));
            		
            		//LOGGER.debug("요청자와 결제자가 틀림 =============>>>>> " + requestMasterIdData.get("requestorId"));
            	}
            	/**********************************************************************
    	         ********************  공통 결재마스터 테이블 등록 *********************
    	         **********************************************************************/
    	        this.commonDao.select("LGVATTCOMM.insertApprovalMaster", approvalMasterData);
                
    			if( !"OK".equals( approvalMasterData.getString("retCode") ) ) {
    				throw new LGCOMException( approvalMasterData.getString("errorMessage") );
    			}
    	        
    			/**********************************************************************
    	         ******************* 공통 결재상태 테이블에 결재자 등록 ***************
    	         **********************************************************************/
    	        List<LGCOMData> approvalList = (List<LGCOMData>)param.get("approval");
    	        for( LGCOMData item : LGCOMUtils.emptyIfNull(approvalList) ) {
    	        	
    	            item.put("sessionAppUserId", requestMasterIdData.get("requestorId"));
    	            item.put("approvalActionCode", "APPROVAL");
    	            item.put("requestMasterId", approvalMasterData.get("requestMasterId"));
    	            item.put("requestCode", approvalMasterData.get("requestCode"));
    	            item.put("ouId",approvalMasterData.get("ouId"));
    	            
    	            //결제자 사번 복호화처리
    	            try {
    					decodeText = AES_Decode(item.getString("employeeNo"), key);
    				} catch (InvalidKeyException | UnsupportedEncodingException | NoSuchAlgorithmException
    						| NoSuchPaddingException | InvalidAlgorithmParameterException | IllegalBlockSizeException
    						| BadPaddingException e) {
    					throw new LGCOMException(e.getMessage());
    				}
    	            
    	            item.put("employeeNo", decodeText);
    	            this.commonDao.select("LGVATTCOMM.insertApprovalLine",item);
    	            
    				if( !"OK".equals( item.getString("retCode") ) ) {
    					throw new LGCOMException( item.getString("errorMessage") );
    				}
    	        }
    	        
	        	approvalMasterData.set("approvalCommand", "REQUEST");	//결제구분 : 승인요청
	        	approvalMasterData.set("sessionAppUserId",requestMasterIdData.get("requestorId"));
	        	
	        	this.commonDao.select("LGVATTCOMM.insertApprovalRequest", approvalMasterData); 
	        	
				if( !"OK".equals( approvalMasterData.getString("retCode") ) ) {
					throw new LGCOMException( approvalMasterData.getString("errorMessage") );
				}
				
				//잔여휴가 체크하여 잔여휴가가 없을경우 처리
				String errorMsg = retrieveAnnualLeave(mdata);
				if(errorMsg.length() != 0 && errorMsg != null) {
					throw new LGCOMException(messageSourceAccessor.getMessage(errorMsg));
				}
    	        
    	        /**********************************************************************
    	         *************************  장기근태 업데이트 *************************
    	         **********************************************************************/
    	        LGCOMData uData = new LGCOMData();
    	        
    	        uData.put("approvalRequestId",approvalMasterData.get("requestMasterId"));
    	        uData.put("requestCode",approvalMasterData.get("requestCode"));
    	        uData.put("subsidiaryCode",subsidiaryCode);
    	        uData.put("employeeNo",mdata.getString("employeeNo"));
    	        uData.put("sessionAppUserId",requestMasterIdData.get("requestorId"));
    	        
    	        this.commonDao.update("LGVATT20450.updateMutipleLongPlan",uData); 
            }
            resultData.set("requestMasterId", approvalMasterData.get("requestMasterId"));
            resultData.set("requestCode", approvalMasterData.get("requestCode"));
            resultData.set("employeeNo", mdata.getString("employeeNo"));
        }
        return resultData;
    }
    
	@SuppressWarnings("unchecked")
	public LGCOMData checkInputData(LGCOMData param) throws IOException {
    	LOGGER.debug("param = " + param);
    	LGCOMData mdata = (LGCOMData) param.get("master");
    	LGCOMData returnRegCnt = new LGCOMData();
		LGCOMData inputDateBetweenCheck = new LGCOMData();
		LGCOMData searchTodate = new LGCOMData();
		LGCOMData projectSession = (LGCOMData)param.get("LGVHR_PROJECT_SESSION");
    	
		String subsidiaryCode = projectSession.getString("subsidiaryCode");
		int cnt = 0;
		
    	SimpleDateFormat mSimpleDateFormat = new SimpleDateFormat("dd/MM/yyyy");
    	Date currentTime = new Date();
    	String mTime = mSimpleDateFormat.format(currentTime);
    	
    	LGCOMData returnData = new LGCOMData();
    	returnData.set("message","");
    	
    	Date planStartDate = null;
    	Date planEndDate = null; 
    	Date toDay = null;
    	
    	if(NullUtil.isNull(mdata)) {
    		returnData.set("message", messageSourceAccessor.getMessage("error.noPlanData"));
			return returnData;
    	}else{
    		/*************************************************************************
    		 ************************ 입력항목에 대한 필수체크 ***********************
    		 *************************************************************************/
    		try{
    			toDay = mSimpleDateFormat.parse(mTime);
    			
    			//계획시작일자 체크
    			if(mdata.getString("planStartDate").length() == 0 || mdata.getString("planStartDate") == null) {
        			returnData.set("message", messageSourceAccessor.getMessage("note.att.checkPlanDate"));
        			return returnData;
        		}else{
        			planStartDate = mSimpleDateFormat.parse(mdata.getString("planStartDate"));
        			int compare = planStartDate.compareTo(toDay);
        			
        			//계획시작일이 오늘날짜보다 작으면 return
        			if(compare < 0) {
        				returnData.set("message", messageSourceAccessor.getMessage("note.att.checkPlanDate"));
            			return returnData;
        			}
        		}
        		//계획종료일자 체크
    			if(mdata.getString("planEndDate").length() == 0 || mdata.getString("planEndDate") == null) {
        			returnData.set("message", messageSourceAccessor.getMessage("note.att.checkPlanDate")); 
        			return returnData;
        		}else{
        			planEndDate = mSimpleDateFormat.parse(mdata.getString("planEndDate"));
        			//계획시작일자가 계획종료일자 보다 큰경우 체크
        			int compare = planStartDate.compareTo(planEndDate);
        			
        			if(compare > 0) {
        				returnData.set("message", messageSourceAccessor.getMessage("note.att.checkPlanDate"));
            			return returnData;
        			}
        		}
        		//결제요청자 체크
        		if (Integer.parseInt(mdata.getString("employeeSize")) > 1 ) {
        			if(mdata.getString("employeeNo").length() == 0 || mdata.getString("employeeNo") == null) {
        				returnData.set("message", messageSourceAccessor.getMessage("note.att.emptyEmployee"));
            			return returnData;
        			 }
        		 }
        		//selectBox value check
    			if(mdata.getString("attendanceMaster").length() == 0 || mdata.getString("attendanceMaster") == null) {
        			returnData.set("message", messageSourceAccessor.getMessage("note.att.checkSelectAttendanceType"));
        			return returnData;
        		}
    			if(mdata.getString("attendanceDetail").length() == 0 || mdata.getString("attendanceDetail") == null) {
        			returnData.set("message", messageSourceAccessor.getMessage("note.att.emptyAttendance"));
        			return returnData;
        		}
        		if(mdata.getString("thirdSize").length() != 0 && mdata.getString("thirdSize") != null) {
	        		if(Integer.parseInt(mdata.getString("thirdSize")) > 1) {
	        			if(mdata.getString("attendanceDetailLower").length() == 0 || mdata.getString("attendanceDetailLower") == null) {
                			returnData.set("message", messageSourceAccessor.getMessage("note.selectAttendanceDetailReason"));
                			return returnData;
		        		}
	        		}
        		}

    			if(mdata.getString("reason").length() == 0 || mdata.getString("reason") == null) {
        			returnData.set("message", messageSourceAccessor.getMessage("note.att.checkInputReason"));
        			return returnData;
        		}
    		}catch (ParseException e) {
    			e.printStackTrace();
    		}
    		/*************************************************************************
    		 ************************ 입력항목에 대한 로직체크 ***********************
    		 *************************************************************************/
    		mdata.set("subsidiaryCode", subsidiaryCode);
			
    		//기등록된 일정이 있는지 체크
    		returnRegCnt = this.commonDao.select("LGVATT20450.retrievePlanChk", mdata);
    		cnt = Integer.parseInt(returnRegCnt.getString("cnt"));
    		if(cnt > 0) {
    			returnData.set("message", messageSourceAccessor.getMessage("note.att.regPlanCheck"));
    			return returnData;
    		}
    		//워킹데이 날짜 수 구하기
    		mdata.set("subsidiaryCode", subsidiaryCode);
    		inputDateBetweenCheck = this.commonDao.select("LGVATT20450.retrieveWorkDay", mdata);
    		int workDay = Integer.parseInt(inputDateBetweenCheck.getString("workDay"));
    		mdata.set("workDay", workDay);
			
    		//계획일자 제한이 있을경우
			if(mdata.getString("daylimit").length() != 0 && mdata.getString("daylimit") != null) {
    			if(workDay > Integer.parseInt(mdata.getString("daylimit"))) {
        			returnData.set("message", messageSourceAccessor.getMessage("note.att.checkLimitDate"));
        			return returnData;
    			}else{
    				//계획시작일에 대한 계획종료일 조회
    				searchTodate = this.commonDao.select("LGVATT20450.retrieveTodate", mdata);
    				
    				if(!mdata.getString("planEndDate").replaceAll("/", "").equals(searchTodate.getString("toDate").replaceAll("-", ""))) {
            			returnData.set("message", messageSourceAccessor.getMessage("note.att.checkPlanDate"));
            			return returnData;
    				}
    			}
    		}else{
    			//계획시작일에 대한 계획종료일 조회
				searchTodate = this.commonDao.select("LGVATT20450.retrieveTodate", mdata);

				if(searchTodate.getString("toDate").length() != 0 && mdata.getString("toDate") != null) {
					if(!mdata.getString("planEndDate").replaceAll("/", "").equals(searchTodate.getString("toDate").replaceAll("-", ""))) {
            			returnData.set("message", messageSourceAccessor.getMessage("note.att.checkPlanDate"));
	        			return returnData;
					}
				}
    		}
    	}
		//결제자 정보체크
		List<LGCOMData> approvalList = (List<LGCOMData>)param.get("approval");
        
        if(NullUtil.isNull(approvalList)) {
        	//결제자 정보 없을때 메세지
			returnData.set("message", messageSourceAccessor.getMessage("note.att.emptyApprover"));
			return returnData;
        }
		return returnData;
    }
    
    /**
	 * 잔여휴가를 확인한다.
	 * @Method Name : retrieveAnnualLeave
	 * @param param.sessionAppUserId   : 사용자아이디 application_usr_id
	 *             .attType        	   : 결제요청일때 장기근태 코드(LT_TA_REQ)
	 *             .subsidiaryCode 	   : 결재자 요청자 법인코드
	 *             .employeeNo         : 사번
	 *             .languageCode       : 사용자 언어코드
	 *             .attendanceYyyymmdd : 오늘날짜
	 * @return String : 오류메세지
	 */
	private String retrieveAnnualLeave(LGCOMData mdata) {
		SimpleDateFormat mSimpleDateFormat = new SimpleDateFormat("dd/MM/yyyy");
    	Date currentTime = new Date();
    	String mTime = mSimpleDateFormat.format(currentTime);
		String errorMsg = "";
		
		//잔여 휴가일수 체크 retreiveAnnualLeave
		LGCOMData employeeInfo = new LGCOMData();
		LGCOMData annualLeaveInput = new LGCOMData();
        employeeInfo = this.commonDao.select("LGVATTCOMM.retrieveEmployee", mdata);
		
		annualLeaveInput.set("sessionAppUserId", employeeInfo.get("applicationUserId"));
        annualLeaveInput.set("attType", "LT_TA_REQ"); //결제요청일때
        annualLeaveInput.set("subsidiaryCode", employeeInfo.get("subsidiaryCode"));
        annualLeaveInput.set("employeeNo", mdata.getString("employeeNo"));
        annualLeaveInput.set("languageCode", employeeInfo.getString("languageCode"));
        annualLeaveInput.set("attendanceYyyymmdd", mTime);
        annualLeaveInput.set("requestNo", mdata.getString("planningId"));
        annualLeaveInput.set( "newInputResultAttCode", "");
        annualLeaveInput.set( "newInputPlanAttCode", "");
        

        this.commonDao.select("LGVATTCOMM.retrieveValidateAnualLeave", annualLeaveInput); 
    	
		if(!"0".equals(annualLeaveInput.getString("retCode"))) {
			errorMsg = annualLeaveInput.getString("errorMessage");
		}
		return errorMsg;
	}
	/**
	 * Desc : 재량권 번호, 요청서코드 조회(화면에서 하드코딩 하지 않고 쿼리에 하드코딩하여 사용함)
	 * @Method Name : retrieveRequestDocBaseInfo
	 * @param  param
	 * @return LGCOMData
	 */
	public LGCOMData retrieveRequestDocBaseInfo(LGCOMData param) {
		return this.commonDao.select("LGVATT20450.retrieveRequestDocBaseInfo", param);
	}
}
