# Project Status

## Recent Fixes & Feature Implementation
- **Floor-Standing Model Replacement:** Replaced 5 wall/ceiling-mounted items (mirrors, chandeliers, ceiling lights) with freestanding/floor-standing furniture models (`Bathroom_Toilet2`, `Bathroom_Towel`, `Light_Floor2`, `Light_Floor3`, `Light_Stand2`) ideal for floor-detection AR.
- **Unused SavedDesign Codebase Cleanup:** Completely removed unused `SavedDesign` model, `DesignProvider`, `SavedDesignScreen`, and `/saved` route for a clean, lean codebase.
- **Profile Screen Role Selection Cleanup:** Removed quick role switch from `ProfileScreen`. Role selection is now managed exclusively via `/login`.
- **3D Model Automatic 1:1 Rescaling (55% Scale Correction):** Applied a 55% scale factor to all GLB models matching real-world 1:1 AR proportions.
- **50 Curated Showcase Furniture Set:** Linked with captured PNG images in `assets/images/furniture/`.

## Verification
- Executed `flutter analyze`.
- Clean compilation with 0 errors and 0 warnings in app code.

## GitHub Packaging
- Configured Git to exclude furniture `.glb` models and product preview images; `.gitkeep` files preserve the required asset directories.
- Excluded generated Android build output from GitHub.
- Added README setup instructions to restore these files from Google Drive before running the complete app.
- Added the Google Drive download link for the model and image assets to the README.
- No asset files were deleted or moved. This workspace does not currently contain Git repository metadata, so Git tracking state and ignore rules could not be verified with Git commands.
- Current `flutter analyze` reported 61 info-level lint notices and no errors; it exited with code 1 because of those notices.
