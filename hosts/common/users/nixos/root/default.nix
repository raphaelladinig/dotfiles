{
  imports = [
    ../../../ssh
  ];

  users.users.root = {
    hashedPassword = ""; # deactivate password
    openssh.authorizedKeys.keyFiles = [
      ../../../ssh/id_raphael.pub
    ];
  };
}
