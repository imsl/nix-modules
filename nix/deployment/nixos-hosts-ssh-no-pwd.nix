{ paths, config, pkgs, lib, ... }:

with lib;
with pkgs;
with builtins;

let

  sshOptions = [
    "LogLevel=ERROR"
    "PreferredAuthentications=password"
    "StrictHostKeyChecking=no"
    "UserKnownHostsFile=/dev/null"
  ];

in {

  imports = [
    ../nixos-hosts.nix
  ];

  options = {
    nixosHosts.hosts = mkOption {
      type = with types; attrsOf (submodule ({name, ...}: {
        config = {
          ssh.extraArgs = map (o: "-o ${o}") sshOptions;
        };
      }));
    };
  };

  config = {
    nixosHosts.commonNixosImports = singleton ({config,...}: {
      users.users.root.password = mkForce "";
      programs.ssh.extraConfig = concatStringsSep "\n" sshOptions;
      services.openssh = {
        enable = true;
        permitRootLogin = mkForce "yes";
        passwordAuthentication = mkForce true;
        extraConfig = ''
          PermitEmptyPasswords yes
          AuthenticationMethods none
        '';
      };
    });
  };
}
