{
  imports = [
    ../../ssh
  ];

  users.users.root = {
    hashedPassword = ""; # deactivate password
    openssh.authorizedKeys.keyFiles = [
      ../../ssh/ssh_raphael.pub
    ];
  };
}
