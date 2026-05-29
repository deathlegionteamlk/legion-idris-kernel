module Main

import Legion.Boot.Init
import Legion.Memory.Allocator
import Legion.Process.Scheduler
import Legion.Drivers.Serial
import Legion.Syscall.Dispatcher
import Legion.Arch.X86.GDT
import Legion.Arch.X86.IDT
import Legion.Arch.X86.PIC

%default total

kernelName : String
kernelName = "Legion Idris Kernel"

kernelVersion : String
kernelVersion = "0.1.0"

kernelAuthor : String
kernelAuthor = "Demo X Hexa"

kernelOrg : String
kernelOrg = "Death Legion Team LK"

kernelGitHub : String
kernelGitHub = "https://github.com/deathlegionteamlk"

kernelBanner : String
kernelBanner =
  "\n" ++
  "  ██╗     ███████╗ ██████╗ ██╗ ██████╗ ███╗  ██╗\n" ++
  "  ██║     ██╔════╝██╔════╝ ██║██╔═══██╗████╗ ██║\n" ++
  "  ██║     █████╗  ██║  ███╗██║██║   ██║██╔██╗██║\n" ++
  "  ██║     ██╔══╝  ██║   ██║██║██║   ██║██║╚████║\n" ++
  "  ███████╗███████╗╚██████╔╝██║╚██████╔╝██║ ╚███║\n" ++
  "  ╚══════╝╚══════╝ ╚═════╝ ╚═╝ ╚═════╝ ╚═╝  ╚══╝\n" ++
  "\n" ++
  "  " ++ kernelName ++ " v" ++ kernelVersion ++ "\n" ++
  "  " ++ kernelAuthor ++ " | " ++ kernelOrg ++ "\n" ++
  "  " ++ kernelGitHub ++ "\n"

export
kernelMain : IO ()
kernelMain = do
  serialInit
  serialWrite kernelBanner
  serialWrite "[boot] GDT init\n"
  gdtInit
  serialWrite "[boot] IDT init\n"
  idtInit
  serialWrite "[boot] PIC remap\n"
  picRemap 0x20 0x28
  serialWrite "[boot] Physical memory init\n"
  physMemInit
  serialWrite "[boot] Virtual memory init\n"
  virtMemInit
  serialWrite "[boot] Heap init\n"
  heapInit
  serialWrite "[boot] Scheduler init\n"
  schedulerInit
  serialWrite "[boot] Syscall table init\n"
  syscallInit
  serialWrite "[boot] Kernel ready\n"
  schedulerRun

main : IO ()
main = kernelMain
