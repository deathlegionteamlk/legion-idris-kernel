module Legion.Process.Scheduler

import Legion.Memory.Allocator

%default total

public export
data PID : Type where
  MkPID : Bits32 -> PID

public export
data ProcessState : Type where
  Running  : ProcessState
  Ready    : ProcessState
  Blocked  : ProcessState
  Zombie   : ProcessState

public export
record Registers where
  constructor MkRegisters
  eax, ebx, ecx, edx : Bits32
  esi, edi, esp, ebp : Bits32
  eip, eflags        : Bits32
  cs, ds, ss         : Bits16

public export
record Process where
  constructor MkProcess
  pid       : PID
  state     : ProcessState
  regs      : Registers
  pageDir   : Bits32
  kernStack : Bits32
  userStack : Bits32
  priority  : Bits8
  timeSlice : Bits32
  parent    : Maybe PID
  name      : String

pidEq : PID -> PID -> Bool
pidEq (MkPID a) (MkPID b) = a == b

KERNEL_STACK_SIZE : Bits64
KERNEL_STACK_SIZE = 0x2000

USER_STACK_SIZE : Bits64
USER_STACK_SIZE = 0x4000

DEFAULT_TIME_SLICE : Bits32
DEFAULT_TIME_SLICE = 10

%foreign "C:sched_init,legion_ffi"
schedInitFFI : IO ()

%foreign "C:sched_run,legion_ffi"
schedRunFFI : IO ()

%foreign "C:sched_yield,legion_ffi"
schedYieldFFI : IO ()

%foreign "C:sched_spawn,legion_ffi"
schedSpawnFFI : Bits32 -> Bits8 -> IO Bits32

%foreign "C:sched_exit,legion_ffi"
schedExitFFI : Bits32 -> IO ()

%foreign "C:sched_block,legion_ffi"
schedBlockFFI : Bits32 -> IO ()

%foreign "C:sched_unblock,legion_ffi"
schedUnblockFFI : Bits32 -> IO ()

%foreign "C:sched_current_pid,legion_ffi"
schedCurrentPidFFI : IO Bits32

export
schedulerInit : IO ()
schedulerInit = schedInitFFI

export
schedulerRun : IO ()
schedulerRun = schedRunFFI

export
schedYield : IO ()
schedYield = schedYieldFFI

export
spawnProcess : Bits32 -> Bits8 -> IO PID
spawnProcess entryPoint prio = do
  pid <- schedSpawnFFI entryPoint prio
  pure (MkPID pid)

export
exitProcess : Bits32 -> IO ()
exitProcess code = schedExitFFI code

export
blockProcess : PID -> IO ()
blockProcess (MkPID pid) = schedBlockFFI pid

export
unblockProcess : PID -> IO ()
unblockProcess (MkPID pid) = schedUnblockFFI pid

export
currentPID : IO PID
currentPID = map MkPID schedCurrentPidFFI
