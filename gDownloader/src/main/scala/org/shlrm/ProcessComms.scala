package org.shlrm

import java.io.File
import java.nio.charset.StandardCharsets
import java.nio.file.Files

import scala.io.Source

object ProcessComms extends App {

  val file = File.createTempFile("persistentSpellInfo", ".sh")

  val content: String = Source.fromInputStream(this.getClass.getResourceAsStream("constant.sh")).mkString
  Files.write(file.toPath, content.getBytes(StandardCharsets.UTF_8))
  file.setExecutable(true, true) //make it executable only for me

  import scala.sys.process._

  val io = new ProcessIO(
    os => ???,
    stdout => ???,
    stdin => ???
  )
  val process = file.getAbsolutePath.run()


}
