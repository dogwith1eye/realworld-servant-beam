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
import Data (selectUsers, User)

type API = "users" :> Get '[JSON] [User]

startApp ::  (HasLogFunc env, HasConnection env, HasPort env) => RIO env ()
startApp = do
  app <- conduit
  env <- ask
  logInfo $ "app is listening on port " <> (display (portL env))
  liftIO $ run (portL env) app

conduit :: (HasConnection env) => RIO env Application
conduit = serve api <$> server

api :: Proxy API
api = Proxy

server :: (HasConnection env) => RIO env (Server API)
server = users

toHandler :: a -> Servant.Handler a
toHandler = return

users :: (HasConnection env) => RIO env (Servant.Handler [User])
users = toHandler <$> selectUsers
