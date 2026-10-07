/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : LGVPAY00010ServiceImpl.java
 * @Desc    : Payment Master by Employee
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2017. 12. 21.  	limsujin  	최초 프로그램 작성                                     
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvpay.lgvpay00010.service.serviceImpl;

import javax.annotation.Resource;

import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.exception.LGCOMException;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvpay.lgvpay00010.service.LGVPAY00010Service;
import com.lgd.lgvhr.lgvpay.lgvpaycomm.service.LGVPAYCOMMService;

import devonframe.util.NullUtil;
import devonframe.util.StringUtil;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpay00010.service.serviceImpl.LGVPAY00010ServiceImpl.java
 * </PRE>
 *
 * @Author    limsujin
 * @Date      2017. 12. 21.
 * @Version
 */
@Service("LGVPAY00010Service")
public class LGVPAY00010ServiceImpl implements LGVPAY00010Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVPAY00010ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;
	
    @Resource(name="messageSourceAccessor")
    protected MessageSourceAccessor messageSourceAccessor;
    
    @Resource(name="LGVPAYCOMMService")
    private LGVPAYCOMMService lgvpaycomm;

	/**
	 * Desc : payment master 정보를 조회한다.
	 * @Method Name : retrievePaymentMasterData
	 * @param  param
	 * @return LGCOMData
	 * @throws Exception
	 */
	public LGCOMData retrievePaymentMasterData(LGCOMData param) {
		return commonDao.select("LGVPAY00010.retrievePaymentMasterData", param);
    }
    
    /**
     * Desc : payment master 저장 전 체크 
     * - 급여담당자 권한이 있는지 체크
     * - employeeNo 필수값 체크
     * 
     * @Method Name : validateUpdatePaymentBasicData
     * @param param
     * @return boolean
     * @throws Exception
     */
    public boolean validateUpdatePaymentBasicData(LGCOMData param) {
    	boolean validateFlag = false;
    	
    	validateFlag = lgvpaycomm.retrievePayMasterAuthFlag(param); 
    	if ( !validateFlag ) {//급여담당자 권한이 없는 경우
    		throw new LGCOMException(messageSourceAccessor.getMessage("note.NoPermission"));
    		
    	} else {
    		if ( NullUtil.isNone(param.getString("employeeNo")) ) {
    			validateFlag = false;
            	throw new LGCOMException(messageSourceAccessor.getMessage("error.required", StringUtil.split(messageSourceAccessor.getMessage("label.pay.employeeNo"), "")));
            	
    		}
    	}
    	return validateFlag;
    }
    
    /**
     * Desc : payment master 저장 
     * - 급여담당자 권한이 있는지 체크
     * - employeeNo 필수값 체크
     * - 값 수정
     * 
     * @Method Name : updatePaymentBasicData
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
	@Transactional(propagation=Propagation.REQUIRED)
    public LGCOMData updatePaymentBasicData(LGCOMData param) {
		
    	if ( validateUpdatePaymentBasicData(param) ) {//값 체크 정상인 경우 처리
    		//값 수정
    		this.commonDao.select("LGVPAY00010.updatePaymentBasicData", param);
    	}
    	return param;
    }
}
