/**
 * -----------------------------------------------------------------------------
 *
 * @Project : LGDisplay LGCOM Project
 * @Source : LGSETC00090ServiceImpl.java
 * @Desc : Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 * -----------------------------------------------------------------------------
 * ------- 변 경 사 항
 * -----------------------------------------------------------------------------
 * ------- VER DATE AUTHOR DESCRIPTION
 * -----------------------------------------------------------------------------
 * ------ 1. 0 2016. 8. 3. csseo 최초 프로그램 작성
 * -----------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgutlc.lgutlc00090.service.serviceImpl;

import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.util.LGCOMConstants;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgcom.lgutlc.lgutlc00090.service.LGUTLC00090Service;

import devonframe.util.NullUtil;

/**
 * <PRE>
 * com.lgd.lgcom.lgsetc.lgsetc00090.service.serviceImpl.LGSETC00090ServiceImpl.java
 * </PRE>
 *
 * @Author csseo
 * @Date 2016. 8. 3. 오전 9:00:58
 * @Version
 */
@Service(value = "LGUTLC00090Service")
public class LGUTLC00090ServiceImpl implements LGUTLC00090Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGUTLC00090ServiceImpl.class);

	@Resource(name = "commonDao")
	CommonDao commonDao;

	/**
	 * Desc : Dynamic Query 목록을 조회한다.
	 * 
	 * @Method Name : retrieveDynamicQueryList
	 * @param param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveDynamicQueryList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGUTLC00090.retrieveDynamicQueryList", param);
	}

	/**
	 * Desc : Dynamic Query 상세내역을 조회한다.
	 * 
	 * @Method Name : retrieveDynamicQueryDetail
	 * @param param
	 * @return LGCOMData
	 */
	public LGCOMData retrieveDynamicQueryDetail(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.select("LGUTLC00090.retrieveDynamicQueryDetail", param);
	}

	/**
	 * Desc : Dynamic Query 컬럼 목록을 조회한다.
	 * 
	 * @Method Name : retrieveDynamicQueryDetail
	 * @param param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveDynamicQueryColumnList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGUTLC00090.retrieveDynamicQueryColumnList", param);
	}

	/**
	 * Desc : Dynamic Query 내용을 저장한다.
	 * 
	 * @Method Name : saveDynamicQueryInfo
	 * @param param
	 * @return LGCOMData
	 */
	@SuppressWarnings("unchecked")
	public LGCOMData saveDynamicQueryInfo(LGCOMData param) {
		LOGGER.debug("param = " + param);
		LGCOMData result = new LGCOMData();
		result.set("queryId", param.get("queryId"));
		result.set("accessGroup", param.get("accessGroup"));

		/* 사용자 세션 얻기 */
		LGCOMData userSession = (LGCOMData) param.get("USER_SESSION");
		// 1. Query ID가 존재하는지 체크해서 존재하지 않으면 신규 ID 채번
		// 2. 등록된 쿼리를 저장
		if (param.get("queryId") == null || NullUtil.isNone((String) param.get("queryId"))) {
			LGCOMData map = this.commonDao.select("LGUTLC00090.retrieveNewDynamicQueryId");
			LOGGER.debug("map = " + map);
			param.set("queryId", map.getLong("nextQueryId"));
			result.set("queryId", map.getLong("nextQueryId"));
			this.commonDao.insert("LGUTLC00090.insertDynamicQueryData", param);
		} else {
			this.commonDao.update("LGUTLC00090.updateDynamicQueryData", param);
		}

		// 3. 컬럼 정보를 저장
		LGCOMData columnsInfo = (LGCOMData) param.get("columns");
		if (columnsInfo != null) {
			/* 삭제 */
			List<LGCOMData> dList = (List<LGCOMData>) columnsInfo.get(LGCOMConstants.STATUS_DELETE);
			for (LGCOMData item : LGCOMUtils.emptyIfNull(dList)) {
				/* 세션 사용자 정보 세팅 */
				item.set("sessionUserId", userSession.getString("applicationUserId"));
				this.commonDao.delete("LGUTLC00090.deleteDynamicQueryColumnData", item);
			}

			/* 신규 */
			List<LGCOMData> cList = (List<LGCOMData>) columnsInfo.get(LGCOMConstants.STATUS_INSERT);
			for (LGCOMData item : LGCOMUtils.emptyIfNull(cList)) {
				/* Query ID 세팅 */
				item.put("queryId", param.get("queryId"));
				/* 세션 사용자 정보 세팅 */
				item.set("sessionUserId", userSession.getString("applicationUserId"));
				this.commonDao.insert("LGUTLC00090.insertDynamicQueryColumnData", item);
			}
			/* 수정 */
			List<LGCOMData> uList = (List<LGCOMData>) columnsInfo.get(LGCOMConstants.STATUS_UPDATE);
			for (LGCOMData item : LGCOMUtils.emptyIfNull(uList)) {
				/* 세션 사용자 정보 세팅 */
				item.set("sessionUserId", userSession.getString("applicationUserId"));
				this.commonDao.update("LGUTLC00090.updateDynamicQueryColumnData", item);
			}
		}
		return result;
	}

	/**
	 * Desc : Dynamic Query Parameter 목록을 조회한다.
	 * 
	 * @Method Name : retrieveDynamicQueryParamList
	 * @param param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveDynamicQueryParamList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGUTLC00090.retrieveDynamicQueryParamList", param);
	}

	/**
	 * Desc : Dynamic Query Parameter 목록을 저장한다.
	 * 
	 * @Method Name : saveDynamicQueryParamData
	 * @param param
	 */
	@SuppressWarnings("unchecked")
	public void saveDynamicQueryParamData(LGCOMData param) {
		LOGGER.debug("param = " + param);
		/* 사용자 세션 얻기 */
		LGCOMData userSession = (LGCOMData) param.get("USER_SESSION");
		/* 삭제 */
		List<LGCOMData> dList = (List<LGCOMData>) param.get(LGCOMConstants.STATUS_DELETE);
		
		for( LGCOMData item : LGCOMUtils.emptyIfNull(dList) ) {
			/* 세션 사용자 정보 세팅 */
			item.put("sessionUserId", userSession.getString("applicationUserId"));
			this.commonDao.delete("LGUTLC00090.deleteDynamicQueryParamData", item);
		}
		/* 신규 */
		List<LGCOMData> cList = (List<LGCOMData>) param.get(LGCOMConstants.STATUS_INSERT);
		
		for( LGCOMData item : LGCOMUtils.emptyIfNull(cList) ) {
			/* 세션 사용자 정보 세팅 */
			item.put("sessionUserId", userSession.getString("applicationUserId"));
			this.commonDao.insert("LGUTLC00090.insertDynamicQueryParamData", item);
		}
		
		/* 수정 */
		List<LGCOMData> uList = (List<LGCOMData>) param.get(LGCOMConstants.STATUS_UPDATE);
		
		for( LGCOMData item : LGCOMUtils.emptyIfNull(uList) ) {
			/* 세션 사용자 정보 세팅 */
			item.put("sessionUserId", userSession.getString("applicationUserId"));
			this.commonDao.update("LGUTLC00090.updateDynamicQueryParamData", item);
		}
	}

	/**
	 * Desc : Dynamic Query Parameter 기본값 목록을 조회한다.
	 * 
	 * @Method Name : retrieveDynamicQueryParamValueList
	 * @param param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveDynamicQueryParamValueList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGUTLC00090.retrieveDynamicQueryParamValueList", param);
	}

	/**
	 * Desc : Dynamic Query Parameter Value 목록을 저장한다.
	 * 
	 * @Method Name : saveDynamicQueryParamValueData
	 * @param param
	 */
	@SuppressWarnings("unchecked")
	public void saveDynamicQueryParamValueData(LGCOMData param) {
		LOGGER.debug("param = " + param);
		/* 사용자 세션 얻기 */
		LGCOMData userSession = (LGCOMData) param.get("USER_SESSION");
		// 1. 항목 정보를 저장
		LGCOMData columnsInfo = (LGCOMData) param.get("columns");
		if (columnsInfo != null) {
			/* 삭제 */
			List<LGCOMData> dList = (List<LGCOMData>) columnsInfo.get(LGCOMConstants.STATUS_DELETE);
			for( LGCOMData item : LGCOMUtils.emptyIfNull(dList) ) {
				/* 세션 사용자 정보 세팅 */
				item.put("sessionUserId", userSession.getString("applicationUserId"));
				this.commonDao.delete("LGUTLC00090.deleteDynamicQueryParamValueData", item);
			}
			
			/* 신규 */
			List<LGCOMData> cList = (List<LGCOMData>) columnsInfo.get(LGCOMConstants.STATUS_INSERT);
			for( LGCOMData item : LGCOMUtils.emptyIfNull(cList) ) {
				/* 세션 사용자 정보 세팅 */
				item.put("sessionUserId", userSession.getString("applicationUserId"));
				this.commonDao.insert("LGUTLC00090.insertDynamicQueryParamValueData", item);
			}
			
			/* 수정 */
			List<LGCOMData> uList = (List<LGCOMData>) columnsInfo.get(LGCOMConstants.STATUS_UPDATE);
			for( LGCOMData item : LGCOMUtils.emptyIfNull(uList) ) {
				/* 세션 사용자 정보 세팅 */
				item.put("sessionUserId", userSession.getString("applicationUserId"));
				this.commonDao.update("LGUTLC00090.updateDynamicQueryParamValueData", item);
			}
		}
	}

	/**
	 * Desc : Dynamic Query Parameter 출력용 목록을 조회한다.
	 * 
	 * @Method Name : retrieveParamValueListForInput
	 * @param param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveParamValueListForInput(LGCOMData param) {
		LOGGER.debug("param = " + param);
		/* 쿼리 정보를 조회한다. */
		LGCOMData queryBase = this.commonDao.select("LGUTLC00090.retrieveDynamicQueryPreviewData", param);
		/* From 절과 Where절에서 적용된 기본 Parameter 정보를 뽑아낸다. */
		StringBuffer sqlBuff = new StringBuffer();
		/* From 절 */
		sqlBuff.append(NullUtil.nvl((String) queryBase.get("fromClause"), "").trim());
		sqlBuff.append("\n");
		/* Where 절 */
		sqlBuff.append(NullUtil.nvl((String) queryBase.get("whereClause"), "").trim());
		/* 조회된 Parameter Values 정보 */
		List<LGCOMData> result = LGCOMData.createList();
		LGCOMData item = null;
		/* 정규식 처리 */
		Pattern pattern = Pattern.compile("([\\[])+([_\\-0-9a-zA-Zㄱ-ㅎㅏ-ㅣ가-힣\\s])*([\\]])+", Pattern.MULTILINE);
		Matcher matcher = pattern.matcher(sqlBuff);
		
		while (matcher.find()) {
			String paramName = matcher.group(0).replaceAll("\\[", "").replaceAll("\\]", "").trim();
			LOGGER.debug("paramName = " + paramName);
			item = new LGCOMData();
			item.set("queryId", param.get("queryId"));
			item.set("paraName", paramName);
			
			if (!this.isContained(result, item)) {
				/* 찾은 Parameter Name으로 Parameter 정보를 조회한다. */
				LGCOMData paraData = this.commonDao.select("LGUTLC00090.retrieveParamValueListForInput", item);
				if (paraData != null) {
					String defaultValue = NullUtil.nvl(paraData.get("defaultValue"), "");
					if (NullUtil.isNone(defaultValue)) {
						item.set("initialValue", defaultValue);
					} else {
						LGCOMData defVal = this.commonDao.selectOneDynamicQuery(
								"SELECT (" + defaultValue + ") AS default_value FROM DUAL WHERE rownum = 1");
						item.set("initialValue", defVal.getString("defaultValue"));
					}
					item.set("requiredFlag", paraData.getString("requiredFlag"));
					item.set("isCodeType", paraData.getString("isCodeType"));
					item.set("paraType", paraData.getString("paraType"));
				} else {
					item.set("defaultValue", "");
					item.set("initialValue", "");
					item.set("requiredFlag", "N");
					item.set("isCodeType", "N");
					item.set("paraType", "C");
				}
				result.add(item);
			}
		}
		return result;
	}

	/**
	 * Desc : Dynamic Query Parameter 검색 Popup 목록을 조회한다.
	 * 
	 * @Method Name : retrieveParamSearchListForInput
	 * @param param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveParamSearchListForInput(LGCOMData param) {
		LOGGER.debug("param = " + param);
		// Query ID와 Parameter Name으로 해당 컬럼을 조회한다.
		LGCOMData paramData = this.commonDao.select("LGUTLC00090.retrieveParamSearchListForInput", param);
		LOGGER.debug("paramData = " + paramData);
		// Parameter 조회 쿼리 생성
		StringBuffer buffer = new StringBuffer();
		buffer.append("SELECT");
		// code column
		buffer.append(" ").append(paramData.getString("codeCol")).append(" AS code\n");
		// name column
		if (!NullUtil.isNone(paramData.getString("descCol"))) {
			buffer.append("     ,").append(paramData.getString("descCol")).append(" AS description\n");
		} else {
			buffer.append("     ,").append(paramData.getString("codeCol")).append(" AS description\n");
		}
		// from clause
		buffer.append(" ").append(paramData.getString("fromClause")).append("\n");
		// where clause
		boolean isWhareClause = true;
		if (!NullUtil.isNone(paramData.getString("whereClause"))) {
			buffer.append(" ").append(paramData.getString("whereClause")).append("\n");
			isWhareClause = false;
		}
		// keyword
		if (!NullUtil.isNone((String) param.get("keyword"))) {
			if (isWhareClause) {
				buffer.append(" WHERE ").append(paramData.getString("codeCol")).append(" LIKE '")
						.append(param.get("keyword")).append("'\n");
			} else {
				buffer.append("   AND ").append(paramData.getString("codeCol")).append(" LIKE '")
						.append(param.get("keyword")).append("'\n");
			}
		}
		if (!NullUtil.isNone(paramData.getString("orderByClause"))) {
			buffer.append(" ").append(paramData.getString("orderByClause")).append("\n");
		}
		LOGGER.debug("query buffer = " + buffer.toString());
		// 검색쿼리를 수행한다.
		return this.commonDao.selectListDynamicQuery(buffer.toString(), param);
	}

	/**
	 * Desc : Dynamic Query SQL을 생성한다.
	 * 
	 * @Method Name : retrieveDynamicQueryPreview
	 * @param param
	 * @return LGCOMData
	 */
	public LGCOMData retrieveDynamicQueryPreview(LGCOMData param) {
		LOGGER.debug("param = " + param);
		LGCOMData result = new LGCOMData();
		result.set("generatedSql", this.retrieveDynamicQueryBody(param));
		return result;
	}

	/**
	 * Desc : Dynamic Query SQL을 생성한다.
	 * 
	 * @Method Name : retrieveDynamicQueryPreview
	 * @param param
	 * @return LGCOMData
	 */
	public LGCOMData retrieveDynamicQueryTest(LGCOMData param) {
		LOGGER.debug("param = " + param);
		String genQuery = this.retrieveDynamicQueryBody(param);
		LOGGER.debug("genQuery =\n" + genQuery);
		LGCOMData result = this.commonDao.selectOneDynamicQuery("SELECT COUNT(*) AS cnt FROM (" + genQuery + ") WHERE rownum = 1");
		result.set("generatedSql", genQuery);
		return result;
	}

	/**
	 * Desc : 쿼리 ID를 받아 Data를 조합해서 Query를 생성한다.
	 * 
	 * @Method Name : retrieveDynamicQueryBody
	 * @param queryId
	 * @return String
	 */
	@SuppressWarnings("unchecked")
	public String retrieveDynamicQueryBody(LGCOMData param) {
		LOGGER.debug("param = " + param);
		StringBuffer buffer = new StringBuffer();
		boolean isRunMode = false;
		
		/* 쿼리 기본정보 조회 */
		LGCOMData queryBase = this.commonDao.select("LGUTLC00090.retrieveDynamicQueryPreviewData", param);
		LOGGER.debug("queryBase = " + queryBase);
		
		/* 컬럼 목록 조회 */
		List<LGCOMData> columnList = this.commonDao.selectList("LGUTLC00090.retrieveDynamicQueryColumnData", param);
		LOGGER.debug("columnList = " + columnList);
		
		/* 실제 실행시에는 SELECT INSERT 구문을 구현한다. */
		if ("RUN".equals(param.getString("queryMode"))) {
			isRunMode = true;
		}
		
		if (isRunMode) {
			buffer.append("INSERT INTO XXLGE_QUERY_RESULTS (\n");
			for (int m = 1; m <= columnList.size(); m++) {
				if (m > 1) {
					buffer.append("\t, ");
				}
				buffer.append("F").append(((m < 10) ? "0" + Integer.toString(m) : Integer.toString(m))).append("\n");
			}
			buffer.append("\t, SESSION_ID\n");
			buffer.append("\t, QUERY_ID\n");
			buffer.append(") \n");
		}
		/* 화면에서 받은 Arguments */
		LGCOMData sqlParam = (LGCOMData) param.get("sqlArg");
		LOGGER.debug("sqlParam = " + sqlParam);

		/* SELECT 구문 */
		buffer.append("SELECT ");
		/* Hint 구문 */
		if (!NullUtil.isNone((String) queryBase.get("hintClause"))) {
			buffer.append(" /*+ ").append(queryBase.getString("hintClause")).append(" */\n");
		}
		/* Distinct 구문 */
		if ("Y".equals(NullUtil.nvl((String) queryBase.get("distinctFlag"), "N"))) {
			buffer.append(" distinct ");
		}
		/* Column 조합 */
		for (int a = 0; a < columnList.size(); a++) {
			LGCOMData column = columnList.get(a);
			if (a > 0) {
				buffer.append("\t, ");
			} else if (!isRunMode && a > 0) {
				buffer.append("\t, ");
			}
			if ("C".equals(column.getString("dataType"))) {
				buffer.append(column.getString("columnName"));
				if ("VIEW".equals((String) param.get("queryMode"))) {
					buffer.append(" AS \"").append(column.getString("displayName")).append("\"");
				}
			} else if ("N".equals(column.getString("dataType"))) {
				if (!NullUtil.isNone((String) column.get("formatMask"))) {
					buffer.append("TO_CHAR(").append(column.getString("columnName")).append(", '")
							.append(column.getString("formatMask")).append("')");
					if ("VIEW".equals((String) param.get("queryMode"))) {
						buffer.append(" AS \"").append(column.getString("displayName")).append("\"");
					} else {
						buffer.append(" AS \"").append(column.getString("columnName")).append("\"");
					}
				} else {
					buffer.append(column.getString("columnName"));
					if ("VIEW".equals((String) param.get("queryMode"))) {
						buffer.append(" AS \"").append(column.getString("displayName")).append("\"");
					}
				}
			} else if ("D".equals(column.getString("dataType"))) {
				buffer.append("TO_CHAR(").append(column.getString("columnName")).append(", 'YYYY.MM.DD')");
				if ("VIEW".equals((String) param.get("queryMode"))) {
					buffer.append(" AS \"").append(column.getString("displayName")).append("\"");
				} else {
					buffer.append(" AS \"").append(column.getString("columnName")).append("\"");
				}
			} else if ("T".equals(column.getString("dataType"))) {
				buffer.append("TO_CHAR(").append(column.getString("columnName")).append(", 'YYYY.MM.DD HH24:MI:SS')");
				if ("VIEW".equals((String) param.get("queryMode"))) {
					buffer.append(" AS \"").append(column.getString("displayName")).append("\"");
				} else {
					buffer.append(" AS \"").append(column.getString("columnName")).append("\"");
				}
			}
			buffer.append("\n");
		}
		
		/* 실행시에는 SESSION_ID, QUERY_ID를 조회한다. */
		if (isRunMode) {
			buffer.append("\t, ").append((String) param.get("sessionId")).append("\n");
			buffer.append("\t, ").append((String) param.get("queryId")).append("\n");
		}
		
		/* 화면에서 받은 Arguments */
		Iterator<Map.Entry<String, Object>> iter1 = sqlParam.entrySet().iterator();
		/* From 절 */
		String fromClause = NullUtil.nvl((String) queryBase.get("fromClause"), "").trim();
		while (iter1.hasNext()) {
			Map.Entry<String, Object> entry = iter1.next();
			Object obj = entry.getValue();
			String val = null;
			if (obj != null) {
				if (obj instanceof String) {
					val = (String) obj;
				} else {
					val = obj.toString();
				}
			} else {
				val = "";
			}
			fromClause = fromClause.replaceAll("\\[" + entry.getKey() + "\\]", NullUtil.nvl(val, ""));
		}
		buffer.append(" ").append(fromClause).append("\n");
		/* 화면에서 받은 Arguments */
		Iterator<Map.Entry<String, Object>> iter2 = sqlParam.entrySet().iterator();
		/* Where 절 */
		String whereClause = NullUtil.nvl((String) queryBase.get("whereClause"), "").trim();
		while (iter2.hasNext()) {
			Map.Entry<String, Object> entry = iter2.next();
			Object obj = entry.getValue();
			String val = null;
			if (obj != null) {
				if (obj instanceof String) {
					val = (String) obj;
				} else {
					val = obj.toString();
				}
			} else {
				val = "''";
			}
			whereClause = whereClause.replaceAll("\\[" + entry.getKey() + "\\]", NullUtil.nvl(val, ""));
		}
		buffer.append(" ").append(whereClause).append("\n");
		/* Order by 절 */
		if (!NullUtil.isNone((String) queryBase.get("orderByClause"))) {
			buffer.append(" ").append((String) queryBase.get("orderByClause")).append("\n");
		}
		return buffer.toString();
	}

	/**
	 * Desc : 쿼리 Parsing 시에 Param Name으로 중복을 체크한다.
	 * 
	 * @Method Name : isContained
	 * @param list
	 * @param item
	 * @return boolean
	 */
	private boolean isContained(List<LGCOMData> list, LGCOMData item) {
		boolean isContain = false;
		if (list != null && item != null) {
			for (int i = 0; i < list.size(); i++) {
				if (list.get(i).getString("paraName").equalsIgnoreCase(item.getString("paraName"))) {
					isContain = true;
					break;
				}
			}
		}
		return isContain;
	}
}
