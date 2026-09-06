{ ... }:
{
  den.aspects.ai.skills.homeManager =
    {
      config,
      lib,
      repoRoot,
      ...
    }:
    let
      skills = lib.filterAttrs (
        name: type: type == "directory" && builtins.pathExists (./. + "/${name}/SKILL.md")
      ) (builtins.readDir ./.);
      skillDirectories = [
        ".claude/skills"
        ".codex/skills"
      ];
    in
    {
      home.file = builtins.listToAttrs (
        builtins.concatLists (
          map (
            directory:
            lib.mapAttrsToList (name: _: {
              name = "${directory}/${name}";
              value.source = config.lib.file.mkOutOfStoreSymlink "${repoRoot}/modules/ai/skills/${name}";
            }) skills
          ) skillDirectories
        )
      );
    };
}
