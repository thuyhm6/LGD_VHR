package com.lgd.lgvhr.lgvatt.lgvatt20030.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.beans.factory.annotation.Autowired;
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
import com.lgd.lgvhr.lgvatt.lgvatt20030.service.LGVATT20030Service;

import devonframe.util.NullUtil;

/**
 * @author HMS
 * OT Level New&Detail
 *
 */
@Service("LGVATT20030Service")
public class LGVATT20030ServiceImpl implements LGVATT20030Service{

static final LGCOMLogger logger = LGCOMLoggerFactory.getLogger(LGVATT20030ServiceImpl.class);
	
	LGCOMData result = null;
	
	@Autowired
	private CommonDao commonDao;
	
	@Resource(name="messageSourceAccessor")
    protected MessageSourceAccessor messageSourceAccessor;
	
	@Override
	public List<LGCOMData> retrieveAttContractOrg(LGCOMData param) throws LGCOMException {
		
		logger.debug("retrieveAttContract Parameter: {} ", param);	
		
		return this.commonDao.selectList("LGVATT20030.retrieveAttContractOrg", param);
	}

	@Override
	public List<LGCOMData> retrieveAttContractOrgLineWorkerList(LGCOMData param) throws LGCOMException {
		logger.debug("retrieveAttContractOrgLineWorkerList Parameter: {} ", param);		
		
		param.set("sessionUserId", ((LGCOMData)param.get("LGVHR_PROJECT_SESSION")).getString("employeeNo"));		
		
		
		return this.commonDao.selectList("LGVATT20030.retrieveAttContractOrgLineWorkerList", param);
	}

	@Override
	public LGCOMData retrieveOtLevelInfo(LGCOMData param) throws LGCOMException {
		logger.debug("retrieveAttContractOrgLineWorkerList Parameter: {} ", param);
		
		result = new LGCOMData();
		
		LGCOMData resultData = this.commonDao.select("LGVATT20030.retrieveOtLevelInfo", param);
		
		result.set("levelData", resultData);
		
		return result;
	}

	@Override
	public void saveOtLevelRequest(LGCOMData param) throws LGCOMException {
		logger.debug("saveOtLevelRequest Parameter {} ", param);
		
		List<LGCOMData> insertData = param.getList(LGCOMConstants.STATUS_INSERT);
		List<LGCOMData> updateData = param.getList(LGCOMConstants.STATUS_UPDATE);
		List<LGCOMData> deleteData = param.getList(LGCOMConstants.STATUS_DELETE);
		
		LGCOMData requestParameter = (LGCOMData)param.get("parameter");
		
		if(insertData != null && !insertData.isEmpty()){
			// 추가된 데이터를 insert 한다.
			for(LGCOMData iData : insertData){
				iData.set("sessionUserId", ((LGCOMData)param.get("LGVHR_PROJECT_SESSION")).getString("applicationUserId"));
				iData.set("subsidiaryCode", ((LGCOMData)param.get("LGVHR_PROJECT_SESSION")).getString("subsidiaryCode"));
				iData.set("approvalRequestId",((LGCOMData)requestParameter.get("requestorData")).getString("requestMasterId"));				
				iData.set("requestCode", ((LGCOMData)requestParameter.get("requestorData")).getString("requestCode"));
				
				
				commonDao.update("LGVATT20030.saveOtLevelRequest", iData);
			}
		}
		
		if(updateData != null && !updateData.isEmpty()){
			// 추가된 데이터를 insert 한다.
			for(LGCOMData uData : updateData){
				uData.set("sessionUserId", ((LGCOMData)param.get("LGVHR_PROJECT_SESSION")).getString("applicationUserId"));
				uData.set("subsidiaryCode", ((LGCOMData)param.get("LGVHR_PROJECT_SESSION")).getString("subsidiaryCode"));
				uData.set("approvalRequestId",((LGCOMData)requestParameter.get("requestorData")).getString("requestMasterId"));				
				uData.set("requestCode", ((LGCOMData)requestParameter.get("requestorData")).getString("requestCode"));		
				commonDao.update("LGVATT20030.saveOtLevelRequest", uData);
			}
		}
		
		if(deleteData != null && !deleteData.isEmpty()){
			// 추가된 데이터를 insert 한다.
			for(LGCOMData dData : deleteData){
				dData.set("sessionUserId", ((LGCOMData)param.get("LGVHR_PROJECT_SESSION")).getString("employeeNo"));
				dData.set("subsidiaryCode", ((LGCOMData)param.get("LGVHR_PROJECT_SESSION")).getString("subsidiaryCode"));
				dData.set("requestCode", param.getString("requestDocCode"));
				
				commonDao.update("LGVATT20030.deleteOtLevelRequest", dData);
			}
		}
		
		
	}

	@Override
	public List<LGCOMData> retrieveOtLevelRequest(LGCOMData param) throws LGCOMException {
		logger.debug("retrieveOtLevelRequest : {} ", param);
		param.set("sessionUserId", ((LGCOMData)param.get(LGCOMConstants.HTTP_SESSION_KEY)).getString("applicationUserId"));
		param.set("subsidiaryCode", ((LGCOMData)param.get("LGVHR_PROJECT_SESSION")).getString("subsidiaryCode"));
		
		
		
		return commonDao.selectList("LGVATT20030.retrieveOtLevelRequest", param);
	}
	
	

	@Override
	public LGCOMData retrieveInitData(LGCOMData param) throws LGCOMException {
		
		
		LGCOMData result = new LGCOMData();
		//요청서구분코드로 요청구분코드 조회
		LGCOMData reqDocBaseInfo = retrieveRequestDocBaseInfo(param);
		if ( !NullUtil.isNull(reqDocBaseInfo) ) {
			param.set( "requestCode", reqDocBaseInfo.get("requestCode"));
		}
		result.set( "reqDocBaseInfo", reqDocBaseInfo );
		result.set( "approvalMasterData", this.commonDao.select("LGVATTCOMM.retreiveRequestBasicInfo", param) );
		
		return result;
	}

	public LGCOMData retrieveRequestDocBaseInfo(LGCOMData param) {
		return this.commonDao.select("LGVATT20030.retrieveRequestDocBaseInfo", param);
	}

	@Override
	public LGCOMData retrieveHeaderInfo(LGCOMData param) throws LGCOMException {
		LGCOMData result = new LGCOMData();
		param.set("sessionUserId", ((LGCOMData)param.get("LGVHR_PROJECT_SESSION")).getString("employeeNo"));
		param.set("subsidiaryCode", ((LGCOMData)param.get("LGVHR_PROJECT_SESSION")).getString("subsidiaryCode"));
		LGCOMData reqDocBaseInfo = retrieveRequestDocBaseInfo(param);
		result.set( "reqDocBaseInfo", reqDocBaseInfo );
		result.set( "reqHeaderBaseInfo", commonDao.select("LGVATT20030.retrieveRequestHeaderInfo", param) );
		return result;
		
	}

	@Override
	@Transactional(propagation=Propagation.REQUIRED)
	public void saveApprovalRequest(LGCOMData param) throws LGCOMException {
		/*
		 * 통합 결재 태운다.
		 */
		
		logger.debug("saveApprovalRequest = " + param);
    	String systemCode = LGCOMUtils.getValueFromProjectProperties("systemCodeU");
        String projectSessionName = systemCode+"_PROJECT_SESSION";//프로젝트 세션명
        LGCOMData userSession = (LGCOMData)param.get(LGCOMConstants.HTTP_SESSION_KEY);
        LGCOMData projectSession = (LGCOMData)param.get(projectSessionName);
        
        
        // 결재요청아이디 시퀀스 조회
        LGCOMData requestMasterIdData = this.commonDao.select("LGVATTCOMM.retrieveRequestMasterId");
        
        requestMasterIdData.set( LGCOMConstants.HTTP_SESSION_KEY, userSession );//요청정보 조회하면서 세션정보 일부 셋팅함.
        requestMasterIdData.set( projectSessionName, projectSession );
        requestMasterIdData.set( "approvalMenuId", "M_LGVATT_1069" );
        requestMasterIdData.set( "systemCode", systemCode );
        requestMasterIdData.set("requestorId", userSession.get("applicationUserId"));
        
        
        
        /* 요청코드, 시스템코드, 모듈코드, 요청번호, 요청제목등 조회 */
        LGCOMData approvalMasterData = new LGCOMData();
        approvalMasterData = this.commonDao.select("LGVATTCOMM.retreiveRequestBasicInfo", requestMasterIdData);
        
        // 요청 마스터 데이터가 없으면 처리 하지 않음
        if(approvalMasterData != null && !approvalMasterData.isEmpty()){
        	
        	saveRequestOtLevelRequest(approvalMasterData, param);
        	
        	/* 공통 결재마스터 테이블 등록 */
	        this.commonDao.select("LGVATTCOMM.insertApprovalMaster", approvalMasterData);
            
			if( !"OK".equals( approvalMasterData.getString("retCode") ) ) {
				throw new LGCOMException( approvalMasterData.getString("errorMessage") );
			}
        	// 결재테이블 처리
        	List<LGCOMData> approvalList =((LGCOMData)param.get("parameter")).getList("approvalData");
        	logger.debug("approvalList : {}", approvalList);
        	
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
			
        }		
	}
	// 결재시 그리드 정보 넣는다.
	private void saveRequestOtLevelRequest(LGCOMData approvalMasterData, LGCOMData param) {
		logger.debug("saveOtLevelRequest param {} ", param);
		logger.debug("saveOtLevelRequest approvalMasterData {} ", approvalMasterData);
		
		List<LGCOMData> insertData = param.getList(LGCOMConstants.STATUS_INSERT);
		List<LGCOMData> updateData = param.getList(LGCOMConstants.STATUS_UPDATE);
		List<LGCOMData> deleteData = param.getList(LGCOMConstants.STATUS_DELETE);	
		
		
		if(insertData != null && !insertData.isEmpty()){
			// 신규 데이터를 insert 한다.
			for(LGCOMData iData : insertData){
				iData.set("sessionUserId", ((LGCOMData)param.get("USER_SESSION")).getString("applicationUserId"));
				iData.set("subsidiaryCode", ((LGCOMData)param.get("LGVHR_PROJECT_SESSION")).getString("subsidiaryCode"));				
				iData.set("approvalRequestId", approvalMasterData.get("requestMasterId"));
				iData.set("requestCode", approvalMasterData.get("requestCode"));
				iData.set("requestNo", approvalMasterData.get("requestNo"));			
				
				commonDao.update("LGVATT20030.saveOtLevelRequest", iData);
			}
		}
		
		if(updateData != null && !updateData.isEmpty()){
			// 추가된 데이터를 insert 한다.
			for(LGCOMData uData : updateData){
				uData.set("sessionUserId", ((LGCOMData)param.get("USER_SESSION")).getString("applicationUserId"));
				uData.set("subsidiaryCode", ((LGCOMData)param.get("LGVHR_PROJECT_SESSION")).getString("subsidiaryCode"));
				uData.set("statusCode", ((LGCOMData)param.get("parameter")).getString("statusCode"));
				uData.set("approvalRequestId", approvalMasterData.get("requestMasterId"));				
				uData.set("requestCode", approvalMasterData.get("requestCode"));
				uData.set("requestNo", approvalMasterData.get("requestNo"));			
				commonDao.update("LGVATT20030.saveOtLevelRequest", uData);
			}
		}
		
		
	}

	@Override
	@Transactional(propagation=Propagation.REQUIRED)
	public void saveRequestApprovalOrReject(LGCOMData param) throws LGCOMException {
        LGCOMData userSession = (LGCOMData)param.get(LGCOMConstants.HTTP_SESSION_KEY);
        LGCOMData projectSession = (LGCOMData)param.get("LGVHR_PROJECT_SESSION");
        
        param.set("sessionUserId", ((LGCOMData)param.get(LGCOMConstants.HTTP_SESSION_KEY)).getString("applicationUserId"));
        
      //요청서 아이디 또는 요청서 코드 또는 결재/반려 구분코드가 없는 경우 오류 리턴
        if ( NullUtil.isNone(param.getString("requestMasterId")) || NullUtil.isNone(param.getString("requestCode")) 
        		|| NullUtil.isNone(param.getString("approvalCommand"))
        		|| (!"APPROVAL".equals(param.getString("approvalCommand")) && !"REJECT".equals(param.getString("approvalCommand"))) ) {
        	throw new LGCOMException(messageSourceAccessor.getMessage("error.CheckRequestNo."));//승인요청번호를 확인하세요.
        }
        
        LGCOMData reqDocBaseInfo = retrieveRequestDocBaseInfo(param);
        
        if ( NullUtil.isNull(reqDocBaseInfo) 
				|| NullUtil.isNull(param.getString("requestCode"))
				|| (NullUtil.notNone(reqDocBaseInfo.getString("requestCode")) && !param.getString("requestCode").equals(reqDocBaseInfo.getString("requestCode"))) ) {
        	logger.error("requestCode is different!!!!(PARAM:"+NullUtil.nvl(param.getString("requestCode"), "")+", ORI:"+NullUtil.nvl(reqDocBaseInfo.getString("requestCode"), "")+")");
        	//해당 작업을 위한 권한이 없습니다.
	        throw new LGCOMException(messageSourceAccessor.getMessage("note.NoPermission"));
        	
        }else{
        	//결재자인지, 결재가능한 상태인지 체크
	        String errorMsg = retrieveValidateApproval(param);
	        if ( NullUtil.notNone(errorMsg) ) {
	        	throw new LGCOMException(errorMsg);
	        }
	        
	        /* 파라메터:requestCode, 통합결재연동여부(portal_flag)와 메일발송여부(mail_flag) 조회하기 위함 */
	        LGCOMData approvalMasterData = this.commonDao.select("LGVATTCOMM.retreiveRequestBasicInfo", param);
	
	        param.set("portalFlag", approvalMasterData.get("portalFlag"));
	        param.set("mailFlag", approvalMasterData.get("mailFlag"));
	    	param.set("sessionAppUserId", userSession.get("applicationUserId"));
	    	//공통 결재 프로시저 호출
	    	this.commonDao.select("LGVATTCOMM.insertApprovalRequest", param);
			if( !"OK".equals( param.getString("retCode") ) ) {
				throw new LGCOMException( param.getString("errorMessage") );
			}
			param.set("approvalRequestId", param.getString("requestMasterId"));
			this.commonDao.update("LGVATT20030.updateOtLevelRequest", param);
        }
	}
	
	
	/**
	 * 결재 상태 체크
	 * @param param
	 * @return
	 */
	private String retrieveValidateApproval(LGCOMData param) {
		
		logger.debug("retrieveValidateApproval param {} ", param);
		/* 결재 상태 조회
         * [PARAMETER]
         * - requestMasterId    : 요청서아이디. 요청서아이디 + 요청서코드 : unique
         * - requestCode        : 요청서코드.
         * - approverEmployeeNo : 결재자 사번. 특정 결재자에 대해 체크하는 경우 값 입력.
         *                        값이 없는 경우 세션 사번(LGVHR_PROJECT_SESSION.employeeNo)으로 체크
         */
		
		LGCOMData resultData = this.commonDao.select("LGVATTCOMM.retrieveApprovalStatus", param);
        
        if ( !NullUtil.isNull(resultData) ) {
        	if ( !"Y".equals(resultData.get("approverFlag")) ) {
        		return messageSourceAccessor.getMessage("note.att.noApprover");//결재자가 아닙니다.
        		
        	} else if ( !"Y".equals(resultData.get("approvalEnableFlag")) ) {
        		return messageSourceAccessor.getMessage("note.att.notInProgressStatus");//결재가능한 상태가 아닙니다. 결재문서의 진행상태를 확인해주세요.
        		
        	}
        }
		
		return null;
	}

	@Override
	public LGCOMData retrieveEmployeeName(LGCOMData param) throws LGCOMException {
		// TODO Auto-generated method stub
		return commonDao.select("LGVATT20030.retrieveEmployeeName", param);
	}

	@Override
	public LGCOMData retrieveApprovalStatus(LGCOMData param) throws LGCOMException {
		// TODO Auto-generated method stub
		return this.commonDao.select("LGVATTCOMM.retrieveApprovalStatus", param);
	}

	@Override
	public List<LGCOMData> retrieveEmployeeNo(LGCOMData param) throws LGCOMException {
		// TODO Auto-generated method stub
		return commonDao.selectList("LGVATT20030.retrieveEmployeeNo", param);
	}

	@Override
	public LGCOMData retrieveDupData(LGCOMData param) throws LGCOMException {
		// TODO Auto-generated method stub
		return this.commonDao.select("LGVATT20030.retrieveDupData", param);
	}
	
}
