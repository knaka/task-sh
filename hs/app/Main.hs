module Main (main) where

-- pcapriotti/optparse-applicative: Applicative option parser https://github.com/pcapriotti/optparse-applicative/?tab=readme-ov-file#quick-start

import Options.Applicative
import Control.Monad (join)
-- import Data.Semigroup ((<>))

-- 各サブコマンドの情報を保持するデータ型を定義
data CommandInfo = CommandInfo
  { cmdName   :: String
  , cmdDesc   :: String
  , cmdParser    :: Parser (IO ())
  }

-- サブコマンドの定義をリストで管理
commands :: [CommandInfo]
commands =
  [ CommandInfo "hs-start" "Start the process" (start <$> argument str (metavar "ARG"))
  , CommandInfo "hs-stop"  "Stop the process"  (pure stop)
  , CommandInfo "subcmds" "List subcommands" (pure subcmds)
  ]

-- 各コマンドのパーサーを生成
opts :: Parser (IO ())
opts = subparser $ mconcat $ map mkCommand commands
  where
    mkCommand :: CommandInfo -> Mod CommandFields (IO ())
    mkCommand (CommandInfo name desc parser) =
      command name (info parser (progDesc desc))

start :: String -> IO ()
start arg = putStrLn $ "start " ++ arg

stop :: IO ()
stop = putStrLn "stop"

-- サブコマンドの一覧を表示する関数
subcmds :: IO ()
subcmds = do
  mapM_ (\cmd -> putStrLn $ "" ++ cmdName cmd ++ "\t" ++ cmdDesc cmd) commands

main :: IO ()
main = join $ execParser (info opts idm)
