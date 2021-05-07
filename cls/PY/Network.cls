Class PY.Network [ Abstract ]
{

ClassMethod SaveAsPDF(sqlText As %String, figScale As %Integer = 1, figSizeX As %Integer = 10, figSizeY As %Integer = 10, file As %String = "graph") [ Language = python ]
{
	import iris
	import networkx as nx
	import matplotlib.pyplot as plt
	
	G = nx.Graph()
	stmt = iris.sql.prepare(sqlText)
	rs = stmt.execute()
	for idx, row in enumerate(rs):
		G.add_edge(row[0],row[1])
		
	pos = nx.spring_layout(G, scale=figScale)
	plt.figure(figsize=(figSizeX,figSizeY))
	nx.draw(G, pos, with_labels=False, font_weight='bold',width=2)
	
	plt.savefig(file+".pdf")
	plt.clf()
}

}

