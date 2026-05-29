module Legion.FS.VFS

%default total

public export
data FileType : Type where
  RegularFile : FileType
  Directory   : FileType
  CharDevice  : FileType
  BlockDevice : FileType
  SymLink     : FileType

public export
data OpenFlag : Type where
  O_RDONLY : OpenFlag
  O_WRONLY : OpenFlag
  O_RDWR   : OpenFlag
  O_CREAT  : OpenFlag
  O_TRUNC  : OpenFlag
  O_APPEND : OpenFlag

public export
record INode where
  constructor MkINode
  ino     : Bits32
  ftype   : FileType
  size    : Bits64
  uid     : Bits16
  gid     : Bits16
  mode    : Bits16
  nlinks  : Bits32

public export
record FileDesc where
  constructor MkFileDesc
  fd    : Bits32
  inode : INode
  pos   : Bits64
  flags : List OpenFlag

public export
record DirEntry where
  constructor MkDirEntry
  ino  : Bits32
  name : String

public export
interface FileSystem (0 fs : Type) where
  fsOpen    : fs -> String -> List OpenFlag -> IO (Either String FileDesc)
  fsClose   : fs -> FileDesc -> IO (Either String ())
  fsRead    : fs -> FileDesc -> Bits64 -> IO (Either String (List Bits8, FileDesc))
  fsWrite   : fs -> FileDesc -> List Bits8 -> IO (Either String (Bits64, FileDesc))
  fsReadDir : fs -> String -> IO (Either String (List DirEntry))
  fsStat    : fs -> String -> IO (Either String INode)
  fsMkDir   : fs -> String -> Bits16 -> IO (Either String ())
  fsUnlink  : fs -> String -> IO (Either String ())
