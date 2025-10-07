{
  config,
  pkgs,
  ...
}: let
  secretsPath = config.hostSpec.secretsPath;
in {
  imports = [
    ../common/templates/hosts/simple
    ./disk-config.nix
    ../common/power-management.nix
    ../common/bluetooth.nix
  ];

  hostSpec = {
    hostName = "inspiron";
    useOSProber = true;
  };

  "userSpec-raphael" = {
    school = true;
  };

  sops.secrets = {
    Cristallo = {
      sopsFile = "${secretsPath}/Cristallo.nmconnection";
      path = "/etc/NetworkManager/system-connections/Cristallo.nmconnection";
    };
    CristalloOsttirol = {
      sopsFile = "${secretsPath}/CristalloOsttirol.nmconnection";
      path = "/etc/NetworkManager/system-connections/CristalloOsttirol.nmconnection";
    };
    HTLinn = {
      sopsFile = "${secretsPath}/HTLinn.nmconnection";
      path = "/etc/NetworkManager/system-connections/HTLinn.nmconnection";
    };
    pixel = {
      sopsFile = "${secretsPath}/pixel.nmconnection";
      path = "/etc/NetworkManager/system-connections/pixel.nmconnection";
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
