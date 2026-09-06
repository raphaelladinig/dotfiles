{ ... }:
{
  den.aspects.ai.agents-md.homeManager =
    { config, repoRoot, ... }:
    let
      instructions = config.lib.file.mkOutOfStoreSymlink "${repoRoot}/modules/ai/agents-md/AGENTS.md";
    in
    {
      home.file = {
        ".codex/AGENTS.md".source = instructions;
        ".claude/CLAUDE.md".source = instructions;
      };
    };
}
