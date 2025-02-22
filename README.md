# AR WorldEnvironment Background Transparency issue
![image](https://github.com/user-attachments/assets/eb20f4d6-d0d5-476a-b53f-b87a237d1939)


![image](https://github.com/user-attachments/assets/d0e55026-26d9-4caa-a2ef-08cd816ba56d)

## Overview

This demo project highlights an issue where the WorldEnvironment background appears transparent when using OpenXR in Godot, despite background transparency being disabled.

## Expected Behavior

The WorldEnvironment should render as an opaque background with a sky shader or solid color, visible through the window cutout created using PassthroughGeometry.

## Observed Behavior

The WorldEnvironment background appears transparent or extremely faint when viewed through the window. The sky is present but difficult to see, suggesting a rendering issue with the background.

## Steps to Reproduce

1. Open the project in Godot 4.4 Beta 4 (or later if applicable).

2. Ensure the Godot OpenXR Vendor Plugin is installed and enabled.

3. Run the project on a Meta Quest 3 using OpenXR with passthrough enabled.

4. Observe the view through the real-world window:

    - PassthroughGeometry allows visibility of the real-world room, including walls.

    - The window frame is cut out from the mesh used in PassthroughGeometry, allowing a clear view into the virtual world.

    - The virtual environment outside the window is visible.

    - However, the background (WorldEnvironment) is transparent or extremely faint instead of rendering as expected.

## Troubleshooting Attempts

- Setting the WorldEnvironment background to a solid color with no transparency still results in a transparent or barely visible background.

- Adjusting the sky shader brightness and environment settings has no effect—unless set to pure white with extremely high energy levels, which results in an unnaturally bright, blinding background.

- Passthrough works correctly, and virtual objects render as expected.

- The issue persists across different rendering settings in Godot OpenXR.

- A bunch of other stuff that I forgot.

## Possible Causes

- WorldEnvironment settings may not be applied correctly when OpenXR passthrough is active.

- The Godot OpenXR plugin may be handling background rendering incorrectly.

## Next Steps

- Report this issue to the Godot OpenXR Vendor Plugin maintainers, including this demo project for replication and further investigation.
