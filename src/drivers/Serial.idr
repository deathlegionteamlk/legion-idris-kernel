module Legion.Drivers.Serial

%default total

public export
data SerialPort : Type where
  COM1 : SerialPort
  COM2 : SerialPort
  COM3 : SerialPort
  COM4 : SerialPort

portBase : SerialPort -> Bits16
portBase COM1 = 0x3F8
portBase COM2 = 0x2F8
portBase COM3 = 0x3E8
portBase COM4 = 0x2E8

%foreign "C:outb,legion_ffi"
outb : Bits16 -> Bits8 -> IO ()

%foreign "C:inb,legion_ffi"
inb : Bits16 -> IO Bits8

lineStatus : SerialPort -> IO Bits8
lineStatus port = inb (portBase port + 5)

transmitEmpty : SerialPort -> IO Bool
transmitEmpty port = do
  status <- lineStatus port
  pure ((status .&. 0x20) /= 0)

waitTransmit : SerialPort -> IO ()
waitTransmit port = do
  ready <- transmitEmpty port
  if ready then pure () else waitTransmit port

export
serialInit : IO ()
serialInit = initPort COM1
  where
    initPort : SerialPort -> IO ()
    initPort port = do
      let base = portBase port
      outb (base + 1) 0x00
      outb (base + 3) 0x80
      outb (base + 0) 0x03
      outb (base + 1) 0x00
      outb (base + 3) 0x03
      outb (base + 2) 0xC7
      outb (base + 4) 0x0B

export
serialWriteChar : Char -> IO ()
serialWriteChar c = do
  waitTransmit COM1
  outb (portBase COM1) (cast (ord c))

export
serialWrite : String -> IO ()
serialWrite s = traverse_ serialWriteChar (unpack s)

export
serialReadChar : IO Char
serialReadChar = do
  status <- lineStatus COM1
  if (status .&. 0x01) /= 0
    then do b <- inb (portBase COM1)
            pure (chr (cast b))
    else serialReadChar
