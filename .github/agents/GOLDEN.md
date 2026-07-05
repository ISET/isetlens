# ISETLens Golden Value Testing Plan

This document outlines the numerical checking strategy ("golden values") to protect key computations and structures in the `isetlens` repository against regressions.

## 1. Core Routine Targets (Local / Fast)

Before testing rendering outputs, we will introduce numerical golden checks on the structural, geometric, and optical parameters computed by core lens utilities.

### Lens File Parsing and Round Trips
*   **Target**: PBRT/JSON lens-file parsing and writing through `lensC.fileRead`, `lensC.fileWrite`, and `lensMatrix`.
*   **Golden Values**: Expected radii, thicknesses, apertures, refractive indices, focal lengths, and surface counts for representative lenses.
*   **Verification**: Check that round-tripped lens files preserve optical parameters within explicit tolerances and do not reorder or drop surfaces.

### Ray Tracing and Film Intersections
*   **Target**: Ray generation, refraction through spherical surfaces, aperture clipping, and recording on `filmC`.
*   **Golden Values**: Expected ray origins, directions, survival counts, endpoint coordinates, and film hit locations for simple single- and multi-element lenses.
*   **Verification**: Verify `rayC`, `lensC.rtSourceToEntrance`, `lensC.rtThroughLens`, and `rayC.recordOnFilm` outputs against stable analytical or precomputed references.

### Focus, Black-Box, and Paraxial Optics
*   **Target**: Focus-distance estimates, black-box-model/cardinal-point computations, and paraxial optical-system matrices.
*   **Golden Values**: Expected focal lengths, principal planes, pupil positions, effective numerical aperture, and object-to-film distances for canonical lens files.
*   **Verification**: Verify `lensFocus`, `lensC.bbmCreate`, `lensC.bbmGetValue`, and `paraxial/` routines with explicit named tolerances.

---

## 2. Remote Rendering Targets (Stanford VPN / Docker-dependent)

Once connected to the Stanford VPN and any required remote rendering services, we will introduce golden value checks for ISETLens examples that render through PBRT.

### Rendered Lens Output
*   **Target**: Optical image, PSF, depth, and focus outputs from examples that combine ISETLens lens files with PBRT rendering.
*   **Golden Values**: Stable image statistics, focus distances, PSF summaries, and lens-to-film distances for representative scenes and lenses.
*   **Verification**:
    ```matlab
    testCase.verifyEqual(lensFilmDistance, expectedLensFilmDistance, 'RelTol', 0.01);
    ```

### PSF and Diffraction Summaries
*   **Target**: PSF estimates, diffraction-limited comparisons, and spectral line-spread summaries.
*   **Golden Values**: Expected PSF dimensions, peak locations, normalization checks, and line-spread widths for selected wavelengths and apertures.
*   **Verification**: Confirm values are within documented tolerances of established baseline measurements.

---

## 3. Implementation Strategy in Unit Tests

*   **Tolerances**: All tests will utilize MATLAB's `verifyEqual` or `verifyLessThan` with explicit absolute (`AbsTol`) or relative (`RelTol`) tolerance arguments to avoid test failures caused by machine-specific float variations.
*   **Storage**: Golden values will be stored directly inside the relevant `test_*.m` code structures (for lightweight arrays/scalars) or inside structured MAT-files within the package `_tests_` directories.
