module Legion.IPC.Pipe

import Legion.Process.Scheduler
import Legion.Memory.Allocator

%default total

PIPE_BUFFER_SIZE : Bits64
PIPE_BUFFER_SIZE = 0x1000

public export
data PipeEnd : Type where
  ReadEnd  : PipeEnd
  WriteEnd : PipeEnd

public export
record Pipe where
  constructor MkPipe
  readFD  : Bits32
  writeFD : Bits32
  buffer  : Bits64
  head    : Bits64
  tail    : Bits64
  readers : List PID
  writers : List PID

public export
data IPCError : Type where
  BrokenPipe   : IPCError
  PipeFull     : IPCError
  PipeEmpty    : IPCError
  BadFD        : Bits32 -> IPCError

%foreign "C:pipe_create,legion_ffi"
pipeCreateFFI : IO Bits64

%foreign "C:pipe_read,legion_ffi"
pipeReadFFI : Bits64 -> Bits64 -> IO Bits64

%foreign "C:pipe_write,legion_ffi"
pipeWriteFFI : Bits64 -> Bits64 -> Bits64 -> IO Bits64

%foreign "C:pipe_close,legion_ffi"
pipeCloseFFI : Bits64 -> Bits8 -> IO ()

export
pipeCreate : IO (Either IPCError (Bits32, Bits32))
pipeCreate = do
  handle <- pipeCreateFFI
  if handle == 0
    then pure (Left BrokenPipe)
    else pure (Right (cast handle, cast handle + 1))

export
pipeRead : Bits32 -> Bits64 -> IO (Either IPCError Bits64)
pipeRead fd count = do
  n <- pipeReadFFI (cast fd) count
  if n == 0xFFFFFFFFFFFFFFFF
    then pure (Left PipeEmpty)
    else pure (Right n)

export
pipeWrite : Bits32 -> Bits64 -> IO (Either IPCError Bits64)
pipeWrite fd buf = do
  n <- pipeWriteFFI (cast fd) buf PIPE_BUFFER_SIZE
  if n == 0xFFFFFFFFFFFFFFFF
    then pure (Left PipeFull)
    else pure (Right n)

export
pipeClose : Bits32 -> PipeEnd -> IO ()
pipeClose fd end =
  pipeCloseFFI (cast fd) (case end of ReadEnd => 0; WriteEnd => 1)
