#!/usr/bin/env python3

# Converts the JWST simulated PSF to the packed PNG format expected by
# the godot-starlight addon. The source PSF images must be obtained in
# FITS format from here:
# <https://www.stsci.edu/jwst/science-planning/proposal-planning-toolbox/simulated-data>

# This script was adapted by me (Tiffany) from a FITS-to-EXR conversion
# script, the original description follows.

# Presented by Min-Su Shin 
# (2015 - , KASI, Republic of Korea)
# (2012 - 2015; Astrophysics, University of Oxford).

# This is an example code which converts astronomical fits images to 
# an OpenEXR file (http://www.openexr.com/). This file format supports 
# 32-bit floating-point which is commonly used in astronomical FITS files.
# OpenEXR is one common format for a high dynamic-range (HDR) image.

# Here, I use astropy, numpy, and Python OpenEXR binding.
# conda install openexr-python numpy astropy
# You may find pfstools (http://pfstools.sourceforge.net/) and 
# exrtools (http://scanline.ca/exrtools/) useful in order to 
# check the output EXR files.

from astropy.io import fits
import numpy
from img_scale import cbrt
from skimage.measure import block_reduce
from PIL import Image

# read FITS images
# red channel
fits_fn = "./PSF+scatlight_0.8micron.fits"
hdulist = fits.open(fits_fn)
r_img_header = hdulist[0].header
r_img_data = hdulist[0].data
hdulist.close()
width=r_img_data.shape[0]
height=r_img_data.shape[1]
print("reading the FITS file ",fits_fn," done...")
print(r_img_data.dtype)

# green channel
fits_fn = "./PSF+scatlight_0.7micron.fits"
hdulist = fits.open(fits_fn)
g_img_header = hdulist[0].header
g_img_data = hdulist[0].data
hdulist.close()
width=g_img_data.shape[0]
height=g_img_data.shape[1]
print("reading the FITS file ",fits_fn," done...")
print(g_img_data.dtype)

# blue channel
fits_fn = "./PSF+scatlight_0.6micron.fits"
hdulist = fits.open(fits_fn)
b_img_header = hdulist[0].header
b_img_data = hdulist[0].data
hdulist.close()
width=b_img_data.shape[0]
height=b_img_data.shape[1]
print("reading the FITS file ",fits_fn," done...")
print(b_img_data.dtype)

def crop_center(img,cropx,cropy):
    y,x = img.shape
    startx = x//2 - cropx//2
    starty = y//2 - cropy//2    
    return img[starty:starty+cropy, startx:startx+cropx]

width = 2048
height = 2048
r_img_data = crop_center(r_img_data, width, height)
g_img_data = crop_center(g_img_data, width, height)
b_img_data = crop_center(b_img_data, width, height)

downscale = 1

if downscale != 1:
  r_img_data = block_reduce(r_img_data, block_size=(downscale,downscale), func=numpy.sum, cval=numpy.sum(r_img_data))
  g_img_data = block_reduce(g_img_data, block_size=(downscale,downscale), func=numpy.sum, cval=numpy.sum(r_img_data))
  b_img_data = block_reduce(b_img_data, block_size=(downscale,downscale), func=numpy.sum, cval=numpy.sum(r_img_data))
  width = width // downscale
  height = height // downscale

coords = numpy.mgrid[0:width, 0:height]
xcoord = coords[0] - (width / 2)
ycoord = coords[1] - (height / 2)
dist_sq = xcoord * xcoord + ycoord * ycoord + 0

r_img_data = r_img_data * dist_sq
g_img_data = g_img_data * dist_sq
b_img_data = b_img_data * dist_sq

r_max = numpy.max(r_img_data)
g_max = numpy.max(g_img_data)
b_max = numpy.max(b_img_data)

r_img_data = r_img_data / r_max
g_img_data = g_img_data / g_max
b_img_data = b_img_data / b_max

b = 1000
log_b = numpy.log(b)
r_img_data = numpy.log(1.0 + r_img_data * (b - 1.0)) / log_b
g_img_data = numpy.log(1.0 + g_img_data * (b - 1.0)) / log_b
b_img_data = numpy.log(1.0 + b_img_data * (b - 1.0)) / log_b

print("max values: ", r_max, g_max, b_max)

r_img_data = numpy.asarray(r_img_data * 255.0, dtype=numpy.uint8)
g_img_data = numpy.asarray(g_img_data * 255.0, dtype=numpy.uint8)
b_img_data = numpy.asarray(b_img_data * 255.0, dtype=numpy.uint8)

rgb = numpy.dstack((r_img_data, g_img_data, b_img_data))

image = Image.fromarray(rgb)
image.save("jwst.png")
