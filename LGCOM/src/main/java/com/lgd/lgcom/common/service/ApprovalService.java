/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : RegionService.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 5. 25.    csseo    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.common.service;

import java.util.List;
import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.common.service.ApprovalService.java
 * </PRE>
 *
 * @Author    soncs
 * @Date      2016. 8. 19. 오전 8:55:01
 * @Version
 */
public interface ApprovalService {
	/**
	 * Desc : approval.jsp 에서 요청 정보 전체를 조회한다.
	 * @Method Name : retrieveRequestInfoList
	 * @param  param
	 * @return LGCOMData
	 */
	public LGCOMData retrieveRequestInfoList(LGCOMData param);

	/**
	 * Desc : 요청마스터ID와 요청코드로 첨부파일 목록을 조회한다.
	 * @Method Name : retrieveAttachmentList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveAttachmentList(LGCOMData param);

	/**
	 * Desc : 요청마스터ID와 요청코드로 저장된 결재선 목록을 조회한다.
	 * @Method Name : retrieveApprovalLineList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveApprovalLineList(LGCOMData param);

	/**
	 * Desc : 요청마스터ID와 요청코드로 참조 목록을 조회한다.
	 * @Method Name : retrieveCarbonCopyList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveCarbonCopyList(LGCOMData param);

	/**
	 * Desc : 요청마스터ID와 요청코드로 검토 목록을 조회한다.
	 * @Method Name : retrieveInspectionList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveInspectionList(LGCOMData param);

	/**
	 * Desc : 요청마스터ID와 요청코드로 전달 목록을 조회한다.
	 * @Method Name : retrieveForwarderList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveForwarderList(LGCOMData param);

	/**
	 * Desc : 요청마스터ID와 요청코드로 검토 목록을 조회한다.
	 * @Method Name : retrieveReviewerList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveReviewerList(LGCOMData param);


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
	public LGCOMData retrieveRequestHeadInfo(LGCOMData param);

	/**
	 * Desc : 선택된 결재권자의 위임정보를 조회한다.
	 * @Method Name : retrievePortalMandatorInfo
	 * @param  param - LGCOMData
	 * @return LGCOMData
	 */
	public LGCOMData retrievePortalMandatorInfo(LGCOMData param);
	/**************************************************/
	/* 요청서 객체 생성                               */
	/* 2017.04.08. forain 추가                        */
	/**************************************************/
}
