#! /usr/bin/env nix-shell
#! nix-shell -i runghc -p "haskellPackages.ghcWithPackages (p: with p; [ text turtle neat-interpolation pureMD5 ])"

{-# LANGUAGE OverloadedStrings, QuasiQuotes #-}

import qualified Data.Text as Text
import Turtle hiding (text)
import NeatInterpolation (text)

main :: IO ()
main = sh $ do
  copySshKeysToVagrant
{-
  server <- getServer   -- Read the server address from a file
  path <- build         -- Build NixOS for our server
  upload server path    -- Upload the build to the server
  activate server path  -- Start running the new version
-}
appName = "move"

getWebAppVpsIp = Shell ()
  line <- single (inproc command args empty)
  echo line
  where
    command = "docker-machine"
    args = ["ip", appName]

-- The path of the NixOS build that we're deploying.
newtype NixOS = NixOS Text

-- The address of the server to which we're deploying.
newtype Server = Server Text

vagrantIdentityFile = ".vagrant/machines/default/virtualbox/private_key"
vagrantUser = "vagrant"
vagrantHost = "172.16.16.16"

nixosIdentityFile = "id_rsa_nixos"

getServer :: Shell Server
getServer = do
  line <- single (input "server-address.txt")
  return (Server (lineToText line))

build :: Shell NixOS
build =
  do
    line <- single (inproc command args empty)
    return (NixOS (lineToText line))
  where
    command = "nix-build"
    args = ["server.nix", "--no-out-link"]

upload :: Server -> NixOS -> Shell ()
upload (Server server) (NixOS path) =
  procs command args empty
  where
    command = "nix-copy-closure"
    args = ["--to", "--use-substitutes", server, path]

activate :: Server -> NixOS -> Shell ()
activate (Server server) (NixOS path) =
  procs command args empty
  where
    command = "ssh"
    args = [server, remoteCommand]
    remoteCommand = [text|
        sudo nix-env --profile $profile --set $path
        sudo $profile/bin/switch-to-configuration switch
      |]
    profile = "/nix/var/nix/profiles/system"

copySshKeysToVagrant :: Shell ()
copySshKeysToVagrant = do
  procs command args empty
  where
    command = "scp"
    args = ["-i", vagrantIdentityFile, localKeyPath, remotePath]
    localKeyPath = Text.strip [text|/Users/lucian/.ssh/$nixosIdentityFile|]
    remotePath = Text.strip [text|$vagrantUser@$vagrantHost:/home/$vagrantUser/.ssh/|]

