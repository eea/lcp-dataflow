<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0" xmlns:office="http://openoffice.org/2000/office"
                xmlns:table="http://openoffice.org/2000/table" xmlns:text="http://openoffice.org/2000/text" xmlns:xs="http://www.w3.org/2001/XMLSchema">
    <xsl:output method="xml"/>
    <!--
        $Id$
    -->
    <xsl:param name="xml_folder_uri"/>
    <xsl:variable name="language">en</xsl:variable>
    <xsl:variable name="labels" select="document('https://svn.eionet.europa.eu/repositories/Reportnet/Dataflows/LCP/xml/lcp-labels-en.xml')/labels"/>


    <xsl:variable name="codelists" select="document('https://svn.eionet.europa.eu/repositories/Reportnet/Dataflows/LCP/xml/languages/lcp-codelists-en.xml')/LCPCodelists"/>
    <!--<xsl:variable name="schema" select="document('https://svn.eionet.europa.eu/repositories/Reportnet/Dataflows/IPPC-WI-Directive/schemas/dir20081ec_schema.xsd')/xs:schema"/>
    --><xsl:variable name="heading" select="'Questionnaire on the implementation of LCP'" />
    <xsl:template match="/LCPQuestionnaire">
        <office:document-content xmlns:office="http://openoffice.org/2000/office"
                                 xmlns:table="http://openoffice.org/2000/table" office:version="1.0"
                                 xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:number="http://openoffice.org/2000/datastyle"
                                 xmlns:text="http://openoffice.org/2000/text" xmlns:fo="http://www.w3.org/1999/XSL/Format"
                                 xmlns:style="http://openoffice.org/2000/style">
            <office:automatic-styles>
                <style:style style:name="row-height" style:family="table-cell">
                    <style:properties  style:row-height="2cm" />
                </style:style>
                <style:style style:name="string-cell" style:family="table-cell">
                    <style:properties fo:text-align="left"
                                      fo:font-size="10pt" style:column-width="5cm" />
                </style:style>
                <style:style style:name="long-string-cell" style:family="table-cell">
                    <style:properties fo:text-align="left"
                                      fo:font-size="10pt" style:column-width="15cm" />
                </style:style>
                <style:style style:name="number-cell" style:family="table-cell">
                    <style:properties fo:text-align="right"
                                      fo:font-size="10pt" style:column-width="5cm" />
                </style:style>
                <style:style style:name="long-number-cell" style:family="table-cell">
                    <style:properties fo:text-align="right"
                                      fo:font-size="10pt" style:column-width="10cm" />
                </style:style>
                <style:style style:name="total-number-cell" style:family="table-cell">
                    <style:properties fo:text-align="right" fo:font-weight="bold"
                                      fo:font-size="10pt" style:column-width="5cm" />
                </style:style>
                <style:style style:name="string-heading" style:family="table-cell">
                    <style:properties fo:text-align="left"
                                      fo:font-size="10pt" style:column-width="5cm" fo:font-weight="bold" style:row-height="2cm" />
                </style:style>
                <style:style style:name="long-string-heading" style:family="table-cell">
                    <style:properties fo:text-align="left"
                                      fo:font-size="10pt" style:column-width="10cm" fo:font-weight="bold" />
                </style:style>
                <style:style style:name="cell1" style:family="table-cell">
                    <style:properties fo:text-align="left"
                                      fo:font-size="10pt" style:column-width="5cm" />
                </style:style>
                <style:style style:name="cell2" style:family="table-cell">
                    <style:properties fo:text-align="center"
                                      fo:font-size="12pt" fo:font-style="italic" style:column-width="5cm" />
                </style:style>

                <style:style style:name="Heading2" style:family="table-cell">
                    <style:properties fo:text-align="center"
                                      fo:font-size="10pt" fo:font-weight="bold" style:column-width="5cm" style:row-height="2cm"/>
                </style:style>
                <style:style style:name="long-Heading2" style:family="table-cell">
                    <style:properties fo:text-align="left"
                                      fo:font-size="10pt" fo:font-weight="bold" style:column-width="10cm" style:row-height="2cm"/>
                </style:style>
                <style:style style:name="Heading3" style:family="table-cell">
                    <style:properties fo:text-align="Right"
                                      fo:font-size="10pt" fo:font-weight="bold" style:column-width="5cm" />
                </style:style>
                <style:style style:name="Heading4" style:family="table-cell">
                    <style:properties fo:text-align="right"
                                      fo:font-size="10pt" fo:font-weight="bold" style:column-width="10cm" />
                </style:style>
            </office:automatic-styles>

            <office:body>
                <table:table>
                    <xsl:attribute name="table:name"><xsl:value-of select="'BasicData'" /></xsl:attribute>
                    <xsl:for-each select=".">
                        <table:table-columns>
                            <table:table-column
                                    table:default-cell-value-type="string"
                                    table:default-cell-style-name="long-string-heading">
                            </table:table-column>
                            <table:table-column
                                    table:default-cell-value-type="string"
                                    table:default-cell-style-name="long-string-heading">
                            </table:table-column>
                        </table:table-columns>
                        <table:table-header-rows>
                            <table:table-row table:default-cell-value-type="string"  >
                                <table:table-cell table:style-name="Heading2">
                                    <text:p>
                                        <xsl:value-of select="$labels/basicData"/>
                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>

                                    </text:p>
                                </table:table-cell>
                            </table:table-row>

                        </table:table-header-rows>
                        <table:table-rows>
                            <xsl:call-template name="basicData-table"/>
                        </table:table-rows>
                    </xsl:for-each>

                </table:table>

                <table:table>
                    <xsl:attribute name="table:name"><xsl:value-of select="'List of Plants'" /></xsl:attribute>
                    <xsl:for-each select="./ListOfPlants">
                    <table:table-columns>
                        <table:table-column
                                table:default-cell-value-type="string"
                                table:default-cell-style-name="long-string-heading">
                        </table:table-column>
                        <table:table-column
                                table:default-cell-value-type="number"
                                table:default-cell-style-name="number-cell">
                        </table:table-column>
                        <table:table-column
                                table:default-cell-value-type="string"
                                table:default-cell-style-name="long-string-heading">
                        </table:table-column>
                        <table:table-column
                                table:default-cell-value-type="string"
                                table:default-cell-style-name="long-string-heading">
                        </table:table-column>
                        <table:table-column
                                table:default-cell-value-type="string"
                                table:default-cell-style-name="long-string-heading">
                        </table:table-column>
                        <table:table-column
                                table:default-cell-value-type="string"
                                table:default-cell-style-name="string-cell">
                        </table:table-column>
                        <table:table-column
                                table:default-cell-value-type="string"
                                table:default-cell-style-name="string-cell">
                        </table:table-column>
                        <table:table-column
                                table:default-cell-value-type="string"
                                table:default-cell-style-name="string-cell">
                        </table:table-column>
                        <table:table-column
                                table:default-cell-value-type="string"
                                table:default-cell-style-name="number-cell">
                        </table:table-column>
                        <table:table-column
                                table:default-cell-value-type="string"
                                table:default-cell-style-name="number-cell">
                        </table:table-column>
                        <table:table-column
                                table:default-cell-value-type="string"
                                table:default-cell-style-name="long-string-heading">
                        </table:table-column>
                        <table:table-column
                                table:default-cell-value-type="string"
                                table:default-cell-style-name="long-string-heading">
                        </table:table-column>
                    </table:table-columns>
                    <table:table-header-rows>
                    <table:table-row table:default-cell-value-type="string"  >
                        <table:table-cell table:style-name="Heading2">
                            <text:p>
                                <xsl:value-of select="$labels/listOfPlants"/>
                            </text:p>
                        </table:table-cell>
                        <table:table-cell  table:style-name="Heading2">
                            <text:p>

                            </text:p>
                        </table:table-cell>
                        <table:table-cell  table:style-name="Heading2">
                            <text:p>

                            </text:p>
                        </table:table-cell>
                        <table:table-cell  table:style-name="Heading2">
                            <text:p>

                            </text:p>
                        </table:table-cell>
                        <table:table-cell  table:style-name="Heading2">
                            <text:p>

                            </text:p>
                        </table:table-cell>
                        <table:table-cell  table:style-name="Heading2">
                            <text:p>

                            </text:p>
                        </table:table-cell>
                        <table:table-cell  table:style-name="Heading2">
                            <text:p>

                            </text:p>
                        </table:table-cell>
                        <table:table-cell  table:style-name="Heading2">
                            <text:p>

                            </text:p>
                        </table:table-cell>
                        <table:table-cell  table:style-name="Heading2">
                            <text:p>

                            </text:p>
                        </table:table-cell>
                        <table:table-cell  table:style-name="Heading2">
                            <text:p>

                            </text:p>
                        </table:table-cell>
                        <table:table-cell  table:style-name="Heading2">
                            <text:p>

                            </text:p>
                        </table:table-cell>
                        <table:table-cell  table:style-name="Heading2">
                            <text:p>

                            </text:p>
                        </table:table-cell>
                    </table:table-row>
                    <table:table-row table:default-cell-value-type="string"  >
                        <table:table-cell table:style-name="Heading2">
                            <text:p>
                                <xsl:value-of select="$labels/plantName"/>
                            </text:p>
                        </table:table-cell>
                        <table:table-cell  table:style-name="Heading2">
                            <text:p>
                                <xsl:value-of select="$labels/plantId"/>
                            </text:p>
                        </table:table-cell>
                        <table:table-cell  table:style-name="Heading2">
                            <text:p>
                                <xsl:value-of select="$labels/EPRTRNationalId"/>
                            </text:p>
                        </table:table-cell>
                        <table:table-cell  table:style-name="Heading2">
                            <text:p>
                                <xsl:value-of select="$labels/address1"/>
                            </text:p>
                        </table:table-cell>
                        <table:table-cell  table:style-name="Heading2">
                            <text:p>
                                <xsl:value-of select="$labels/address2"/>
                            </text:p>
                        </table:table-cell>
                        <table:table-cell  table:style-name="Heading2">
                            <text:p>
                                <xsl:value-of select="$labels/city"/>
                            </text:p>
                        </table:table-cell>
                        <table:table-cell  table:style-name="Heading2">
                            <text:p>
                                <xsl:value-of select="$labels/region"/>
                            </text:p>
                        </table:table-cell>
                        <table:table-cell  table:style-name="Heading2">
                            <text:p>
                                <xsl:value-of select="$labels/postalCode"/>
                            </text:p>
                        </table:table-cell>
                        <table:table-cell  table:style-name="Heading2">
                            <text:p>
                                <xsl:value-of select="$labels/longitude"/>
                            </text:p>
                        </table:table-cell>
                        <table:table-cell  table:style-name="Heading2">
                            <text:p>
                                <xsl:value-of select="$labels/latitude"/>
                            </text:p>
                        </table:table-cell>
                        <table:table-cell  table:style-name="Heading2">
                            <text:p>
                                <xsl:value-of select="$labels/facilityName"/>
                            </text:p>
                        </table:table-cell>
                        <table:table-cell  table:style-name="Heading2">
                            <text:p>
                                <xsl:value-of select="$labels/comments"/>
                            </text:p>
                        </table:table-cell>
                    </table:table-row>
                    </table:table-header-rows>
                    <table:table-rows>
                        <xsl:call-template name="listOfPlants-table"/>
                    </table:table-rows>
                    </xsl:for-each>
                </table:table>

                <table:table>
                    <xsl:attribute name="table:name"><xsl:value-of select="'Plant Details'" /></xsl:attribute>
                    <xsl:for-each select="./ListOfPlants">
                        <table:table-columns>
                            <table:table-column
                                    table:default-cell-value-type="string"
                                    table:default-cell-style-name="long-string-heading">
                            </table:table-column>
                            <table:table-column
                                    table:default-cell-value-type="number"
                                    table:default-cell-style-name="number-cell">
                            </table:table-column>
                            <table:table-column
                                    table:default-cell-value-type="string"
                                    table:default-cell-style-name="string-cell">
                            </table:table-column>
                            <table:table-column
                                    table:default-cell-value-type="string"
                                    table:default-cell-style-name="number-cell">
                            </table:table-column>
                            <table:table-column
                                    table:default-cell-value-type="string"
                                    table:default-cell-style-name="string-cell">
                            </table:table-column>
                            <table:table-column
                                    table:default-cell-value-type="string"
                                    table:default-cell-style-name="number-cell">
                            </table:table-column>
                            <table:table-column
                                    table:default-cell-value-type="string"
                                    table:default-cell-style-name="string-cell">
                            </table:table-column>
                            <table:table-column
                                    table:default-cell-value-type="string"
                                    table:default-cell-style-name="number-cell">
                            </table:table-column>
                            <table:table-column
                                    table:default-cell-value-type="string"
                                    table:default-cell-style-name="number-cell">
                            </table:table-column>
                            <table:table-column
                                    table:default-cell-value-type="string"
                                    table:default-cell-style-name="string-cell">
                            </table:table-column>
                            <table:table-column
                                    table:default-cell-value-type="string"
                                    table:default-cell-style-name="string-cell">
                            </table:table-column>
                            <table:table-column
                                    table:default-cell-value-type="string"
                                    table:default-cell-style-name="string-cell">
                            </table:table-column>
                            <table:table-column
                                table:default-cell-value-type="string"
                                table:default-cell-style-name="number-cell">
                            </table:table-column>
                            <table:table-column
                                    table:default-cell-value-type="string"
                                    table:default-cell-style-name="string-cell">
                            </table:table-column>
                            <table:table-column
                                    table:default-cell-value-type="string"
                                    table:default-cell-style-name="number-cell">
                            </table:table-column>
                            <table:table-column
                                    table:default-cell-value-type="string"
                                    table:default-cell-style-name="string-cell">
                            </table:table-column>
                            <table:table-column
                                    table:default-cell-value-type="string"
                                    table:default-cell-style-name="number-cell">
                            </table:table-column>
                            <table:table-column
                                    table:default-cell-value-type="string"
                                    table:default-cell-style-name="string-cell">
                            </table:table-column>
                            <table:table-column
                                    table:default-cell-value-type="string"
                                    table:default-cell-style-name="number-cell">
                            </table:table-column>
                            <table:table-column
                                    table:default-cell-value-type="string"
                                    table:default-cell-style-name="string-cell">
                            </table:table-column>
                            <table:table-column
                                    table:default-cell-value-type="string"
                                    table:default-cell-style-name="number-cell">
                            </table:table-column>
                            <table:table-column
                                    table:default-cell-value-type="string"
                                    table:default-cell-style-name="string-cell">
                            </table:table-column>
                            <table:table-column
                                    table:default-cell-value-type="string"
                                    table:default-cell-style-name="number-cell">
                            </table:table-column>
                            <table:table-column
                                    table:default-cell-value-type="string"
                                    table:default-cell-style-name="long-string-heading">
                            </table:table-column>
                            <table:table-column
                                    table:default-cell-value-type="string"
                                    table:default-cell-style-name="number-cell">
                            </table:table-column>
                            <table:table-column
                                    table:default-cell-value-type="string"
                                    table:default-cell-style-name="string-cell">
                            </table:table-column>
                            <table:table-column
                                    table:default-cell-value-type="string"
                                    table:default-cell-style-name="string-cell">
                            </table:table-column>
                            <table:table-column
                                    table:default-cell-value-type="string"
                                    table:default-cell-style-name="number-cell">
                            </table:table-column>
                            <table:table-column
                                    table:default-cell-value-type="string"
                                    table:default-cell-style-name="number-cell">
                            </table:table-column>
                            <table:table-column
                                    table:default-cell-value-type="string"
                                    table:default-cell-style-name="string-cell">
                            </table:table-column>
                        </table:table-columns>
                        <table:table-header-rows>
                            <table:table-row table:default-cell-value-type="string"  >
                                <table:table-cell table:style-name="Heading2">
                                    <text:p>
                                        <xsl:value-of select="$labels/plantDetails"/>
                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>

                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>

                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>

                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>

                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>

                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>

                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>

                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>

                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>

                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>

                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>

                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>

                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>

                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>

                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>

                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>

                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>

                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>

                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>

                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>

                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>

                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>

                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>

                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>

                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>

                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>

                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>

                                    </text:p>
                                </table:table-cell>
                            </table:table-row>
                            <table:table-row table:default-cell-value-type="string"  >
                                <table:table-cell table:style-name="Heading2">
                                    <text:p>
                                        <xsl:value-of select="$labels/plantName"/>
                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>
                                        <xsl:value-of select="$labels/plantId"/>
                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>
                                        <xsl:value-of select="$labels/statusOfThePlant"/>
                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>
                                        <xsl:value-of select="$labels/MWth"/>
                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>
                                        <xsl:value-of select="$labels/extensionBy50MWOrMore"/>
                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>
                                        <xsl:value-of select="$labels/capacityAddedMW"/>
                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>
                                        <xsl:value-of select="$labels/substantialChange"/>
                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>
                                        <xsl:value-of select="$labels/capacityAffectedMW"/>
                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>
                                        <xsl:value-of select="$labels/dateOfStartOfOperation"/>
                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>
                                        <xsl:value-of select="$labels/refineries"/>
                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>
                                        <xsl:value-of select="$labels/otherSector"/>
                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>
                                        <xsl:value-of select="$labels/gasTurbine"/>
                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>
                                        <xsl:value-of select="$labels/MWthGasTurbine"/>
                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>
                                        <xsl:value-of select="$labels/boiler"/>
                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>
                                        <xsl:value-of select="$labels/MWthBoiler"/>
                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>
                                        <xsl:value-of select="$labels/gasEngine"/>
                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>
                                        <xsl:value-of select="$labels/MWthGasEngine"/>
                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>
                                        <xsl:value-of select="$labels/dieselEngine"/>
                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>
                                        <xsl:value-of select="$labels/MWthDieselEngine"/>
                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>
                                        <xsl:value-of select="$labels/other"/>
                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>
                                        <xsl:value-of select="$labels/otherTypeOfCombustion"/>
                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>
                                        <xsl:value-of select="$labels/MWthOther"/>
                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>
                                        <xsl:value-of select="$labels/operatingHours"/>
                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>
                                        <xsl:value-of select="$labels/comments"/>
                                    </text:p>
                                </table:table-cell>
                            </table:table-row>
                        </table:table-header-rows>
                        <table:table-rows>
                            <xsl:call-template name="plantDetails-table"/>
                        </table:table-rows>
                    </xsl:for-each>
                </table:table>

                <table:table>
                    <xsl:attribute name="table:name"><xsl:value-of select="'Energy Input, Emissions'" /></xsl:attribute>
                    <xsl:for-each select="./ListOfPlants">
                        <table:table-columns>
                            <table:table-column
                                    table:default-cell-value-type="string"
                                    table:default-cell-style-name="long-string-heading">
                            </table:table-column>
                            <table:table-column
                                    table:default-cell-value-type="number"
                                    table:default-cell-style-name="number-cell">
                            </table:table-column>
                            <table:table-column
                                    table:default-cell-value-type="string"
                                    table:default-cell-style-name="number-cell">
                            </table:table-column>
                            <table:table-column
                                    table:default-cell-value-type="string"
                                    table:default-cell-style-name="number-cell">
                            </table:table-column>
                            <table:table-column
                                    table:default-cell-value-type="string"
                                    table:default-cell-style-name="number-cell">
                            </table:table-column>
                            <table:table-column
                                    table:default-cell-value-type="string"
                                    table:default-cell-style-name="number-cell">
                            </table:table-column>
                            <table:table-column
                                    table:default-cell-value-type="string"
                                    table:default-cell-style-name="number-cell">
                            </table:table-column>
                            <table:table-column
                                    table:default-cell-value-type="string"
                                    table:default-cell-style-name="number-cell">
                            </table:table-column>
                            <table:table-column
                                    table:default-cell-value-type="string"
                                    table:default-cell-style-name="number-cell">
                            </table:table-column>
                            <table:table-column
                                    table:default-cell-value-type="string"
                                    table:default-cell-style-name="number-cell">
                            </table:table-column>
                        </table:table-columns>
                        <table:table-header-rows>
                            <table:table-row table:default-cell-value-type="string"  >
                                <table:table-cell table:style-name="Heading2">
                                    <text:p>
                                        <xsl:value-of select="$labels/energyInputEmissions"/>
                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>

                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>

                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>

                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>

                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>

                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>

                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>

                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>

                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>

                                    </text:p>
                                </table:table-cell>
                            </table:table-row>
                            <table:table-row table:default-cell-value-type="string"  >
                                <table:table-cell table:style-name="Heading2">
                                    <text:p>
                                        <xsl:value-of select="$labels/plantName"/>
                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>
                                        <xsl:value-of select="$labels/plantId"/>
                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>
                                        <xsl:value-of select="$labels/biomass"/>
                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>
                                        <xsl:value-of select="$labels/otherSolidFuels"/>
                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>
                                        <xsl:value-of select="$labels/liquidFuels"/>
                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>
                                        <xsl:value-of select="$labels/naturalGas"/>
                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>
                                        <xsl:value-of select="$labels/otherGases"/>
                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>
                                        <xsl:value-of select="$labels/SO2"/>
                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>
                                        <xsl:value-of select="$labels/NOx"/>
                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>
                                        <xsl:value-of select="$labels/dust"/>
                                    </text:p>
                                </table:table-cell>
                            </table:table-row>
                        </table:table-header-rows>
                        <table:table-rows>
                            <xsl:call-template name="energyInputEmissions-table"/>
                        </table:table-rows>
                    </xsl:for-each>
                </table:table>

                <table:table>
                    <xsl:attribute name="table:name"><xsl:value-of select="'Opt Outs, TNP'" /></xsl:attribute>
                    <xsl:for-each select="./ListOfPlants">
                        <table:table-columns>
                            <table:table-column
                                    table:default-cell-value-type="string"
                                    table:default-cell-style-name="long-string-heading">
                            </table:table-column>
                            <table:table-column
                                    table:default-cell-value-type="number"
                                    table:default-cell-style-name="number-cell">
                            </table:table-column>
                            <table:table-column
                                    table:default-cell-value-type="string"
                                    table:default-cell-style-name="string-cell">
                            </table:table-column>
                            <table:table-column
                                    table:default-cell-value-type="string"
                                    table:default-cell-style-name="number-cell">
                            </table:table-column>
                            <table:table-column
                                    table:default-cell-value-type="string"
                                    table:default-cell-style-name="number-cell">
                            </table:table-column>
                            <table:table-column
                                    table:default-cell-value-type="string"
                                    table:default-cell-style-name="string-cell">
                            </table:table-column>
                        </table:table-columns>
                        <table:table-header-rows>
                            <table:table-row table:default-cell-value-type="string"  >
                                <table:table-cell table:style-name="Heading2">
                                    <text:p>
                                        <xsl:value-of select="$labels/optOutsTNP"/>
                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>

                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>

                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>

                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>

                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>

                                    </text:p>
                                </table:table-cell>
                            </table:table-row>
                            <table:table-row table:default-cell-value-type="string"  >
                                <table:table-cell table:style-name="Heading2">
                                    <text:p>
                                        <xsl:value-of select="$labels/plantName"/>
                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>
                                        <xsl:value-of select="$labels/plantId"/>
                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>
                                        <xsl:value-of select="$labels/optOutPlant"/>
                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>
                                        <xsl:value-of select="$labels/capacityOptedOut"/>
                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>
                                        <xsl:value-of select="$labels/hoursOperated"/>
                                    </text:p>
                                </table:table-cell>
                                <table:table-cell  table:style-name="Heading2">
                                    <text:p>
                                        <xsl:value-of select="$labels/plantIncludedInNERP"/>
                                    </text:p>
                                </table:table-cell>
                            </table:table-row>
                        </table:table-header-rows>
                        <table:table-rows>
                            <xsl:call-template name="optOutsTNP-table"/>
                        </table:table-rows>
                    </xsl:for-each>
                </table:table>

                <table:table>
                    <xsl:attribute name="table:name"><xsl:value-of select="'LCP Article 15'" /></xsl:attribute>
                    <xsl:for-each select="./ListOfPlants">
                    <table:table-columns>
                        <table:table-column
                                table:default-cell-value-type="string"
                                table:default-cell-style-name="long-string-heading">
                        </table:table-column>
                        <table:table-column
                                table:default-cell-value-type="number"
                                table:default-cell-style-name="number-cell">
                        </table:table-column>
                        <table:table-column
                                table:default-cell-value-type="string"
                                table:default-cell-style-name="string-cell">
                        </table:table-column>
                        <table:table-column
                                table:default-cell-value-type="string"
                                table:default-cell-style-name="number-cell">
                        </table:table-column>
                        <table:table-column
                                table:default-cell-value-type="string"
                                table:default-cell-style-name="number-cell">
                        </table:table-column>
                        <table:table-column
                                table:default-cell-value-type="string"
                                table:default-cell-style-name="string-cell">
                        </table:table-column>
                        <table:table-column
                                table:default-cell-value-type="string"
                                table:default-cell-style-name="number-cell">
                        </table:table-column>
                        <table:table-column
                                table:default-cell-value-type="string"
                                table:default-cell-style-name="number-cell">
                        </table:table-column>
                        <table:table-column
                                table:default-cell-value-type="string"
                                table:default-cell-style-name="number-cell">
                        </table:table-column>
                        <table:table-column
                                table:default-cell-value-type="string"
                                table:default-cell-style-name="string-cell">
                        </table:table-column>
                        <table:table-column
                                table:default-cell-value-type="string"
                                table:default-cell-style-name="number-cell">
                        </table:table-column>
                        <table:table-column
                                table:default-cell-value-type="string"
                                table:default-cell-style-name="number-cell">
                        </table:table-column>
                        <table:table-column
                                table:default-cell-value-type="string"
                                table:default-cell-style-name="string-cell">
                        </table:table-column>
                        <table:table-column
                                table:default-cell-value-type="string"
                                table:default-cell-style-name="number-cell">
                        </table:table-column>
                        <table:table-column
                                table:default-cell-value-type="string"
                                table:default-cell-style-name="number-cell">
                        </table:table-column>
                        <table:table-column
                                table:default-cell-value-type="string"
                                table:default-cell-style-name="long-string-heading">
                        </table:table-column>


                    </table:table-columns>
                    <table:table-header-rows>
                    <table:table-row table:default-cell-value-type="string"  >
                        <table:table-cell table:style-name="Heading2">
                            <text:p>
                                <xsl:value-of select="$labels/LCPArticle15"/>
                            </text:p>
                        </table:table-cell>
                        <table:table-cell  table:style-name="Heading2">
                            <text:p>

                            </text:p>
                        </table:table-cell>
                        <table:table-cell  table:style-name="Heading2">
                            <text:p>

                            </text:p>
                        </table:table-cell>
                        <table:table-cell  table:style-name="Heading2">
                            <text:p>

                            </text:p>
                        </table:table-cell>
                        <table:table-cell  table:style-name="Heading2">
                            <text:p>

                            </text:p>
                        </table:table-cell>
                        <table:table-cell  table:style-name="Heading2">
                            <text:p>

                            </text:p>
                        </table:table-cell>
                        <table:table-cell  table:style-name="Heading2">
                            <text:p>

                            </text:p>
                        </table:table-cell>
                        <table:table-cell  table:style-name="Heading2">
                            <text:p>

                            </text:p>
                        </table:table-cell>
                        <table:table-cell  table:style-name="Heading2">
                            <text:p>

                            </text:p>
                        </table:table-cell>
                        <table:table-cell  table:style-name="Heading2">
                            <text:p>

                            </text:p>
                        </table:table-cell>
                        <table:table-cell  table:style-name="Heading2">
                            <text:p>

                            </text:p>
                        </table:table-cell>
                        <table:table-cell  table:style-name="Heading2">
                            <text:p>

                            </text:p>
                        </table:table-cell>
                        <table:table-cell  table:style-name="Heading2">
                            <text:p>

                            </text:p>
                        </table:table-cell>
                        <table:table-cell  table:style-name="Heading2">
                            <text:p>

                            </text:p>
                        </table:table-cell>
                        <table:table-cell  table:style-name="Heading2">
                            <text:p>

                            </text:p>
                        </table:table-cell>
                        <table:table-cell  table:style-name="Heading2">
                            <text:p>

                            </text:p>
                        </table:table-cell>
                    </table:table-row>
                    <table:table-row table:default-cell-value-type="string"  >
                        <table:table-cell table:style-name="Heading2">
                            <text:p>
                                <xsl:value-of select="$labels/plantName"/>
                            </text:p>
                        </table:table-cell>
                        <table:table-cell  table:style-name="Heading2">
                            <text:p>
                                <xsl:value-of select="$labels/plantId"/>
                            </text:p>
                        </table:table-cell>
                        <table:table-cell  table:style-name="Heading2">
                            <text:p>
                                <xsl:value-of select="$labels/art5"/>
                            </text:p>
                        </table:table-cell>
                        <table:table-cell  table:style-name="Heading2">
                            <text:p>
                                <xsl:value-of select="$labels/operatingHours"/>
                            </text:p>
                        </table:table-cell>
                        <table:table-cell  table:style-name="Heading2">
                            <text:p>
                                <xsl:value-of select="$labels/elvSO2"/>
                            </text:p>
                        </table:table-cell>
                        <table:table-cell  table:style-name="Heading2">
                            <text:p>
                                <xsl:value-of select="$labels/notaBeneAnnex"/>
                            </text:p>
                        </table:table-cell>
                        <table:table-cell  table:style-name="Heading2">
                            <text:p>
                                <xsl:value-of select="$labels/elvSO2"/>
                            </text:p>
                        </table:table-cell>
                        <table:table-cell  table:style-name="Heading2">
                            <text:p>
                                <xsl:value-of select="$labels/desulphurisation"/>
                            </text:p>
                        </table:table-cell>
                        <table:table-cell  table:style-name="Heading2">
                            <text:p>
                                <xsl:value-of select="$labels/sInput"/>
                            </text:p>
                        </table:table-cell>
                        <table:table-cell  table:style-name="Heading2">
                            <text:p>
                                <xsl:value-of select="$labels/annexVIAfootnote2"/>
                            </text:p>
                        </table:table-cell>
                        <table:table-cell  table:style-name="Heading2">
                            <text:p>
                                <xsl:value-of select="$labels/operatingHours"/>
                            </text:p>
                        </table:table-cell>
                        <table:table-cell  table:style-name="Heading2">
                            <text:p>
                                <xsl:value-of select="$labels/elvNoX"/>
                            </text:p>
                        </table:table-cell>
                        <table:table-cell  table:style-name="Heading2">
                            <text:p>
                                <xsl:value-of select="$labels/annexVIAfootnote3"/>
                            </text:p>
                        </table:table-cell>
                        <table:table-cell  table:style-name="Heading2">
                            <text:p>
                                <xsl:value-of select="$labels/volatileContents"/>
                            </text:p>
                        </table:table-cell>
                        <table:table-cell  table:style-name="Heading2">
                            <text:p>
                                <xsl:value-of select="$labels/elvNoX"/>
                            </text:p>
                        </table:table-cell>
                        <table:table-cell  table:style-name="Heading2">
                            <text:p>
                                <xsl:value-of select="$labels/comments"/>
                            </text:p>
                        </table:table-cell>
                    </table:table-row>
                    </table:table-header-rows>
                    <table:table-rows>
                        <xsl:call-template name="LCPArticle15-table"/>
                    </table:table-rows>
                    </xsl:for-each>
                </table:table>
            </office:body>
        </office:document-content>
    </xsl:template>


    <xsl:template name="basicData-table">
        <table:table-row table:default-cell-value-type="string"  >
            <table:table-cell table:style-name="Heading1">
                <text:p>
                    <xsl:value-of select="$labels/memberState"/>
                </text:p>
            </table:table-cell>
            <table:table-cell  table:style-name="cell1">
                <text:p>
                    <xsl:value-of select="./BasicData/MemberState" />
                </text:p>
            </table:table-cell>
        </table:table-row>
        <table:table-row table:default-cell-value-type="string"  >
            <table:table-cell table:style-name="Heading1">
                <text:p>
                    <xsl:value-of select="$labels/referenceYear"/>
                </text:p>
            </table:table-cell>
            <table:table-cell  table:style-name="number-cell">
                <text:p>
                    <xsl:value-of select="./BasicData/ReferenceYear" />
                </text:p>
            </table:table-cell>
        </table:table-row>
        <table:table-row table:default-cell-value-type="string"  >
            <table:table-cell table:style-name="Heading1">
                <text:p>
                    <xsl:value-of select="$labels/numberOfPlants"/>
                </text:p>
            </table:table-cell>
            <table:table-cell  table:style-name="number-cell">
                <text:p>
                    <xsl:value-of select="./BasicData/NumberOfPlants" />
                </text:p>
            </table:table-cell>
        </table:table-row>
        <table:table-row table:default-cell-value-type="string"  >
            <table:table-cell table:style-name="Heading1">
                <text:p>
                    <xsl:value-of select="$labels/organization"/>
                </text:p>
            </table:table-cell>
            <table:table-cell  table:style-name="cell1">
                <text:p>
                    <xsl:value-of select="./BasicData/Organization" />
                </text:p>
            </table:table-cell>
        </table:table-row>
        <table:table-row table:default-cell-value-type="string"  >
            <table:table-cell table:style-name="Heading1">
                <text:p>
                    <xsl:value-of select="$labels/address1"/>
                </text:p>
            </table:table-cell>
            <table:table-cell  table:style-name="cell1">
                <text:p>
                    <xsl:value-of select="./BasicData/Address1" />
                </text:p>
            </table:table-cell>
        </table:table-row>
        <table:table-row table:default-cell-value-type="string"  >
            <table:table-cell table:style-name="Heading1">
                <text:p>
                    <xsl:value-of select="$labels/address2"/>
                </text:p>
            </table:table-cell>
            <table:table-cell  table:style-name="cell1">
                <text:p>
                    <xsl:value-of select="./BasicData/Address2" />
                </text:p>
            </table:table-cell>
        </table:table-row>
        <table:table-row table:default-cell-value-type="string"  >
            <table:table-cell table:style-name="Heading1">
                <text:p>
                    <xsl:value-of select="$labels/city"/>
                </text:p>
            </table:table-cell>
            <table:table-cell  table:style-name="cell1">
                <text:p>
                    <xsl:value-of select="./BasicData/City" />
                </text:p>
            </table:table-cell>
        </table:table-row>
        <table:table-row table:default-cell-value-type="string"  >
            <table:table-cell table:style-name="Heading1">
                <text:p>
                    <xsl:value-of select="$labels/state"/>
                </text:p>
            </table:table-cell>
            <table:table-cell  table:style-name="cell1">
                <text:p>
                    <xsl:value-of select="./BasicData/State" />
                </text:p>
            </table:table-cell>
        </table:table-row>
        <table:table-row table:default-cell-value-type="string"  >
            <table:table-cell table:style-name="Heading1">
                <text:p>
                    <xsl:value-of select="$labels/postalCode"/>
                </text:p>
            </table:table-cell>
            <table:table-cell  table:style-name="cell1">
                <text:p>
                    <xsl:value-of select="./BasicData/PostalCode" />
                </text:p>
            </table:table-cell>
        </table:table-row>
        <table:table-row table:default-cell-value-type="string"  >
            <table:table-cell table:style-name="Heading1">
                <text:p>
                    <xsl:value-of select="$labels/nameOfContactPerson"/>
                </text:p>
            </table:table-cell>
            <table:table-cell  table:style-name="cell1">
                <text:p>
                    <xsl:value-of select="./BasicData/NameOfContactPerson" />
                </text:p>
            </table:table-cell>
        </table:table-row>
        <table:table-row table:default-cell-value-type="string"  >
            <table:table-cell table:style-name="Heading1">
                <text:p>
                    <xsl:value-of select="$labels/phone"/>
                </text:p>
            </table:table-cell>
            <table:table-cell  table:style-name="cell1">
                <text:p>
                    <xsl:value-of select="./BasicData/Phone" />
                </text:p>
            </table:table-cell>
        </table:table-row>
        <table:table-row table:default-cell-value-type="string"  >
            <table:table-cell table:style-name="Heading1">
                <text:p>
                    <xsl:value-of select="$labels/eMail"/>
                </text:p>
            </table:table-cell>
            <table:table-cell  table:style-name="cell1">
                <text:p>
                    <xsl:value-of select="./BasicData/EMail" />
                </text:p>
            </table:table-cell>
        </table:table-row>
    </xsl:template>

    <xsl:template name="listOfPlants-table">
    <xsl:for-each select="Plant">
        <table:table-row table:default-cell-value-type="string"  >
            <table:table-cell  table:style-name="cell1">
                <text:p>
                    <xsl:value-of select="./PlantName" />
                </text:p>
            </table:table-cell>
            <table:table-cell  table:style-name="number-cell">
                <text:p>
                    <xsl:value-of select="./PlantId" />
                </text:p>
            </table:table-cell>
            <table:table-cell  table:style-name="cell1">
                <text:p>
                    <xsl:value-of select="./EPRTRNationalId" />
                </text:p>
            </table:table-cell>
            <table:table-cell  table:style-name="cell1">
                <text:p>
                    <xsl:value-of select="./PlantLocation/Address1" />
                </text:p>
            </table:table-cell>
            <table:table-cell  table:style-name="cell1">
                <text:p>
                    <xsl:value-of select="./PlantLocation/Address2" />
                </text:p>
            </table:table-cell>
            <table:table-cell  table:style-name="cell1">
                <text:p>
                    <xsl:value-of select="./PlantLocation/City" />
                </text:p>
            </table:table-cell>
            <table:table-cell  table:style-name="cell1">
                <text:p>
                    <xsl:value-of select="./PlantLocation/Region" />
                </text:p>
            </table:table-cell>
            <table:table-cell  table:style-name="cell1">
                <text:p>
                    <xsl:value-of select="./PlantLocation/PostalCode" />
                </text:p>
            </table:table-cell>
            <table:table-cell  table:style-name="number-cell">
                <text:p>
                    <xsl:value-of select="./GeographicalCoordinate/Longitude" />
                </text:p>
            </table:table-cell>
            <table:table-cell  table:style-name="number-cell">
                <text:p>
                    <xsl:value-of select="./GeographicalCoordinate/Latitude" />
                </text:p>
            </table:table-cell>
            <table:table-cell  table:style-name="cell1">
                <text:p>
                    <xsl:value-of select="./FacilityName" />
                </text:p>
            </table:table-cell>
            <table:table-cell  table:style-name="cell1">
                <text:p>
                    <xsl:value-of select="./Comments" />
                </text:p>
            </table:table-cell>
        </table:table-row>
    </xsl:for-each>
</xsl:template>

    <xsl:template name="plantDetails-table">
        <xsl:for-each select="Plant/PlantDetails">
            <table:table-row table:default-cell-value-type="string"  >
                <table:table-cell  table:style-name="cell1">
                    <text:p>
                        <xsl:value-of select="../PlantName" />
                    </text:p>
                </table:table-cell>
                <table:table-cell  table:style-name="number-cell">
                    <text:p>
                        <xsl:value-of select="../PlantId" />
                    </text:p>
                </table:table-cell>
                <table:table-cell  table:style-name="cell1">
                    <text:p>
                        <xsl:value-of select="./StatusOfThePlant" />
                    </text:p>
                </table:table-cell>
                <table:table-cell  table:style-name="number-cell">
                    <text:p>
                        <xsl:value-of select="./MWth" />
                    </text:p>
                </table:table-cell>
                <table:table-cell  table:style-name="cell1">
                    <text:p>
                        <xsl:value-of select="./ExtensionBy50MWOrMore" />
                    </text:p>
                </table:table-cell>
                <table:table-cell  table:style-name="number-cell">
                    <text:p>
                        <xsl:value-of select="./CapacityAddedMW" />
                    </text:p>
                </table:table-cell>
                <table:table-cell  table:style-name="cell1">
                    <text:p>
                        <xsl:value-of select="./SubstantialChange" />
                    </text:p>
                </table:table-cell>
                <table:table-cell  table:style-name="number-cell">
                    <text:p>
                        <xsl:value-of select="./CapacityAffectedMW" />
                    </text:p>
                </table:table-cell>
                <table:table-cell  table:style-name="number-cell">
                    <text:p>
                        <xsl:value-of select="./DateOfStartOfOperation" />
                    </text:p>
                </table:table-cell>
                <table:table-cell  table:style-name="cell1">
                    <text:p>
                        <xsl:value-of select="./Refineries" />
                    </text:p>
                </table:table-cell>
                <table:table-cell  table:style-name="cell1">
                    <text:p>
                        <xsl:value-of select="./OtherSector" />
                    </text:p>
                </table:table-cell>
                <table:table-cell  table:style-name="cell1">
                    <text:p>
                        <xsl:value-of select="./GasTurbine" />
                    </text:p>
                </table:table-cell>
                <table:table-cell  table:style-name="number-cell">
                    <text:p>
                        <xsl:value-of select="./GasTurbineThermalInput" />
                    </text:p>
                </table:table-cell>
                <table:table-cell  table:style-name="cell1">
                    <text:p>
                        <xsl:value-of select="./Boiler" />
                    </text:p>
                </table:table-cell>
                <table:table-cell  table:style-name="number-cell">
                    <text:p>
                        <xsl:value-of select="./BoilerThermalInput" />
                    </text:p>
                </table:table-cell>
                <table:table-cell  table:style-name="cell1">
                    <text:p>
                        <xsl:value-of select="./GasEngine" />
                    </text:p>
                </table:table-cell>
                <table:table-cell  table:style-name="number-cell">
                    <text:p>
                        <xsl:value-of select="./GasEngineThermalInput" />
                    </text:p>
                </table:table-cell>
                <table:table-cell  table:style-name="cell1">
                    <text:p>
                        <xsl:value-of select="./DieselEngine" />
                    </text:p>
                </table:table-cell>
                <table:table-cell  table:style-name="number-cell">
                    <text:p>
                        <xsl:value-of select="./DieselEngineTurbineThermalInput" />
                    </text:p>
                </table:table-cell>
                <table:table-cell  table:style-name="cell1">
                    <text:p>
                        <xsl:value-of select="./Other" />
                    </text:p>
                </table:table-cell>
                <table:table-cell  table:style-name="cell1">
                    <text:p>
                        <xsl:value-of select="./OtherTypeOfCombustion" />
                    </text:p>
                </table:table-cell>
                <table:table-cell  table:style-name="number-cell">
                    <text:p>
                        <xsl:value-of select="./OtherThermalInput" />
                    </text:p>
                </table:table-cell>
                <table:table-cell  table:style-name="number-cell">
                    <text:p>
                        <xsl:value-of select="./OperatingHours" />
                    </text:p>
                </table:table-cell>
                <table:table-cell  table:style-name="cell1">
                    <text:p>
                        <xsl:value-of select="./Comments" />
                    </text:p>
                </table:table-cell>
            </table:table-row>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="energyInputEmissions-table">
        <xsl:for-each select="Plant/EnergyInputAndTotalEmissionsToAir">
            <table:table-row table:default-cell-value-type="string"  >
                <table:table-cell  table:style-name="cell1">
                    <text:p>
                        <xsl:value-of select="../PlantName" />
                    </text:p>
                </table:table-cell>
                <table:table-cell  table:style-name="number-cell">
                    <text:p>
                        <xsl:value-of select="../PlantId" />
                    </text:p>
                </table:table-cell>
                <table:table-cell  table:style-name="number-cell">
                    <text:p>
                        <xsl:value-of select="./EnergyInput/Biomass" />
                    </text:p>
                </table:table-cell>
                <table:table-cell  table:style-name="number-cell">
                    <text:p>
                        <xsl:value-of select="./EnergyInput/OtherSolidFuels" />
                    </text:p>
                </table:table-cell>
                <table:table-cell  table:style-name="number-cell">
                    <text:p>
                        <xsl:value-of select="./EnergyInput/LiquidFuels" />
                    </text:p>
                </table:table-cell>
                <table:table-cell  table:style-name="number-cell">
                    <text:p>
                        <xsl:value-of select="./EnergyInput/NaturalGas" />
                    </text:p>
                </table:table-cell>
                <table:table-cell  table:style-name="number-cell">
                    <text:p>
                        <xsl:value-of select="./EnergyInput/OtherGases" />
                    </text:p>
                </table:table-cell>
                <table:table-cell  table:style-name="number-cell">
                    <text:p>
                        <xsl:value-of select="./TotalEmissionsToAir/SO2" />
                    </text:p>
                </table:table-cell>
                <table:table-cell  table:style-name="number-cell">
                    <text:p>
                        <xsl:value-of select="./TotalEmissionsToAir/NOx" />
                    </text:p>
                </table:table-cell>
                <table:table-cell  table:style-name="number-cell">
                    <text:p>
                        <xsl:value-of select="./TotalEmissionsToAir/Dust" />
                    </text:p>
                </table:table-cell>
            </table:table-row>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="optOutsTNP-table">
        <xsl:for-each select="Plant/OptOutsAndNERP">
            <table:table-row table:default-cell-value-type="string"  >
                <table:table-cell  table:style-name="cell1">
                    <text:p>
                        <xsl:value-of select="../PlantName" />
                    </text:p>
                </table:table-cell>
                <table:table-cell  table:style-name="number-cell">
                    <text:p>
                        <xsl:value-of select="../PlantId" />
                    </text:p>
                </table:table-cell>
                <table:table-cell  table:style-name="cell1">
                    <text:p>
                        <xsl:value-of select="./OptOutPlant" />
                    </text:p>
                </table:table-cell>
                <table:table-cell  table:style-name="number-cell">
                    <text:p>
                        <xsl:value-of select="./CapacityOptedOutMW" />
                    </text:p>
                </table:table-cell>
                <table:table-cell  table:style-name="number-cell">
                    <text:p>
                        <xsl:value-of select="./HoursOperated" />
                    </text:p>
                </table:table-cell>
                <table:table-cell  table:style-name="cell1">
                    <text:p>
                        <xsl:value-of select="./PlantIncludedInNERP" />
                    </text:p>
                </table:table-cell>
            </table:table-row>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="LCPArticle15-table">
        <xsl:for-each select="Plant/LcpArt15">
            <table:table-row table:default-cell-value-type="string"  >
                <table:table-cell  table:style-name="cell1">
                    <text:p>
                        <xsl:value-of select="../PlantName" />
                    </text:p>
                </table:table-cell>
                <table:table-cell  table:style-name="number-cell">
                    <text:p>
                        <xsl:value-of select="../PlantId" />
                    </text:p>
                </table:table-cell>
                <table:table-cell  table:style-name="cell1">
                    <text:p>
                        <xsl:value-of select="./Art5_1" />
                    </text:p>
                </table:table-cell>
                <table:table-cell  table:style-name="number-cell">
                    <text:p>
                        <xsl:value-of select="./OperatingHours" />
                    </text:p>
                </table:table-cell>
                <table:table-cell  table:style-name="number-cell">
                    <text:p>
                        <xsl:value-of select="./ElvSO2" />
                    </text:p>
                </table:table-cell>
                <table:table-cell  table:style-name="cell1">
                    <text:p>
                        <xsl:value-of select="./NotaBeneAnnexIII" />
                    </text:p>
                </table:table-cell>
                <table:table-cell  table:style-name="number-cell">
                    <text:p>
                        <xsl:value-of select="./NotaBeneElvSO2" />
                    </text:p>
                </table:table-cell>
                <table:table-cell  table:style-name="number-cell">
                    <text:p>
                        <xsl:value-of select="./DesulphurisationRate" />
                    </text:p>
                </table:table-cell>
                <table:table-cell  table:style-name="number-cell">
                    <text:p>
                        <xsl:value-of select="./SInput" />
                    </text:p>
                </table:table-cell>
                <table:table-cell  table:style-name="cell1">
                    <text:p>
                        <xsl:value-of select="./AnnexVI_A_Footnote2" />
                    </text:p>
                </table:table-cell>
                <table:table-cell  table:style-name="number-cell">
                    <text:p>
                        <xsl:value-of select="./AnnexVI_A_Footnote2_OperatingHours" />
                    </text:p>
                </table:table-cell>
                <table:table-cell  table:style-name="number-cell">
                    <text:p>
                        <xsl:value-of select="./ElvNOx" />
                    </text:p>
                </table:table-cell>
                <table:table-cell  table:style-name="cell1">
                    <text:p>
                        <xsl:value-of select="./AnnexVI_A_Footnote3" />
                    </text:p>
                </table:table-cell>
                <table:table-cell  table:style-name="number-cell">
                    <text:p>
                        <xsl:value-of select="./VolatileContents" />
                    </text:p>
                </table:table-cell>
                <table:table-cell  table:style-name="number-cell">
                    <text:p>
                        <xsl:value-of select="./AnnexVI_A_Footnote3_ElvNOx" />
                    </text:p>
                </table:table-cell>
                <table:table-cell  table:style-name="cell1">
                    <text:p>
                        <xsl:value-of select="./Comments" />
                    </text:p>
                </table:table-cell>
            </table:table-row>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>