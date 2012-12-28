<?xml version="1.0"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
  >

<!--

	Copyright (c) 2005, Gregory D. Fast
	All rights reserved.

	Redistribution and use in source and binary forms, with or without
	modification, are permitted provided that the following conditions
	are met:

			* Redistributions of source code must retain the above copyright
				notice, this list of conditions and the following disclaimer.

			* Redistributions in binary form must reproduce the above copyright
				notice, this list of conditions and the following disclaimer in the
				documentation and/or other materials provided with the distribution.

	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
	"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
	LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
	A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
	OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
	SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
	TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
	PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
	LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
	NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

-->
  
  <xsl:output method="html" />

  <xsl:template match="/testsuite">
    <html>
      <head>
	<title>Test Suite Results for <xsl:value-of select="@name" /></title>
	<style>
	  .error { color: #ff0000; }
	  .eresult {
	    background: #ffcccc;
	    color: #ff0000;
	  }
	  h1,h2 {
	    background: #cccccc;
	    color: #000055;
	    border: 1px dotted black;
	  }
	</style>
      </head>
      <body>
	<h1>Test Suite Results</h1>

	<p>Results for: <xsl:value-of select="@name" /></p>
	
	<p>
	  Test suite run at: <b><xsl:value-of select="@rundate" /></b>
	</p>

	<h2>Summary</h2>
	
	<p>
	  <xsl:if test="result[@passed = 'false']">
	    <xsl:attribute name="class">error</xsl:attribute>
	  </xsl:if>
	  <xsl:value-of select="result/summary/text()" />
	</p>
	<p>
	  Elapsed time: <xsl:value-of select="elapsed-time/text()" />
	</p>

	<table border="1">
	  <tr>
	    <th>Case</th>
	    <th>Result</th>
	  </tr>
	  <xsl:for-each select="test">
	    <tr>
	      <td>
		<xsl:if test="fault/text()">
		  <xsl:attribute name="class">error</xsl:attribute>
		</xsl:if>
		<xsl:value-of select="@name" />
	      </td>
	      <td>
		<xsl:choose>
		  <xsl:when test="fault/text()">
		    <xsl:attribute name="class">eresult</xsl:attribute>
		    <pre>
		      <xsl:value-of select="fault/text()" />
		    </pre>
		  </xsl:when>
		  <xsl:otherwise>
		    (pass)
		  </xsl:otherwise>
		</xsl:choose>
	      </td>
	    </tr>
	  </xsl:for-each>
	</table>
      </body>
    </html>
  </xsl:template>

</xsl:stylesheet>
