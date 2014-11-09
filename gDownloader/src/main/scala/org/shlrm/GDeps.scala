package org.shlrm

import com.typesafe.scalalogging.LazyLogging

import scala.concurrent.{Await, Future}

object GDeps extends App with LazyLogging {

  import scala.concurrent.ExecutionContext.Implicits.global

  logger.info("Starting up!")

  //Get all the spells

  import scala.sys.process._

  //NOTE: have to execute everything inside of some bash
  val lines = Seq("bash", "-c", ". /etc/sorcery/config; codex_get_all_spells").lineStream

  logger.debug("After linestream!")

  case class SimpleSummoner(grimoire: String, section: String, spell: String) {

    //A couple mutable thingies to store our output.
    // Probably could've done it without, but I'd need vars
    val stdOut = new StringBuffer
    val stdErr = new StringBuffer

    val outputLogger = ProcessLogger(
      line => stdOut.append(line).append("\n"),
      line => stdErr.append(line).append("\n"))

    val exitStatus = Future {
      s"summon -g $grimoire $spell" !< outputLogger
    }
    override def toString(): String = {
      s"$grimoire/$section/$spell"
    }
  }

  val spellInfoStream = lines.map { l =>
    logger.debug(s"Found spell $l")

    val triad = l.replaceAll("/var/lib/sorcery/codex/", "").split("/")

    SimpleSummoner(triad(0), triad(1), triad(2))
  }

  logger.info("Created spellInfoStream")

  spellInfoStream.toList.map { f =>
    import scala.concurrent.duration._
    scala.concurrent.blocking {
      //Downloads of things could take a REALLY long time, wait 10 minutes for it to do whatever
      try {
        val exitStatus = Await.result(f.exitStatus, 10 minutes)

        exitStatus match {
          case 0 => logger.info(s"Successful download of $f")
          case _ => {
            logger.error(s"FAILED to download $f:\n${f.stdOut}\n")
          }
        }
      } catch {
        case e:Exception =>
          logger.error(s"An exception was caught while awaiting a result for $f", e)
      }
    }
  }

  logger.info("COMPLEATED")
}
