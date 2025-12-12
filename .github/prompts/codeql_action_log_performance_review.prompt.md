---
mode: agent
---
You are reviewing CodeQL log output for performance issues.

It is critical that you understand key aspects of CodeQL log output that can flag performance issues.  Understanding the language being scanned is critical to the performance review process.  You should be able to identify the language being scanned, the number of files in the database, and the number of lines of code in the database.  You should also be able to identify the time taken to extract the code from the database, build the database, and analyze the code.

In general, look for the following key aspects in the log output:
- The time taken to extract the code from into the CodeQL database insert format (`Extracting ..` and `Done extracting ..` will be logged for each file)
- The time taken to create/optimize the database indicates size/complexity (`TRAP import`)
- The time taken to analyze the code (each query: `[##/## eval ###ms] Evaluation done; writing results to... `)
- The number of files in the database vs the number of files in the baseline (`CodeQL scanned <# in DB> out of <# in baseline > <language> files ... in this invocation`)
- The number of lines of code in the database (if in debug mode `Total lines of user written <language(s)> code in the database`)

## Agent AI Instructions

These log files will be huge, instead of reading them line by line - run grep style commands in the cli to investigate the file.


## Review Areas

### Excluding Code

This is one of the most important aspects of CodeQL performance.  Excluding a file from analysis will speed up extraction, database creation, query execution, and result generation. We would expect to see some number of files excluded from the scan.  Scanning unit tests or vendored dependencies is often not useful, and can slow down the scan.  Any interpreted language or compiled that utilizes `build-mode: none` can take advantage of a `paths-ignore` array in a CodeQL configuration file.

To analyze this aspect, look for the following key aspects in the log output:
- In general, the number of files in the database vs the number of files in the baseline should not match (`CodeQL scanned <# in DB> out of <# in baseline > <language> files ... in this invocation`) - this indicates no exclusions were made.
- Extractor output `Done extracting /home/runner/work/<repo>/<repo>/src/public/static/3rd-party-static/<CommonPackageName.2.1.0>.js (11164 ms)`
  - Identifying common 3rd party libraries by name and version can be a good indicator of files that should be excluded from the scan. For example `jquery.3.5.1.js` or `react.16.8.6.js`.  These are commonly in a parent folder that indicates all files contained are vendored and should be completely excluded from the scan using a `paths-ignore` array entry in the `codeql.yml` file.  For example, `paths-ignore: [ '**/public/static/3rd-party-static/**' ]`.
  - Call out any timings > 1000ms for extraction `(11164 ms)` - often times this indicates a large bundled JS file (and other files in the same folder are often Generated or vendored).


See also: https://docs.github.com/en/code-security/code-scanning/troubleshooting-code-scanning/analysis-takes-too-long#reduce-the-amount-of-code-being-analyzed-in-a-single-workflow

### Hardware Recommendations

The default GitHub runner is 8GB of RAM and 2 CPUs.  This is often not enough power for extracting code from large repos or scanning through complex databases. A RAM ~7GB `CODEQL_RAM: 6914` and 2 cores `CODEQL_THREADS: 2` will likely indicate this is running on the default runner.

The recommended hardware sizes for running CodeQL are based off of lines of code:
- Small (<100 K lines of code) = 8 GB or higher	2 cores
- Medium (100 K to 1 M lines of code) =	16 GB or higher	4 or 8 cores
- Large (>1 M lines of code) =	64 GB or higher	8 cores

See also: https://docs.github.com/en/code-security/code-scanning/troubleshooting-code-scanning/analysis-takes-too-long#increase-the-memory-or-cores

`Compiling in one thread due to RAM limits.` is an indication that there is limited RAM available.  This is not often critical as the CodeQL bundle is used that includes precompiled queries.

### Breaking apart monorepos

CodeQL can detect data flows through the code but once it reaches a process boundary the flow is stopped. This creates a natural separation point for CodeQL scans based on data flows. Creating a CodeQL scan configuration that separates applications by front end (ex: Web.sln) and back end code(ex: API.sln) that are separated by process/network boundaries would be optimal for performance.  This would allow for a smaller database to be created and analyzed.  The time taken to extract the code from the database, build the database, and analyze the code would all be reduced.  This would further enable a decrease in wall-clock scan time by using parallel per-solution scans using an Actions matrix strategy (such that each gets its own runtime and resources). It will be important to include your common framework code in each solution so that you get a successful compilation while you further analyze other ways to share code.

Consider utilizing the https://github.com/advanced-security/monorepo-code-scanning-action that builds scan filters based on the monorepo structure as defined in a `projects.json` to describe the monorepo project structure.  Further this will optimize scanning by detectiong which projects have changed on a PR and only scanning those projects.  Each project will be analyzed in parallel and the results will be combined into a single report.  This will further reduce the time taken to scan the monorepo.


To find this scenario - review the extractor logs and identify common project structures that might indicate indivdidual applications that would not have any cross method calls OR data flows. Commonly applications will be organized by various techniques - if any of these appear like good candidates for separation, please call them out:
- monorepo structure (ex: `apps/` or `services/`)
- front end web/api / middle tier api / back end data access
- common project structures (ex: `src/` or `lib/` or `framework/` or `common/`)
