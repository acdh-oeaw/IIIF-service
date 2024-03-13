# Umbrella web service for converting images and serving metadata and images using the IIIF standard

This repository contains a lighttpd proxy server that
* uses the conversion and metadata service [https://github.com/acdh-oeaw/JPEG2000-conversion-and-IIIF-presentation]
* and the image server [https://github.com/acdh-oeaw/iipsrv] 
* and combines them with UniversalViewer [https://universalviewer.io/] or Mirador [https://projectmirador.org/] for the browser

This is an alpine based image.