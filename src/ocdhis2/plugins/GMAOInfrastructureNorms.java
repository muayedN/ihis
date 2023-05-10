package ocdhis2.plugins;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashSet;
import java.util.Hashtable;
import java.util.Vector;

import org.dom4j.Element;

import be.mxs.common.util.system.Debug;
import be.openclinic.system.SH;
import net.admin.Service;
import ocdhis2.DHIS2Plugin;

public class GMAOInfrastructureNorms extends DHIS2Plugin {

	@Override
	public Vector getItems(Date begin, Date end, Element dataset, Hashtable pluginParameters) {
		return null;
	}
	
	@Override
	public Vector getResults(Date begin, Date end, Element dataset, Hashtable pluginParameters) {
		Vector items = new Vector();
		try {
			Vector<String> scores = new Vector<String>();
			String rootService=SH.c((String)pluginParameters.get("organisationlevel"));
			if(rootService.length()>0) {
				String score = be.openclinic.assets.Util.getNormsScoreForService(rootService,"i",end);
				if(score.length()>0) {
					scores.add(score);
				}
				Vector children=Service.getChildIds(rootService);
				for(int n=0;n<children.size();n++){
					score = be.openclinic.assets.Util.getNormsScoreForService((String)children.elementAt(n),"i",end);
					if(score.length()>0) {
						scores.add(score);
					}
				}
			}
			int[][] results = new int[3][3];
			for(int n=0;n<scores.size();n++) {
				String score = scores.elementAt(n);
				if(score.startsWith("cds;")) {
					double d =Double.parseDouble(score.split(";")[1]);
					if(d<0.5) {
						results[0][0]++;
					}
					else if(d<0.75) {
						results[0][1]++;
					}
					else {
						results[0][2]++;
					}
				}
				else if(score.startsWith("hd;")) {
					double d =Double.parseDouble(score.split(";")[1]);
					if(d<0.5) {
						results[1][0]++;
					}
					else if(d<0.75) {
						results[1][1]++;
					}
					else {
						results[1][2]++;
					}
				}
				else if(score.startsWith("h3;")) {
					double d =Double.parseDouble(score.split(";")[1]);
					if(d<0.5) {
						results[2][0]++;
					}
					else if(d<0.75) {
						results[2][1]++;
					}
					else {
						results[2][2]++;
					}
				}
			}
			if(results[0][0]>0) items.add(results[0][0]+";1;cds");
			if(results[0][1]>0) items.add(results[0][1]+";2;cds");
			if(results[0][2]>0) items.add(results[0][2]+";3;cds");
			if(results[1][0]>0) items.add(results[1][0]+";1;hd");
			if(results[1][1]>0) items.add(results[1][1]+";2;hd");
			if(results[1][2]>0) items.add(results[1][2]+";3;hd");
			if(results[2][0]>0) items.add(results[2][0]+";1;h3");
			if(results[2][1]>0) items.add(results[2][1]+";2;h3");
			if(results[2][2]>0) items.add(results[2][2]+";3;h3");
		}
		catch(Exception e) {
			e.printStackTrace();
		}
		return items;
	}

}
