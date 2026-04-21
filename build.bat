@echo off
set "PATH=%PATH%;C:\Users\sungh\.cargo\bin"
echo Using cargo from:
where cargo
echo Starting build...
call npx pnpm --filter hop-desktop tauri build
