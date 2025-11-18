/**
 * @name Print AST for actions
 * @description Outputs a representation of the Abstract Syntax Tree.
 * @id actions/tools/print-ast
 * @kind graph
 * @tags ast
 */

private import codeql.actions.ideContextual.IDEContextual
import codeql.actions.ideContextual.printAst
private import codeql.actions.Ast

/**
 * Temporarily tweak this class or make a copy to control
 * which functions are printed.
 */
class Cfg extends PrintAstConfiguration {
  /**
   * TWEAK THIS PREDICATE AS NEEDED.
   */
  override predicate shouldPrintNode(PrintAstNode n) {
    super.shouldPrintNode(n) and
    // Only include source files with a `test` directory as the parent
    // of its containing directory, which fits the expected structure
    // of CodeQL unit tests in this project.
    (
      // For a file located under some `test/*/.github/worklows` directory structure
      n.getLocation()
          .getFile()
          .getParentContainer()
          .getParentContainer()
          .getParentContainer()
          .getParentContainer()
          .getBaseName() = "test"
      or
      // For a file located under some `test/*/*/action.yml` directory structure
      n.getLocation()
          .getFile()
          .getParentContainer()
          .getParentContainer()
          .getParentContainer()
          .getBaseName() = "test" and
      n.getLocation().getFile().getBaseName() = "action.yml"
    )
  }
}
