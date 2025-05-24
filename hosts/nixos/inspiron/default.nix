{
  config,
  pkgs,
  ...
}: let
  secretsPath = config.hostSpec.secretsPath;
in {
  imports = [
    ../../common/templates/hosts/nixos/main
    ./disk-config.nix
    ../../common/power-management.nix
    ../../common/bluetooth.nix
  ];

  hostSpec = {
    hostName = "inspiron";
    useOSProber = true;
  };

  userSpec.raphael = {
    school = true;
  };

  services.logind.extraConfig = ''
    HandlePowerKey=ignore
  '';

  age.secrets = {
    Cristallo = {
      file = "${secretsPath}/Cristallo.nmconnection.age";
      path = "/etc/NetworkManager/system-connections/Cristallo.nmconnection";
    };
    CristalloOsttirol = {
      file = "${secretsPath}/CristalloOsttirol.nmconnection.age";
      path = "/etc/NetworkManager/system-connections/CristalloOsttirol.nmconnection";
    };
    HTLinn = {
      file = "${secretsPath}/HTLinn.nmconnection.age";
      path = "/etc/NetworkManager/system-connections/HTLinn.nmconnection";
    };
  };

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "usbhid"
  ];
  boot.initrd.kernelModules = ["dm-snapshot"];
  boot.kernelModules = ["kvm-amd"];

  hardware.cpu.amd.updateMicrocode = config.hardware.enableRedistributableFirmware;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  hardware.amdgpu.opencl.enable = true;

  systemd.services.fix-touchpad = {
    path = [pkgs.kmod];
    serviceConfig.ExecStart = ''${pkgs.systemd}/bin/systemd-inhibit --what=sleep --why="fixing touchpad must finish before sleep" --mode=delay  ${./fix_touchpad.sh}'';
    serviceConfig.Type = "oneshot";
    description = "reload touchpad driver";
    wantedBy = [
      "graphical.target"
      "post-resume.target"
    ];
    after = ["post-resume.target"];
  };
}
