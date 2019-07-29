{-# LANGUAGE NoImplicitPrelude     #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE DeriveGeneric         #-}
{-# LANGUAGE DeriveAnyClass        #-}
{-# LANGUAGE FlexibleInstances     #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE PartialTypeSignatures #-}
{-# LANGUAGE StandaloneDeriving    #-}
{-# LANGUAGE TypeApplications      #-}
{-# LANGUAGE TypeFamilies          #-}

module Data where

import Import
import Data.Text (Text)
import Database.Beam
import Database.Beam.Postgres
import Data.Aeson

data UserT f = User
  { _id :: Columnar f Int
  , _password :: Columnar f Text
  , _email :: Columnar f Text
  , _username :: Columnar f Text
  , _bio :: Columnar f Text
  , _image :: Columnar f (Maybe Text)
  } deriving (Generic, Beamable)

type User = UserT Identity

deriving instance Show User
deriving instance Eq User
deriving instance Ord User
deriving instance ToJSON User
deriving instance FromJSON User

type UserId = PrimaryKey UserT Identity

deriving instance Show UserId
deriving instance Eq UserId
deriving instance Ord UserId

instance Table UserT where
  data PrimaryKey UserT f
      = UserId (Columnar f Int) deriving (Generic, Beamable)
  primaryKey = UserId . _id

data ConduitDb f = ConduitDb
  { _conduitUsers :: f (TableEntity UserT)
  } deriving (Generic)

instance Database Postgres ConduitDb

conduitDb :: DatabaseSettings Postgres ConduitDb
conduitDb = defaultDbSettings

runBeam :: (HasConnection env) => Pg a -> RIO env a
runBeam pg = do
  env <- ask
  liftIO $
    runBeamPostgres (connectionL env) $ pg

runBeamDebug :: (HasConnection env, HasLogFunc env) => Pg a -> RIO env a
runBeamDebug pg = do
  env <- ask
  liftIO $
    runBeamPostgresDebug (\s -> runRIO env $ logInfo $ fromString s) (connectionL env) $ pg

selectUsers :: (HasConnection env) => RIO env [User]
selectUsers = runBeam $ 
  runSelectReturningList $
    select $ all_ (_conduitUsers conduitDb)

selectUsersDebug :: (HasConnection env, HasLogFunc env) => RIO env [User]
selectUsersDebug = runBeamDebug $ 
  runSelectReturningList $
    select $ all_ (_conduitUsers conduitDb)