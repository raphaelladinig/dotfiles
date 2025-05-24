{
  hostSpec,
  config,
  ...
}: let
  secretsPath = hostSpec.secretsPath;
  hostName = hostSpec.hostName;
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
          path = "/home/raphael/Notes";
          devices = ["inspiron" "hetzner-cloud"];
        };
        "Dev" = {
          path = "/home/raphael/Dev";
          devices = ["inspiron" "hetzner-cloud"];
        };
        "Sync" = {
          path = "/home/raphael/Sync";
          devices = ["inspiron" "hetzner-cloud"];
        };
      };
    };
  };
}
