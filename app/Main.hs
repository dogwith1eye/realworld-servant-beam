{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell   #-}
module Main (main) where

import Import
import Run
import RIO.Process
import Options.Applicative.Simple
import qualified Paths_realworld_servant_beam
import Database.PostgreSQL.Simple

main :: IO ()
main = do
  (options, ()) <- simpleOptions
    $(simpleVersion Paths_realworld_servant_beam.version)
    "Header for command line arguments"
    "Program description, also for command line arguments"
    (Options
       <$> switch ( long "verbose"
                 <> short 'v'
                 <> help "Verbose output?"
                  )
    )
    empty
  lo <- logOptionsHandle stderr (optionsVerbose options)
  pc <- mkDefaultProcessContext
  conn <- connectPostgreSQL "postgresql://postgres@db/conduit"
  withLogFunc lo $ \lf ->
    let app = App
          { appLogFunc = lf
          , appProcessContext = pc
          , appOptions = options
          , appPort = 8080
          , appConnection = conn
          }
     in runRIO app startApp
