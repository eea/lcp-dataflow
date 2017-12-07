<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/XSL/Transform">
        <xsl:import href="common.xsl"/>
    <xsl:output method="text" />

    <xsl:param name="envelopeurl" />
    <xsl:param name="filename" />
    <xsl:param name="isreleased" select="'1'"/>
    <xsl:param name="releasetime" select="substring-before(current-dateTime(), '.')"/>
    <xsl:param name="commandline" select="'false'"/>
    <!--
    For testing:
    <xsl:param name="isreleased"/>
    <xsl:param name="releasetime"/>
    <xsl:param name="isreleased" select="'1'"/>
    <xsl:param name="releasetime" select="substring-before(current-date(), '+')"/>
    -->

    <xsl:variable name="reportid" select="concat($envelopeurl, '/', $filename , '#', $releasetime)"/>

    <xsl:template match="LCPQuestionnaire">
        <xsl:variable name="country" select="BasicData/MemberState"/>
        <xsl:text></xsl:text>
        <xsl:apply-templates/>


        <xsl:text>UPDATE BasicData SET most_recent_report = Yes WHERE MemberState='</xsl:text>
        <xsl:value-of select="$country"/>
        <xsl:text>' and ReferenceYear=</xsl:text>
        <xsl:value-of select="BasicData/ReferenceYear"/>
        <!--<xsl:text> and official_report=</xsl:text>
        <xsl:call-template name="boolean"><xsl:with-param name="value" select="@officialReport"/></xsl:call-template><xsl:text></xsl:text>
        -->
        <xsl:text> and report_submissiondate IN (SELECT TOP 1 report_submissiondate FROM BasicData WHERE MemberState='</xsl:text>
        <xsl:value-of select="$country"/>
        <xsl:text>' and ReferenceYear=</xsl:text>
        <xsl:value-of select="BasicData/ReferenceYear"/>
        <!--<xsl:text> and official_report=</xsl:text>
        <xsl:call-template name="boolean"><xsl:with-param name="value" select="@officialReport"/></xsl:call-template><xsl:text></xsl:text>
        -->
        <xsl:text> order by report_submissiondate  DESC);</xsl:text>
        <xsl:call-template name="statementSeparator"/>

        <xsl:text>UPDATE BasicData SET most_recent_report = No WHERE MemberState='</xsl:text>
        <xsl:value-of select="$country"/>
        <xsl:text>' and report_submissiondate=</xsl:text>
        <xsl:value-of select="BasicData/ReferenceYear"/>
        <!--<xsl:text> and official_report=</xsl:text>
        <xsl:call-template name="boolean"><xsl:with-param name="value" select="@officialReport"/></xsl:call-template><xsl:text></xsl:text>
        -->
        <xsl:text> and report_submissiondate NOT IN (SELECT TOP 1 report_submissiondate FROM BasicData WHERE MemberState='</xsl:text>
        <xsl:value-of select="$country"/>
        <xsl:text>' and report_submissiondate=</xsl:text>
        <xsl:value-of select="BasicData/ReferenceYear"/>
        <!--<xsl:text> and official_report=</xsl:text>
        <xsl:call-template name="boolean"><xsl:with-param name="value" select="@officialReport"/></xsl:call-template><xsl:text></xsl:text>
        -->
        <xsl:text> order by report_submissiondate  DESC);</xsl:text>
        <xsl:call-template name="statementSeparator"/>
    </xsl:template>

    <xsl:template match="BasicData">
         <xsl:text>
                INSERT INTO BasicData(Report_ID, most_recent_report, MemberState, ReferenceYear, NumberOfPlants, Organization, Address1, Address2, City, State, PostalCode,
                    NameOfContactPerson, Phone, EMail, report_submissiondate, envelope_url, filename, envelope_isreleased) VALUES (</xsl:text>
                    <xsl:call-template name="string"><xsl:with-param name="value" select="$reportid"/></xsl:call-template><xsl:text>,</xsl:text>
                    <xsl:text>No,</xsl:text>
                    <xsl:call-template name="string"><xsl:with-param name="value" select="MemberState"/></xsl:call-template><xsl:text>, </xsl:text>
                    <xsl:call-template name="number"><xsl:with-param name="value" select="ReferenceYear"/></xsl:call-template><xsl:text>, </xsl:text>
                    <xsl:call-template name="number"><xsl:with-param name="value" select="NumberOfPlants"/></xsl:call-template><xsl:text>, </xsl:text>
                    <xsl:call-template name="string"><xsl:with-param name="value" select="Organization"/></xsl:call-template><xsl:text>, </xsl:text>
                    <xsl:call-template name="string"><xsl:with-param name="value" select="Address1"/></xsl:call-template><xsl:text>, </xsl:text>
                    <xsl:call-template name="string"><xsl:with-param name="value" select="Address2"/></xsl:call-template><xsl:text>, </xsl:text>
                    <xsl:call-template name="string"><xsl:with-param name="value" select="City"/></xsl:call-template><xsl:text>, </xsl:text>
                    <xsl:call-template name="string"><xsl:with-param name="value" select="State"/></xsl:call-template><xsl:text>, </xsl:text>
                    <xsl:call-template name="string"><xsl:with-param name="value" select="PostalCode"/></xsl:call-template><xsl:text>, </xsl:text>
                    <xsl:call-template name="string"><xsl:with-param name="value" select="NameOfContactPerson"/></xsl:call-template><xsl:text>, </xsl:text>
                    <xsl:call-template name="string"><xsl:with-param name="value" select="Phone"/></xsl:call-template><xsl:text>, </xsl:text>
                    <xsl:call-template name="string"><xsl:with-param name="value" select="EMail"/></xsl:call-template><xsl:text>, </xsl:text>


                    <xsl:call-template name="datetime"><xsl:with-param name="value" select="$releasetime"/></xsl:call-template><xsl:text>, </xsl:text>
                    <xsl:call-template name="string"><xsl:with-param name="value" select="$envelopeurl"/></xsl:call-template><xsl:text>, </xsl:text>
                    <xsl:call-template name="string"><xsl:with-param name="value" select="$filename"/></xsl:call-template><xsl:text>, </xsl:text>
                    <xsl:call-template name="string"><xsl:with-param name="value" select="$isreleased"/></xsl:call-template>
            <xsl:text>);
       </xsl:text>
    </xsl:template>

    <!--
        <xsl:template match="ListOfPlants">
            <xsl:for-each select="Plant">
                <xsl:text>
                    INSERT INTO Plant VALUES (</xsl:text>
                        <xsl:call-template name="string"><xsl:with-param name="value" select="PlantName"/></xsl:call-template><xsl:text>,</xsl:text>
                        <xsl:call-template name="string"><xsl:with-param name="value" select="PlantId"/></xsl:call-template><xsl:text>,</xsl:text>
                        <xsl:call-template name="string"><xsl:with-param name="value" select="FacilityName"/></xsl:call-template><xsl:text>,</xsl:text>
                        <xsl:call-template name="string"><xsl:with-param name="value" select="EPRTRNationalId"/></xsl:call-template><xsl:text>,</xsl:text>
                        <xsl:call-template name="string"><xsl:with-param name="value" select="PlantLocation/Address1"/></xsl:call-template><xsl:text>,</xsl:text>
                        <xsl:call-template name="string"><xsl:with-param name="value" select="PlantLocation/Address2"/></xsl:call-template><xsl:text>,</xsl:text>
                        <xsl:call-template name="string"><xsl:with-param name="value" select="PlantLocation/City"/></xsl:call-template><xsl:text>,</xsl:text>
                        <xsl:call-template name="string"><xsl:with-param name="value" select="PlantLocation/Region"/></xsl:call-template><xsl:text>,</xsl:text>
                        <xsl:call-template name="string"><xsl:with-param name="value" select="PlantLocation/PostalCode"/></xsl:call-template><xsl:text>,</xsl:text>
                        <xsl:call-template name="string"><xsl:with-param name="value" select="GeographicalCoordinate/Longitude"/></xsl:call-template><xsl:text>,</xsl:text>
                        <xsl:call-template name="string"><xsl:with-param name="value" select="GeographicalCoordinate/Latitude"/></xsl:call-template>
                    <xsl:text>);
                </xsl:text>
            </xsl:for-each>
        </xsl:template>
    -->

    <xsl:template match="ListOfPlants">
        <xsl:for-each select="Plant">
            <xsl:variable name="plant_name" select="PlantName"/>
                <xsl:text> INSERT INTO Plant(PlantName, PlantId, FacilityName, EPRTRNationalId, Address1, Address2, City, Region, PostalCode, Longitude, Latitude, FK_BasicData_ID) SELECT
                   </xsl:text>

                    <xsl:call-template name="string"><xsl:with-param name="value" select="PlantName"/></xsl:call-template><xsl:text>,</xsl:text>
                    <xsl:call-template name="string"><xsl:with-param name="value" select="PlantId"/></xsl:call-template><xsl:text>,</xsl:text>
                    <xsl:call-template name="string"><xsl:with-param name="value" select="FacilityName"/></xsl:call-template><xsl:text>,</xsl:text>
                    <xsl:call-template name="string"><xsl:with-param name="value" select="EPRTRNationalId"/></xsl:call-template><xsl:text>,</xsl:text>
                    <xsl:call-template name="string"><xsl:with-param name="value" select="PlantLocation/Address1"/></xsl:call-template><xsl:text>,</xsl:text>
                    <xsl:call-template name="string"><xsl:with-param name="value" select="PlantLocation/Address2"/></xsl:call-template><xsl:text>,</xsl:text>
                    <xsl:call-template name="string"><xsl:with-param name="value" select="PlantLocation/City"/></xsl:call-template><xsl:text>,</xsl:text>
                    <xsl:call-template name="string"><xsl:with-param name="value" select="PlantLocation/Region"/></xsl:call-template><xsl:text>,</xsl:text>
                    <xsl:call-template name="string"><xsl:with-param name="value" select="PlantLocation/PostalCode"/></xsl:call-template><xsl:text>,</xsl:text>
                    <xsl:call-template name="string"><xsl:with-param name="value" select="GeographicalCoordinate/Longitude"/></xsl:call-template><xsl:text>,</xsl:text>
                    <xsl:call-template name="string"><xsl:with-param name="value" select="GeographicalCoordinate/Latitude"/></xsl:call-template><xsl:text>,</xsl:text>
                    <xsl:text>ID FROM BasicData WHERE Report_ID = </xsl:text><xsl:call-template name="string"><xsl:with-param name="value" select="$reportid"/></xsl:call-template>
                    <xsl:text> AND MemberState = </xsl:text><xsl:call-template name="string"><xsl:with-param name="value" select="../../BasicData/MemberState"/></xsl:call-template>
                <xsl:text>;
                </xsl:text>



                <xsl:text> INSERT INTO PlantDetails(StatusOfThePlant, MWth, ExtensionBy50MWOrMore, CapacityAddedMW, SubstantialChange, CapacityAffectedMW, DateOfStartOfOperation,
                    Refineries, OtherSector, GasTurbine, GasTurbineThermalInput, Boiler, BoilerThermalInput, GasEngine, GasEngineThermalInput, DieselEngine, DieselEngineTurbineThermalInput,
                    Other, OtherTypeOfCombustion, OtherThermalInput, OperatingHours, Comments, FK_Plant_ID) SELECT </xsl:text>

                    <xsl:call-template name="string"><xsl:with-param name="value" select="PlantDetails/StatusOfThePlant"/></xsl:call-template><xsl:text>,</xsl:text>
                    <xsl:call-template name="number"><xsl:with-param name="value" select="PlantDetails/MWth"/></xsl:call-template><xsl:text>,</xsl:text>
                    <xsl:call-template name="boolean"><xsl:with-param name="value" select="PlantDetails/ExtensionBy50MWOrMore"/></xsl:call-template><xsl:text>,</xsl:text>
                    <xsl:call-template name="number"><xsl:with-param name="value" select="PlantDetails/CapacityAddedMW"/></xsl:call-template><xsl:text>,</xsl:text>
                    <xsl:call-template name="boolean"><xsl:with-param name="value" select="PlantDetails/SubstantialChange"/></xsl:call-template><xsl:text>,</xsl:text>
                    <xsl:call-template name="number"><xsl:with-param name="value" select="PlantDetails/CapacityAffectedMW"/></xsl:call-template><xsl:text>,</xsl:text>
                    <xsl:call-template name="datetime"><xsl:with-param name="value" select="PlantDetails/DateOfStartOfOperation"/></xsl:call-template><xsl:text>,</xsl:text>
                    <xsl:call-template name="boolean"><xsl:with-param name="value" select="PlantDetails/Refineries"/></xsl:call-template><xsl:text>,</xsl:text>
                    <xsl:call-template name="string"><xsl:with-param name="value" select="PlantDetails/OtherSector"/></xsl:call-template><xsl:text>,</xsl:text>
                    <xsl:call-template name="boolean"><xsl:with-param name="value" select="PlantDetails/GasTurbine"/></xsl:call-template><xsl:text>,</xsl:text>
                    <xsl:call-template name="number"><xsl:with-param name="value" select="PlantDetails/GasTurbineThermalInput"/></xsl:call-template><xsl:text>,</xsl:text>
                    <xsl:call-template name="boolean"><xsl:with-param name="value" select="PlantDetails/Boiler"/></xsl:call-template><xsl:text>,</xsl:text>
                    <xsl:call-template name="number"><xsl:with-param name="value" select="PlantDetails/BoilerThermalInput"/></xsl:call-template><xsl:text>,</xsl:text>
                    <xsl:call-template name="boolean"><xsl:with-param name="value" select="PlantDetails/GasEngine"/></xsl:call-template><xsl:text>,</xsl:text>
                    <xsl:call-template name="number"><xsl:with-param name="value" select="PlantDetails/GasEngineThermalInput"/></xsl:call-template><xsl:text>,</xsl:text>
                    <xsl:call-template name="boolean"><xsl:with-param name="value" select="PlantDetails/DieselEngine"/></xsl:call-template><xsl:text>,</xsl:text>
                    <xsl:call-template name="number"><xsl:with-param name="value" select="PlantDetails/DieselEngineTurbineThermalInput"/></xsl:call-template><xsl:text>,</xsl:text>
                    <xsl:call-template name="boolean"><xsl:with-param name="value" select="PlantDetails/Other"/></xsl:call-template><xsl:text>,</xsl:text>
                    <xsl:call-template name="string"><xsl:with-param name="value" select="PlantDetails/OtherTypeOfCombustion"/></xsl:call-template><xsl:text>,</xsl:text>
                    <xsl:call-template name="number"><xsl:with-param name="value" select="PlantDetails/OtherThermalInput"/></xsl:call-template><xsl:text>,</xsl:text>
                    <xsl:call-template name="number"><xsl:with-param name="value" select="PlantDetails/OperatingHours"/></xsl:call-template><xsl:text>,</xsl:text>
                    <xsl:call-template name="string"><xsl:with-param name="value" select="PlantDetails/Comments"/></xsl:call-template><xsl:text>,</xsl:text>

                    <xsl:text>  ID  from Plant where  PlantName =  '</xsl:text><xsl:value-of select="PlantName"/><xsl:text>' AND PlantId = </xsl:text>
                    <xsl:call-template name="string"><xsl:with-param name="value" select="PlantId"/></xsl:call-template><xsl:text> AND
                     FK_BasicData_ID in (
                                        SELECT ID FROM BasicData WHERE Report_ID = </xsl:text><xsl:call-template name="string"><xsl:with-param name="value" select="$reportid"/></xsl:call-template>
                                        <xsl:text> AND MemberState = </xsl:text><xsl:call-template name="string"><xsl:with-param name="value" select="../../BasicData/MemberState"/></xsl:call-template><xsl:text> </xsl:text>
                <xsl:text>);
                </xsl:text>

                <xsl:text> INSERT INTO EnergyInputAndTotalEmissionsToAir(Biomass, OtherSolidFuels, LiquidFuels, NaturalGas, OtherGases, HardCoal, Lignite, SO2, NOx, Dust, FK_Plant_ID) SELECT </xsl:text>
                    <xsl:call-template name="number"><xsl:with-param name="value" select="EnergyInputAndTotalEmissionsToAir/EnergyInput/Biomass"/></xsl:call-template><xsl:text>, </xsl:text>
                    <xsl:call-template name="number"><xsl:with-param name="value" select="EnergyInputAndTotalEmissionsToAir/EnergyInput/OtherSolidFuels"/></xsl:call-template><xsl:text>, </xsl:text>
                    <xsl:call-template name="number"><xsl:with-param name="value" select="EnergyInputAndTotalEmissionsToAir/EnergyInput/LiquidFuels"/></xsl:call-template><xsl:text>, </xsl:text>
                    <xsl:call-template name="number"><xsl:with-param name="value" select="EnergyInputAndTotalEmissionsToAir/EnergyInput/NaturalGas"/></xsl:call-template><xsl:text>, </xsl:text>
                    <xsl:call-template name="number"><xsl:with-param name="value" select="EnergyInputAndTotalEmissionsToAir/EnergyInput/OtherGases"/></xsl:call-template><xsl:text>, </xsl:text>
                    <xsl:call-template name="number"><xsl:with-param name="value" select="EnergyInputAndTotalEmissionsToAir/EnergyInput/HardCoal"/></xsl:call-template><xsl:text>, </xsl:text>
                    <xsl:call-template name="number"><xsl:with-param name="value" select="EnergyInputAndTotalEmissionsToAir/EnergyInput/Lignite"/></xsl:call-template><xsl:text>, </xsl:text>
                    <xsl:call-template name="number"><xsl:with-param name="value" select="EnergyInputAndTotalEmissionsToAir/TotalEmissionsToAir/SO2"/></xsl:call-template><xsl:text>, </xsl:text>
                    <xsl:call-template name="number"><xsl:with-param name="value" select="EnergyInputAndTotalEmissionsToAir/TotalEmissionsToAir/NOx"/></xsl:call-template><xsl:text>, </xsl:text>
                    <xsl:call-template name="number"><xsl:with-param name="value" select="EnergyInputAndTotalEmissionsToAir/TotalEmissionsToAir/Dust"/></xsl:call-template><xsl:text>, </xsl:text>
                    <xsl:text>  ID  from Plant where  PlantName =  '</xsl:text><xsl:value-of select="PlantName"/><xsl:text>' AND PlantId = </xsl:text>
                        <xsl:call-template name="string"><xsl:with-param name="value" select="PlantId"/></xsl:call-template><xsl:text> AND
                                 FK_BasicData_ID in (
                                                    SELECT ID FROM BasicData WHERE Report_ID = </xsl:text><xsl:call-template name="string"><xsl:with-param name="value" select="$reportid"/></xsl:call-template>
                        <xsl:text> AND MemberState = </xsl:text><xsl:call-template name="string"><xsl:with-param name="value" select="../../BasicData/MemberState"/></xsl:call-template><xsl:text> </xsl:text>
                        <xsl:text>);
                        </xsl:text>

                <xsl:text> INSERT INTO OptOutsAndNERP(OptOutPlant, CapacityOptedOutMW, HoursOperated,PlantIncludedInNERP, FK_Plant_ID)  SELECT </xsl:text>
                    <xsl:call-template name="boolean"><xsl:with-param name="value" select="OptOutsAndNERP/OptOutPlant"/></xsl:call-template><xsl:text>, </xsl:text>
                    <xsl:call-template name="number"><xsl:with-param name="value" select="OptOutsAndNERP/CapacityOptedOutMW"/></xsl:call-template><xsl:text>, </xsl:text>
                    <xsl:call-template name="number"><xsl:with-param name="value" select="OptOutsAndNERP/HoursOperated"/></xsl:call-template><xsl:text>, </xsl:text>
                    <xsl:call-template name="boolean"><xsl:with-param name="value" select="OptOutsAndNERP/PlantIncludedInNERP"/></xsl:call-template><xsl:text>, </xsl:text>
                    <xsl:text>  ID  from Plant where  PlantName =  '</xsl:text><xsl:value-of select="PlantName"/><xsl:text>' AND PlantId = </xsl:text>
                    <xsl:call-template name="string"><xsl:with-param name="value" select="PlantId"/></xsl:call-template><xsl:text> AND
                                         FK_BasicData_ID in (
                                                            SELECT ID FROM BasicData WHERE Report_ID = </xsl:text><xsl:call-template name="string"><xsl:with-param name="value" select="$reportid"/></xsl:call-template>
                    <xsl:text> AND MemberState = </xsl:text><xsl:call-template name="string"><xsl:with-param name="value" select="../../BasicData/MemberState"/></xsl:call-template><xsl:text> </xsl:text>
                    <xsl:text>);
                    </xsl:text>

                <xsl:text> INSERT INTO LcpArt15(Art5_1, OperatingHours, ElvSO2, NotaBeneAnnexIII, NotaBeneElvSO2, DesulphurisationRate, SInput, AnnexVI_A_Footnote2,
                    AnnexVI_A_Footnote2_OperatingHours, ElvNOx, AnnexVI_A_Footnote3, VolatileContents, AnnexVI_A_Footnote3_ElvNOx, Comments, FK_Plant_ID) SELECT </xsl:text>
                    <xsl:call-template name="boolean"><xsl:with-param name="value" select="LcpArt15/Art5_1"/></xsl:call-template><xsl:text>,</xsl:text>
                    <xsl:call-template name="number"><xsl:with-param name="value" select="LcpArt15/OperatingHours"/></xsl:call-template><xsl:text>,</xsl:text>
                    <xsl:call-template name="number"><xsl:with-param name="value" select="LcpArt15/ElvSO2"/></xsl:call-template><xsl:text>,</xsl:text>
                    <xsl:call-template name="boolean"><xsl:with-param name="value" select="LcpArt15/NotaBeneAnnexIII"/></xsl:call-template><xsl:text>,</xsl:text>
                    <xsl:call-template name="number"><xsl:with-param name="value" select="LcpArt15/NotaBeneElvSO2"/></xsl:call-template><xsl:text>,</xsl:text>
                    <xsl:call-template name="number"><xsl:with-param name="value" select="LcpArt15/DesulphurisationRate"/></xsl:call-template><xsl:text>,</xsl:text>
                    <xsl:call-template name="number"><xsl:with-param name="value" select="LcpArt15/SInput"/></xsl:call-template><xsl:text>,</xsl:text>
                    <xsl:call-template name="boolean"><xsl:with-param name="value" select="LcpArt15/AnnexVI_A_Footnote2"/></xsl:call-template><xsl:text>,</xsl:text>
                    <xsl:call-template name="number"><xsl:with-param name="value" select="LcpArt15/AnnexVI_A_Footnote2_OperatingHours"/></xsl:call-template><xsl:text>,</xsl:text>
                    <xsl:call-template name="number"><xsl:with-param name="value" select="LcpArt15/ElvNOx"/></xsl:call-template><xsl:text>,</xsl:text>
                    <xsl:call-template name="boolean"><xsl:with-param name="value" select="LcpArt15/AnnexVI_A_Footnote3"/></xsl:call-template><xsl:text>,</xsl:text>
                    <xsl:call-template name="number"><xsl:with-param name="value" select="LcpArt15/VolatileContents"/></xsl:call-template><xsl:text>,</xsl:text>
                    <xsl:call-template name="number"><xsl:with-param name="value" select="LcpArt15/AnnexVI_A_Footnote3_ElvNOx"/></xsl:call-template><xsl:text>,</xsl:text>
                    <xsl:call-template name="string"><xsl:with-param name="value" select="LcpArt15/Comments"/></xsl:call-template><xsl:text>,</xsl:text>
                    <xsl:text>  ID  from Plant where  PlantName =  '</xsl:text><xsl:value-of select="PlantName"/><xsl:text>' AND PlantId = </xsl:text>
                    <xsl:call-template name="string"><xsl:with-param name="value" select="PlantId"/></xsl:call-template><xsl:text> AND
                                         FK_BasicData_ID in (
                                                            SELECT ID FROM BasicData WHERE Report_ID = </xsl:text><xsl:call-template name="string"><xsl:with-param name="value" select="$reportid"/></xsl:call-template>
                    <xsl:text> AND MemberState = </xsl:text><xsl:call-template name="string"><xsl:with-param name="value" select="../../BasicData/MemberState"/></xsl:call-template><xsl:text> </xsl:text>
                        <xsl:text>);
                        </xsl:text>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="statementSeparator">
        <xsl:if test="$commandline='false'"> </xsl:if>
        <xsl:text> </xsl:text>
    </xsl:template>


</xsl:stylesheet>