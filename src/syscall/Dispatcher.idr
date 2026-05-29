module Legion.Syscall.Dispatcher

import Legion.Process.Scheduler
import Legion.Memory.Allocator
import Legion.Drivers.Serial

%default total

public export
data SyscallNr : Type where
  SysExit   : SyscallNr
  SysFork   : SyscallNr
  SysRead   : SyscallNr
  SysWrite  : SyscallNr
  SysOpen   : SyscallNr
  SysClose  : SyscallNr
  SysGetPID : SyscallNr
  SysSbrk   : SyscallNr
  SysYield  : SyscallNr
  SysUnknown : Bits32 -> SyscallNr

toSyscallNr : Bits32 -> SyscallNr
toSyscallNr 1  = SysExit
toSyscallNr 2  = SysFork
toSyscallNr 3  = SysRead
toSyscallNr 4  = SysWrite
toSyscallNr 5  = SysOpen
toSyscallNr 6  = SysClose
toSyscallNr 20 = SysGetPID
toSyscallNr 45 = SysSbrk
toSyscallNr 158 = SysYield
toSyscallNr n  = SysUnknown n

public export
record SyscallRegs where
  constructor MkSyscallRegs
  nr   : Bits32
  arg1 : Bits32
  arg2 : Bits32
  arg3 : Bits32
  arg4 : Bits32
  arg5 : Bits32

handleSyscall : SyscallRegs -> IO Bits32
handleSyscall regs =
  case toSyscallNr regs.nr of
    SysExit   => do exitProcess regs.arg1
                    pure 0
    SysFork   => do pid <- spawnProcess 0 5
                    pure (case pid of MkPID n => n)
    SysWrite  => do serialWrite (show regs.arg2)
                    pure regs.arg3
    SysGetPID => do pid <- currentPID
                    pure (case pid of MkPID n => n)
    SysYield  => do schedYield
                    pure 0
    SysSbrk   => do result <- kmalloc (cast regs.arg1)
                    pure (case result of
                            Left _    => 0xFFFFFFFF
                            Right ptr => cast ptr)
    _         => pure 0xFFFFFFFF

%foreign "C:syscall_register_handler,legion_ffi"
syscallRegisterHandlerFFI : (Bits32 -> Bits32 -> Bits32 -> Bits32 -> Bits32 -> Bits32 -> IO Bits32) -> IO ()

export
syscallInit : IO ()
syscallInit =
  syscallRegisterHandlerFFI $ \nr, a1, a2, a3, a4, a5 =>
    handleSyscall (MkSyscallRegs nr a1 a2 a3 a4 a5)
