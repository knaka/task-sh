<!-- +INCLUDE: ./README.md -->
# Task Runner Written in Shell Script

## Running Tasks

* The task runner is invoked with `./task` on Linux and macOS, or `.\task.cmd` on Windows.
* On Windows, `task.cmd` installs BusyBox for Windows if not already installed and runs the scripts with it.
* Running `./task` without arguments shows available tasks/subcommands.
* Tasks `foo:bar` and `baz` are executed with `./task foo:bar baz[arg1,arg2]`. Arguments are passed in brackets.
* The task runner is written in shell script and the task `foo:bar` is implemented as the shell script function `task_foo__bar`.
* Subcommand `qux` is executed as `./task qux arg1 arg2` and is implemented as the shell script function `subcmd_qux`.

## Task Files and Directory Structure

* The entry point is `./task` on Linux and macOS, or `.\task.cmd` on Windows.
* Task files (`task.sh` and `task-*.lib.sh`) can be stored in the top directory of the project or in the `./tasks/` directory. All task script files should be placed in the same directory to ensure proper `source` functionality between scripts, so splitting them across directories is not recommended.
* Project-specific tasks/subcommands are defined in `task-project.lib.sh`, while other library tasks/subcommands are stored in `task-*.lib.sh` files.

## Shell Script Grammar

* The shell scripts should be executable with Bash, Dash, and BusyBox Ash.
* Therefore, the shell scripts should only use POSIX shell features.
* However, `local` variable declarations are not part of POSIX shell features, but they can be used as they are available in the shells listed above.
<!-- +END -->

<!-- +INCLUDE: ./DEVELOPMENT.md -->
# Developer Guide for Task Runner

## Testing

To run all tests in `test-*.lib.sh`:
```bash
./task test
```

To run specific tests only, specify the test names as arguments. The following example runs test functions `test_foo` and `test_bar`:

```bash
./task test foo bar
```
<!-- +END -->
