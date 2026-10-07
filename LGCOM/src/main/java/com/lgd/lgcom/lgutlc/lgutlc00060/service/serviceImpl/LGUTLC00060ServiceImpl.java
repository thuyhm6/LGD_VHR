/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGUTLC00060ServiceImpl.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 6. 9.    csseo    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgutlc.lgutlc00060.service.serviceImpl;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.List;

import javax.annotation.Resource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.service.BoardService;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.exception.LGCOMException;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgcom.lgutlc.lgutlc00060.service.LGUTLC00060Service;

/**
 * <PRE>
 * com.lgd.lgcom.lgutlc.lgutlc00050.service.serviceImpl.LGUTLC00050ServiceImpl.java
 * </PRE>
 *
 * @Author    csseo
 * @Date      2016. 6. 9. 오후 1:39:58
 * @Version
 */
@Service("LGUTLC00060Service")
public class LGUTLC00060ServiceImpl implements LGUTLC00060Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGUTLC00060ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

	@Autowired
	BoardService boardService;

	/**
	 * Desc : 게시판 아이디를 받아서 게시판 목록을 조회한다.
	 * @Method Name : retrieveBoardList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveBoardList(LGCOMData param) {
	    LOGGER.debug("param = " + param);
		List<LGCOMData> list = this.commonDao.selectList("LGUTLC00040.retrieveBoardList",param);
		for( LGCOMData item : LGCOMUtils.emptyIfNull( list ) ) {
			/* 제목 XSS 적용 */
			String boardTitle = item.getString("bulletinBoardTitle");
			// Executable Img 처리
			boardTitle = LGCOMUtils.removeExecutableImgTag(boardTitle);
			// XSS 처리
			boardTitle = LGCOMUtils.xssFilter(boardTitle);
			item.set("bulletinBoardTitle",boardTitle);
		}
		return list;
	}

	/**
	 * Desc : 게시판 쓰기 페이지로 이동하기 위한 Dummy Service
	 * @Method Name : retrieveBoardWriteForm
	 * @param  param
	 */
	public void retrieveBoardWriteForm(LGCOMData param) {
		LOGGER.debug("param = " + param);
	}

	/**
	 * Desc : 게시판 정보를 저장한다.
	 * @Method Name : saveBoardData
	 * @param  param
	 * @throws IOException
	 * @throws SQLException
	 */
	@SuppressWarnings({ "unchecked", "rawtypes" })
	public void saveBoardData(LGCOMData param) throws SQLException, IOException {
		/* 신규 및 답글 여부 */
		boolean isCreated = false;
		/* 사용자 세션을 얻는다. */
		LGCOMData userSession = (LGCOMData)param.get("USER_SESSION");
		/* Editor의 내용을 Base64로 인코딩해서 오므로 다시 디코딩한다. */
		param.set("bbBodyContent",LGCOMUtils.decodeReplaceString(param.getString("bbBodyContent")));
		
		LOGGER.debug("param = " + param);
		/* 부모ID가 있으면서 보드ID가 없고, Board Level 이 1이상이면 */
		if(!"0".equals(param.get("bulletinBoardParentId").toString().trim()) && "".equals(param.get("bulletinBoardNo").toString().trim())) {
			// 부모의 답글 개수 Update
			param.set("replyFlag","plus");
			this.commonDao.update("Board.updateBoardReplyCount", param);
		}
		if(!param.containsKey("bulletinBoardNo") || "".equals(param.get("bulletinBoardNo").toString().trim())) {
			isCreated = true;
		}
		/* 수정건이면 */
		if(!isCreated) {
			// 게시글 상세내역을 조회한다.
			LGCOMData detail = boardService.retrieveBoardDetail(param);
			// 작성자가 아니면 수정 불가
			if(detail.getDouble("writerId") != userSession.getDouble("applicationUserId")) {
				throw new LGCOMException("error.invalidAutho");
			}
		}
		/* 게시판 내용을 저장한다. */
		if(isCreated) {
			LGCOMData boardNoData = this.commonDao.select("Board.retrieveNextBulletinBoardNo");
			LOGGER.debug("boardNoData = " + boardNoData);
			param.set("bulletinBoardNo", boardNoData.getString("nextBulletinBoardNo"));
			LOGGER.debug("param = " + param);
			this.commonDao.update("LGUTLC00040.insertBoardData", param);
		} else {
			LOGGER.debug("param = " + param);
			this.commonDao.update("LGUTLC00040.updateBoardData", param);
		}
		/* 첨부파일 정보가 있다면 첨부파일 정보를 생성한다. */
		long attachFile1Id = -1;
		long attachFile2Id = -1;
		long attachFile3Id = -1;
		if(param.containsKey("attachFile1") && param.get("attachFile1") != null) {
			LGCOMData attach1 = (LGCOMData)param.get("attachFile1");
			if(!attach1.containsKey("fileSeqNo")) {
				LGCOMData seqNo1Data = this.commonDao.select("Board.retrieveNextBoardAttachFileSeqNo");
				// 파일번호 세팅
				attach1.put("fileSeqNo",seqNo1Data.getLong("nextFileSeqNo"));
				attachFile1Id = seqNo1Data.getLong("nextFileSeqNo");
			} else {
				attachFile1Id = new BigDecimal(attach1.get("fileSeqNo")+"").intValue();
			}
			// 게시번호 세팅
			attach1.put("bulletinBoardNo",param.get("bulletinBoardNo"));
			// 등록자 세팅
			attach1.put("creationUserId",userSession.getString("applicationUserId"));
			LOGGER.debug("attach1 = " + attach1);
			this.commonDao.update("Board.saveBoardAttachFile",attach1);
		}
		if(param.containsKey("attachFile2") && param.get("attachFile2") != null) {
			LGCOMData attach2 = (LGCOMData)param.get("attachFile2");
			if(!attach2.containsKey("fileSeqNo")) {
				// 파일번호 세팅
				LGCOMData seqNo2Data = this.commonDao.select("Board.retrieveNextBoardAttachFileSeqNo");
				attach2.put("fileSeqNo",seqNo2Data.getLong("nextFileSeqNo"));
				attachFile2Id = seqNo2Data.getLong("nextFileSeqNo");
			} else {
				attachFile2Id = new BigDecimal(attach2.get("fileSeqNo")+"").intValue();
			}
			// 게시번호 세팅
			attach2.put("bulletinBoardNo",param.get("bulletinBoardNo"));
			// 등록자 세팅
			attach2.put("creationUserId",userSession.getString("applicationUserId"));
			LOGGER.debug("attach2 = " + attach2);
			this.commonDao.update("Board.saveBoardAttachFile",attach2);
		}
		if(param.containsKey("attachFile3") && param.get("attachFile3") != null) {
			LGCOMData attach3 = (LGCOMData)param.get("attachFile3");
			if(!attach3.containsKey("fileSeqNo")) {
				// 파일번호 세팅
				LGCOMData seqNo2Data = this.commonDao.select("Board.retrieveNextBoardAttachFileSeqNo");
				attach3.put("fileSeqNo",seqNo2Data.getLong("nextFileSeqNo"));
				attachFile3Id = seqNo2Data.getLong("nextFileSeqNo");
			} else {
				attachFile3Id = new BigDecimal(attach3.get("fileSeqNo")+"").intValue();
			}
			// 게시번호 세팅
			attach3.put("bulletinBoardNo",param.get("bulletinBoardNo"));
			// 등록자 세팅
			attach3.put("creationUserId",userSession.getString("applicationUserId"));
			LOGGER.debug("attach3 = " + attach3);
			this.commonDao.update("Board.saveBoardAttachFile",attach3);
		}
		/* 첨부파일이 있다면 게시판에 첨부ID를 변경한다. */
		if(attachFile1Id != -1 || attachFile2Id != -1 || attachFile3Id != -1) {
			param.set("attachFile1Id",attachFile1Id);
			param.set("attachFile2Id",attachFile2Id);
			param.set("attachFile3Id",attachFile3Id);
			this.commonDao.update("Board.updateBoardAttachData",param);
		}
	}

	/**
	 * Desc : 게시판 정보를 삭제한다.
	 * @Method Name : deleteBoardData
	 * @param  param
	 * @return LGCOMData
	 */
	public LGCOMData deleteBoardData(LGCOMData param) throws SQLException, IOException {
		if(!"N".equals(param.getString("forceDelete"))) {
			throw new LGCOMException("error.invalidAutho");
		}
		param.set("forceDelete","N");
		return this.boardService.deleteBoardData(param);
	}

	/**
	 * Desc : 게시판 Super User에 의해 작성자가 아님에도 무조건 삭제한다.
	 * @Method Name : deletePhysicalBoardData
	 * @param  param
	 * @throws IOException
	 * @throws SQLException
	 */
	public LGCOMData deletePhysicalBoardData(LGCOMData param) throws SQLException, IOException {
		LOGGER.debug("param = " + param);
		param.set("forceDelete","Y");
		return this.boardService.deleteBoardData(param);
	}
}
