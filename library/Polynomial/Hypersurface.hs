{-# LANGUAGE DataKinds, TypeFamilies, FlexibleContexts, FlexibleInstances, PolyKinds #-}
{-# LANGUAGE UndecidableInstances, MultiParamTypeClasses #-}


module Polynomial.Hypersurface where

import Polynomial.Prelude
import Polynomial.Monomial
import Geometry.ConvexHull2
import qualified Data.Map.Strict as MS
import qualified Data.Sized as DS
import Data.Maybe
import Debug.Trace
import Data.List
import Geometry.ConvexHull3 (Point3D)
import Geometry.Polytope

-- | The tropical hypersurface of a polynomial f is the n-1 skeleton of the Newton polyotpe of f with a regular subdivision induced by a vector w in R^n. The hypersurface will be stored as a set of points.


-- | This function produces a key-value map of the terms of a polynomial with their corresponding coordinates for the Newton polytope

-- mapTermPoint :: (IsMonomialOrder ord, Ord k, Integral k) 
--     => Polynomial k ord n -> MS.Map Point3D (Monomial ord n, k)
-- mapTermPoint poly = MS.fromList $ zipWith (,) points terms 
--     where
--         terms = MS.toList $ (getTerms poly)
--         monExps = DS.toList . getMonomial
--         toPoints = \(mon,coef) -> let [a,b] = monExps mon in (a, b, fromIntegral coef)
--         points = map toPoints terms

mapTermPoint :: (IsMonomialOrder ord, Ord k, Integral k) 
    => Polynomial k ord n -> MS.Map Point2D (Monomial ord n, k)
mapTermPoint poly = MS.fromList $ zipWith (,) points terms 
    where
        terms = MS.toList $ (getTerms poly)
        monExps = DS.toList . getMonomial
        toPoints = \(mon,coef) -> let [a,b] = monExps mon in (a, b)
        points = map toPoints terms


-- | Finds the vertex of a tropical line which corresponds to the intersection of the polyhedral fan of a triangle

computeIntersection :: (Integral k) => (Monomial ord n, k) -> (Monomial ord n, k) -> (Monomial ord n, k) -> Point2D
computeIntersection (mon1, c1) (mon2, c2) (mon3, c3) = (x, y) 
        where 
            [a,b] = DS.toList $ getMonomial mon1
            [d,e] = DS.toList $ getMonomial mon2
            [g,h] = DS.toList $ getMonomial mon3
            c = fromIntegral c1
            f = fromIntegral c2
            i = fromIntegral c3
            y = ((f-c)*(d-g) - (i-f)*(a-d)) `div` ((b-e)*(d-g)-(e-h)*(a-d)) 
            x = ((f-c)-(b-e)*y) `div` (a-d)

findFanVertex :: (Integral k) => MS.Map Point2D (Monomial ord n, k) -> [Point2D] -> Point2D
findFanVertex mapPointMon points = computeIntersection mon1 mon2 mon3 
    where
        [pp1, pp2, pp3] = (reverse.sort) points
        mon1 = fromJust $ MS.lookup pp1 mapPointMon
        mon2 = fromJust $ MS.lookup pp2 mapPointMon
        mon3 = fromJust $ MS.lookup pp3 mapPointMon


innerNormal :: Point2D -> Point2D -> Point2D -> Point2D
innerNormal a@(x1,y1) b@(x2,y2) c@(x3,y3)
    | dot > 0 = nab
    | dot < 0 = (y1-y2,x2-x1)
    where
        ab = (x2-x1,y2-y1)
        ac = (x3-x1,y3-y1)
        nab = (y2-y1,x1-x2) -- (y,-x)
        dot = (y2-y1)*(x3-x1) + (x1-x2)*(y3-y1)


innerNormals :: Point2D -> Point2D -> Point2D -> [Point2D]
innerNormals a@(x1,y1) b@(x2,y2) c@(x3,y3) = [inner1, inner2, inner3]
    where
        inner1 = innerNormal a b c
        inner2 = innerNormal b c a
        inner3 = innerNormal c a b
        

verticess :: (IsMonomialOrder ord, Ord k, Integral k)  => Polynomial k ord n -> [Point2D]
verticess poly = map (findFanVertex polyMap) triangles 
    where
        polyMap = mapTermPoint poly
        triangles = subdivision poly