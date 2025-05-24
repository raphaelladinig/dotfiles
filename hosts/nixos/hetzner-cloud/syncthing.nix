{config, ...}: let
  secretsPath = config.hostSpec.secretsPath;
  hostName = config.hostSpec.hostName;
in {
  age.secrets = {
    "${hostName}_syncthing-cert".file = "${secretsPath}/${hostName}_syncthing-cert.age";
    "${hostName}_syncthing-key".file = "${secretsPath}/${hostName}_syncthing-key.age";
  };

  services.syncthing = {
    enable = true;
    cert = "${config.age.secrets."${hostName}_syncthing-cert".path}";
    key = "${config.age.secrets."${hostName}_syncthing-key".path}";
    settings = {
      options = {
        urAccepted = -1;
      };
      devices = {
        "inspiron" = {
          id = "ZK6XBCB-PDML64D-OKWV3QD-EC2LC2W-TGRMLK4-PNVW2A4-BQPPTNO-UXJACQQ";
          autoAcceptFolders = true;
        };
        "hetzner-cloud" = {
          id = "PIDQDU6-R5DNKS2-GKCKY2N-MEFX4C6-LNSQ6R2-SKJ4M44-WI55H4U-BCZBUAN";
          autoAcceptFolders = true;
        };
      };
      folders = {
        "Notes" = {
          path = "/var/lib/syncthing/Notes";
          versioning = {
            type = "simple";
            params = {
              keep = "7";
              cleanoutDays = "7";
            };
          };
          devices = ["inspiron" "hetzner-cloud"];
        };
        "Dev" = {
          path = "/var/lib/syncthing/Dev";
          versioning = {
            type = "simple";
            params = {
              keep = "7";
              cleanoutDays = "7";
            };
          };
          devices = ["inspiron" "hetzner-cloud"];
        };
        "Sync" = {
          path = "/var/lib/syncthing/Sync";
          versioning = {
            type = "simple";
            params = {
              keep = "7";
              cleanoutDays = "7";
            };
          };
          devices = ["inspiron" "hetzner-cloud"];
        };
      };
    };
  };

  systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";
}
