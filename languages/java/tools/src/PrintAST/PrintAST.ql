/**
 * @name Print AST for java
 * @description Outputs a representation of the Abstract Syntax Tree.
 * @id java/tools/print-ast
 * @kind graph
 * @tags ast
 */

import java
import semmle.code.java.PrintAst
import definitions

/**
 * Temporarily tweak this class or make a copy to control
 * which functions are printed.
 */
class Cfg extends PrintAstConfiguration {
  /**
   * TWEAK THIS PREDICATE AS NEEDED.
   */
  override predicate shouldPrint(Element e, Location l) {
    super.shouldPrint(e, l) and
    l.getFile().getBaseName() = "Example1.java"
  }
}
