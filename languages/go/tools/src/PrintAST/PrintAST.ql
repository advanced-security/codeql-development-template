/**
 * @name Print AST for go
 * @description Outputs a representation of the Abstract Syntax Tree.
 * @id go/tools/print-ast
 * @kind graph
 * @tags ast
 */

import go
import semmle.go.PrintAst

/**
 * Temporarily tweak this class or make a copy to control
 * which functions are printed.
 */
class Cfg extends PrintAstConfiguration {
  override predicate shouldPrintFunction(FuncDecl func) { this.shouldPrintFile(func.getFile()) }

  override predicate shouldPrintFile(File file) { file.getBaseName() = "Example1.go" }

  override predicate shouldPrintComments(File file) { none() }
}
