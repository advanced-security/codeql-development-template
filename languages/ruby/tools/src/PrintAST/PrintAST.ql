/**
 * @name Print AST for ruby
 * @description Outputs a representation of the Abstract Syntax Tree.
 * @id ruby/tools/print-ast
 * @kind graph
 * @tags ast
 */

private import codeql.ruby.AST
private import codeql.ruby.printAst

/**
 * Temporarily tweak this class or make a copy to control
 * which functions are printed.
 */
class Cfg extends PrintAstConfiguration {
  /**
   * TWEAK THIS PREDICATE AS NEEDED.
   */
  override predicate shouldPrintNode(AstNode n) { super.shouldPrintNode(n) }
}
