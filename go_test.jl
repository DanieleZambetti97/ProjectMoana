#executable for launch tests
import Pkg

Pkg.activate(".")
Pkg.test()