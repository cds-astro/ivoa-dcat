# Map VO record into DCAT

by G.Landais - Nov 2025


- DCAT: https://www.w3.org/TR/vocab-dcat-3/
- VOResource: https://www.ivoa.net/documents/VOResource/
- VODataService: https://www.ivoa.net/documents/VODataService/

This is a test to map a registry record into DCAT serialisation in format XML.
The serialisation is based on the DCAT output provided by ZENODO.

example: https://zenodo.org/records/17122603 use "DCAT" Export

Implementation Example: https://cds.unistra.fr/registry/?verb=GetRecord&metadataPrefix=DCAT&identifier=ivo://cds.vizier/i/350

# Contents

- IVOA Note: `make`
- todcat.xsl: XSLT that transforms IVOA registry record (OAI-PMH ser) into DCAT
- examples


# Issues
- [ ] rights: improve when http spdx and spdx name
- [ ] openAPI URL ?

