package org.shlrm

import java.io.{ByteArrayInputStream, File}
import java.nio.charset.StandardCharsets
import java.nio.file.Files
import java.util.concurrent.{LinkedBlockingDeque, LinkedBlockingQueue, ConcurrentLinkedDeque, ConcurrentLinkedQueue}
import java.util.concurrent.atomic.{AtomicBoolean, AtomicReference}

import com.typesafe.scalalogging.LazyLogging

import scala.io.Source

object ProcessComms extends App with LazyLogging {

  val file = File.createTempFile("persistentSpellInfo", ".sh")

  val content: String = Source.fromInputStream(this.getClass.getResourceAsStream("/constant.sh")).mkString
  Files.write(file.toPath, content.getBytes(StandardCharsets.UTF_8))
  file.setExecutable(true, true) //make it executable only for me

  import scala.sys.process._

  //Somewhere to put our output

  val lines = new LinkedBlockingQueue[String]()
  val output = new LinkedBlockingQueue[String]()

  val running = new AtomicBoolean(true)

  val stdout = new StringBuffer
  val stderr = new StringBuffer

  val thingy = new Appendable {
    override def append(charSequence: CharSequence): Appendable = {
      if(!charSequence.toString.trim.isEmpty) {
        output.add(charSequence.toString)
      }
      this
    }

    override def append(charSequence: CharSequence, i: Int, i1: Int): Appendable = {
      //TODO: this is probably wrong, as it should build up an entire line
      logger.info(s"Appending partial: $charSequence, $i, $i1")
      output.add(charSequence.subSequence(i, i1).toString)
      this
    }

    override def append(c: Char): Appendable = {
      logger.info(s"Appending single character: $c")
      //TODO: this might be wrong, as it should probably build up an entire newline
      output.add(c.toString)
      this
    }
  }


  val io = new ProcessIO(
    stdin => {
      var running = true
      while (running) {
        val line = lines.take() + "\n" //TODO: this is super forever blocking
        logger.info(s"Got a line to write: ${line}")
        val content = new ByteArrayInputStream(line.getBytes)
        BasicIO.transferFully(content, stdin)
        stdin.flush()
        if(line == "stop") {
          running = false
        }
      }
    },
    BasicIO.processFully(thingy),
    BasicIO.processFully(stderr)
  )


  val process = file.getAbsolutePath.run(io)

  //it's running, now lets feed it some stuff

  //send it a line...
  lines.add("/var/lib/sorcery/codex/stable/gnustep-libs/gnustep-performance")
  logger.info(s"Entire queue is: ${output.size()}")
  val response = output.take()
  logger.info(s"FIRST RESPONSE: $response")
  logger.info(s"Entire queue is: ${output.size()}")

  lines.add("/var/lib/sorcery/codex/stable/graphics/cinclude2dot")
  logger.info(s"SECOND RESPONSE: ${output.take()}")
  logger.info(s"Entire queue is: ${output.size()}")

  lines.add("stop")
  logger.info("Should shut down now...")

  val exitValue = process.exitValue()
  logger.info(s"exit value is: $exitValue")
}
