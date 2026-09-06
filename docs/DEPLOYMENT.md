# Deployment Guide — Free GitHub Deployment

This project is designed for two free deployment paths:

1. **Windows desktop:** GitHub Releases / ZIP distribution.
2. **Web:** GitHub Pages static hosting.

The supplied technical guide recommends GitHub Releases for desktop and GitHub Pages for the optional web build.

---

## Part A — Push the project to GitHub

### 1. Install Git

Install Git for Windows and verify:

```powershell
git --version
```

### 2. Create a GitHub repository

On GitHub, create a new repository, for example:

`project1-3d-ai-visualization`

For the easiest first deployment, make it **Public**.

Do not add another README if you already have this repository's README.

### 3. Open PowerShell in this project folder

```powershell
cd C:\AIProjects\project1-3d-ai-visualization
```

### 4. Initialize Git

```powershell
git init
git branch -M main
git add .
git commit -m "Initial Project 1 3D AI Visualization"
```

### 5. Connect the GitHub repository

Replace the placeholder with your own repository URL:

```powershell
git remote add origin https://github.com/YOUR_USERNAME/project1-3d-ai-visualization.git
git push -u origin main
```

---

# Part B — Run and test before deploying

Open:

`godot/project.godot`

in Godot 4.7.2.

Press **F6/F5**.

You should see:

- 3D grid
- five roles appearing
- state changes in Mock Mode
- task markers
- event timeline
- selected-agent panel

Click agents and watch their details change.

---

# Part C — Windows desktop release

## Method 1: Godot editor

1. Open the project in Godot.
2. Go to **Project → Export**.
3. Confirm the **Windows Desktop** preset exists.
4. Install/export templates if Godot asks.
5. Choose an output such as:

`builds/windows/AIVisualization.exe`

6. Export the project.
7. Test the `.exe` on your machine.

## Method 2: command line

From the repository root:

```powershell
godot --path godot --export-release "Windows Desktop" builds/windows/AIVisualization.exe
```

If `godot` is not recognized, use the full path to `Godot.exe`.

## Package it

Put the exported executable and its generated `.pck`/support files in:

```text
release/
```

Compress the release folder into:

`AIVisualization-Windows-x64.zip`

## Publish on GitHub Releases

1. Push your source code to GitHub.
2. Open the repository.
3. Create a new Release/tag, e.g. `v1.0.0`.
4. Attach `AIVisualization-Windows-x64.zip`.
5. Publish the release.

This gives you a free download page without running a server.

---

# Part D — Web deployment with GitHub Pages

GitHub Pages is a static host. It is suitable for this visualization when it runs in mock mode or calls a separately hosted/public backend.

## 1. Export Web

In Godot:

1. **Project → Export**
2. Select **Web**
3. Export to a folder named `docs`
4. Ensure the generated entry file is `docs/index.html`

Or use:

```powershell
godot --path godot --export-release "Web" docs/index.html
```

Your repository becomes:

```text
project1-3d-ai-visualization/
├── docs/
│   ├── index.html
│   ├── *.wasm
│   ├── *.pck
│   └── other generated web files
└── ...
```

Add an empty `docs/.nojekyll` file if needed to prevent Jekyll processing.

## 2. Commit the generated web build

```powershell
git add docs
git commit -m "Add web export"
git push
```

## 3. Enable GitHub Pages

In GitHub:

1. Open the repository.
2. Go to **Settings → Pages**.
3. Under the publishing/source section, choose **Deploy from a branch**.
4. Select `main`.
5. Select `/docs`.
6. Save.

GitHub will show the Pages URL after the deployment finishes.

## 4. If the page shows a blank screen

Check:

- Browser developer console.
- Correct generated `.wasm` and `.pck` files are present.
- The project was exported using the intended Godot version.
- You are opening the GitHub Pages URL, not a local file.
- Browser security/CORS rules are satisfied for any remote API.
- Do not put secret/private API keys in the web build.

---

# Part E — Connecting a future AI backend

Start with the built-in Mock Mode.

When Project 2 is ready, expose an HTTP endpoint returning either:

### One event

```json
{
  "event": "agent.status",
  "timestamp": "2026-09-05T20:00:00",
  "agent_id": "research_01",
  "role": "Research Agent",
  "state": "working",
  "task_id": "task_102",
  "progress": 0.45,
  "message": "Collecting sources"
}
```

### Or an array

```json
[
  {
    "event": "agent.status",
    "timestamp": "2026-09-05T20:00:00",
    "agent_id": "research_01",
    "role": "Research Agent",
    "state": "working",
    "progress": 0.45
  }
]
```

Then paste the endpoint into the HTTP source field and click **Connect HTTP Polling**.

For a web build, the endpoint must permit browser requests with appropriate CORS headers.

---

# Part F — Recommended development order

Follow this order rather than trying to connect everything at once:

1. Run the 3D scene.
2. Verify five mock roles.
3. Verify state transitions.
4. Verify task progress.
5. Verify event timeline.
6. Verify agent selection.
7. Run event parser tests.
8. Test malformed/unknown events.
9. Export Windows.
10. Test Windows build on a clean machine.
11. Export Web.
12. Deploy Web to GitHub Pages.
13. Only then connect an external backend.
14. Later, consider WebSocket for real-time events.

This matches the architecture in the supplied guide and keeps Project 1 independent from Project 2.
