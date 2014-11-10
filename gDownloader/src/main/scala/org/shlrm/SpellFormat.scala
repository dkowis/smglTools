package org.shlrm

trait SpellFormat {

  case class SourceFile(fileName: String, hash: String, urls: List[String])

  case class Spell(version: String, sourceFiles: List[SourceFile])

}
