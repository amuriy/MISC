from osgeo import gdal
from osgeo.gdalnumeric import *
from osgeo.gdalconst import *
import sys

fileName1 = sys.argv[1]
fileName2 = sys.argv[2]
outFile = sys.argv[3]

#Open the datasets
ds1 = gdal.Open(fileName1, GA_ReadOnly )
ds2 = gdal.Open(fileName2, GA_ReadOnly )
band1 = ds1.GetRasterBand(1)
band2 = ds2.GetRasterBand(1)

#Read the data into numpy arrays
data1 = BandReadAsArray(band1)
data2 = BandReadAsArray(band2)

#The actual calculation
dataOut = numpy.arctan2(data1,data2) * 180 / numpy.pi

#Write the out file
driver = gdal.GetDriverByName("GTiff")
dsOut = driver.Create('%s' % outFile, ds1.RasterXSize, ds1.RasterYSize, 1, band1.DataType)
CopyDatasetInfo(ds1,dsOut)
bandOut=dsOut.GetRasterBand(1)
BandWriteArray(bandOut, dataOut)

#Close the datasets
band1 = None
band2 = None
ds1 = None
bandOut = None
dsOut = None
