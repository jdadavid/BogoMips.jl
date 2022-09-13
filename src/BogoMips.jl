module BogoMips

export bogomips

using Printf

# using CpuId: cpucycle
# cupcyclejl() = CpuId.cpucycle()

cpuGhz = nothing;
cur_cpu = nothing;

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
  if verbose; println("$cpuGhz Ghz on cpu $cur_cpu."); end
end

cpucyclejl() = convert(UInt64,floor(time_ns()*cpuGhz))

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
  if verbose
    print("Calibrating delay loop..")
    print("(on cpu $cur_cpu)")
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
end

end # module
