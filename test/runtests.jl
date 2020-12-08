using ReTest

include("tests.jl")
retest(CodesTests, CodesTests.Codes)
