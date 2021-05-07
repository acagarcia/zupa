# Zupa
A demonstration of [Beautiful Soup](https://beautiful-soup-4.readthedocs.io/en/latest/), [Pickle](https://docs.python.org/3/library/pickle.html), and [NetworkX](https://networkx.org/) using Python in InterSystems IRIS. [Zupa ogórkowa](https://en.wikipedia.org/wiki/Pickle_soup) is a type of (beautiful) pickle soup!

Zupa is a simple web scraper which uses Beautiful Soup to traverse child links of a root URL using breadth first search. The InterSytems IRIS object database is used to persist link data and serves as a queue used by the traversal algorithm. Optionally, Pickle can be used to serialize the Beautiful Soup object for storage. **Important:** please read and abide by any relevant terms of use before storing Beautiful Soup data. Finally, a small NetworkX wrapper class can visualize the graph of URLs and their children.

## Install
1. Clone the repo
2. Load the files into IRIS
## Quick Start
* Call `Set status = ##class(PY.DocURL).Populate()` to populate the `PY.DocURL` and `PY.DocURL_SubURLs` tables. 
* Call `Do ##class(PY.Network).SaveAsPDF("SELECT ISCDocURL,SubURLs FROM PY.ISCDocURL_SubURLs",2,50,50)` to generate a PDF of the graph within `$System.Util.ManagerDirectory() _ namespace`
## Extending `PY.AbstractURL`
`PY.AbstractURL` can be extended to traverse other root URLs. For example:
1. Create a new class `PY.WikiBachURL` which extends `PY.AbstractURL`
2. Override the `ROOTURL` parameter to be `https://en.wikipedia.org/wiki/Johann_Sebastian_Bach`
3. Optionally override any of the other parameters defined in `PY.AbstractURL`. Please read an understand the terms of use of URLs you will traverse before setting `STOREURLCONTENT` to `1`, as this setting determines whether Beatiful Soup will be pickled and stored in the database
4. Override `GetURLList()` to determine how child links are selected and stored. This method should return a Python list of URLs.




