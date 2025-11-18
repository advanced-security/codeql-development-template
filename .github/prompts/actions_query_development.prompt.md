---
mode: agent
---

# Actions Query Development

This prompt provides guidance for developing CodeQL queries targeting GitHub Actions workflows. For common query development patterns and best practices, see [query_development.prompt.md](query_development.prompt.md).

## Language-Specific Guidelines

### Actions CodeQL Libraries

- Import `actions` for GitHub Actions AST nodes and predicates
- Common imports: `Workflow`, `Job`, `Step`, `Uses`, `Run`, `Event`
- Use `DataFlow` for tracking data flow through workflow steps
- Import security-related predicates for Actions-specific vulnerabilities

### Actions AST Navigation

- **Workflows**: `WorkflowImpl` for workflow files
- **Actions**: `CompositeActionImpl` for composite action definitions
- **Jobs**: `JobImpl` for job definitions
- **Steps**: `StepImpl` for individual steps, `RunsImpl` for runs configuration
- **Events**: `EventImpl`, `OnImpl` for workflow triggers
- **Expressions**: `ExpressionImpl` for `${{ }}` expression syntax
- **Inputs/Outputs**: `InputsImpl`, `OutputsImpl`, `InputImpl` for input/output definitions
- **Environment**: `EnvImpl` for environment variable definitions
- **Values**: `ScalarValueImpl` for scalar string values
- **Text Components**: `StringTextComponent`, `StringInterpolationComponent` for string content

### GitHub Actions Workflow Structure

- **Triggers**: Event-based workflow triggers and conditions
- **Jobs**: Job dependencies, parallelism, and strategy matrices
- **Steps**: Sequential step execution within jobs
- **Contexts**: `github`, `env`, `secrets`, `inputs` contexts
- **Expressions**: `${{ }}` expression syntax and evaluation
- **Conditional execution**: `if` conditions on jobs and steps

### Common Actions Patterns

- **Action usage**: `step.getUses().getAction() = "actions/checkout"`
- **Script execution**: `step.getRun().getScript()` for shell commands
- **Environment variables**: Access to `env` context and variables
- **Secret usage**: `secrets.TOKEN` and secret handling
- **Matrix strategies**: Job matrix configurations
- **Artifact handling**: Upload/download artifact patterns
- **Cache usage**: Cache action patterns

### Data Flow in Actions

- Track data flow between steps and jobs
- Environment variable propagation
- Secret exposure through echo or logs
- Input/output parameter flow between actions
- Context variable usage across workflow

### Actions Security Patterns

- **Script injection**: Unsanitized user input in shell commands
- **Secret exposure**: Secrets logged or exposed in output
- **Privilege escalation**: Excessive permissions or token scope
- **Supply chain attacks**: Untrusted action usage
- **Code injection**: Dynamic script generation with user input
- **Information disclosure**: Sensitive data in logs or artifacts
- **Workflow poisoning**: Malicious workflow modifications
- **Container vulnerabilities**: Unsafe container image usage

### Actions-Specific Vulnerabilities

- **Expression injection**: `${{ github.event.issue.title }}` in scripts
- **Secret leakage**: Secrets used in contexts that log them
- **Untrusted input**: PR content used in workflow execution
- **Permissions abuse**: Overly broad `GITHUB_TOKEN` permissions
- **Third-party actions**: Unverified or malicious marketplace actions
- **Environment pollution**: Malicious environment variable injection
- **Artifact poisoning**: Untrusted artifacts affecting subsequent jobs

### GitHub Actions Context

- **GitHub context**: Repository, event, actor information
- **Runner context**: Operating system, architecture details
- **Environment context**: Environment variables and secrets
- **Job context**: Job status and outputs
- **Steps context**: Previous step outcomes and outputs
- **Strategy context**: Matrix strategy variables
- **Inputs context**: Workflow dispatch and reusable workflow inputs

### Best Practices for Actions Queries

- Check for proper input sanitization in shell scripts
- Verify minimal required permissions for workflows
- Validate third-party action versions and sources
- Ensure secrets are not logged or exposed
- Check for proper error handling in custom actions
- Verify artifact security and integrity
- Review workflow trigger conditions for safety

## CLI References

- [qlt query generate new-query](../../resources/cli/qlt/qlt_query_generate_new-query.prompt.md)
- [codeql query format](../../resources/cli/codeql/codeql_query_format.prompt.md)
- [codeql query compile](../../resources/cli/codeql/codeql_query_compile.prompt.md)
- [codeql query run](../../resources/cli/codeql/codeql_query_run.prompt.md)
