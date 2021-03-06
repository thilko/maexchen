module MessageParser ( parseCommand ) where


import Text.ParserCombinators.Parsec
import qualified Text.ParserCombinators.Parsec.Token as T
import Text.ParserCombinators.Parsec.Language

import qualified Data.ByteString as BS
import qualified Data.ByteString.Char8 as BSC

import Command

parseCommand :: BS.ByteString -> Command
parseCommand = runParser commandParser


runParser :: Parser a -> BS.ByteString -> a
runParser p str = case parse p "" (BSC.unpack str) of
  Left err  -> error $ "parse error at " ++ (show err)
  Right val -> val



commandParser :: Parser Command
commandParser = roundStartingP
            <|> yourTurnP
            <|> unknownP
            <?> "Parse error"


roundStartingP = do
  try $ symbolP "ROUND STARTING"
  semiP
  token <- tokenP
  return $ RoundStarting token

yourTurnP = do
  try $ symbolP "YOUR TURN"
  semiP
  token <- tokenP
  return $ YourTurn token

unknownP = do
  unknownCommand <- lineP
  return $ Unknown unknownCommand


lexer = T.makeTokenParser emptyDef

lineP     = many $ noneOf "\n"
semiP     = T.semi lexer
tokenP    = many $ noneOf ";"
symbolP   = T.symbol lexer
