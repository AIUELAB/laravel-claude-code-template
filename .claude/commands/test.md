# Run Tests

Execute PHPUnit tests with various options.

## Usage

Optional arguments:
- (none) - Run all tests
- `--filter=TestName` - Run specific test
- `--coverage` - With coverage report
- `Feature` - Run only feature tests
- `Unit` - Run only unit tests

## Instructions

1. Run tests in Docker container:
   ```bash
   docker compose exec app php artisan test $ARGUMENTS
   ```

2. Parse and summarize results:
   - Total tests run
   - Passed / Failed / Skipped
   - Execution time
   - Coverage percentage (if --coverage)

3. For failures:
   - Show the failing test name
   - Show the assertion that failed
   - Suggest potential fixes

4. If all tests pass, confirm with a success message.

## Tips

- Use `--parallel` for faster execution on large test suites
- Use `--stop-on-failure` to stop at first failure
