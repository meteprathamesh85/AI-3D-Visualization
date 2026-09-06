# Event Protocol

Project 1 consumes state/events. It does not own authoritative AI state.

## Agent status

```json
{
  "event": "agent.status",
  "timestamp": "2026-09-05T20:00:00",
  "agent_id": "research_01",
  "role": "Research Agent",
  "state": "working",
  "task_id": "task_102",
  "progress": 0.45,
  "message": "Collecting sources",
  "importance": "normal"
}
```

Supported event families include:

- `agent.created`
- `agent.activated`
- `agent.status`
- `agent.completed`
- `agent.sleeping`
- `task.created`
- `task.progress`
- `task.completed`
- `memory.saved`
- `lesson.candidate`
- `lesson.verified`
- `system.warning`
- `system.error`

The client safely ignores unknown event types.
Malformed JSON or invalid required fields are rejected without crashing.
