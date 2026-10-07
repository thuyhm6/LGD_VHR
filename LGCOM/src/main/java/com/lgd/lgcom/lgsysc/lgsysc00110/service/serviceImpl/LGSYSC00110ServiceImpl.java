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
package com.lgd.lgcom.lgsysc.lgsysc00110.service.serviceImpl;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.util.LGCOMConstants;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgcom.lgsysc.lgsysc00110.service.LGSYSC00110Service;

import devonframe.paging.model.PagingList;

/**
 * <PRE>
 * com.lgd.lgcom.lgsysc.lgsysc00090.service.serviceImpl.LGSYSC00090ServiceImpl.java
 * </PRE>
 *
 * @Author    김치민
 * @Date      2016. 5. 23. 오후 5:04:58
 * @Version
 */
@Service("LGSYSC00110Service")
public class LGSYSC00110ServiceImpl implements LGSYSC00110Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGSYSC00110ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

	/**
	 * Desc : Role에 매핑된 menu 목록을 조회한다.
	 * @Method Name : retrieveRoleMenuList
	 * @param  param
	 * @return List<?> 
	 * @throws Exception
	 */
	@SuppressWarnings({ "unchecked", "rawtypes" })
    public List<LGCOMData>  retrieveRoleMenuList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		
		PagingList list = (PagingList)this.commonDao.selectList("LGSYSC00110.retrieveRoleMenuList",param);
		
		int firstIndex = -1;
		int secondIndex = -1;
		int thirdIndex = -1;
		
		List<LGCOMData> result = LGCOMData.createList();
		
		Iterator<LGCOMData> it = list.iterator();
		
		LGCOMData row = new LGCOMData();		
		
 		while( it.hasNext() ){
 			LGCOMData item = it.next();
            if("1".equals( item.getString("menuLevelNo") )){
                firstIndex += 1;
                secondIndex = -1;
                thirdIndex  = -1;
                List<LGCOMData> rows = LGCOMData.createList();
                item.set("rows", rows);
                result.add(item);
            }else if("2".equals( item.getString("menuLevelNo") )){
                secondIndex += 1;
                thirdIndex  = -1;
                List<LGCOMData> rows = LGCOMData.createList();
                item.set("rows", rows);
                ((List<LGCOMData>)(result.get(firstIndex).get("rows"))).add(item);
            } else if("3".equals( item.getString("menuLevelNo") )){
            	thirdIndex += 1;
                List<LGCOMData> rows = LGCOMData.createList();
                item.set("rows", rows);
                ((List<LGCOMData>)(((List<LGCOMData>)(result.get(firstIndex).get("rows"))).get(secondIndex).get("rows"))).add(item);
            } else if("4".equals( item.getString("menuLevelNo") )){
                ((List<LGCOMData>)(((List<LGCOMData>)(((List<LGCOMData>)(result.get(firstIndex).get("rows"))).get(secondIndex).get("rows"))).get(thirdIndex).get("rows"))).add(item);
            }
 		}	
		
 		row.set("rows", result);
		list.clear();
		list.add( row );
		
		LOGGER.debug("result = " + list);
		return list;
	}
	

	/**
	 * Desc : Role에 맵핑된 메뉴 목록을 저장한다.
	 * @Method Name : saveRoleMenuList
	 * @param  param
	 * @throws Exception
	 */
	@SuppressWarnings({ "rawtypes", "unchecked" })
	public void saveRoleMenuList(LGCOMData param){
		LOGGER.debug("saveList = " + param);
		
		LGCOMData paramRoleCode = new LGCOMData();	
		LGCOMData parameters = (LGCOMData)param.get("parameter");
		paramRoleCode.set("roleCode", parameters.getString("roleCode"));
		
		this.commonDao.delete("LGSYSC00110.deleteRoleMenuList",paramRoleCode);
		
		/* 등록건 */
        List<LGCOMData> cList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_INSERT);     
        
        for( LGCOMData item : LGCOMUtils.emptyIfNull( cList ) ) {
            /* 세션 사용자 정보 세팅 */
            item.set("sessionUserId",((LGCOMData)param.get("USER_SESSION")).getString("applicationUserId"));
            item.set("roleCode", parameters.get("roleCode"));
            this.commonDao.insert("LGSYSC00110.saveRoleMenuList", item);
        }
	}
}
