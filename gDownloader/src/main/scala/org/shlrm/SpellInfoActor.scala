package org.shlrm

import java.io.{PrintWriter, File}
import java.nio.charset.StandardCharsets
import java.nio.file.{Files, Paths}

import akka.actor.{ActorLogging, Actor}
import akka.actor.Actor.Receive

import scala.io.Source

object SpellInfoActorProtocol extends SpellFormat {

  case class InfoRequest(path: String)

}

class SpellInfoActor extends Actor with ActorLogging {

  import SpellInfoActorProtocol._

  var shellFile: Option[File] = None
  var process: Option[Process] = None

  var processInput:Option[PrintWriter] = None


  @throws[Exception](classOf[Exception])
  override def preStart(): Unit = {
    // Start up the shell script
    //Create a temp file, and make it executable
    val file = File.createTempFile("persistentSpellInfo", ".sh")
    shellFile = Some(file)

    val content: String = Source.fromInputStream(self.getClass.getResourceAsStream("constant.sh")).mkString
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

  @throws[Exception](classOf[Exception])
  override def postStop(): Unit = {
    //send stop to the shell script and make sure it terminated
  }

  override def receive: Receive = {
    case _ =>
      log.info("WOO")
  }
}
