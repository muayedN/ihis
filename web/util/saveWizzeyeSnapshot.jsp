<%@page import="org.dom4j.*,java.io.*,java.nio.charset.StandardCharsets,org.apache.commons.httpclient.methods.multipart.*,java.nio.file.*,org.apache.commons.io.*,org.apache.commons.httpclient.*,org.apache.commons.httpclient.methods.*"%>
<%@page import="be.openclinic.system.Encryption,be.mxs.common.util.system.HTMLEntities"%>
<%@include file="/includes/helper.jsp"%>
<%
	String id=request.getParameter("id");
	String user=request.getParameter("user");
	String wizzeyeRoot = SH.cs("wizzeyeserver","https://webrtc.hnrw.org:448/room.html").substring(0,SH.cs("wizzeyeserver","https://webrtc.hnrw.org:448/room.html").lastIndexOf("/"));
	String objectUrl=wizzeyeRoot+"/getObject.html?id="+id;
	System.out.println("objectUrl = "+objectUrl);
%>
<%=sJSPROTOTYPE %>
<center>
<IMG width='300px' height='200px' id="receivedimage"/><br/>
<SPAN id='roomid'></SPAN>
</center>
<IFRAME style="display:none" id="myiframe" src="<%=objectUrl%>"></iframe>

<script>
	document.getElementById('receivedimage').height=window.innerHeight*0.5;
	document.getElementById('receivedimage').width=window.innerWidth*0.5;
	window.onmessage = function(e){
		if(e.data.snapshot){
			document.getElementById("receivedimage").src=e.data.snapshot;
			document.getElementById("roomid").innerHTML="<p/><img height='16px' src='../_img/themes/default/ajax-loader.gif'/>";
			storeData(e.data.room,e.data.snapshot,"snapshot");
		}
		else if(e.data.videorecording){
			document.getElementById("roomid").innerHTML="<p/><img height='16px' src='../_img/themes/default/ajax-loader.gif'/>";
			storeData(e.data.room,e.data.videorecording,"video");
		}
	};
	
	function storeData(roomid,imagedata,type){
	  	var url = '<c:url value="/util/storeWizzeyeData.jsp"/>?ts='+<%=getTs()%>;
	  	new Ajax.Request(url,{
	    	method: "POST",
	    	postBody: 'roomid='+roomid+
			      	  '&type='+type+
			      	  '&user=<%=user%>'+
			    	  '&id=<%=id%>'+
		          	  '&imagedata='+imagedata,
	    	onSuccess: function(resp){
				document.getElementById("roomid").innerHTML="<p/>Room = "+roomid;
	    		window.setTimeout("alert('Successfully stored');window.close();",500);
	    		//Image was successfully stored, send message back to IFRAME
	    		console.log("Successfully stored "+type+" for room "+roomid+" into OpenClinic database");
	    	}
	  	});
	}
	
</script>
