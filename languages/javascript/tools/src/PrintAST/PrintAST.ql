/**
 * @name Print AST for javascript
 * @description Outputs a representation of the Abstract Syntax Tree.
 * @id javascript/tools/print-ast
 * @kind graph
 * @tags ast
 */

import javascript
import semmle.javascript.PrintAst

/**
 * Temporarily tweak this class or make a copy to control
 * which functions are printed.
 */
class Cfg extends PrintAstConfiguration {
  /**
   * TWEAK THIS PREDICATE AS NEEDED.
   */
  override predicate shouldPrint(Locatable e, Location l) {
    super.shouldPrint(e, l) and
    // Only include source files with a `test` directory as the parent
    // of its containing directory, which fits the expected structure
    // of CodeQL unit tests in this project.
    l.getFile().getParentContainer().getParentContainer().getBaseName() = "test"
  }
}
