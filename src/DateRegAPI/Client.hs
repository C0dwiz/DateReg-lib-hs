{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE OverloadedStrings #-}

module DateRegAPI.Client where

import Control.Monad.Reader
import Control.Monad.Except
import Network.HTTP.Client
import Network.HTTP.Types
import Data.Aeson
import Data.Text (Text)
import Data.ByteString.Lazy (ByteString)
import qualified Data.Text as T
import qualified Data.Text.Encoding as TE

import DateRegAPI.Core
import DateRegAPI.Models
import DateRegAPI.Errors
import DateRegAPI.Cache (Cache(..))

makeRequest :: FromJSON a => String -> [(String, String)] -> DateRegM a
makeRequest endpoint params = do
  DateRegAPI{..} <- ask
  let config = apiConfig
      url = configBaseUrl config ++ endpoint
      allParams = ("token", configToken config) : params

  let cacheKey = show (endpoint, allParams)
  cached <- liftIO $ cacheLookup apiCache cacheKey
  case cached of
    Just cachedValue -> case eitherDecode cachedValue of
      Right value -> return value
      Left _ -> makeHttpRequest
    Nothing -> makeHttpRequest
  where
    makeHttpRequest = do
      DateRegAPI{..} <- ask
      let config = apiConfig
      
      initReq <- parseRequest (configBaseUrl config ++ endpoint)
      let request = initReq
            { queryString = renderQuery True (map toByteStringPair (("token", configToken config) : params))
            }
      
      response <- liftIO $ httpLbs request apiManager
      let status = responseStatus response
          body = responseBody response
      
      case statusCode status of
        200 -> case eitherDecode body of
          Left err -> throwError $ ParseError err
          Right value -> do
            liftIO $ cacheInsert apiCache (configCacheSize config) (show (endpoint, params)) body
            return value
        
        401 -> throwError $ AuthenticationError "Invalid API token"
        402 -> throwError $ PaymentError "Insufficient balance"
        403 -> throwError $ ForbiddenError "API token blocked or method forbidden"
        404 -> throwError $ NotFoundError "Endpoint not found"
        code | code >= 500 -> throwError $ ServerError "Internal server error"
             | otherwise -> throwError $ APIError $ "Unexpected HTTP status: " ++ show code
    
    toByteStringPair (k, v) = (TE.encodeUtf8 (T.pack k), Just (TE.encodeUtf8 (T.pack v)))

getCreationDateFast :: Int -> DateRegM CreationDateResponse
getCreationDateFast userId
  | userId <= 0 = throwError $ InvalidInput "user_id must be positive"
  | otherwise = makeRequest "/users/getCreationDateFast" [("user_id", show userId)]

getCreationDateSmart :: Int -> DateRegM CreationDateResponse
getCreationDateSmart userId
  | userId <= 0 = throwError $ InvalidInput "user_id must be positive"
  | otherwise = makeRequest "/users/getCreationDateSmart" [("user_id", show userId)]

getCreationDateByUsername :: Text -> DateRegM CreationDateByUsernameResponse
getCreationDateByUsername username
  | T.null cleaned = throwError $ InvalidInput "Username cannot be empty"
  | otherwise = makeRequest "/users/getCreationDateByUsername" [("username", T.unpack cleaned)]
  where
    cleaned = T.strip $ T.dropWhile (== '@') username

resolveUsername :: Text -> DateRegM ResolveUsernameResponse
resolveUsername username
  | T.null cleaned = throwError $ InvalidInput "Username cannot be empty"
  | otherwise = makeRequest "/users/resolveUsername" [("username", T.unpack cleaned)]
  where
    cleaned = T.strip $ T.dropWhile (== '@') username