<?xml version="1.0" encoding="UTF-8"?>
<!-- Comments
  - Person and Organization: 
      - altIdentifier iwith ivoid or ror
      - regexp '[Tt]eam*'
  - Affiliation: - 
  - relationships: manage all
  - rights: improve when http spdx and spdx name
  - openAPI
  - capabilty: we should have always a description?
  - tofix adress in vcard
  - UAT (keywords?)
  - link distribution with table when capability.interface.httpparam.stats
  - tableset only when resourceType is CatalogueResource or CatalogueService

    Choice:
  - use citedcat (as Zenodo) : not dcat vocabulary
  - use dcat:Catalogue for CatalogueService, CatalogueResource
  - add tables in a relation dcat:catalog dcat:DataSet
-->
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
 xmlns=""
 xmlns:oai="http://www.openarchives.org/OAI/2.0/" 
 xmlns:ri="http://www.ivoa.net/xml/RegistryInterface/v1.0" 
 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd http://www.ivoa.net/xml/RegistryInterface/v1.0 http://www.ivoa.net/xml/RegistryInterface/RegistryInterface-1.0.xsd"
 xmlns:regexp="http://exslt.org/regular-expressions"
 exclude-result-prefixes="oai"
>
<xsl:output method="xml" indent="yes"/>


<xsl:template match="/">

<!-- OAI-PMH header 
     copy responseDate but adapt request  to modify metadataPrefix
-->
<OAI-PMH xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd http://www.ivoa.net/xml/RegistryInterface/v1.0 http://www.ivoa.net/xml/RegistryInterface/RegistryInterface-1.0.xsd">
    <xsl:variable name="ivoid" select="oai:OAI-PMH/oai:request/@identifier"/>

    <responseDate><xsl:value-of select="oai:OAI-PMH/oai:responseDate"/></responseDate>
    <request>
        <xsl:attribute name="verb"><xsl:value-of select="oai:OAI-PMH/oai:request/@verb"/></xsl:attribute>
        <xsl:attribute name="metadataPrefix">dcat</xsl:attribute>
        <xsl:attribute name="identifier"><xsl:value-of select="$ivoid"/></xsl:attribute>
        <xsl:value-of select="oai:OAI-PMH/oai:request"/>
    </request>


    <getRecord>
        <xsl:for-each select="//ri:Resource">
        <record>
            <!-- Copy the record header -->
            <xsl:copy-of select="/oai:OAI-PMH/oai:GetRecord/oai:record/oai:header"/>

            <metadata>
            <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                     xmlns:adms="http://www.w3.org/ns/adms#"
                     xmlns:bibo="http://purl.org/ontology/bibo/" 
                     xmlns:citedcat="https://w3id.org/citedcat-ap/" 
                     xmlns:dct="http://purl.org/dc/terms/" 
                     xmlns:dctype="http://purl.org/dc/dcmitype/" 
                     xmlns:dcat="http://www.w3.org/ns/dcat#" 
                     xmlns:foaf="http://xmlns.com/foaf/0.1/"
                     xmlns:gsp="http://www.opengis.net/ont/geosparql#"
                     xmlns:locn="http://www.w3.org/ns/locn#"
                     xmlns:org="http://www.w3.org/ns/org#"
                     xmlns:owl="http://www.w3.org/2002/07/owl#"
                     xmlns:prov="http://www.w3.org/ns/prov#"
                     xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                     xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                     xmlns:vcard="http://www.w3.org/2006/vcard/ns#"
                     xmlns:wdrs="http://www.w3.org/2007/05/powder-s#" 
                     xmlns:vs="http://www.ivoa.net/xml/VODataService/v1.1#">
            <rdf:Description>

            <!-- get the xsi:type : CataLogueService, ResourceService, DataService, DataResource -->
            <xsl:choose>
                <xsl:when test="contains(@xsi:type, 'vs:CatalogService')">
                    <!-- Service exclusively dedicated for resoures declared in the resource-level 
                         include: CatalogueResource
                    -->
                    <rdf:type rdf:resource="http://www.w3.org/ns/dcat#Catalogue"/>
                    <dct:type rdf:resource="http://purl.org/dc/dcmitype/Dataset"/>
                </xsl:when>
                <xsl:when test="contains(@xsi:type, 'CatalogueResource')">
                    <!-- Structured Data possibly having capabilities 
                         include: tableset
                    -->
                    <rdf:type rdf:resource="http://www.w3.org/ns/dcat#Catalogue"/>
                    <dct:type rdf:resource="http://purl.org/dc/dcmitype/Dataset"/>
                </xsl:when>
                <xsl:when test="contains(@xsi:type, 'DataService')">
                     <!-- like DataResource with a main Service 
                          include: DataResource
                     -->
                     <rdf:type rdf:resource="http://www.w3.org/ns/dcat#Service"/>
                </xsl:when>
                <xsl:when test="contains(@xsi:type, 'DataResource')">
                     <!-- Unstrustured data, possily having capabilities
                        include: coverage, intrument, facility, productTypeServed
                     -->
                     <rdf:type rdf:resource="http://www.w3.org/ns/dcat#Catalogue"/>
                </xsl:when>
                <xsl:otherwise>
                     <rdf:type rdf:resource="http://www.w3.org/ns/dcat#Resource"/><!--check syntaxe and rdf -->
                </xsl:otherwise>
            </xsl:choose>
           

            <!-- creator(s) -->

            <xsl:for-each select="./curation/creator">
                <dct:creator>
                    <rdf:Description>
                        <xsl:choose>
                            <xsl:when test="contains(./@altIdentifier, 'orcid')">
                                <xsl:attribute name="rdf:about"><xsl:value-of select="./@altIdentifier"/></xsl:attribute>
                                <rdf:type rdf:resource="https://xmlns.com/foaf/0.1/Person"/>
                            </xsl:when>
                            <xsl:when test="contains(./@altIdentifier, 'ror') or contains(./altIdentifier, 'ivoid')">
                                <xsl:attribute name="rdf:about"><xsl:value-of select="./@altIdentifier"/></xsl:attribute>
                                <rdf:type rdf:resource="https://xmlns.com/foaf/0.1/Person"/><!-- TODO : how to distinguish Person and Orgaizaton -->
                            </xsl:when>
                            <xsl:otherwise>
                                <!-- by default consider a Person -->
                                <rdf:type rdf:resource="https://xmlns.com/foaf/0.1/Person"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <foaf:name><xsl:value-of select="name"/></foaf:name>
                    </rdf:Description>
                    <!--TODO affiliation (do not exist in VOResource) -->
                </dct:creator>
            </xsl:for-each>


            <!-- title -->
            <xsl:if test="./title"><dct:title><xsl:value-of select="./title"/></dct:title></xsl:if>

            <!-- publisher : assume a foaf:Organization -->
            <xsl:for-each select=".//curation/publisher">
                <dct:publisher>
                    <foaf:Organization>
                        <xsl:if test="./@ivo-id">
                            <!-- is it better infoaf:nick ? -->
                            <xsl:attribute name="rdf:about"><xsl:value-of select="./@ivo-id"/></xsl:attribute>
                        </xsl:if>
                        <foaf:name><xsl:value-of select="."/></foaf:name>
                        <xsl:if test="./@altIdentifier">
                            <!-- RoR : is it better in rdf:about-->
                            <foaf:nick><xsl:value-of select="./@altIdentifier"/></foaf:nick>
                        </xsl:if>
                    </foaf:Organization>
                </dct:publisher>  
            </xsl:for-each>

            <!-- date(s) -->

            <xsl:for-each select="./curation/date">
                <xsl:if test="@role='Created'">
                    <dct:created rdf:datatype="http://www.w3.org/2001/XMLSchema#date"><xsl:value-of select="."/></dct:created><!-- or use issued ? -->
                </xsl:if>
                <xsl:if test="@role='Updated'">
                    <dct:modified rdf:datatype="http://www.w3.org/2001/XMLSchema#date"><xsl:value-of select="."/></dct:modified>
                </xsl:if>
            </xsl:for-each>

            <!-- other names: altIdentifier + shortName -->
            <xsl:if test="$ivoid">
                <adms:identifier>
                    <adms:Identifier>
                        <skos:notation rdf:datatype="http://www.w3.org/2001/XMLSchema#anyURI"><xsl:value-of select="$ivoid"/></skos:notation>
                        <adms:schemeAgency>ivo-id</adms:schemeAgency>
                    </adms:Identifier>
                </adms:identifier>
            </xsl:if>

            <!-- using adms:identifier is used by zenodo but we could also use owl:sameas which is used in zenodo  -->
            <xsl:for-each select="./altIdentifier">
                <xsl:variable name="lower" select="translate(.,'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
                <xsl:if test="contains($lower,'doi:')">
                    <adms:identifier>
                        <adms:Identifier>
                            <skos:notation rdf:datatype="http://www.w3.org/2001/XMLSchema#anyURI"><xsl:value-of select="."/></skos:notation>
                            <adms:schemeAgency>DOI</adms:schemeAgency>
                        </adms:Identifier>
                    </adms:identifier>
                </xsl:if>
            </xsl:for-each>
            <xsl:if test="./shortName">
                <dct:identifier><xsl:value-of select="./shortName"></xsl:value-of></dct:identifier>
            </xsl:if>

            <!--  contact -->

            <xsl:for-each select="./curation/contact">
                <dcat:contactPoint>
                    <vcard:Organization>
                        <xsl:if test="./name"><vcard:fn><xsl:value-of select="./name"/></vcard:fn></xsl:if>
                        <xsl:if test="./address"><vcard:address><xsl:value-of select="./address"/></vcard:address></xsl:if> <!-- not sure that it is accepted in vcard -->
                        <xsl:if test="./email">
                             <xsl:variable name='email' select="./email"/>
                            <vcard:email><xsl:value-of select="./email"/></vcard:email>
                        </xsl:if>
                    </vcard:Organization>
                </dcat:contactPoint> 
            </xsl:for-each>
    
            <!-- subject(s) -->

            <xsl:for-each select="./content/subject">
                <dcat:keyword><xsl:value-of select="."/></dcat:keyword> <!-- there is also dcat:keyword ?? -->
                <!-- if theme UAT, we could <dct:term  rdf:resource="http://www.ivoa.net/rdf/#...."/>  -->
            </xsl:for-each>

            <!-- description -->

            <xsl:if test="./content/description">
                <dct:description><xsl:value-of select="./content/description"/></dct:description>
            </xsl:if>

            <!-- source -->
            <xsl:for-each select="./content/source">
                <citedcat:isSupplementTo> <!-- that's not dcat but CiteDCAT-AP. It is used in zenodo, else use dcat:RelatinShip -->
                    <rdf:Description>
                        <xsl:choose>
                            <xsl:when test="contains(.,'doi:')"><!-- add type see dcat: 8.1 -->
                                <xsl:attribute name="rdf:about"><xsl:value-of select="."/></xsl:attribute>
                            </xsl:when>
                            <xsl:otherwise>  <!-- guess it is  a bibcode -->
                                <xsl:attribute name="rdf:about">https://ui.adsabs.harvard.edu/abs/<xsl:value-of select="."/></xsl:attribute>
                            </xsl:otherwise> 
                        </xsl:choose>
                        <dct:identifier><xsl:value-of select="."/></dct:identifier> <!-- may be possible to define the type DOI, bibcode...? -->
                        <rdf:type rdf:resource="https://www.ivoa.net/rdf/voresource/content_type/content_type.html#Bibliography"/>
                    </rdf:Description>
                </citedcat:isSupplementTo>
            </xsl:for-each>

            <!-- referenceURL -->

            <xsl:if test="./content/referenceURL">
                <dcat:landingpage><xsl:value-of select="./content/referenceURL"/></dcat:landingpage><!-- value shoud be foaf:Document -->
            </xsl:if>

            <!-- type : I don't know what todo with that (controled voc: https://www.ivoa.net/rdf/voresource/content_type/2016-08-17/content_type.html) -->
    
            <xsl:for-each select="./content/type">
                <dct:type>http://www.ivoa.net/rdf/voresource/content_type#<xsl:value-of select="."/></dct:type> <!-- or use att rdf:resource="http://www.ivoa.net/rdf... -->
            </xsl:for-each>

            <!-- contentLevel -->
            <xsl:for-each select="./content/contentLevel">
                <adms:status>http://www.ivoa.net/rdf/voresource/content_level#<xsl:value-of select="."/></adms:status><!-- or use att rdf:resource="http://www.ivoa.net/rdf... -->
            </xsl:for-each>

            <!-- relationships (isServedBy) -->

            <xsl:for-each select="./content/relationship">
                <xsl:if test="./relationshipType='IsServedBy'">
                    <xsl:choose>
                        <xsl:when test="contains(./relatedResource/@ivo-id,'ivo://')">
                            <dcat:distribution>
                                <dcat:Distribution>
                                    <!--xsl:attribute name="rdf:about"><xsl:value-of select="./relatedResource/@ivo-id"/></xsl:attribute-->
                                    <!--dct:identifier><xsl:value-of select="./relatedResource/@ivo-id"/></dct:identifier-->
                                    <dcat:accessService>
                                        <dcat:Service><xsl:attribute name="rdf:about"><xsl:value-of select="./relatedResource/@ivo-id"/></xsl:attribute></dcat:Service>
                                    </dcat:accessService>
                                    <xsl:if test="description"><dct:description><xsl:value-of select="./relatedResource"/></dct:description></xsl:if>
                                    <dct:conformsTo></dct:conformsTo>
                                </dcat:Distribution>
                            </dcat:distribution>
                        </xsl:when>
                    </xsl:choose>
                </xsl:if>
            </xsl:for-each>

            <!-- relationships (others) -->

            <xsl:for-each select="./content/relationship">
                <xsl:choose>
                    <xsl:when test="./relationshipType='IsServedBy'">
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="relationName">
                            <xsl:choose>
                                <xsl:when test="relationshipType='isSupplementTo'">
                                    <xsl:text>citedcat:isSupplementTo</xsl:text>
                                </xsl:when>
                                <xsl:when test="relationshipType='Cites'">
                                    <xsl:text>bibo:Cites</xsl:text>
                                <xsl:variable name="relationName" select="bibo:Cites"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>dct:relation</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
        
                        <xsl:for-each select="relatedResource">
                            <xsl:element name="{$relationName}">
                            <xsl:choose>
                                <xsl:when test="@ivo-id"> <!-- TODO DOI and other -->
                                        <xsl:element name="Description">
                                            <xsl:attribute name="rdf:about"><xsl:value-of select="@ivo-id"/></xsl:attribute>
                                            <dct:identifier><xsl:value-of select="@ivo-id"/></dct:identifier>
                                            <!--the folowing type could be wrong, but I don't know how to know the type -->
                                            <!--xsl:element name="rdf:type">
                                                <xsl:attribute name="rdf:resource">http://www.ivoa.net/xml/VODataService/v1.1#CatalogueResource</xsl:attribute> 
                                            </xsl:element-->
                                            <xsl:element name="rdf:type">
                                                <xsl:attribute name="rdf:resource">http://www.w3.org/ns/dcat#DataSet</xsl:attribute>
                                            </xsl:element>
                                        </xsl:element>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="."/>
                                </xsl:otherwise>
                            </xsl:choose>
                            </xsl:element>
                        </xsl:for-each>
                    </xsl:otherwise>        
                </xsl:choose>
            </xsl:for-each>

            <!-- rights -->

            <xsl:for-each select="./rights">
                <dct:rights><xsl:value-of select="."/></dct:rights> <!-- todo disinguish when there is a license using <dct:license> -->
            </xsl:for-each>


            <!-- capability -->
            <xsl:for-each select="./capability">
                <xsl:variable name="std"><xsl:value-of select="@standardID"/></xsl:variable>
                <xsl:for-each select="./interface">
                    <xsl:variable name="stdDesc">
                        <xsl:choose> <!-- set default description -->
                            <xsl:when test="contains($std, 'ConeSearch')"><xsl:text>Data access using the Simple Cone Search</xsl:text></xsl:when>
                            <xsl:when test="contains($std, 'TAP')"><xsl:text>Data access using the Table Access protocol using ADQL</xsl:text></xsl:when>
                            <xsl:when test="contains($std, 'SIA')"><xsl:text>Data access using the Simple Image Access</xsl:text></xsl:when>
                            <xsl:when test="contains($std, 'SSA')"><xsl:text>Data access using the Simple Spectra Access</xsl:text></xsl:when>
                            <xsl:when test="contains(@xsi:type,'WebBrowser')">Data access using web browser</xsl:when><!-- vs:WebBrowser -->
                            <xsl:when test="contains(@xsi:type,'ParamHTTP')">Other HTTP Data access</xsl:when> <!-- vs:ParamHTTP -->
                        </xsl:choose>
                    </xsl:variable>
                    <dcat:distribution>
                    <dcat:Distribution>
                        <xsl:if test="description"><dct:description><xsl:value-of select="description"/></dct:description></xsl:if>
                        <dct:description><xsl:value-of select="$stdDesc"/></dct:description>
                        
                        <xsl:variable name="url"><xsl:value-of select="accessURL"/></xsl:variable>
                        <xsl:if test="accessURL">
                            <dcat:accessURL>
                                <xsl:attribute name="rdf:resource"><xsl:value-of select="$url"/></xsl:attribute>
                            </dcat:accessURL>
                        </xsl:if>
                        <xsl:if test="$std!=''"><!-- not in zenodo -->
                            <dcat:conformTo><xsl:value-of select="$std"/></dcat:conformTo>
                        </xsl:if>

                        <xsl:for-each select="./resultType">
                            <dct:formats><xsl:value-of select="."/></dct:formats>
                        </xsl:for-each>

                        <xsl:if test="$std!=''">
                            <dcat:accessService>
                                <dcat:DataService>
                                    <xsl:if test="@ivo-id"><dct:identifier><xsl:value-of select="@ivo-id"/></dct:identifier></xsl:if>
                                    <dcat:endpointURL><xsl:value-of select="$url"/></dcat:endpointURL>
                                    <dcat:endpointURLDescription>https://ivo.net/openAPI/...</dcat:endpointURLDescription><!-- I have no URL today -->
                                </dcat:DataService>
                            </dcat:accessService>

                            <xsl:for-each select="mirrorURL">
                                <dcat:accessService>
                                    <dcat:DataService>
                                        <dcat:endpointURL><xsl:value-of select="."/></dcat:endpointURL>
                                        <dcat:endpointURLDescription>https://ivo.net/openAPI/...</dcat:endpointURLDescription><!-- I have no URL today -->
                                    </dcat:DataService>
                                </dcat:accessService>
                            </xsl:for-each>
                        </xsl:if>

                        <!--xsl:for-each select="mirrorURL">
                            <dcat:accessURL>
                                <xsl:attribute name="rdf:resource"><xsl:value-of select="."/></xsl:attribute>
                            </dcat:accessURL>
                        </xsl:for-each-->
                    </dcat:Distribution>
                    </dcat:distribution>
                </xsl:for-each>
            </xsl:for-each>

            <!-- Coverage -->
            <xsl:if test="./coverage">
                <vs:coverage>
                    <vs:Coverage>
                    <!--rdf:Description-->
                    <xsl:if test="./coverage/spatial">
                        <vs:spatial><xsl:value-of select="./coverage/spatial"/></vs:spatial>
                    </xsl:if>
                    <xsl:if test="./coverage/footprint">
                        <vs:footprint>
                            <xsl:if test="./coverage/footprint/@ivo-id">
                                <xsl:attribute name="ivo-id"><xsl:value-of select="./coverage/footprint/@ivo-id"/></xsl:attribute>
                            </xsl:if>
                            <xsl:value-of select="./coverage/footprint"/>
                        </vs:footprint>
                    </xsl:if>
                    <xsl:if test="./coverage/waveband">
                        <vs:waveband><xsl:value-of select="./coverage/waveband"/></vs:waveband>
                    </xsl:if>
                    <!--/rdf:Description-->
                    </vs:Coverage>
                </vs:coverage>
            </xsl:if>

            <!-- tableset -->
            <xsl:if test="contains(@xsi:type, 'vs:CatalogResource') or contains(@xsi:type, 'vs:CatalogService')">
            <xsl:for-each select="./tableset">
                <xsl:for-each select="schema"><!-- I consider schema as a Catalog -->
                    <xsl:for-each select="table">
                        <dcat:dataset>
                            <dcat:DataSet>
                                <dct:identifier><xsl:value-of select="name"/></dct:identifier>

<xsl:variable name='name' select="name"/>
<!--xsl:if test="//ri:Resource/capability/interface/inputParam/stats/option/.=name"-->
<xsl:for-each select="//ri:Resource/capability/interface">
    <xsl:variable name='access' select="accessURL/."/>
    <xsl:if test="./inputParam/stats/option/.=$name">
        <!-- distribution directly in table -->
        <dcat:distribution>
            <dcat:Distribution>
                <dcat:accessService>
                    <dcat:DataService>
                        <dcat:endpointURL><xsl:value-of select="$access"/></dcat:endpointURL>
                    </dcat:DataService>
                </dcat:accessService>
            </dcat:Distribution>
        </dcat:distribution>
    </xsl:if>
</xsl:for-each>
                                <vs:table>
                                    <!--rdf:Description>
                                        <rdf:type rdf:resource="http://www.ivoa.net/xml/VODataService/v1.1#Table"/-->
                                    <vs:Table>
                                        <vs:name><xsl:value-of select="name"/></vs:name>
                                        <vs:description><xsl:value-of select="description"/></vs:description>
                                        <xsl:for-each select="column">
                                            <vs:column>
                                                <!--rdf:Description-->
                                                <vs:Column>
                                                    <vs:name><xsl:value-of select="name"/></vs:name>
                                                    <xsl:if test="description"><vs:description><xsl:value-of select="description"/></vs:description></xsl:if>
                                                    <xsl:if test="unit"><vs:unit><xsl:value-of select="unit"/></vs:unit></xsl:if>
                                                    <xsl:if test="ucd"><vs:ucd><xsl:value-of select="ucd"/></vs:ucd></xsl:if>
                                                    <xsl:if test="flag"><vs:flag><xsl:value-of select="flag"/></vs:flag></xsl:if>
                                                    <xsl:if test="dataType">
                                                        <vs:dataType>
                                                            <xsl:if test="dataType/@arraysize"><xsl:attribute name="arraysize"><xsl:value-of select="dataType/@arraysize"/></xsl:attribute></xsl:if>
                                                            <xsl:if test="dataType/@xsi:type"><xsl:attribute name="type"><xsl:value-of select="dataType/@xsi:type"/></xsl:attribute></xsl:if>
                                                            <xsl:value-of select="dataType"/>
                                                        </vs:dataType>
                                                    </xsl:if>
                                                <!--/rdf:Description-->
                                                </vs:Column>
                                            </vs:column>
                                        </xsl:for-each>
                                    <!--/rdf:Description-->
                                    </vs:Table>
                                </vs:table>
                            </dcat:DataSet>
                        </dcat:dataset>
                    </xsl:for-each>
                </xsl:for-each>
            </xsl:for-each>
            </xsl:if>

            </rdf:Description>
            </rdf:RDF>

            </metadata>
        </record>
        </xsl:for-each>
    </getRecord>
</OAI-PMH>

</xsl:template>
</xsl:transform>

