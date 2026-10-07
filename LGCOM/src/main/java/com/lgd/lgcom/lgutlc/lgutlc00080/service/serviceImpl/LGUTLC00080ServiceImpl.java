/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGUTLC00080ServiceImpl.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 8.  3.    csseo    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgutlc.lgutlc00080.service.serviceImpl;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;
import javax.xml.bind.DatatypeConverter;

import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVPrinter;
import org.apache.commons.io.FileUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import com.google.gson.Gson;
import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.service.BatchAsyncService;
import com.lgd.lgcom.common.service.BatchService;
import com.lgd.lgcom.common.service.CommonService;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.concurrent.CommonBatchService;
import com.lgd.lgcom.framework.dao.DynamicDao;
import com.lgd.lgcom.framework.exception.LGCOMException;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgcom.lgutlc.lgutlc00080.service.LGUTLC00080Service;
import com.lgd.lgcom.lgutlc.lgutlc00090.service.LGUTLC00090Service;

import devonframe.util.NullUtil;

/**
 * <PRE>
 * com.lgd.lgcom.lgutlc.lgutlc00080.service.serviceImpl.LGUTLC00080ServiceImpl.java
 * </PRE>
 *
 * @Author    csseo
 * @Date      2016. 8. 3. 오전 9:00:58
 * @Version
 */
@Service(value="LGUTLC00080Service")
public class LGUTLC00080ServiceImpl implements LGUTLC00080Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGUTLC00080ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

	@Resource(name="dynamicDao")
	DynamicDao dynamicDao;

	@Value("common_directory_#{systemProperties['env'] == null ? 'local' : systemProperties['env']}")
	String commonDirectory;

	@Autowired
	LGUTLC00090Service service;

	@Autowired
	BatchAsyncService asyncService;

	@Autowired
	CommonService commonService;
	
	@Autowired
    BatchService batchService;
	
	/**
	 * Desc : Dynamic Query 목록을 조회한다.
	 * @Method Name : retrieveDynamicQueryPopList
	 * @param  param
	 * @return List<?>
	 */
	public List<LGCOMData> retrieveDynamicQueryPopList(LGCOMData param) {
	    LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGUTLC00080.retrieveDynamicQueryPopList",param);
	}

	/**
	 * Desc : Dynamic Query 컬럼 목록을 조회한다.
	 * @Method Name : retrieveDynamicQueryDetail
	 * @param  param
	 * @return List<?>
	 */
	public List<LGCOMData> retrieveDynamicQueryColumnList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGUTLC00080.retrieveDynamicQueryColumnList",param);
	}

	
	
	public LGCOMData saveDynamicQueryResultList(LGCOMData param) {
		
		if("Y".equals((String)param.get("executeAs"))) {
			param.set("programId", "LGUTLC00083");
			LGCOMData batchParam = new LGCOMData();
			batchParam.set("data", param);
			
			LGCOMData result = batchService.executeBatch( batchParam );
			return result;
		} else {
			return saveDynamicQueryResultListNewBatch(param);
		}
	}
	
	/**
	 * Desc : Dynamic Query 결과 목록을 조회한다.
	 * @Method Name : retrieveDynamicQueryResultList
	 * @param  param
	 * @result int
	 */
	public LGCOMData saveDynamicQueryResultListNewBatch(LGCOMData param) {
		LOGGER.debug("param = " + param);
		// 넘겨받은 Argument를 JSON String으로 변환
		Gson gson = new Gson();
		String arguments = gson.toJson(param.get("sqlArg"));
		LOGGER.debug("arguments = " + arguments);
		// 결과값을 반환할 Map 생성
		LGCOMData result = new LGCOMData();
		// 신규 DQ Session ID를 생성한다.
		LGCOMData idMap = this.commonDao.select("LGUTLC00080.retrieveNewDynamicQuerySessionId");
		result.set("executeAs",param.get("executeAs"));
		result.set("sessionId",idMap.getString("newSessionId"));
		result.set("queryId",(String)param.get("queryId"));
		
		param.set("sessionId",idMap.getString("newSessionId"));
		String generatedQuery = this.service.retrieveDynamicQueryBody(param);
		
		LOGGER.debug("generatedQuery =\n" + generatedQuery);
		// 세션정보 얻기
		LGCOMData userSession = (LGCOMData)param.get("USER_SESSION");
		if("Y".equals((String)param.get("executeAs"))) {
			// DQ 수행 History 테이블 적재
			LGCOMData historyParam = new LGCOMData();
			historyParam.set("defaultOrgId",userSession.getString("defaultOrgId"));
			historyParam.set("applicationUserId",userSession.getString("applicationUserId"));
			historyParam.set("sessionId",param.getString("sessionId"));
			historyParam.set("queryId",param.getString("queryId"));
			historyParam.set("generatedQuery",generatedQuery);
			historyParam.set("programId","LGUTLC00080");
			historyParam.set("resultCount",0);
			historyParam.set("statusCode","S");
			historyParam.set("sqlText",arguments);
			historyParam.set("batchRequestId", param.getString("batchRequestId"));
			this.commonDao.insert("LGUTLC00080.insertDynamicQueryExecHistory",historyParam);
			
			// Background DQ 수행 Procedure 호출
			LGCOMData procParam = new LGCOMData();
			procParam.set("applicationUserId",userSession.getDouble("applicationUserId"));
			procParam.set("orgId",userSession.getString("defaultOrgId"));
			procParam.set("userId",userSession.getString("applicationUserId"));
			procParam.set("sessionId",param.getString("sessionId"));
			procParam.set("queryId",param.getString("queryId"));
			procParam.set("accessGroup",param.getString("accessGroup"));
			procParam.set("description","");
			procParam.set("batchRequestId", param.getString("batchRequestId"));
			// Procedure 호출 Thread
			//new Thread(new DynamicQueryExecutor(this.commonDao,procParam)).start();
			
			try {
				this.commonDao.select("LGUTLC00080.processDynamicQueryResult", procParam );
				
				historyParam = new LGCOMData();
				if("E".equals( procParam.getString("errorCode"))) {
					// DQ 수행 History 테이블 적재
					historyParam.set("defaultOrgId", procParam.getString("orgId"));
					historyParam.set("applicationUserId", procParam.getString("applicationUserId"));
					historyParam.set("sessionId", procParam.getString("sessionId"));
					historyParam.set("queryId", procParam.getString("queryId"));
					historyParam.set("sqlExecutionResultRowCount", 0);
					historyParam.set("batchJobStartDate", "SYSDATE");
					historyParam.set("batchJobEndDate", "SYSDATE");
					historyParam.set("rsltStatusCode", "ERROR");
					historyParam.set("resultContent", procParam.getString("errorMsg"));
					historyParam.set("userId", procParam.getString("userId"));
					modifyDynamicQueryExecLog(historyParam);
				}
			} catch(Exception ex) {
				LOGGER.error(ex.getMessage(),ex);
				// DQ 수행 History 테이블 적재
			    historyParam = new LGCOMData();
				historyParam.set("defaultOrgId",procParam.getString("orgId"));
				historyParam.set("applicationUserId",procParam.getString("applicationUserId"));
				historyParam.set("sessionId",procParam.getString("sessionId"));
				historyParam.set("queryId",procParam.getString("queryId"));
				historyParam.set("sqlExecutionResultRowCount",0);
				historyParam.set("batchJobStartDate","SYSDATE");
				historyParam.set("batchJobEndDate","SYSDATE");
				historyParam.set("rsltStatusCode","ERROR");
				historyParam.set("resultContent",ex.getCause().getMessage());
				historyParam.set("userId",procParam.getString("userId"));
				modifyDynamicQueryExecLog(historyParam);
			}	
		} else {
			// 조회된 결과를 Temp 테이블에 입력한다.
			int insertResult = this.commonDao.updateDynamicQuery(generatedQuery);
			result.set("executeCount",insertResult);
			if(insertResult > 0) {
				// DQ 수행 History 테이블 적재
				LGCOMData historyParam = new LGCOMData();
				historyParam.set("defaultOrgId",userSession.getString("defaultOrgId"));
				historyParam.set("applicationUserId",userSession.getString("applicationUserId"));
				historyParam.set("sessionId",param.get("sessionId"));
				historyParam.set("queryId",param.get("queryId"));
				historyParam.set("generatedQuery",generatedQuery);
				historyParam.set("programId","LGUTLC00080");
				historyParam.set("resultCount",insertResult);
				historyParam.set("statusCode","S");
				historyParam.set("sqlText",arguments);
				this.commonDao.insert("LGUTLC00080.insertDynamicQueryExecHistory",historyParam);
				// DQ 수행 Log 테이블 적재
				LGCOMData logParam = new LGCOMData();
				logParam.set("defaultOrgId",userSession.getString("defaultOrgId"));
				logParam.set("applicationUserId",userSession.getDouble("applicationUserId"));
				logParam.set("formId","LGUTLC00080");
				logParam.set("queryId",param.getString("queryId"));
				this.commonDao.insert("LGUTLC00080.insertDynamicQueryUseLog",logParam);
			}
		}
		return result;
	}

	/**
	 * Desc : Dynamic Query 결과 목록을 조회한다.
	 * @Method Name : retrieveDynamicQueryResultList2
	 * @param  param
	 * @result LGCOMData
	 */
	public LGCOMData saveDynamicQueryResultList2(LGCOMData param) {
		LOGGER.debug("param = " + param);
		// 넘겨받은 Argument를 JSON String으로 변환
		Gson gson = new Gson();
		String arguments = gson.toJson(param.get("sqlArg"));
		String attModuleCode = "LGCOM";
		LOGGER.debug("arguments = " + arguments);
		LOGGER.debug("attModuleCode = " + attModuleCode);
		
		// 결과값을 반환할 Map 생성
		LGCOMData result = new LGCOMData();
		// 신규 DQ Session ID를 생성한다.
		LGCOMData idMap = this.commonDao.select("LGUTLC00080.retrieveNewDynamicQuerySessionId");
		
		result.set("sessionId",idMap.getString("newSessionId"));
		result.set("queryId",(String)param.get("queryId"));
		param.set("sessionId",idMap.getString("newSessionId"));
		
		String generatedQuery = this.service.retrieveDynamicQueryBody(param);
		LOGGER.debug("generatedQuery =\n" + generatedQuery);
		param.set("queryMode","EXECUTABLE");
		String executeQuery = this.service.retrieveDynamicQueryBody(param);
		LOGGER.debug("executeQuery =\n" + executeQuery);
		String getterQuery = this.generateGetResultQuery(param);
		LOGGER.debug("getterQuery =\n" + getterQuery);
		// 건수를 조회한다.
		StringBuffer buffer = new StringBuffer();
		buffer.append("SELECT COUNT(1) AS cnt FROM (").append(executeQuery).append(")");
		LGCOMData countData = this.dynamicDao.selectOne(buffer.toString());
		LOGGER.debug("countData = " + countData);
		// 파일생성 기본 경로
		String fileBaseDir = LGCOMUtils.getValueFromProjectProperties(this.commonDirectory);
		// 세션정보 얻기
		LGCOMData userSession = (LGCOMData)param.get("USER_SESSION");
		if(countData.getInt("cnt") > 1) {
			// Async 수행여부 Y
			result.set("executeAs","Y");
			// DQ 수행 History 테이블 적재
			LGCOMData historyParam = new LGCOMData();
			//Map<String,Object> historyParam = new HashMap<String,Object>();
			historyParam.set("defaultOrgId",userSession.getString("defaultOrgId"));
			historyParam.set("applicationUserId",userSession.getString("applicationUserId"));
			historyParam.set("sessionId",param.get("sessionId"));
			historyParam.set("queryId",param.get("queryId"));
			historyParam.set("generatedQuery",generatedQuery);
			historyParam.set("programId","LGUTLC00080");
			historyParam.set("resultCount",0);
			historyParam.set("statusCode","P");
			historyParam.set("sqlText",arguments);
			this.commonDao.insert("LGUTLC00080.insertDynamicQueryExecHistory",historyParam);
			// Async 처리 시작
			LGCOMData batchMap = new LGCOMData();
			StringBuffer argBuffer = new StringBuffer();
			argBuffer.append("DynamicQueryExecutor");						// 실행할 Class Name(com.lgd.lgcom.common.batch.exec 아래에 존재해야 한다.)
			argBuffer.append(" ");											// 각 Argument의 구분자는 공백이다.
			argBuffer.append(result.getString("sessionId"));				// 수행할 첫번째 Arg, 세션ID
			argBuffer.append(" ");											// 각 Argument의 구분자는 공백이다.
			argBuffer.append(result.getString("queryId"));					// 수행할 두번째 Arg, 쿼리ID
			argBuffer.append(" ");											// 각 Argument의 구분자는 공백이다.
			argBuffer.append(arguments);									// 수행할 세번째 Arg, 쿼리 수행 Argument
			argBuffer.append(" ");											// 각 Argument의 구분자는 공백이다.
			argBuffer.append(userSession.getString("defaultOrgId"));		// 수행할 네번째 Arg, Default Org Id
			argBuffer.append(" ");											// 각 Argument의 구분자는 공백이다.
			argBuffer.append(userSession.getString("applicationUserId"));	// 수행할 다섯번째 Arg, Application User Id
			argBuffer.append(" ");											// 각 Argument의 구분자는 공백이다.
			argBuffer.append(attModuleCode);								// 수행할 여섯번째 Arg, 첨부파일용 모듈코드
			argBuffer.append(" ");											// 각 Argument의 구분자는 공백이다.
			argBuffer.append(LGCOMUtils.encodeString(fileBaseDir));         // 수행할 일곱번째 Arg, 첨부파일용 모듈코드
			argBuffer.append(" ");											// 각 Argument의 구분자는 공백이다.
			argBuffer.append(LGCOMUtils.encodeString(generatedQuery));		// 수행할 여덟번째 Arg, SELECT INSERT 쿼리(Base64 Encode)
			argBuffer.append(" ");											// 각 Argument의 구분자는 공백이다.
			argBuffer.append(LGCOMUtils.encodeString(getterQuery));			// 수행할 아홉번째 Arg, Result 테이블 조회 쿼리(Base64 Encode)
			batchMap.set("vParam",argBuffer.toString());
			this.asyncService.executeBatchAsync(batchMap);
		} else {
			// 시작일시
			SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd kk:mm:ss");
			Date startDate = new Date();
			// 조회된 결과를 Temp 테이블에 입력한다.
			String statusCode = "S";		// 처리결과 기본 완료
			String errorMessage = "";		// 기본 메세지는 ""
			// 파일 ID
			String attachFileId = "";
			int insertResult = 0;
			if(countData.getInt("cnt") > 0) {
				// 쿼리를 수행하고 결과값을 Result Table에 적재한다.
				insertResult = this.commonDao.updateDynamicQuery(generatedQuery);
				// 적재완료후 적재건이 존재하면
				if(insertResult > 0) {
					ResultSet rs = null;
					OutputStreamWriter osw = null;
					FileOutputStream fos = null;
					try {
						// 첨부파일 정보를 적재
						attachFileId = this.commonService.retrieveNewAttachFileId();
						String attachReqNum = this.commonService.retrieveNewAttachFileGroupId();
						String fileName = "Bizweb_DQ_" + result.getString("sessionId") + ".csv";

						// 파일생성 경로가 없으면 생성한다.
						File repoDir = new File(LGCOMUtils.getValueFromProjectProperties(this.commonDirectory)+"/"+attModuleCode);
						if(!repoDir.exists()) {
							FileUtils.forceMkdir(repoDir);
						}
						// 파일을 쓴다.
						fos = new FileOutputStream(new File(fileBaseDir+"/"+attModuleCode,attachFileId));
						byte [] header = new byte[3];
						header[0] = DatatypeConverter.parseHexBinary("EF")[0];
						header[1] = DatatypeConverter.parseHexBinary("BB")[0];
						header[2] = DatatypeConverter.parseHexBinary("BF")[0];
						fos.write(header);
						osw = new OutputStreamWriter(fos,"UTF-8");
						// 지정된 경로에 session id를 기준으로 템프파일을 적재한다.
						LGCOMData resultData = this.dynamicDao.requestExcelExport(getterQuery,param);
						rs = (ResultSet)resultData.get("resultSet");
						CSVPrinter csvPrinter = new CSVPrinter(osw, CSVFormat.DEFAULT);
						csvPrinter.printRecords(rs);
						csvPrinter.flush();
						csvPrinter.close();

						LGCOMData attachParam = new LGCOMData();
						attachParam.set("fileId",attachFileId);
						attachParam.set("reqNumber",attachReqNum);
						attachParam.set("moduleCode",attModuleCode);
						attachParam.set("fileName",fileName);
						attachParam.set("fileSize",-1);
						attachParam.set("USER_SESSION",userSession);
						LOGGER.debug("attachParam = " + attachParam);
						this.commonService.insertAttachFileInfo(attachParam);
						result.set("fileId",attachFileId);
					} catch(Exception ex) {
						statusCode = "E";
						errorMessage = ex.getMessage();
						throw new LGCOMException(ex);
					} finally {
						try {if(rs != null)  {rs.close(); };}catch(SQLException e1){/*exception*/}
						try {if(osw != null) {osw.close();};}catch(IOException e2){/*exception*/}
						try {if(fos != null) {fos.close();};}catch(IOException e2){/*exception*/}
					}
				}
			}
			// 종료일시
			Date endDate = new Date();
			result.set("executeCount",insertResult);

			// DQ 수행 History 테이블 적재
			LGCOMData historyParam = new LGCOMData();
			historyParam.set("defaultOrgId",userSession.getString("defaultOrgId"));
			historyParam.set("applicationUserId",userSession.getString("applicationUserId"));
			historyParam.set("sessionId",param.get("sessionId"));
			historyParam.set("queryId",param.get("queryId"));
			historyParam.set("generatedQuery",generatedQuery);
			historyParam.set("programId","LGUTLC00080");
			historyParam.set("resultCount",insertResult);
			historyParam.set("concurrentRequestId",attachFileId);
			historyParam.set("startDate",sdf.format(startDate));
			historyParam.set("endDate",sdf.format(endDate));
			historyParam.set("sqlErrorContent",errorMessage);
			historyParam.set("statusCode",statusCode);
			historyParam.set("sqlText",arguments);
			this.commonDao.insert("LGUTLC00080.insertDynamicQueryExecHistory2",historyParam);
		}
		LOGGER.debug("result = " + result);
		return result;
	}

	/**
	 * Desc : Dynamic Query 결과 목록을 조회한다.
	 * @Method Name : retrieveDynamicQueryResultList
	 * @param  param
	 * @return LGCOMData
	 */
	public List<LGCOMData> retrieveDynamicQueryResultList(LGCOMData param) {
	    LOGGER.debug("param = " + param);
		/* Query ID로 Query 정보 조회 */
	    LGCOMData queryData = this.commonDao.select("LGUTLC00090.retrieveDynamicQueryDetail",param);
		LOGGER.debug("queryData = " + queryData);
		if(queryData != null) {
		    param.set("orderByClause",queryData.getString("orderByClause"));
		}
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGUTLC00080.retrieveDynamicQueryResultList",param);
	}

	/**
	 * Desc : Dynamic Query 실행 이력을 조회한다.
	 * @Method Name : retrieveDynamicQueryTodayList
	 * @param  param
	 * @return List<?>
	 * @throws IOException
	 * @throws SQLException
	 */
	public List<LGCOMData> retrieveDynamicQueryTodayList(LGCOMData param) throws SQLException, IOException {
	    LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGUTLC00080.retrieveDynamicQueryTodayList",param);
	}

	/**
	 * Desc : Excel 파일을 다운로드 한다.
	 * @Method Name : exportDynamicQueryExcel
	 * @param  param
	 * @return void
	 */
	public LGCOMData exportDynamicQueryExcel(LGCOMData param) throws Exception {
		return this.dynamicDao.requestExcelExport(this.generateGetResultQuery(param),param);
	}

	/**
	 * Desc : 처리완료시 처리결과를 로깅한다.
	 * @Method Name : modifyDynamicQueryExecLog
	 * @param param
	 */
	private void modifyDynamicQueryExecLog( LGCOMData param) {
		this.commonDao.update("LGUTLC00080.updateDynamicQueryExecHistory",param);
	}

	/**
	 * Desc :
	 * @Method Name : generateGetResultQuery
	 * @param param
	 * @return
	 */
	private String generateGetResultQuery(LGCOMData param) {
		LOGGER.debug("param = " + param);
		/* Query ID로 Query 정보 조회 */
		LGCOMData queryData = this.commonDao.select("LGUTLC00090.retrieveDynamicQueryDetail",param);
		/* 쿼리 ID로 해당 컬럼을 조회한다. */
		List<LGCOMData> columnList = this.commonDao.selectList("LGUTLC00080.retrieveDynamicQueryColumnList",param);
		/* 쿼리를 생성한다. */
		StringBuffer generatedQuery = new StringBuffer();
		
		//20171025 이준성 추가
		generatedQuery.append("  SELECT '");
		for(int i=0; i < columnList.size(); i++) {
			LGCOMData item = (LGCOMData)columnList.get(i);
            if(i > 0) {
                generatedQuery.append("       , '");
            }
            generatedQuery.append(item.getString("columnPrompt")).append("' \n");
        }
        
        generatedQuery.append(" FROM DUAL \n");
        
        generatedQuery.append(" UNION ALL \n");
		
		generatedQuery.append(" SELECT * FROM (\n SELECT ");
		for(int i=0; i < columnList.size(); i++) {
		    LGCOMData item = (LGCOMData)columnList.get(i);
			String colIdx = (((i+1) < 10) ? "0"+(i+1):(i+1)+"");
			if(i > 0) {
				generatedQuery.append("       , ");
			}
			generatedQuery.append("F").append(colIdx).append(" AS \"").append(item.getString("columnPrompt")).append("\"\n");
		}
		generatedQuery.append("    FROM XXLGE_QUERY_RESULTS \n");
		generatedQuery.append("   WHERE session_id = ").append(param.get("sessionId").toString()).append(" \n");
		generatedQuery.append("     AND query_id   = ").append(param.get("queryId").toString()).append(" \n");
		if(queryData != null && !NullUtil.isNone(queryData.getString("orderByClause"))) {
		    generatedQuery.append(queryData.getString("orderByClause")).append("\n");
		}
		generatedQuery.append(") \n");
		
		LOGGER.debug("generatedQuery = \n" + generatedQuery.toString());
		return generatedQuery.toString();
	}

	class DynamicQueryExecutor implements Runnable {
	    LGCOMLogger logger = LGCOMLoggerFactory.getLogger(DynamicQueryExecutor.class);
		CommonDao dao;
		Map<String,Object> arguments;
		public DynamicQueryExecutor(CommonDao dao, Map<String,Object> args) {
			this.dao = dao;
			this.arguments = args;
		}

		@Override
		public void run() {
			try {
			    logger.debug("before arguments = " + this.arguments);
			    
			    LGCOMData param = new LGCOMData();
			    param.putAll( this.arguments );
				this.dao.select("LGUTLC00080.processDynamicQueryResult",param);
				logger.debug("after arguments = " + this.arguments);
				if("E".equals((String)this.arguments.get("errorCode"))) {
					// DQ 수행 History 테이블 적재
					LGCOMData historyParam = new LGCOMData();
					historyParam.set("defaultOrgId",arguments.get("orgId"));
					historyParam.set("applicationUserId",arguments.get("applicationUserId"));
					historyParam.set("sessionId",arguments.get("sessionId"));
					historyParam.set("queryId",arguments.get("queryId"));
					historyParam.set("sqlExecutionResultRowCount",0);
					historyParam.set("batchJobStartDate","SYSDATE");
					historyParam.set("batchJobEndDate","SYSDATE");
					historyParam.set("rsltStatusCode","ERROR");
					historyParam.set("resultContent",(String)this.arguments.get("errorMsg"));
					historyParam.set("userId",arguments.get("userId"));
					modifyDynamicQueryExecLog(historyParam);
				}
			} catch(Exception ex) {
			    logger.error(ex.getMessage(),ex);
				// DQ 수행 History 테이블 적재
			    LGCOMData historyParam = new LGCOMData();
				historyParam.set("defaultOrgId",arguments.get("orgId"));
				historyParam.set("applicationUserId",arguments.get("applicationUserId"));
				historyParam.set("sessionId",arguments.get("sessionId"));
				historyParam.set("queryId",arguments.get("queryId"));
				historyParam.set("sqlExecutionResultRowCount",0);
				historyParam.set("batchJobStartDate","SYSDATE");
				historyParam.set("batchJobEndDate","SYSDATE");
				historyParam.set("rsltStatusCode","ERROR");
				historyParam.set("resultContent",ex.getCause().getMessage());
				historyParam.set("userId",arguments.get("userId"));
				modifyDynamicQueryExecLog(historyParam);
			}
		}
	}
}
