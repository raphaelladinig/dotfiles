ObjC.import("AppKit");

// System Events' `picture of every desktop` routes through the legacy desktop
// picture shim, which stalls and only ever reaches one display. NSWorkspace
// still exposes a per-screen setter, so drive every attached screen directly.
function run(argv) {
  const wallpaper = argv[0];

  if (!wallpaper) {
    throw new Error("usage: apply-wallpaper.js <wallpaper>");
  }

  const workspace = $.NSWorkspace.sharedWorkspace;
  const desired = $.NSURL.fileURLWithPath(wallpaper);
  const screens = $.NSScreen.screens;
  const files = $.NSFileManager.defaultManager;

  for (let index = 0; index < screens.count; index++) {
    const screen = screens.objectAtIndex(index);
    const current = workspace.desktopImageURLForScreen(screen);

    if (
      !current.isNil() &&
      (ObjC.unwrap(current.path) === wallpaper ||
        files.contentsEqualAtPathAndPath(current.path, desired.path))
    ) {
      continue;
    }

    if (!workspace.setDesktopImageURLForScreenOptionsError(desired, screen, $(), null)) {
      throw new Error("Failed to set wallpaper on screen " + index);
    }
  }
}
