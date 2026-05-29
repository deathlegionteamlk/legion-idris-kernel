module Legion.Boot.Init

import Legion.Arch.X86.GDT
import Legion.Arch.X86.IDT
import Legion.Arch.X86.PIC
import Legion.Memory.Allocator
import Legion.Drivers.Serial

%default total

export
data BootInfo : Type where
  MkBootInfo : (memLower : Bits32) -> (memUpper : Bits32) -> (cmdLine : String) -> BootInfo

export
bootInfoMemTotal : BootInfo -> Bits32
bootInfoMemTotal (MkBootInfo lo hi _) = lo + hi

export
bootPanic : String -> IO ()
bootPanic msg = do
  serialWrite "\n[PANIC] "
  serialWrite msg
  serialWrite "\n[PANIC] System halted.\n"
  haltCPU

%foreign "C:halt_cpu,legion_ffi"
export
haltCPU : IO ()
