<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                version="2.0">
    <xsl:output method="html" indent="yes"
                doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
                doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
                omit-xml-declaration="yes"/>
    <xsl:variable name="schema"
                  select="document('http://dd.eionet.europa.eu/schemas/LCP-article_72_IED/LCP-IED.xsd')/xs:schema"/>
    <xsl:variable name="labelsLanguage" select="LCPQuestionnaire/@xml:lang"/>
    <xsl:variable name="xmlPath" select="'https://svn.eionet.europa.eu/repositories/Reportnet/Dataflows/LCP-v2/xml/'"/>
    <xsl:variable name="labelsUrl">
        <xsl:choose>
            <xsl:when test="doc-available(concat($xmlPath, 'lcp-labels-', $labelsLanguage ,'.xml'))">
                <xsl:value-of select="concat($xmlPath, 'lcp-labels-', $labelsLanguage ,'.xml')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat($xmlPath, '../lcp-labels-en.xml')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="labels" select="document($labelsUrl)/labels"/>


    <xsl:template name="getLabel">
        <xsl:param name="labelName"/>
        <!--<xsl:param name="lang" select="'en'"/>-->
        <xsl:variable name="labelValue" select="$labels/*[local-name() = $labelName]"/>
        <xsl:choose>
            <xsl:when test="string-length($labelValue) &gt; 0">
                <xsl:choose>
                    <xsl:when test="contains($labelValue,'{{reportingYear}}')">
                        <xsl:value-of select="replace($labelValue,'\{\{reportingYear\}\}', string(../@year))"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of disable-output-escaping="yes" select="$labelValue"/>
                    </xsl:otherwise>
                </xsl:choose>

            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of disable-output-escaping="yes" select="$labelName"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="getValue">
        <xsl:param name="elem"/>
        <xsl:param name="elementType" select="''"/>
        <xsl:param name="colspan" select="0"/>
        <xsl:param name="isLink" select="false()"/>
        <xsl:param name="codelistElement" select="''"/>
        <xsl:variable name="elemValue">
            <xsl:choose>
                <xsl:when test="$elem/text()='yes'">Yes</xsl:when>
                <xsl:when test="$elem/text()='no'">No</xsl:when>
                <!-- detect disabled fields -->
                <xsl:otherwise>
                    <xsl:value-of select="$elem"/>
                </xsl:otherwise>

            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="string($elemValue) = 'true'">
                <xsl:call-template name="getLabel">
                    <xsl:with-param name="labelName" select="'yes'"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="string($elemValue) = 'false'">
                <xsl:call-template name="getLabel">
                    <xsl:with-param name="labelName" select="'no'"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$codelistElement='TypeOfCombustionPlant'">
                <xsl:call-template name="break">
                    <xsl:with-param name="text"
                                    select="$schema/xs:simpleType[@name = 'TypeOfCombustionPlantType']/xs:restriction/xs:enumeration[@value = $elemValue]/xs:annotation/xs:documentation"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$codelistElement='Derogation'">
                <xsl:call-template name="break">
                    <xsl:with-param name="text"
                                    select="$schema/xs:simpleType[@name = 'DerogationType']/xs:restriction/xs:enumeration[@value = $elemValue]/xs:annotation/xs:documentation"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$codelistElement='MonthValue'">
                <xsl:call-template name="break">
                    <xsl:with-param name="text"
                                    select="$schema/xs:simpleType[@name = 'MonthValueType']/xs:restriction/xs:enumeration[@value = $elemValue]/xs:annotation/xs:documentation"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$codelistElement='OtherSolidFuelsValue'">
                <xsl:call-template name="break">
                    <xsl:with-param name="text"
                                    select="$schema/xs:simpleType[@name = 'OtherSolidFuelsValueType']/xs:restriction/xs:enumeration[@value = $elemValue]/xs:annotation/xs:documentation"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$codelistElement='OtherGasesValue'">
                <xsl:call-template name="break">
                    <xsl:with-param name="text"
                                    select="$schema/xs:simpleType[@name = 'OtherGasesValueType']/xs:restriction/xs:enumeration[@value = $elemValue]/xs:annotation/xs:documentation"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$codelistElement='OtherSector'">
                <xsl:call-template name="break">
                    <xsl:with-param name="text"
                                    select="$schema/xs:simpleType[@name = 'OtherSectorType']/xs:restriction/xs:enumeration[@value = $elemValue]/xs:annotation/xs:documentation"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="break">
                    <xsl:with-param name="text" select="$elemValue"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="break">
        <xsl:param name="text" select="."/>
        <xsl:choose>

            <xsl:when test="contains($text, '&#10;')">
                <xsl:value-of select="substring-before($text, '&#10;')"/>
                <br/>
                <xsl:call-template name="break">
                    <xsl:with-param name="text" select="substring-after($text, '&#10;')"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$text"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--<xsl:template name="getLabelInCodelist" >
        <xsl:param name="labelName"/>

        <xsl:param name="schemaElementName" select="''"/>
        <xsl:param name="codelistElementName"  select="substring($schemaElementName,1,number(string-length($schemaElementName)-4))"/>
        --><!--<xsl:param name="lang" select="'en'"/>--><!--
        <xsl:variable name="codelistValue" select="$codelists/*[local-name() = $codelistElementName]/*/label[../code = $labelName]"/>
        <xsl:choose>
            <xsl:when test="string-length($codelistValue) &gt; 0">
                <xsl:value-of select="$codelistValue"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="labelValue" select="$schema/xs:simpleType[@name = $schemaElementName]//xs:enumeration[@value = $labelName]/xs:annotation/xs:documentation"/>
                <xsl:choose>
                    <xsl:when test="string-length($labelValue[1]) &gt; 0">
                        <xsl:value-of select="$labelValue"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$labelName"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>-->


    <xsl:template match="/">
        <html lang="en" xmlns="http://www.w3.org/1999/xhtml">
            <head>
                <title>
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'Questionnaire-title'"/>
                    </xsl:call-template>
                </title>
                <meta content="text/html; charset=utf-8"/>
                <style type="text/css">
                    /*@media print{@page {size: landscape}}*/
                    @page {
                    size: A4;
                    /*margin: 0;*/
                    margin-right: 0.5em;
                    margin-left: 0.5em;
                    }
                    @media print {

                    html, body {
                    width: 210mm;
                    height: 297mm;
                    }
                    @page {size: landscape}
                    table { page : rotated}
                    table{ font-size: 6pt;}
                    th { page-break-inside : avoid }
                    td { page-break-inside : avoid; white-space: pre-line;}
                    tr { page-break-inside : avoid }
                    /*.table-2{ page-break-inside : avoid}*/
                    #table-3 { display: none; !important}
                    .table-3-print{display: inherit !important}
                    /*.table-3-print{ page-break-inside : avoid !important;}*/
                    .table-3-print, .table-3-print tr , .table-3-print tr td{width: 100% !important;padding-bottom:
                    1em;}
                    .table-3-print-all, .table-3-print-all table {width: 100% !important; display: inherit !important; }
                    #table-3-main-h2{display: none !important;}
                    h2 { page-break-after : avoid }
                    @page{orphans:4; widows:2;}

                    #table-6 { display: none; !important}
                    .table-6-print{display: inherit !important; padding-bottom: 1em;}

                    th{text-align: center !important;
                    padding: 0;}
                    td{ padding: 0;}

                    }
                    /*@media print{@page {
                    -webkit-transform: rotate(-90deg); -moz-transform:rotate(-90deg);
                    filter:progid:DXImageTransform.Microsoft.BasicImage(rotation=3);
                    }*/
                    #table-3-main-h2{display: inherit;}
                    .table-3-print-all{display: none;}
                    .table-3-print{display: none;}
                    .table-6-print{display: none;}
                    body {
                    font-size: 80%;
                    font-family: verdana, helvetica, arial, sans-serif;
                    color: #333;
                    margin-left:30px;
                    }
                    h1 {
                    font-size: 160%;
                    color: #315076;
                    text-align: center;
                    padding-bottom: 0.5em;
                    font-style: italic;
                    }
                    h2 {
                    font-size: 130%;
                    border-bottom: 1px solid #999999;
                    font-style: italic;
                    margin-left:-25px;
                    }
                    h3{
                    font-size: 110%;
                    color: #315076;
                    margin-left:-25px;
                    }
                    h4{
                    font-size: 110%;
                    color: #315076;
                    margin-top: 10px;
                    margin-bottom: 5px;
                    }
                    caption {
                    display: none;
                    font-family: vardana, verdana, helvetica, arial, sans-serif;
                    text-align: left;
                    font-size: 150%;
                    }

                    table {
                    border-collapse: collapse;
                    }
                    th, td{
                    padding: 0.5em 0.5em 0.5em 0.5em;
                    text-align:left;
                    border: 1px solid #bbb;
                    }
                    th {
                    background-color: #f9f8f6;
                    text-align: left;
                    vertical-align: bottom;

                    }
                    td{
                    text-align: left;
                    vertical-align: text-top;
                    }
                    table.datatable {
                    width: 100%;
                    }

                    table.question{
                    margin-top: 13px;
                    }
                    table.question th, table.question td{
                    vertical-align: top;
                    border: none;
                    }
                    table.question th{
                    font-size: 105%;
                    color: #315076;
                    background-color: transparent;
                    padding-left: 0;
                    }
                    table.second{
                    margin-top: 5px;
                    }
                    .sub {
                    font-size: 0.8em;
                    }

                    sup {
                    font-size: 0.8em;
                    font-style: italic;
                    color: #777;
                    }
                    .note{
                    font-size: 0.8em;
                    font-weight: normal;
                    color: #315076;
                    }
                    .value {
                    background-color: #ffffe0;
                    }
                    .disabled td{
                    background-color:lightgrey;
                    }
                    .italicTableHeading{
                    font-style: italic;
                    color: black;
                    margin-left: 1em;
                    }
                    .total {
                    font-weight: bold;
                    }
                    .note{ color: darkblue;}
                    .sub-header{ font-weight: bold;
                    color: #000000;
                    font-size: larger;}
                    .padding-bottom{
                    padding-bottom: 2em;
                    }
                </style>

            </head>
            <body>
                <h1>
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'Questionnaire-title'"/>
                    </xsl:call-template>
                </h1>

                <xsl:apply-templates/>
                <div class="padding-bottom"/>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="BasicData">
        <h2>
            <xsl:call-template name="getLabel">
                <xsl:with-param name="labelName" select="'basicData'"/>
            </xsl:call-template>
        </h2>
        <table id="table-1" class="table table-hover table-bordered">
            <tbody>
                <tr>
                    <th>
                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'memberState'"/>
                        </xsl:call-template>
                    </th>
                    <td>
                        <xsl:call-template name="getValue">
                            <xsl:with-param name="elem" select="MemberState"/>
                        </xsl:call-template>
                    </td>
                </tr>
                <tr>
                    <th>
                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'referenceYear'"/>
                        </xsl:call-template>
                    </th>
                    <td>
                        <xsl:call-template name="getValue">
                            <xsl:with-param name="elem" select="ReferenceYear"/>
                        </xsl:call-template>
                    </td>
                </tr>
                <tr>
                    <th>
                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'numberOfPlants'"/>
                        </xsl:call-template>
                        <!--
                                                <div class="note">
                                                    <xsl:call-template name="getLabel">
                                                        <xsl:with-param name="labelName" select="'note1'"/>
                                                    </xsl:call-template>
                                                </div>
                        -->
                    </th>
                    <td>
                        <xsl:call-template name="getValue">
                            <xsl:with-param name="elem" select="NumberOfPlants"/>
                        </xsl:call-template>
                    </td>
                </tr>
                <tr>
                    <td colspan="2" class="sub-header">
                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'nationalContactPerson'"/>
                        </xsl:call-template>
                        <!--
                                                <div class="note" style="font-weight: lighter; font-size: 0.9em;">
                                                    <xsl:call-template name="getLabel">
                                                        <xsl:with-param name="labelName" select="'note2'"/>
                                                    </xsl:call-template>
                                                </div>
                        -->
                    </td>
                </tr>

                <tr>
                    <th>
                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'organization'"/>
                        </xsl:call-template>
                    </th>
                    <td>
                        <xsl:call-template name="getValue">
                            <xsl:with-param name="elem" select="Organization"/>
                        </xsl:call-template>
                    </td>
                </tr>
                <tr>
                    <th>
                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'address1'"/>
                        </xsl:call-template>
                    </th>
                    <td>
                        <xsl:call-template name="getValue">
                            <xsl:with-param name="elem" select="Address1"/>
                        </xsl:call-template>
                    </td>
                </tr>
                <tr>
                    <th>
                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'city'"/>
                        </xsl:call-template>
                    </th>
                    <td>
                        <xsl:call-template name="getValue">
                            <xsl:with-param name="elem" select="City"/>
                        </xsl:call-template>
                    </td>
                </tr>
                <tr>
                    <th>
                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'state'"/>
                        </xsl:call-template>
                    </th>
                    <td>
                        <xsl:call-template name="getValue">
                            <xsl:with-param name="elem" select="State"/>
                        </xsl:call-template>
                    </td>
                </tr>
                <tr>
                    <th>
                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'postalCode'"/>
                        </xsl:call-template>
                    </th>
                    <td>
                        <xsl:call-template name="getValue">
                            <xsl:with-param name="elem" select="PostalCode"/>
                        </xsl:call-template>
                    </td>
                </tr>
                <tr>
                    <th>
                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'nameOfDepartmentContactPerson'"/>
                        </xsl:call-template>
                    </th>
                    <td>
                        <xsl:call-template name="getValue">
                            <xsl:with-param name="elem" select="NameOfDepartmentContactPerson"/>
                        </xsl:call-template>
                    </td>
                </tr>
                <tr>
                    <th>
                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'phone'"/>
                        </xsl:call-template>
                    </th>
                    <td>
                        <xsl:call-template name="getValue">
                            <xsl:with-param name="elem" select="Phone"/>
                        </xsl:call-template>
                    </td>
                </tr>
                <tr>
                    <th>
                        <xsl:call-template name="getLabel">
                            <xsl:with-param name="labelName" select="'eMail'"/>
                        </xsl:call-template>
                    </th>
                    <td>
                        <xsl:call-template name="getValue">
                            <xsl:with-param name="elem" select="Email"/>
                        </xsl:call-template>
                    </td>
                </tr>
            </tbody>
        </table>
    </xsl:template>

    <xsl:template match="ListOfPlants">
        <h2>
            <xsl:call-template name="getLabel">
                <xsl:with-param name="labelName" select="'listOfPlants'"/>
            </xsl:call-template>
        </h2>
        <table id="table-2">
            <tr>
                <th rowspan="2">
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'plantName'"/>
                    </xsl:call-template>
                </th>
                <th rowspan="2">
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'plantId'"/>
                    </xsl:call-template>
                </th>
                <th rowspan="2">
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'EPRTRNationalId'"/>
                    </xsl:call-template>
                </th>
                <th colspan="5">
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'plantLocation'"/>
                    </xsl:call-template>
                </th>
                <th colspan="2">
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'geographicalCoordinate'"/>
                    </xsl:call-template>
                </th>
                <th rowspan="2">
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'facilityName'"/>
                    </xsl:call-template>
                </th>
                <th rowspan="2">
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'comments'"/>
                    </xsl:call-template>
                </th>
            </tr>
            <tr>
                <th>
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'streetName'"/>
                    </xsl:call-template>
                </th>
                <th>
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'city'"/>
                    </xsl:call-template>
                </th>
                <th>
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'region'"/>
                    </xsl:call-template>
                </th>
                <th>
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'postalCode'"/>
                    </xsl:call-template>
                </th>
                <th>
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'longitude'"/>
                    </xsl:call-template>
                </th>
                <th>
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'latitude'"/>
                    </xsl:call-template>
                </th>

            </tr>
            <xsl:for-each select="./Plant">
                <tr>
                    <td>
                        <xsl:call-template name="getValue">
                            <xsl:with-param name="elem" select="./PlantName"/>
                        </xsl:call-template>
                    </td>
                    <td>
                        <xsl:call-template name="getValue">
                            <xsl:with-param name="elem" select="./PlantId"/>
                        </xsl:call-template>
                    </td>
                    <td>
                        <xsl:call-template name="getValue">
                            <xsl:with-param name="elem" select="EPRTRNationalId"/>
                        </xsl:call-template>
                    </td>
                    <td>
                        <xsl:call-template name="getValue">
                            <xsl:with-param name="elem" select="PlantLocation/StreetName"/>
                        </xsl:call-template>
                    </td>
                    <td>
                        <xsl:call-template name="getValue">
                            <xsl:with-param name="elem" select="PlantLocation/City"/>
                        </xsl:call-template>
                    </td>
                    <td>
                        <xsl:call-template name="getValue">
                            <xsl:with-param name="elem" select="PlantLocation/Region"/>
                        </xsl:call-template>
                    </td>
                    <td>
                        <xsl:call-template name="getValue">
                            <xsl:with-param name="elem" select="PlantLocation/PostalCode"/>
                        </xsl:call-template>
                    </td>
                    <td>
                        <xsl:call-template name="getValue">
                            <xsl:with-param name="elem" select="GeographicalCoordinate/Longitude"/>
                        </xsl:call-template>
                    </td>
                    <td>
                        <xsl:call-template name="getValue">
                            <xsl:with-param name="elem" select="GeographicalCoordinate/Latitude"/>
                        </xsl:call-template>
                    </td>
                    <td>
                        <xsl:call-template name="getValue">
                            <xsl:with-param name="elem" select="FacilityName"/>
                        </xsl:call-template>
                    </td>
                    <td>
                        <xsl:call-template name="getValue">
                            <xsl:with-param name="elem" select="Comments"/>
                        </xsl:call-template>
                    </td>
                </tr>

            </xsl:for-each>
        </table>
        <div id="table-3-main-h2">
            <h2>
                <xsl:call-template name="getLabel">
                    <xsl:with-param name="labelName" select="'plantDetails'"/>
                </xsl:call-template>
            </h2>
        </div>
        <table id="table-3">
            <tr>
                <th rowspan="2">
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'plantName'"/>
                    </xsl:call-template>
                </th>
                <th rowspan="2">
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'plantId'"/>
                    </xsl:call-template>
                </th>
                <th rowspan="2">
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'MWth'"/>
                    </xsl:call-template>
                </th>
                <th rowspan="2">
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'dateOfStartOfOperation'"/>
                    </xsl:call-template>
                </th>
                <th rowspan="2">
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'refineries'"/>
                    </xsl:call-template>
                </th>
                <th rowspan="2">
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'otherSector'"/>
                        <!--<xsl:with-param name="codelistElement" select="'OtherSector'"/>-->
                    </xsl:call-template>
                </th>
                <th rowspan="2">
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'operatingHours'"/>
                    </xsl:call-template>
                </th>
                <th rowspan="2">
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'comments'"/>
                    </xsl:call-template>
                </th>
                <th colspan="2">
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'typeOfCombustionPlant'"/>
                    </xsl:call-template>
                </th>
                <th rowspan="2">
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'typeOfCombustionPlantFurtherDetails'"/>
                    </xsl:call-template>
                </th>
                <th rowspan="2">
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'Derogation'"/>
                    </xsl:call-template>
                </th>

            </tr>
            <xsl:for-each select="./Plant">
                <tr>
                    <td>
                        <xsl:call-template name="getValue">
                            <xsl:with-param name="elem" select="./PlantName"/>
                        </xsl:call-template>
                    </td>
                    <td>
                        <xsl:call-template name="getValue">
                            <xsl:with-param name="elem" select="./PlantId"/>
                        </xsl:call-template>
                    </td>
                    <td>
                        <xsl:call-template name="getValue">
                            <xsl:with-param name="elem" select="./PlantDetails/MWth"/>
                        </xsl:call-template>
                    </td>
                    <td>
                        <xsl:call-template name="getValue">
                            <xsl:with-param name="elem" select="./PlantDetails/DateOfStartOfOperation"/>
                        </xsl:call-template>
                    </td>
                    <td>
                        <xsl:call-template name="getValue">
                            <xsl:with-param name="elem" select="./PlantDetails/Refineries"/>
                        </xsl:call-template>
                    </td>
                    <td>
                        <xsl:call-template name="getValue">
                            <xsl:with-param name="elem" select="./PlantDetails/OtherSector"/>
                            <xsl:with-param name="codelistElement" select="'OtherSector'"/>
                        </xsl:call-template>
                    </td>
                    <td>
                        <xsl:call-template name="getValue">
                            <xsl:with-param name="elem" select="./PlantDetails/OperatingHours"/>
                        </xsl:call-template>
                    </td>
                    <td>
                        <xsl:call-template name="getValue">
                            <xsl:with-param name="elem" select="./PlantDetails/Comments"/>
                        </xsl:call-template>
                    </td>
                    <td>
                        <xsl:call-template name="getValue">
                            <xsl:with-param name="elem" select="./PlantDetails/TypeOfCombustionPlant"/>
                        </xsl:call-template>
                    </td>
                    <td>
                        <xsl:call-template name="getValue">
                            <xsl:with-param name="elem" select="./PlantDetails/TypeOfCombustionPlantFurtherDetails"/>
                        </xsl:call-template>
                    </td>
                    <td>
                        <xsl:call-template name="getValue">
                            <xsl:with-param name="elem" select="./PlantDetails/Derogation"/>
                        </xsl:call-template>
                    </td>
                </tr>
            </xsl:for-each>
        </table>
        <div class="table-3-print-all">
            <div style="page-break-inside: auto !important;">
                <h2>
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'plantDetails'"/>
                    </xsl:call-template>
                </h2>
                <table class="table-3-print">
                    <tr>
                        <th rowspan="2">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'plantName'"/>
                            </xsl:call-template>
                        </th>
                        <th rowspan="2">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'plantId'"/>
                            </xsl:call-template>
                        </th>
                        <th rowspan="2">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'MWth'"/>
                            </xsl:call-template>
                        </th>
                        <th rowspan="2">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'DateOfStartOfOperation'"/>
                            </xsl:call-template>
                        </th>
                        <th rowspan="2">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'Refineries'"/>
                            </xsl:call-template>
                        </th>
                        <th rowspan="2">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'OtherSector'"/>
                                <!--<xsl:with-param name="codelistElement" select="'OtherSector'"/>-->
                            </xsl:call-template>
                        </th>
                        <th rowspan="2">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'OperatingHours'"/>
                            </xsl:call-template>
                        </th>
                        <th rowspan="2">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'Comments'"/>
                            </xsl:call-template>
                        </th>
                        <th colspan="2">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'TypeOfCombustionPlant'"/>
                            </xsl:call-template>
                        </th>
                        <th rowspan="2">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'TypeOfCombustionPlantFurtherDetails'"/>
                            </xsl:call-template>
                        </th>
                        <th rowspan="2">
                            <xsl:call-template name="getLabel">
                                <xsl:with-param name="labelName" select="'Derogation'"/>
                            </xsl:call-template>
                        </th>
                    </tr>
                    <xsl:for-each select="./Plant">
                        <tr>
                            <td>
                                <xsl:call-template name="getValue">
                                    <xsl:with-param name="elem" select="./PlantName"/>
                                </xsl:call-template>
                            </td>
                            <td>
                                <xsl:call-template name="getValue">
                                    <xsl:with-param name="elem" select="./PlantId"/>
                                </xsl:call-template>
                            </td>
                            <td>
                                <xsl:call-template name="getValue">
                                    <xsl:with-param name="elem" select="./PlantDetails/MWth"/>
                                </xsl:call-template>
                            </td>
                            <td>
                                <xsl:call-template name="getValue">
                                    <xsl:with-param name="elem" select="./PlantDetails/DateOfStartOfOperation"/>
                                </xsl:call-template>
                            </td>
                            <td>
                                <xsl:call-template name="getValue">
                                    <xsl:with-param name="elem" select="./PlantDetails/Refineries"/>
                                </xsl:call-template>
                            </td>
                            <td>
                                <xsl:call-template name="getValue">
                                    <xsl:with-param name="elem" select="./PlantDetails/OtherSector"/>
                                    <!--<xsl:with-param name="codelistElement" select="'OtherSector'"/>-->
                                </xsl:call-template>
                            </td>
                            <td>
                                <xsl:call-template name="getValue">
                                    <xsl:with-param name="elem" select="./PlantDetails/OperatingHours"/>
                                </xsl:call-template>
                            </td>
                            <td>
                                <xsl:call-template name="getValue">
                                    <xsl:with-param name="elem" select="./PlantDetails/Comments"/>
                                </xsl:call-template>
                            </td>
                            <td>
                                <xsl:call-template name="getValue">
                                    <xsl:with-param name="elem" select="./PlantDetails/TypeOfCombustionPlant"/>
                                </xsl:call-template>
                            </td>
                            <td>
                                <xsl:call-template name="getValue">
                                    <xsl:with-param name="elem" select="./PlantDetails/TypeOfCombustionPlantFurtherDetails"/>
                                </xsl:call-template>
                            </td>
                            <td>
                                <xsl:call-template name="getValue">
                                    <xsl:with-param name="elem" select="./PlantDetails/Derogation"/>
                                </xsl:call-template>
                            </td>
                        </tr>
                    </xsl:for-each>
                </table>
            </div>

        </div>

        <h2>
            <xsl:call-template name="getLabel">
                <xsl:with-param name="labelName" select="'energyInputEmissions'"/>
            </xsl:call-template>
        </h2>
        <table id="table-4">
            <tr>
                <th rowspan="2">
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'plantName'"/>
                    </xsl:call-template>
                </th>
                <th rowspan="2">
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'PlantId'"/>
                    </xsl:call-template>
                </th>
                <th colspan="5">
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'energyInput'"/>
                    </xsl:call-template>
                </th>
                <th colspan="3">
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'totalEmissionsToAir'"/>
                    </xsl:call-template>
                </th>
            </tr>
            <tr>

                <th>
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'Biomass'"/>
                    </xsl:call-template>
                </th>
                <th>
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'Coal'"/>
                    </xsl:call-template>
                </th>
                <th>
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'Lignite'"/>
                    </xsl:call-template>
                </th>
                <th>
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'Peat'"/>
                    </xsl:call-template>
                </th>
                <th>
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'otherSolidFuels'"/>
                    </xsl:call-template>
                </th>
                <th>
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'liquidFuels'"/>
                    </xsl:call-template>
                </th>
                <th>
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'naturalGas'"/>
                    </xsl:call-template>
                </th>
                <th>
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'otherGases'"/>
                    </xsl:call-template>
                </th>
                <th>
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'SO2'"/>
                    </xsl:call-template>
                </th>
                <th>
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'NOx'"/>
                    </xsl:call-template>
                </th>
                <th>
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'dust'"/>
                    </xsl:call-template>
                </th>
            </tr>
            <xsl:for-each select="./Plant">
                <tr>
                    <td>
                        <xsl:call-template name="getValue">
                            <xsl:with-param name="elem" select="./PlantName"/>
                        </xsl:call-template>
                    </td>
                    <td>
                        <xsl:call-template name="getValue">
                            <xsl:with-param name="elem" select="./PlantId"/>
                        </xsl:call-template>
                    </td>

                    <td>
                        <xsl:call-template name="getValue">
                            <xsl:with-param name="elem"
                                            select="./EnergyInputAndTotalEmissionsToAir/EnergyInput/Biomass"/>
                        </xsl:call-template>
                    </td>
                    <td>
                        <xsl:call-template name="getValue">
                            <xsl:with-param name="elem"
                                            select="./EnergyInputAndTotalEmissionsToAir/EnergyInput/Coal"/>
                        </xsl:call-template>
                    </td>
                    <td>
                        <xsl:call-template name="getValue">
                            <xsl:with-param name="elem"
                                            select="./EnergyInputAndTotalEmissionsToAir/EnergyInput/Lignite"/>
                        </xsl:call-template>
                    </td>
                    <td>
                        <xsl:call-template name="getValue">
                            <xsl:with-param name="elem"
                                            select="./EnergyInputAndTotalEmissionsToAir/EnergyInput/Peat"/>
                        </xsl:call-template>
                    </td>
                    <td>
                        <xsl:call-template name="getValue">
                            <xsl:with-param name="elem"
                                            select="./EnergyInputAndTotalEmissionsToAir/EnergyInput/OtherSolidFuels/OtherSolidFuel/Value"/>
                        </xsl:call-template>
                    </td>
                    <td>
                        <xsl:call-template name="getValue">
                            <xsl:with-param name="elem"
                                            select="./EnergyInputAndTotalEmissionsToAir/EnergyInput/LiquidFuels"/>
                        </xsl:call-template>
                    </td>
                    <td>
                        <xsl:call-template name="getValue">
                            <xsl:with-param name="elem"
                                            select="./EnergyInputAndTotalEmissionsToAir/EnergyInput/NaturalGas"/>
                        </xsl:call-template>
                    </td>
                    <td>
                        <xsl:call-template name="getValue">
                            <xsl:with-param name="elem"
                                            select="./EnergyInputAndTotalEmissionsToAir/EnergyInput/OtherGases/OtherGas/Value"/>
                        </xsl:call-template>
                    </td>

                    <td>
                        <xsl:call-template name="getValue">
                            <xsl:with-param name="elem"
                                            select="./EnergyInputAndTotalEmissionsToAir/TotalEmissionsToAir/SO2"/>
                        </xsl:call-template>
                    </td>
                    <td>
                        <xsl:call-template name="getValue">
                            <xsl:with-param name="elem"
                                            select="./EnergyInputAndTotalEmissionsToAir/TotalEmissionsToAir/NOx"/>
                        </xsl:call-template>
                    </td>
                    <td>
                        <xsl:call-template name="getValue">
                            <xsl:with-param name="elem"
                                            select="./EnergyInputAndTotalEmissionsToAir/TotalEmissionsToAir/TSP"/>
                        </xsl:call-template>
                    </td>
                </tr>
            </xsl:for-each>
        </table>

        <h2>
            <xsl:call-template name="getLabel">
                <xsl:with-param name="labelName" select="'Desulphurisation'"/>
            </xsl:call-template>
        </h2>
        <table id="table-5">
            <tr>
                <th rowspan="2">
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'plantName'"/>
                    </xsl:call-template>
                </th>
                <th rowspan="2">
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'plantId'"/>
                    </xsl:call-template>
                </th>
                <th colspan="3">
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'monthValue'"/>
                    </xsl:call-template>
                </th>
                <th rowspan="2">
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'desulphurisationRate'"/>
                    </xsl:call-template>
                </th>
                <th rowspan="2">
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'sulphurContent'"/>
                    </xsl:call-template>
                </th>
                <th rowspan="2">
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'technicalJustification'"/>
                    </xsl:call-template>
                </th>
            </tr>
            <xsl:for-each select="./Plant">
                <tr>
                    <td>
                        <xsl:call-template name="getValue">
                            <xsl:with-param name="elem" select="./PlantName"/>
                        </xsl:call-template>
                    </td>
                    <td>
                        <xsl:call-template name="getValue">
                            <xsl:with-param name="elem" select="./PlantId"/>
                        </xsl:call-template>
                    </td>
                    <td>
                        <xsl:call-template name="getValue">
                            <xsl:with-param name="elem" select="./Desulphurisation/Months/Month/MonthValue"/>
                        </xsl:call-template>
                    </td>
                    <td>
                        <xsl:call-template name="getValue">
                            <xsl:with-param name="elem" select="./Desulphurisation/Months/Month/DesulphurisationRate"/>
                        </xsl:call-template>
                    </td>
                    <td>
                        <xsl:call-template name="getValue">
                            <xsl:with-param name="elem" select="./Desulphurisation/Months/Month/SulphurContent"/>
                        </xsl:call-template>
                    </td>
                    <td>
                        <xsl:call-template name="getValue">
                            <xsl:with-param name="elem" select="./Desulphurisation/Months/Month/TechnicalJustification"/>
                        </xsl:call-template>
                    </td>
                </tr>
            </xsl:for-each>
        </table>

        <h2>
            <xsl:call-template name="getLabel">
                <xsl:with-param name="labelName" select="'UsefulHeat'"/>
            </xsl:call-template>
        </h2>
        <table id="table-6">
            <tr>
                <th>
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'plantName'"/>
                    </xsl:call-template>
                </th>
                <th>
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'plantId'"/>
                    </xsl:call-template>
                </th>
                <th>
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'UsefulHeat'"/>
                    </xsl:call-template>
                </th>
            </tr>
            <xsl:for-each select="./Plant">
                <tr>
                    <td>
                        <xsl:call-template name="getValue">
                            <xsl:with-param name="elem" select="./PlantName"/>
                        </xsl:call-template>
                    </td>
                    <td>
                        <xsl:call-template name="getValue">
                            <xsl:with-param name="elem" select="./PlantId"/>
                        </xsl:call-template>
                    </td>
                    <td>
                        <xsl:call-template name="getValue">
                            <xsl:with-param name="elem" select="./UsefulHeat/UsefulHeatProportion"/>
                        </xsl:call-template>
                    </td>
                </tr>
            </xsl:for-each>
        </table>
        <table class="table-6-print">
            <tr>
                <th>
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'plantName'"/>
                    </xsl:call-template>
                </th>
                <th>
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'plantId'"/>
                    </xsl:call-template>
                </th>
                <th>
                    <xsl:call-template name="getLabel">
                        <xsl:with-param name="labelName" select="'UsefulHeat'"/>
                    </xsl:call-template>
                </th>
            </tr>
            <xsl:for-each select="./Plant">
                <tr>
                    <td>
                        <xsl:call-template name="getValue">
                            <xsl:with-param name="elem" select="./PlantName"/>
                        </xsl:call-template>
                    </td>
                    <td>
                        <xsl:call-template name="getValue">
                            <xsl:with-param name="elem" select="./PlantId"/>
                        </xsl:call-template>
                    </td>
                    <td>
                        <xsl:call-template name="getValue">
                            <xsl:with-param name="elem" select="./UsefulHeat/UsefulHeatProportion"/>
                        </xsl:call-template>
                    </td>
                </tr>
            </xsl:for-each>
        </table>
    </xsl:template>
</xsl:stylesheet>