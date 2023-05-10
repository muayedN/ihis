<%@page import="org.apache.commons.httpclient.*,org.apache.commons.httpclient.methods.*,java.io.*,be.openclinic.medical.*"%>
<%@include file="/includes/helper.jsp"%>
<%!
	void checkCounter(String name, int minvalue){
		try{
			if(MedwanQuery.getInstance().getOpenclinicCounterNoIncrement(name)<minvalue){
				MedwanQuery.getInstance().getOpenclinicCounter(name, minvalue-1);
			}
		}
		catch(Exception e){
			e.printStackTrace();
		}
	}
%>
<%
	String sResult="<response type='error' message='[0.0] Undefined error'/>";
	try{
		String objecttype=request.getParameter("objecttype");
		String xml=request.getParameter("xml");
		String updateuser=request.getParameter("updateuser");
		int minid = Integer.parseInt(request.getParameter("minid"));
		if(objecttype.equalsIgnoreCase("admin")){
			AdminPerson person = AdminPerson.fromXml(xml, true);
			person.updateuserid=updateuser;
			String oldid=person.personid;
			person.personid="";
			checkCounter("PersonID",Math.max(minid,Integer.parseInt(oldid)));
			if(person.store()){
				sResult="<response type='admin' oldid='"+oldid+"' newid='"+person.personid+"'/>";
			}
		}
		else if(objecttype.equalsIgnoreCase("encounter")){
			Encounter encounter = Encounter.fromXml(xml);
			encounter.setUpdateUser(updateuser);
			String oldid=encounter.getObjectId()+"";
			encounter.setUid("");
			checkCounter("OC_ENCOUNTERS",Math.max(minid,Integer.parseInt(oldid)));
			encounter.store();
			sResult="<response type='encounter' oldid='"+oldid+"' newid='"+encounter.getObjectId()+"'/>";
		}
		else if(objecttype.equalsIgnoreCase("transaction")){
			TransactionVO transaction = TransactionVO.fromXml(xml);
			transaction.setUpdateUser(updateuser);
			String oldid=transaction.getTransactionId()+"";
			transaction.setTransactionId(-1);
			checkCounter("TransactionID",Math.max(minid,Integer.parseInt(oldid)));
			int personid=MedwanQuery.getInstance().getPersonIdFromHealthrecordId(transaction.getHealthrecordId());
			MedwanQuery.getInstance().updateTransaction(personid, transaction);
			for(int n=0;n<transaction.getAnalyses().size();n++){
				RequestedLabAnalysis a = (RequestedLabAnalysis)transaction.getAnalyses().elementAt(n);
				a.setServerId(transaction.getServerId()+"");
				a.setTransactionId(transaction.getTransactionId()+"");
				a.store();
			}
			// If the transaction contains a be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_OBJECTID item,
			// then we must keep track of the value of this item so it can be updated at a later stage.
			// store the combination personid+oldtransactionid+newtransactionid
			// later, the itemvalue must be replaced by newtransactionid for same personid and itemvalue=oldtransactionid
			// if it already exists, then do it right away, if not, place it in a queue
			
			sResult="<response type='transaction' oldid='"+oldid+"' newid='"+transaction.getTransactionId()+"'/>";
		}
		else{
			sResult="<response type='error' message='[1.0] Undefined objecttype: "+objecttype+"'/>";
		}
	}
	catch(Exception e){
		e.printStackTrace();
	}
%>
<%=sResult %>
