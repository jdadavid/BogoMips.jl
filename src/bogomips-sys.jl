#!/bin/bash
# -*- mode: julia -*-
#=
exec /usr/local/bin/julia --color=yes --startup-file=no "${BASH_SOURCE[0]}" "$@"
=#

#using CpuId: cpucycle
the_cpu_info=Sys.cpu_info()
curcpu=1
for i = eachindex(the_cpu_info)
  global curcpu
  if the_cpu_info[i].speed > the_cpu_info[curcpu].speed
    curcpu=1
  end # if
end # for
print("(on cpu $curcpu)")
#const cpuMhz = Sys.cpu_info()[1].speed
const cpuMhz = the_cpu_info[curcpu].speed
const cpuGhz = cpuMhz*0.001
cpucyclejl()   = convert(UInt64,floor(time_ns()*cpuGhz))

using Printf
#using Infiltrator

#using InteractiveUtils
#println("Hello Julia cmd World!")

function delayp1(loops)
  for i in 1:loops
    x=i 
  end
end

function delayrt(cycles)
  c0=cpucyclejl()
  c1=c0+cycles
  c=c0
  while c<c1
    c=cpucyclejl()
  end
end

function the_main()
print("Calibrating delay loop.. ")

loops_to_do=1
done=false
success=false

while !done
  t0=time_ns()
  delayrt(loops_to_do)
  t1=time_ns()
  dtsec=(t1-t0)*1.0e-9
  #println(" loops_to_do=$loops_to_do dtsec=$dtsec")
  success = dtsec > 1
  #@infiltrate
  if success
    done = true
    loops_per_sec = (loops_to_do / dtsec)
    bogomips = loops_per_sec / 500_000
    @printf("ok - %.2f bogomips\n", bogomips)
  end
  la = loops_to_do
  #global loops_to_do
  loops_to_do = 2 * loops_to_do
  if loops_to_do < la ; done=true; end
end
if !success
  println("failed")
end

end
the_main()
