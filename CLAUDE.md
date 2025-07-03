<!-- +INCLUDE: ./DEVELOPMENT.md -->
# Guide for developers

## Project Structure

* Project specific tasks/subcommands are defined in `task-project.lib.sh` .

## Shell script

* The shell scripts should be executable with Bash, Dash, and BusyBox Ash.
* Therefore, the shell scripts should only use POSIX shell features.
* However, `local` variable declarations are not part of POSIX shell features, but they can be used as they are available in many shell implementations.

## Testing

To run tests in `test-*.lib.sh`:
```bash
./task test
```

To run specific tests only, specify the test names as arguments. The following example runs functions `test_foo` and `test_bar`:

```bash
./task test foo bar
```
<!-- +END -->
