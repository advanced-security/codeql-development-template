/**
 * @name Print AST for python
 * @description Outputs a representation of the Abstract Syntax Tree.
 * @id python/tools/print-ast
 * @kind graph
 * @tags ast
 */

import semmle.python.PrintAst

/**
 * Temporarily tweak this class or make a copy to control
 * which functions are printed.
 */
class Cfg extends PrintAstConfiguration {
  /**
   * TWEAK THIS PREDICATE AS NEEDED.
   */
  override predicate shouldPrint(AstNode e, Location l) {
    super.shouldPrint(e, l) and
    // Only include source files with a `test` directory as the parent
    // of its containing directory, which fits the expected structure
    // of CodeQL unit tests in this project.
    l.getFile().getParent().getParent().getBaseName() = "test" and
    // Exclude the "Name" class so that results are deterministic
    // for a given source file, which is required for unit tests
    // to be useful for this query.
    not e.getAQlClass() = "Name"
  }
}
