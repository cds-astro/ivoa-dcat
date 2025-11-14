#!/usr/bin/python3
import lxml
from lxml import etree
from io import StringIO

import sys

if len(sys.argv) != 3:
    print(f"Usage {sys.argv[0]} xsl_file xml_sile")
    sys.exit(1)

xsl_file = sys.argv[1]
xml_file = sys.argv[2]

with open(xsl_file, "rb") as fd:
    xsl_bytes = fd.read()
xsl_root = etree.XML(xsl_bytes)
transform = etree.XSLT(xsl_root)

with open(xml_file, "r", encoding='utf-8') as fd:
    doc = etree.parse(fd)
#    xml_string= fd.read()

#f = StringIO(xml_string)
#doc = etree.parse(f)
result_tree = transform(doc)

print(result_tree)
