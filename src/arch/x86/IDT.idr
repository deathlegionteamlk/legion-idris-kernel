module Legion.Arch.X86.IDT

%default total

public export
data GateType : Type where
  InterruptGate : GateType
  TrapGate      : GateType
  TaskGate      : GateType

public export
record IDTEntry where
  constructor MkIDTEntry
  handler  : Bits32
  selector : Bits16
  gtype    : GateType
  dpl      : Bits8

public export
IDTTable : Type
IDTTable = Vect 256 IDTEntry

nullEntry : IDTEntry
nullEntry = MkIDTEntry 0 0 InterruptGate 0

encodeGate : GateType -> Bits8
encodeGate InterruptGate = 0x8E
encodeGate TrapGate      = 0x8F
encodeGate TaskGate      = 0x85

%foreign "C:idt_set_gate,legion_ffi"
idtSetGate : Bits8 -> Bits32 -> Bits16 -> Bits8 -> IO ()

%foreign "C:idt_load,legion_ffi"
idtLoad : IO ()

%foreign "C:isr_stub_table,legion_ffi"
isrStubTable : Bits32

installISRs : Nat -> IO ()
installISRs 0 = pure ()
installISRs (S n) = do
  installISRs n
  idtSetGate (cast n) (isrStubTable + cast (n * 4)) 0x08 0x8E

export
idtInit : IO ()
idtInit = do
  installISRs 256
  idtLoad
