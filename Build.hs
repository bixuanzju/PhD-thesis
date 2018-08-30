import Development.Shake
import Development.Shake.Command
import Development.Shake.FilePath
import Development.Shake.Util


ottFile = "ott-rules.tex"
doc = "Thesis"
ottFlags = "-tex_wrap false -tex_show_meta false"


main :: IO ()
main = shakeArgs shakeOptions{shakeFiles="_build"} $ do

    want [doc <.> "pdf"]

    "*.pdf" %> \_ -> do
        texSource <- getDirectoryFiles "" ["//*.tex"]
        mngSource <- getDirectoryFiles "" ["//*.mngtex"]
        let mngFiles = [c -<.> "mng" | c <- mngSource]
        need $ [ottFile] ++ mngFiles ++ texSource
        cmd "latexmk" [doc -<.> "tex"]

    "//*.mng" %> \out -> do
      ottSource <- getDirectoryFiles "" ["spec/*.ott"]
      let dep = out -<.> ".mngtex"
      need $ dep : ottSource
      cmd "ott" ottSource ottFlags "-tex_filter" [dep] [out]

    ottFile %> \out -> do
        ottSource <- getDirectoryFiles "" ["spec/*.ott"]
        need ottSource
        cmd "ott" ottSource ottFlags "-o" [out]

    phony "clean" $ do
        putNormal "Cleaning files in _build"
        removeFilesAfter "_build" ["//*"]
        cmd "latexmk -C"
