# Aerospace Scenario System

A flexible, YAML-based window management system for Aerospace that allows you to define different workspace layouts and window arrangements based on monitor conditions.

## Features

- **Multiple Scenarios**: Define different scenarios for different monitor setups
- **Monitor Conditions**: Execute scenarios based on monitor count (eq, gt, gte, lt, lte)
- **Flexible Window Detection**: Find windows by app name, app+project, or app+title
- **Placeholder Substitution**: Use `{workspace:Name}` and `{window:Name}` in commands
- **Validation**: Full YAML schema validation before execution
- **Modular Design**: Small, focused functions for easy maintenance

## Requirements

- `yq` (mikefarah v4) - Install with `brew install yq`
- `aerospace` CLI available in PATH
- Bash 3.2+

## Quick Start

1. **Create a scenario file** (see `example.yaml` for reference)
2. **Run the scenario**: `bash lib/scenarios/run.sh your_scenario.yaml`

## YAML Structure

```yaml
name: Scenario Name
workspaces:
  - name: Main
    id: 5
  - name: Second
    id: 6

windows:
  - name: Godot
    find:
      type: app
      app: Godot
  - name: CursorGodotProj
    find:
      type: app_and_project
      app: Cursor
      project: ~/dev/godot

scenarios:
  multi_monitor:
    when:
      monitors:
        op: gt
        value: 1
    commands:
      - aerospace move-node-to-workspace --window-id {window:Godot} {workspace:Second}
      - aerospace workspace {workspace:Second}

  single_monitor:
    when:
      monitors:
        op: eq
        value: 1
    commands:
      - aerospace move-node-to-workspace --window-id {window:Godot} {workspace:Main}
      - aerospace layout --window-id {window:Godot} accordion
```

## Window Detection Types

### `app`

Find window by application name only.

```yaml
- name: Terminal
  find:
    type: app
    app: Terminal
```

### `app_and_project`

Find window by app name and project folder match. This will get the list of folders in the provided project folder, and try to make a match with one of the windows found by app name.

```yaml
- name: CursorProject
  find:
    type: app_and_project
    app: Cursor
    project: ~/dev/myproject
```

### `app_and_title`

Find window by app name and title string match.

```yaml
- name: BrowserTab
  find:
    type: app_and_title
    app: Arc
    title: GitHub
```

## Monitor Conditions

- `eq`: Equal to value
- `gt`: Greater than value
- `gte`: Greater than or equal to value
- `lt`: Less than value
- `lte`: Less than or equal to value

## Placeholders

- `{workspace:Name}` → Replaced with workspace ID
- `{window:Name}` → Replaced with resolved window ID

## Example Usage

```bash
bash .../aerospace-scenarios/run.sh frontend-development.yaml
```

## Architecture

- `util.sh`: Common utilities and logging
- `parse.sh`: YAML parsing functions
- `validator.sh`: Schema validation
- `resolve.sh`: Window and workspace resolution
- `execute.sh`: Scenario execution logic
- `run.sh`: Main entry point

## Troubleshooting

### "Unknown workspace/window referenced"

- Check that all placeholders in commands reference existing names
- Ensure workspace and window names match exactly (case-sensitive)

### "Monitor condition does not hold"

- Verify your monitor count matches the condition
- Use `aerospace list-monitors | wc -l` to check current count

### "Window not found"

- Ensure the target applications are running
- Check that project paths exist for `app_and_project` type
- Verify app names match exactly

### "yq command not found"

- Install yq: `brew install yq`
- Ensure it's in your PATH

## Extending

The system is designed to be modular. You can:

- Add new window detection types in `resolve.sh`
- Extend validation rules in `validator.sh`
- Add new command types in `execute.sh`
- Create custom logging in `util.sh`
