module Legion.Arch.X86.GDT

%default total

public export
data Ring : Type where
  Ring0 : Ring
  Ring3 : Ring

public export
data SegType : Type where
  Code : Ring -> SegType
  Data : Ring -> SegType
  TSS  : SegType
  Null : SegType

public export
record GDTEntry where
  constructor MkGDTEntry
  base  : Bits32
  limit : Bits32
  stype : SegType

public export
GDTTable : Type
GDTTable = List GDTEntry

defaultGDT : GDTTable
defaultGDT =
  [ MkGDTEntry 0 0 Null
  , MkGDTEntry 0 0xFFFFF (Code Ring0)
  , MkGDTEntry 0 0xFFFFF (Data Ring0)
  , MkGDTEntry 0 0xFFFFF (Code Ring3)
  , MkGDTEntry 0 0xFFFFF (Data Ring3)
  ]

encodeEntry : GDTEntry -> Bits64
encodeEntry (MkGDTEntry base limit stype) =
  let limitLow  = limit .&. 0xFFFF
      baseLow   = base  .&. 0xFFFF
      baseMid   = (base `shiftR` 16) .&. 0xFF
      baseHigh  = (base `shiftR` 24) .&. 0xFF
      access = case stype of
                 Null        => 0x00
                 Code Ring0  => 0x9A
                 Data Ring0  => 0x92
                 Code Ring3  => 0xFA
                 Data Ring3  => 0xF2
                 TSS         => 0x89
      flags = 0xCF
  in (cast limitLow)
       .|. (cast baseLow `shiftL` 16)
       .|. (cast baseMid `shiftL` 32)
       .|. (cast access  `shiftL` 40)
       .|. (cast flags   `shiftL` 52)
       .|. (cast baseHigh `shiftL` 56)

%foreign "C:gdt_load,legion_ffi"
gdtLoad : Bits32 -> Bits16 -> IO ()

export
gdtInit : IO ()
gdtInit =
  let entries = map encodeEntry defaultGDT
  in gdtLoad 0 (cast (length defaultGDT * 8 - 1))
