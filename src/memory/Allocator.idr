module Legion.Memory.Allocator

%default total

public export
data MemRegion : Type where
  MkMemRegion : (base : Bits64) -> (size : Bits64) -> (used : Bool) -> MemRegion

public export
record PhysFrame where
  constructor MkPhysFrame
  addr : Bits64

public export
record VirtPage where
  constructor MkVirtPage
  addr : Bits64

PAGE_SIZE : Bits64
PAGE_SIZE = 0x1000

HEAP_START : Bits64
HEAP_START = 0x400000

HEAP_INITIAL_SIZE : Bits64
HEAP_INITIAL_SIZE = 0x100000

public export
data AllocError : Type where
  OutOfMemory  : AllocError
  InvalidFree  : Bits64 -> AllocError
  DoubleFree   : Bits64 -> AllocError
  Misaligned   : Bits64 -> AllocError

%foreign "C:phys_mem_init,legion_ffi"
physMemInitFFI : IO ()

%foreign "C:virt_mem_init,legion_ffi"
virtMemInitFFI : IO ()

%foreign "C:heap_init,legion_ffi"
heapInitFFI : Bits64 -> Bits64 -> IO ()

%foreign "C:kmalloc,legion_ffi"
kmallocFFI : Bits64 -> IO Bits64

%foreign "C:kfree,legion_ffi"
kfreeFFI : Bits64 -> IO ()

%foreign "C:phys_alloc_frame,legion_ffi"
physAllocFrameFFI : IO Bits64

%foreign "C:phys_free_frame,legion_ffi"
physFreeFrameFFI : Bits64 -> IO ()

%foreign "C:virt_map_page,legion_ffi"
virtMapPageFFI : Bits64 -> Bits64 -> Bits32 -> IO ()

%foreign "C:virt_unmap_page,legion_ffi"
virtUnmapPageFFI : Bits64 -> IO ()

export
physMemInit : IO ()
physMemInit = physMemInitFFI

export
virtMemInit : IO ()
virtMemInit = virtMemInitFFI

export
heapInit : IO ()
heapInit = heapInitFFI HEAP_START HEAP_INITIAL_SIZE

export
kmalloc : Bits64 -> IO (Either AllocError Bits64)
kmalloc size = do
  ptr <- kmallocFFI size
  if ptr == 0
    then pure (Left OutOfMemory)
    else pure (Right ptr)

export
kfree : Bits64 -> IO ()
kfree ptr = kfreeFFI ptr

export
physAllocFrame : IO (Either AllocError PhysFrame)
physAllocFrame = do
  addr <- physAllocFrameFFI
  if addr == 0
    then pure (Left OutOfMemory)
    else pure (Right (MkPhysFrame addr))

export
physFreeFrame : PhysFrame -> IO ()
physFreeFrame (MkPhysFrame addr) = physFreeFrameFFI addr

public export
data PageFlag : Type where
  Present    : PageFlag
  Writable   : PageFlag
  UserAccess : PageFlag
  NoExecute  : PageFlag

flagBits : List PageFlag -> Bits32
flagBits = foldl (\acc, f => acc .|. tobit f) 0
  where
    tobit : PageFlag -> Bits32
    tobit Present    = 0x001
    tobit Writable   = 0x002
    tobit UserAccess = 0x004
    tobit NoExecute  = 0x800

export
virtMapPage : VirtPage -> PhysFrame -> List PageFlag -> IO ()
virtMapPage (MkVirtPage vaddr) (MkPhysFrame paddr) flags =
  virtMapPageFFI vaddr paddr (flagBits flags)

export
virtUnmapPage : VirtPage -> IO ()
virtUnmapPage (MkVirtPage vaddr) = virtUnmapPageFFI vaddr
