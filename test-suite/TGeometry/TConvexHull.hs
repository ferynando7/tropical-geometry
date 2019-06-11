module TGeometry.TConvexHull (testsConvexHull) where

    import Test.Tasty
    import Test.Tasty.HUnit as HU
    import Geometry.ConvexHull
    import Data.List
      
    
    testComputeSegment :: TestTree
    testComputeSegment = HU.testCase "Compute segments" $ do
            computeSegment [] @?= Nothing
            computeSegment [(1,2,3)] @?= Nothing
            computeSegment [(1,2,3), (1,2,3)] @?= Nothing
            computeSegment [(1,2,3),(2,4,6),(7,6,5),(3,0,1),(4,3,2)] @?= Just [(1,2,3),(2,4,6)]
            computeSegment [(1,2,3),(7,6,5),(2,4,6),(3,0,1),(4,3,2)] @?= Just [(1,2,3),(7,6,5)]


    testComputeTriangle :: TestTree
    testComputeTriangle = HU.testCase "Compute triangles" $ do
            computeTriangle [] @?= Nothing
            computeTriangle [(1,2,3),(2,4,6),(7,6,5),(3,0,1),(4,3,2)] @?= Just [(1,2,3),(2,4,6),(7,6,5)]
            computeTriangle [(1,2,3),(2,4,6),(3,6,9),(7,6,5),(3,0,1),(4,3,2)] @?= Just [(1,2,3),(2,4,6),(7,6,5)]
        
    testComputeTetrahedron :: TestTree
    testComputeTetrahedron = HU.testCase "Compute tetrahedrons" $ do
            computeTetrahedron [] @?= Nothing
            computeTetrahedron [(1,2,3),(2,4,6),(7,6,5),(3,0,1),(4,3,2)] @?= Just [(1,2,3),(2,4,6),(7,6,5),(3,0,1)]
            computeTetrahedron [(1,2,3),(2,4,3),(3,6,3),(7,6,3),(3,0,1),(4,3,2)] @?= Just [(1,2,3),(2,4,3),(7,6,3),(3,0,1)]
        



    a,b,c,d,e,f :: Point3D
    a = (3,5,0)
    b = (0,6,0)
    c = (0,3,0)
    d = (2,2,0)
    e = (6,0,0)
    f = (9,3,0)

    testIsBetween3D :: TestTree
    testIsBetween3D = HU.testCase "IsBetween3D" $ do
        isBetween3D [a,c] b @?= False
        isBetween3D [f,b] a @?= True

    testsMergePoints :: TestTree
    testsMergePoints = HU.testCase "Merging points" $ do
        mergePoints [a,b,c,d] [a,d,e,f] @?= [b,c,e,f]
        
    testsConvexHull3D :: TestTree
    testsConvexHull3D = HU.testCase "Compute convex hull 3D" $ do
            convexHull3D [(1,2,3), (2,1,3), (5,3,1)] @?= Just (sort [(1,2,3), (2,1,3), (5,3,1)])
            convexHull3D [(0,0,0), (0,2,0), (2,0,0), (1,1,0)] @?= Nothing
--            convexHull3D [(0,0,0), (0,2,0), (2,0,0), (1,1,1)] @?= Just (sort [(0,0,0), (0,2,0), (2,0,0), (1,1,1)])
            -- convexHull3D [(0,0,0),(3,3,3),(0,4,0),(4,0,0),(0,0,4),(4,4,0),(0,4,4),(4,0,4),(4,4,4)] @?= Just (sort [(0,0,0),(0,4,0),(4,0,0),(0,0,4),(4,4,0),(0,4,4),(4,0,4),(4,4,4)])
           -- convexHull3D [(1,1,2),(0,0,0),(3,3,3),(0,4,0),(4,0,0),(2,1,3),(2,2,2),(0,0,4),(4,4,0),(0,4,4),(4,0,4),(4,4,4)] @?= Just (sort [(0,0,0),(0,4,0),(4,0,0),(0,0,4),(4,4,0),(0,4,4),(4,0,4),(4,4,4)])
            convexHull3D [(1,1,1),(0,0,0),(3,3,3),(0,4,0),(4,0,0),(2,0,2),(2,2,2),(0,0,4),(4,4,0),(0,4,4),(4,0,4),(4,4,4)] @?= Just (sort [(0,0,0),(0,4,0),(4,0,0),(0,0,4),(4,4,0),(0,4,4),(4,0,4),(4,4,4)])


    testsConvexHull :: TestTree
    testsConvexHull = testGroup "Test for convex hull in 3D" [testComputeSegment, testComputeTriangle, testComputeTetrahedron, testIsBetween3D, testsMergePoints, testsConvexHull3D]
    
    
    