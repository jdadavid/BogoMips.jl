# BogoMips.jl

![Lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)<!--
![Lifecycle](https://img.shields.io/badge/lifecycle-maturing-blue.svg)
![Lifecycle](https://img.shields.io/badge/lifecycle-stable-green.svg)
![Lifecycle](https://img.shields.io/badge/lifecycle-retired-orange.svg)
![Lifecycle](https://img.shields.io/badge/lifecycle-archived-red.svg)
![Lifecycle](https://img.shields.io/badge/lifecycle-dormant-blue.svg) -->
[![Build Status](https://travis-ci.com/jdadavid/BogoMips.jl.svg?branch=master)](https://travis-ci.com/jdadavid/BogoMips.jl)
[![codecov.io](http://codecov.io/github/jdadavid/BogoMips.jl/coverage.svg?branch=master)](http://codecov.io/github/jdadavid/BogoMips.jl?branch=master)
<!--
[![Documentation](https://img.shields.io/badge/docs-stable-blue.svg)](https://jdadavid.github.io/BogoMips.jl/stable)
[![Documentation](https://img.shields.io/badge/docs-master-blue.svg)](https://jdadavid.github.io/BogoMips.jl/dev)
-->
# BogoMips.jl
Compute BogoMips in pure Julia

Usage : 
either, inside Julia REPL, 

  add the package
  
      `]add https://github.com/jdadavid/BogoMips.jl.git`
      
    or
    
      `import Pkg; Pkg.add(url="https://github.com/jdadavid/BogoMips.jl.git")`
      
  and then call
```
     using BogoMips
     bogomips(true) # true = prints the bogomips and return nothing, false or omitted = dont print but return computed_bogomips value
     # or 
     bg=bogomips(false); println("Computed :"*round(bg,digits=2) * "bogomips.")
     # or
     bg=bogomips(); println("Computed :"*round(bg,digits=2) * "bogomips.")
```

or, in command line :

```
  cd BogoMips.jl
  julia -q -e 'include("src/BogoMips.jl");using .BogoMips;bogomips(true)'
```
