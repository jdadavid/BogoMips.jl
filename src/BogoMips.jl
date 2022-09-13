module BogoMips

export bogomips

using Printf

# using CpuId: cpucycle
# cupcyclejl() = CpuId.cpucycle()

cur_cpucycle=0;

function init_cpucycle(verbose=false)
  the_cpu_info=Sys.cpu_info()
  cur_cpu=firstindex(the_cpu_info)
  for i = eachindex(the_cpu_info)
    # global cur_cpu
    if the_cpu_info[i].speed > the_cpu_info[cur_cpu].speed
      cur_cpu=i
    end # if
  end # for
  if verbose; print("(on cpu $curcpu)"); end
  const cpuMhz = the_cpu_info[curcpu].speed
  const cpuGhz = cpuMhz*0.001
  global cur_cpucycle=convert(UInt64,floor(time_ns()*cpuGhz))
end
cpucyclejl()   = cur_cpucycle;


function delayrt(cycles)
  c0=cpucyclejl()
  c1=c0+cycles
  c=c0
  while c<c1
    c=cpucyclejl()
  end
end

function bogomips(verbose=false)
  if verbose
    print("Calibrating delay loop.. ")
  end
  # if cur_cpucycle == 0
      init_cpucycle(verbose)
  # end
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
      if verbose
        @printf("ok - %.2f bogomips\n", bogomips)
      end
      return bogo
    end
    la = loops_to_do
    loops_to_do = 2 * loops_to_do
    if loops_to_do < la ; done=true; end
  end
  if !success
    @warning "bogomips failed : $dtsec secs)"
  end
  return bogo
end

end # module
