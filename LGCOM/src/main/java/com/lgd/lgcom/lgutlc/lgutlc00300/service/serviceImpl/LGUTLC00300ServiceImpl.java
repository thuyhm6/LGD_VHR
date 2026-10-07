/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : LGUTLC00300ServiceImpl.java
 * @Desc    :
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER       DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *    1.0   2016.08.22.      CYJ      최초 프로그램 작성                                     
 *------------------------------------------------------------------------------
 */
package com.lgd.lgcom.lgutlc.lgutlc00300.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgcom.lgutlc.lgutlc00300.service.LGUTLC00300Service;

/**
 * <PRE>
 * com.lgd.lgcom.lgutlc.lgutlc00300.service.serviceImpl.LGUTLC00300ServiceImpl.java
 * </PRE>
 *
 * @Author    CYJ
 * @Date      2016. 08. 22. 오후 1:39:58
 * @Version
 */
@Service("LGUTLC00300Service")
public class LGUTLC00300ServiceImpl implements LGUTLC00300Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGUTLC00300ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;

	/**
     * Desc : 나의 결재 승인 목록을 조회한다.
     * @Method Name : retrieveApprovalList
     * @param  param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrieveApprovalList(LGCOMData param){        
        String pStatus = param.getString("status");        
        String listName = "LGUTLC00300.retrieveApprovalPList";
        
        if( pStatus != null && !"".equals(pStatus) ){            
                
            if("P".equals(pStatus)){
                    
                listName = "LGUTLC00300.retrieveApprovalPList";
                    
            }else{
                
                listName = "LGUTLC00300.retrieveApprovalCList";
                    
            }           
            
        } else {
            
            listName = "LGUTLC00300.retrieveApprovalPList";
            
        }
        
        return this.commonDao.selectList(listName, param);
    }
    
}
