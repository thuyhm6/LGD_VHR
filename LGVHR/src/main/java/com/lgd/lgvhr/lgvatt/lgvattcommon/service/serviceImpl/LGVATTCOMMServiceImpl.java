/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVATTCOMMServiceImpl.java
 * @Desc    : 근태 공통 조회
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2017. 10. 18.    limsjin    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvatt.lgvattcommon.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvatt.lgvattcommon.service.LGVATTCOMMService;

import devonframe.util.NullUtil;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvatt.lgvattcommon.service.serviceImpl.LGVATTCOMMServiceImpl.java
 * </PRE>
 *
 * @Author    limsjin
 * @Date	  2017. 10. 18. 오후 3:48:12
 * @Version
 */
@Service("LGVATTCOMMService")
public class LGVATTCOMMServiceImpl implements LGVATTCOMMService {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVATTCOMMServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;
	
	

	/**
	 * Desc : 근태유형 목록을 조회한다.
	 * @Method Name : retrieveAttendanceTypeList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveAttendanceTypeList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVATTCOMM.retrieveAttendanceTypeList",param);
	}

	/**
	 * Desc : 근태코드 목록을 조회한다.
	 * @Method Name : retrieveAttendanceCodeList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveAttendanceCodeList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVATTCOMM.retrieveAttendanceCodeList",param);
	}

	/**
	 * Desc : 근태유형, 근태코드 목록을 조회한다.
	 * @Method Name : retrieveAttendanceCodeList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public LGCOMData retrieveAttendanceTypeNCodeList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		LGCOMData result = new LGCOMData();
		//근태유형
		result.set("attendanceType", this.commonDao.selectList("LGVATTCOMM.retrieveAttendanceTypeList",param));
		//근태코드
		result.set("attendanceCode", this.commonDao.selectList("LGVATTCOMM.retrieveAttendanceCodeList",param));
		return result;
	}
	
	/**
	 * Desc : 출근시간을 조회한다.
	 * @Method Name : retrieveWorkStartTimeList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveWorkStartTimeList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVATTCOMM.retrieveWorkStartTimeList",param);
	}

	/**
	 * Desc : 주어진 조건에 따라 사용자 정보를 조회한다.
	 * @Method Name : retrieveEmployee
	 * @param  param
	 * @return LGCOMData
	 */
	public LGCOMData retrieveEmployee(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.select("LGVATTCOMM.retrieveEmployee",param);
	}

	/**
	 * Desc : 근무일, 교대유형, Day/Night구분, 석식여부, 근무시작시간, 입력한 OT에 따라 지급비율이 다른 OT를 자동 계산한다.
	 * @Method Name : processCalculateOT
	 * @param  param
	 * @return LGCOMData
	 */
	public LGCOMData processCalculateOT(LGCOMData param) {
		LOGGER.debug("param = " + param);
		this.commonDao.select("LGVATTCOMM.processCalculateOT",param);
		
		return param;
	}

	/**
	 * Desc : 요청서 작성 시 필요한 기본정보를 조회한다.(재량권 번호, 요청서번호)
	 * @Method Name : retrieveRequestDocBaseInfo
	 * @param  param
	 * @return LGCOMData
	 */
	public LGCOMData retrieveRequestDocBaseInfo(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.select("LGVATTCOMM.retrieveRequestDocBaseInfo",param);
	}

	/**
	 * Desc : 재량권 정보를 조회한다.
	 * @Method Name : retrieveARMInfo
	 * @param  param
	 * @return LGCOMData
	 */
	public List<LGCOMData> retrieveARMInfo(LGCOMData param) {
		LOGGER.debug("param = " + param);
		
		if ( NullUtil.notNone( param.getString("employeeNo")) ) {
			param.set( "ARM_PARAM", this.commonDao.select("LGVATTCOMM.retrieveEmployee", param));
		} else {
			param.set( "ARM_PARAM", param.get("LGVHR_PROJECT_SESSION"));
		}
		return this.commonDao.selectList("LGVATTCOMM.retrieveARMInfo",param);
	}
	
	/**
	 * Desc : 승인 정보를 조회한다.
	 * @Method Name : retrieveApproverList
	 * @param  param
	 * @return LGCOMData
	 */
	public List<LGCOMData> retrieveApproverList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		
		return this.commonDao.selectList("LGVATTCOMM.retrieveApproverList",param);
	}

	/**
	 * Desc : 월간 근태 리포트 추출
	 * @Method Name : createExcelMonthReport
	 * @param  param
	 * @return LGCOMData
	 */
	@Override
	public List<LGCOMData> createExcelMonthReport(LGCOMData param) {
		List<LGCOMData> list = LGCOMData.createList();	
		
        
        LOGGER.debug("param = " + param);
        
        List<LGCOMData> reportParam = param.getList("report");
        
        for(LGCOMData data: reportParam){
        	int sessionId = LGCOMUtils.getRandomNumber();
        	
        	data.set("sessionId", sessionId);
        	data.set("sessionUserId", ((LGCOMData)param.get("USER_SESSION")).getString("applicationUserId"));
        	data.set("subsidiaryCode", ((LGCOMData)param.get("LGVHR_PROJECT_SESSION")).getString("subsidiaryCode"));
        	data.set("timeAndAttendancdYyyymm", param.getString("timeAndAttendancdYyyymm"));
        	int resultCnt = 0;
        	if("WorkingTimeSheet".equals(data.getString("sheetName").replaceAll(" ", ""))){        		
        		resultCnt = this.commonDao.insert("LGVATTCOMM.createExcelMonthReportMain",data);
        	}else if("OT15".equals(data.getString("sheetName").replaceAll(" ", ""))){
        		resultCnt = this.commonDao.insert("LGVATTCOMM.createExcelMonthReportOt15",data);
        	}else if("OT20".equals(data.getString("sheetName").replaceAll(" ", ""))){
        		resultCnt = this.commonDao.insert("LGVATTCOMM.createExcelMonthReportOt20",data);
        	}else if("OT30".equals(data.getString("sheetName").replaceAll(" ", ""))){
        		resultCnt = this.commonDao.insert("LGVATTCOMM.createExcelMonthReportOt30",data);
        	}else if("Night20".equals(data.getString("sheetName").replaceAll(" ", ""))){
        		resultCnt = this.commonDao.insert("LGVATTCOMM.createExcelMonthReportNight20",data);
        	}else if("Night21".equals(data.getString("sheetName").replaceAll(" ", ""))){
        		resultCnt = this.commonDao.insert("LGVATTCOMM.createExcelMonthReportNight21",data);
        	}else if("Night27".equals(data.getString("sheetName").replaceAll(" ", ""))){
        		resultCnt = this.commonDao.insert("LGVATTCOMM.createExcelMonthReportNight27",data);
        	}else if("Night39".equals(data.getString("sheetName").replaceAll(" ", ""))){
        		resultCnt = this.commonDao.insert("LGVATTCOMM.createExcelMonthReportNight39",data);
        	}else if("2S-Night30+".equals(data.getString("sheetName").replaceAll(" ", ""))){
        		resultCnt = this.commonDao.insert("LGVATTCOMM.createExcelMonthReportNight30Up",data);
        	}else if("AllHRMPermission".equals(data.getString("sheetName").replaceAll(" ", ""))){
        		resultCnt = this.commonDao.insert("LGVATT60020.createExcelAllHRMPermission",data);
        	}
        	
        	
        	try {
            	LGCOMData result = new LGCOMData();
            	
            	String strSess = String.valueOf(sessionId);
            	Double doubleSessionId = Double.parseDouble(strSess);
            	LOGGER.debug("doubleSessionId : {}", doubleSessionId);
            	LOGGER.debug("doubleSessionId : {}", Double.valueOf(strSess).doubleValue());
                result.set("resultCnt", resultCnt);
                result.set("sessionId", Double.valueOf(strSess).doubleValue());
                result.set("sheetName", data.getString("sheetName"));
                list.add(result);
            } catch (Exception e) {
                LOGGER.error(e.getMessage(), e);
            }
        	
        }        
        return list;
	}
	
	/**
	 * Desc : 전달된 파라메터의 OT값과 Total OT로 계산한 OT값이 동일한지 비교
	 * @Method Name : retrieveCompareOT
	 * @param  param
	 * @return String
	 */
	public String retrieveCompareOT(LGCOMData param) {
        LGCOMData tempData = new LGCOMData();
		tempData = this.commonDao.select("LGVATTCOMM.retrieveCalculateOtParamData", param);
    	
		//요청 시 OT 체크하는 경우
		if ( !NullUtil.isNull(tempData) && "Y".equals(NullUtil.nvl(tempData.getString("otCheckFlag"), "")) ) {
        	//OT재계산
        	this.processCalculateOT(tempData);
        	
			tempData.set("itemData", param);
			//파라메터 OT값과 Total OT로 게산된 OT값 비교
			LGCOMData compareData = this.commonDao.select("LGVATTCOMM.retrieveCompareOtData", tempData);
        	
			if ( !NullUtil.isNull(compareData) && "Y".equals(compareData.getString("errorFlag")) ) {
				LOGGER.error("retrieveCompareOT ERROR(compareData)=>" + compareData);
    			LOGGER.error("retrieveCompareOT ERROR(tempData)=>" + tempData);

    			if ( NullUtil.notNone(compareData.getString("errorMessage")) ) {
    				return compareData.getString("errorMessage");
    			}
			}
		}
        return null;
	}
	
	/**
	 * Desc : 전체 조직 리스트를 벨류셋형식으로 가져온다.
	 * @Method Name : retrieveAllOrgList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveAllOrgList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVATTCOMM.retrieveAllOrgList",param);
	}


	/**
	 * Desc : 포틀릿에서 보여줄 근태 Summary 정보를 조회한다.
	 * @Method Name : retrievePortletATTSummary
	 * @param  param
	 * @return LGCOMData
	 */
	public LGCOMData retrievePortletATTSummary(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.select("LGVATTCOMM.retrievePortletATTSummary",param);
	}
}
