<%@page import="org.apache.commons.httpclient.*,org.apache.commons.httpclient.methods.*"%>
<%@page import="be.openclinic.mobilemoney.*,be.openclinic.system.*,be.mxs.common.util.db.*"%>
<%@include file="/includes/helper.jsp"%>

<%
	String sStatus="cancel";
	String sUid=SH.p(request,"uid");	
	String sInvoiceUid = sUid.split(";")[1];
	String sAmount = sUid.split(";")[2];
	String sPhoneNumber = sUid.split(";")[3];
	String uid=Base64.getEncoder().encodeToString(sUid.getBytes());
	HttpClient client = new HttpClient();
	String url = SH.cs("orangeMoneyURL","");
	PostMethod method = new PostMethod(url);
	method.setRequestHeader("Content-type","text/xml; charset=windows-1252");
	//*******************************************************
	//Todo: choose parameters to send to OrangeMoney API here
	//*******************************************************
	NameValuePair nvp1= new NameValuePair("callbacksuccess",SH.cs("orangeMoneySuccessCallbackURL","")+"&uid="+uid);
	NameValuePair nvp2= new NameValuePair("callbackfailure",SH.cs("orangeMoneyFailureCallbackURL","")+"&uid="+uid);
	NameValuePair nvp3= new NameValuePair("amount",sAmount);
	NameValuePair nvp4= new NameValuePair("phonenumber",sPhoneNumber);
	NameValuePair nvp5= new NameValuePair("merchantcode",SH.cs("orangeMoneyMerchantCode",""));
	method.setQueryString(new NameValuePair[]{nvp1,nvp2,nvp3,nvp4,nvp5});
	int statusCode = client.executeMethod(method);
	if(statusCode==200){
		sStatus="ok";
	}
	String sError=method.getResponseBodyAsString();
	SH.syslog("OrangeMoney API call result: "+statusCode+" => "+sError.trim());
%>
{
	"status":"<%=sStatus %>",
	"transactionId":"<%=sInvoiceUid %>"
}
