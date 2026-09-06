extends SceneTree

const EventParserScene := preload("res://scripts/state/event_parser.gd")

func _init() -> void:
    var valid := EventParserScene.validate_event({
        "event":"agent.status",
        "timestamp":"2026-09-05T20:00:00",
        "agent_id":"research_01",
        "progress":0.45
    })
    assert(valid.valid)

    var invalid := EventParserScene.validate_event({"event":"agent.status"})
    assert(not invalid.valid)

    var bad_progress := EventParserScene.validate_event({
        "event":"agent.status",
        "timestamp":"2026-09-05T20:00:00",
        "progress":2.0
    })
    assert(not bad_progress.valid)

    print("PASS: event parser tests")
    quit()
