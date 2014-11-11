package org.shlrm

import spray.json.DefaultJsonProtocol

/**
 * A container for the JSON marshalling of the spell format
 */
object SpellFormat {

  case class SourceFile(fileName: String, hash: String, urls: List[String])

  case class Spell(spellPath:String, version: String, sourceFiles: List[SourceFile])

  object SpellFormatProtocol extends DefaultJsonProtocol {
    implicit val sourceFileFormat = jsonFormat3(SourceFile)
    implicit val spellFormat = jsonFormat3(Spell)
  }
}
