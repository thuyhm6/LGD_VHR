package com.lgd.lgvhr.lgvatt.lgvatt20060.service.serviceImpl;

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
import com.lgd.lgvhr.lgvatt.lgvatt20060.service.LGVATT20060Service;

@Service(value="LGVATT20060Service")
public class LGVATT20060ServiceImpl implements LGVATT20060Service {
	protected final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVATT20060ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao; 

	@Resource(name="messageSourceAccessor")
    protected MessageSourceAccessor messageSourceAccessor;
	
	/**
	 * Desc : 
	 * @Method Name : retrieveLWResultList
	 * @param  param
	 * @return List<LGCOMData>
	 * @throws Exception
	 */
	@Override
	public List<LGCOMData> retrieveLWResultList(LGCOMData param) {
		// TODO Auto-generated method stub
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVATT20060.retrieveLWResultList",param);
	}
	
	/**
	 * Desc : 재량권 번호, 요청서코드 조회(화면에서 하드코딩 하지 않고 쿼리에 하드코딩하여 사용함)
	 * @Method Name : retrieveRequestDocBaseInfo
	 * @param  param
	 * @return LGCOMData
	 */
	public LGCOMData retrieveRequestDocBaseInfo(LGCOMData param) {
		return this.commonDao.select("LGVATT20060.retrieveRequestDocBaseInfo", param);
	}
	
	/**
	 * Desc : requestLWResultList
	 * @Method Name : requestLWResultList
	 * @param  param
	 * @return void
	 * @throws Exception
	 */
    @SuppressWarnings("unchecked")
	@Transactional(propagation=Propagation.REQUIRED)
	public void requestLWResultList(LGCOMData param) throws LGCOMException{
    	LOGGER.debug("param = " + param);
    	String systemCode = LGCOMUtils.getValueFromProjectProperties("systemCodeU");
        String projectSessionName = systemCode+"_PROJECT_SESSION";//프로젝트 세션명
        LGCOMData userSession = (LGCOMData)param.get(LGCOMConstants.HTTP_SESSION_KEY);
        LGCOMData projectSession = (LGCOMData)param.get(projectSessionName);

        // 결재요청아이디 시퀀스 조회
        LGCOMData requestMasterIdData = this.commonDao.select("LGVATTCOMM.retrieveRequestMasterId");
        
        requestMasterIdData.set( LGCOMConstants.HTTP_SESSION_KEY, userSession );//요청정보 조회하면서 세션정보 일부 셋팅함.
        requestMasterIdData.set( projectSessionName, projectSession );
        requestMasterIdData.set( "approvalMenuId", "M_LGVATT_1022" );
        requestMasterIdData.set( "systemCode", systemCode );
        requestMasterIdData.set("requestorId", userSession.get("applicationUserId"));
        
        /* 요청코드, 시스템코드, 모듈코드, 요청번호, 요청제목등 조회 */
        LGCOMData approvalMasterData = new LGCOMData();
        approvalMasterData = this.commonDao.select("LGVATTCOMM.retreiveRequestBasicInfo", requestMasterIdData);
        
        // 데이터가 없는 경우 처리하지 않음
        if ( approvalMasterData != null && !approvalMasterData.isEmpty() ) {
        	
			/* 실적수정건 저장 */
			List<LGCOMData> modifyList = (List<LGCOMData>)param.get("modifyList");
			
			for( LGCOMData item : LGCOMUtils.emptyIfNull(modifyList) ) {
				item.put("applicationUserId",userSession.get("applicationUserId"));
				item.put("requestMasterId", approvalMasterData.get("requestMasterId"));
				item.put("requestCode", approvalMasterData.get("requestCode"));
				item.put( LGCOMConstants.HTTP_SESSION_KEY, userSession );
				item.put( projectSessionName, projectSession );
				item.put("requestNo", approvalMasterData.get("requestNo"));
				item.put("subsidiaryCode",projectSession.getString("subsidiaryCode"));
				
				LOGGER.debug("item=>" + item);
				
				LGCOMData isExistFlag = this.commonDao.select("LGVATT20060.isExistResult", item);
				
				if(isExistFlag.get("isExistFlag").equals("true")) {
					this.commonDao.delete("LGVATT20060.deleteExistResult", item);
				} 

				this.commonDao.insert("LGVATT20060.insertOldResult", item);
				
				if( "Y".equals(item.getString("isEditOt")) ) {
	        		
	        		LGCOMData tempData = new LGCOMData();
	        		tempData.set("subsidiaryCode", item.get("subsidiaryCode"));
	        		tempData.set("employeeNo", item.get("employeeNo"));//HMT_20210717 Add employeeNo 
	        		tempData.set("attendanceYyyymmdd", item.get("actualDate"));
	        		tempData.set("attendanceCode", item.get("actualAttendanceDetail"));
	        		tempData.set("shiftTypeCode", item.get("actualShiftCode"));
	        		tempData.set("dayNightFlag", item.get("actualDayNight"));
	        		tempData.set("dinnerFlag", item.get("actualDinnerChk"));
	        		tempData.set("workingStartTime", item.get("actualStartTm"));
	        		tempData.set("lateness", String.valueOf(item.get("deductionLateness")));
	        		tempData.set("leavingEarly", String.valueOf(item.get("deductionLeavingEarly")));
	        		tempData.set("goingOut", String.valueOf(item.get("deductionGoingOut")));
	        		tempData.set("overtimeSumHours", String.valueOf(item.get("actualOT")));
	        		
	        		this.commonDao.select("LGVATTCOMM.processCalculateOT",tempData);
	        		
	        		item.set("weekday", tempData.get("ot150"));
	        		item.set("weekdayHoliday", tempData.get("ot200"));
	        		item.set("publicHoliday", tempData.get("ot300"));
	        		item.set("atNightWeekday", tempData.get("nt200"));
	        		item.set("atNightWeekdayAfterOT", tempData.get("nt210"));
	        		item.set("atNightWeekdayHoliday", tempData.get("nt270"));
	        		item.set("atNightPublicHoliday", tempData.get("nt390"));
	        		item.set("nightNormal", tempData.get("nt30"));
	        	}
				
				this.commonDao.insert("LGVATT20060.insertNewResult", item);
	        }
        	
	        /* 공통 결재마스터 테이블 등록 */
	        this.commonDao.select("LGVATTCOMM.insertApprovalMaster", approvalMasterData);
            
			if( !"OK".equals( approvalMasterData.getString("retCode") ) ) {
				throw new LGCOMException( approvalMasterData.getString("errorMessage") );
			}
	        
	        /* 공통 결재상태 테이블에 결재자 등록 */
			List<LGCOMData> approvalList = (List<LGCOMData>)param.get("approval");
	        LOGGER.debug("approvalList=>" + approvalList);
	        for( LGCOMData item : LGCOMUtils.emptyIfNull(approvalList) ) {
	            /* 사용자 세션정보 셋팅 */
	            item.put("sessionAppUserId",userSession.get("applicationUserId"));
	            
	            item.put("approvalActionCode", "APPROVAL");
	            item.put("requestMasterId", approvalMasterData.get("requestMasterId"));
	            item.put("requestCode", approvalMasterData.get("requestCode"));
	            item.put("ouId",approvalMasterData.get("ouId"));
	            this.commonDao.select("LGVATTCOMM.insertApprovalLine",item);
	            
				if( !"OK".equals( item.getString("retCode") ) ) {
					throw new LGCOMException( item.getString("errorMessage") );
				}
	        }
	        
	        //결재요청
        	approvalMasterData.set("approvalCommand", "REQUEST");
        	approvalMasterData.set("sessionAppUserId",userSession.get("applicationUserId"));
        	
        	this.commonDao.select("LGVATTCOMM.insertApprovalRequest", approvalMasterData);
        	
			if( !"OK".equals( approvalMasterData.getString("retCode") ) ) {
				throw new LGCOMException( approvalMasterData.getString("errorMessage") );
			}
			
			LGCOMData leaveChkParam = new LGCOMData();
			leaveChkParam.set("sessionAppUserId", userSession.get("applicationUserId"));
			leaveChkParam.set("attType", "UPD_REQ");
			leaveChkParam.set("subsidiaryCode", projectSession.getString("subsidiaryCode"));
			leaveChkParam.set("languageCode",userSession.getString("languageCode"));
			leaveChkParam.set("requestNo",approvalMasterData.get("requestNo"));
			leaveChkParam.set("attendanceYyyymmdd","");
			leaveChkParam.set("empCat","LGD_LW");
			leaveChkParam.set( "newInputResultAttCode", "");
			leaveChkParam.set( "newInputPlanAttCode", "");
			
			this.commonDao.select("LGVATTCOMM.retrieveValidateAnualLeave", leaveChkParam);
	        	
			if(leaveChkParam.getInt("retCode") < 0) {
        		throw new LGCOMException( messageSourceAccessor.getMessage(leaveChkParam.getString("errorMessage")) );
        	}
			
        }
	}
    
    /**
	 * Desc : 
	 * @Method Name : retrieveLWResultApprovalList
	 * @param  param
	 * @return List<LGCOMData>
	 * @throws Exception
	 */
    @Override
    public List<LGCOMData> retrieveLWResultApprovalList(LGCOMData param) {
    	LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVATT20060.retrieveLWResultApprovalList",param);
    }
    
    /**
	 * Desc : 
	 * @Method Name : saveRequestApprovalOrReject
	 * @param  param
	 * @return void
	 * @throws Exception
	 */
    @Override
    @Transactional(propagation=Propagation.REQUIRED)
    public void saveRequestApprovalOrReject(LGCOMData param) {
    	LOGGER.debug("param = " + param);
    	
    	String systemCode = LGCOMUtils.getValueFromProjectProperties("systemCodeU");
        String projectSessionName = systemCode+"_PROJECT_SESSION";//프로젝트 세션명
        LGCOMData userSession = (LGCOMData)param.get(LGCOMConstants.HTTP_SESSION_KEY);
        LGCOMData projectSession = (LGCOMData)param.get(projectSessionName);
        
        param.set( projectSessionName, projectSession );
        
        /* 요청코드, 시스템코드, 모듈코드, 요청번호, 요청제목등 조회 */
        LGCOMData approvalData = this.commonDao.select("LGVATTCOMM.retreiveRequestBasicInfo", param);
        
        param.set("sessionAppUserId", userSession.get("applicationUserId"));
        param.set("portalFlag", approvalData.get("portalFlag"));
        param.set("mailFlag", approvalData.get("mailFlag"));
        
    	this.commonDao.select("LGVATTCOMM.insertApprovalRequest", param);
    	
    	if( !"OK".equals(  param.getString("retCode") ) ) {
			throw new LGCOMException(  param.getString("errorMessage") );
		}
		
		LGCOMData isApproved = this.commonDao.select("LGVATTCOMM.retrieveApprovalStatus", param);
		
    	if( "Y".equals(isApproved.get("approvedFlag")) ) {
    		this.commonDao.select("LGVATTCOMM.applyAttModifyRequest", param);
    	} else {
    		if( "APPROVAL".equals(param.getString("approvalCommand")) ) {
    			param.set("approvalCommand", "INPROGRESS");
    		}
    	}
    	
    	this.commonDao.update("LGVATT20060.updateRequestProgress", param);
        
        LGCOMData leaveChkParam = new LGCOMData();
		leaveChkParam.set("sessionAppUserId", userSession.get("applicationUserId"));
		leaveChkParam.set("attType", "UPD_APPR");
		leaveChkParam.set("subsidiaryCode", projectSession.getString("subsidiaryCode"));
		leaveChkParam.set("languageCode",userSession.getString("languageCode"));
		leaveChkParam.set("requestNo",approvalData.get("requestNo"));
		leaveChkParam.set("attendanceYyyymmdd","");
		leaveChkParam.set("empCat","LGD_LW");
		leaveChkParam.set( "newInputResultAttCode", "");
		leaveChkParam.set( "newInputPlanAttCode", "");
		
		this.commonDao.select("LGVATTCOMM.retrieveValidateAnualLeave", leaveChkParam);
        	
		if(leaveChkParam.getInt("retCode") < 0) {
    		throw new LGCOMException( messageSourceAccessor.getMessage(leaveChkParam.getString("errorMessage")) );
    	}
    }
    
    /**
	 * Desc : 
	 * @Method Name : isEnableAttendSubmit
	 * @param  param
	 * @return LGCOMData
	 * @throws Exception
	 */
	@Override
	public LGCOMData isEnableSubmitOrApproval(LGCOMData param) {
		LOGGER.debug("param = " + param);
		
		String systemCode = LGCOMUtils.getValueFromProjectProperties("systemCodeU");
        String projectSessionName = systemCode+"_PROJECT_SESSION";//프로젝트 세션명
        LGCOMData projectSession = (LGCOMData)param.get(projectSessionName);
        
        param.set( projectSessionName, projectSession );
		
		return this.commonDao.select("LGVATT20060.isEnableSubmitOrApproval",param);
	}
	
	/**
	 * Desc : 
	 * @Method Name : isEnableAttendSubmit
	 * @param  param
	 * @return LGCOMData
	 * @throws Exception
	 */
	@Override
	public LGCOMData isEnableModify(LGCOMData param) {
		LOGGER.debug("param = " + param);
		
		String systemCode = LGCOMUtils.getValueFromProjectProperties("systemCodeU");
        String projectSessionName = systemCode+"_PROJECT_SESSION";//프로젝트 세션명
        LGCOMData projectSession = (LGCOMData)param.get(projectSessionName);
        
        param.set( projectSessionName, projectSession );
		
		return this.commonDao.select("LGVATT20060.isEnableModify",param);
	}
	
	/**
	 * Desc : 
	 * @Method Name : saveSelfReject
	 * @param  param
	 * @return void
	 * @throws Exception
	 */
	@Override
	public void saveSelfReject(LGCOMData param) {
		LOGGER.debug("param = " + param);
    	
    	String systemCode = LGCOMUtils.getValueFromProjectProperties("systemCodeU");
        String projectSessionName = systemCode+"_PROJECT_SESSION";//프로젝트 세션명
        LGCOMData userSession = (LGCOMData)param.get(LGCOMConstants.HTTP_SESSION_KEY);
        LGCOMData projectSession = (LGCOMData)param.get(projectSessionName);
        
        param.set( projectSessionName, projectSession );
        
        /* 요청코드, 시스템코드, 모듈코드, 요청번호, 요청제목등 조회 */
        LGCOMData approvalData = this.commonDao.select("LGVATTCOMM.retreiveRequestBasicInfo", param);
        
        param.set("sessionAppUserId", userSession.get("applicationUserId"));
        param.set("portalFlag", approvalData.get("portalFlag"));
        param.set("mailFlag", approvalData.get("mailFlag"));
        
    	this.commonDao.select("LGVATTCOMM.insertApprovalRequest", param);
    	
    	this.commonDao.update("LGVATT20060.updateRequestProgress", param);
	}
}
