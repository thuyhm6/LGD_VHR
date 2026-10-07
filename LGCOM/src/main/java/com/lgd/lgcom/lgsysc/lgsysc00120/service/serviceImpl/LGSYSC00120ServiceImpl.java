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
package com.lgd.lgcom.lgsysc.lgsysc00120.service.serviceImpl;

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
import com.lgd.lgcom.lgsysc.lgsysc00120.service.LGSYSC00120Service;

import devonframe.paging.model.PagingList;

/**
 * <PRE>
 * com.lgd.lgcom.lgsysc.lgsysc00120.service.serviceImpl.LGSYSC00120ServiceImpl.java
 * </PRE>
 *
 * @Author    김치민
 * @Date      2016. 5. 23. 오후 5:04:58
 * @Version
 */
@Service("LGSYSC00120Service")
public class LGSYSC00120ServiceImpl implements LGSYSC00120Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGSYSC00120ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

	/**
	 * Desc : Role에 매핑된 조직 목록을 조회한다.
	 * @Method Name : retrieveRoleOrgList
	 * @param  param
	 * @return List<?> 
	 * @throws Exception
	 */
	@SuppressWarnings({ "unchecked", "rawtypes" })
    public List<LGCOMData>  retrieveRoleOrgList( LGCOMData param ){
		LOGGER.debug("param = " + param );		

        PagingList list = new PagingList<>();
		
		if("C".equals(param.get("orgType"))){
		    list = (PagingList)this.commonDao.selectList("LGSYSC00120.retrieveRoleOrgCompList",param);
		}else if("I".equals(param.get("orgType"))){
		    list = (PagingList)this.commonDao.selectList("LGSYSC00120.retrieveRoleOrgInvList",param);
		}else if("L".equals(param.get("orgType"))){
		    list = (PagingList)this.commonDao.selectList("LGSYSC00120.retrieveRoleOrgLdgList",param);
		}else if("B".equals(param.get("orgType"))){
            //list = (PagingList)this.commonDao.selectList("LGSYSC00120.retrieveRoleOrgBuList",param);
            return this.commonDao.selectList("LGSYSC00120.retrieveRoleOrgBuList",param);
        }else if("G".equals(param.get("orgType"))){
            //list = (PagingList)this.commonDao.selectList("LGSYSC00120.retrieveRoleOrgGrpList",param);
            return this.commonDao.selectList("LGSYSC00120.retrieveRoleOrgGrpList",param);
        }else if("D".equals(param.get("orgType"))){
            list = (PagingList)this.commonDao.selectList("LGSYSC00120.retrieveRoleOrgDivList",param);
        }
		LOGGER.debug("result1 = " + list);
		String firstId = "-1";		
		int firstIndex = -1;

		Iterator<LGCOMData> it = list.iterator(); //최종 리턴 객체	
		LGCOMData row = new LGCOMData();	 //결과 리스트를 감쌀 맵객체	
        List<LGCOMData> result = LGCOMData.createList();  //실제 데이터가 들어갈 리스트
        
        while( it.hasNext() ){
        	LGCOMData item = it.next();
            if( "C".equals(param.get("orgType")) ){                              
                if(firstId.equals(item.getString("businessGroupId"))){               
                	LGCOMData child = new LGCOMData();
                    child.set("businessGroupId", "");
                    child.set("businessGroupName", "");
                    child.set("companyId", item.getString("companyId"));
                    child.set("companyName", item.getString("companyName"));
                    child.set("ynFlag", item.getString("ynFlag"));
                    ((List<LGCOMData>)(result.get(firstIndex).get("rows"))).add(child);
                }else{
                    firstIndex += 1;
                    firstId = item.getString("businessGroupId");
                    List<LGCOMData> rows = LGCOMData.createList();
                    LGCOMData parent = new LGCOMData();
                    LGCOMData child = new LGCOMData();
                    parent.set("rows", rows);
                    parent.set("businessGroupId", item.getString("businessGroupId"));
                    parent.set("businessGroupName", item.getString("businessGroupName"));
                    parent.set("companyId", "");
                    parent.set("companyName", "");
                    parent.set("ynFlag", "N");
                    result.add(parent);
                    child.set("businessGroupId", "");
                    child.set("businessGroupName", "");
                    child.set("companyId", item.getString("companyId"));
                    child.set("companyName", item.getString("companyName"));
                    child.set("ynFlag", item.getString("ynFlag"));
                    ((List<LGCOMData>)(result.get(firstIndex).get("rows"))).add(child);
                }
            }else if( "I".equals(param.get("orgType")) ){
                if(firstId.equals(item.getString("companyId"))){               
                	LGCOMData child = new LGCOMData();
                    child.set("companyId", "");
                    child.set("companyName", "");
                    child.set("invOrgId", item.getString("invOrgId"));
                    child.set("invOrgName", item.getString("invOrgName"));
                    child.set("ynFlag", item.getString("ynFlag"));
                    ((List<LGCOMData>)(result.get(firstIndex).get("rows"))).add(child);
                }else{
                    firstIndex += 1;
                    firstId = item.getString("companyId");
                    List<LGCOMData> rows = LGCOMData.createList();
                    LGCOMData parent = new LGCOMData();
                    LGCOMData child = new LGCOMData();
                    parent.set("rows", rows);
                    parent.set("companyId", item.getString("companyId"));
                    parent.set("companyName", item.getString("companyName"));
                    parent.set("invOrgId", "");
                    parent.set("invOrgName", "");
                    parent.set("ynFlag", "N");
                    result.add(parent);
                    child.set("companyId", "");
                    child.set("companyName", "");
                    child.set("invOrgId", item.getString("invOrgId"));
                    child.set("invOrgName", item.getString("invOrgName"));
                    child.set("ynFlag", item.getString("ynFlag"));
                    ((List<LGCOMData>)(result.get(firstIndex).get("rows"))).add(child);
                }
            }else if( "L".equals(param.get("orgType")) ){
                if(firstId.equals(item.getString("businessGroupId"))){               
                	LGCOMData child = new LGCOMData();
                    child.set("businessGroupId", "");
                    child.set("businessGroupName", "");
                    child.set("ledgeId", item.getString("ledgeId"));
                    child.set("ledgeName", item.getString("ledgeName"));
                    child.set("ynFlag", item.getString("ynFlag"));
                    ((List<LGCOMData>)(result.get(firstIndex).get("rows"))).add(child);
                }else{
                    firstIndex += 1;
                    firstId = item.getString("businessGroupId");
                    List<LGCOMData> rows = LGCOMData.createList();
                    LGCOMData parent = new LGCOMData();
                    LGCOMData child = new LGCOMData();
                    parent.set("rows", rows);
                    parent.set("businessGroupId", item.getString("businessGroupId"));
                    parent.set("businessGroupName", item.getString("businessGroupName"));
                    parent.set("ledgeId", "");
                    parent.set("ledgeName", "");
                    parent.set("ynFlag", "N");
                    result.add(parent);
                    child.set("businessGroupId", "");
                    child.set("businessGroupName", "");
                    child.set("ledgeId", item.getString("ledgeId"));
                    child.set("ledgeName", item.getString("ledgeName"));
                    child.set("ynFlag", item.getString("ynFlag"));
                    ((List<LGCOMData>)(result.get(firstIndex).get("rows"))).add(child);
                }
            }else if( "D".equals(param.get("orgType")) ){
                if(firstId.equals(item.getString("parentOrganizationId"))){
                	LGCOMData child = new LGCOMData();
                    child.set("organizationId", item.getString("organizationId"));
                    child.set("organizationName", item.getString("organizationName"));
                    child.set("ynFlag", item.getString("ynFlag"));
                    child.set("lvl", "2");
                    ((List<LGCOMData>)(result.get(firstIndex).get("rows"))).add(child);
                }else{
                    firstIndex += 1;
                    firstId = item.getString("parentOrganizationId");
                    List<LGCOMData> rows = LGCOMData.createList();                    
                    LGCOMData parent = new LGCOMData();
                    LGCOMData child = new LGCOMData();
                    parent.set("organizationId", item.getString("parentOrganizationId"));
                    parent.set("organizationName", item.getString("parentOrganizationName"));
                    parent.set("ynFlag", "N");
                    parent.set("lvl", "1");
                    parent.set("rows", rows);
                    result.add(parent);
                    child.set("organizationId", item.getString("organizationId"));
                    child.set("organizationName", item.getString("organizationName"));
                    child.set("ynFlag", item.getString("ynFlag"));
                    child.set("lvl", "2");
                    ((List<LGCOMData>)(result.get(firstIndex).get("rows"))).add(child);
                }
            }
        }		
 		row.set("rows", result);
		list.clear();
		list.add( row );
		
		LOGGER.debug("result2 = " + list);
		return list;
	}
	

	/**
	 * Desc : Role에 매핑된 조직을 저장한다.
	 * @Method Name : saveRoleMenuList
	 * @param  param
	 * @throws Exception
	 */
	@SuppressWarnings({ "rawtypes", "unchecked" })
	public void saveRoleOrgList(LGCOMData param){
	    LOGGER.debug("saveList = " + param);
	    
	    LGCOMData paramRoleCode =(LGCOMData)param.get("parameter");
	    
        if( "C".equals(paramRoleCode.get("orgType").toString()) || 
            "I".equals(paramRoleCode.get("orgType").toString()) ||
            "L".equals(paramRoleCode.get("orgType").toString())   ){
            this.commonDao.delete("LGSYSC00120.deleteRoleOrgList",paramRoleCode);
        }else if("B".equals(paramRoleCode.get("orgType").toString()) || 
                 "G".equals(paramRoleCode.get("orgType").toString()) ||
                 "D".equals(paramRoleCode.get("orgType").toString())   ){
            this.commonDao.delete("LGSYSC00120.deleteRoleHrOrgList",paramRoleCode);
        }

        /* 등록건 */
        List<LGCOMData> list = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_INSERT);
        
        String companyTempId = "", companyTempName = "";
        for( LGCOMData item : LGCOMUtils.emptyIfNull(list) ) {
            item.set("sessionUserId",((LGCOMData)param.get("USER_SESSION")).getString("applicationUserId"));
            item.set("roleCode",paramRoleCode.get("roleCode"));
            item.set("organizationTypeCode",paramRoleCode.get("orgType"));
            if( "L".equals(paramRoleCode.get("orgType")) || "C".equals(paramRoleCode.get("orgType")) ){
                if(item.get("businessGroupId").toString().isEmpty()){
                    this.commonDao.insert("LGSYSC00120.saveRoleOrgList", item);
                }
            }else if( "I".equals(paramRoleCode.get("orgType")) ){                                              
                if(item.get("companyId").toString().isEmpty()){
                    item.set("companyId",companyTempId);
                    item.set("companyName",companyTempName);
                    this.commonDao.insert("LGSYSC00120.saveRoleOrgList", item);
                }else{
                    companyTempId = item.get("companyId").toString();
                    companyTempName = item.get("companyName").toString();
                }
            }else if( "B".equals(paramRoleCode.get("orgType")) || "G".equals(paramRoleCode.get("orgType")) ){
                this.commonDao.insert("LGSYSC00120.saveRoleOrgList", item);
            }else if( "D".equals(paramRoleCode.get("orgType")) ){
                if( !"1".equals(item.get("lvl").toString()) ){
                    this.commonDao.insert("LGSYSC00120.saveRoleOrgList", item);
                }
            }
        }
	}
}
