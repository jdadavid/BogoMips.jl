module BogoMips

export bogomips

using Printf

# using CpuId: cpucycle
# cupcyclejl() = CpuId.cpucycle()

alwaysinit=true;
function setalwaysinit(); return alwaysinit ; end
function setalwaysinit(b::Bool); ba=alwaysinit; global alwaysinit=b; return ba end

the_cpu_info=nothing
ncpus=0
speeds=Vector{Int32}(undef,ncpus)
tusr=Vector{UInt64}(undef,ncpus)
ttot=Vector{UInt64}(undef,ncpus)
cpumin=nothing
cpumax=nothing
MHzmax=nothing
cpucur=1

function init_cpuinfo()
	global the_cpu_info,ncpus,speeds,tusr,ttot,cpumin,cpumax,MHzmax
	the_cpu_info=Sys.cpu_info()
	ncpus=length(the_cpu_info)
	speeds=Vector{Int32}(undef,ncpus)
	tusr=Vector{UInt64}(undef,ncpus)
	ttot=Vector{UInt64}(undef,ncpus)
	for i in eachindex(the_cpu_info)
		speeds[i]=the_cpu_info[i].speed
		
		tusr[i]=the_cpu_info[i].cpu_times!user
		ttot[i]=tusr[i]
		ttot[i]=ttot[i]+the_cpu_info[i].cpu_times!sys
		ttot[i]=ttot[i]+the_cpu_info[i].cpu_times!nice
		ttot[i]=ttot[i]+the_cpu_info[i].cpu_times!irq
		# ttot[i]=ttot[i]+the_cpu_info[i].cpu_times!idle
	end
	_     ,cpumin =findmin(speeds)
	MHzmax,cpumax =findmax(speeds)
	nothing
end

function getcpucur(); cpucur;end
function setcpucur()
	global cpucur
	cpucur=1
end
	
	
init_cpuinfo()
setcpucur()


cpuGHz() = cpuMHz()*0.001
cpuMHz() = 0.001*speeds[cpucur]


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

cpucycleMhzx() = convert(UInt64,floor(0.001*time_ns()*speeds[cpumax]))
cpucyclecur()  = convert(UInt64,floor(0.001*time_ns()*speeds[cpucur]))

cpucyclejl() = cpucyclecur()

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
  # if alwaysinit; initGhz(verbose); end
  if alwaysinit; init_cpuinfo(); end
  if verbose
    print("Calibrating delay loop..")
    print("(cpu$(cpucur)@$(round(cpuGHz(),digits=1))Ghz)..")
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

# Grabbed from ThreadPinning.jl/querying.jl
"""
Returns the ID of the CPU on which the calling thread
is currently executing.
See `sched_getcpu` for more information.
"""
getcpuid() = Int(sched_getcpu())

# """
# Returns the ID of the CPU on which the given Julia thread
# (`threadid`) is currently executing.
# """
# getcpuid(threadid::Integer) = fetch(@tspawnat threadid getcpuid())

# """
# Returns the ID of the CPUs on which the Julia threads
# are currently running.
# See `getcpuid` for more information.
# """
# function getcpuids()
    # nt = nthreads()
    # cpuids = zeros(Int, nt)
    # @threads :static for tid in 1:nt
        # cpuids[tid] = getcpuid()
    # end
    # return cpuids
# end
# Grabbed from ThreadPinning.jl/libuv.jl
# ------------ uv.h ------------
# Documentation:
# https://github.com/clibs/uv/blob/master/docs/src/threading.rst
const uv_thread_t = Culong # = pthread_t

"""
Ref: [docs](https://github.com/clibs/uv/blob/d0240ce496fcd86d45e8a6b211732220fdb27eac/docs/src/threading.rst#L130)
"""
uv_thread_self() = @ccall uv_thread_self()::uv_thread_t
# End Grabbed

function __init__()
  init_cpuinfo()
  setcpucur()
end

end # module
