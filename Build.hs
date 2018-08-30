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

    doc <.> "pdf" %> \out -> do
        texSource <- getDirectoryFiles "" ["//*.tex"]
        mngSource <- getDirectoryFiles "" ["//*.mngtex"]
        let mngFiles = [c -<.> "mng" | c <- mngSource]
        need $ [ottFile] ++ mngFiles ++ texSource
        cmd "latexmk" [doc -<.> "tex"]

    "//*.mng" %> \out -> do
      ottSource <- getDirectoryFiles "" ["spec/*.ott"]
      need [out -<.> ".mngtex"]
      cmd "ott" ottSource ottFlags "-tex_filter" [out -<.> ".mngtex"] [out]

    ottFile %> \out -> do
        ottSource <- getDirectoryFiles "" ["spec/*.ott"]
        cmd "ott" ottSource ottFlags "-o" [out]

    phony "clean" $ do
        putNormal "Cleaning files in _build"
        removeFilesAfter "_build" ["//*"]
        cmd "latexmk -C"
