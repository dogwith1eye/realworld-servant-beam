{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE TemplateHaskell   #-}
{-# LANGUAGE TypeOperators     #-}
module Run
    ( startApp
    ) where

import Import
import Network.Wai.Handler.Warp
import Servant
import Data

type API = "users" :> Get '[JSON] [User]

startApp ::  (HasLogFunc env, HasConnection env, HasPort env) => RIO env ()
startApp = do
  env <- ask
  logInfo $ "app is listening on port " <> (display (portL env))
  let srv = hoistServer api (runRIO env) server
  let app = serve api srv
  liftIO $ run (portL env) app 

api :: Proxy API
api = Proxy

server :: (HasConnection env, HasLogFunc env) => ServerT API (RIO env)
server = selectUsersDebug