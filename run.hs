#! /usr/bin/env nix-shell
#! nix-shell shell.nix -i runghc

{-# LANGUAGE OverloadedStrings #-}

import qualified Data.Text as Text
import Turtle hiding (text)

main :: IO ()
main = sh $ do
  getWebAppVpsIp

appName = "move"

getWebAppVpsIp :: Shell ()
getWebAppVpsIp = do
  line <- single (inproc command args empty)
  echo line
  where
    command = "docker-machine"
    args = ["ip", appName]