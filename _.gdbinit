set history size unlimited
set history save on


define armex
  printf "EXEC_RETURN (LR):\n",
  info registers $lr
    if (($lr & 0x4) == 0x4)
      printf "Uses MSP 0x%x return.\n", $msp
      set $armex_base = (uint32_t *)$msp
    else
      printf "Uses PSP 0x%x return.\n", $psp
      set $armex_base = (uint32_t *)$psp
    end

    printf "xPSR            0x%x\n", *($armex_base+7)
    printf "ReturnAddress   0x%x\n", *($armex_base+6)
    printf "LR (R14)        0x%x\n", *($armex_base+5)
    printf "R12             0x%x\n", *($armex_base+4)
    printf "R3              0x%x\n", *($armex_base+3)
    printf "R2              0x%x\n", *($armex_base+2)
    printf "R1              0x%x\n", *($armex_base+1)
    printf "R0              0x%x\n", *($armex_base)
    printf "Return instruction:\n"
    x/i *($armex_base+6)
    printf "LR instruction:\n"
    x/i *($armex_base+5)
end

document armex
ARMv7 Exception entry behavior.
xPSR, ReturnAddress, LR (R14), R12, R3, R2, R1, and R0
end

#python
#import sys
#sys.path.insert(0, '/usr/share/gcc-7.2.0/python')
#from libstdcxx.v6.printers import register_libstdcxx_printers
#register_libstdcxx_printers (None)
#end 
