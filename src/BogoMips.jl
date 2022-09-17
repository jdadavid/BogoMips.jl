module BogoMips

export bogomips

using Printf

# using CpuId: cpucycle
# cupcyclejl() = CpuId.cpucycle()

alwaysinitGhz=true;

cpuGhz = nothing;
cur_cpu = nothing;
cpuGhzmin = 0;
cpumin=1;
cpumax=1;
cpuGhzmax = nothing;

# function fib, for small workload (fib(20): ~5mus) and heavy workload (fib(30): ~5ms on my Ryzen 5 3500U)
#   n      fib_value  time(mus)
#  20         10_946         40
#  25        121_393        431
#  30      1_346_269      4_957
#  35     14_930_352     53_998
#  40    165_580_141    635_562
#  41    267_914_296  1_042_420
#  42    433_494_437  1_737_908
#  43    701_408_733  2_869_705
#  44  1_134_903_170  4_448_693
#  45  1_836_311_903  7_227_998

function fib(n)
    if n <= 1 return 1 end
    return fib(n - 1) + fib(n - 2)
end

function initGhz(verbose=false)
  global cur_cpu
  global cpuGhz
  the_cpu_info=Sys.cpu_info()
  cur_cpu=firstindex(the_cpu_info)
  for i = eachindex(the_cpu_info)
    if the_cpu_info[i].speed > the_cpu_info[cur_cpu].speed
      cur_cpu=i
    end # if
  end # for
  cpuMhz = the_cpu_info[cur_cpu].speed
  cpuGhz = cpuMhz*0.001
  if verbose; println("initGhz : $(round(cpuGhz,digits=1)) Ghz on cpu $cur_cpu."); end
end

function 

cpucycleGhz() = convert(UInt64,floor(time_ns()*cpuGhz))
cpucyclejl = cpucycleGhz

function delayrt(cycles)
  c0=cpucyclejl()
  c1=c0+cycles
  c=c0
  while c<c1
    c=cpucyclejl()
  end
end

"""
 bogomips(verbose=false)
 Compute bogomips (see https://en.wikipedia.org/wiki/BogoMips )
   . if verbose is true, print the result to stdout (and return nothing, in order not to pollute stdout in REPL)
   . if verbose is false (default), return computed bogomips value
"""
function bogomips(verbose=false)
  if alwaysinitGhz
    initGhz(verbose)
  end
  if verbose
    print("Calibrating delay loop..")
    print("(cpu$(cur_cpu)@$(round(cpuGhz,digits=1))Ghz)..")
  end
  loops_to_do=1
  done=false
  success=false
  bogo=nothing

  while !done
    t0=time_ns()
    delayrt(loops_to_do)
    t1=time_ns()
    dtsec=(t1-t0)*1.0e-9
    success = dtsec > 1
    if success
      done = true
      loops_per_sec = (loops_to_do / dtsec)
      bogo = loops_per_sec / 500_000
	  # bogo=round(bogo,digits=2)
      if verbose
        @printf("..ok - %.0f bogomips\n", bogo)
		return nothing
	  else
	    return bogo
      end
    end
    la = loops_to_do
    loops_to_do = 2 * loops_to_do
    if loops_to_do < la ; done=true; end
  end # while !done
  if !success
    @warn "bogomips failed : looptodo is $loops_to_do, la is $la; loop took $dtsec secs)"
  end
  return bogo
end

function __init__()
  initGhz()
  # cpucyclejl=cupcycleGhz1;
end

end # module
