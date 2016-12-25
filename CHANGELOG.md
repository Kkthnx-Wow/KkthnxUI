# KkthnxUI Change Log

What makes unicorns cry?

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]
### Added
- Brought back the auto hide feature for garrison icon and calendar. (Can be improved)
- Cached some more globals
- locals for the new time datatext
- Maybe fixed a rare questframe issue. ??
- New animations file to handle fade in and out and flashing.
- PVP dialog timer implemented.

### Fixed
- Border for auras properly have a backdrop
- Bug report fixes for cast bar and pixel perfect script.
- Silly me. I had to calendar code backwards :D

### Removed
- General UI files/code cleanup.
- Script to fix quest frames from sticking removed until I can properly fix it.
- Some event checks were not needed.

### Changed
- Boss names are now white on boss frames.
- Code cleanup in fixes file.
- Globals slowly being coverted a different way so table.insert will be cached like table_insert = table.insert.
- Media changes for certain languages. (Keep an eye on this).
- Recoded/improved the flyout buttons code.
- Time datatext is redone.