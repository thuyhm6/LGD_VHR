/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGCOM Project
 * @Source  : SampleService.java
 * @Desc    : 
 *
 * Copyright ⓒ 2016 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항                       
 *------------------------------------------------------------------------------
 *    VER  	DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 * 	1. 0	2016. 8. 25.  	jhpark23  	최초 프로그램 작성                                     
 *------------------------------------------------------------------------------
 */ 
package com.lgd.lgcom.common.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * <PRE>
 * com.lgd.lgcom.common.service.SampleService.java
 * </PRE>
 *
 * @Author    jhpark23
 * @Date	   2016. 8. 25. 오전 11:56:12
 * @Version   
 */
public interface ConcurrentService {

    public void updateRequestAsRead(LGCOMData param);
    
    public List<LGCOMData> retrieveUnReadRequestList(LGCOMData param);
    
    public List<LGCOMData> retrieveCachedRequestList(LGCOMData param);
}
