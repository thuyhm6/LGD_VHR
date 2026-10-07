/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGSYSC00090ServiceImpl.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2016. 5. 31. rlaclskfk    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgsysc.lgsysc00090.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.util.LGCOMConstants;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.exception.LGCOMException;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgcom.lgsysc.lgsysc00090.service.LGSYSC00090Service;

/**
 * <PRE>
 * com.lgd.lgcom.lgsysc.lgsysc00090.service.serviceImpl.LGSYSC00090ServiceImpl.java
 * </PRE>
 *
 * @Author    rlaclskfk
 * @Date      2016. 5. 23. 오후 5:04:58
 * @Version
 */
@Service("LGSYSC00090Service")
public class LGSYSC00090ServiceImpl implements LGSYSC00090Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGSYSC00090ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

	/**
	 * Desc : Role 목록을 조회한다.
	 * @Method Name : retrieveRoleList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveRoleList(LGCOMData param){
		LOGGER.debug("param = " + param);

		return this.commonDao.selectList("LGSYSC00090.retrieveRoleList",param);
	}

	/**
     * Desc :  Role Code 중복체크 한다.
     * @Method Name : retrieveRoleCode
     * @param  param
     * @throws Exception
     */
    public boolean retrieveRoleCode(LGCOMData param){
        LOGGER.debug("param = " + param);
        boolean result = false;
        LGCOMData temp = this.commonDao.select("LGSYSC00090.retrieveRoleCode", param);
        int count = temp.getInt("cnt");
        LOGGER.debug("result = " + temp);
        if(count > 0){
            result = true;
        }else{
            result = false;
        }
        return result;
    }

	/**
	 * Desc : Role 목록을 저장한다.
	 * @Method Name : saveRoleList
	 * @param  param
	 * @throws Exception
	 */
	@SuppressWarnings({ "rawtypes", "unchecked" })
	public void saveRoleList(LGCOMData param){
		LOGGER.debug("param = " + param);
		LGCOMData userSession = (LGCOMData)param.get("USER_SESSION");
		
		List<LGCOMData> sList = LGCOMData.createList();
		
		/* 등록건 */
		List<LGCOMData> cList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_INSERT);
		for( LGCOMData item : LGCOMUtils.emptyIfNull(cList)) {
			LGCOMData map = this.commonDao.select("LGSYSC00090.retrieveRoleCode",item);
            if(map.getInt("cnt") > 0) {
                throw new LGCOMException("error.duplicateValue");
            }
			/* 세션 사용자 정보 세팅 */
			item.set("sessionUserId", userSession.getString("applicationUserId") );
			sList.add(item);
		}
		
		/* 수정건 */
		List<LGCOMData> uList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_UPDATE);
		
		for( LGCOMData item : LGCOMUtils.emptyIfNull(cList)) {
			item.set("sessionUserId", userSession.getString("applicationUserId") );
			sList.add(item);
		}
		
		/* 전체 저장건 */
		for( LGCOMData item : LGCOMUtils.emptyIfNull(sList)) {
			this.commonDao.update("LGSYSC00090.mergeRoleInfo", item );
		}
	}

	/**
	 * Desc :  선택된 Role을 물리적으로 삭제한다.
	 * @Method Name : deleteRoleCodePhysical
	 * @param  param
	 * @throws Exception
	 */
	public void deleteRoleCodePhysical(LGCOMData param) {
		LOGGER.debug("param = " + param);
		this.commonDao.delete("LGSYSC00090.deleteRoleMenuMaster",param);
		this.commonDao.delete("LGSYSC00090.deleteUserRoleInfo",param);
		this.commonDao.delete("LGSYSC00090.deleteRoleBizOrgInfo",param);
		this.commonDao.delete("LGSYSC00090.deleteRoleHrmOrgInfo",param);
		this.commonDao.delete("LGSYSC00090.deleteProgramAccessInfo",param);
        this.commonDao.delete("LGSYSC00090.deleteCodeTypeCodeAccessInfo",param);
		this.commonDao.delete("LGSYSC00090.deleteRoleMaster",param);
	}
}
