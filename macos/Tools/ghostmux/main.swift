#!/usr/bin/env swift
import Foundation

private let usage = """
ghostmux - Ghostty CLI (UDS only)

Usage:
  ghostmux <command> [options]

Commands:
  list-surfaces         List all terminals
  send-keys             Send keys to a terminal (requires -t)
  set-title             Set terminal title (requires -t)
  capture-pane, capturep  Capture pane contents (visible only by default)

Options:
  -t <target>           Target terminal (UUID, title, or UUID prefix)
  -l, --literal         Send keys literally (no special handling)
  --enter               Press Enter after sending text
  -S <start>            capture-pane start line (0 = first visible line)
  -E <end>              capture-pane end line (0 = first visible line)
  -p                    capture-pane print to stdout (default in ghostmux)
  -h, --help            Show this help

Examples:
  ghostmux list-surfaces
  ghostmux send-keys -t workspace "ls -la" --enter
  ghostmux send-keys -t 550e8400 C-c
  ghostmux set-title -t workspace "build: ghostty"
  ghostmux capture-pane -t 550e8400
  ghostmux capturep -t 550e8400 -S 0 -E 5
"""

private let commandTypes: [GhostmuxCommand.Type] = [
    ListSessionsCommand.self,
    SendKeysCommand.self,
    SetTitleCommand.self,
    CapturePaneCommand.self,
]

func printUsage() {
    print(usage)
}

func resolveCommand(_ name: String) -> GhostmuxCommand.Type? {
    for command in commandTypes {
        if command.name == name || command.aliases.contains(name) {
            return command
        }
    }
    return nil
}

func main() {
    let args = Array(CommandLine.arguments.dropFirst())
    if args.isEmpty {
        printUsage()
        return
    }

    if args.contains("-h") || args.contains("--help") {
        printUsage()
        return
    }

    let commandName = args[0]
    let commandArgs = Array(args.dropFirst())

    guard let command = resolveCommand(commandName) else {
        fputs("error: unknown command '\(commandName)'\n", stderr)
        fputs("run 'ghostmux --help' for usage\n", stderr)
        exit(1)
    }

    let client = GhostmuxClient(socketPath: defaultSocketPath())
    let context = CommandContext(args: commandArgs, client: client)

    do {
        try command.run(context: context)
    } catch let error as GhostmuxError {
        fputs("error: \(error.description)\n", stderr)
        exit(1)
    } catch {
        fputs("error: \(error)\n", stderr)
        exit(1)
    }
}

main()
