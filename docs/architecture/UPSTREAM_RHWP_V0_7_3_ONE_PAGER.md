# rhwp v0.7.3 Upstream Update 1-Pager

## Background

HOP는 `third_party/rhwp` submodule과 published `@rhwp/core` 패키지를 함께 사용한다. 현재 pinned submodule commit은 `70d9e2d704d88da2e81baa8b09e21523593efa18`로 `v0.7.2-13` 지점이고, studio host는 `@rhwp/core` `0.7.2`를 사용한다. upstream 최신 stable release는 `v0.7.3`이다.

## Problem

현재 HOP는 upstream release tag와 npm package version이 정확히 맞지 않는 중간 스냅샷에 서 있다. Rust vendor source, published WASM package, HOP-owned desktop adapters 사이의 기준점이 어긋나 있어 저장, HWPX, 파일 열기, bootstrap 경계에서 호환성 리스크가 커진다.

## Goal

`third_party/rhwp`를 `v0.7.3`로 올리고 `@rhwp/core`를 `0.7.3`으로 정렬한다. HOP가 소유하는 desktop/file/save/print/window integration을 유지한 채 studio build, desktop tests, clippy, debug bundle build를 통과시킨다.

## Non-goals

* `origin/main` 최신 커밋까지 추적하지 않는다.
* `third_party/rhwp` 아래에 HOP 제품 로직을 추가하지 않는다.
* HWPX 저장 정책을 이번 업데이트에서 새로 설계하지 않는다.

## Constraints

* `third_party/rhwp`는 read-only vendor source로 유지한다.
* macOS, Windows, Linux 경계를 깨지 않아야 한다.
* HOP의 file I/O와 window lifecycle은 app-owned layers에서 유지한다.
* `scripts/update-upstream.sh`는 현재 branch-based update만 지원하므로 tag pinning이 가능하도록 보완해야 한다.

## Implementation Outline

1. `scripts/update-upstream.sh`에 tag or ref pinning을 지원해 branch update와 release pinning 둘 다 처리한다.
2. `third_party/rhwp`를 `v0.7.3` tag로 이동한다.
3. `apps/studio-host/package.json`과 `pnpm-lock.yaml`의 `@rhwp/core`를 `0.7.3`으로 정렬한다.
4. upstream `rhwp-studio` 변경 중 HOP가 shadowing하는 표면을 다시 맞춘다.
5. HOP desktop adapters에서 upstream `sourceFormat`/HWPX save 정책과 충돌하지 않도록 정리한다.
6. pinned baseline 문서와 관련 테스트를 갱신한다.

## Verification Plan

* `pnpm run test:upstream`
* `pnpm run build:studio`
* `pnpm run test:studio`
* `pnpm run test:desktop`
* `pnpm run clippy:desktop`
* `pnpm --filter hop-desktop tauri build --debug --bundles app`

## Rollback / Recovery

검증 실패 시 submodule pointer를 `70d9e2d704d88da2e81baa8b09e21523593efa18`로 되돌리고 `@rhwp/core`를 `0.7.2`로 복구한다. HOP adapter 쪽 호환 수정은 separate commit or hunk 단위로 남겨 문제 지점을 분리한다.
