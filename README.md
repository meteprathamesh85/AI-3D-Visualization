# Project 1 — 3D AI Visualization

A lightweight, stylized Godot visualization client for displaying AI roles, tasks, events, progress, memory/learning events and status.

> This project follows the supplied **Project 1 — 3D AI Visualization** technical guide. The guide explicitly keeps the visualization independent from Project 2: it is a client, not the AI brain, authoritative memory, RAG system, or agent reasoning engine.

## What is included

- Stylized low-detail 3D grid scene.
- Five reusable AI role visuals generated at runtime.
- Agent states: idle, working, waiting, testing, teaching, completed, sleeping, error.
- Task markers with progress.
- Event timeline.
- Selected-agent details panel.
- Local mock event generator — works without any backend.
- JSON event validation.
- Optional HTTP polling transport.
- Safe handling for malformed/unknown events.
- Windows and Web export presets.
- Tests for the event parser.
- Git/GitHub-ready repository structure.
- Deployment documentation for GitHub Releases and GitHub Pages.

## Architecture

```text
PROJECT 1
   |
   +---- Visual State
   |
   +---- UI State
           |
       Godot Scene Tree
        /      |      \
    Agents   Tasks   Events
                    |
             Optional HTTP
                    |
             External AI Backend
```

Authoritative AI logic stays outside this project.

## Requirements

Target stack from the supplied guide:

- Godot 4.7.2 stable
- Blender 5.2 LTS (optional; this starter contains no external 3D assets)
- Git
- VS Code (optional)

No paid engine, asset subscription, database, or deployment service is required.

## Run locally

1. Install Godot 4.7.2 stable.
2. Open `godot/project.godot` in Godot.
3. Press **F6/F5** or click Run Project.
4. The application starts in **Mock Mode** automatically.

### Controls

- **Space** — pause/resume mock event generation.
- **P** — pause/resume UI/world updates.
- **Left click an agent** — inspect its state.
- Use the HTTP panel to point at a public JSON endpoint when you have a backend.

## Repository layout

```text
project1-3d-ai-visualization/
├── .gitignore
├── .gitattributes
├── LICENSE
├── README.md
├── docs/
│   ├── DEPLOYMENT.md
│   └── EVENT_PROTOCOL.md
├── godot/
│   ├── project.godot
│   ├── export_presets.cfg
│   ├── scenes/main.tscn
│   └── scripts/
│       ├── main.gd
│       ├── agents/agent_visual.gd
│       ├── tasks/task_visual.gd
│       ├── state/event_parser.gd
│       ├── mock/mock_event_generator.gd
│       └── networking/http_event_source.gd
├── blender/
│   ├── source/.gitkeep
│   └── exports/.gitkeep
├── mock/
│   └── sample_events.json
├── tests/
│   └── test_event_parser.gd
└── builds/
    └── README.md
```

## Why this starter is structured this way

The supplied guide says to build mock mode first, then JSON parsing, and only afterward networking. This repository follows that order. The visualization can therefore be demonstrated before Project 2 exists.

The guide also recommends simple geometry, few materials, limited event history, and testing at 1280×720 and 1920×1080. This implementation uses simple runtime-generated meshes, a small event history, and a 1280×720 default viewport.

## Deployment

See [`docs/DEPLOYMENT.md`](docs/DEPLOYMENT.md).

### Desktop

Export a Windows build and publish the ZIP through GitHub Releases. This is the simplest free distribution route and requires no server.

### Web

Export the Godot Web build into a `docs/` folder (or another Pages publishing folder), commit it to GitHub, and enable GitHub Pages. The web build is static; it cannot run your private AI backend.

For a public web client calling an external backend, the backend must allow browser requests (CORS), and **private API keys must never be placed in the web build**.

## Command-line export

After installing Godot and configuring the export templates:

```bash
godot --path godot --export-release "Windows Desktop" builds/AIVisualization.exe
```

For a web export:

```bash
godot --path godot --export-release "Web" web/index.html
```

The exact command can vary slightly with the executable name/path on Windows.

## Test

From a terminal:

```bash
godot --headless --path godot --script res://../tests/test_event_parser.gd
```

If the command-line Godot executable is not on PATH, run the equivalent command using the full path to `Godot.exe`.

## Important boundary

This project is intentionally **not**:

- the Personal AI brain
- authoritative memory storage
- RAG
- agent reasoning
- a realistic city simulation
- a hundreds-of-NPC simulation

It is a visualization client that can later observe an external AI system.
