#!/usr/bin/env python
############################################################################
#
# MODULE:       v.mbg
#
# AUTHOR(S):    Alexander Muriy
#
# PURPOSE:      Creates a vector map containing polygons which represent a specified
#               minimum bounding geometry enclosing each input feature or each group
#               of input features
#
# COPYRIGHT:    (c) 2013, David Butterworth, University of Queensland
#               (c) 2019, Alexander Muriy
#
#               This program is free software under the GNU General Public
#               License (>=v2). Read the file COPYING that comes with GRASS
#               for details.
#
#############################################################################
#
# REQUIREMENTS:
#      - NumPy Python module
#      - ??
#  
#%module
#% description: Creates a vector map containing polygons which represent "Minimum Bounding Geometry".
#% keyword: vector
#% keyword: geometry
#%end

#%option G_OPT_V_INPUT
#%  key: input
#%  description: Vector map 
#%end


##################
# IMPORT MODULES #
##################

import os
import sys
import atexit
from numpy import *
import grass.script as grass
# from grass.pygrass.modules.shortcuts import general as g
# from grass.pygrass.modules.shortcuts import raster as r
from grass.pygrass.modules.shortcuts import vector as v
# from grass.pygrass.gis import region
from grass.pygrass.vector import VectorTopo
from grass.pygrass.vector.geometry import Point 

import miniball

# from matplotlib import pyplot as plt

####################
#### FUNCTIONS #####
####################

def cleanup():
    """Remove temporary maps"""
    nuldev = open(os.devnull, 'w')
    grass.run_command('g.remove', flags = 'f', quiet = True,
                        type = ['raster','vector'], stderr = nuldev,
                        pattern = '{}*'.format(tmpname))
    

def vector_to_nparray(in_vect):
    data = VectorTopo(in_vect)
    data.open('r')

    coords = []
    coor_list = []
    for i in range(len(data)):
        coor = data.read(i+1).coords()
        coor2 = " ".join(str(x) for x in coor)
        coor3 = [float(s) for s in coor2.split(' ')]
        coords.append(coor3)
        
    coords_arr = array(coords)
    return coords_arr


def nparray_to_vector(in_array, out_vect):
    if in_array.ndim == 2: 
        points = rec.fromarrays([in_array.T[0], in_array.T[1]])
    elif in_array.ndim == 1:
        points = [in_array]
        
    new = VectorTopo(out_vect)
    new.open("w", overwrite=True)
    
    for pnt in points:
        new.write(Point(*pnt))

    new.close()
    new.build() 

    

def minBoundingRect(hull_points_2d):
    """
    author: David Butterworth
    https://github.com/dbworth/minimum-area-bounding-rectangle
    """
    # Compute edges (x2-x1,y2-y1)
    edges = zeros( (len(hull_points_2d)-1,2) ) # empty 2 column array
    for i in range( len(edges) ):
        edge_x = hull_points_2d[i+1,0] - hull_points_2d[i,0]
        edge_y = hull_points_2d[i+1,1] - hull_points_2d[i,1]
        edges[i] = [edge_x,edge_y]

    # Calculate edge angles   atan2(y/x)
    edge_angles = zeros( (len(edges)) ) # empty 1 column array
    for i in range( len(edge_angles) ):
        edge_angles[i] = math.atan2( edges[i,1], edges[i,0] )

    # Check for angles in 1st quadrant
    for i in range( len(edge_angles) ):
        edge_angles[i] = abs( edge_angles[i] % (math.pi/2) ) # want strictly positive answers

    # Remove duplicate angles
    edge_angles = unique(edge_angles)

    # Test each angle to find bounding box with smallest area
    min_bbox = (0, sys.maxint, 0, 0, 0, 0, 0, 0) # rot_angle, area, width, height, min_x, max_x, min_y, max_y
    for i in range( len(edge_angles) ):

        # Create rotation matrix to shift points to baseline
        # R = [ cos(theta)      , cos(theta-PI/2)
        #       cos(theta+PI/2) , cos(theta)     ]
        R = array([ [ math.cos(edge_angles[i]), math.cos(edge_angles[i]-(math.pi/2)) ], [ math.cos(edge_angles[i]+(math.pi/2)), math.cos(edge_angles[i]) ] ])

        # Apply this rotation to convex hull points
        rot_points = dot(R, transpose(hull_points_2d) ) # 2x2 * 2xn

        # Find min/max x,y points
        min_x = nanmin(rot_points[0], axis=0)
        max_x = nanmax(rot_points[0], axis=0)
        min_y = nanmin(rot_points[1], axis=0)
        max_y = nanmax(rot_points[1], axis=0)

        # Calculate height/width/area of this bounding rectangle
        width = max_x - min_x
        height = max_y - min_y
        area = width*height

        # Store the smallest rect found first (a simple convex hull might have 2 answers with same area)
        if (area < min_bbox[1]):
            min_bbox = ( edge_angles[i], area, width, height, min_x, max_x, min_y, max_y )
        # Bypass, return the last found rect

    # Re-create rotation matrix for smallest rect
    angle = min_bbox[0]   
    R = array([ [ math.cos(angle), math.cos(angle-(math.pi/2)) ], [ math.cos(angle+(math.pi/2)), math.cos(angle) ] ])

    # Project convex hull points onto rotated frame
    proj_points = dot(R, transpose(hull_points_2d) ) # 2x2 * 2xn

    # min/max x,y points are against baseline
    min_x = min_bbox[4]
    max_x = min_bbox[5]
    min_y = min_bbox[6]
    max_y = min_bbox[7]

    # Calculate center point and project onto rotated frame
    center_x = (min_x + max_x)/2
    center_y = (min_y + max_y)/2
    center_point = dot( [ center_x, center_y ], R )

    # Calculate corner points and project onto rotated frame
    corner_points = zeros( (4,2) ) # empty 2 column array
    corner_points[0] = dot( [ max_x, min_y ], R )
    corner_points[1] = dot( [ min_x, min_y ], R )
    corner_points[2] = dot( [ min_x, max_y ], R )
    corner_points[3] = dot( [ max_x, max_y ], R )

    return (angle, min_bbox[1], min_bbox[2], min_bbox[3], center_point, corner_points) # rot_angle, area, width, height, center_point, corner_points


############
### MAIN ###
############

def main():
    global tmpname
    tmpname = grass.tempname(12)

    inmap = options['input']

    hull = tmpname + '_hull'    
    v.hull(input = inmap, output = hull, flags = 'f', quiet = True)
    
    vert = tmpname + '_vert'    
    v.to_points(input = hull, output = vert, use = 'vertex', layer = '-1', flags = 't', quiet = True)
    
    # xy_points = vector_to_nparray(inmap)
    
    hull_coords = vector_to_nparray(vert)
    # hull_coords = hull_coords[::-1]
    # print 'Convex hull points: \n', hull_coords, "\n"
    
    # Find minimum area bounding rectangle
    (rot_angle, area, width, height, center_point, corner_points) = minBoundingRect(hull_coords)
    
    print "Minimum area bounding box:"
    print "Rotation angle:", rot_angle, "rad  (", rot_angle*(180/math.pi), "deg )"
    print "Width:", width, " Height:", height, "  Area:", area
    print "Center point: \n", center_point 
    print "Corner points: \n", corner_points, "\n" 
    
    
    # plt.scatter(xy_points[:,0], xy_points[:,1])
    # plt.scatter(corner_points[:,0], corner_points[:,1], color='red')
    # plt.scatter(center_point[0], center_point[1], color='green')
    # # bbox = minimum_bounding_rectangle(points)
    # # plt.fill(bbox[:,0], bbox[:,1], alpha=0.2)
    # plt.axis('equal')
    # plt.show()    


    nparray_to_vector(corner_points, 'newvect')
    nparray_to_vector(center_point, 'center_point')
    
    v.hull(input = 'newvect', output = 'newvect_hull', flags = 'f', quiet = True, overwrite = True)


    # import numpy
    
    # C, r2 = miniball.get_bounding_ball(hull_coords)
    # print(C)
    # print(r2)
    
    # import math
    # math.sqrt(r2)

    # echo '668076.12141766 227634.66619505' | v.in.ascii in=- out=circle_center sep=' ' --o
    # v.buffer in=circle_center out=circle dist=126720.88540607662 tolerance=0.001 --o


    def getMinVolEllipse(P, tolerance=0.01):
        """ Author:
        https://github.com/minillinim/ellipsoid
        """
        (N, d) = shape(P)
        d = float(d)
        
        # Q will be our working array
        Q = vstack([copy(P.T), ones(N)]) 
        QT = Q.T
        
        # initializations
        err = 1.0 + tolerance
        u = (1.0 / N) * ones(N)

        # Khachiyan Algorithm
        while err > tolerance:
            V = dot(Q, dot(diag(u), QT))
            M = diag(dot(QT , dot(linalg.inv(V), Q)))    # M the diagonal vector of an NxN matrix
            j = argmax(M)
            maximum = M[j]
            step_size = (maximum - d - 1.0) / ((d + 1.0) * (maximum - 1.0))
            new_u = (1.0 - step_size) * u
            new_u[j] += step_size
            err = linalg.norm(new_u - u)
            u = new_u

        # center of the ellipse 
        center = dot(P.T, u)
        
        # the A matrix for the ellipse
        A = linalg.inv(
            dot(P.T, dot(diag(u), P)) - 
            array([[a * b for b in center] for a in center])
        ) / d
        
        # Get the values we'd like to return
        U, s, rotation = linalg.svd(A)
        radii = 1.0/sqrt(s)
        
        return (center, radii, rotation)



    # find the ellipsoid
    (center, radii, rotation) = getMinVolEllipse(hull_coords, .01)

    print(center)
    print(radii)
    print(rotation)


    
    # import math

    # """
    # https://stackoverflow.com/questions/38409156/minimal-enclosing-parallelogram-in-python
    
    # Minimal Enclosing Parallelogram
    
    # area, v1, v2, v3, v4 = mep(convex_polygon)
    
    # convex_polygon - array of points. Each point is a array [x, y] (1d array of 2 elements)
    # points should be presented in clockwise order.
    
    # the algorithm used is described in the following paper:
    # http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.53.9659&rep=rep1&type=pdf
    # """
    
    def distance(p1, p2, p):
        return abs(((p2[1]-p1[1])*p[0] - (p2[0]-p1[0])*p[1] + p2[0]*p1[1] - p2[1]*p1[0]) /
                   math.sqrt((p2[1]-p1[1])**2 + (p2[0]-p1[0])**2))
    
    def antipodal_pairs(convex_polygon):
        l = []
        n = len(convex_polygon)
        p1, p2 = convex_polygon[0], convex_polygon[1]
        
        t, d_max = None, 0
        for p in range(1, n):
            d = distance(p1, p2, convex_polygon[p])
            if d > d_max:
                t, d_max = p, d
                l.append(t)
                
        for p in range(1, n):
            p1, p2 = convex_polygon[p % n], convex_polygon[(p+1) % n]
            _p, _pp = convex_polygon[t % n], convex_polygon[(t+1) % n]
            while distance(p1, p2, _pp) > distance(p1, p2, _p):
                t = (t + 1) % n
                _p, _pp = convex_polygon[t % n], convex_polygon[(t+1) % n]
                l.append(t)
                
        return l


    # returns score, area, points from top-left, clockwise , favouring low area
    def mep(convex_polygon):
        def compute_parallelogram(convex_polygon, l, z1, z2):
            def parallel_vector(a, b, c):
                v0 = [c[0]-a[0], c[1]-a[1]]
                v1 = [b[0]-c[0], b[1]-c[1]]
                return [c[0]-v0[0]-v1[0], c[1]-v0[1]-v1[1]]

            # finds intersection between lines, given 2 points on each line.
            # (x1, y1), (x2, y2) on 1st line, (x3, y3), (x4, y4) on 2nd line.
            def line_intersection(x1, y1, x2, y2, x3, y3, x4, y4):
                px = ((x1*y2 - y1*x2)*(x3 - x4) - (x1 - x2)*(x3*y4 - y3*x4))/((x1-x2)*(y3-y4) - (y1-y2)*(x3-x4))
                py = ((x1*y2 - y1*x2)*(y3 - y4) - (y1 - y2)*(x3*y4 - y3*x4))/((x1-x2)*(y3-y4) - (y1-y2)*(x3-x4))
                return px, py


            # from each antipodal point, draw a parallel vector,
            # so ap1->ap2 is parallel to p1->p2
            #    aq1->aq2 is parallel to q1->q2
            p1, p2 = convex_polygon[z1 % n], convex_polygon[(z1+1) % n]
            q1, q2 = convex_polygon[z2 % n], convex_polygon[(z2+1) % n]
            ap1, aq1 = convex_polygon[l[z1 % n]], convex_polygon[l[z2 % n]]
            ap2, aq2 = parallel_vector(p1, p2, ap1), parallel_vector(q1, q2, aq1)

            a = line_intersection(p1[0], p1[1], p2[0], p2[1], q1[0], q1[1], q2[0], q2[1])
            b = line_intersection(p1[0], p1[1], p2[0], p2[1], aq1[0], aq1[1], aq2[0], aq2[1])
            d = line_intersection(ap1[0], ap1[1], ap2[0], ap2[1], q1[0], q1[1], q2[0], q2[1])
            c = line_intersection(ap1[0], ap1[1], ap2[0], ap2[1], aq1[0], aq1[1], aq2[0], aq2[1])

            s = distance(a, b, c) * math.sqrt((b[0]-a[0])**2 + (b[1]-a[1])**2)
            return s, a, b, c, d


        z1, z2 = 0, 0
        n = len(convex_polygon)
        
        # for each edge, find antipodal vertice for it (step 1 in paper).
        l = antipodal_pairs(convex_polygon)

        so, ao, bo, co, do, z1o, z2o = 100000000000, None, None, None, None, None, None
        
        # step 2 in paper.
        for z1 in range(0, n):
            if z1 >= z2:
                z2 = z1 + 1
            p1, p2 = convex_polygon[z1 % n], convex_polygon[(z1+1) % n]
            a, b, c = convex_polygon[z2 % n], convex_polygon[(z2+1) % n], convex_polygon[l[z2 % n]]
            if distance(p1, p2, a) >= distance(p1, p2, b):
                continue

            while distance(p1, p2, c) > distance(p1, p2, b):
                z2 += 1
                a, b, c = convex_polygon[z2 % n], convex_polygon[(z2+1) % n], convex_polygon[l[z2 % n]]

            st, at, bt, ct, dt = compute_parallelogram(convex_polygon, l, z1, z2)

            if st < so:
                so, ao, bo, co, do, z1o, z2o = st, at, bt, ct, dt, z1, z2

    # return so, ao, bo, co, do, z1o, z2o


    convex_polygon = hull_coords

    area, v1, v2, v3, v4 = mep(convex_polygon)
    # print area
    # print v1
    
    
    
    
    sys.exit(1) 
    

    

    
    
    



if __name__ == "__main__":
    options, flags = grass.parser()
    atexit.register(cleanup)
    main()
    
