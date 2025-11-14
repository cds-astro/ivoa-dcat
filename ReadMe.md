# Map VO record into DCAT

by G.Landais - Nov 2025


- DCAT: https://www.w3.org/TR/vocab-dcat-3/
- VOResource: https://www.ivoa.net/documents/VOResource/
- VODataService: https://www.ivoa.net/documents/VODataService/

This is a test to map a registry record into DCAT serialisation in format XML.
The serialisation is based on the DCAT output provided by ZENODO.

example: https://zenodo.org/records/17122603 use "DCAT" Export


The process uses XSLT.



# Issues
- [ ] manage also Service
- [ ] how to distinguish Person and Organization ?
- [ ] Affiliation is not in VOResource
- [ ] relationships: manage doi or bibcode (TODO)
- [ ] relationships: manage other thatrelated-to and isServedBy and isSuplementTo (TODO)
- [ ] rights: improve when http spdx and spdx name
- [ ] openAPI URL ?
- [ ] capabilty: a description should be mandatory ?

## Choice
- relations use distribution (or citedcat)
- table description: Catalog (schema), then  Datasets (tables) 
- use citedcat  (not in DCAT): ivoa:CatalogueResource and dcat:Dataset to the type of relations

