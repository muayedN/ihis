<%@page import="be.mxs.common.util.system.Pointer"%>
<%@page import="javax.json.JsonObject"%>
<%@page import="javax.json.Json"%>
<%@page import="javax.json.JsonReader"%>
<%@page import="be.openclinic.mobilemoney.*,be.openclinic.system.*"%>
<%
	String uid = SH.p(request,"uid");
	String status = Pointer.getPointer("mm."+uid);
%>
{
	"status":"<%=SH.c(status) %>",
	"financialTransactionId":"<%=uid.split(";")[1] %>",
	"telephone":"<%=uid.split(";")[3] %>"
}