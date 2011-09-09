<?xml version="1.0" encoding="utf-8"?>
<!-- Copyright 2011 by Chris Hubick, Athabasca University. All Rights Reserved. -->
<!-- This work is licensed under the terms of the "GNU AFFERO GENERAL PUBLIC LICENSE" version 3, as published by the Free -->
<!-- Software Foundation <http://www.gnu.org/licenses/>. -->

<!-- This XSLT will generate an HTML5 document containing links which can be used to query the REST service defined by a WADL file. -->

<!-- The output page is a stand-alone (self-contained) document which uses extensive JQuery (CDN hosted) and HTML5 form controls. -->
<!-- Output has been tested in Opera 11 (best HTML5 form support as of Jan 2011). -->
<!-- Firefox may work to some extent, but version 4 doesn't yet have complete HTML5 form control support. -->

<!-- The output should contain a method 'Index' followed by a hierarchical list of 'Forms' for each resource and it's children. -->
<!-- Following a link to a specific resource/method should highlight it with a red border for easier identification. -->
<!-- Each resource/method displays it's path URI, with method URI's being links to query the actual service. -->
<!-- Each resource/method will display a form containing links to it's parent resources, and controls for entering it's associated Path/Query params. -->
<!-- Modifying the form control for a parameter should dynamically update any references to that parameter (ie, the method link, child resources, etc) when focus is removed from the input control. -->
<!-- The parent-resource links (colored green) should allow for easier location of input controls for entering required parent resource parameter values (using the 'back' button to return). -->
<!-- Any parameter (of the form '{ParamName}') should have it's input control auto-populated by the presence of a corresponding query parameter (of the form '?ParamName=value', supplied in the URL referencing the output of this XSLT). -->
<!-- This should allow you to link others directly to a specific resource/method in the output, auto-populating it's required parameters to a determined set of values. -->
<!-- The output of this XSLT being a series of *links*, only GET methods are supported, not 'POST', etc. -->

<!-- This XSLT attempts to map the XML Schema parameter 'type' values from the WADL into their corresponding HTML5 form control types (see xs_to_input_type template) -->
<!-- Parameters using regular expressions should result in HTML5 input controls using those expressions as 'pattern' attributes. -->
<!-- WADL does not currently contain 'xs:dateTime' parameters when generated automatically, but if you manually adjust a 'type' attribute in the WADL, this XSLT should map that to an HTML5 'datetime' control. -->

<!-- Extended WADL using Javadoc to include 'doc' elements *is* supported. HTML output elements will be annotated with '[?]' yellow superscript documentation links, which, when clicked, will popup a JQuery dialog containing the corresponding Javadoc (HTML formatting supported). -->

<!-- How to utilize/apply this XSLT to your WADL? -->

<!-- You could attempt to link this XSLT directly to your WADL file with a processing instruction like: -->
<!-- <?xml-stylesheet href="wadl-links.xsl" type="text/xsl"?> -->
<!-- But that is currently broken in JQuery because of bugs ( http://bugs.jquery.com/ticket/6598 ) -->
<!-- Also, Firefox only seems to recognize it's ability to apply XSLT and display the file if renamed from .wadl to .xml. -->

<!-- On Linux, the 'libxslt' package allows application of XSLT on the command line like this: -->
<!-- xsltproc -o application-links.xhtml - -stringparam page_title 'Application Links' wadl-links.xsl application.wadl -->
<!-- (Remove the space between '- -stringparam' dashes, which would terminate this XML comment) -->

<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:wadl="http://wadl.dev.java.net/2009/02" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <xsl:output indent="yes" media-type="application/xhtml+xml" method="xml" omit-xml-declaration="no" doctype-system="about:legacy-compat" />

  <xsl:param name="page_title" select="'Application Links'" />


  <xsl:template match="@*|node()" mode="index">
    <xsl:apply-templates select="@*|node()" mode="index" />
  </xsl:template>


  <xsl:template match="@*|node()">
    <xsl:apply-templates select="@*|node()" />
  </xsl:template>


  <xsl:template match="wadl:application">
    <xsl:element name="html">

      <xsl:element name="head">

        <xsl:element name="title">
          <xsl:value-of select="$page_title" />
        </xsl:element>

        <xsl:element name="link">
          <xsl:attribute name="rel">
            <xsl:text>stylesheet</xsl:text>
          </xsl:attribute>
          <xsl:attribute name="type">
            <xsl:text>text/css</xsl:text>
          </xsl:attribute>
          <xsl:attribute name="href">
            <xsl:text>http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/themes/base/jquery-ui.css</xsl:text>
          </xsl:attribute>
        </xsl:element>

        <xsl:element name="style">
          <xsl:attribute name="type">
            <xsl:text>text/css</xsl:text>
          </xsl:attribute>
          <xsl:text>
            a.index {
              white-space: nowrap;
            }
            ol.resources, ol.methods {
              margin: 0;
              padding: 0;
              margin-left: 0.5em;
              padding-bottom: 0.5em;
              border-left-width: thin; 
              border-left-style: dotted;
              border-left-color: gray;
            }
            li.resource, li.method {
              margin: 0;
              padding: 0;
              margin-left: 0.5em;
              list-style-type: none;
            }
            form.resource_url, form.method_url {
              margin: 0;
              padding: 0;
              padding-top: 0.5em;
            }
            fieldset.resource_url, fieldset.method_url {
              border-width: thin;
              border-style: dotted;
              border-color: gray;
            }
            *:target fieldset.resource_url, *:target fieldset.method_url {
              border-width: medium;
              border-style: solid;
              border-color: red;
            }
            legend.resource_url, legend.method_url {
              white-space: normal;
            }
            span.url_form_component_param {
              white-space: nowrap;
            }
            a.resource_id_link, a.resource_id_link:link, a.resource_id_link:visited, a.method_id_link, a.method_id_link:link, a.method_id_link:visited {
              color: black;
            }
            a.url_form_component, a.url_form_component:link, a.url_form_component:visited, input.param_style_template {
              color: green;
            }
            label.url_form_component_param_label, input.param_style_query {
              color: olive;
            }
            span.url_form_divider {
              color: silver;
            }
            span.documentation {
              color: silver;
              font-family: monospace;
              font-size: smaller;
              white-space: nowrap;
              vertical-align: super;
            }
            a.documentation, a.documentation:link, a.documentation:visited {
              background-color: yellow;
              color: blue;
            }
          </xsl:text>
        </xsl:element><!-- style -->

        <xsl:element name="script">
          <xsl:attribute name="type">
            <xsl:text>text/javascript</xsl:text>
          </xsl:attribute>
          <xsl:attribute name="src">
            <xsl:text>http://ajax.googleapis.com/ajax/libs/jquery/1.4/jquery.min.js</xsl:text>
          </xsl:attribute>
        </xsl:element><!-- script -->

        <xsl:element name="script">
          <xsl:attribute name="type">
            <xsl:text>text/javascript</xsl:text>
          </xsl:attribute>
          <xsl:attribute name="src">
            <xsl:text>http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/jquery-ui.min.js</xsl:text>
          </xsl:attribute>
        </xsl:element><!-- script -->

        <xsl:call-template name="script_inline">
          <xsl:with-param name="script">
            <xsl:text><![CDATA[

function getURLQueryParam(q,s) {
  s = s ? s : window.location.search;
  var re = new RegExp('&' + q + '(?:=([^&]*))?(?=&|$)', 'i');
  return (s = s.replace(/^\?/,'&').match(re)) ? (typeof s[1] == 'undefined' ? '' : decodeURIComponent(s[1])) : undefined;
}

function compile_url_form_components(components) {
  var result = "";
  var inQuery = false;
  components.each(function(index,element) {
    var component = "";
    switch(element.tagName) {
      case "input":
        switch($(this).attr('type')) {
          case "checkbox":
            if ( (($(this).is(":checked")) && ($(this).attr('checked') != 'checked')) || (($(this).is(":checked") != true) && ($(this).attr('checked')))) {
              if ($(this).is(".param_style_query")) {
                if (inQuery) {
                  component += "&";
                } else {
                  component += "?";
                  inQuery = true;
                } 
                component += $(this).attr('name');
                component += "=";
              }
              if ($(this).is(":checked")) {
                component += "true";
              } else {
                component += "false";
              }
            }
            break;
          default:
            if (($(this).is(".param_style_template")) || ($(this).val() != $(this).html())) {
              if ($(this).is(".param_style_query")) {
                if (inQuery) {
                  component += "&";
                } else {
                  component += "?";
                  inQuery = true;
                } 
                component += $(this).attr('name');
                component += "=";
              }
              component += $(this).val() ? $(this).val() : $(this).attr('placeholder');
            }
            break;
        }
        break;
      default:
        if ((result.charAt(result.length-1) == '/') && ($(this).text().charAt(0) == '/')) {
          component += $(this).text().substring(1);
        } else {
          component += $(this).text();
        }
        break;
    }
    result += component;
    return true;
  });
  return result;
}

function update_resource_url(url_form_component) {
  var form = url_form_component.filter("form.resource_url");
  if (form.size() == 0) form = url_form_component.parents("form.resource_url:first");
  var fieldset = form.find("fieldset.resource_url:first");
  var resourceURL = compile_url_form_components(fieldset.find(".url_form_component"));
  var a = fieldset.find("a.resource_url");
  a.text(resourceURL);
  return;
}

function update_method_url(url_form_component) {
  var form = url_form_component.filter("form.method_url");
  if (form.size() == 0) form = url_form_component.parents("form.method_url:first");
  var fieldset = form.find("fieldset.method_url:first");
  var methodURL = compile_url_form_components(fieldset.find(".url_form_component"));
  form.attr('action', methodURL);
  var a = fieldset.find("a.method_url");
  a.attr('href', methodURL);
  a.text(methodURL);
  return;
}

function propagate_resource_value(url_form_component) {
  var form = url_form_component.filter("form.resource_url");
  if (form.size() == 0) form = url_form_component.parents("form.resource_url:first");
  var resourceID = form.attr("id");
  var fieldset = form.find("fieldset.resource_url:first");
  var resourceValue = compile_url_form_components(fieldset.find("a.url_form_component:not([href]), input.url_form_component"));
  var scope = form.parents("li.resource:first");
  if (scope.size() == 0) scope = form.parents("body:first");
  scope.find("a.url_form_component[href='#" + resourceID + "'] code.url_form_component_a_code").each(function(index,element) {
    $(this).text(resourceValue);
    if ($(this).parents("fieldset.resource_url:first").size() > 0) {
      update_resource_url($(this));
    } else if ($(this).parents("fieldset.method_url:first").size() > 0) {
      update_method_url($(this));
    }
    return true;
  });
  return;
}

jQuery(document).ready(function () {

  $("input.url_form_component").each(function() {
    var placeholder = $(this).attr('placeholder');
    if (!placeholder) return;
    var paramName = placeholder.substring(1, placeholder.length-1);
    var paramValue = getURLQueryParam(paramName);
    if (!paramValue) return;
    $(this).val(paramValue);
    return;
  });

  $("fieldset.resource_url input.url_form_component").change(function() {
    update_resource_url($(this));
    return;
  });

  $("fieldset.method_url input.url_form_component").change(function() {
    update_method_url($(this));
    return;
  });

  $("fieldset.resource_url input.url_form_component").change(function() {
    propagate_resource_value($(this));
    return;
  });

  $("input.url_form_component").change(); // Manually fire change events to trigger updates/propagation in case field auto-population from the query string or by the browser.

  $(".url_form_component").removeAttr("disabled"); // Default = disabled, in case of no script.

  return;
});
            ]]></xsl:text>
          </xsl:with-param>
        </xsl:call-template><!-- script_inline -->

      </xsl:element><!-- head -->

      <xsl:element name="body">
        <xsl:element name="h1">
          <xsl:value-of select="$page_title" />
        </xsl:element>
        <xsl:element name="h2">
          <xsl:text>Index</xsl:text>
        </xsl:element>
        <xsl:element name="ol">
          <xsl:attribute name="class">
            <xsl:text>index</xsl:text>
          </xsl:attribute>
          <xsl:apply-templates mode="index" />
        </xsl:element>
        <xsl:element name="h2">
          <xsl:text>Forms</xsl:text>
        </xsl:element>
        <xsl:apply-templates />
      </xsl:element><!-- body -->

    </xsl:element><!-- html -->
  </xsl:template>

  <xsl:template name="output_resource_path_value">
    <xsl:param name="path" />

    <xsl:variable name="pathBeforeParamStart" select="substring-before($path,'{')" />

    <xsl:choose>
      <xsl:when test="$pathBeforeParamStart != ''"><!-- There is a {param} in $path. -->

        <xsl:value-of select="$pathBeforeParamStart" />

        <xsl:variable name="pathFromParamStart" select="substring($path,string-length($pathBeforeParamStart)+2)" />
        <xsl:variable name="paramContent" select="substring-before($pathFromParamStart,'}')" />
        <xsl:variable name="paramName" select="substring-before(concat($paramContent,':'),':')" />

        <xsl:text>{</xsl:text>
        <xsl:value-of select="$paramName" />
        <xsl:text>}</xsl:text>

        <xsl:if test="string-length($path) > string-length($pathBeforeParamStart) + string-length($paramContent) + 2"><!-- Recursively process any remaining content in this $path after the {param}. -->
          <xsl:call-template name="output_resource_path_value">
            <xsl:with-param name="path" select="substring($path, string-length($pathBeforeParamStart) + string-length($paramContent) + 3)" />
          </xsl:call-template>
        </xsl:if>

      </xsl:when><!-- $pathBeforeParamStart != '' (There is a {param} in $path.) -->
      <xsl:otherwise><!-- No remaining {param}'s in $path, output the rest. -->

        <xsl:value-of select="$path" />

      </xsl:otherwise><!-- No remaining {param}'s in $path. -->
    </xsl:choose>

  </xsl:template>

  <xsl:template name="output_resource_path">
    <xsl:param name="normalize" select="'true'" />

    <xsl:choose>
      <xsl:when test="local-name(.) = 'resources'">
        <xsl:value-of select="@base" />
      </xsl:when>
      <xsl:when test="local-name(.) = 'resource'">
        <xsl:variable name="parentPath">
          <xsl:for-each select="..">
            <xsl:call-template name="output_resource_path">
              <xsl:with-param name="normalize" select="$normalize" />
            </xsl:call-template>
          </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="$parentPath" />
        <xsl:variable name="path">
          <xsl:choose>
            <xsl:when test="(($normalize = 'true') and (substring($parentPath, string-length($parentPath), string-length($parentPath)) = '/') and (substring(@path, 1, 1) = '/'))">
              <xsl:if test="string-length(@path) > 1">
                <xsl:value-of select="substring(@path, 2)" />
              </xsl:if>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="@path" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:call-template name="output_resource_path_value">
          <xsl:with-param name="path" select="$path" />
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:template>


  <xsl:template name="output_url_form_divider">
    <xsl:text> </xsl:text>
    <xsl:element name="span">
      <xsl:attribute name="class">
        <xsl:text>url_form_divider</xsl:text>
      </xsl:attribute>
      <xsl:text>+</xsl:text>
    </xsl:element>
    <xsl:text> </xsl:text>
  </xsl:template>


  <xsl:template name="output_url_form_component_a_code">
    <xsl:param name="text" />
    <xsl:param name="href" select="''" />

    <xsl:element name="a">
      <xsl:if test="$href != ''">
        <xsl:attribute name="href">
          <xsl:value-of select="$href" />
        </xsl:attribute>
      </xsl:if>
      <xsl:attribute name="class">
        <xsl:text>url_form_component</xsl:text>
      </xsl:attribute>
      <xsl:element name="code">
        <xsl:attribute name="class">
          <xsl:text>url_form_component_a_code</xsl:text>
        </xsl:attribute>
        <xsl:value-of select="$text" />
      </xsl:element>
    </xsl:element>
  </xsl:template>


  <xsl:template name="output_url_form_component_input">
    <xsl:param name="type" />
    <xsl:param name="name" />
    <xsl:param name="title" select="''" />
    <xsl:param name="value" select="''" />
    <xsl:param name="classSuffix" select="''" />
    <xsl:param name="placeholder" select="''" />
    <xsl:param name="pattern" select="''" />
    <xsl:param name="checked" select="''" />

    <xsl:element name="input">
      <xsl:attribute name="class">
        <xsl:text>url_form_component</xsl:text>
        <xsl:if test="$classSuffix != ''">
          <xsl:text> </xsl:text>
          <xsl:value-of select="$classSuffix" />
        </xsl:if>
      </xsl:attribute>
      <xsl:attribute name="type">
        <xsl:value-of select="$type" />
      </xsl:attribute>
      <xsl:attribute name="name">
        <xsl:value-of select="$name" />
      </xsl:attribute>
      <xsl:if test="$title != ''">
        <xsl:attribute name="title">
          <xsl:value-of select="$title" />
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="$value != ''">
        <xsl:attribute name="value">
          <xsl:value-of select="$value" />
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="($type = 'text') or ($type = 'password') or ($type = 'number') or ($type = 'url')">
        <xsl:choose>
          <xsl:when test="$value != ''">
            <xsl:attribute name="size">
              <xsl:value-of select="round(string-length($value)*1.2)" />
            </xsl:attribute>
          </xsl:when>
          <xsl:when test="$placeholder != ''">
            <xsl:attribute name="size">
              <xsl:value-of select="round(string-length($placeholder)*1.2)" />
            </xsl:attribute>
          </xsl:when>
        </xsl:choose>
      </xsl:if>
      <xsl:if test="$placeholder != ''">
        <xsl:attribute name="placeholder">
          <xsl:value-of select="$placeholder" />
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="$pattern != ''">
        <xsl:attribute name="pattern">
          <xsl:value-of select="$pattern" />
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="$checked != ''">
        <xsl:attribute name="checked">
          <xsl:value-of select="$checked" />
        </xsl:attribute>
      </xsl:if>
      <xsl:attribute name="disabled"><!-- Scripting enabled removes this at runtime. -->
        <xsl:text>disabled</xsl:text>
      </xsl:attribute>
    </xsl:element>
  </xsl:template>


  <xsl:template name="output_url_form_component_param">
    <xsl:param name="pattern" select="''" />

    <xsl:variable name="title">
      <xsl:text>{</xsl:text>
      <xsl:value-of select="@name" />
      <xsl:if test="$pattern != ''">
        <xsl:text>:</xsl:text>
        <xsl:value-of select="$pattern" />
      </xsl:if>
      <xsl:text>}</xsl:text>
    </xsl:variable>
    <xsl:variable name="classSuffix">
      <xsl:text>param_style_</xsl:text>
      <xsl:value-of select="@style" />
    </xsl:variable>

    <xsl:element name="span">
      <xsl:attribute name="class">
        <xsl:text>url_form_component_param</xsl:text>
      </xsl:attribute>

      <xsl:if test="@style = 'query'">
        <xsl:element name="label">
          <xsl:attribute name="for">
            <xsl:value-of select="@name" />
          </xsl:attribute>
          <xsl:attribute name="class">
            <xsl:text>url_form_component_param_label</xsl:text>
          </xsl:attribute>
          <xsl:element name="code">
            <xsl:attribute name="class">
              <xsl:text>url_form_component_param_label_code</xsl:text>
            </xsl:attribute>
            <xsl:value-of select="@name" />
            <xsl:text>=</xsl:text>
          </xsl:element>
        </xsl:element>
      </xsl:if>

      <xsl:choose>

        <xsl:when test="@type = 'xs:boolean'">
          <xsl:call-template name="output_url_form_component_input">
            <xsl:with-param name="type" select="'checkbox'" />
            <xsl:with-param name="name" select="@name" />
            <xsl:with-param name="title" select="$title" />
            <xsl:with-param name="classSuffix" select="$classSuffix" />
            <xsl:with-param name="checked">
              <xsl:if test="@default = 'true'">
                <xsl:text>checked</xsl:text>
              </xsl:if>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:when><!-- @type = 'xs:boolean' -->

        <xsl:otherwise>
          <xsl:call-template name="output_url_form_component_input">
            <xsl:with-param name="type">
              <xsl:call-template name="xs_to_input_type">
                <xsl:with-param name="type" select="@type" />
              </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="name" select="@name" />
            <xsl:with-param name="title" select="$title" />
            <xsl:with-param name="classSuffix" select="$classSuffix" />
            <xsl:with-param name="placeholder">
              <xsl:text>{</xsl:text>
              <xsl:value-of select="@name" />
              <xsl:text>}</xsl:text>
            </xsl:with-param>
            <xsl:with-param name="pattern" select="$pattern" />
          </xsl:call-template>
        </xsl:otherwise><!-- @type = ? -->

      </xsl:choose><!-- @type -->

    </xsl:element><!-- span.url_form_param -->

  </xsl:template>


  <xsl:template name="output_url_form_resource_path_component">
    <xsl:param name="path" />
    <xsl:param name="base_uri" select="'false'" />
    <xsl:param name="mode" select="'leaf'" />

    <xsl:variable name="href">
      <xsl:if test="$mode = 'parent'">
        <xsl:text>#</xsl:text>
        <xsl:call-template name="encode_id">
          <xsl:with-param name="text">
            <xsl:call-template name="output_resource_path">
              <xsl:with-param name="normalize" select="'false'" />
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>

    <xsl:choose>

      <xsl:when test="(($base_uri = 'true') and ($mode = 'leaf'))">
        <xsl:call-template name="output_url_form_component_input">
          <xsl:with-param name="type" select="'url'" />
          <xsl:with-param name="name" select="'base'" />
          <xsl:with-param name="value" select="$path" />
        </xsl:call-template>
      </xsl:when><!-- (($base_uri = 'true') and ($mode = 'leaf')) -->

      <xsl:when test="(($base_uri = 'true') and ($mode = 'parent'))">
        <xsl:call-template name="output_url_form_component_a_code">
          <xsl:with-param name="text" select="$path" />
          <xsl:with-param name="href" select="$href" />
        </xsl:call-template>
      </xsl:when><!-- (($base_uri = 'true') and ($mode = 'parent')) -->

      <xsl:when test="$mode = 'leaf'">
        <xsl:variable name="pathBeforeParamStart" select="substring-before($path,'{')" />

        <xsl:choose>

          <xsl:when test="$pathBeforeParamStart != ''"><!-- There is a {param} in $path. -->

            <xsl:call-template name="output_url_form_component_a_code">
              <xsl:with-param name="text" select="$pathBeforeParamStart" />
            </xsl:call-template>
            <xsl:call-template name="output_url_form_divider" />

            <xsl:variable name="pathFromParamStart" select="substring($path,string-length($pathBeforeParamStart)+2)" />
            <xsl:variable name="paramContent" select="substring-before($pathFromParamStart,'}')" />
            <xsl:variable name="paramName" select="substring-before(concat($paramContent,':'),':')" />
            <xsl:variable name="paramPattern" select="substring-after($paramContent,':')" />

            <xsl:choose>
              <xsl:when test="wadl:param[@style='template'][@name=$paramName]"><!-- A wsdl:param element exists for this $paramName. -->
                <xsl:for-each select="wadl:param[@style='template'][@name=$paramName]">
                  <xsl:call-template name="output_url_form_component_param">
                    <xsl:with-param name="pattern" select="$paramPattern" />
                  </xsl:call-template>
                </xsl:for-each>
                <xsl:apply-templates select="wadl:param[@style='template'][@name=$paramName]" />
              </xsl:when>
              <xsl:otherwise><!-- No wsdl:param element exists for this $paramName, possibly a wildcard regex kinda thing. -->
                <xsl:call-template name="output_url_form_component_input">
                  <xsl:with-param name="type" select="'text'" />
                  <xsl:with-param name="name" select="$paramName" />
                  <xsl:with-param name="title">
                    <xsl:text>{</xsl:text>
                    <xsl:value-of select="$paramContent" />
                    <xsl:text>}</xsl:text>
                  </xsl:with-param>
                  <xsl:with-param name="classSuffix" select="param_style_template" />
                  <xsl:with-param name="placeholder">
                    <xsl:text>{</xsl:text>
                    <xsl:value-of select="$paramName" />
                    <xsl:text>}</xsl:text>
                  </xsl:with-param>
                  <xsl:with-param name="pattern" select="$paramPattern" />
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>

            <xsl:if test="string-length($path) > string-length($pathBeforeParamStart) + string-length($paramContent) + 2"><!-- Recursively process any remaining content in this $path after the {param}. -->
              <xsl:call-template name="output_url_form_divider" />
              <xsl:call-template name="output_url_form_resource_path_component">
                <xsl:with-param name="path" select="substring($path, string-length($pathBeforeParamStart) + string-length($paramContent) + 3)" />
              </xsl:call-template>
            </xsl:if>

          </xsl:when><!-- $pathBeforeParamStart != '' (There is a {param} in $path.) -->

          <xsl:otherwise><!-- No remaining {param}'s in $path, output the rest. -->
            <xsl:call-template name="output_url_form_component_a_code">
              <xsl:with-param name="text" select="$path" />
            </xsl:call-template>
          </xsl:otherwise><!-- No remaining {param}'s in $path. -->

        </xsl:choose>

      </xsl:when><!-- $mode = 'leaf' -->

      <xsl:when test="$mode = 'parent'">
        <xsl:call-template name="output_url_form_component_a_code">
          <xsl:with-param name="text" select="$path" />
          <xsl:with-param name="href" select="$href" />
        </xsl:call-template>
      </xsl:when><!-- $mode = 'parent' -->

    </xsl:choose>

  </xsl:template>


  <xsl:template name="output_url_form_resource_path_components">
    <xsl:param name="mode" select="'leaf'" />

    <xsl:choose>

      <xsl:when test="local-name(.) = 'resources'">

        <xsl:call-template name="output_url_form_resource_path_component">
          <xsl:with-param name="path" select="@base" />
          <xsl:with-param name="base_uri" select="'true'" />
          <xsl:with-param name="mode" select="$mode" />
        </xsl:call-template>

      </xsl:when>

      <xsl:when test="local-name(.) = 'resource'">

        <xsl:for-each select="..">
          <xsl:call-template name="output_url_form_resource_path_components">
            <xsl:with-param name="mode" select="'parent'" />
          </xsl:call-template>
        </xsl:for-each>

        <xsl:call-template name="output_url_form_divider" />

        <xsl:call-template name="output_url_form_resource_path_component">
          <xsl:with-param name="path" select="@path" />
          <xsl:with-param name="mode" select="$mode" />
        </xsl:call-template>

      </xsl:when>

    </xsl:choose>

  </xsl:template>


  <xsl:template name="sub_resources">
    <xsl:if test="wadl:resource">
      <xsl:element name="ol">
        <xsl:attribute name="class">
          <xsl:text>resources</xsl:text>
        </xsl:attribute>
        <xsl:apply-templates select="wadl:resource" />
      </xsl:element>
    </xsl:if>
  </xsl:template>


  <xsl:template match="wadl:resources">
    <xsl:call-template name="output_resource_url_form" />
    <xsl:call-template name="sub_resources" />
  </xsl:template>


  <xsl:template name="output_resource_url_form">
    <xsl:variable name="resourceID">
      <xsl:call-template name="encode_id">
        <xsl:with-param name="text">
          <xsl:call-template name="output_resource_path">
            <xsl:with-param name="normalize" select="'false'" />
          </xsl:call-template>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>

    <xsl:element name="form">
      <xsl:attribute name="id">
        <xsl:value-of select="$resourceID" />
      </xsl:attribute>
      <xsl:attribute name="class">
        <xsl:text>resource_url</xsl:text>
      </xsl:attribute>

      <xsl:element name="fieldset">
        <xsl:attribute name="class">
          <xsl:text>resource_url</xsl:text>
        </xsl:attribute>

        <xsl:element name="legend">
          <xsl:attribute name="class">
            <xsl:text>resource_url</xsl:text>
          </xsl:attribute>

          <xsl:element name="a">
            <xsl:attribute name="href">
              <xsl:text>#</xsl:text>
              <xsl:value-of select="$resourceID" />
            </xsl:attribute>
            <xsl:attribute name="class">
              <xsl:text>resource_id_link</xsl:text>
            </xsl:attribute>
            <xsl:choose>
              <xsl:when test="local-name(.) = 'resources'">
                <xsl:text>Base</xsl:text>
              </xsl:when>
              <xsl:when test="local-name(.) = 'resource'">
                <xsl:text>Resource</xsl:text>
              </xsl:when>
            </xsl:choose>
          </xsl:element><!-- a.resource_id_link -->

          <xsl:for-each select="wadl:doc">
            <xsl:call-template name="output_doc_link" />
          </xsl:for-each>

          <xsl:if test="local-name(.) = 'resource'">
            <xsl:text>: </xsl:text>
            <xsl:element name="a">
              <xsl:attribute name="class">
                <xsl:text>resource_url</xsl:text>
              </xsl:attribute>
              <xsl:call-template name="output_resource_path" />
            </xsl:element>
          </xsl:if>

        </xsl:element><!-- legend.resource_url -->

        <xsl:call-template name="output_url_form_resource_path_components">
          <xsl:with-param name="mode" select="'leaf'" />
        </xsl:call-template>

      </xsl:element><!-- fieldset.resource_url -->

    </xsl:element><!-- form.resource_url -->

  </xsl:template>


  <xsl:template match="wadl:resource">
    <xsl:element name="li">
      <xsl:attribute name="class">
        <xsl:text>resource</xsl:text>
      </xsl:attribute>
      <xsl:call-template name="output_resource_url_form" />
      <xsl:if test="wadl:method[@name='GET']">
        <xsl:element name="ol">
          <xsl:attribute name="class">
            <xsl:text>methods</xsl:text>
          </xsl:attribute>
          <xsl:apply-templates select="wadl:method[@name='GET']" />
        </xsl:element>
      </xsl:if>
      <xsl:call-template name="sub_resources" />
    </xsl:element><!-- li.resource -->
  </xsl:template>


  <xsl:template match="wadl:method[@name='GET']">
    <xsl:variable name="methodID">
      <xsl:call-template name="encode_id">
        <xsl:with-param name="text">
          <xsl:for-each select="..">
            <xsl:call-template name="output_resource_path">
              <xsl:with-param name="normalize" select="'false'" />
            </xsl:call-template>
          </xsl:for-each>
          <xsl:text>#</xsl:text>
          <xsl:value-of select="@id" />
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="href">
      <xsl:for-each select="..">
        <xsl:call-template name="output_resource_path" />
      </xsl:for-each>
    </xsl:variable>

    <xsl:element name="li">
      <xsl:attribute name="id">
        <xsl:value-of select="$methodID" />
      </xsl:attribute>
      <xsl:attribute name="class">
        <xsl:text>method</xsl:text>
      </xsl:attribute>

      <xsl:element name="form">
        <xsl:attribute name="method">
          <xsl:text>GET</xsl:text>
        </xsl:attribute>
        <xsl:attribute name="action">
          <xsl:value-of select="$href" />
        </xsl:attribute>
        <xsl:attribute name="class">
          <xsl:text>method_url</xsl:text>
        </xsl:attribute>

        <xsl:element name="fieldset">
          <xsl:attribute name="class">
            <xsl:text>method_url</xsl:text>
          </xsl:attribute>

          <xsl:element name="legend">
            <xsl:attribute name="class">
              <xsl:text>method_url</xsl:text>
            </xsl:attribute>
            <xsl:element name="a">
              <xsl:attribute name="href">
                <xsl:text>#</xsl:text>
                <xsl:value-of select="$methodID" />
              </xsl:attribute>
              <xsl:attribute name="class">
                <xsl:text>method_id_link</xsl:text>
              </xsl:attribute>
              <xsl:text>Method &apos;</xsl:text>
              <xsl:value-of select="@id" />
              <xsl:text>&apos;</xsl:text>
            </xsl:element>
            <xsl:for-each select="wadl:doc">
              <xsl:call-template name="output_doc_link" />
            </xsl:for-each>
            <xsl:text>: </xsl:text>
            <xsl:element name="a">
              <xsl:attribute name="class">
                <xsl:text>method_url</xsl:text>
              </xsl:attribute>
              <xsl:attribute name="href">
                <xsl:value-of select="$href" />
              </xsl:attribute>
              <xsl:attribute name="target">
                <xsl:text>_blank</xsl:text>
              </xsl:attribute>
              <xsl:value-of select="$href" />
            </xsl:element>
          </xsl:element><!-- legend -->

          <xsl:for-each select="..">
            <xsl:call-template name="output_url_form_resource_path_components">
              <xsl:with-param name="mode" select="'parent'" />
            </xsl:call-template>
          </xsl:for-each>

          <xsl:if test="wadl:request/wadl:param[@style='query']">
            <xsl:for-each select="wadl:request/wadl:param[@style='query']">
              <xsl:call-template name="output_url_form_divider" />
              <xsl:call-template name="output_url_form_component_param" />
              <xsl:for-each select="wadl:doc">
                <xsl:call-template name="output_doc_link" />
              </xsl:for-each>
            </xsl:for-each>
          </xsl:if>

        </xsl:element><!-- fieldset.method_url -->

      </xsl:element><!-- form.method_url -->

    </xsl:element><!-- li.method -->

  </xsl:template>


  <xsl:template match="wadl:method[@name='GET']" mode="index">
    <xsl:variable name="methodID">
    </xsl:variable>
    <xsl:variable name="href">
      <xsl:for-each select="..">
        <xsl:call-template name="output_resource_path" />
      </xsl:for-each>
    </xsl:variable>

    <xsl:element name="li">
      <xsl:attribute name="class">
        <xsl:text>index</xsl:text>
      </xsl:attribute>

      <xsl:element name="a">
        <xsl:attribute name="href">
          <xsl:text>#</xsl:text>
          <xsl:call-template name="encode_id">
            <xsl:with-param name="text">
              <xsl:for-each select="..">
                <xsl:call-template name="output_resource_path">
                  <xsl:with-param name="normalize" select="'false'" />
                </xsl:call-template>
              </xsl:for-each>
              <xsl:text>#</xsl:text>
              <xsl:value-of select="@id" />
            </xsl:with-param>
          </xsl:call-template>
        </xsl:attribute>
        <xsl:attribute name="title">
          <xsl:value-of select="@id" />
        </xsl:attribute>
        <xsl:attribute name="class">
          <xsl:text>index</xsl:text>
        </xsl:attribute>
        <xsl:for-each select="..">
          <xsl:call-template name="output_resource_path" />
        </xsl:for-each>
      </xsl:element><!-- a.index -->

    </xsl:element><!-- li.index -->

  </xsl:template>


  <xsl:template name="output_doc_link">
    <xsl:variable name="enc1">
      <xsl:call-template name="replace">
        <xsl:with-param name="txt" select="." />
        <xsl:with-param name="in">
          <xsl:text>&apos;</xsl:text>
        </xsl:with-param>
        <xsl:with-param name="out">
          <xsl:text>\&apos;</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="enc2">
      <xsl:call-template name="replace">
        <xsl:with-param name="txt" select="$enc1" />
        <xsl:with-param name="in">
          <xsl:text>&#10;</xsl:text>
        </xsl:with-param>
        <xsl:with-param name="out">
          <xsl:text>\n</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="enc3">
      <xsl:call-template name="replace">
        <xsl:with-param name="txt" select="$enc2" />
        <xsl:with-param name="in">
          <xsl:text>&#13;</xsl:text>
        </xsl:with-param>
        <xsl:with-param name="out">
          <xsl:text>\r</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>

    <xsl:element name="span">
      <xsl:attribute name="class">
        <xsl:text>documentation</xsl:text>
      </xsl:attribute>
      <xsl:text>[</xsl:text>
      <xsl:element name="a">
        <xsl:attribute name="class">
          <xsl:text>documentation</xsl:text>
        </xsl:attribute>
        <xsl:attribute name="href">
          <xsl:text>#</xsl:text>
        </xsl:attribute>
        <xsl:attribute name="title">
          <xsl:text>Documentation</xsl:text>
        </xsl:attribute>
        <xsl:attribute name="onclick">
          <xsl:text>$('&lt;div /&gt;').html('</xsl:text>
          <xsl:value-of select="$enc3" />
          <xsl:text>').dialog({ title: 'Documentation', modal: true, autoOpen: true, width: 800, height: 600 });</xsl:text>
          <xsl:text> return false;</xsl:text>
        </xsl:attribute>
        <xsl:text>?</xsl:text>
      </xsl:element>
      <xsl:text>]</xsl:text>
    </xsl:element>
  </xsl:template>


  <xsl:template name="script_inline">
    <xsl:param name="script" />
    <xsl:element name="script">
      <xsl:attribute name="type">
        <xsl:text>text/javascript</xsl:text>
      </xsl:attribute>
      <xsl:text disable-output-escaping="yes">&#x0A;// &lt;![CDATA[&#x0A;</xsl:text>
      <xsl:value-of select="$script" disable-output-escaping="yes" />
      <xsl:text>&#x0A;// ]]</xsl:text>
      <xsl:text disable-output-escaping="yes">&gt;&#x0A;</xsl:text>
    </xsl:element>
  </xsl:template>


  <xsl:template name="xs_to_input_type">
    <xsl:param name="type" />
    <xsl:choose>
      <xsl:when test="($type = 'xs:string')">
        <xsl:text>text</xsl:text>
      </xsl:when>
      <xsl:when test="($type = 'xs:boolean')">
        <xsl:text>checkbox</xsl:text>
      </xsl:when>
      <xsl:when test="($type = 'xs:duration')">
        <xsl:text>datetime</xsl:text>
      </xsl:when>
      <xsl:when test="($type = 'xs:dateTime')">
        <xsl:text>datetime</xsl:text>
      </xsl:when>
      <xsl:when test="($type = 'xs:time')">
        <xsl:text>time</xsl:text>
      </xsl:when>
      <xsl:when test="($type = 'xs:date')">
        <xsl:text>date</xsl:text>
      </xsl:when>
      <xsl:when test="($type = 'xs:gYearMonth')">
        <xsl:text>month</xsl:text>
      </xsl:when>
      <xsl:when test="($type = 'xs:decimal') or ($type = 'xs:float') or ($type = 'xs:double') or ($type = 'xs:integer') or ($type = 'xs:nonPositiveInteger') or ($type = 'xs:negativeInteger') or ($type = 'xs:long') or ($type = 'xs:int') or ($type = 'xs:short') or ($type = 'xs:byte') or ($type = 'xs:nonNegativeInteger') or ($type = 'xs:unsignedLong') or ($type = 'xs:unsignedInt') or ($type = 'xs:unsignedShort') or ($type = 'xs:unsignedByte') or ($type = 'xs:positiveInteger')">
        <xsl:text>number</xsl:text>
      </xsl:when>
      <xsl:when test="($type = 'xs:anyURI')">
        <xsl:text>url</xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>


  <!-- Create a valid XML ID value from the text input. -->
  <xsl:template name="encode_id">
    <xsl:param name="text" />

    <xsl:variable name="ascii-chars">
      <xsl:text>!&quot;#$%&amp;&apos;()*+,-./0123456789:;&lt;=&gt;?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~&#127;</xsl:text>
    </xsl:variable>
    <xsl:variable name="valid-chars">
      <xsl:text>-.0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz</xsl:text>
    </xsl:variable>
    <xsl:variable name="hex-chars">
      <xsl:text>0123456789ABCDEFabcdef</xsl:text>
    </xsl:variable>

    <xsl:if test="$text">
      <xsl:variable name="first-char" select="substring($text,1,1)" />
      <xsl:choose>
        <xsl:when test="($first-char = '_') and (string-length($text) &gt;= 3) and (contains($hex-chars, substring($text,2,1))) and (contains($hex-chars, substring($text,3,1)))">
          <xsl:value-of select="$first-char" />
        </xsl:when>
        <xsl:when test="contains($valid-chars, $first-char)">
          <xsl:value-of select="$first-char" />
        </xsl:when>
        <xsl:when test="not(contains($ascii-chars, $first-char))">
          <xsl:value-of select="$first-char" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="ascii-value" select="string-length(substring-before($ascii-chars, $first-char)) + 32" />
          <xsl:text>_</xsl:text>
          <xsl:value-of select="substring($hex-chars, floor($ascii-value div 16) + 1,1)" />
          <xsl:value-of select="substring($hex-chars, $ascii-value mod 16 + 1, 1)" />
        </xsl:otherwise>
      </xsl:choose>

      <xsl:call-template name="encode_id">
        <xsl:with-param name="text" select="substring($text,2)" />
      </xsl:call-template>
    </xsl:if>
  </xsl:template>


  <!-- Given param 'txt' replace all occurrences of 'in' text with 'out' text -->
  <xsl:template name="replace">
    <xsl:param name="txt" />
    <xsl:param name="in" />
    <xsl:param name="out" />
    <xsl:choose>
      <xsl:when test="contains($txt,$in)">
        <xsl:value-of select="concat(substring-before($txt,$in),$out)" />
        <xsl:call-template name="replace">
          <xsl:with-param name="txt" select="substring-after($txt,$in)" />
          <xsl:with-param name="in" select="$in" />
          <xsl:with-param name="out" select="$out" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$txt" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


</xsl:stylesheet>

