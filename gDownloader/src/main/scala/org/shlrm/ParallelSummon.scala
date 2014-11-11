package org.shlrm

import com.typesafe.scalalogging.LazyLogging

import scala.annotation.tailrec
import scala.concurrent.{Await, Future}

object ParallelSummon extends App with LazyLogging {

  import scala.concurrent.ExecutionContext.Implicits.global
  import scala.sys.process._

  logger.info("Starting up!")


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

  //NOTE: have to execute everything inside of some bash
  //Get all the spells
  // Always use a def for streams, not a val, you want to not keep it all around forever!
  def spellStream = Seq("bash", "-c", ". /etc/sorcery/config; codex_get_all_spells").lineStream.map {l =>
    logger.debug(s"Found spell $l")

    val triad = l.replaceAll("/var/lib/sorcery/codex/", "").split("/")

    SimpleSummoner(triad(0), triad(1), triad(2))
  }

//  val iterator = spellStream.toIterator
//
//  iterator.foreach { item =>
//
//  }

  logger.info("Created spellInfoStream")
  //Need to not convert this stream to a list... It keeps too many things around

  /**
   * Have to use this so that we throw objects away, so they can be collected, otherwise I'm keeping *ALL* the string
   * output from every spell in memory. Derp.
   * @param stream
   */
  @tailrec
  def consumeStream(stream: Stream[SimpleSummoner]):Unit = {
    if(stream.nonEmpty) {
      //If the stream is non empty, take one, and do something with it, then recurse
      val summon = stream.head
      import scala.concurrent.duration._
      scala.concurrent.blocking {
        //Downloads of things could take a REALLY long time, wait 10 minutes for it to do whatever
        try {
          val exitStatus = Await.result(summon.exitStatus, 10 minutes)

          exitStatus match {
            case 0 => logger.info(s"Successful download of $summon")
            case _ => {
              logger.error(s"FAILED to download $summon:\n${summon.stdOut}\n")
            }
          }
        } catch {
          case e:Exception =>
            logger.error(s"An exception was caught while awaiting a result for $summon", e)
        }
      }

      consumeStream(stream.tail)
    }
  }

  consumeStream(spellStream)

  logger.info("COMPLEATED")
}
