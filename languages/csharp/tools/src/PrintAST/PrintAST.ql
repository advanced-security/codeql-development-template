/**
 * @name Print AST for csharp
 * @description Outputs a representation of the Abstract Syntax Tree.
 * @id csharp/tools/print-ast
 * @kind graph
 * @tags ast
 */

import csharp
import semmle.code.csharp.PrintAst

/**
 * Temporarily tweak this class or make a copy to control
 * which functions are printed.
 */
class Cfg extends PrintAstConfiguration {
  /**
   * TWEAK THIS PREDICATE AS NEEDED.
   */
  override predicate shouldPrint(Element e, Location l) { super.shouldPrint(e, l) }
}
