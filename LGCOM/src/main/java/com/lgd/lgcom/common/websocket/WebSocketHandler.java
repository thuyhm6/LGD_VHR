package com.lgd.lgcom.common.websocket;

import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;

public class WebSocketHandler extends TextWebSocketHandler {
	private static LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(WebSocketHandler.class);
	
	@Override
	protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
		LOGGER.debug( message.getPayload()  );
		
		LGCOMData data = new LGCOMData();
		data.set("name", "홍길동");
		session.sendMessage(new TextMessage( data.toJson() ));
	}
}
