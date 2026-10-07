/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGUTLC00140ServiceImpl.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 10. 5.    csseo    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgutlc.lgutlc00140.service.serviceImpl;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.List;

import javax.annotation.Resource;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.util.LGCOMConstants;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgcom.lgutlc.lgutlc00140.service.LGUTLC00140Service;

import devonframe.util.NullUtil;

/**
 * <PRE>
 * com.lgd.lgcom.lgutlc.lgutlc00401.service.serviceImpl.LGUTLC00140ServiceImpl.java
 * </PRE>
 *
 * @Author    forain
 * @Date	   2016. 10. 5. 오후 1:39:20
 * @Version
 */
@Service("LGUTLC00140Service")
public class LGUTLC00140ServiceImpl implements LGUTLC00140Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGUTLC00140ServiceImpl.class);

	/**
	 * Log 파일 경로
	 */
	@Value("concurrent_log_path_#{systemProperties['env'] == null ? 'local' : systemProperties['env']}")
	String logPath = null;

	@Resource(name="commonDao")
	CommonDao commonDao;

	/**
	 * Desc : Concurrent 수행내역 조회
	 * @Method Name : retrieveConcurrentViewerList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveConcurrentViewerList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		/* 세션정보 */
		LGCOMData sessionData =(LGCOMData)param.get(LGCOMConstants.HTTP_SESSION_KEY);
		/* 관리자 권한이 없는 경우 */
		if(!"Y".equals(param.getString("adminFlag"))) {
			/* 요청자 ID 와 로그인 사용자 정보가 상이할 경우 로그인 사용자 정보로 대체 */
		    param.set("requestUserId",sessionData.get("applicationUserId"));
		}
		
		// Concurrent 수행 정보를 조회한다.
		List<LGCOMData> list = this.commonDao.selectList("LGUTLC00140.retrieveConcurrentViewerList",param);
		// 목록이 존재할 경우 각 실행결과의 로그 파일 및 출력 파일 존재여부를 체크한다.
		for(LGCOMData item : LGCOMUtils.emptyIfNull(list) ) {
			String logfileName = item.getString("logfileName");
			String outfileName = item.getString("outfileName");
			File logFile = new File(LGCOMUtils.getValueFromProjectProperties(this.logPath) + "/" + logfileName);
			File outFile = new File(LGCOMUtils.getValueFromProjectProperties(this.logPath) + "/" + outfileName);
			// 로그파일 경로가 null 이거나 로그파일 객체가 null 또는 로그파일 객체가 존재하지 않거나 로그파일 객체가 파일이 아니라면
			if(NullUtil.isNone(logfileName) || logFile == null || !logFile.exists() || !logFile.isFile()) {
				item.set("logfileExist","N");
			} else {
				item.set("logfileExist","Y");
			}
			// 출력파일 경로가 null 이거나 출력파일 객체가 null 또는 출력파일 객체가 존재하지 않거나 출력파일 객체가 파일이 아니라면
			if(NullUtil.isNone(outfileName) || outFile == null || !outFile.exists() || !outFile.isFile()) {
				item.set("outfileExist","N");
			} else {
				item.set("outfileExist","Y");
			}
		}
		return list;
	}

	/**
	 * Desc : Concurrent 수행내역 로그 조회
	 * @Method Name : retrieveConcurrentLogContent
	 * @param  param
	 * @return LGCOMData
	 */
	public LGCOMData retrieveConcurrentLogContent(LGCOMData param) {
		LOGGER.debug("param = " + param);
		// Concurrent 수행 정보를 조회한다.
		LGCOMData result = this.commonDao.select("Common.retrieveConcurrentOutputFileInfo",param);
		result.set("errorCode","");
		result.set("errorMsg","");
		LOGGER.debug("result = " + result);
		// Viewer Mode가 log 일 경우
		if("log".equalsIgnoreCase(param.getString("viewMode"))) {
			// 로그 파일이 존재하지 않으면
			if(NullUtil.isNone(result.getString("logfileName"))) {
				result.set("errorCode","FN");		// File not found.
			} else {
				// 조회된 로그파일을 Access 한다.
				File logFile = new File(LGCOMUtils.getValueFromProjectProperties(this.logPath) + "/" + result.getString("logfileName"));
				// 주어진 로그 파일이 존재하지 않거나 파일이 아니면
				if(!logFile.exists() || !logFile.isFile()) {
					result.set("errorCode","FN");		// File not found.
				} else {
					try {
						result.set("content",this.readFileContent(logFile));
					} catch(IOException ie) {
						result.set("errorCode","E");		// File read error
						result.set("errorMsg",ie.getMessage());
					}
				}
			}
		}
		else if("out".equalsIgnoreCase(param.getString("viewMode"))) {
			// Output 파일이 존재하지 않으면
			if(NullUtil.isNone(result.getString("outfileName"))) {
				result.set("errorCode","FN");		// File not found.
			} else {
				// 조회된 Output 파일을 Access 한다.
				File outFile = new File(LGCOMUtils.getValueFromProjectProperties(this.logPath) + "/" + result.getString("outfileName"));
				// 주어진 Output 파일이 존재하지 않거나 파일이 아니면
				if(!outFile.exists() || !outFile.isFile()) {
					result.set("errorCode","FN");		// File not found.
				} else {
					try {
						result.set("content",this.readFileContent(outFile));
					} catch(IOException ie) {
						result.set("errorCode","E");		// File read error
						result.set("errorMsg",ie.getMessage());
					}
				}
			}
		}
		return result;
	}

	/**
	 * Desc : TEXT 유형의 파일 객체를 받아 파일의 내용을 읽어들인다.
	 * @Method Name : readFileContent
	 * @param  file
	 * @return String
	 * @throws IOException
	 */
	private String readFileContent(File file) throws IOException {
		StringBuffer buffer = new StringBuffer();
		FileInputStream fis = null;
		InputStreamReader isr = null;
		BufferedReader br = null;
		try {
			String outLine = null;
			fis = new FileInputStream(file);
			isr = new InputStreamReader(fis,"UTF-8");
			br = new BufferedReader(isr);
			while((outLine = br.readLine()) != null) {
				buffer.append(outLine).append("\n");
			}
		} finally {
			try { if(br != null)  {br.close(); }; } catch(IOException ie1) {/*exception*/}
			try { if(isr != null) {isr.close();}; } catch(IOException ie2) {/*exception*/}
			try { if(fis != null) {fis.close();}; } catch(IOException ie3) {/*exception*/}
		}
		return buffer.toString();
	}
}
