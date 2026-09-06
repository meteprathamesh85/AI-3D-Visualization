class_name MockEventGenerator
extends Node

signal event_generated(event: Dictionary)

var running := true
var elapsed := 0.0
var step_index := 0
var interval := 2.8

var agents := [
	{"agent_id":"research_01","role":"Research Agent","state":"idle","task_id":"task_102","progress":0.0,"current_action":"Ready","message":"Waiting for work","importance":"normal"},
	{"agent_id":"engineer_01","role":"Software Engineer","state":"sleeping","task_id":"task_103","progress":0.0,"current_action":"Offline","message":"Resting","importance":"low"},
	{"agent_id":"teacher_01","role":"Teacher","state":"idle","task_id":"task_104","progress":0.0,"current_action":"Preparing","message":"Ready to teach","importance":"normal"},
	{"agent_id":"analyst_01","role":"Data Analyst","state":"waiting","task_id":"task_105","progress":0.25,"current_action":"Reviewing","message":"Waiting for evidence","importance":"normal"},
	{"agent_id":"manager_01","role":"Coordinator","state":"working","task_id":"task_106","progress":0.55,"current_action":"Coordinating","message":"Tracking project tasks","importance":"high"}
]

var sequences := {
	"research_01": ["idle","working","waiting","completed","sleeping"],
	"engineer_01": ["sleeping","working","testing","completed","sleeping"],
	"teacher_01": ["idle","teaching","teaching","waiting","idle"],
	"analyst_01": ["waiting","working","testing","completed","waiting"],
	"manager_01": ["working","working","waiting","completed","working"]
}

func _ready() -> void:
	for agent in agents:
		_emit_agent(agent, false)

func _process(delta: float) -> void:
	if not running:
		return
	elapsed += delta
	if elapsed >= interval:
		elapsed = 0.0
		_advance_one()

func set_running(value: bool) -> void:
	running = value

func _advance_one() -> void:
	var agent: Dictionary = agents[step_index % agents.size()]
	var id := str(agent.agent_id)
	var seq: Array = sequences[id]
	var state_index: int = floori(float(step_index) / float(agents.size())) % seq.size()
	var new_state := str(seq[state_index])
	agent.state = new_state
	agent.progress = _progress_for(new_state, state_index, seq.size())
	agent.current_action = _action_for(new_state)
	agent.message = _message_for(new_state)
	agent.timestamp = Time.get_datetime_string_from_system(true)
	_emit_agent(agent, true)
	if new_state == "completed":
		event_generated.emit({
			"event":"task.completed",
			"timestamp":agent.timestamp,
			"agent_id":id,
			"task_id":agent.task_id,
			"progress":1.0,
			"message":"Task completed successfully"
		})
	step_index += 1

func _emit_agent(agent: Dictionary, include_timestamp: bool) -> void:
	var event := {
		"event":"agent.status",
		"timestamp":agent.get("timestamp", Time.get_datetime_string_from_system(true)),
		"agent_id":agent.agent_id,
		"role":agent.role,
		"state":agent.state,
		"task_id":agent.task_id,
		"progress":agent.progress,
		"current_action":agent.current_action,
		"message":agent.message,
		"importance":agent.importance
	}
	if include_timestamp:
		event.timestamp = Time.get_datetime_string_from_system(true)
	event_generated.emit(event)

func _progress_for(state: String, index: int, total: int) -> float:
	if state == "completed":
		return 1.0
	if state == "sleeping" or state == "idle":
		return 0.0
	return clamp((float(index) + 1.0) / float(max(total, 2)), 0.0, 0.95)

func _action_for(state: String) -> String:
	match state:
		"working": return "Collecting sources"
		"waiting": return "Waiting for evidence"
		"testing": return "Running validation tests"
		"teaching": return "Explaining and assessing"
		"completed": return "Delivering result"
		"sleeping": return "Offline / resting"
		_: return "Standing by"

func _message_for(state: String) -> String:
	match state:
		"working": return "Active task in progress"
		"waiting": return "Blocked on the next input"
		"testing": return "Checking results"
		"teaching": return "Learning session active"
		"completed": return "Task finished"
		"sleeping": return "No active work"
		_: return "Available"
