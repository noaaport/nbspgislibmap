Overview
========

The Nbsp GIS Map library is a collection of C programs, scripts and
auxiliary files and templates for producing image maps from a variety
of radar (NIDS) and satellite (GINI,GOESR) data files received via NOAAPort.
It uses the programs of the
`NbspGISlib library
<https://bitbucket.org/noaaport/nbspgislib>`_
to convert the data to the appropriate gis formats and then process the
resulting files using *mapserver*.

The wiki has some examples about usage.

Latest News - 10 Feb 2025
=========================

The current version adds support for the goesr sat files (nbspglgoesrmap tool)
which in turn uses the new programs (nbspgoesr, nbspgoesrinfo and
nbspgoesrgis) available in the nbsp package (and also independently
in the nbspgislib package).

News - 18 Jan 2015
==================

Binary packages for FreeBSD-10.1, Ubuntu-14.04 and CentOS-6.6 are available
in the Downloads section.

News  - 18 Jan 2015
===================

The new version  supports *Storm relative velocity* products
(e.g. N1S), as shown in this `example
<http://www.noaaport.net/examples/gis/n1slvx>`_.

News  - 03 Jan 2015
===================

The new version  supports *Storm precipitation accumulation* products
(e.g. N1P), as shown in this `example
<http://www.noaaport.net/examples/gis/n1plvx>`_.
