/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : SampleServiceImpl.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2016. 8. 25.  	jhpark23  	최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.common.service.serviceImpl;

import java.util.List;

import javax.servlet.http.HttpServletRequest;

import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.ehcache.EhCacheCacheManager;
import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.service.ApprovalService;
import com.lgd.lgcom.common.service.UserSessionService;
import com.lgd.lgcom.common.util.CacheUtils;
import com.lgd.lgcom.common.util.LGCOMConstants;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;


/**
 * <PRE>
 * com.lgd.lgcom.common.service.serviceImpl.ApprovalServiceImpl.java
 * </PRE>
 *
 * @Author    jhpark23
 * @Date	   2016. 8. 25. 오전 11:56:51
 * @Version
 */
@Service("approvalService")
public class ApprovalServiceImpl implements ApprovalService {
	private static LGCOMLogger logger = LGCOMLoggerFactory.getLogger(ApprovalServiceImpl.class);
	
	@Autowired
	private CommonDao commonDao;

	@Autowired
	private EhCacheCacheManager cacheManager;

	@Autowired
	private UserSessionService userSessionService;

	/**
	 * Desc : approval.jsp 에서 요청 정보 전체를 조회한다.
	 * @Method Name : retrieveRequestInfoList
	 * @param  param
	 * @return LGCOMData
	 * @see com.lgd.lgcom.common.service.ApprovalService#retrieveRequestInfoList(com.lgd.lgcom.framework.model.LGCOMData)
	 */
	@Override
	public LGCOMData retrieveRequestInfoList(LGCOMData param) {

		LGCOMData result = new LGCOMData();

		List<LGCOMData> requestInfoList  = this.commonDao.selectList("Approval.retrieveRequestInfoList",param);
		if( requestInfoList == null || requestInfoList.size() == 0 ) {
			return null;
		} else {
			//참조 및 전달의 경우, 이 페이지를 열람 하면 읽은 시간을 기록 한다.
			this.commonDao.update("Approval.updateReadDate",param);
		}

		LGCOMData requestInfo = requestInfoList.get(0); 
		
		HttpServletRequest request = LGCOMUtils.getRequest();
		LGCOMData sessionUser = userSessionService.getSession( request );

		if( !requestInfo.getString("organizationId").equals( sessionUser.getString("defaultOrgId") ) ) {
			//위의 RequestInfo 에서 나온 organizationId 를 사용하여, Region 정보를 읽어들인다.
			LGCOMData region = this.commonDao.select("Approval.retrieveRegionAndOrgInfo", requestInfo );
			sessionUser.set( "defaultOrgShortCode", region.getString("defaultOrgShortCode") );
			sessionUser.set( "defaultOrgId", region.getString("defaultOrgId") );
			sessionUser.set( "requestRegionCode", region.getString("requestRegionCode") );
			sessionUser.set( "requestRegionName", region.getString("requestRegionName") );
			sessionUser.set( "defaultOrgName", region.getString("defaultOrgName") );
			sessionUser.set( "serverTimeDifferenceSeqs", region.getString("serverTimeDifferenceSeqs") );

			userSessionService.setSession( request,  sessionUser );
		}

		//Detail 화면 호출을 위한 메뉴정보를 인출한다.
		LGCOMData menuInfo = CacheUtils.getCacheValue(cacheManager, LGCOMConstants.MENU_CACHE, requestInfo.getString("approvalUrlAddr") );
		requestInfo.set("programId", menuInfo.getString("programId"));
		requestInfo.set("menuName", menuInfo.getString("menuName"));
		requestInfo.set("systemCode", menuInfo.getString("systemCode"));
		requestInfo.set("menuId", menuInfo.getString("menuId"));

		List<LGCOMData> approverList    = this.commonDao.selectList("Approval.retrieveApproverList",param);

		//첨부파일 목록은, "비용사전품의서" 의 Conversion 된 이전 데이터들에 한하여, HRM 측 목록으로 열어준다.
		List<LGCOMData> attachmentList = null;
		if( "51002".equals( requestInfo.getString("requestCode") ) && "CONVERSION".equals(  requestInfo.getString("requestCreationCode") ) ){
			attachmentList  = this.commonDao.selectList("Approval.retrieveAttachmentListHRM",param);
		} else {
			attachmentList  = this.commonDao.selectList("Approval.retrieveAttachmentList",param);
		}

		List<LGCOMData> inspectionList  = this.commonDao.selectList("Approval.retrieveInspectionList",param);
		List<LGCOMData> carbonCopyList  = this.commonDao.selectList("Approval.retrieveCarbonCopyList",param);
		List<LGCOMData> forwardList  = this.commonDao.selectList("Approval.retrieveForwardList",param);

		List<LGCOMData> reviewerList  = this.commonDao.selectList("Approval.retrieveReviewerList",param);
		for( LGCOMData item : LGCOMUtils.emptyIfNull(reviewerList) ) {
			if( item.getString("attachmentReqNumber") != null ) {
				param.set("reqNumber",  item.getString("attachmentReqNumber") );
				item.set( "attachFileList", commonDao.selectList("LGSYSC00210.selectAttachmentListByReqNumber",param) );
			}
		}

		result.set( "requestInfo", requestInfo );
		result.set( "attachmentList", attachmentList );
		result.set( "approverList", approverList );
		result.set( "inspectionList", inspectionList );
		result.set( "carbonCopyList", carbonCopyList );
		result.set( "forwardList", forwardList );
		result.set( "reviewerList", reviewerList );

		return result;
	}

	/**
	 * Desc : 요청마스터ID와 요청코드로 첨부파일 목록을 조회한다.
	 * @Method Name : retrieveAttachmentList
	 * @param  param
	 * @return List<LGCOMData>
	 * @see com.lgd.lgcom.common.service.ApprovalService#retrieveAttachmentList(com.lgd.lgcom.framework.model.LGCOMData)
	 */
	@Override
	public List<LGCOMData> retrieveAttachmentList(LGCOMData param) {
		return null;
	}

	/**
	 * Desc : 요청ID와 요청코드로 저장된 결재선 목록을 조회한다.
	 * @Method Name : retrieveApprovalLineList
	 * @param  param
	 * @return List<LGCOMData>
	 * @see com.lgd.lgcom.common.service.ApprovalService#retrieveApprovalLineList(com.lgd.lgcom.framework.model.LGCOMData)
	 */
	@Override
	public List<LGCOMData> retrieveApprovalLineList(LGCOMData param) {
		return this.commonDao.selectList("Approval.retrieveApprovalLineList",param);
	}

	/**
	 * Desc : 요청마스터ID와 요청코드로 참조자 목록을 조회한다.
	 * @Method Name : retrieveCarbonCopyList
	 * @param  param
	 * @return List<LGCOMData>
	 * @see com.lgd.lgcom.common.service.ApprovalService#retrieveCarbonCopyList(com.lgd.lgcom.framework.model.LGCOMData)
	 */
	@Override
	public List<LGCOMData> retrieveCarbonCopyList(LGCOMData param) {
		return this.commonDao.selectList("Approval.retrieveCarbonCopyList",param);
	}

	/**
	 * Desc : 요청마스터ID와 요청코드로 검토자 목록을 조회한다.
	 * @Method Name : retrieveInspectionList
	 * @param  param
	 * @return List<LGCOMData>
	 * @see com.lgd.lgcom.common.service.ApprovalService#retrieveInspectionList(com.lgd.lgcom.framework.model.LGCOMData)
	 */
	@Override
	public List<LGCOMData> retrieveInspectionList(LGCOMData param) {
		return this.commonDao.selectList("Approval.retrieveInspectionList",param);
	}

	/**
	 * Desc : 요청마스터ID와 요청코드로 전달 목록을 조회한다.
	 * @Method Name : retrieveForwarderList
	 * @param  param
	 * @return List<LGCOMData>
	 * @see com.lgd.lgcom.common.service.ApprovalService#retrieveForwarderList(com.lgd.lgcom.framework.model.LGCOMData)
	 */
	@Override
	public List<LGCOMData> retrieveForwarderList(LGCOMData param) {
		return this.commonDao.selectList("Approval.retrieveForwardList",param);
	}

	/**
	 * Desc : 요청마스터ID와 요청코드로 검토 목록을 조회한다.
	 * @Method Name : retrieveReviewerList
	 * @param  param
	 * @return List<LGCOMData>
	 * @see com.lgd.lgcom.common.service.ApprovalService#retrieveReviewerList(com.lgd.lgcom.framework.model.LGCOMData)
	 */
	public List<LGCOMData> retrieveReviewerList(LGCOMData param) {
		return this.commonDao.selectList("Approval.retrieveReviewerList",param);
	}

	/**************************************************/
	/* 요청서 객체 생성                               */
	/* 2017.04.08. forain 추가                        */
	/**************************************************/
	/**
	 * Desc : 요청ID와 요청번호를 받아 저장된 요청자 정보를 조회한다.
	 * @Method Name : retrieveRequestHeadInfo
	 * @param  param - LGCOMData
	 * @return LGCOMData
	 */
	public LGCOMData retrieveRequestHeadInfo(LGCOMData param) {
		logger.debug("[ApprovalServiceImpl] param = " + param);
		if(StringUtils.isNoneEmpty(param.getString("requestMasterId")) && StringUtils.isNoneEmpty(param.getString("requestCode"))) {
		    return this.commonDao.select("Approval.retrieveRequestHeadInfo",param);
		} else {
		    return this.commonDao.select("Approval.retrieveRequestEmptyHeadInfo",param);
		}
	}

	/**
	 * Desc : 선택된 결재권자의 위임정보를 조회한다.
	 * @Method Name : retrievePortalMandatorInfo
	 * @param  param - LGCOMData
	 * @return LGCOMData
	 */
	public LGCOMData retrievePortalMandatorInfo(LGCOMData param) {
		return this.commonDao.select("Approval.retrievePortalMandatorInfo",param);
	}
	/**************************************************/
	/* 요청서 객체 생성                               */
	/* 2017.04.08. forain 추가                        */
	/**************************************************/
}
