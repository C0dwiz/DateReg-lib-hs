module DateRegAPI.Errors
  ( DateRegError(..)
  , handleDateRegError
  ) where

import Control.Exception

data DateRegError
  = AuthenticationError String
  | PaymentError String
  | ForbiddenError String
  | NotFoundError String
  | ServerError String
  | APIError String
  | RequestError String
  | InvalidInput String
  | ParseError String
  deriving (Show, Eq)

instance Exception DateRegError

handleDateRegError :: IO a -> (DateRegError -> IO a) -> IO a
handleDateRegError = catch