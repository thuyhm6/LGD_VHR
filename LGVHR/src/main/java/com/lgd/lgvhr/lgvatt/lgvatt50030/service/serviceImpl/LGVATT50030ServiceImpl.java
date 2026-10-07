/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVATT50030Service.java
 * @Desc    : 연간휴가 조회
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2017. 12. 04.    bakderia    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvatt.lgvatt50030.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvatt.lgvatt50030.service.LGVATT50030Service;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvatt.lgvatt50030.controller.LGVATT50030Controller.java
 * </PRE>
 *
 * @Author    bakderia
 * @Date      2017. 12. 04. 오전 11:08:35
 * @Version
 */
@Service(value="LGVATT50030Service")
public class LGVATT50030ServiceImpl implements LGVATT50030Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVATT50030ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

	/**
	 * Desc : 연간휴가를 조회한다.
	 * @Method Name : retrieveAttendanceClose
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveAttendanceLeave(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVATT50030.retrieveAttendanceLeave",param);
	}
	
	/**
	 * Desc : 근태년월을 조회한다.
	 * @Method Name : retrieveAttendanceYyyymmNEmployeeList
	 * @param  param
	 * @return LGCOMData
	 */
	public LGCOMData retrieveAttendanceYyyymm(LGCOMData param) {
		LOGGER.debug("param = " + param);
		LGCOMData result = new LGCOMData();
		
		//현재근태년월
		result.set("currentYyyymmData", this.commonDao.select("LGVATTCOMM.retrieveCurrentYyyymm", param));
		//근태년월 리스트
		result.set("yyyymmList", this.commonDao.selectList("LGVATTCOMM.retrieveAttendanceYyyymmList",param));

		return result;
	}
	
	/**
	 * Desc : excelDownData
	 * @Method Name : excelDownData
	 * @param  param
	 * @return LGCOMData
	 * @throws Exception
	 */
    public LGCOMData excelDownData(LGCOMData param) {
        
        int sessionId = LGCOMUtils.getRandomNumber();
        param.set("sessionId", sessionId);
        LOGGER.debug("param = " + param);
        int resultCnt = this.commonDao.insert("LGVATT50030.excelDownData",param);
        
        LGCOMData result = new LGCOMData();
        result.set("resultCnt", resultCnt);
        result.set("sessionId", sessionId);
        return result;
        
    }
}
