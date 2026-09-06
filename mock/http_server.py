from http.server import BaseHTTPRequestHandler, HTTPServer
from datetime import datetime, timezone
import json


HOST = "127.0.0.1"
PORT = 8000


AGENTS = [
    {
        "agent_id": "research_01",
        "role": "Research Agent",
        "actions": [
            ("working", 0.25, "Searching for information"),
            ("working", 0.50, "Analyzing sources"),
            ("working", 0.75, "Comparing evidence"),
            ("completed", 1.00, "Research completed"),
        ],
    },
    {
        "agent_id": "engineer_01",
        "role": "Software Engineer",
        "actions": [
            ("working", 0.20, "Designing solution"),
            ("working", 0.45, "Writing implementation"),
            ("working", 0.70, "Testing implementation"),
            ("completed", 1.00, "Implementation completed"),
        ],
    },
    {
        "agent_id": "teacher_01",
        "role": "Teacher",
        "actions": [
            ("teaching", 0.20, "Preparing lesson"),
            ("teaching", 0.50, "Explaining concept"),
            ("teaching", 0.80, "Checking understanding"),
            ("completed", 1.00, "Lesson completed"),
        ],
    },
    {
        "agent_id": "analyst_01",
        "role": "Data Analyst",
        "actions": [
            ("working", 0.25, "Collecting data"),
            ("working", 0.50, "Analyzing data"),
            ("waiting", 0.75, "Waiting for additional evidence"),
            ("completed", 1.00, "Analysis completed"),
        ],
    },
    {
        "agent_id": "manager_01",
        "role": "Coordinator",
        "actions": [
            ("working", 0.25, "Planning tasks"),
            ("working", 0.50, "Coordinating agents"),
            ("working", 0.75, "Reviewing results"),
            ("completed", 1.00, "Coordination completed"),
        ],
    },
]


event_counter = 0


class EventHandler(BaseHTTPRequestHandler):

    def do_GET(self):
        global event_counter

        if self.path != "/events.json":
            self.send_response(404)
            self.end_headers()
            return

        agent_index = event_counter % len(AGENTS)
        progress_index = (event_counter // len(AGENTS)) % 4

        agent = AGENTS[agent_index]
        state, progress, action = agent["actions"][progress_index]

        event = {
            "event": "agent.status",
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "agent_id": agent["agent_id"],
            "role": agent["role"],
            "state": state,
            "progress": progress,
            "task_id": f"task_{agent['agent_id']}",
            "current_action": action,
            "message": f"{agent['role']} updated through HTTP",
            "importance": "normal",
        }

        body = json.dumps(event).encode("utf-8")

        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()

        self.wfile.write(body)

        print(
            f"Sent: {agent['agent_id']} -> "
            f"{state} ({int(progress * 100)}%)"
        )

        event_counter += 1

    def log_message(self, format, *args):
        pass


server = HTTPServer((HOST, PORT), EventHandler)

print(
    f"HTTP event server running at "
    f"http://{HOST}:{PORT}/events.json"
)
print("Events change every HTTP request.")
print("Press Ctrl+C to stop.")

try:
    server.serve_forever()
except KeyboardInterrupt:
    print("\nServer stopped.")
    server.server_close()