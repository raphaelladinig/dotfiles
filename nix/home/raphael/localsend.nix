{hostSpec, ...}: let
  secretsPath = hostSpec.secretsPath;
in {
  sops.secrets.localsend = {
    sopsFile = "${secretsPath}/localsend";
    path = ".local/share/org.localsend.localsend_app/shared_preferences.json";
  };
}
