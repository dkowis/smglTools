package org.shlrm

import java.io.{ByteArrayInputStream, File}
import java.nio.charset.StandardCharsets
import java.nio.file.Files
import java.util.concurrent.{Executors, LinkedBlockingQueue}
import java.util.concurrent.atomic.AtomicBoolean

import com.typesafe.scalalogging.LazyLogging

import scala.concurrent.{ExecutionContext, Promise, Future}
import scala.io.Source
import scala.util.Success

class SpellInfoProvider(resource: String = "/constant.sh") extends LazyLogging {

  import org.shlrm.SpellFormat._

  val tempFile = File.createTempFile("persistentSpellInfo", ".sh")
  val content = Source.fromInputStream(this.getClass.getResourceAsStream(resource)).mkString
  Files.write(tempFile.toPath, content.getBytes(StandardCharsets.UTF_8))
  tempFile.setExecutable(true, true)

  //Need a limit on the number of threads that can exist, 4 is probably safe
  implicit val singleExecutionContext = ExecutionContext.fromExecutor(Executors.newFixedThreadPool(4))
  import scala.sys.process._

  val stopped = new AtomicBoolean(false)

  private val inputLock = new Object()

  val toProcess = new LinkedBlockingQueue[String]()
  val fromProcess = new LinkedBlockingQueue[String]()

  val lineAppender = new Appendable {
    val buffer = new StringBuffer()

    def checkForLinePlace() = {
      val currentString = buffer.toString
      if (currentString.contains("\n")) {
        //It's got one newline at least, so lets grab the sequence from start to newline, and place it as output
        val start = 0
        val end = currentString.indexOf('\n') + 1
        val line = currentString.substring(start, end) //because the substring end is exclusive
        fromProcess.add(line) //Stick it in the thingy
        buffer.delete(start, end) //take it out of the buffer
      }
    }

    override def append(charSequence: CharSequence): Appendable = {
      buffer.append(charSequence)
      checkForLinePlace()
      this
    }

    override def append(charSequence: CharSequence, i: Int, i1: Int): Appendable = {
      buffer.append(charSequence, i, i1)
      checkForLinePlace()
      this
    }

    override def append(c: Char): Appendable = {
      buffer.append(c)
      checkForLinePlace()
      this
    }
  }

  val io = new ProcessIO(
    stdin => {
      var running = true
      while (running) {
        val toSend = toProcess.take() + "\n"
        val content = new ByteArrayInputStream(toSend.getBytes())
        BasicIO.transferFully(content, stdin)
        stdin.flush()
        if (toSend.trim() == "stop") {
          running = false
          stopped.set(true)
        }
      }
    },
    BasicIO.processFully(lineAppender),
    BasicIO.processFully(stderr) //TODO: this should go somewhere else, but meh for now
  )

  //finally fire up the process
  val process = tempFile.getAbsolutePath.run(io)


  def spellInfo(spellPath: String): Future[Spell] = {
    logger.debug(s"Request: SpellInfo: $spellPath")
    if (stopped.get) {
      throw new Exception("STOPPED!")
    }
    val promise = Promise[Spell]()
    Future {
      import scala.concurrent.blocking
      //send output to the shell program and get a line back...
      blocking {
        //TODO: this still might have problems and things could get out of sync...
        val response = inputLock.synchronized {
          toProcess.put(spellPath)
          fromProcess.take()
        }
        //JSON MARSHALLING TIME
        try {
          import spray.json._
          import SpellFormatProtocol._

          val marshalled = response.parseJson.convertTo[Spell]
          logger.debug(s"Complete: SpellInfo: $spellPath")
          promise.complete(Success(marshalled))
        } catch {
          case e: Exception =>
            promise.failure(e)
        }
      }
    }
    promise.future
  }

  def shutdown() = {
    toProcess.put("stop")
  }

}
