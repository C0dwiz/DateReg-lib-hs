{-# LANGUAGE OverloadedStrings #-}

module Main where

import DateRegAPI
import Data.Default
import Control.Monad.Reader (runReaderT)
import Control.Monad.Except (runExceptT)

main :: IO ()
main = do
  let config = def
        { configToken = "your-token-here"
        }
  
  withDateRegAPI config $ \api -> do
    -- Получаем информацию о пользователе
    result <- runExceptT $ runReaderT (runDateRegM (resolveUsername "liteapi")) api
    case result of
      Left err -> putStrLn $ "Error: " ++ show err
      Right userInfo -> do
        putStrLn $ "User ID: " ++ show (rurId userInfo)
        putStrLn $ "Username: " ++ maybe "N/A" show (rurUsername userInfo)
        putStrLn $ "Premium: " ++ show (rurPremium userInfo)
        
        -- Получаем дату регистрации
        creationResult <- runExceptT $ runReaderT (runDateRegM (getCreationDateSmart (rurId userInfo))) api
        case creationResult of
          Left err -> putStrLn $ "Error getting creation date: " ++ show err
          Right creationDate -> do
            putStrLn $ "Creation date: " ++ show (cdrCreationDate creationDate)
            putStrLn $ "Accuracy: " ++ show (cdrAccuracyPercent creationDate) ++ "%"