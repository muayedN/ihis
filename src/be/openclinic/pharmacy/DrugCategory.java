package be.openclinic.pharmacy;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;

import java.util.*;
import java.sql.*;
import java.sql.Date;

import net.admin.Label;

public class DrugCategory {
    public String code="";
    public String parentcode="";
    public Vector labels=new Vector();
    public java.util.Date updatetime;
    public String updateuserid;

   public DrugCategory(){
        code = "";
        labels = new Vector();
        parentcode = "";
    }

    //--- GET LABEL -------------------------------------------------------------------------------
    public String getLabel(String language){
        Label label;
        for (int n=0;n<labels.size();n++){
            label = (Label)labels.elementAt(n);
            if (label.language.equalsIgnoreCase(language)){
                return label.value;
            }
        }
        return "";
    }

    //--- DELETE ----------------------------------------------------------------------------------
    public void delete(Connection connection){
        if (this.code!=null && this.code.length()>0){
            try {
                PreparedStatement ps = connection.prepareStatement("delete from DrugCategories where categoryid=?");
                ps.setString(1,this.code);
                ps.execute();
                ps.close();
            }
            catch (Exception e){
                e.printStackTrace();
            }
        }
    }

    public void saveToDB(){
    	try {
        	Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
        	saveToDB(conn);
			conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    }
    public boolean saveToDB(Connection connection) {
        boolean bReturn = false;
        try {
            PreparedStatement ps;
            if (this.code.trim().length()>0) {
                for (int i=0; (i<this.labels.size())&&(bReturn);i++) {
                    ((Label)(this.labels.elementAt(i))).saveToDB("drug.category",this.code);
                }

                String sSelect = "DELETE FROM DrugCategories WHERE UPPER(categoryid) = ?";
                ps = connection.prepareStatement(sSelect);
                ps.setString(1,this.code.toUpperCase());
                ps.execute();
                ps.close();

                sSelect = "INSERT INTO DrugCategories (categoryid, categoryparentid,updateuserid,updatetime)"+
                          " VALUES (?,?,?,?)";
                ps = connection.prepareStatement(sSelect);
                ps.setString(1,this.code.toUpperCase());
                ps.setString(2,this.parentcode);
                ps.setInt(3, Integer.parseInt(this.updateuserid));
                ps.setTimestamp(4,new Timestamp(new java.util.Date().getTime()));
                ps.executeUpdate();
                ps.close();
                bReturn=true;
            }
        }
        catch(SQLException e){
            e.printStackTrace();
        }

        return bReturn;
    }

    public static DrugCategory getCategory(String sCategoryID){
        if(sCategoryID==null){
            sCategoryID="NONEXISTING";
        }
        DrugCategory category = null;

    	Connection ad_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            PreparedStatement ps = ad_conn.prepareStatement(" SELECT * FROM DrugCategories WHERE categoryid = ? ");
            ps.setString(1,sCategoryID);
            ResultSet rs = ps.executeQuery();
            if (rs.next()){
            	category=new DrugCategory();
            	category.code = ScreenHelper.checkString(rs.getString("categoryid"));
                category.labels = category.getCategoryLabels();
                category.parentcode = ScreenHelper.checkString(rs.getString("categoryparentid"));

                category.updatetime = rs.getDate("updatetime");
                category.updateuserid = rs.getString("updateuserid");
            }
            rs.close();
            ps.close();
        }
        catch (Exception e){
            e.printStackTrace();
        }
        try {
			ad_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return category;
    }

    //--- GET PARENT IDS --------------------------------------------------------------------------
    public static Vector getParentIds(String childId){
        SortedSet parentIds = new TreeSet();
        String parentId;

        try{
            DrugCategory category = DrugCategory.getCategory(childId);
            if(category!=null){
                parentId = category.parentcode;
                if(parentId!=null && parentId.trim().length()>0){
                    parentIds.add(parentId);
                    parentIds.addAll(getParentIds(parentId)); // recursion
                }
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }

        // Set to Vector
        Iterator iter = parentIds.iterator();
        Vector ids = new Vector();
        while(iter.hasNext()){
            ids.add(iter.next());
        }

        Collections.reverse(ids);

        return ids;
    }

    public static Vector getParentIdsNoReverse(String childId){
        SortedSet parentIds = new TreeSet();
        String parentId;
        try{
            DrugCategory category = DrugCategory.getCategory(childId);
            if(category!=null){
                parentId = category.parentcode;
                if(parentId!=null && parentId.trim().length()>0){
                    parentIds.add(parentId);
                    if(!parentId.equalsIgnoreCase(childId)) {
                    	parentIds.addAll(getParentIds(parentId)); // recursion
                    }
                }
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }

        // Set to Vector
        Iterator iter = parentIds.iterator();
        Vector ids = new Vector();
        while(iter.hasNext()){
            ids.add(iter.next());
        }


        return ids;
    }

    //--- GET CHILD IDS ---------------------------------------------------------------------------
    public static Vector getChildIds(String parentId){
        HashSet childIds = new HashSet();
        String childId = "";
        PreparedStatement ps = null;
        ResultSet rs = null;

    	Connection ad_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            if(parentId!=null && parentId.trim().length()>0){
                childIds.add(parentId);
            }

            String sSelect = "SELECT categoryid FROM DrugCategories WHERE categoryparentid = ?";
            ps = ad_conn.prepareStatement(sSelect);
            ps.setString(1,parentId);

            rs = ps.executeQuery();
            while(rs.next()){
                childId = rs.getString("categoryid");

                if(childId!=null && childId.trim().length()>0){
                    childIds.add(childId);
                    childIds.addAll(getChildIds(childId)); // recursion
                }
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                ad_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }

        // Set to Vector
        Iterator iter = childIds.iterator();
        Vector ids = new Vector();
        while(iter.hasNext()){
            ids.add(iter.next());
        }

        return ids;
    }

    public static Vector getCategoryIDsByParentID(String sCode){
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sSelect = "SELECT categoryid FROM DrugCategories WHERE categoryparentid = ?";
        Vector vCategoryIDs = new Vector();
        String sCategoryID;

    	Connection lad_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = lad_conn.prepareStatement(sSelect);
            ps.setString(1,sCode);
            rs = ps.executeQuery();

            while(rs.next()){
                sCategoryID = ScreenHelper.checkString(rs.getString("categoryid"));
                vCategoryIDs.addElement(sCategoryID);
            }
            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                lad_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
        return vCategoryIDs;
    }

    public static Vector getCategoryIDsByText(String sWebLanguage, String sText){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vCategoryIDs = new Vector();
        String sID;


        String sQuery = "SELECT OC_LABEL_TYPE,OC_LABEL_ID FROM OC_LABELS"+
                        " WHERE "+ScreenHelper.getConfigParam("lowerCompare","OC_LABEL_TYPE")+" = 'drug.category'"+
                        "  AND "+ScreenHelper.getConfigParam("lowerCompare","OC_LABEL_LANGUAGE")+" LIKE ?"+
                        "  AND ("+ScreenHelper.getConfigParam("lowerCompare","OC_LABEL_ID")+" LIKE ?"+
                        "   OR "+ScreenHelper.getConfigParam("lowerCompare","OC_LABEL_ID")+" LIKE ?"+
                        "   OR "+ScreenHelper.getConfigParam("lowerCompare","OC_LABEL_VALUE")+" LIKE ?"+
                        "  )";

        Connection loc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = loc_conn.prepareStatement(sQuery);
            ps.setString(1,"%"+sWebLanguage.toLowerCase()+"%");
            ps.setString(2,"%"+sText.toLowerCase()+"%");
            ps.setString(3,"%"+sText.toLowerCase()+".%");
            ps.setString(4,"%"+sText.toLowerCase()+"%");
            rs = ps.executeQuery();

            while(rs.next()){
                sID = ScreenHelper.checkString(rs.getString("OC_LABEL_ID"));

                vCategoryIDs.addElement(sID);
            }
            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                loc_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
        return vCategoryIDs;
    }

    public static Vector getTopCategoryIDs(){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vCategoryIDs = new Vector();
        String sID;

        String sSelect = "SELECT categoryid FROM DrugCategories WHERE categoryparentid IS NULL OR categoryparentid = ''";

    	Connection lad_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = lad_conn.prepareStatement(sSelect);
            rs = ps.executeQuery();

            while(rs.next()){
                sID = ScreenHelper.checkString(rs.getString("categoryid"));
                vCategoryIDs.addElement(sID);
            }
            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                lad_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
        return vCategoryIDs;
    }

    public static boolean hasParentCode(String sCategoryUid,String parentCode){
        boolean hasParentCode = false;

        // parent of all external Categories is an external Category too, even when it has no parent.
        if(sCategoryUid.equalsIgnoreCase(parentCode)) return true;

        Vector parents = getParentIds(sCategoryUid.trim());
        String parentId;
        for(int i=0; i<parents.size(); i++){
            parentId = (String)parents.get(i);
            if(parentId.toLowerCase().startsWith(parentCode)){
                hasParentCode = true;
                break;
            }
        }

        return hasParentCode;
    }

    // return vector with the labels (diff. lang) for the Category
    public Vector getCategoryLabels(){
        Vector vCategoryLabels = new Vector();

        if(this.code.length() > 0){
            String supportedLanguages = ScreenHelper.getConfigString("supportedLanguages","nl,fr").toLowerCase();
            Label label;
            String tmpLang;
            StringTokenizer tokenizer = new StringTokenizer(supportedLanguages,",");
            while(tokenizer.hasMoreTokens()){
                tmpLang = tokenizer.nextToken();
                label = new Label(tmpLang,ScreenHelper.getTranNoLink("drug.category",this.code,tmpLang));
                vCategoryLabels.addElement(label);
            }
        }

        return vCategoryLabels;
    }

    public static void manageCategorySave(Hashtable hCategory){
        PreparedStatement ps = null;

        String sInsert = " INSERT INTO DrugCategories (categoryid, categoryparentid, updateuserid, updatetime)" +
                         " VALUES (?,?,?,?)";
    	Connection ad_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = ad_conn.prepareStatement(sInsert);
            ps.setString(1, hCategory.get("categoryid").toString().toUpperCase());
            ps.setString(2, hCategory.get("categoryparentid").toString());
            ps.setInt(3, Integer.parseInt(hCategory.get("updateuserid").toString()));
            ps.setTimestamp(4,(Timestamp)hCategory.get("updatetime"));
            ps.executeUpdate();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(ps!=null)ps.close();
                ad_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
    }

    public static void manageCategoryUpdate(Hashtable hCategory){
        PreparedStatement ps = null;

        String sUpdate = " UPDATE DrugCategories SET categoryid = ?, categoryparentid = ?, updateuserid = ?, updatetime = ? " +
                         " WHERE categoryid = ?";

    	Connection ad_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = ad_conn.prepareStatement(sUpdate);

            ps.setString(1, hCategory.get("categoryid").toString());
            ps.setString(2, hCategory.get("categoryparentid").toString());
            ps.setInt(3, Integer.parseInt(hCategory.get("updateuserid").toString()));
            ps.setTimestamp(4, (Timestamp)hCategory.get("updatetime"));
            ps.setString(5, hCategory.get("oldcategoryid").toString());
            ps.executeUpdate();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(ps!=null)ps.close();
                ad_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
    }
}
