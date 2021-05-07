/// Class describing the structure of persistent data used to store scraped meta-data and content.
Class PY.AbstractURL Extends %Persistent [ Abstract, NoExtent ]
{

Parameter ROOTURL;

Parameter STOREURLCONTENT = 0;

Parameter MAXPROCESSCOUNT = 1000;

Parameter TARGETHANGMS = 100;

Parameter VARIABILITYHANGMS = 50;

Parameter LONGHANGSEC = 5;

Parameter LONGHANGPERCENTCHANCE = 1;

Property URL As %String(MAXLEN = "") [ Required ];

Property Soup As PY.Pickle;

Property SubURLs As list Of %Persistent(SQLPROJECTION = "table/column", STORAGEDEFAULT = "array");

Property IsProcessed As %Boolean [ InitialExpression = 0, Required ];

Index URL On URL [ Unique ];

Index IsProcessed On IsProcessed [ Type = bitmap ];

ClassMethod Populate() As %Status
{
	Quit ##class(PY.URLTraverser).Traverse(..#ROOTURL,$classname(),..#STOREURLCONTENT,..#MAXPROCESSCOUNT,..#TARGETHANGMS,..#VARIABILITYHANGMS,..#LONGHANGSEC,..#LONGHANGPERCENTCHANCE)
}

ClassMethod GetURLList(soup As %SYS.Python) [ Language = python ]
{
	return []
}

}

