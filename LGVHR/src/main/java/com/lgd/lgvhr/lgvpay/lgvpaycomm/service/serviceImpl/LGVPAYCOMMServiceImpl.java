/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAYCOMMService.java
 * @Desc    : 급여 공통
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2017. 12. 13.  	limsujin  	최초 프로그램 작성                                     
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvpay.lgvpaycomm.service.serviceImpl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.service.UserService;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvpay.lgvpaycomm.service.LGVPAYCOMMService;

import devonframe.util.NullUtil;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpaycomm.service.serviceImpl.LGVPAYCOMMServiceImpl.java
 * </PRE>
 *
 * @Author    limsujin
 * @Date      2017. 12. 13.
 * @Version
 */
@Service("LGVPAYCOMMService")
public class LGVPAYCOMMServiceImpl implements LGVPAYCOMMService {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVPAYCOMMServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

    @Resource(name="userService")
    private UserService userService;

	/**
	 * Desc : 주어진 조건에 따라 사용자 정보를 조회한다.
	 * @Method Name : retrieveEmployee
	 * @param  param
	 * @return LGCOMData
	 */
	public LGCOMData retrieveEmployee(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.select("LGVPAYCOMM.retrieveEmployee",param);
	}
    
    /**
     * 급여담당자 권한이 있는지 여부 조회
     * 
     * @param param.employeeNo
     * @return boolean
     */
    public boolean retrievePayMasterAuthFlag(LGCOMData param) {
    	//authGroup
    	boolean validateFlag = false;
    	
		LGCOMData paramData = (LGCOMData)param.clone();//세션 사번으로 체크하기 위해 param 객체를 복사한다.
		paramData.set( "employeeNo", "" );//세션 사번으로 체크하기 위해 null로 셋팅
    	
    	LGCOMData employeeData = this.retrieveEmployee(paramData);//application_user_id 조회
    	paramData.set( "employeeRoleList", userService.retrieveUserRoleList(employeeData) );
    	
		//권한코드에 급여담당자 권한코드가 있는지 확인
		LGCOMData result = this.commonDao.select("LGVPAYCOMM.retrievePayMasterAuthFlag", paramData);
		
		if ( !NullUtil.isNull(result) && "Y".equals(result.getString("authFlag")) ) {
			validateFlag = true;
		}
    	return validateFlag;
    }
    
    /**
     * 급여 시스템담당자 권한이 있는지 여부 조회
     * 
     * @param param.employeeNo
     * @return boolean
     */
    public boolean retrievePaySystemMasterAuthFlag(LGCOMData param) {
    	//authGroup
    	boolean validateFlag = false;
    	
		LGCOMData paramData = (LGCOMData)param.clone();//세션 사번으로 체크하기 위해 param 객체를 복사한다.
		paramData.set( "employeeNo", "" );//세션 사번으로 체크하기 위해 null로 셋팅
    	
    	LGCOMData employeeData = this.retrieveEmployee(paramData);//application_user_id 조회
    	paramData.set( "employeeRoleList", userService.retrieveUserRoleList(employeeData) );
    	
		//권한코드에 급여담당자 권한코드가 있는지 확인
		LGCOMData result = this.commonDao.select("LGVPAYCOMM.retrievePaySystemMasterAuthFlag", paramData);
		
		if ( !NullUtil.isNull(result) && "Y".equals(result.getString("authFlag")) ) {
			validateFlag = true;
		}
    	return validateFlag;
    }
    
}
