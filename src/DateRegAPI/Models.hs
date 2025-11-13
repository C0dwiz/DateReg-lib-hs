{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}

module DateRegAPI.Models where

import Data.Aeson
import Data.Text (Text)
import GHC.Generics

data CreationDateResponse = CreationDateResponse
  { cdrUserId :: Int
  , cdrCreationDate :: Text
  , cdrAccuracyText :: Text
  , cdrAccuracyPercent :: Int
  } deriving (Show, Eq, Generic)

instance FromJSON CreationDateResponse where
  parseJSON = withObject "CreationDateResponse" $ \v -> CreationDateResponse
    <$> v .: "user_id"
    <*> v .: "creation_date"
    <*> v .: "accuracy_text"
    <*> v .: "accuracy_percent"

data CreationDateByUsernameResponse = CreationDateByUsernameResponse
  { cdburUsername :: Text
  , cdburUserId :: Int
  , cdburCreationDate :: Text
  , cdburAccuracyText :: Text
  , cdburAccuracyPercent :: Int
  } deriving (Show, Eq, Generic)

instance FromJSON CreationDateByUsernameResponse where
  parseJSON = withObject "CreationDateByUsernameResponse" $ \v -> CreationDateByUsernameResponse
    <$> v .: "username"
    <*> v .: "user_id"
    <*> v .: "creation_date"
    <*> v .: "accuracy_text"
    <*> v .: "accuracy_percent"

data UsernameInfo = UsernameInfo
  { uiUsername :: Text
  , uiEditable :: Bool
  , uiActive :: Bool
  } deriving (Show, Eq, Generic)

instance FromJSON UsernameInfo where
  parseJSON = withObject "UsernameInfo" $ \v -> UsernameInfo
    <$> v .: "username"
    <*> v .: "editable"
    <*> v .: "active"

data UserPhoto = UserPhoto
  { upPhotoId :: Int
  , upDcId :: Int
  , upHasVideo :: Bool
  , upPersonal :: Bool
  , upStrippedThumb :: Maybe Text
  } deriving (Show, Eq, Generic)

instance FromJSON UserPhoto where
  parseJSON = withObject "UserPhoto" $ \v -> UserPhoto
    <$> v .: "photo_id"
    <*> v .: "dc_id"
    <*> v .: "has_video"
    <*> v .: "personal"
    <*> v .:? "stripped_thumb"

data ResolveUsernameResponse = ResolveUsernameResponse
  { rurId :: Int
  , rurFirstName :: Maybe Text
  , rurLastName :: Maybe Text
  , rurUsername :: Maybe Text
  , rurPhone :: Maybe Text
  , rurPremium :: Bool
  , rurVerified :: Bool
  , rurBot :: Bool
  , rurDeleted :: Bool
  , rurScam :: Bool
  , rurFake :: Bool
  , rurAccessHash :: Maybe Int
  , rurPhoto :: Maybe UserPhoto
  , rurUsernames :: [UsernameInfo]
  } deriving (Show, Eq, Generic)

instance FromJSON ResolveUsernameResponse where
  parseJSON = withObject "ResolveUsernameResponse" $ \v -> ResolveUsernameResponse
    <$> v .: "id"
    <*> v .:? "first_name"
    <*> v .:? "last_name"
    <*> v .:? "username"
    <*> v .:? "phone"
    <*> v .: "premium"
    <*> v .: "verified"
    <*> v .: "bot"
    <*> v .: "deleted"
    <*> v .: "scam"
    <*> v .: "fake"
    <*> v .:? "access_hash"
    <*> v .:? "photo"
    <*> v .: "usernames"