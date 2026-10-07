package com.lgd.lgvhr.lgvatt.lgvatt30080.service;

import java.util.List;

import com.lgd.lgcom.framework.exception.LGCOMException;
import com.lgd.lgcom.framework.model.LGCOMData;

public interface LGVATT30080Service {
	
	/**
	 * Special OT 요청 리스트 조회
	 * @param param
	 * @return
	 * @throws LGCOMException
	 */
	public List<LGCOMData> retrieveSpecialOtRequestList(LGCOMData param) throws LGCOMException;
	
	/**
	 * Special OT 최종 confirm
	 * @param param
	 * @return
	 * @throws LGCOMException
	 */
	public void updateSpecialOTByHR(LGCOMData param);

}
