{config, ...}: let
  secretsPath = config.hostSpec.secretsPath;
  hostName = config.hostSpec.hostName;
in {
  sops.secrets = {
    "${hostName}_syncthing-cert".sopsFile = "${secretsPath}/${hostName}_syncthing-cert";
    "${hostName}_syncthing-key".sopsFile = "${secretsPath}/${hostName}_syncthing-key";
  };

  services.syncthing = {
    enable = true;
    cert = "${config.sops.secrets."${hostName}_syncthing-cert".path}";
    key = "${config.sops.secrets."${hostName}_syncthing-key".path}";
    overrideDevices = true;
    overrideFolders = true;
    settings = {
      options = {
        urAccepted = -1;
      };
      devices = {
        "inspiron" = {
          id = "ZK6XBCB-PDML64D-OKWV3QD-EC2LC2W-TGRMLK4-PNVW2A4-BQPPTNO-UXJACQQ";
        };
        "pixel" = {
          id = "HBI2CGT-BWWHY3B-3BRAYDY-RI6YW5S-HYMPIS3-YBO6XWF-BWIP6YA-TZLTNQK";
        };
        "sync-nbg" = {
          id = "PIDQDU6-R5DNKS2-GKCKY2N-MEFX4C6-LNSQ6R2-SKJ4M44-WI55H4U-BCZBUAN";
        };
      };
      folders = {
        "Sync" = {
          id = "default";
          path = "/var/lib/syncthing/Sync";
          versioning = {
            type = "simple";
            params = {
              keep = "7";
              cleanoutDays = "7";
            };
          };
          devices = ["inspiron" "sync-nbg" "pixel"];
        };
        "Dev" = {
          id = "Dev";
          path = "/home/raphael/Dev";
          devices = ["inspiron" "sync-nbg"];
        };
      };
    };
  };
}
