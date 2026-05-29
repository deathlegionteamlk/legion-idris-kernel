module Legion.Arch.X86.PIC

%default total

PIC1_CMD  : Bits16
PIC1_CMD  = 0x20

PIC1_DATA : Bits16
PIC1_DATA = 0x21

PIC2_CMD  : Bits16
PIC2_CMD  = 0xA0

PIC2_DATA : Bits16
PIC2_DATA = 0xA1

ICW1_INIT : Bits8
ICW1_INIT = 0x11

ICW4_8086 : Bits8
ICW4_8086 = 0x01

%foreign "C:outb,legion_ffi"
outb : Bits16 -> Bits8 -> IO ()

%foreign "C:inb,legion_ffi"
inb : Bits16 -> IO Bits8

%foreign "C:io_wait,legion_ffi"
ioWait : IO ()

export
picRemap : Bits8 -> Bits8 -> IO ()
picRemap offset1 offset2 = do
  a1 <- inb PIC1_DATA
  a2 <- inb PIC2_DATA
  outb PIC1_CMD ICW1_INIT
  ioWait
  outb PIC2_CMD ICW1_INIT
  ioWait
  outb PIC1_DATA offset1
  ioWait
  outb PIC2_DATA offset2
  ioWait
  outb PIC1_DATA 0x04
  ioWait
  outb PIC2_DATA 0x02
  ioWait
  outb PIC1_DATA ICW4_8086
  ioWait
  outb PIC2_DATA ICW4_8086
  ioWait
  outb PIC1_DATA a1
  outb PIC2_DATA a2

export
picEOI : Bits8 -> IO ()
picEOI irq =
  if irq >= 8
    then do outb PIC2_CMD 0x20
            outb PIC1_CMD 0x20
    else outb PIC1_CMD 0x20

export
picMaskIRQ : Bits8 -> IO ()
picMaskIRQ irq =
  if irq < 8
    then do val <- inb PIC1_DATA
            outb PIC1_DATA (val .|. (1 `shiftL` cast irq))
    else do val <- inb PIC2_DATA
            outb PIC2_DATA (val .|. (1 `shiftL` cast (irq - 8)))

export
picUnmaskIRQ : Bits8 -> IO ()
picUnmaskIRQ irq =
  if irq < 8
    then do val <- inb PIC1_DATA
            outb PIC1_DATA (val .&. complement (1 `shiftL` cast irq))
    else do val <- inb PIC2_DATA
            outb PIC2_DATA (val .&. complement (1 `shiftL` cast (irq - 8)))
