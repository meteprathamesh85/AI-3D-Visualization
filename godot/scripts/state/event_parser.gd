class_name EventParser
extends RefCounted

const REQUIRED_FIELDS := ["event", "timestamp"]

static func parse_json_line(text: String) -> Dictionary:
    var parsed = JSON.parse_string(text)
    if parsed == null or not parsed is Dictionary:
        return {}
    return parsed

static func validate_event(event: Dictionary) -> Dictionary:
    var result := {"valid": true, "errors": []}
    for field in REQUIRED_FIELDS:
        if not event.has(field):
            result.valid = false
            result.errors.append("Missing field: %s" % field)
    if event.has("progress"):
        var p = event.progress
        if not (p is int or p is float):
            result.valid = false
            result.errors.append("progress must be numeric")
        elif float(p) < 0.0 or float(p) > 1.0:
            result.valid = false
            result.errors.append("progress must be between 0 and 1")
    return result
