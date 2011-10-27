CORBA has IDL; SOAP has WSDL. Developers often ask for similar 
capabilites for HTTP-based, "RESTful" services. While WSDL does claim
support for HTTP,  isn't well-positioned to take advantage of HTTP's 
features, nor to encourage good practice.

There are a lot of proposals in this space, but 
`WADL <http://wadl.dev.java.net/>`__ is the most mature
and capable. More thoughts 
`here <http://www.mnot.net/blog/2005/05/18/WADL>`__.

wadl_documentation.xsl is an XSL stylesheet that transforms WADL into human-readable 
documentation, one of many 
`uses of a Web description format <http://www.mnot.net/blog/2004/06/14/desc_usecases>`__.

See an example of its output at <http://mnot.github.com/wadl_stylesheets/>.

Note that `EXSLT node-set <http://www.exslt.org/exsl/functions/node-set/>`__ 
support is required, so this stylesheet will not work natively in some browsers. Try 
`Saxon <http://saxon.sourceforge.net/>`__ or 
`xsltproc <http://xmlsoft.org/XSLT/xsltproc.html>`__.

uri.xsd is a library of XML type restrictions that correspond to different 
components of a URI, so they can be accurately described (e.g., in a WADL param element).

Feedback is preferred on the 
`W3C http description list <http://lists.w3.org/Archives/Public/public-web-http-desc/>`__.
