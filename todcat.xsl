<?xml version="1.0" encoding="UTF-8"?>
<!-- Comments
  - manage also Service
  - how to distinguish Person and Organization
  - Affiliation is not in VOResource
  - relationships: manage doi or bibcode
  - relationships: manage other thatrelated-to and isServedBy and isSuplementTo
  - rights: improve when http spdx and spdx name
  - openAPI
  - capabilty: we should have always a description?

    Choice:
  - relations use distribution (or citedcat)
  - table description: Catalog (schema), then  Datasets (tables) 
  - use citedcat  (not dcat): ivoa:CatalogueResource and dcat:Datasetto the type of relations
-->
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
 xmlns=""
 xmlns:oai="http://www.openarchives.org/OAI/2.0/" 
 xmlns:ri="http://www.ivoa.net/xml/RegistryInterface/v1.0" 
 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd http://www.ivoa.net/xml/RegistryInterface/v1.0 http://www.ivoa.net/xml/RegistryInterface/RegistryInterface-1.0.xsd"
 xmlns:regexp="http://exslt.org/regular-expressions"
>
<!--xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
 xmlns:oai="http://www.openarchives.org/OAI/2.0/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd http://www.ivoa.net/xml/RegistryInterface/v1.0 http://www.ivoa.net/xml/RegistryInterface/RegistryInterface-1.0.xsd"
 xmlns:ri="http://www.ivoa.net/xml/RegistryInterface/v1.0" 
-->
<xsl:output method="xml" indent="yes"/>

<!--xsl:when test="oai:GetRecord/oai:record/ri:Resource/@xsi:type='vs:CatalogService'"-->
<xsl:template match="*">

<!-- opy OAI-PMH header -->
<OAI-PMH xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd http://www.ivoa.net/xml/RegistryInterface/v1.0 http://www.ivoa.net/xml/RegistryInterface/RegistryInterface-1.0.xsd">
<xsl:if test='//datestamp'>
<yes/>
    <responseDate><xsl:value-of select="//responseDate"></xsl:value-of></responseDate>
</xsl:if>
<request/>
<getRecord><record>

<header>
    <xsl:if test="//identifier"><!-- fails if //hedarer/identifier ???-->
    <identifier><xsl:value-of select="//identifier"></xsl:value-of></identifier>
    </xsl:if>
    <xsl:for-each select="//setSpec"><!-- fails if //hedarer/identifier ???-->
    <setSpec><xsl:value-of select="."></xsl:value-of></setSpec>
    </xsl:for-each>
</header>
<metadata>


<xsl:choose>
<xsl:when test="*">
  <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:adms="http://www.w3.org/ns/adms#" xmlns:bibo="http://purl.org/ontology/bibo/" xmlns:citedcat="https://w3id.org/citedcat-ap/" xmlns:dct="http://purl.org/dc/terms/" xmlns:dctype="http://purl.org/dc/dcmitype/" xmlns:dcat="http://www.w3.org/ns/dcat#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:gsp="http://www.opengis.net/ont/geosparql#" xmlns:locn="http://www.w3.org/ns/locn#" xmlns:org="http://www.w3.org/ns/org#" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:prov="http://www.w3.org/ns/prov#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:vcard="http://www.w3.org/2006/vcard/ns#" xmlns:wdrs="http://www.w3.org/2007/05/powder-s#" 
xmlns:ivods="http://www.ivoa.net/xml/VODataService/v1.1"> <!--Add VODataService-->
  <rdf:Description>

    <rdf:type rdf:resource="http://www.w3.org/ns/dcat#Catalogue"/><!--check syntaxe and rdf -->
    <dct:type rdf:resource="http://purl.org/dc/dcmitype/Dataset"/>

    <!-- creator(s) -->

    <xsl:for-each select="//ri:Resource/curation/creator">
        <dct:creator>
            <rdf:Description>
            <xsl:choose>
                <xsl:when test="contains(./altIdentifier, 'orcid')">
                    <!-- add orcid if exists  in rdf:about -->
                    <xsl:attribute name="rdf:about"><xsl:value-of select="./altIdentifier"/></xsl:attribute>
                </xsl:when>
            </xsl:choose>
                <rdf:type rdf:Resource="https://xmlns.com/foaf/0.1/Person"><!-- TODO : how to distinguish Person and Orgaizaton -->
                    <foaf:name><xsl:value-of select="name"/></foaf:name>
                </rdf:type>
            </rdf:Description>
            <!--TODO affiliation (do not exist in VOResource) -->
        </dct:creator>
    </xsl:for-each>

    <!-- title -->
    <xsl:if test="//ri:Resource/title"><dct:title><xsl:value-of select="//ri:Resource/title"/></dct:title></xsl:if>

    <!-- publisher -->
    <xsl:for-each select="//curation/publisher">
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

    <xsl:for-each select="//ri:Resource/curation/date">
    <xsl:if test="@role='Created'">
    <dct:created rdf:datatype="http://www.w3.org/2001/XMLSchema#date"><xsl:value-of select="."/></dct:created><!-- or use issued ? -->
    </xsl:if>
    <xsl:if test="@role='Updated'">
    <dct:modified rdf:datatype="http://www.w3.org/2001/XMLSchema#date"><xsl:value-of select="."/></dct:modified>
    </xsl:if>
    </xsl:for-each>

    <!-- other names: altIdentifier + shortName -->
    <xsl:if test="//identifier"><!-- fails if //hedarer/identifier ???-->
    <adms:identifier>
        <adms:Identifier>
            <skos:notation rdf:datatype="http://www.w3.org/2001/XMLSchema#anyURI"><xsl:value-of select="//identifier"/></skos:notation>
            <adms:schemeAgency>ivo-id</adms:schemeAgency>
        </adms:Identifier>
    </adms:identifier>
    </xsl:if>

    <!-- using adms:identifier is used by zenodo but we could also use owl:sameas which is used in zenodo  -->
    <xsl:for-each select="//ri:Resource/altIdentifier">
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
    <xsl:if test="//ri:Resource/shortName">
    <!--adms:identifier>
        <adms:Identifier>
            <skos:notation rdf:datatype="http://www.w3.org/2001/XMLSchema#anyURI"><xsl:value-of select="//ri:Resource/shortName"/></skos:notation>
        </adms:Identifier>
    </adms:identifier-->
        <dct:identifier><xsl:value-of select="//ri:Resource/shortName"></xsl:value-of></dct:identifier>
    </xsl:if>

    <!--  contact -->

    <xsl:if test="//ri:Resource/curation/contact">
    <dcat:contactPoint>
        <vcard:Organization>
            <xsl:if test="//curation/contact/name"><vcard:fn><xsl:value-of select="//curation/contact/name"/></vcard:fn></xsl:if>
            <xsl:if test="//curation/contact/address"><vcard:Address><xsl:value-of select="//curation/contact/address"/></vcard:Address></xsl:if> <!-- not sure that it is accepted in vcard -->
            <xsl:if test="//curation/contact/email">
                <xsl:variable name='email' select="//curation/contact/email"/>
                <vcard:email><xsl:value-of select="//curation/contact/email"/></vcard:email>
            </xsl:if>
        </vcard:Organization>
    </dcat:contactPoint> 
    </xsl:if>
    
    <!-- subject(s) -->
    <xsl:for-each select="//ri:Resource/content/subject">
    <dcat:keyword><xsl:value-of select="."/></dcat:keyword> <!-- there is also dcat:keyword ?? -->
    <!-- if theme UAT, we could <dct:term  rdf:resource="http://www.ivoa.net/rdf/#...."/>  -->
    </xsl:for-each>

    <!-- description -->
    <xsl:if test="//ri:Resource/content/description">
    <dct:description><xsl:value-of select="//ri:Resource/content/description"/></dct:description>
    </xsl:if>

    <!-- source -->
    <xsl:for-each select="//ri:Resource/content/source">
    <citedcat:isSupplementTo> <!-- that's not dcat but CiteDCAT-AP. It is used in zenodo, else use dcat:RelatinShip -->
        <rdf:Description>
            <xsl:choose>
                <xsl:when test="contains(.,'doi:')"><!-- add type see dcat: 8.1 -->
                    <xsl:attribute name="rdf:about"><xsl:value-of select="."/></xsl:attribute>
                </xsl:when>
                <xsl:otherwise>  <!-- guess it is  a bibcode -->
                    <xsl:attribute name="rdf:about">https://ui.adsabs.harvard.edu/abs/2021A%26A...654A.108S/abstract/<xsl:value-of select="."/></xsl:attribute>
                </xsl:otherwise> 
            </xsl:choose>
            <dct:identifier><xsl:value-of select="."/></dct:identifier> <!-- may be possible to define the type DOI, bibcode...? -->
            <dct:type rdf:resource="https://www.ivoa.net/rdf/voresource/content_type/content_type.html#Bibliography"/>
        </rdf:Description>
    </citedcat:isSupplementTo>
    </xsl:for-each>

    <!-- referenceURL -->
    <xsl:if test="//ri:Resource/content/referenceURL">
        <dcat:landingpage><xsl:value-of select="//ri:Resource/content/referenceURL"/></dcat:landingpage><!-- value shoud be foaf:Document -->
    </xsl:if>

    <!-- type : I don't know what todo with that (controled voc: https://www.ivoa.net/rdf/voresource/content_type/2016-08-17/content_type.html) -->
    
    <xsl:for-each select="//ri:Resource/content/type">
        <dct:type>http://www.ivoa.net/rdf/voresource/content_type#<xsl:value-of select="."/></dct:type> <!-- or use att rdf:resource="http://www.ivoa.net/rdf... -->
    </xsl:for-each>

    <!-- contentLevel -->
    <xsl:for-each select="//ri:Resource/content/contentLevel">
        <adms:status>http://www.ivoa.net/rdf/voresource/content_level#<xsl:value-of select="."/></adms:status><!-- or use att rdf:resource="http://www.ivoa.net/rdf... -->
    </xsl:for-each>

    <!-- relationships (isServedBy) -->
    <xsl:for-each select="//ri:Resource/content/relationship">
        <xsl:if test="./relationshipType='IsServedBy'">
    <dcat:Distribution>
        <dcat:AccessService>
            <xsl:choose>
                <xsl:when test="contains(./relatedResource/@ivo-id,'ivo://')"><!-- not dure about the serialization -->
                    <xsl:element name="Description"> <!-- that's not dcat but used in zenodo -->
                        <xsl:attribute name="rdf:about"><xsl:value-of select="./relatedResource/@ivo-id"/></xsl:attribute>
                        <dct:identifier><xsl:value-of select="./relatedResource/@ivo-id"/></dct:identifier>
                        <xsl:element name="rdf:type">
                            <xsl:attribute name="rdf:resource">http://www.w3.org/ns/dcat#Service</xsl:attribute>
                        </xsl:element>
                        <xsl:element name="rdf:type">
                            <xsl:attribute name="rdf:resource">http://purl.org/dc/dcmitype/Service</xsl:attribute>
                        </xsl:element>
                    </xsl:element>
                </xsl:when>

                <xsl:otherwise>  <!-- do nothing -> see capability -->                                        
                </xsl:otherwise>        
            </xsl:choose>
            <dcat:DataService>
            </dcat:DataService>
        </dcat:AccessService>
    </dcat:Distribution>
        </xsl:if>
    </xsl:for-each>

    <!-- relationships (others) -->
    <xsl:for-each select="//ri:Resource/content/relationship">
        <xsl:choose>
            <xsl:when test="relationshipType='isSupplementTo'">
                <xsl:for-each select="relatedResource">
                    <xsl:if test="@ivo-id"> <!-- TODO DOI and other -->
                    <citedcat:isSupplementTo>
                        <xsl:element name="Description">
                            <xsl:attribute name="rdf:about"><xsl:value-of select="@ivo-id"/></xsl:attribute>
                            <dct:identifier><xsl:value-of select="@ivo-id"/></dct:identifier>
                            <xsl:element name="rdf:type">
                                <xsl:attribute name="rdf:resource">http://www.ivoa.net/xml/VODataService/v1.1#CatalogueResource</xsl:attribute> <!--that could be wrong, but I don't know how to know the type -->
                            </xsl:element>
                            <xsl:element name="rdf:type">
                                <xsl:attribute name="rdf:resource">http://www.w3.org/ns/dcat#DataSet</xsl:attribute>
                            </xsl:element>
                        </xsl:element>
                    </citedcat:isSupplementTo>
                    </xsl:if>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="//ri:Resource/content/relationship/relationshipType='related-to'">
                <xsl:for-each select="relatedResource">
                    <xsl:if test="@ivo-id"> <!-- TODO DOI and other -->
                    <dct:relation>
                        <xsl:element name="Description">
                            <xsl:attribute name="rdf:about"><xsl:value-of select="@ivo-id"/></xsl:attribute>
                            <dct:identifier><xsl:value-of select="@ivo-id"/></dct:identifier>
                            <xsl:element name="rdf:type">
                                <xsl:attribute name="rdf:resource">http://www.ivoa.net/xml/VODataService/v1.1#CatalogueResource</xsl:attribute> <!--that could be wrong, but I don't know how to know the type -->
                            </xsl:element>
                            <xsl:element name="rdf:type">
                                <xsl:attribute name="rdf:resource">http://www.w3.org/ns/dcat#DataSet</xsl:attribute> 
                            </xsl:element>
                        </xsl:element>
                    </dct:relation>
                    </xsl:if>
                </xsl:for-each>
            </xsl:when>

            <!-- TODO the other cases -->
        </xsl:choose>
    </xsl:for-each>

    <!-- rights -->
    <xsl:for-each select="//ri:Resource/rights">
        <dct:rights><xsl:value-of select="."/></dct:rights> <!-- todo disinguish when there is a license using <dct:license> -->
    </xsl:for-each>




<!--  CONTIUE CURATION HERE -->



    <!-- capability -->
    <xsl:for-each select="//ri:Resource/capability">
        <xsl:variable name="std"><xsl:value-of select="@standardID"/></xsl:variable>
        <xsl:variable name="desc"><xsl:value-of select="description"/></xsl:variable>
        <xsl:for-each select="./interface">
            <dcat:Distribution>
                <dct:description><xsl:value-of select="$desc"/></dct:description>
                <xsl:variable name="url"><xsl:value-of select="accessURL"/></xsl:variable>
                <xsl:if test="accessURL">
                    <dcat:accessURL><xsl:value-of select="$url"/></dcat:accessURL>
                </xsl:if>

                <xsl:for-each select="./resultType">
                    <dct:formats><xsl:value-of select="."/></dct:formats>
                </xsl:for-each>

                <xsl:if test="$std!=''">
                    <dcat:AccessService>
                            <xsl:element name="Description"> <!-- that's not dcat but used in zenodo -->
                                <xsl:attribute name="rdf:about"><xsl:value-of select="@ivo-id"/></xsl:attribute>
                                <dct:identifier><xsl:value-of select="@ivo-id"/></dct:identifier>
                                <dcat:endpointURL><xsl:value-of select="$url"/></dcat:endpointURL>
                                <dcat:endpointURLDescription>http://ivo.net/openAPI/...</dcat:endpointURLDescription><!-- I have no URL today -->
                            </xsl:element>
                                
                    </dcat:AccessService>
                </xsl:if>

                <xsl:for-each select="mirrorURL">
                    <dcat:accessURL><xsl:value-of select="."/></dcat:accessURL>
                </xsl:for-each>
            </dcat:Distribution>
        </xsl:for-each>
    </xsl:for-each>

    <!-- tableset -->
    <xsl:for-each select="//ri:Resource/tableset">
        <xsl:for-each select="schema"><!-- I consider schema as a Catalog -->
        <dcat:Catalog>
            <xsl:element name="rdf:Description">
                <xsl:attribute name="rdf:about"><xsl:value-of select="name"/></xsl:attribute>
                <dct:type rdf:resource="http://purl.org/dc/dcmitype/Catalog"/>
                <dcat:Catalog>
                    <xsl:for-each select="table">
                        <xsl:element name="rdf:Description">
                            <xsl:attribute name="rdf:about"><xsl:value-of select="name"/></xsl:attribute>
                            <dct:type rdf:resource="http://purl.org/dc/dcmitype/Dataset"/><!--I don't think it is ok-->
                            <dcat:Dataset>
                                <dct:description><xsl:value-of select="description"/></dct:description>
                                <xsl:for-each select="column">
                                    <rdf:Description>
                                        <rdf:type rdf:resource="http://www.ivoa.net/xml/VODataService/v1.1#Column"/> <!--Introduce VODataservice because column doesn't exist in DCAT -->
                                        <ivods:Column>
                                            <ivods:name><xsl:value-of select="name"/></ivods:name>
                                            <xsl:if test="description"><ivods:description><xsl:value-of select="description"/></ivods:description></xsl:if>
                                            <xsl:if test="unit"><ivods:unit><xsl:value-of select="unit"/></ivods:unit></xsl:if>
                                            <xsl:if test="ucd"><ivods:ucd><xsl:value-of select="ucd"/></ivods:ucd></xsl:if>
                                            <xsl:if test="flag"><ivods:flag><xsl:value-of select="flag"/></ivods:flag></xsl:if>
                                        </ivods:Column>
                                    </rdf:Description>
                                </xsl:for-each>
                            </dcat:Dataset>
                        </xsl:element>
                    </xsl:for-each>
                </dcat:Catalog>
            </xsl:element>
        </dcat:Catalog>
        </xsl:for-each>
    </xsl:for-each>

  </rdf:Description>
  </rdf:RDF>

</xsl:when>
</xsl:choose>
</metadata>
</record></getRecord>
</OAI-PMH>
</xsl:template>

<!--/xsl:stylesheet-->
</xsl:transform>

