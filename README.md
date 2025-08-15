# Aerospace Scenarios

A YAML-based window management system for [Aerospace](https://github.com/nikitabobko/aerospace) that automatically organizes your workspace based on your monitor setup.

## What It Does

**Aerospace Scenarios** solves a common problem: when you connect or disconnect external monitors, your windows get scattered across different workspaces, and you have to manually reorganize everything. This tool automatically detects your monitor count and applies the appropriate workspace layout.

### The Problem

- **Single monitor**: You want all development tools in one workspace for focused work
- **Multiple monitors**: You want to spread windows across different workspaces for better organization
- **Manual switching**: Currently requires running different scripts or manually moving windows

### The Solution

Define your ideal workspace layouts in YAML, and let the system automatically:

1. **Detect** your current monitor count
2. **Match** it to the appropriate scenario
3. **Execute** the window placement commands
4. **Organize** your workspace exactly how you want it

## How It Works

### 1. Monitor Detection

The system counts your active monitors using `aerospace list-monitors` and compares it against your defined conditions.

### 2. Scenario Matching

Each scenario defines a monitor condition (e.g., "greater than 1 monitor") and a set of commands to execute when that condition is true.

### 3. Window Resolution

The system intelligently finds your windows using three strategies:

- **App name only**: Find any window from a specific application
- **App + project**: Find windows from an app that have a title that match a folder in a provided folder. Useful for vscode like software to organize multiple windows from the same software.
- **App + title**: Find windows from an app with a specific title pattern

### 4. Command Execution

Using placeholder substitution, it runs aerospace commands to move windows to the right workspaces and set the right layouts.

## Example Use Cases

### Development Workflow

```yaml
# Single monitor: Focus mode
scenarios:
  single_monitor:
    when: { monitors: { op: eq, value: 1 } }
    commands:
      - Move Godot to workspace 5
      - Move Cursor to workspace 5
      - Set both to accordion layout
      - Switch to workspace 5

# Multiple monitors: Spread mode
scenarios:
  multi_monitor:
    when: { monitors: { op: gt, value: 1 } }
    commands:
      - Move Godot to workspace 6 (external)
      - Move Cursor to workspace 5 (main)
      - Switch between workspaces
```

### Content Creation

```yaml
# Single monitor: All-in-one
scenarios:
  single_monitor:
    when: { monitors: { op: eq, value: 1 } }
    commands:
      - Move Photoshop to workspace 3
      - Move Lightroom to workspace 3
      - Move browser to workspace 3
      - Set tiling layout

# Multiple monitors: Professional setup
scenarios:
  multi_monitor:
    when: { monitors: { op: gt, value: 1 } }
    commands:
      - Move Photoshop to workspace 4 (color-calibrated)
      - Move Lightroom to workspace 5 (preview)
      - Move browser to workspace 3 (reference)
```

## Installation

### Prerequisites

- **Aerospace**: Window manager must be installed and running
- **yq**: YAML parser (install with `brew install yq`)
- **Bash**: Version 3.2 or higher

### Setup

1. Clone this repository:

   ```bash
   git clone <your-repo-url> aerospace-scenarios
   cd aerospace-scenarios
   ```

2. Make the script executable:

   ```bash
   chmod +x aerospace-scenarios
   ```

3. Create your first scenario file (see examples below)

## Usage

### Basic Usage

```bash
# Run with default logging (to file)
./aerospace-scenarios my-scenario.yaml

# Run with verbose output
./aerospace-scenarios --verbose my-scenario.yaml

# Log to stdout only
./aerospace-scenarios --log-to-stdout my-scenario.yaml

# Custom log file
./aerospace-scenarios --log-file ~/logs/aerospace.log my-scenario.yaml
```

### Logging Options

- `--log-to-file`: Log to file only (default: `/tmp/aerospace_scenarios.log`)
- `--log-to-stdout`: Log to terminal only
- `--log-to-both`: Log to both file and terminal
- `--no-log`: Disable logging
- `--verbose`: Enable detailed debug logging

## YAML Configuration

### Basic Structure

```yaml
name: "My Workspace Setup"
workspaces:
  - name: Main
    id: 5
  - name: External
    id: 6

windows:
  - name: Editor
    find:
      type: app
      app: Cursor
  - name: Terminal
    find:
      type: app
      app: Terminal

scenarios:
  single_monitor:
    when:
      monitors:
        op: eq
        value: 1
    commands:
      - aerospace move-node-to-workspace --window-id {window:Editor} {workspace:Main}
      - aerospace move-node-to-workspace --window-id {window:Terminal} {workspace:Main}
      - aerospace workspace {workspace:Main}
```

### Window Detection Types

#### `app` - Find by application name

```yaml
- name: Browser
  find:
    type: app
    app: Arc
```

#### `app_and_project` - Find by app + project folder

```yaml
- name: ProjectEditor
  find:
    type: app_and_project
    app: Cursor
    project: ~/dev/my-project
```

#### `app_and_title` - Find by app + title pattern

```yaml
- name: GitHubTab
  find:
    type: app_and_title
    app: Arc
    title: GitHub
```

### Monitor Conditions

- `eq`: Equal to value
- `gt`: Greater than value
- `gte`: Greater than or equal to value
- `lt`: Less than value
- `lte`: Less than or equal to value

### Placeholders

- `{workspace:Name}` → Replaced with workspace ID
- `{window:Name}` → Replaced with resolved window ID

## Architecture

The system is built with modularity in mind:

```
aerospace-scenarios          # Main entry point
├── lib/
│   ├── log/
│   │   └── logging.sh      # Logging system
│   └── scenarios/
│       ├── util.sh         # Common utilities
│       ├── parse.sh        # YAML parsing
│       ├── validator.sh    # Schema validation
│       ├── resolve.sh      # Window/workspace resolution
│       └── execute.sh      # Scenario execution
└── scenarios/              # Your scenario files
    ├── development.yaml
    ├── gaming.yaml
    └── content-creation.yaml
```

## Creating Your First Scenario

1. **Identify your workflow**: What windows do you use together?
2. **Define workspaces**: What workspace IDs do you want to use?
3. **Map windows**: How should windows be grouped?
4. **Set conditions**: When should each scenario apply?

### Example: Development Setup

```yaml
name: "Development Workspace"
workspaces:
  - name: Main
    id: 5
  - name: External
    id: 6

windows:
  - name: Editor
    find:
      type: app_and_project
      app: Cursor
      project: ~/dev/current-project
  - name: Terminal
    find:
      type: app
      app: Terminal
  - name: Browser
    find:
      type: app
      app: Arc

scenarios:
  single_monitor:
    when:
      monitors:
        op: eq
        value: 1
    commands:
      - aerospace move-node-to-workspace --window-id {window:Editor} {workspace:Main}
      - aerospace move-node-to-workspace --window-id {window:Terminal} {workspace:Main}
      - aerospace move-node-to-workspace --window-id {window:Browser} {workspace:Main}
      - aerospace layout --window-id {window:Editor} accordion
      - aerospace layout --window-id {window:Terminal} accordion
      - aerospace workspace {workspace:Main}

  multi_monitor:
    when:
      monitors:
        op: gt
        value: 1
    commands:
      - aerospace move-node-to-workspace --window-id {window:Editor} {workspace:Main}
      - aerospace move-node-to-workspace --window-id {window:Terminal} {workspace:Main}
      - aerospace move-node-to-workspace --window-id {window:Browser} {workspace:External}
      - aerospace workspace {workspace:Main}
```

## Troubleshooting

### Common Issues

**"Unknown workspace/window referenced"**

- Check that all placeholders reference existing names
- Ensure names match exactly (case-sensitive)

**"Monitor condition does not hold"**

- Verify your monitor count: `aerospace list-monitors | wc -l`
- Check your condition logic (eq, gt, etc.)

**"Window not found"**

- Ensure applications are running
- Check app names match exactly
- Verify project paths exist for `app_and_project` type

**"yq command not found"**```

- Install yq: `brew install yq`
- Ensure it's in your PATH

### Debug Mode

Use `--verbose` to see detailed execution information:

```bash
./aerospace-scenarios --verbose my-scenario.yaml
```

## Contributing

The system is designed to be extensible:

- **New window detection types**: Add to `lib/scenarios/resolve.sh`
- **Additional validations**: Extend `lib/scenarios/validator.sh`
- **Custom commands**: Enhance `lib/scenarios/execute.sh`
- **Logging improvements**: Modify `lib/log/logging.sh`

## License

[Add your license information here]

## Acknowledgments

- Built for [Aerospace](https://github.com/nikitabobko/aerospace) window manager
- Inspired by the need for dynamic workspace management
- Designed for developers who work across different monitor setups
