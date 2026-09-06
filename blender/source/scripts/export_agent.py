import bpy
import os


# ---------------------------------------------------------
# Determine project root
# ---------------------------------------------------------

project_root = os.path.abspath(
    os.path.join(os.path.dirname(__file__), "..", "..", "..")
)

input_file = os.path.join(
    project_root,
    "blender",
    "source",
    "agent_visual.blend"
)

output_file = os.path.join(
    project_root,
    "blender",
    "exports",
    "agent_visual.glb"
)


# ---------------------------------------------------------
# Open source Blender file
# ---------------------------------------------------------

bpy.ops.wm.open_mainfile(filepath=input_file)


# ---------------------------------------------------------
# Export GLB
# ---------------------------------------------------------

bpy.ops.export_scene.gltf(
    filepath=output_file,
    export_format="GLB",
    use_selection=False,
)


print("==========================================")
print("AI AGENT GLB EXPORT SUCCESSFUL")
print(f"Output: {output_file}")
print("==========================================")