# Desktop Update Notice 1-Pager

## Background

HOP desktop currently checks for Tauri updater releases from GitHub `latest.json` and applies them during startup. This is technically functional, but it can restart the app without explicit user consent.

## Problem

Automatic install and restart is too aggressive for a document editor. Users can be surprised by a sudden restart, may still be reviewing a document, and may not want to update immediately even if no document is currently dirty.

## Goal

Change the updater flow to a user-approved in-app notice that appears in the lower-left corner, lets the user start the update explicitly, never auto-restarts, and asks for a second explicit action before restart.

## Non-goals

Do not add a modal dialog, OS notification integration, background scheduled update retries, or persistent “skip this version” behavior across launches.

## Constraints

The implementation must be safe to ship as the next release because existing installs may update into it immediately. Update state must survive startup event timing races between Rust and the frontend. Dirty documents must block update actions that can disrupt editing.

## Implementation outline

Store updater notice state in Rust, emit state changes to all windows, and expose commands to fetch the current state, start installation, and restart after install. Replace auto-install/startup restart with a background availability check only. In the studio host, hydrate updater state during startup, listen for updater state events, and render a small non-modal lower-left notice with action buttons and progress.

## Verification plan

Verify no auto-restart occurs on startup, update availability notice appears after hydrate and after runtime events, dismiss hides it only for the current session, dirty documents block update and restart actions, offline startup stays quiet, and install success transitions to a restart-ready notice. Run focused Rust, desktop, and studio tests plus release-safe build checks.

## Rollback or recovery notes

If the new notice flow fails in release testing, revert only the updater UX change before the next release. Do not reintroduce auto-restart behavior as a fallback because it recreates the original data-loss risk.
