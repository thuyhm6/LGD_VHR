package com.lgd.lgvhr.lgvatt.lgvatt20040.service.serviceImpl;

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
import com.lgd.lgvhr.lgvatt.lgvatt20040.service.LGVATT20040Service;

@Service(value="LGVATT20040Service")
public class LGVATT20040ServiceImpl implements LGVATT20040Service {
	protected final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVATT20040ServiceImpl.class);
	
	/*@Resource(name="tnxManager")
    protected CompositeDataSourceTransactionManager tnxManager;*/

	@Resource(name="commonDao")
	CommonDao commonDao; 

	@Resource(name="messageSourceAccessor")
    protected MessageSourceAccessor messageSourceAccessor;
	
	/**
	 * Desc : 
	 * @Method Name : executeUserInterface
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	@Override
	public List<LGCOMData> retrieveLWAttList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVATT20040.retrieveLWAttList",param);
	}
	
	@Transactional(propagation=Propagation.REQUIRED)
	public void updateLWAttPlanActualList(LGCOMData param) throws LGCOMException{
		LOGGER.debug("param = " + param);
		
		String systemCode = LGCOMUtils.getValueFromProjectProperties("systemCodeU");
        String projectSessionName = systemCode+"_PROJECT_SESSION";//프로젝트 세션명
        LGCOMData userSession = (LGCOMData)param.get(LGCOMConstants.HTTP_SESSION_KEY);
        LGCOMData projectSession = (LGCOMData)param.get(projectSessionName);
        
		/* 수정건 저장 */
        @SuppressWarnings("unchecked")
		List<LGCOMData> modifyList = (List<LGCOMData>)param.get("modifyList");
        
        for( LGCOMData item : LGCOMUtils.emptyIfNull( modifyList ) ) {
        	item.set("applicationUserId",userSession.getString("applicationUserId"));
        	item.set("sessionAppUserId",userSession.getString("applicationUserId"));
        	item.set("attType", "INPUT");
        	item.set("subsidiaryCode",projectSession.getString("subsidiaryCode"));
        	item.set("languageCode",userSession.getString("languageCode"));
        	item.set("attendanceYyyymmdd", item.getString("planDate"));
        	item.set("empCat","LGD_LW"); // HR 담당자 입력화면에서 입력 될 경우에도 사무직/기능직 관계없이 LGD_LW로 파라미터 넘김.
        	item.set("newInputPlanAttCode",item.getString("planAttendanceDetail"));
        	item.set("newInputResultAttCode",item.getString("actualAttendanceDetail"));
        	
        	LOGGER.debug("item = " + item);
        	
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
        	
            this.commonDao.update("LGVATT20040.updateLWAttPlanList",item);
            this.commonDao.update("LGVATT20040.updateLWAttActualList",item);
            
        	/*if( ("AL".equals(item.getString("planAttendanceDetail")) || "AL".equals(item.getString("actualAttendanceDetail"))) ||
        			("AL".equals(item.getString("actualAttendanceDetail")) || "AL".equals(item.getString("originalAttCode"))) ) {
            */
             /* 2018.02.28 : 반일 휴가 추가로 HL 코드 도 조건에 넣음
              * 실적, 계획, 이전에 입력된 코드중 하나라도 AL 이거나 HL이면 연차 관련 로직을 태움 
              */
             if ( "AL".equals(item.getString("planAttendanceDetail"))||"AL".equals(item.getString("actualAttendanceDetail")) ||"AL".equals(item.getString("originalAttCode")) ||
            	  "HL".equals(item.getString("planAttendanceDetail"))||"HL".equals(item.getString("actualAttendanceDetail")) ||"HL".equals(item.getString("originalAttCode")) ||
            	  "HL_FN".equals(item.getString("planAttendanceDetail"))||"HL_FN".equals(item.getString("actualAttendanceDetail")) ||"HL_FN".equals(item.getString("originalAttCode")) ||
            	  "HL_SN".equals(item.getString("planAttendanceDetail"))||"HL_SN".equals(item.getString("actualAttendanceDetail")) ||"HL_SN".equals(item.getString("originalAttCode"))
                ) {
	        	this.commonDao.select("LGVATTCOMM.retrieveValidateAnualLeave", item);
	        	LOGGER.debug("retCode = " + item.getInt("retCode"));
	        	if(item.getInt("retCode") < 0) {
	        		LOGGER.debug("errorMessage = " + messageSourceAccessor.getMessage(item.getString("errorMessage")) );
	        		throw new LGCOMException( messageSourceAccessor.getMessage(item.getString("errorMessage")) );
	        	}
        	}
        }
	}

	/**
	 * Desc : 
	 * @Method Name : isEnableAttendInput
	 * @param  param
	 * @return LGCOMData
	 * @throws Exception
	 */
	@Override
	public LGCOMData isEnableAttendInput(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.select("LGVATT20040.isEnableAttendInput",param);
	}
	
	/**
	 * Desc : isillegalAtt
	 * @Method Name : isillegalAtt
	 * @param  param
	 * @return LGCOMData
	 * @throws Exception
	 */
	@Override
	public LGCOMData isillegalAtt(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.select("LGVATT20040.isillegalAtt",param);
	}
}
