{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE TemplateHaskell   #-}
{-# LANGUAGE TypeOperators     #-}
module Run
    ( startApp
    ) where

import Import
import Network.Wai
import Network.Wai.Handler.Warp
import Servant
import Data

type API = "users" :> Get '[JSON] [User]

startApp ::  (HasLogFunc env, HasConnection env, HasPort env) => RIO env ()
startApp = do
  env <- ask
  logInfo $ "app is listening on port " <> (display (portL env))
  liftIO $ run (portL env) $ serve api $ hoistServer api (runRIO env) server

api :: Proxy API
api = Proxy

server :: (HasConnection env, HasLogFunc env) => ServerT API (RIO env)
server = selectUsersDebug