import bpy
import math


# ---------------------------------------------------------
# Clean scene
# ---------------------------------------------------------

bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)


# ---------------------------------------------------------
# Materials
# ---------------------------------------------------------

def create_material(name, color, metallic=0.0, roughness=0.5):
    material = bpy.data.materials.new(name)
    material.diffuse_color = (*color, 1.0)
    material.metallic = metallic
    material.roughness = roughness
    return material


body_material = create_material(
    "AgentBody",
    (0.08, 0.45, 0.85),
    metallic=0.2,
    roughness=0.65,
)

head_material = create_material(
    "AgentHead",
    (0.75, 0.82, 0.92),
    metallic=0.05,
    roughness=0.6,
)

ring_material = create_material(
    "AgentRing",
    (0.05, 0.75, 1.0),
    metallic=0.3,
    roughness=0.35,
)


# ---------------------------------------------------------
# Body
# ---------------------------------------------------------

bpy.ops.mesh.primitive_uv_sphere_add(
    segments=32,
    ring_count=16,
    location=(0, 0, 0.85),
)

body = bpy.context.object
body.name = "AgentBody"

body.scale = (0.55, 0.42, 0.85)
bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)

body.data.materials.append(body_material)


# ---------------------------------------------------------
# Head
# ---------------------------------------------------------

bpy.ops.mesh.primitive_uv_sphere_add(
    segments=32,
    ring_count=16,
    location=(0, 0, 1.75),
)

head = bpy.context.object
head.name = "AgentHead"

head.scale = (0.38, 0.38, 0.38)
bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)

head.data.materials.append(head_material)


# ---------------------------------------------------------
# Status ring
# ---------------------------------------------------------

bpy.ops.mesh.primitive_torus_add(
    major_radius=0.62,
    minor_radius=0.055,
    major_segments=48,
    minor_segments=12,
    location=(0, 0, 0.08),
)

ring = bpy.context.object
ring.name = "AgentStatusRing"

ring.data.materials.append(ring_material)


# ---------------------------------------------------------
# Small chest panel
# ---------------------------------------------------------

panel_material = create_material(
    "AgentPanel",
    (0.03, 0.08, 0.15),
    metallic=0.4,
    roughness=0.35,
)

bpy.ops.mesh.primitive_cube_add(
    location=(0, -0.43, 0.95),
)

panel = bpy.context.object
panel.name = "AgentChestPanel"

panel.scale = (0.25, 0.035, 0.18)
bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)

panel.data.materials.append(panel_material)


# ---------------------------------------------------------
# Smooth shading
# ---------------------------------------------------------

for obj in bpy.context.scene.objects:
    if obj.type == "MESH":
        for polygon in obj.data.polygons:
            polygon.use_smooth = True


# ---------------------------------------------------------
# Collection
# ---------------------------------------------------------

collection = bpy.data.collections.new("AI_AGENT")
bpy.context.scene.collection.children.link(collection)

for obj in list(bpy.context.scene.objects):
    if obj.name in [
        "AgentBody",
        "AgentHead",
        "AgentStatusRing",
        "AgentChestPanel",
    ]:
        for collection_old in list(obj.users_collection):
            collection_old.objects.unlink(obj)

        collection.objects.link(obj)


# ---------------------------------------------------------
# Save Blender source
# ---------------------------------------------------------

import os

project_root = os.path.abspath(
    os.path.join(os.path.dirname(__file__), "..", "..", "..")
)

blend_output = os.path.join(
    project_root,
    "blender",
    "source",
    "agent_visual.blend"
)

bpy.ops.wm.save_as_mainfile(
    filepath=blend_output
)

print("AI AGENT BLENDER MODEL CREATED SUCCESSFULLY")