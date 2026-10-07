/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVATT20010ServiceImpl.java
 * @Desc    : 사무직 월 근태 캘린더
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2017. 10. 17.    limsjin    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvatt.lgvatt20010.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvatt.lgvatt20010.service.LGVATT20010Service;

import devonframe.util.NullUtil;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvatt.lgvatt20010.service.serviceImpl.LGVATT20010ServiceImpl.java
 * </PRE>
 *
 * @Author    limsjin
 * @Date	  2017. 10. 17. 오후 3:48:12
 * @Version
 */
@Service("LGVATT20010Service")
public class LGVATT20010ServiceImpl implements LGVATT20010Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVATT20010ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;
	
	/**
	 * Desc : 조직리스트를 조회한다. 조직책임자는 조직책임자 하위부서 리스트, 부서원은 소속부서
	 * @Method Name : retrieveOrgList
	 * @param  param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveOrgList(LGCOMData param) {
		return this.commonDao.selectList("LGVATT20010.retrieveOrgList", param);
	}

	/**
	 * Desc : 근태년월 목록과 부서원 목록을 조회한다.
	 * @Method Name : retrieveAttendanceYyyymmNEmployeeList
	 * @param  param
	 * @return LGCOMData
	 */
	public LGCOMData retrieveAttendanceYyyymmNEmployeeList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		LGCOMData result = new LGCOMData();
		//현재근태년월
		result.set("currentYyyymmData", this.commonDao.select("LGVATTCOMM.retrieveCurrentYyyymm", param));
		//근태년월 리스트
		result.set("yyyymmList", this.commonDao.selectList("LGVATTCOMM.retrieveAttendanceYyyymmList",param));
		//조직 리스트
		result.set("orgList", this.commonDao.selectList("LGVATT20010.retrieveOrgList", param));
		//부서원 리스트
		result.set("employeeList", this.commonDao.selectList("LGVATT20010.retrieveOrgEmployeeList", param));
		//로그인 사용자 본인정보 조회
		result.set( "employeeData", this.commonDao.select("LGVATTCOMM.retrieveEmployee", param));
		
		return result;
	}
	
	/**
	 * Desc : 근태년월에 따른 근태일자를 조회한다.
	 * @Method Name : retrievAttendanceDateList
	 * @param param
	 * @return List<LGCOMData>
	 */
	public List<LGCOMData> retrieveAttendanceDateList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVATT20010.retrieveAttendanceDateList",param);
	}
	
	/**
	 * Desc : 근태년월의 개인 일별 계획/실적 근태, 근태Summary를 조회한다.
	 * @Method Name : retrieveAttendancePlanNResultList
	 * @param  param
	 * @return LGCOMData
	 */
	public LGCOMData retrieveAttendancePlanNResultList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		LGCOMData result = new LGCOMData();
		
		if ( retrieveEmployeeEnableFlag(param) ) {
			result.set("attendPlanNResultList", this.commonDao.selectList("LGVATT20010.retrieveAttendancePlanNResultList", param));
			result.set("attendSummaryData", this.commonDao.select("LGVATT20010.retrieveMonthlyAttendanceSummaryData", param));
		}
		
		return result;
	}
	
	/**
	 * Desc : 해당 사번에 대한 조회권한이 있는지 체크한다.
	 * @Method Name : retrieveEmployeeEnableFlag
	 * @param  param
	 * @return LGCOMData
	 */
	public boolean retrieveEmployeeEnableFlag(LGCOMData param) {
		LOGGER.debug("param = " + param);
		//전달된 사번이 있는 경우 체크
		if ( NullUtil.notNone(param.getString("employeeNo")) ) {
			param.set( "checkEmployeeNo", param.getString("employeeNo") );

			LGCOMData result = this.commonDao.select("LGVATT20010.retrieveOrgEmployeeList", param);
			
			if ( !NullUtil.isNull(result) && param.getString("checkEmployeeNo").equals(result.getString("code")) ) {
				return true;
			} else {
				return false;
			}
		} else {
			return true;
		}
	}
	
	/**
	 * Desc : 2018.03.12 [베트남 급여근태 고도화] Let's에서 호출된 경우 팝업 호출가능한 상태인지 판단한다.
	 * @Method Name : retireveDirectOpenData
	 * @param  param
	 * @return LGCOMData
	 */
	public LGCOMData retireveDirectOpenData(LGCOMData param) {
		return this.commonDao.select("LGVATT20010.retireveDirectOpenData", param);
	}

}
